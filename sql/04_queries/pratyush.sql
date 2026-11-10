-- Instructor screens 6-8.
USE sigil;
SET @instructor_id=1;
SET @term='Fall 2026';
SET @course_id=11;

-- I6. Course cards, enrollment/grade progress, deadlines and request counts.
SELECT c.course_id,c.course_code,c.title,c.section,c.credit_hours,c.term,c.submission_deadline,
       COUNT(e.student_id) AS enrollment,
       COUNT(g.grade_id) AS submitted,
       COUNT(d.student_id) AS saved_drafts,
       (SELECT COUNT(*) FROM CORRECTION_REQUEST r JOIN GRADE old ON old.grade_id=r.grade_id
        WHERE old.course_id=c.course_id AND r.status='pending') AS pending_corrections
FROM COURSE_CONTEXT c LEFT JOIN ENROLLMENT e ON e.course_id=c.course_id
LEFT JOIN GRADE g ON g.course_id=c.course_id AND g.student_id=e.student_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
LEFT JOIN GRADE_DRAFT d ON d.course_id=c.course_id AND d.student_id=e.student_id
WHERE c.instructor_id=@instructor_id AND (@term IS NULL OR c.term=@term)
GROUP BY c.course_id,c.course_code,c.title,c.section,c.credit_hours,c.term,c.submission_deadline
ORDER BY c.term,c.course_code;

-- I7. Roster exists independently of final grades. Invalid CSV cells are
-- rejected by UI validation; valid cells may be saved to GRADE_DRAFT.
SELECT s.student_id,s.netid,s.student_number,s.first_name,s.last_name,
       d.letter_grade AS draft_grade,g.letter_grade AS submitted_grade,
       CASE WHEN g.grade_id IS NOT NULL THEN 'Submitted'
            WHEN d.student_id IS NOT NULL THEN 'Entered' ELSE 'Missing' END AS entry_state
FROM ENROLLMENT e JOIN STUDENT s ON s.student_id=e.student_id
JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
LEFT JOIN GRADE_DRAFT d ON d.student_id=e.student_id AND d.course_id=e.course_id
LEFT JOIN GRADE g ON g.student_id=e.student_id AND g.course_id=e.course_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
WHERE c.instructor_id=@instructor_id AND c.course_id=@course_id
ORDER BY s.last_name,s.first_name,s.student_id;

-- Autosave, edit, and remove an unsubmitted draft; never modify a final Grade.
START TRANSACTION;
INSERT INTO GRADE_DRAFT (student_id,course_id,letter_grade,saved_at)
SELECT e.student_id,e.course_id,'A-',NOW() FROM ENROLLMENT e
JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
WHERE e.student_id=1 AND e.course_id=@course_id AND c.instructor_id=@instructor_id
  AND NOT EXISTS (SELECT 1 FROM GRADE g WHERE g.student_id=e.student_id AND g.course_id=e.course_id)
ON DUPLICATE KEY UPDATE letter_grade='A-',saved_at=NOW();
UPDATE GRADE_DRAFT d JOIN COURSE_CONTEXT c ON c.course_id=d.course_id
SET d.letter_grade='A',d.saved_at=NOW()
WHERE d.student_id=1 AND d.course_id=@course_id AND c.instructor_id=@instructor_id;
DELETE d FROM GRADE_DRAFT d JOIN COURSE_CONTEXT c ON c.course_id=d.course_id
WHERE d.student_id=1 AND d.course_id=@course_id AND c.instructor_id=@instructor_id;
ROLLBACK;
-- Original-grade submission is tested in workflow_tests.sql:
-- CALL submit_original_grade(1,700001,1,11,'A');
-- Whole-roster submission (including imported CSV after application parsing):
-- CALL submit_course_grades(1,11,JSON_ARRAY(JSON_OBJECT('grade_id',700001,'student_id',1,'letter_grade','A')));
-- The batch routine validates every enrolled row and commits all or nothing.

-- I8: current sealed grade selector and the instructor's request history.
SELECT g.grade_id,s.student_id,s.first_name,s.last_name,c.course_code,c.term,
       g.letter_grade,g.checkpoint_id,g.leaf_index
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id JOIN STUDENT s ON s.student_id=g.student_id
WHERE c.instructor_id=@instructor_id AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
ORDER BY c.term,s.last_name;
SELECT r.*,g.letter_grade AS original_letter,c.course_code FROM CORRECTION_REQUEST r
JOIN GRADE g ON g.grade_id=r.grade_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE r.instructor_id=@instructor_id ORDER BY r.requested_at DESC,r.request_id DESC;
START TRANSACTION;
INSERT INTO CORRECTION_REQUEST
    (grade_id,instructor_id,proposed_letter_grade,change_reason,status,requested_at)
SELECT g.grade_id,@instructor_id,'A-','Exam rubric review','pending',NOW()
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE g.grade_id=11 AND c.instructor_id=@instructor_id AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id);
ROLLBACK;
