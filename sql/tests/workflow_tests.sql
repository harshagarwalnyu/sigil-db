-- End-to-end MySQL checks. Publication/submission procedures commit; rebuild
-- afterwards (scripts/validate.py --rebuild does this automatically).
USE sigil;
DROP PROCEDURE IF EXISTS workflow_assert;
DROP PROCEDURE IF EXISTS workflow_reject;
DELIMITER $$
CREATE PROCEDURE workflow_assert(IN ok BOOLEAN,IN label_text VARCHAR(128))
BEGIN
    IF ok IS NULL OR NOT ok THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=label_text; END IF;
END$$
CREATE PROCEDURE workflow_reject(IN statement_text TEXT)
BEGIN
    DECLARE rejected BOOLEAN DEFAULT FALSE;
    SET @workflow_statement=statement_text;
    PREPARE workflow_stmt FROM @workflow_statement;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET rejected=TRUE;
        EXECUTE workflow_stmt;
    END;
    DEALLOCATE PREPARE workflow_stmt;
    IF NOT rejected THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid workflow write was accepted'; END IF;
END$$
DELIMITER ;
SELECT COUNT(*) INTO @redundant FROM information_schema.columns
WHERE table_schema='sigil' AND table_name='COURSE' AND column_name='university_id';
CALL workflow_assert(@redundant=0,'COURSE must derive university through INSTRUCTOR');
SELECT COUNT(*) INTO @context_rows FROM COURSE_CONTEXT WHERE university_id=1;
CALL workflow_assert(@context_rows>=2,'Derived course university must remain queryable');

CALL workflow_reject('CALL submit_original_grade(1,700002,2,12,''A'')');
CALL submit_original_grade(1,700001,1,11,'A');
SELECT COUNT(*) INTO @ok FROM GRADE WHERE grade_id=700001 AND student_id=1 AND course_id=11
    AND checkpoint_id IS NULL AND CHAR_LENGTH(salt)=64
    AND leaf_hash=SHA2(CONCAT_WS('|',grade_id,student_id,course_id,letter_grade,salt),256);
CALL workflow_assert(@ok=1,'Instructor submission must create an authentic unpublished leaf');
SELECT COUNT(*) INTO @drafts FROM GRADE_DRAFT WHERE student_id=1 AND course_id=11;
CALL workflow_assert(@drafts=0,'Submission must remove its saved draft');
CALL workflow_reject('CALL submit_original_grade(1,700003,1,11,''A'')');

-- A two-student batch cannot leave a partially submitted course on failure.
INSERT INTO STUDENT (student_id,university_id,first_name,last_name,email,date_of_birth)
VALUES (800101,1,'Batch','Student','batch@example.edu','2004-01-01');
INSERT INTO COURSE (course_id,instructor_id,course_code,title,credit_hours,term,submission_deadline)
VALUES (800101,1,'BATCH101','Batch Test',3,'TEST-2026',NOW()+INTERVAL 1 DAY);
INSERT INTO ENROLLMENT VALUES (1,800101,NOW()),(800101,800101,NOW());
CALL workflow_reject('CALL submit_course_grades(1,800101,''[{"grade_id":700101,"student_id":1,"letter_grade":"A"},{"grade_id":700102,"student_id":800101,"letter_grade":"Q"}]'')');
CALL workflow_reject('CALL submit_course_grades(1,800101,''[{"grade_id":700101,"student_id":1,"letter_grade":"A"},{"grade_id":700101,"student_id":800101,"letter_grade":"B"}]'')');
SELECT COUNT(*) INTO @partial FROM GRADE WHERE course_id=800101;
CALL workflow_assert(@partial=0,'Invalid roster batch must leave zero final grades');
CALL submit_course_grades(1,800101,'[{"grade_id":700101,"student_id":1,"letter_grade":"A"},{"grade_id":700102,"student_id":800101,"letter_grade":"B"}]');
SELECT COUNT(*) INTO @submitted FROM GRADE WHERE course_id=800101;
CALL workflow_assert(@submitted=2,'Valid whole-roster submission must commit both grades');

CALL review_correction(3,2,TRUE,'Exam reviewed and approved',700002);
SELECT COUNT(*) INTO @ok FROM CORRECTION_REQUEST r JOIN GRADE g ON g.grade_id=r.approved_grade_id
WHERE r.request_id=3 AND r.status='approved' AND g.grade_id=700002 AND g.supersedes_grade_id=2
  AND g.checkpoint_id IS NULL AND g.letter_grade=r.proposed_letter_grade;
CALL workflow_assert(@ok=1,'Approval must append exactly one correction and record the decision');
CALL workflow_assert(is_proof_valid(2)=0,'Proof of the replaced grade must become invalid');
CALL workflow_reject('CALL review_correction(3,2,TRUE,''Again'',700003)');
CALL workflow_reject('CALL review_correction(4,2,FALSE,''Wrong university'',NULL)');
CALL workflow_reject('CALL review_correction(4,4,FALSE,''  '',NULL)');
CALL review_correction(4,4,FALSE,'No supporting evidence',NULL);
SELECT COUNT(*) INTO @ok FROM CORRECTION_REQUEST WHERE request_id=4 AND status='rejected'
    AND reviewer_comment='No supporting evidence' AND approved_grade_id IS NULL;
CALL workflow_assert(@ok=1,'Rejection must preserve its explanation without adding a grade');

START TRANSACTION;
CALL workflow_reject('INSERT INTO ENROLLMENT VALUES (1,12,NOW())');
CALL workflow_reject('INSERT INTO CORRECTION_REQUEST (grade_id,instructor_id,proposed_letter_grade,change_reason,requested_at) VALUES (4,1,''A'',''Review'',NOW())');
CALL workflow_reject('INSERT INTO CORRECTION_REQUEST (grade_id,instructor_id,proposed_letter_grade,change_reason,requested_at) VALUES (700001,1,''A-'',''Review'',NOW())');
UPDATE DISCLOSURE_PROOF SET status='revoked' WHERE proof_id=1;
SELECT COUNT(*) INTO @ok FROM DISCLOSURE_PROOF WHERE proof_id=1 AND revoked_at IS NOT NULL;
CALL workflow_assert(@ok=1,'Revocation must record its time');
CALL workflow_reject('UPDATE DISCLOSURE_PROOF SET status=''active'' WHERE proof_id=1');
ROLLBACK;
DROP PROCEDURE workflow_reject;
DROP PROCEDURE workflow_assert;
SELECT 'PASS: normalized course, instructor submission, approval, rejection and revocation workflows' AS result;
