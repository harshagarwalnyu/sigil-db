# Implementation decisions

MySQL 8.4 is the implementation target. The submitted Milestone PDFs are
historical design artifacts; this file records the implementation differences.

Courses require an instructor from the same university. University addresses
from the earlier overview are outside the implemented schema; UNIVERSITY stores
the ID, name, and public key. STUDENT_PHONE and DISCLOSED_GRADE are the two
additional relations supporting the eight core entities.

Grade content is append-only: corrections insert a new row, and deletion is
blocked. There is exactly one permitted metadata update: an unpublished grade
may receive its checkpoint_id and zero-based leaf_index together. The checkpoint
must match the course university and term, and the index must be in range and
unique within that checkpoint. No grade content may change during sealing.
This is an explicit exception to the older blanket prohibition on UPDATE.

Seed leaf hashes use SHA-256 of the UTF-8 string
`grade_id|student_id|course_id|letter_grade|salt`. Parents hash the concatenated
raw 32-byte child hashes, not their hexadecimal text. A one-leaf tree's root is
that leaf hash. Larger trees duplicate an unpaired final child at each level.
Leaves are ordered by leaf_index, starting at zero. Checkpoint 1 has two leaves
(original grade 1 and correction 11); the correction was recorded before that
checkpoint's publication. The other seed checkpoints each have one leaf.

The fixed salts, `keyN` public keys, and `DEMO-ONLY-signature-N` values are test
fixtures, not cryptographically secure credentials. The roots commit to the
actual seed grade leaves, but these signatures cannot pass real signature
verification. Production uses random salts and genuine keys/signatures generated
outside SQL. An application must compute a root from a stable grade batch before
calling publish_checkpoint; the database accepts that root and signature as
inputs and does not verify their cryptography. Concurrent publication requires
application serialization of grade entry and checkpoint publication for a term.

is_proof_valid checks database state: active status, expiration, nonempty
disclosure, ownership, publication, and current grade version. A true result
does not prove hash or signature validity. The verifier must independently check
the leaf hashes, Merkle paths, and signed root against a trusted university key.
Backend reconstruction uses only ordered leaf hashes, including superseded
leaves, and exposes only the requested proof paths to a verifier.

An offline proof establishes inclusion in a signed historical checkpoint.
Current-grade and revocation checks require fresh trusted state; an offline
file alone cannot establish them. Public proof IDs also require an application
access-control design before deployment; the SQL examples demonstrate queries,
not a complete authentication or sharing-token implementation.
