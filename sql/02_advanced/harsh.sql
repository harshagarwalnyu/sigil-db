-- Advanced commands: Harsh
-- Uses the ERD table names (UPPER_SNAKE_CASE) and Milestone 1 column names.
--
-- 1. TRIGGERS   grade_before_insert / grade_before_update / grade_before_delete
--               Keep Grade append-only: no deletes, no edits, corrections are new rows.
-- 2. FUNCTION   is_proof_valid(proof_id)
--               What the verifier screens check before showing a proof as valid.
-- 3. PROCEDURE  publish_checkpoint(university_id, term, root_hash, signature)
--               Seals every unpublished grade of a term into a new Merkle checkpoint.

DROP TRIGGER IF EXISTS grade_before_insert;
DROP TRIGGER IF EXISTS grade_before_update;
DROP TRIGGER IF EXISTS grade_before_delete;
DROP FUNCTION IF EXISTS is_proof_valid;
DROP PROCEDURE IF EXISTS publish_checkpoint;

DELIMITER $$

-- ---------------------------------------------------------------------------
-- 1a. New grade rows must follow the correction rules.
--     Original grade: only one per student per course.
--     Correction: must point at an existing grade for the SAME student and
--     course, that grade must not already be corrected, and a reason is required.
-- ---------------------------------------------------------------------------
CREATE TRIGGER grade_before_insert
BEFORE INSERT ON GRADE
FOR EACH ROW
BEGIN
    DECLARE old_student INT DEFAULT NULL;
    DECLARE old_course  INT DEFAULT NULL;

    IF NOT EXISTS (
        SELECT 1 FROM STUDENT s JOIN COURSE c
          ON c.university_id = s.university_id
        WHERE s.student_id = NEW.student_id AND c.course_id = NEW.course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student and course must belong to the same university';
    END IF;

    IF NEW.checkpoint_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM MERKLE_CHECKPOINT mc JOIN COURSE c
          ON c.university_id = mc.university_id AND c.term = mc.term
        WHERE mc.checkpoint_id = NEW.checkpoint_id AND c.course_id = NEW.course_id
          AND NEW.leaf_index IS NOT NULL
          AND NEW.leaf_index >= 0 AND NEW.leaf_index < mc.leaf_count
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkpoint must match the course university, term and leaf range';
    END IF;

    IF NEW.supersedes_grade_id IS NULL THEN
        IF EXISTS (SELECT 1 FROM GRADE
                   WHERE student_id = NEW.student_id
                     AND course_id  = NEW.course_id
                     AND supersedes_grade_id IS NULL) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Student already has a grade for this course; add a correction instead';
        END IF;
    ELSE
        SELECT student_id, course_id INTO old_student, old_course
        FROM GRADE WHERE grade_id = NEW.supersedes_grade_id;

        IF old_student IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'The grade being corrected does not exist';
        END IF;
        IF old_student <> NEW.student_id OR old_course <> NEW.course_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A correction must be for the same student and course';
        END IF;
        IF EXISTS (SELECT 1 FROM GRADE WHERE supersedes_grade_id = NEW.supersedes_grade_id) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'That grade was already corrected; correct the newest version';
        END IF;
        IF NEW.change_reason IS NULL OR TRIM(NEW.change_reason) = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A correction needs a change_reason';
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------------
-- 1b. Grade rows can't be edited. The ONE allowed update is sealing an
--     unpublished grade into a checkpoint (filling checkpoint_id + leaf_index
--     while checkpoint_id is still NULL). Every other column must stay the same.
-- ---------------------------------------------------------------------------
CREATE TRIGGER grade_before_update
BEFORE UPDATE ON GRADE
FOR EACH ROW
BEGIN
    IF NOT (
            OLD.checkpoint_id IS NULL
        AND NEW.checkpoint_id IS NOT NULL
        AND NEW.leaf_index IS NOT NULL
        AND NEW.leaf_index >= 0
        AND NEW.grade_id            <=> OLD.grade_id
        AND NEW.student_id          <=> OLD.student_id
        AND NEW.course_id           <=> OLD.course_id
        AND NEW.supersedes_grade_id <=> OLD.supersedes_grade_id
        AND NEW.letter_grade        <=> OLD.letter_grade
        AND NEW.salt                <=> OLD.salt
        AND NEW.leaf_hash           <=> OLD.leaf_hash
        AND NEW.change_reason       <=> OLD.change_reason
        AND NEW.recorded_at         <=> OLD.recorded_at
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Grades are append-only: insert a correction instead of updating';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM MERKLE_CHECKPOINT mc JOIN COURSE c
          ON c.university_id = mc.university_id AND c.term = mc.term
        WHERE mc.checkpoint_id = NEW.checkpoint_id AND c.course_id = NEW.course_id
          AND NEW.leaf_index < mc.leaf_count
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkpoint must match the course university, term and leaf range';
    END IF;
END$$

-- 1c. Grade rows can never be deleted.
CREATE TRIGGER grade_before_delete
BEFORE DELETE ON GRADE
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Grades are append-only: rows cannot be deleted';
END$$

-- ---------------------------------------------------------------------------
-- 2. A proof is valid only if it exists, is active, has not expired, reveals
--    at least one grade, and every revealed grade belongs to the student,
--    is published in a checkpoint, and is the current (not corrected) version.
-- ---------------------------------------------------------------------------
CREATE FUNCTION is_proof_valid(p_proof_id INT)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_student INT DEFAULT NULL;
    DECLARE v_status  VARCHAR(20);
    DECLARE v_expires DATETIME;
    DECLARE v_shown   INT DEFAULT 0;
    DECLARE v_bad     INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_student = NULL;

    SELECT student_id, status, expires_at INTO v_student, v_status, v_expires
    FROM DISCLOSURE_PROOF WHERE proof_id = p_proof_id;

    IF v_student IS NULL OR v_status <> 'active' THEN
        RETURN FALSE;
    END IF;
    IF v_expires IS NOT NULL AND v_expires <= NOW() THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*) INTO v_shown FROM DISCLOSED_GRADE WHERE proof_id = p_proof_id;
    IF v_shown = 0 THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*) INTO v_bad
    FROM DISCLOSED_GRADE dg
    JOIN GRADE g ON g.grade_id = dg.grade_id
    WHERE dg.proof_id = p_proof_id
      AND (   g.student_id <> v_student
           OR g.checkpoint_id IS NULL
           OR EXISTS (SELECT 1 FROM GRADE newer
                      WHERE newer.supersedes_grade_id = g.grade_id));

    RETURN v_bad = 0;
