-- INSERT seed data (10+ rows per table): khalid
-- Do NOT run until every table is created.
INSERT INTO UNIVERSITY VALUES
(1, 'Massachusetts Institute of Technology', 'key1'),
(2, 'Stanford University', 'key2'),
(3, 'Harvard University', 'key3'),
(4, 'University of California, Berkeley', 'key4'),
(5, 'Princeton University', 'key5'),
(6, 'Columbia University', 'key6'),
(7, 'University of Chicago', 'key7'),
(8, 'Yale University', 'key8'),
(9, 'Cornell University', 'key9'),
(10, 'Carnegie Mellon University', 'key10');

INSERT INTO INSTRUCTOR VALUES
(1, 1, 'John', 'Smith', 'john.smith@mit.edu', 'Computer Science'),
(2, 2, 'Sarah', 'Johnson', 'sarah.johnson@stanford.edu', 'Mathematics'),
(3, 3, 'Michael', 'Brown', 'michael.brown@harvard.edu', 'Economics'),
(4, 4, 'Emily', 'Davis', 'emily.davis@berkeley.edu', 'Physics'),
(5, 5, 'David', 'Wilson', 'david.wilson@princeton.edu', 'Chemistry'),
(6, 6, 'Jessica', 'Miller', 'jessica.miller@columbia.edu', 'Biology'),
(7, 7, 'Robert', 'Taylor', 'robert.taylor@uchicago.edu', 'Statistics'),
(8, 8, 'Laura', 'Anderson', 'laura.anderson@yale.edu', 'History'),
(9, 9, 'James', 'Thomas', 'james.thomas@cornell.edu', 'Engineering'),
(10, 10, 'Linda', 'Moore', 'linda.moore@cmu.edu', 'Software Engineering');

INSERT INTO COURSE VALUES
(1, 1, 1, 'CS101', 'Intro to Programming', 3, 'Fall 2025'),
(2, 2, 2, 'MATH201', 'Calculus II', 3, 'Fall 2025'),
(3, 3, 3, 'ECON101', 'Microeconomics', 3, 'Fall 2025'),
(4, 4, 4, 'PHYS101', 'General Physics', 4, 'Fall 2025'),
(5, 5, 5, 'CHEM101', 'General Chemistry', 4, 'Fall 2025'),
(6, 6, 6, 'BIO101', 'Intro to Biology', 4, 'Fall 2025'),
(7, 7, 7, 'STAT201', 'Probability', 3, 'Fall 2025'),
(8, 8, 8, 'HIST101', 'World History', 3, 'Fall 2025'),
(9, 9, 9, 'ENGR101', 'Intro to Engineering', 3, 'Fall 2025'),
(10, 10, 10, 'SE301', 'Software Design', 3, 'Fall 2025');

INSERT INTO MERKLE_CHECKPOINT
SELECT course_id, university_id, term, 1,
       SHA2(CONCAT_WS('|', course_id, university_id, instructor_id, course_code, title, credit_hours, term), 256),
       1,
       CONCAT('sig', course_id),
       '2026-01-01 00:00:00'
FROM COURSE;