-- INSERT seed data (10+ rows per table): pratyush
-- Do NOT run until every table is created.

INSERT INTO GRADE VALUES
(1,  1,  1,  1,    NULL, 'B+', 'salt1',
 SHA2(CONCAT_WS('|', 1, 1, 1, 'B+', 'salt1'), 256),
 1, NULL, '2025-12-15 10:00:00'),

(2,  2,  2,  2,    NULL, 'A',  'salt2',
 SHA2(CONCAT_WS('|', 2, 2, 2, 'A', 'salt2'), 256),
 1, NULL, '2025-12-15 10:30:00'),

(3,  3,  3,  3,    NULL, 'B',  'salt3',
 SHA2(CONCAT_WS('|', 3, 3, 3, 'B', 'salt3'), 256),
 1, NULL, '2025-12-16 11:00:00'),

(4,  4,  4,  4,    NULL, 'A-', 'salt4',
 SHA2(CONCAT_WS('|', 4, 4, 4, 'A-', 'salt4'), 256),
 1, NULL, '2025-12-16 14:15:00'),

(5,  5,  5,  5,    NULL, 'B+', 'salt5',
 SHA2(CONCAT_WS('|', 5, 5, 5, 'B+', 'salt5'), 256),
 1, NULL, '2025-12-17 09:20:00'),

(6,  6,  6,  6,    NULL, 'A',  'salt6',
 SHA2(CONCAT_WS('|', 6, 6, 6, 'A', 'salt6'), 256),
 1, NULL, '2025-12-17 13:45:00'),

(7,  7,  7,  7,    NULL, 'B',  'salt7',
 SHA2(CONCAT_WS('|', 7, 7, 7, 'B', 'salt7'), 256),
 1, NULL, '2025-12-18 10:10:00'),

(8,  8,  8,  8,    NULL, 'A-', 'salt8',
 SHA2(CONCAT_WS('|', 8, 8, 8, 'A-', 'salt8'), 256),
 1, NULL, '2025-12-18 15:00:00'),

(9,  9,  9,  9,    NULL, 'B+', 'salt9',
 SHA2(CONCAT_WS('|', 9, 9, 9, 'B+', 'salt9'), 256),
 1, NULL, '2025-12-19 11:30:00'),

(10, 10, 10, 10,   NULL, 'A',  'salt10',
 SHA2(CONCAT_WS('|', 10, 10, 10, 'A', 'salt10'), 256),
 1, NULL, '2025-12-19 16:00:00'),

(11, 1,  1,  1,    1,    'A',  'salt11',
 SHA2(CONCAT_WS('|', 11, 1, 1, 'A', 'salt11'), 256),
 2, 'Final exam question 4 regraded after review; approved by registrar.', '2025-12-28 14:00:00'),

(12, 3,  3,  NULL, 3,    'A-', 'salt12',
 SHA2(CONCAT_WS('|', 12, 3, 3, 'A-', 'salt12'), 256),
 NULL, 'Midterm rubric adjustment verified by instructor; approved by registrar.', '2026-01-10 09:30:00');

INSERT INTO DISCLOSED_GRADE VALUES
(1,  11),
(2,  2),
(3,  3),
(4,  4),
(5,  5),
(6,  6),
(7,  7),
(8,  8),
(9,  9),
(10, 10),
(11, 11);