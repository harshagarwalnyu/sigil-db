-- Rebuilds the whole database from scratch. Run from the repo root:
--   mysql -u <user> -p < build.sql
-- 04_queries is NOT run here (those are the app's queries, run them by hand to test).

DROP DATABASE IF EXISTS sigil;
CREATE DATABASE sigil;
USE sigil;

-- 1. Tables (order matters: referenced tables first)
SOURCE sql/01_create/1_khalid.sql;
SOURCE sql/01_create/2_mohammad.sql;
SOURCE sql/01_create/3_pratyush.sql;

-- 2. Advanced commands (before data, so triggers/checks validate the seed rows)
SOURCE sql/02_advanced/harsh.sql;

-- 3. Seed data
SOURCE sql/03_seed/1_khalid.sql;
SOURCE sql/03_seed/2_mohammad.sql;
SOURCE sql/03_seed/3_pratyush.sql;
