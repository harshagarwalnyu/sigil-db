-- CREATE TABLE statements: mohammad
create TABLE STUDENT (
    student_id      INT         NOT NULL, 
    university_id   INT         NOT NULL,
    first_name      VARCHAR(25) NOT NULL,
    last_name       VARCHAR(25) NOT NULL,
    email           VARCHAR(50) NOT NULL UNIQUE,
    date_of_birth   DATE        NOT NULL,
    netid           VARCHAR(25) UNIQUE,
    student_number  CHAR(9) UNIQUE,
    PRIMARY KEY(student_id),
    FOREIGN KEY(university_id) REFERENCES UNIVERSITY(university_id)
);

create TABLE VERIFIER(
    verifier_id         INT         NOT NULL,
    organization_name   VARCHAR(100) NOT NULL,
    contact_email       VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY(verifier_id)
);

create TABLE DISCLOSURE_PROOF (
    proof_id        INT         NOT NULL,
    student_id      INT         NOT NULL,
    verifier_id     INT         NOT NULL,
    status       VARCHAR(10)  NOT NULL CHECK (status IN ('active', 'revoked')),
    created_at      DATETIME    NOT NULL,
    expires_at      DATETIME    NOT NULL,
    share_token     CHAR(64) UNIQUE,
    revoked_at      DATETIME,
    CHECK (expires_at > created_at),
    PRIMARY KEY(proof_id),
    FOREIGN KEY(student_id) REFERENCES STUDENT(student_id),
    FOREIGN KEY(verifier_id) REFERENCES VERIFIER(verifier_id)   
);

create TABLE STUDENT_PHONE(
    student_id      INT         NOT NULL,
    phone_number    VARCHAR(15) NOT NULL,
    PRIMARY KEY(student_id, phone_number),
    FOREIGN KEY(student_id) REFERENCES STUDENT(student_id)
);
