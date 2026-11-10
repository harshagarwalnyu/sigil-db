-- Registrar screens 9-12.
USE sigil;
SET @university_id=2;
SET @term='Fall 2025';
SET @search='';

-- R9: KPIs and grade submission progress.
SELECT (SELECT COUNT(*) FROM CORRECTION_REQUEST r JOIN GRADE g ON g.grade_id=r.grade_id
        JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
        WHERE c.university_id=@university_id AND r.status='pending') AS pending_requests,
       (SELECT COUNT(*) FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
        WHERE c.university_id=@university_id AND c.term=@term AND g.checkpoint_id IS NULL) AS unpublished_grades,
       (SELECT MAX(published_at) FROM MERKLE_CHECKPOINT WHERE university_id=@university_id) AS last_publication,
       (SELECT COUNT(*) FROM DISCLOSURE_PROOF dp JOIN STUDENT s ON s.student_id=dp.student_id
        WHERE s.university_id=@university_id AND dp.status='active' AND dp.expires_at>NOW()) AS active_links;
SELECT c.course_id,c.course_code,c.title,c.term,c.submission_deadline,i.email,
       COUNT(e.student_id) AS enrolled,COUNT(g.grade_id) AS submitted
FROM COURSE_CONTEXT c JOIN INSTRUCTOR i ON i.instructor_id=c.instructor_id
LEFT JOIN ENROLLMENT e ON e.course_id=c.course_id
LEFT JOIN GRADE g ON g.student_id=e.student_id AND g.course_id=c.course_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
WHERE c.university_id=@university_id AND c.term=@term
GROUP BY c.course_id,c.course_code,c.title,c.term,c.submission_deadline,i.email;

-- R10. Pending approvals with the original value and proposed replacement.
SELECT r.request_id,r.requested_at,r.proposed_letter_grade,r.change_reason,r.evidence_uri,
       g.grade_id,g.letter_grade,s.first_name,s.last_name,c.course_code,
       i.first_name AS instructor_first_name,i.last_name AS instructor_last_name,
       NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id) AS still_current
FROM CORRECTION_REQUEST r JOIN GRADE g ON g.grade_id=r.grade_id
JOIN COURSE_CONTEXT c ON c.course_id=g.course_id JOIN STUDENT s ON s.student_id=g.student_id
JOIN INSTRUCTOR i ON i.instructor_id=r.instructor_id
WHERE c.university_id=@university_id AND r.status='pending'
ORDER BY r.requested_at,r.request_id;
-- Approval/rejection are transactional and exercised in workflow_tests.sql:
-- CALL review_correction(3,2,TRUE,'Exam reviewed and approved',700002);
-- CALL review_correction(4,4,FALSE,'No supporting evidence',NULL);

-- R11. Next version and exact ordered batch to hash and sign outside SQL.
SELECT COALESCE(MAX(version_no),0)+1 AS next_version FROM MERKLE_CHECKPOINT
WHERE university_id=@university_id AND term=@term;
SELECT ROW_NUMBER() OVER (ORDER BY g.grade_id)-1 AS next_leaf_index,
       g.grade_id,g.student_id,c.course_code,g.letter_grade,g.leaf_hash
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE c.university_id=@university_id AND c.term=@term AND g.checkpoint_id IS NULL
ORDER BY g.grade_id;
-- Application supplies a computed root and signature, then calls:
-- CALL publish_checkpoint(@university_id,@term,@computed_root,@signature);

-- R12. Searchable complete ledger, including old versions. CSV export uses
-- these returned rows; roots/signatures are verified by the application.
SELECT g.grade_id,g.recorded_at,s.netid,s.first_name,s.last_name,c.course_code,c.term,
       g.letter_grade,g.supersedes_grade_id,g.change_reason,g.checkpoint_id,g.leaf_hash,
       CASE WHEN EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id) THEN 'Superseded'
            WHEN g.supersedes_grade_id IS NOT NULL THEN 'Correction' ELSE 'Original' END AS entry_type,
       mc.root_hash,mc.signature
FROM GRADE g JOIN STUDENT s ON s.student_id=g.student_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
LEFT JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id=g.checkpoint_id
WHERE c.university_id=@university_id AND (@term IS NULL OR c.term=@term)
  AND (s.netid LIKE CONCAT('%',@search,'%') OR s.last_name LIKE CONCAT('%',@search,'%')
       OR CAST(g.grade_id AS CHAR)=@search)
ORDER BY g.recorded_at DESC,g.grade_id DESC;

-- R9 activity feed; the database supplies events, the API sends email reminders.
SELECT * FROM (
    SELECT 'Grade submitted' AS event_type,g.recorded_at AS event_at,g.grade_id AS reference_id
    FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id WHERE c.university_id=@university_id
    UNION ALL
    SELECT 'Correction requested',r.requested_at,r.request_id FROM CORRECTION_REQUEST r
    JOIN GRADE g ON g.grade_id=r.grade_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE c.university_id=@university_id
    UNION ALL
    SELECT CONCAT('Correction ',r.status),r.reviewed_at,r.request_id FROM CORRECTION_REQUEST r
    JOIN GRADE g ON g.grade_id=r.grade_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE c.university_id=@university_id AND r.reviewed_at IS NOT NULL
    UNION ALL
    SELECT 'Checkpoint published',published_at,checkpoint_id FROM MERKLE_CHECKPOINT WHERE university_id=@university_id
    UNION ALL
    SELECT 'Proof created',dp.created_at,dp.proof_id FROM DISCLOSURE_PROOF dp
    JOIN STUDENT s ON s.student_id=dp.student_id WHERE s.university_id=@university_id
    UNION ALL
    SELECT 'Proof revoked',dp.revoked_at,dp.proof_id FROM DISCLOSURE_PROOF dp
    JOIN STUDENT s ON s.student_id=dp.student_id WHERE s.university_id=@university_id AND dp.revoked_at IS NOT NULL
) events ORDER BY event_at DESC,reference_id DESC LIMIT 50;
