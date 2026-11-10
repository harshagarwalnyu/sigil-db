-- CREATE TABLE statements: khalid
CREATE TABLE UNIVERSITY (
    university_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    public_key VARCHAR(255) NOT NULL
);

CREATE TABLE INSTRUCTOR (
    instructor_id INT AUTO_INCREMENT PRIMARY KEY,
    university_id INT NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255) UNIQUE,
    department VARCHAR(255),
    FOREIGN KEY (university_id) REFERENCES UNIVERSITY(university_id)
);

CREATE TABLE MERKLE_CHECKPOINT (
    checkpoint_id INT AUTO_INCREMENT PRIMARY KEY,
    university_id INT NOT NULL,
    term VARCHAR(50) NOT NULL,
    version_no INT NOT NULL CHECK (version_no > 0),
    root_hash CHAR(64) NOT NULL,
    leaf_count INT NOT NULL CHECK (leaf_count > 0),
    signature TEXT NOT NULL,
    published_at DATETIME NOT NULL,
    UNIQUE (university_id, term, version_no),
    FOREIGN KEY (university_id) REFERENCES UNIVERSITY(university_id)
);

CREATE TABLE COURSE (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_id INT NOT NULL,
    course_code VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    credit_hours INT NOT NULL CHECK (credit_hours > 0),
    term VARCHAR(50) NOT NULL,
    section VARCHAR(10) NOT NULL DEFAULT '001',
    submission_deadline DATETIME,
    UNIQUE (instructor_id, course_code, term, section),
    FOREIGN KEY (instructor_id) REFERENCES INSTRUCTOR(instructor_id)
);
