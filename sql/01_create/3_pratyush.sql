-- CREATE TABLE statements: pratyush

-- 2. Grade Table
CREATE TABLE GRADE (
    grade_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    checkpoint_id INT DEFAULT NULL,
    supersedes_grade_id INT DEFAULT NULL,
    letter_grade VARCHAR(2) NOT NULL,
    salt CHAR(64) NOT NULL,
    leaf_hash CHAR(64) NOT NULL,
    leaf_index INT DEFAULT NULL,
    change_reason VARCHAR(500) DEFAULT NULL,
    recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (grade_id),
    UNIQUE (supersedes_grade_id),
    UNIQUE (leaf_hash),
    UNIQUE (checkpoint_id, leaf_index),
    FOREIGN KEY (student_id) REFERENCES STUDENT(student_id),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id),
    FOREIGN KEY (checkpoint_id) REFERENCES MERKLE_CHECKPOINT(checkpoint_id),
    FOREIGN KEY (supersedes_grade_id) REFERENCES GRADE(grade_id),
    CHECK (letter_grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F')),
    CHECK (supersedes_grade_id IS NULL OR
           (change_reason IS NOT NULL AND CHAR_LENGTH(TRIM(change_reason)) > 0)),
    CHECK ((checkpoint_id IS NULL AND leaf_index IS NULL) OR
           (checkpoint_id IS NOT NULL AND leaf_index IS NOT NULL AND leaf_index >= 0))
);

-- Enforce original-grade uniqueness even for concurrent inserts.
CREATE UNIQUE INDEX uq_original_student_course
ON GRADE (student_id, (CASE WHEN supersedes_grade_id IS NULL THEN course_id ELSE NULL END));

-- 3. Disclosed_Grade Table
CREATE TABLE DISCLOSED_GRADE (
    proof_id INT NOT NULL,
    grade_id INT NOT NULL,
    PRIMARY KEY (proof_id, grade_id),
    FOREIGN KEY (proof_id) REFERENCES DISCLOSURE_PROOF(proof_id),
    FOREIGN KEY (grade_id) REFERENCES GRADE(grade_id)
);
