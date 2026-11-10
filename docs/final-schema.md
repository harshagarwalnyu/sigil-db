# Final relational schema

PK marks primary-key attributes; FK names the referenced relation. Nullable attributes are suffixed with ?. The SQL export contains all CHECK and UNIQUE constraints.

COURSE has no university_id: COURSE.instructor_id → INSTRUCTOR.instructor_id → INSTRUCTOR.university_id. COURSE_CONTEXT is a derived view, not an additional stored relation.

**CORRECTION_REQUEST**(request_id [PK], grade_id [FK] → GRADE.grade_id, instructor_id [FK] → INSTRUCTOR.instructor_id, proposed_letter_grade, change_reason, evidence_uri?, status, requested_at, reviewed_at?, reviewer_comment?, approved_grade_id? [FK, UK] → GRADE.grade_id)

**COURSE**(course_id [PK], instructor_id [FK] → INSTRUCTOR.instructor_id, course_code, title, credit_hours, term, section, submission_deadline?)

**DISCLOSED_GRADE**(proof_id [PK, FK] → DISCLOSURE_PROOF.proof_id, grade_id [PK, FK] → GRADE.grade_id)

**DISCLOSURE_PROOF**(proof_id [PK], student_id [FK] → STUDENT.student_id, verifier_id [FK] → VERIFIER.verifier_id, status, created_at, expires_at, share_token? [UK], revoked_at?)

**ENROLLMENT**(student_id [PK, FK] → STUDENT.student_id, course_id [PK, FK] → COURSE.course_id, enrolled_at)

**GRADE**(grade_id [PK], student_id [FK] → STUDENT.student_id, course_id [FK] → COURSE.course_id, checkpoint_id? [FK] → MERKLE_CHECKPOINT.checkpoint_id, supersedes_grade_id? [FK, UK] → GRADE.grade_id, letter_grade, salt, leaf_hash [UK], leaf_index?, change_reason?, recorded_at)

**GRADE_DRAFT**(student_id [PK, FK] → ENROLLMENT.student_id, course_id [PK, FK] → ENROLLMENT.course_id, letter_grade, saved_at)

**INSTRUCTOR**(instructor_id [PK], university_id [FK] → UNIVERSITY.university_id, first_name?, last_name?, email? [UK], department?)

**MERKLE_CHECKPOINT**(checkpoint_id [PK], university_id [FK] → UNIVERSITY.university_id, term, version_no, root_hash, leaf_count, signature, published_at)

**STUDENT**(student_id [PK], university_id [FK] → UNIVERSITY.university_id, first_name, last_name, email [UK], date_of_birth, netid? [UK], student_number? [UK])

**STUDENT_PHONE**(student_id [PK, FK] → STUDENT.student_id, phone_number [PK])

**UNIVERSITY**(university_id [PK], name [UK], public_key)

**VERIFIER**(verifier_id [PK], organization_name, contact_email [UK])

The checkpoint and proof minimum-one-child relationships express valid published business objects. A proof may temporarily have zero selected grades during a transaction; is_proof_valid rejects an empty proof.

Normalization: ENROLLMENT and GRADE_DRAFT depend on their complete (student_id, course_id) key; phone numbers and disclosed grades use separate relations. University membership is derived through INSTRUCTOR rather than duplicated on COURSE. GPA and current-grade status remain derived.
