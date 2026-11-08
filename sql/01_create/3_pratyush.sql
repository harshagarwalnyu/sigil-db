-- CREATE TABLE statements: pratyush

-- 2. Grade Table
CREATE TABLE Grade (
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
    FOREIGN KEY (student_id) REFERENCES Student(student_id),
    FOREIGN KEY (course_id) REFERENCES Course(course_id),
    FOREIGN KEY (checkpoint_id) REFERENCES Merkle_Checkpoint(checkpoint_id),
    FOREIGN KEY (supersedes_grade_id) REFERENCES Grade(grade_id),
    CHECK (letter_grade IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F')),
    CHECK (supersedes_grade_id IS NULL OR change_reason IS NOT NULL)
);

-- 3. Disclosed_Grade Table
CREATE TABLE Disclosed_Grade (
    proof_id INT NOT NULL,
    grade_id INT NOT NULL,
    PRIMARY KEY (proof_id, grade_id),
    FOREIGN KEY (proof_id) REFERENCES Disclosure_Proof(proof_id),
    FOREIGN KEY (grade_id) REFERENCES Grade(grade_id)
);