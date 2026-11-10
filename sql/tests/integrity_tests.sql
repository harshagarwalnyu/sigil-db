-- Fail-fast regression tests. Run against the disposable database from build.sql.
USE sigil;
DROP PROCEDURE IF EXISTS test_assert;
DROP PROCEDURE IF EXISTS test_reject;
DELIMITER $$
CREATE PROCEDURE test_assert(IN ok BOOLEAN, IN label_text VARCHAR(128))
BEGIN
    IF ok IS NULL OR NOT ok THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = label_text;
    END IF;
END$$
CREATE PROCEDURE test_reject(IN statement_text TEXT)
BEGIN
    DECLARE rejected BOOLEAN DEFAULT FALSE;
    SET @test_statement = statement_text;
    PREPARE test_stmt FROM @test_statement;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET rejected = TRUE;
        EXECUTE test_stmt;
    END;
    DEALLOCATE PREPARE test_stmt;
    IF NOT rejected THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid write was unexpectedly accepted';
    END IF;
END$$
DELIMITER ;

-- Every seed checkpoint has the claimed number of leaves, numbered 0..n-1.
SELECT COUNT(*) INTO @bad FROM (
    SELECT mc.checkpoint_id
    FROM MERKLE_CHECKPOINT mc LEFT JOIN GRADE g ON g.checkpoint_id = mc.checkpoint_id
    GROUP BY mc.checkpoint_id, mc.leaf_count
    HAVING COUNT(g.grade_id) <> mc.leaf_count
        OR MIN(g.leaf_index) <> 0 OR MAX(g.leaf_index) <> mc.leaf_count - 1
) invalid_checkpoints;
CALL test_assert(@bad = 0, 'Seed checkpoint counts or leaf indexes are inconsistent');

-- Fixtures contain one or two leaves. Parents hash concatenated raw digest bytes.
SELECT COUNT(*) INTO @bad FROM (
    SELECT mc.checkpoint_id
    FROM MERKLE_CHECKPOINT mc JOIN GRADE g ON g.checkpoint_id = mc.checkpoint_id
    GROUP BY mc.checkpoint_id, mc.root_hash
    HAVING mc.root_hash <> CASE COUNT(*)
        WHEN 1 THEN MAX(g.leaf_hash)
        WHEN 2 THEN SHA2(UNHEX(GROUP_CONCAT(g.leaf_hash ORDER BY g.leaf_index SEPARATOR '')), 256)
        ELSE '' END
) invalid_roots;
CALL test_assert(@bad = 0, 'Seed Merkle root does not commit to its grade leaves');
CALL test_assert(is_proof_valid(123456789) = 0, 'Missing proof must be invalid');

START TRANSACTION;
INSERT INTO MERKLE_CHECKPOINT VALUES
    (800001, 3, 'Fall 2025', 2, REPEAT('a',64), 2, 'test-only', NOW()),
    (800002, 2, 'Fall 2025', 2, REPEAT('b',64), 10, 'test-only', NOW()),
    (800003, 3, 'Spring 2026', 1, REPEAT('c',64), 10, 'test-only', NOW());

CALL test_reject('UPDATE GRADE SET checkpoint_id=800001 WHERE grade_id=12');
CALL test_reject('UPDATE GRADE SET checkpoint_id=800001, leaf_index=-1 WHERE grade_id=12');
CALL test_reject('UPDATE GRADE SET checkpoint_id=800001, leaf_index=2 WHERE grade_id=12');
CALL test_reject('UPDATE GRADE SET checkpoint_id=800002, leaf_index=5 WHERE grade_id=12');
CALL test_reject('UPDATE GRADE SET checkpoint_id=800003, leaf_index=5 WHERE grade_id=12');
CALL test_reject('UPDATE GRADE SET letter_grade=''F'' WHERE grade_id=1');
CALL test_reject('DELETE FROM GRADE WHERE grade_id=12');
CALL test_reject('INSERT INTO GRADE (student_id,course_id,letter_grade,salt,leaf_hash) VALUES (1,1,''A'',''test'',''test-duplicate-original'')');
CALL test_reject('INSERT INTO GRADE (student_id,course_id,letter_grade,salt,leaf_hash) VALUES (1,2,''A'',''test'',''test-cross-university'')');
CALL test_reject('INSERT INTO GRADE (student_id,course_id,supersedes_grade_id,letter_grade,salt,leaf_hash,change_reason) VALUES (3,3,12,''A'',''test'',''test-blank-reason'',''  '')');
CALL test_reject('INSERT INTO MERKLE_CHECKPOINT VALUES (800004,3,''Fall 2025'',2,REPEAT(''a'',64),1,''test-only'',NOW())');
CALL test_reject('INSERT INTO COURSE (course_id,instructor_id,course_code,title,credit_hours,term) VALUES (800001,1,''TEST'',''Test'',0,''Fall 2025'')');
CALL test_reject('INSERT INTO COURSE (course_id,instructor_id,course_code,title,credit_hours,term) VALUES (800001,NULL,''TEST'',''Test'',3,''Fall 2025'')');
CALL test_reject('INSERT INTO COURSE (course_id,instructor_id,course_code,title,credit_hours,term) VALUES (800001,999999,''TEST'',''Test'',3,''Fall 2025'')');
CALL test_reject('INSERT INTO DISCLOSURE_PROOF (proof_id,student_id,verifier_id,status,created_at,expires_at) VALUES (800001,3,1,''active'',NOW(),NOW()-INTERVAL 1 DAY)');

