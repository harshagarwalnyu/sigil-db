-- CREATE TABLE statements: khalid
CREATE TABLE UNIVERSITY (
    university_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    public_key VARCHAR(255)
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
    term VARCHAR(50),
    version_no INT,
    root_hash VARCHAR(255),
    leaf_count INT,
    signature VARCHAR(255),
    published_at DATETIME,
    FOREIGN KEY (university_id) REFERENCES UNIVERSITY(university_id)
);

CREATE TABLE COURSE (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    university_id INT NOT NULL,
    instructor_id INT,
    course_code VARCHAR(50),
    title VARCHAR(255),
    credit_hours INT,
    term VARCHAR(50),
    FOREIGN KEY (university_id) REFERENCES UNIVERSITY(university_id),
    FOREIGN KEY (instructor_id) REFERENCES INSTRUCTOR(instructor_id)
);