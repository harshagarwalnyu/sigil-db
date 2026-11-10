-- Tests for sql/02_advanced/harsh.sql
-- Run AFTER build.sql, from the repo root:
--   mysql -u <user> -p --force sigil < sql/tests/harsh_tests.sql
-- --force keeps going after the errors we EXPECT (those are the triggers working).
-- It leaves test rows (ids 9001+), so run build.sql again afterwards to reset.

-- Test data
INSERT INTO UNIVERSITY (university_id, name, public_key) VALUES (9001, 'Test University', 'test-key');
INSERT INTO STUDENT (student_id, university_id, first_name, last_name, email, date_of_birth)
VALUES (9001, 9001, 'Test', 'Student', 'test.student@example.edu', '2004-01-01'),
       (9002, 9001, 'Other', 'Student', 'other.student@example.edu', '2004-02-02');
INSERT INTO INSTRUCTOR (instructor_id, university_id, first_name, last_name, email, department)
VALUES (9001, 9001, 'Test', 'Prof', 'test.prof@example.edu', 'CS');
INSERT INTO COURSE (course_id, instructor_id, course_code, title, credit_hours, term)
VALUES (9001, 9001, 'TST-101', 'Test Course', 4, 'TEST-2026'),
       (9002, 9001, 'TST-102', 'Test Course 2', 4, 'TEST-2026');
INSERT INTO VERIFIER (verifier_id, organization_name, contact_email) VALUES (9001, 'Test Employer', 'hr@example.com');

INSERT INTO GRADE (grade_id, student_id, course_id, letter_grade, salt, leaf_hash)
VALUES (9001, 9001, 9001, 'B', 'salt1', 'hash9001'),
       (9002, 9001, 9002, 'A', 'salt2', 'hash9002');

-- ===== 1. TRIGGERS =====
SELECT 'EXPECT ERROR: second original grade for same student + course' AS test;
INSERT INTO GRADE (student_id, course_id, letter_grade, salt, leaf_hash) VALUES (9001, 9001, 'A', 's', 'h-dup');

SELECT 'EXPECT ERROR: correction for a different student' AS test;
INSERT INTO GRADE (student_id, course_id, supersedes_grade_id, letter_grade, salt, leaf_hash, change_reason)
VALUES (9002, 9001, 9001, 'A', 's', 'h-x', 'typo');

SELECT 'EXPECT ERROR: correction with no reason' AS test;
INSERT INTO GRADE (student_id, course_id, supersedes_grade_id, letter_grade, salt, leaf_hash)
VALUES (9001, 9001, 9001, 'A', 's', 'h-y');

SELECT 'EXPECT ERROR: changing a letter grade' AS test;
UPDATE GRADE SET letter_grade = 'A' WHERE grade_id = 9001;

SELECT 'EXPECT ERROR: deleting a grade' AS test;
DELETE FROM GRADE WHERE grade_id = 9001;

-- ===== 3. PROCEDURE =====
SELECT 'EXPECT OK: publish checkpoint v1 seals both grades (leaf 0 and 1)' AS test;
CALL publish_checkpoint(9001, 'TEST-2026', 'roothash-v1', 'signature-v1');
SELECT grade_id, letter_grade, checkpoint_id, leaf_index FROM GRADE WHERE student_id = 9001;

SELECT 'EXPECT ERROR: re-sealing an already published grade' AS test;
UPDATE GRADE SET checkpoint_id = NULL WHERE grade_id = 9001;

SELECT 'EXPECT ERROR: nothing left to publish' AS test;
CALL publish_checkpoint(9001, 'TEST-2026', 'roothash-v2', 'signature-v2');

-- ===== 2. FUNCTION =====
INSERT INTO DISCLOSURE_PROOF (proof_id, student_id, verifier_id, status, created_at, expires_at)
VALUES (9001, 9001, 9001, 'active', NOW(), NOW() + INTERVAL 30 DAY),
       (9002, 9001, 9001, 'revoked', NOW(), NOW() + INTERVAL 30 DAY),
       (9003, 9001, 9001, 'active', NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 1 DAY),
       (9004, 9001, 9001, 'active', NOW(), NOW() + INTERVAL 30 DAY);
INSERT INTO DISCLOSED_GRADE (proof_id, grade_id) VALUES (9001, 9001), (9002, 9001), (9003, 9001);
-- 9004 reveals no grades

SELECT 'EXPECT 1, 0, 0, 0, 0: valid, revoked, expired, no grades, missing' AS test;
SELECT is_proof_valid(9001) AS valid_proof,
       is_proof_valid(9002) AS revoked,
       is_proof_valid(9003) AS expired,
       is_proof_valid(9004) AS no_grades,
       is_proof_valid(12345) AS missing;

SELECT 'EXPECT OK: correct grade 9001 (B to A), publish v2' AS test;
INSERT INTO GRADE (grade_id, student_id, course_id, supersedes_grade_id, letter_grade, salt, leaf_hash, change_reason)
VALUES (9003, 9001, 9001, 9001, 'A', 'salt3', 'hash9003', 'Final exam regraded');
CALL publish_checkpoint(9001, 'TEST-2026', 'roothash-v2', 'signature-v2');

SELECT 'EXPECT ERROR: correcting 9001 again (already corrected)' AS test;
INSERT INTO GRADE (student_id, course_id, supersedes_grade_id, letter_grade, salt, leaf_hash, change_reason)
VALUES (9001, 9001, 9001, 'A-', 's', 'h-z', 'again');

SELECT 'EXPECT 0: proof 9001 now shows an outdated grade' AS test;
SELECT is_proof_valid(9001) AS valid_proof;

SELECT checkpoint_id, term, version_no, leaf_count FROM MERKLE_CHECKPOINT WHERE university_id = 9001;
