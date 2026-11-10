-- Workflow support for Milestone 2 screens 6-10. Actor IDs must come from
-- authenticated server sessions, never directly from browser form fields.
DROP TRIGGER IF EXISTS enrollment_before_insert;
DROP TRIGGER IF EXISTS proof_before_update;
DROP TRIGGER IF EXISTS request_before_insert;
DROP PROCEDURE IF EXISTS submit_original_grade;
DROP PROCEDURE IF EXISTS submit_course_grades;
DROP PROCEDURE IF EXISTS review_correction;
DELIMITER $$
CREATE TRIGGER enrollment_before_insert BEFORE INSERT ON ENROLLMENT
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM STUDENT s JOIN COURSE_CONTEXT c
          ON s.university_id=c.university_id
          WHERE s.student_id=NEW.student_id AND c.course_id=NEW.course_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Enrollment requires the same university';
    END IF;
END$$

CREATE TRIGGER proof_before_update BEFORE UPDATE ON DISCLOSURE_PROOF
FOR EACH ROW
BEGIN
    IF OLD.status='revoked' AND NEW.status<>'revoked' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Revocation cannot be undone';
    END IF;
    IF NEW.status='revoked' AND OLD.status<>'revoked' THEN
        SET NEW.revoked_at=NOW();
    END IF;
END$$

