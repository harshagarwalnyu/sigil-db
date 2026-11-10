-- Student screens 2-5.
USE sigil;
SET @student_id=1;
SET @course_id=1;
SET @term=NULL; -- NULL means all terms.

-- S2a. Transcript including enrollment with no submitted grade.
SELECT c.course_id,c.course_code,c.title,c.credit_hours,c.term,
       g.grade_id,g.letter_grade,
       CASE WHEN g.grade_id IS NULL THEN 'In progress'
            WHEN g.checkpoint_id IS NULL THEN 'Awaiting publication' ELSE 'Sealed' END AS grade_status,
       g.supersedes_grade_id IS NOT NULL AS corrected, mc.version_no
FROM ENROLLMENT e JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
LEFT JOIN GRADE g ON g.student_id=e.student_id AND g.course_id=e.course_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
LEFT JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id=g.checkpoint_id
WHERE e.student_id=@student_id AND (@term IS NULL OR c.term=@term)
ORDER BY c.term,c.course_code;

-- S2b. Credit-weighted GPA: current versions only; no grade means no GPA credit.
WITH current_grades AS (
    SELECT g.*,c.credit_hours FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE g.student_id=@student_id
      AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
)
SELECT ROUND(SUM(credit_hours * CASE letter_grade
    WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3 WHEN 'B' THEN 3.0
    WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3 WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7
    WHEN 'D+' THEN 1.3 WHEN 'D' THEN 1.0 ELSE 0.0 END)/NULLIF(SUM(credit_hours),0),2) AS gpa,
    COALESCE(SUM(CASE WHEN letter_grade<>'F' THEN credit_hours ELSE 0 END),0) AS earned_credits,
    COALESCE(SUM(checkpoint_id IS NOT NULL),0) AS sealed_grades,
    (SELECT COUNT(*) FROM DISCLOSURE_PROOF dp WHERE dp.student_id=@student_id
        AND dp.status='active' AND dp.expires_at>NOW()) AS active_links
FROM current_grades;

-- S2c. Credits in progress (enrolled but not yet submitted).
SELECT COALESCE(SUM(c.credit_hours),0) AS in_progress_credits
FROM ENROLLMENT e JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
WHERE e.student_id=@student_id AND NOT EXISTS
    (SELECT 1 FROM GRADE g WHERE g.student_id=e.student_id AND g.course_id=e.course_id);

-- S3. Complete history; never expose a salt in the history UI.
SELECT g.grade_id,g.letter_grade,g.recorded_at,g.supersedes_grade_id,
       g.change_reason,g.checkpoint_id,g.leaf_index,g.leaf_hash,mc.root_hash,mc.signature,
       i.first_name AS instructor_first_name,i.last_name AS instructor_last_name,
       NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id) AS is_current
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
JOIN INSTRUCTOR i ON i.instructor_id=c.instructor_id
LEFT JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id=g.checkpoint_id
WHERE g.student_id=@student_id AND g.course_id=@course_id
ORDER BY g.recorded_at DESC,g.grade_id DESC;

-- S4. Picker/search, organization dropdown and profile contact details.
SET @search='';
SELECT g.grade_id,c.course_code,c.title,c.term,g.letter_grade,
       g.checkpoint_id IS NOT NULL AS selectable
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE g.student_id=@student_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
  AND (c.course_code LIKE CONCAT('%',@search,'%') OR c.title LIKE CONCAT('%',@search,'%'))
ORDER BY c.term,c.course_code;
SELECT verifier_id,organization_name,contact_email FROM VERIFIER ORDER BY organization_name;
SELECT phone_number FROM STUDENT_PHONE WHERE student_id=@student_id ORDER BY phone_number;

-- S4 creation: all selected grades must be owned/current/sealed. Validate the
-- affected row count against the selection count before COMMIT in the app.
-- Demonstration uses an unused proof/verifier ID and rolls back.
START TRANSACTION;
INSERT INTO VERIFIER VALUES (800101,'Example Employer','verify@example.org');
INSERT INTO DISCLOSURE_PROOF
    (proof_id,student_id,verifier_id,status,created_at,expires_at,share_token)
VALUES (800101,@student_id,800101,'active',NOW(),NOW()+INTERVAL 30 DAY,HEX(RANDOM_BYTES(32)));
INSERT INTO DISCLOSED_GRADE (proof_id,grade_id)
SELECT 800101,g.grade_id FROM GRADE g WHERE g.grade_id=11 AND g.student_id=@student_id
    AND g.checkpoint_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id);
SELECT is_proof_valid(800101) AS ready_to_share;
ROLLBACK;

-- S5: status tabs, counts, selected proof content, and irreversible revocation.
SELECT dp.proof_id,v.organization_name,dp.created_at,dp.expires_at,
       CASE WHEN dp.status='revoked' THEN 'Revoked' WHEN dp.expires_at<=NOW() THEN 'Expired'
            ELSE 'Active' END AS link_status,
       COUNT(dg.grade_id) AS selected_grades,dp.share_token
FROM DISCLOSURE_PROOF dp JOIN VERIFIER v ON v.verifier_id=dp.verifier_id
LEFT JOIN DISCLOSED_GRADE dg ON dg.proof_id=dp.proof_id
WHERE dp.student_id=@student_id
GROUP BY dp.proof_id,v.organization_name,dp.created_at,dp.expires_at,dp.status,dp.share_token
ORDER BY dp.created_at DESC;
START TRANSACTION;
UPDATE DISCLOSURE_PROOF SET status='revoked'
WHERE proof_id=1 AND student_id=@student_id AND status='active';
SELECT status,revoked_at FROM DISCLOSURE_PROOF WHERE proof_id=1;
ROLLBACK;
