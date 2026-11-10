-- University is derived, not redundantly stored on COURSE.
CREATE VIEW COURSE_CONTEXT AS
SELECT c.*, i.university_id
FROM COURSE c JOIN INSTRUCTOR i ON i.instructor_id=c.instructor_id;
