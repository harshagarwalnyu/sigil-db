-- INSERT seed data (10+ rows per table): mohammad
-- Do NOT run until every table is created.
INSERT INTO STUDENT VALUES
(1,  1,  'Omar',    'Haddad',   'omar.haddad@mit.edu',        '2004-03-12'),
(2,  2,  'Aisha',   'Rahman',   'aisha.rahman@stanford.edu',  '2003-07-25'),
(3,  3,  'Daniel',  'Kim',      'daniel.kim@harvard.edu',     '2004-11-02'),
(4,  4,  'Sofia',   'Martinez', 'sofia.martinez@berkeley.edu','2005-01-18'),
(5,  5,  'Ethan',   'Clark',    'ethan.clark@princeton.edu',  '2003-09-30'),
(6,  6,  'Noura',   'Alqahtani','noura.alqahtani@columbia.edu','2004-05-14'),
(7,  7,  'Lucas',   'Nguyen',   'lucas.nguyen@uchicago.edu',  '2004-08-09'),
(8,  8,  'Hannah',  'Lee',      'hannah.lee@yale.edu',        '2005-02-27'),
(9,  9,  'Yusuf',   'Demir',    'yusuf.demir@cornell.edu',    '2003-12-05'),
(10, 10, 'Grace',   'Patel',    'grace.patel@cmu.edu',        '2004-06-21');

INSERT INTO VERIFIER VALUES
(1,  'Google',              'hiring@google.com'),
(2,  'Microsoft',           'recruiting@microsoft.com'),
(3,  'Amazon',              'talent@amazon.com'),
(4,  'Goldman Sachs',       'careers@gs.com'),
(5,  'Deloitte',            'verify@deloitte.com'),
(6,  'Meta',                'recruiting@meta.com'),
(7,  'Apple',               'jobs@apple.com'),
(8,  'JPMorgan Chase',      'campus@jpmorgan.com'),
(9,  'IBM',                 'hr@ibm.com'),
(10, 'NYU Graduate School', 'admissions@nyu.edu');

INSERT INTO DISCLOSURE_PROOF VALUES
(1,  1,  1,  'active',  '2026-09-01 10:00:00', '2026-12-01 10:00:00'),
(2,  2,  3,  'active',  '2026-09-05 14:30:00', '2026-12-05 14:30:00'),
(3,  3,  2,  'revoked', '2026-09-10 09:15:00', '2026-12-10 09:15:00'),
(4,  4,  4,  'active',  '2026-09-12 16:45:00', '2026-12-12 16:45:00'),
(5,  5,  5,  'active',  '2026-09-20 11:00:00', '2026-12-20 11:00:00'),
(6,  6,  10, 'active',  '2026-10-01 08:00:00', '2027-01-01 08:00:00'),
(7,  7,  6,  'revoked', '2026-10-03 13:20:00', '2027-01-03 13:20:00'),
(8,  8,  8,  'active',  '2026-10-07 15:10:00', '2027-01-07 15:10:00'),
(9,  9,  9,  'active',  '2026-10-15 10:30:00', '2027-01-15 10:30:00'),
(10, 10, 7,  'active',  '2026-10-20 12:00:00', '2027-01-20 12:00:00'),
(11, 1,  6,  'active',  '2026-10-25 09:00:00', '2027-01-25 09:00:00');

INSERT INTO STUDENT_PHONE VALUES
(1,  '617-555-0101'),
(1,  '617-555-0102'),
(2,  '650-555-0201'),
(3,  '617-555-0301'),
(4,  '510-555-0401'),
(5,  '609-555-0501'),
(6,  '212-555-0601'),
(6,  '212-555-0602'),
(7,  '312-555-0701'),
(8,  '203-555-0801'),
(9,  '607-555-0901'),
(10, '412-555-1001');
