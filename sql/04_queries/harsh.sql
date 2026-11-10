-- Harsh Agarwal: verifier screens 13-15 and mobile sharing screen 16.
-- Run AFTER build.sql: mysql -u <user> -p sigil < sql/04_queries/harsh.sql
-- The reads do not modify data. The sharing example ends with ROLLBACK.
-- Applications must bind parameters and authorize student writes server-side.
USE sigil;
SET @proof_token = SHA2('demo-token-1',256);
SET @proof_id = (SELECT proof_id FROM DISCLOSURE_PROOF WHERE share_token=@proof_token);
SET @selected_grade_id = 11;
SET @university_id = 1;
SET @term = 'Fall 2025';
SET @root_prefix = '';

-- Q1. Screen 13: look up a proof and explain its database status.
-- A missing proof returns no rows. No grades are exposed for invalid proofs.
-- This is a status check; the browser must ALSO verify hashes and signatures.
SELECT dp.proof_id, v.organization_name, dp.created_at, dp.expires_at,
       CASE
           WHEN dp.status = 'revoked' THEN 'Revoked'
           WHEN dp.expires_at <= NOW() THEN 'Expired'
           WHEN is_proof_valid(dp.proof_id) = 0 THEN 'Invalid or outdated grades'
           ELSE 'Ready for cryptographic verification'
       END AS verification_status
FROM DISCLOSURE_PROOF dp
JOIN VERIFIER v ON v.verifier_id = dp.verifier_id
WHERE dp.proof_id = @proof_id;

-- Q2. Screens 14/16: the disclosed grades and evidence for a valid proof only.
-- Rebuild each checkpoint tree in leaf_index order using Q4, then return ONLY
-- the selected leaves and sibling paths to the browser. Do not expose Q4 publicly.
SELECT dp.proof_id, s.first_name, s.last_name,
       g.grade_id, g.student_id, g.course_id, c.course_code, c.title,
       c.credit_hours, c.term, g.letter_grade, g.salt, g.leaf_hash, g.leaf_index,
       mc.checkpoint_id, mc.version_no, mc.root_hash, mc.signature,
       mc.published_at, u.name AS university_name, u.public_key
FROM DISCLOSURE_PROOF dp
JOIN STUDENT s ON s.student_id = dp.student_id
JOIN DISCLOSED_GRADE dg ON dg.proof_id = dp.proof_id
JOIN GRADE g ON g.grade_id = dg.grade_id
JOIN COURSE_CONTEXT c ON c.course_id = g.course_id
JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id = g.checkpoint_id
JOIN UNIVERSITY u ON u.university_id = mc.university_id
WHERE dp.proof_id = @proof_id AND is_proof_valid(dp.proof_id) = 1
ORDER BY c.term, c.course_code, g.grade_id;

-- Q3. Screen 15: public checkpoint registry; excludes all student/grade data.
SELECT u.name AS university_name, u.public_key,
       mc.checkpoint_id, mc.term, mc.version_no, mc.root_hash,
       mc.leaf_count, mc.signature, mc.published_at
FROM MERKLE_CHECKPOINT mc
JOIN UNIVERSITY u ON u.university_id = mc.university_id
WHERE mc.university_id = @university_id AND (@term IS NULL OR mc.term = @term)
  AND mc.root_hash LIKE CONCAT(@root_prefix,'%')
ORDER BY mc.version_no DESC;

-- Q4. Backend only: ordered leaf hashes to reconstruct the requested tree.
-- Include superseded leaves: removing one would change the published root.
SELECT g.leaf_index, g.leaf_hash
FROM GRADE g
WHERE g.checkpoint_id = (
    SELECT g.checkpoint_id FROM GRADE g JOIN DISCLOSED_GRADE dg ON dg.grade_id=g.grade_id
    WHERE g.grade_id=@selected_grade_id AND dg.proof_id=@proof_id AND is_proof_valid(@proof_id)=1
)
ORDER BY g.leaf_index;

-- Q5. Screen 16: student's shared proofs, with validity and grade counts.
SET @student_id = 1;
SELECT dp.proof_id, v.organization_name, dp.status, dp.created_at, dp.expires_at,
       COUNT(dg.grade_id) AS disclosed_grade_count,
       is_proof_valid(dp.proof_id) AS database_valid
FROM DISCLOSURE_PROOF dp
JOIN VERIFIER v ON v.verifier_id = dp.verifier_id
LEFT JOIN DISCLOSED_GRADE dg ON dg.proof_id = dp.proof_id
WHERE dp.student_id = @student_id
GROUP BY dp.proof_id, v.organization_name, dp.status, dp.created_at, dp.expires_at
ORDER BY dp.created_at DESC, dp.proof_id DESC;

-- Q6-Q9. Mobile sharing lifecycle (INSERT, DELETE, UPDATE).
-- Demo-only unused ID. Production allocates IDs without MAX(id)+1 races.
-- Keep creation and selection in one transaction; share only after COMMIT.
-- ROLLBACK here makes the example repeatable and preserves the seed data.
SET @new_proof_id = 800001;
SET @selected_grade_id = 11;
START TRANSACTION;
INSERT INTO DISCLOSURE_PROOF
    (proof_id, student_id, verifier_id, status, created_at, expires_at,share_token)
VALUES (@new_proof_id, @student_id, 1, 'active', NOW(), NOW() + INTERVAL 30 DAY,HEX(RANDOM_BYTES(32)));

INSERT INTO DISCLOSED_GRADE (proof_id, grade_id)
SELECT @new_proof_id, g.grade_id
FROM GRADE g
WHERE g.grade_id = @selected_grade_id AND g.student_id = @student_id
  AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE newer WHERE newer.supersedes_grade_id = g.grade_id);
SELECT is_proof_valid(@new_proof_id) AS new_proof_valid;

-- Remove a selection before the newly created proof has been shared.
-- Never alter the disclosed set of an already shared proof; revoke it instead.
DELETE FROM DISCLOSED_GRADE
WHERE proof_id = @new_proof_id AND grade_id = @selected_grade_id;
SELECT is_proof_valid(@new_proof_id) AS empty_proof_invalid;

-- Re-select the grade, then demonstrate revocation with an ownership check.
INSERT INTO DISCLOSED_GRADE (proof_id, grade_id)
SELECT @new_proof_id, g.grade_id
FROM GRADE g
WHERE g.grade_id = @selected_grade_id AND g.student_id = @student_id
  AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE newer WHERE newer.supersedes_grade_id = g.grade_id);
UPDATE DISCLOSURE_PROOF SET status = 'revoked'
WHERE proof_id = @new_proof_id AND student_id = @student_id AND status = 'active';
SELECT is_proof_valid(@new_proof_id) AS revoked_proof_invalid;
ROLLBACK;
