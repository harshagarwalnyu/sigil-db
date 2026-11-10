-- Each of the ten universities has a past graded offering and a current
-- offering with an enrolled student and a saved draft: 20 enrollment rows.
INSERT INTO COURSE
    (course_id,instructor_id,course_code,title,credit_hours,term,section,submission_deadline)
SELECT course_id+10,instructor_id,CONCAT(course_code,'-II'),
       CONCAT(title,' II'),credit_hours,'Fall 2026','001','2026-12-20 23:59:59'
FROM COURSE WHERE course_id<=10;
UPDATE COURSE SET submission_deadline='2025-12-20 23:59:59' WHERE course_id<=10;
UPDATE STUDENT SET netid=LOWER(CONCAT(SUBSTR(first_name,1,1),SUBSTR(last_name,1,1),LPAD(student_id,4,'0'))),
    student_number=CONCAT('N',LPAD(student_id,8,'0'));
UPDATE DISCLOSURE_PROOF SET share_token=SHA2(CONCAT('demo-token-',proof_id),256),
    revoked_at=CASE WHEN status='revoked' THEN created_at ELSE NULL END;

INSERT INTO ENROLLMENT (student_id,course_id,enrolled_at)
SELECT student_id,student_id,'2025-09-01 09:00:00' FROM STUDENT
UNION ALL
SELECT student_id,student_id+10,'2026-09-01 09:00:00' FROM STUDENT;
INSERT INTO GRADE_DRAFT (student_id,course_id,letter_grade,saved_at)
SELECT student_id,student_id+10,
       CASE WHEN student_id IN (1,2,6,10) THEN 'A' ELSE 'B+' END,
       '2026-11-08 15:00:00' FROM STUDENT;

INSERT INTO CORRECTION_REQUEST
    (request_id,grade_id,instructor_id,proposed_letter_grade,change_reason,evidence_uri,
     status,requested_at,reviewed_at,reviewer_comment,approved_grade_id)
VALUES
    (1,1,1,'A','Final exam question 4 regraded.',NULL,'approved','2025-12-27 10:00:00','2025-12-28 14:00:00','Approved after review',11),
    (2,3,3,'A-','Midterm rubric adjustment.',NULL,'approved','2026-01-09 10:00:00','2026-01-10 09:30:00','Approved rubric correction',12),
    (3,2,2,'A-','Recheck final exam arithmetic.',NULL,'pending','2026-11-01 10:00:00',NULL,NULL,NULL),
    (4,4,4,'A','Lab points omitted from final total.','evidence/lab-rubric.pdf','pending','2026-11-02 10:00:00',NULL,NULL,NULL),
    (5,5,5,'A-','Late assignment credit verified.',NULL,'pending','2026-11-03 10:00:00',NULL,NULL,NULL),
    (6,6,6,'A-','Request to revisit participation mark.',NULL,'rejected','2026-10-01 10:00:00','2026-10-02 10:00:00','No grading error established',NULL),
    (7,7,7,'B+','Examination page was not scanned.',NULL,'pending','2026-11-04 10:00:00',NULL,NULL,NULL),
    (8,8,8,'A','Essay rubric review.',NULL,'draft','2026-11-05 10:00:00',NULL,NULL,NULL),
    (9,9,9,'A-','Problem set total entered incorrectly.',NULL,'pending','2026-11-06 10:00:00',NULL,NULL,NULL),
    (10,10,10,'A-','Resubmission eligibility review.',NULL,'rejected','2026-10-10 10:00:00','2026-10-11 10:00:00','Resubmission deadline had passed',NULL);

-- A multi-course transcript and selective disclosure: grade 14 stays hidden.
INSERT INTO COURSE
    (course_id,instructor_id,course_code,title,credit_hours,term,submission_deadline)
VALUES (21,1,'CS205','Data Structures',4,'Spring 2026','2026-05-20 23:59:59'),
       (22,1,'CS230','Discrete Mathematics',3,'Spring 2026','2026-05-20 23:59:59');
INSERT INTO ENROLLMENT VALUES (1,21,'2026-01-20 09:00:00'),(1,22,'2026-01-20 09:00:00');
INSERT INTO MERKLE_CHECKPOINT VALUES
    (11,1,'Spring 2026',1,
     SHA2(CONCAT(UNHEX(SHA2('13|1|21|A-|salt13',256)),UNHEX(SHA2('14|1|22|B+|salt14',256))),256),
     2,'DEMO-ONLY-signature-11','2026-06-01 10:00:00');
INSERT INTO GRADE
    (grade_id,student_id,course_id,checkpoint_id,letter_grade,salt,leaf_hash,leaf_index,recorded_at)
VALUES (13,1,21,11,'A-','salt13',SHA2('13|1|21|A-|salt13',256),0,'2026-05-19 10:00:00'),
       (14,1,22,11,'B+','salt14',SHA2('14|1|22|B+|salt14',256),1,'2026-05-19 11:00:00');
INSERT INTO DISCLOSED_GRADE VALUES (1,13);