-- A correct, one-time publication update succeeds.
UPDATE GRADE SET checkpoint_id=800001, leaf_index=0 WHERE grade_id=12;
SELECT COUNT(*) INTO @sealed FROM GRADE WHERE grade_id=12 AND checkpoint_id=800001 AND leaf_index=0;
CALL test_assert(@sealed=1, 'Valid sealing must succeed');
CALL test_reject('UPDATE GRADE SET checkpoint_id=800001, leaf_index=1 WHERE grade_id=12');
CALL test_reject('INSERT INTO GRADE (student_id,course_id,checkpoint_id,supersedes_grade_id,letter_grade,salt,leaf_hash,leaf_index,change_reason) VALUES (3,3,800001,12,''A'',''test'',''test-duplicate-index'',0,''test correction'')');

-- Time-relative proof fixtures stay meaningful after the seed proofs expire.
INSERT INTO DISCLOSURE_PROOF (proof_id,student_id,verifier_id,status,created_at,expires_at) VALUES
    (800001,3,1,'active',NOW(),NOW()+INTERVAL 1 DAY),
    (800002,3,1,'active',NOW()-INTERVAL 2 DAY,NOW()-INTERVAL 1 DAY),
    (800003,3,1,'revoked',NOW(),NOW()+INTERVAL 1 DAY);
INSERT INTO DISCLOSED_GRADE VALUES (800001,12),(800002,12),(800003,12);
CALL test_assert(is_proof_valid(800001)=1, 'Current published grade should be valid');
CALL test_assert(is_proof_valid(800002)=0, 'Expired proof must be invalid');
CALL test_assert(is_proof_valid(800003)=0, 'Revoked proof must be invalid');
DELETE FROM DISCLOSED_GRADE WHERE proof_id=800001;
CALL test_assert(is_proof_valid(800001)=0, 'Empty proof must be invalid');
INSERT INTO DISCLOSED_GRADE VALUES (800001,3);
CALL test_assert(is_proof_valid(800001)=0, 'Superseded grade must be invalid');
DELETE FROM DISCLOSED_GRADE WHERE proof_id=800001;
INSERT INTO DISCLOSED_GRADE VALUES (800001,2);
CALL test_assert(is_proof_valid(800001)=0, 'Another student grade must be invalid');
ROLLBACK;

-- Exercise publication itself against the one unpublished seed correction.
SELECT leaf_hash INTO @correction_root FROM GRADE WHERE grade_id=12;
CALL publish_checkpoint(3, 'Fall 2025', @correction_root, 'test-only-signature');
SELECT COUNT(*) INTO @published
FROM GRADE g JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id=g.checkpoint_id
WHERE g.grade_id=12 AND g.leaf_index=0 AND mc.university_id=3
  AND mc.term='Fall 2025' AND mc.version_no=2 AND mc.leaf_count=1
  AND mc.root_hash=g.leaf_hash;
CALL test_assert(@published=1, 'Publication must seal correction as next version and leaf zero');
CALL test_reject('CALL publish_checkpoint(3,''Fall 2025'',''unused'',''test-only'')');
-- Publication commits. Rebuild afterwards to restore the unpublished fixture.
DROP PROCEDURE test_reject;
DROP PROCEDURE test_assert;
SELECT 'PASS: integrity regression tests' AS result;
