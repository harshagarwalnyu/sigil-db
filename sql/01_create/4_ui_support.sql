-- Additional relations required by the submitted Milestone 2 screens.
CREATE TABLE ENROLLMENT (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrolled_at DATETIME NOT NULL,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id)
);

CREATE TABLE GRADE_DRAFT (
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    letter_grade VARCHAR(2) NOT NULL,
    saved_at DATETIME NOT NULL,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id, course_id) REFERENCES ENROLLMENT(student_id, course_id),
    CHECK (letter_grade IN ('A','A-','B+','B','B-','C+','C','C-','D+','D','F'))
);

CREATE TABLE CORRECTION_REQUEST (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    grade_id INT NOT NULL,
    instructor_id INT NOT NULL,
    proposed_letter_grade VARCHAR(2) NOT NULL,
    change_reason VARCHAR(500) NOT NULL,
    evidence_uri VARCHAR(500),
    status VARCHAR(10) NOT NULL DEFAULT 'pending',
    requested_at DATETIME NOT NULL,
    reviewed_at DATETIME,
    reviewer_comment VARCHAR(500),
    approved_grade_id INT UNIQUE,
    FOREIGN KEY (grade_id) REFERENCES GRADE(grade_id),
    FOREIGN KEY (instructor_id) REFERENCES INSTRUCTOR(instructor_id),
    FOREIGN KEY (approved_grade_id) REFERENCES GRADE(grade_id),
    CHECK (proposed_letter_grade IN ('A','A-','B+','B','B-','C+','C','C-','D+','D','F')),
    CHECK (CHAR_LENGTH(TRIM(change_reason)) > 0),
    CHECK (status IN ('draft','pending','approved','rejected')),
    CHECK (reviewed_at IS NULL OR reviewed_at >= requested_at),
    CHECK ((status IN ('draft','pending') AND reviewed_at IS NULL AND approved_grade_id IS NULL)
        OR (status='approved' AND reviewed_at IS NOT NULL AND approved_grade_id IS NOT NULL)
        OR (status='rejected' AND reviewed_at IS NOT NULL AND approved_grade_id IS NULL
            AND reviewer_comment IS NOT NULL AND CHAR_LENGTH(TRIM(reviewer_comment)) > 0))
);