CREATE TRIGGER request_before_insert BEFORE INSERT ON CORRECTION_REQUEST
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
        WHERE g.grade_id=NEW.grade_id AND c.instructor_id=NEW.instructor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Request must come from the course instructor';
    END IF;
    -- Historical approved requests refer to the old grade they replaced.
    IF NEW.status IN ('draft','pending') AND NOT EXISTS (
        SELECT 1 FROM GRADE g WHERE g.grade_id=NEW.grade_id
          AND g.checkpoint_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Request must target the current sealed grade';
    END IF;
END$$

CREATE PROCEDURE submit_original_grade(
    IN p_instructor INT, IN p_grade_id INT, IN p_student INT,
    IN p_course INT, IN p_letter VARCHAR(2)
)
BEGIN
    DECLARE v_salt CHAR(64);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM COURSE_CONTEXT c JOIN ENROLLMENT e ON e.course_id=c.course_id
        WHERE c.course_id=p_course AND c.instructor_id=p_instructor AND e.student_id=p_student
          AND (c.submission_deadline IS NULL OR NOW()<=c.submission_deadline)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unauthorized, unenrolled or past the grade deadline';
    END IF;
    SET v_salt=HEX(RANDOM_BYTES(32));
    INSERT INTO GRADE (grade_id,student_id,course_id,letter_grade,salt,leaf_hash)
    VALUES (p_grade_id,p_student,p_course,p_letter,v_salt,
            SHA2(CONCAT_WS('|',p_grade_id,p_student,p_course,p_letter,v_salt),256));
    DELETE FROM GRADE_DRAFT WHERE student_id=p_student AND course_id=p_course;
    COMMIT;
END$$

-- JSON batch contains explicit grade_id, student_id and letter_grade values.
-- The entire enrolled roster is validated and submitted in one transaction.
CREATE PROCEDURE submit_course_grades(IN p_instructor INT,IN p_course INT,IN p_batch JSON)
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_grade INT;
    DECLARE v_student INT;
    DECLARE v_letter VARCHAR(2);
    DECLARE v_salt CHAR(64);
    DECLARE v_expected INT;
    DECLARE v_seen INT;
    DECLARE v_distinct INT;
    DECLARE v_bad INT;
    DECLARE roster CURSOR FOR
        SELECT grade_id,student_id,letter_grade FROM JSON_TABLE(p_batch,'$[*]' COLUMNS(
            grade_id INT PATH '$.grade_id',student_id INT PATH '$.student_id',
            letter_grade VARCHAR(10) PATH '$.letter_grade')) batch_rows;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done=TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    IF p_batch IS NULL OR JSON_TYPE(p_batch)<>'ARRAY' OR NOT EXISTS (
        SELECT 1 FROM COURSE WHERE course_id=p_course AND instructor_id=p_instructor
        AND (submission_deadline IS NULL OR NOW()<=submission_deadline)
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid batch, instructor or submission deadline'; END IF;
    SELECT COUNT(*) INTO v_expected FROM ENROLLMENT WHERE course_id=p_course;
    SELECT COUNT(*),COUNT(DISTINCT student_id),
        COALESCE(SUM(grade_id IS NULL OR grade_id<=0 OR student_id IS NULL OR letter_grade IS NULL
            OR letter_grade NOT IN ('A','A-','B+','B','B-','C+','C','C-','D+','D','F')
            OR NOT EXISTS (SELECT 1 FROM ENROLLMENT e WHERE e.course_id=p_course AND e.student_id=b.student_id)),0)
        INTO v_seen,v_distinct,v_bad
    FROM JSON_TABLE(p_batch,'$[*]' COLUMNS(grade_id INT PATH '$.grade_id',student_id INT PATH '$.student_id',
        letter_grade VARCHAR(10) PATH '$.letter_grade')) b;
    IF v_expected=0 OR v_expected<>v_seen OR v_seen<>v_distinct OR v_bad<>0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Batch must contain one valid grade per enrolled student';
    END IF;
    OPEN roster;
    grade_loop: LOOP
        FETCH roster INTO v_grade,v_student,v_letter;
        IF v_done THEN LEAVE grade_loop; END IF;
        SET v_salt=HEX(RANDOM_BYTES(32));
        INSERT INTO GRADE (grade_id,student_id,course_id,letter_grade,salt,leaf_hash)
        VALUES (v_grade,v_student,p_course,v_letter,v_salt,
            SHA2(CONCAT_WS('|',v_grade,v_student,p_course,v_letter,v_salt),256));
    END LOOP;
    CLOSE roster;
    DELETE FROM GRADE_DRAFT WHERE course_id=p_course;
    COMMIT;
END$$

-- p_new_grade_id is an application-assigned unused ID. A duplicate is rejected
-- atomically; an allocator must retry collisions rather than use unlocked MAX+1.
CREATE PROCEDURE review_correction(
    IN p_request INT, IN p_registrar_university INT, IN p_approve BOOLEAN,
    IN p_comment VARCHAR(500), IN p_new_grade_id INT
)
BEGIN
    DECLARE v_grade INT DEFAULT NULL;
    DECLARE v_student INT;
    DECLARE v_course INT;
    DECLARE v_letter VARCHAR(2);
    DECLARE v_reason VARCHAR(500);
    DECLARE v_salt CHAR(64);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    SELECT r.grade_id,g.student_id,g.course_id,r.proposed_letter_grade,r.change_reason
        INTO v_grade,v_student,v_course,v_letter,v_reason
    FROM CORRECTION_REQUEST r JOIN GRADE g ON g.grade_id=r.grade_id
    JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE r.request_id=p_request AND r.status='pending'
      AND c.university_id=p_registrar_university FOR UPDATE;
    IF v_grade IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No pending request for this university';
    END IF;
    IF p_approve IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Approval decision is required';
    END IF;
    IF p_approve THEN
        SET v_salt=HEX(RANDOM_BYTES(32));
        INSERT INTO GRADE
            (grade_id,student_id,course_id,supersedes_grade_id,letter_grade,salt,leaf_hash,change_reason)
        VALUES (p_new_grade_id,v_student,v_course,v_grade,v_letter,v_salt,
            SHA2(CONCAT_WS('|',p_new_grade_id,v_student,v_course,v_letter,v_salt),256),v_reason);
        UPDATE CORRECTION_REQUEST SET status='approved', reviewed_at=NOW(),
            reviewer_comment=p_comment, approved_grade_id=p_new_grade_id WHERE request_id=p_request;
    ELSE
        IF p_comment IS NULL OR CHAR_LENGTH(TRIM(p_comment))=0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rejecting a request requires a comment';
        END IF;
        UPDATE CORRECTION_REQUEST SET status='rejected', reviewed_at=NOW(),
            reviewer_comment=p_comment WHERE request_id=p_request;
    END IF;
    COMMIT;
END$$
DELIMITER ;