END$$

-- ---------------------------------------------------------------------------
-- 3. Publish a checkpoint for one university + term.
--    root_hash and signature are computed by the app (the private key is never
--    stored in the database). Creates the next version_no for that term and
--    seals every unpublished grade of the term, numbering leaves 0..n-1 in
--    grade_id order. All or nothing: any error rolls the whole thing back.
-- ---------------------------------------------------------------------------
CREATE PROCEDURE publish_checkpoint(
    IN p_university_id INT,
    IN p_term          VARCHAR(50),
    IN p_root_hash     VARCHAR(255),
    IN p_signature     TEXT
)
BEGIN
    DECLARE v_count      INT DEFAULT 0;
    DECLARE v_version    INT DEFAULT 1;
    DECLARE v_checkpoint INT;
    DECLARE v_grade      INT;
    DECLARE v_leaf       INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count
    FROM GRADE g JOIN COURSE c ON c.course_id = g.course_id
    WHERE g.checkpoint_id IS NULL
      AND c.university_id = p_university_id
      AND c.term = p_term;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No unpublished grades for this term';
    END IF;

    SELECT COALESCE(MAX(version_no), 0) + 1 INTO v_version
    FROM MERKLE_CHECKPOINT
    WHERE university_id = p_university_id AND term = p_term;

    INSERT INTO MERKLE_CHECKPOINT
        (university_id, term, version_no, root_hash, leaf_count, signature, published_at)
    VALUES
        (p_university_id, p_term, v_version, p_root_hash, v_count, p_signature, NOW());
    SET v_checkpoint = LAST_INSERT_ID();

    seal_loop: LOOP
        SET v_grade = NULL;
        SELECT MIN(g.grade_id) INTO v_grade
        FROM GRADE g JOIN COURSE c ON c.course_id = g.course_id
        WHERE g.checkpoint_id IS NULL
          AND c.university_id = p_university_id
          AND c.term = p_term;

        IF v_grade IS NULL THEN
            LEAVE seal_loop;
        END IF;

        UPDATE GRADE
        SET checkpoint_id = v_checkpoint, leaf_index = v_leaf
        WHERE grade_id = v_grade;

        SET v_leaf = v_leaf + 1;
    END LOOP;

    COMMIT;

    SELECT v_checkpoint AS checkpoint_id, v_version AS version_no, v_count AS leaf_count;
END$$

DELIMITER ;
