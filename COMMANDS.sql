-- Sigil Milestone 3: actual MySQL export plus tested application queries.
-- WARNING: importing recreates the disposable sigil database.
-- MySQL dump 10.13  Distrib 8.4.9, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: sigil
-- ------------------------------------------------------
-- Server version	8.4.9

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `sigil`
--

/*!40000 DROP DATABASE IF EXISTS `sigil`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `sigil` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `sigil`;

--
-- Table structure for table `CORRECTION_REQUEST`
--

DROP TABLE IF EXISTS `CORRECTION_REQUEST`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CORRECTION_REQUEST` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `grade_id` int NOT NULL,
  `instructor_id` int NOT NULL,
  `proposed_letter_grade` varchar(2) NOT NULL,
  `change_reason` varchar(500) NOT NULL,
  `evidence_uri` varchar(500) DEFAULT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'pending',
  `requested_at` datetime NOT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `reviewer_comment` varchar(500) DEFAULT NULL,
  `approved_grade_id` int DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `approved_grade_id` (`approved_grade_id`),
  KEY `grade_id` (`grade_id`),
  KEY `instructor_id` (`instructor_id`),
  CONSTRAINT `correction_request_ibfk_1` FOREIGN KEY (`grade_id`) REFERENCES `GRADE` (`grade_id`),
  CONSTRAINT `correction_request_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `INSTRUCTOR` (`instructor_id`),
  CONSTRAINT `correction_request_ibfk_3` FOREIGN KEY (`approved_grade_id`) REFERENCES `GRADE` (`grade_id`),
  CONSTRAINT `correction_request_chk_1` CHECK ((`proposed_letter_grade` in (_cp850'A',_cp850'A-',_cp850'B+',_cp850'B',_cp850'B-',_cp850'C+',_cp850'C',_cp850'C-',_cp850'D+',_cp850'D',_cp850'F'))),
  CONSTRAINT `correction_request_chk_2` CHECK ((char_length(trim(`change_reason`)) > 0)),
  CONSTRAINT `correction_request_chk_3` CHECK ((`status` in (_cp850'draft',_cp850'pending',_cp850'approved',_cp850'rejected'))),
  CONSTRAINT `correction_request_chk_4` CHECK (((`reviewed_at` is null) or (`reviewed_at` >= `requested_at`))),
  CONSTRAINT `correction_request_chk_5` CHECK ((((`status` in (_cp850'draft',_cp850'pending')) and (`reviewed_at` is null) and (`approved_grade_id` is null)) or ((`status` = _cp850'approved') and (`reviewed_at` is not null) and (`approved_grade_id` is not null)) or ((`status` = _cp850'rejected') and (`reviewed_at` is not null) and (`approved_grade_id` is null) and (`reviewer_comment` is not null) and (char_length(trim(`reviewer_comment`)) > 0))))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CORRECTION_REQUEST`
--

LOCK TABLES `CORRECTION_REQUEST` WRITE;
/*!40000 ALTER TABLE `CORRECTION_REQUEST` DISABLE KEYS */;
INSERT INTO `CORRECTION_REQUEST` VALUES (1,1,1,'A','Final exam question 4 regraded.',NULL,'approved','2025-12-27 10:00:00','2025-12-28 14:00:00','Approved after review',11),(2,3,3,'A-','Midterm rubric adjustment.',NULL,'approved','2026-01-09 10:00:00','2026-01-10 09:30:00','Approved rubric correction',12),(3,2,2,'A-','Recheck final exam arithmetic.',NULL,'pending','2026-11-01 10:00:00',NULL,NULL,NULL),(4,4,4,'A','Lab points omitted from final total.','evidence/lab-rubric.pdf','pending','2026-11-02 10:00:00',NULL,NULL,NULL),(5,5,5,'A-','Late assignment credit verified.',NULL,'pending','2026-11-03 10:00:00',NULL,NULL,NULL),(6,6,6,'A-','Request to revisit participation mark.',NULL,'rejected','2026-10-01 10:00:00','2026-10-02 10:00:00','No grading error established',NULL),(7,7,7,'B+','Examination page was not scanned.',NULL,'pending','2026-11-04 10:00:00',NULL,NULL,NULL),(8,8,8,'A','Essay rubric review.',NULL,'draft','2026-11-05 10:00:00',NULL,NULL,NULL),(9,9,9,'A-','Problem set total entered incorrectly.',NULL,'pending','2026-11-06 10:00:00',NULL,NULL,NULL),(10,10,10,'A-','Resubmission eligibility review.',NULL,'rejected','2026-10-10 10:00:00','2026-10-11 10:00:00','Resubmission deadline had passed',NULL);
/*!40000 ALTER TABLE `CORRECTION_REQUEST` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `request_before_insert` BEFORE INSERT ON `CORRECTION_REQUEST` FOR EACH ROW BEGIN
    IF NOT EXISTS (SELECT 1 FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
        WHERE g.grade_id=NEW.grade_id AND c.instructor_id=NEW.instructor_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Request must come from the course instructor';
    END IF;
    -- Historical approved requests refer to the old grade they replaced.
    IF NEW.status IN ('draft','pending') AND NOT EXISTS (
        SELECT 1 FROM GRADE g WHERE g.grade_id=NEW.grade_id
          AND g.checkpoint_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Request must target the current sealed grade';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `COURSE`
--

DROP TABLE IF EXISTS `COURSE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `COURSE` (
  `course_id` int NOT NULL AUTO_INCREMENT,
  `instructor_id` int NOT NULL,
  `course_code` varchar(50) NOT NULL,
  `title` varchar(255) NOT NULL,
  `credit_hours` int NOT NULL,
  `term` varchar(50) NOT NULL,
  `section` varchar(10) NOT NULL DEFAULT '001',
  `submission_deadline` datetime DEFAULT NULL,
  PRIMARY KEY (`course_id`),
  UNIQUE KEY `instructor_id` (`instructor_id`,`course_code`,`term`,`section`),
  CONSTRAINT `course_ibfk_1` FOREIGN KEY (`instructor_id`) REFERENCES `INSTRUCTOR` (`instructor_id`),
  CONSTRAINT `course_chk_1` CHECK ((`credit_hours` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `COURSE`
--

LOCK TABLES `COURSE` WRITE;
/*!40000 ALTER TABLE `COURSE` DISABLE KEYS */;
INSERT INTO `COURSE` VALUES (1,1,'CS101','Intro to Programming',3,'Fall 2025','001','2025-12-20 23:59:59'),(2,2,'MATH201','Calculus II',3,'Fall 2025','001','2025-12-20 23:59:59'),(3,3,'ECON101','Microeconomics',3,'Fall 2025','001','2025-12-20 23:59:59'),(4,4,'PHYS101','General Physics',4,'Fall 2025','001','2025-12-20 23:59:59'),(5,5,'CHEM101','General Chemistry',4,'Fall 2025','001','2025-12-20 23:59:59'),(6,6,'BIO101','Intro to Biology',4,'Fall 2025','001','2025-12-20 23:59:59'),(7,7,'STAT201','Probability',3,'Fall 2025','001','2025-12-20 23:59:59'),(8,8,'HIST101','World History',3,'Fall 2025','001','2025-12-20 23:59:59'),(9,9,'ENGR101','Intro to Engineering',3,'Fall 2025','001','2025-12-20 23:59:59'),(10,10,'SE301','Software Design',3,'Fall 2025','001','2025-12-20 23:59:59'),(11,1,'CS101-II','Intro to Programming II',3,'Fall 2026','001','2026-12-20 23:59:59'),(12,2,'MATH201-II','Calculus II II',3,'Fall 2026','001','2026-12-20 23:59:59'),(13,3,'ECON101-II','Microeconomics II',3,'Fall 2026','001','2026-12-20 23:59:59'),(14,4,'PHYS101-II','General Physics II',4,'Fall 2026','001','2026-12-20 23:59:59'),(15,5,'CHEM101-II','General Chemistry II',4,'Fall 2026','001','2026-12-20 23:59:59'),(16,6,'BIO101-II','Intro to Biology II',4,'Fall 2026','001','2026-12-20 23:59:59'),(17,7,'STAT201-II','Probability II',3,'Fall 2026','001','2026-12-20 23:59:59'),(18,8,'HIST101-II','World History II',3,'Fall 2026','001','2026-12-20 23:59:59'),(19,9,'ENGR101-II','Intro to Engineering II',3,'Fall 2026','001','2026-12-20 23:59:59'),(20,10,'SE301-II','Software Design II',3,'Fall 2026','001','2026-12-20 23:59:59'),(21,1,'CS205','Data Structures',4,'Spring 2026','001','2026-05-20 23:59:59'),(22,1,'CS230','Discrete Mathematics',3,'Spring 2026','001','2026-05-20 23:59:59');
/*!40000 ALTER TABLE `COURSE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `COURSE_CONTEXT`
--

DROP TABLE IF EXISTS `COURSE_CONTEXT`;
/*!50001 DROP VIEW IF EXISTS `COURSE_CONTEXT`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `COURSE_CONTEXT` AS SELECT
 1 AS `course_id`,
 1 AS `instructor_id`,
 1 AS `course_code`,
 1 AS `title`,
 1 AS `credit_hours`,
 1 AS `term`,
 1 AS `section`,
 1 AS `submission_deadline`,
 1 AS `university_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `DISCLOSED_GRADE`
--

DROP TABLE IF EXISTS `DISCLOSED_GRADE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DISCLOSED_GRADE` (
  `proof_id` int NOT NULL,
  `grade_id` int NOT NULL,
  PRIMARY KEY (`proof_id`,`grade_id`),
  KEY `grade_id` (`grade_id`),
  CONSTRAINT `disclosed_grade_ibfk_1` FOREIGN KEY (`proof_id`) REFERENCES `DISCLOSURE_PROOF` (`proof_id`),
  CONSTRAINT `disclosed_grade_ibfk_2` FOREIGN KEY (`grade_id`) REFERENCES `GRADE` (`grade_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DISCLOSED_GRADE`
--

LOCK TABLES `DISCLOSED_GRADE` WRITE;
/*!40000 ALTER TABLE `DISCLOSED_GRADE` DISABLE KEYS */;
INSERT INTO `DISCLOSED_GRADE` VALUES (2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10),(1,11),(11,11),(1,13);
/*!40000 ALTER TABLE `DISCLOSED_GRADE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `DISCLOSURE_PROOF`
--

DROP TABLE IF EXISTS `DISCLOSURE_PROOF`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `DISCLOSURE_PROOF` (
  `proof_id` int NOT NULL,
  `student_id` int NOT NULL,
  `verifier_id` int NOT NULL,
  `status` varchar(10) NOT NULL,
  `created_at` datetime NOT NULL,
  `expires_at` datetime NOT NULL,
  `share_token` char(64) DEFAULT NULL,
  `revoked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`proof_id`),
  UNIQUE KEY `share_token` (`share_token`),
  KEY `student_id` (`student_id`),
  KEY `verifier_id` (`verifier_id`),
  CONSTRAINT `disclosure_proof_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `STUDENT` (`student_id`),
  CONSTRAINT `disclosure_proof_ibfk_2` FOREIGN KEY (`verifier_id`) REFERENCES `VERIFIER` (`verifier_id`),
  CONSTRAINT `disclosure_proof_chk_1` CHECK ((`status` in (_cp850'active',_cp850'revoked'))),
  CONSTRAINT `disclosure_proof_chk_2` CHECK ((`expires_at` > `created_at`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `DISCLOSURE_PROOF`
--

LOCK TABLES `DISCLOSURE_PROOF` WRITE;
/*!40000 ALTER TABLE `DISCLOSURE_PROOF` DISABLE KEYS */;
INSERT INTO `DISCLOSURE_PROOF` VALUES (1,1,1,'active','2026-09-01 10:00:00','2026-12-01 10:00:00','65d01b54c870182ca3365564dbc7677a196f72a52f1ec15fdbf2da5efd013345',NULL),(2,2,3,'active','2026-09-05 14:30:00','2026-12-05 14:30:00','75e2c402bd94ae6120970a34fbb6c85702daf622ba2a9b2a1bcc33ecb06c2ffa',NULL),(3,3,2,'revoked','2026-09-10 09:15:00','2026-12-10 09:15:00','5afd495756689d04e1216b5df82338997fb40d3e1429298d1086a3246fb4b4c9','2026-09-10 09:15:00'),(4,4,4,'active','2026-09-12 16:45:00','2026-12-12 16:45:00','4d1f5d280e73386cae594fcc248d17af83f4183fd0f093855820bb03190107ba',NULL),(5,5,5,'active','2026-09-20 11:00:00','2026-12-20 11:00:00','4c9c1a199dbe52c46c8bcea9a04a10315a10c5d63abd6705f66ca5e2053c93f0',NULL),(6,6,10,'active','2026-10-01 08:00:00','2027-01-01 08:00:00','61b0cde39fbed9d66534ded31a4ed332ee7320693174e8029acde5d085b835c8',NULL),(7,7,6,'revoked','2026-10-03 13:20:00','2027-01-03 13:20:00','d1201d02510457be4a0f319b34f6b96809e67d85523bc37ebce87aedfa5239e4','2026-10-03 13:20:00'),(8,8,8,'active','2026-10-07 15:10:00','2027-01-07 15:10:00','9fe4d4c0f12a98eebbcf19e3fc8e22ba5b50d7df2fc3944c427dcccd13e82cdd',NULL),(9,9,9,'active','2026-10-15 10:30:00','2027-01-15 10:30:00','6dd500f69de94e0d7fa9b4816f6505082bee4bb7b4a4d818494d0204e3b450ad',NULL),(10,10,7,'active','2026-10-20 12:00:00','2027-01-20 12:00:00','cd65b17c43e7ce2b8d6cb1cb482e3d0ff5836bfdfccd4b1b4b61ae1694094e48',NULL),(11,1,6,'active','2026-10-25 09:00:00','2027-01-25 09:00:00','77c0e610d04036e9946b1b5e6f099f1c43fbd0e2f7e9be3725f295cb47ab994d',NULL);
/*!40000 ALTER TABLE `DISCLOSURE_PROOF` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `proof_before_update` BEFORE UPDATE ON `DISCLOSURE_PROOF` FOR EACH ROW BEGIN
    IF OLD.status='revoked' AND NEW.status<>'revoked' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Revocation cannot be undone';
    END IF;
    IF NEW.status='revoked' AND OLD.status<>'revoked' THEN
        SET NEW.revoked_at=NOW();
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `ENROLLMENT`
--

DROP TABLE IF EXISTS `ENROLLMENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ENROLLMENT` (
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `enrolled_at` datetime NOT NULL,
  PRIMARY KEY (`student_id`,`course_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `enrollment_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `STUDENT` (`student_id`),
  CONSTRAINT `enrollment_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `COURSE` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ENROLLMENT`
--

LOCK TABLES `ENROLLMENT` WRITE;
/*!40000 ALTER TABLE `ENROLLMENT` DISABLE KEYS */;
INSERT INTO `ENROLLMENT` VALUES (1,1,'2025-09-01 09:00:00'),(1,11,'2026-09-01 09:00:00'),(1,21,'2026-01-20 09:00:00'),(1,22,'2026-01-20 09:00:00'),(2,2,'2025-09-01 09:00:00'),(2,12,'2026-09-01 09:00:00'),(3,3,'2025-09-01 09:00:00'),(3,13,'2026-09-01 09:00:00'),(4,4,'2025-09-01 09:00:00'),(4,14,'2026-09-01 09:00:00'),(5,5,'2025-09-01 09:00:00'),(5,15,'2026-09-01 09:00:00'),(6,6,'2025-09-01 09:00:00'),(6,16,'2026-09-01 09:00:00'),(7,7,'2025-09-01 09:00:00'),(7,17,'2026-09-01 09:00:00'),(8,8,'2025-09-01 09:00:00'),(8,18,'2026-09-01 09:00:00'),(9,9,'2025-09-01 09:00:00'),(9,19,'2026-09-01 09:00:00'),(10,10,'2025-09-01 09:00:00'),(10,20,'2026-09-01 09:00:00');
/*!40000 ALTER TABLE `ENROLLMENT` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `enrollment_before_insert` BEFORE INSERT ON `ENROLLMENT` FOR EACH ROW BEGIN
    IF NOT EXISTS (SELECT 1 FROM STUDENT s JOIN COURSE_CONTEXT c
          ON s.university_id=c.university_id
          WHERE s.student_id=NEW.student_id AND c.course_id=NEW.course_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Enrollment requires the same university';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `GRADE`
--

DROP TABLE IF EXISTS `GRADE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `GRADE` (
  `grade_id` int NOT NULL AUTO_INCREMENT,
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `checkpoint_id` int DEFAULT NULL,
  `supersedes_grade_id` int DEFAULT NULL,
  `letter_grade` varchar(2) NOT NULL,
  `salt` char(64) NOT NULL,
  `leaf_hash` char(64) NOT NULL,
  `leaf_index` int DEFAULT NULL,
  `change_reason` varchar(500) DEFAULT NULL,
  `recorded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`grade_id`),
  UNIQUE KEY `leaf_hash` (`leaf_hash`),
  UNIQUE KEY `supersedes_grade_id` (`supersedes_grade_id`),
  UNIQUE KEY `checkpoint_id` (`checkpoint_id`,`leaf_index`),
  UNIQUE KEY `uq_original_student_course` (`student_id`,((case when (`supersedes_grade_id` is null) then `course_id` else NULL end))),
  KEY `course_id` (`course_id`),
  CONSTRAINT `grade_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `STUDENT` (`student_id`),
  CONSTRAINT `grade_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `COURSE` (`course_id`),
  CONSTRAINT `grade_ibfk_3` FOREIGN KEY (`checkpoint_id`) REFERENCES `MERKLE_CHECKPOINT` (`checkpoint_id`),
  CONSTRAINT `grade_ibfk_4` FOREIGN KEY (`supersedes_grade_id`) REFERENCES `GRADE` (`grade_id`),
  CONSTRAINT `grade_chk_1` CHECK ((`letter_grade` in (_utf8mb4'A',_utf8mb4'A-',_utf8mb4'B+',_utf8mb4'B',_utf8mb4'B-',_utf8mb4'C+',_utf8mb4'C',_utf8mb4'C-',_utf8mb4'D+',_utf8mb4'D',_utf8mb4'F'))),
  CONSTRAINT `grade_chk_2` CHECK (((`supersedes_grade_id` is null) or ((`change_reason` is not null) and (char_length(trim(`change_reason`)) > 0)))),
  CONSTRAINT `grade_chk_3` CHECK ((((`checkpoint_id` is null) and (`leaf_index` is null)) or ((`checkpoint_id` is not null) and (`leaf_index` is not null) and (`leaf_index` >= 0))))
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GRADE`
--

LOCK TABLES `GRADE` WRITE;
/*!40000 ALTER TABLE `GRADE` DISABLE KEYS */;
INSERT INTO `GRADE` VALUES (1,1,1,1,NULL,'B+','salt1','923df89e1cad53c1f182208ce7a7fe98935e875ecca495eccd12e93654dac895',0,NULL,'2025-12-15 10:00:00'),(2,2,2,2,NULL,'A','salt2','ee85e7e2deeec05c1b189683254a5814bb3a9def6912c84f0c0545dec04efc06',0,NULL,'2025-12-15 10:30:00'),(3,3,3,3,NULL,'B','salt3','5e52cc306ab1e2878bcd4e5b0811938d860eaa0ce43f1637d63966299b972185',0,NULL,'2025-12-16 11:00:00'),(4,4,4,4,NULL,'A-','salt4','86238d0132d9345c8283738e184bc0a84b04c508141f1d167de20fcb4c78dc60',0,NULL,'2025-12-16 14:15:00'),(5,5,5,5,NULL,'B+','salt5','b1915578f0366e8fdaf0f6de469f25736e3756e60dce329f077fd294e47446e1',0,NULL,'2025-12-17 09:20:00'),(6,6,6,6,NULL,'A','salt6','e948519501b4318c396da96584698561afda5b5d873e3c30538c075794d9ccd1',0,NULL,'2025-12-17 13:45:00'),(7,7,7,7,NULL,'B','salt7','7af740f4ed0d470e2c3c176d6428f0c6ccd2d4e6e6550c8a15453bd287004a94',0,NULL,'2025-12-18 10:10:00'),(8,8,8,8,NULL,'A-','salt8','33d2ffd0b891e78c44110ae4d15c187d575af4f90804b5b6ba5ea1f9ffc7efc5',0,NULL,'2025-12-18 15:00:00'),(9,9,9,9,NULL,'B+','salt9','5b5e7a2c9e8d5c18e9faefaacfd7d55405697f5ebfa066c887f4f73d5f6021c6',0,NULL,'2025-12-19 11:30:00'),(10,10,10,10,NULL,'A','salt10','41bffe5dfdf2e2a552cc6b18e758b35790f6b3ebf033f84a56246352fe2dd5ca',0,NULL,'2025-12-19 16:00:00'),(11,1,1,1,1,'A','salt11','f3f9d4365e83b42106bc66d0c2abd412015f8eb4f60cb1431d3d3f936eb86e87',1,'Final exam question 4 regraded after review; approved by registrar.','2025-12-28 14:00:00'),(12,3,3,NULL,3,'A-','salt12','4a083911bba0dcb65462755be039f1ac0c42d1a8436802816a2788ce472189f4',NULL,'Midterm rubric adjustment verified by instructor; approved by registrar.','2026-01-10 09:30:00'),(13,1,21,11,NULL,'A-','salt13','e1278f6852ae0be12fac5f8fe4304595d606ae756d3d529dabc85112d460404b',0,NULL,'2026-05-19 10:00:00'),(14,1,22,11,NULL,'B+','salt14','5597416a9eb5e635d45189f94f753005748cdaade40c8dc83736011d3c989562',1,NULL,'2026-05-19 11:00:00');
/*!40000 ALTER TABLE `GRADE` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `grade_before_insert` BEFORE INSERT ON `GRADE` FOR EACH ROW BEGIN
    DECLARE old_student INT DEFAULT NULL;
    DECLARE old_course  INT DEFAULT NULL;

    IF NOT EXISTS (
        SELECT 1 FROM STUDENT s JOIN COURSE_CONTEXT c
          ON c.university_id = s.university_id
        WHERE s.student_id = NEW.student_id AND c.course_id = NEW.course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Student and course must belong to the same university';
    END IF;

    IF NEW.checkpoint_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM MERKLE_CHECKPOINT mc JOIN COURSE_CONTEXT c
          ON c.university_id = mc.university_id AND c.term = mc.term
        WHERE mc.checkpoint_id = NEW.checkpoint_id AND c.course_id = NEW.course_id
          AND NEW.leaf_index IS NOT NULL
          AND NEW.leaf_index >= 0 AND NEW.leaf_index < mc.leaf_count
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkpoint must match the course university, term and leaf range';
    END IF;

    IF NEW.supersedes_grade_id IS NULL THEN
        IF EXISTS (SELECT 1 FROM GRADE
                   WHERE student_id = NEW.student_id
                     AND course_id  = NEW.course_id
                     AND supersedes_grade_id IS NULL) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Student already has a grade for this course; add a correction instead';
        END IF;
    ELSE
        SELECT student_id, course_id INTO old_student, old_course
        FROM GRADE WHERE grade_id = NEW.supersedes_grade_id;

        IF old_student IS NULL THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'The grade being corrected does not exist';
        END IF;
        IF old_student <> NEW.student_id OR old_course <> NEW.course_id THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A correction must be for the same student and course';
        END IF;
        IF EXISTS (SELECT 1 FROM GRADE WHERE supersedes_grade_id = NEW.supersedes_grade_id) THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'That grade was already corrected; correct the newest version';
        END IF;
        IF NEW.change_reason IS NULL OR TRIM(NEW.change_reason) = '' THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'A correction needs a change_reason';
        END IF;
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `grade_before_update` BEFORE UPDATE ON `GRADE` FOR EACH ROW BEGIN
    IF NOT (
            OLD.checkpoint_id IS NULL
        AND NEW.checkpoint_id IS NOT NULL
        AND NEW.leaf_index IS NOT NULL
        AND NEW.leaf_index >= 0
        AND NEW.grade_id            <=> OLD.grade_id
        AND NEW.student_id          <=> OLD.student_id
        AND NEW.course_id           <=> OLD.course_id
        AND NEW.supersedes_grade_id <=> OLD.supersedes_grade_id
        AND NEW.letter_grade        <=> OLD.letter_grade
        AND NEW.salt                <=> OLD.salt
        AND NEW.leaf_hash           <=> OLD.leaf_hash
        AND NEW.change_reason       <=> OLD.change_reason
        AND NEW.recorded_at         <=> OLD.recorded_at
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Grades are append-only: insert a correction instead of updating';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM MERKLE_CHECKPOINT mc JOIN COURSE_CONTEXT c
          ON c.university_id = mc.university_id AND c.term = mc.term
        WHERE mc.checkpoint_id = NEW.checkpoint_id AND c.course_id = NEW.course_id
          AND NEW.leaf_index < mc.leaf_count
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Checkpoint must match the course university, term and leaf range';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/  /*!50003 TRIGGER `grade_before_delete` BEFORE DELETE ON `GRADE` FOR EACH ROW BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Grades are append-only: rows cannot be deleted';
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `GRADE_DRAFT`
--

DROP TABLE IF EXISTS `GRADE_DRAFT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `GRADE_DRAFT` (
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  `letter_grade` varchar(2) NOT NULL,
  `saved_at` datetime NOT NULL,
  PRIMARY KEY (`student_id`,`course_id`),
  CONSTRAINT `grade_draft_ibfk_1` FOREIGN KEY (`student_id`, `course_id`) REFERENCES `ENROLLMENT` (`student_id`, `course_id`),
  CONSTRAINT `grade_draft_chk_1` CHECK ((`letter_grade` in (_cp850'A',_cp850'A-',_cp850'B+',_cp850'B',_cp850'B-',_cp850'C+',_cp850'C',_cp850'C-',_cp850'D+',_cp850'D',_cp850'F')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `GRADE_DRAFT`
--

LOCK TABLES `GRADE_DRAFT` WRITE;
/*!40000 ALTER TABLE `GRADE_DRAFT` DISABLE KEYS */;
INSERT INTO `GRADE_DRAFT` VALUES (1,11,'A','2026-11-08 15:00:00'),(2,12,'A','2026-11-08 15:00:00'),(3,13,'B+','2026-11-08 15:00:00'),(4,14,'B+','2026-11-08 15:00:00'),(5,15,'B+','2026-11-08 15:00:00'),(6,16,'A','2026-11-08 15:00:00'),(7,17,'B+','2026-11-08 15:00:00'),(8,18,'B+','2026-11-08 15:00:00'),(9,19,'B+','2026-11-08 15:00:00'),(10,20,'A','2026-11-08 15:00:00');
/*!40000 ALTER TABLE `GRADE_DRAFT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `INSTRUCTOR`
--

DROP TABLE IF EXISTS `INSTRUCTOR`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `INSTRUCTOR` (
  `instructor_id` int NOT NULL AUTO_INCREMENT,
  `university_id` int NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `department` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`instructor_id`),
  UNIQUE KEY `email` (`email`),
  KEY `university_id` (`university_id`),
  CONSTRAINT `instructor_ibfk_1` FOREIGN KEY (`university_id`) REFERENCES `UNIVERSITY` (`university_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `INSTRUCTOR`
--

LOCK TABLES `INSTRUCTOR` WRITE;
/*!40000 ALTER TABLE `INSTRUCTOR` DISABLE KEYS */;
INSERT INTO `INSTRUCTOR` VALUES (1,1,'John','Smith','john.smith@mit.edu','Computer Science'),(2,2,'Sarah','Johnson','sarah.johnson@stanford.edu','Mathematics'),(3,3,'Michael','Brown','michael.brown@harvard.edu','Economics'),(4,4,'Emily','Davis','emily.davis@berkeley.edu','Physics'),(5,5,'David','Wilson','david.wilson@princeton.edu','Chemistry'),(6,6,'Jessica','Miller','jessica.miller@columbia.edu','Biology'),(7,7,'Robert','Taylor','robert.taylor@uchicago.edu','Statistics'),(8,8,'Laura','Anderson','laura.anderson@yale.edu','History'),(9,9,'James','Thomas','james.thomas@cornell.edu','Engineering'),(10,10,'Linda','Moore','linda.moore@cmu.edu','Software Engineering');
/*!40000 ALTER TABLE `INSTRUCTOR` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `MERKLE_CHECKPOINT`
--

DROP TABLE IF EXISTS `MERKLE_CHECKPOINT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `MERKLE_CHECKPOINT` (
  `checkpoint_id` int NOT NULL AUTO_INCREMENT,
  `university_id` int NOT NULL,
  `term` varchar(50) NOT NULL,
  `version_no` int NOT NULL,
  `root_hash` char(64) NOT NULL,
  `leaf_count` int NOT NULL,
  `signature` text NOT NULL,
  `published_at` datetime NOT NULL,
  PRIMARY KEY (`checkpoint_id`),
  UNIQUE KEY `university_id` (`university_id`,`term`,`version_no`),
  CONSTRAINT `merkle_checkpoint_ibfk_1` FOREIGN KEY (`university_id`) REFERENCES `UNIVERSITY` (`university_id`),
  CONSTRAINT `merkle_checkpoint_chk_1` CHECK ((`version_no` > 0)),
  CONSTRAINT `merkle_checkpoint_chk_2` CHECK ((`leaf_count` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MERKLE_CHECKPOINT`
--

LOCK TABLES `MERKLE_CHECKPOINT` WRITE;
/*!40000 ALTER TABLE `MERKLE_CHECKPOINT` DISABLE KEYS */;
INSERT INTO `MERKLE_CHECKPOINT` VALUES (1,1,'Fall 2025',1,'fa5e9bdbef8a1e9d10733fc464934d8f8070169c4d1b739d561c1f44a2db44b1',2,'DEMO-ONLY-signature-1','2026-01-01 00:00:00'),(2,2,'Fall 2025',1,'ee85e7e2deeec05c1b189683254a5814bb3a9def6912c84f0c0545dec04efc06',1,'DEMO-ONLY-signature-2','2026-01-01 00:00:00'),(3,3,'Fall 2025',1,'5e52cc306ab1e2878bcd4e5b0811938d860eaa0ce43f1637d63966299b972185',1,'DEMO-ONLY-signature-3','2026-01-01 00:00:00'),(4,4,'Fall 2025',1,'86238d0132d9345c8283738e184bc0a84b04c508141f1d167de20fcb4c78dc60',1,'DEMO-ONLY-signature-4','2026-01-01 00:00:00'),(5,5,'Fall 2025',1,'b1915578f0366e8fdaf0f6de469f25736e3756e60dce329f077fd294e47446e1',1,'DEMO-ONLY-signature-5','2026-01-01 00:00:00'),(6,6,'Fall 2025',1,'e948519501b4318c396da96584698561afda5b5d873e3c30538c075794d9ccd1',1,'DEMO-ONLY-signature-6','2026-01-01 00:00:00'),(7,7,'Fall 2025',1,'7af740f4ed0d470e2c3c176d6428f0c6ccd2d4e6e6550c8a15453bd287004a94',1,'DEMO-ONLY-signature-7','2026-01-01 00:00:00'),(8,8,'Fall 2025',1,'33d2ffd0b891e78c44110ae4d15c187d575af4f90804b5b6ba5ea1f9ffc7efc5',1,'DEMO-ONLY-signature-8','2026-01-01 00:00:00'),(9,9,'Fall 2025',1,'5b5e7a2c9e8d5c18e9faefaacfd7d55405697f5ebfa066c887f4f73d5f6021c6',1,'DEMO-ONLY-signature-9','2026-01-01 00:00:00'),(10,10,'Fall 2025',1,'41bffe5dfdf2e2a552cc6b18e758b35790f6b3ebf033f84a56246352fe2dd5ca',1,'DEMO-ONLY-signature-10','2026-01-01 00:00:00'),(11,1,'Spring 2026',1,'5730a61f7c8b37308ae89b8d4bad94468382a8ec4dc2195c8ae8a88be6ca7b06',2,'DEMO-ONLY-signature-11','2026-06-01 10:00:00');
/*!40000 ALTER TABLE `MERKLE_CHECKPOINT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `STUDENT`
--

DROP TABLE IF EXISTS `STUDENT`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `STUDENT` (
  `student_id` int NOT NULL,
  `university_id` int NOT NULL,
  `first_name` varchar(25) NOT NULL,
  `last_name` varchar(25) NOT NULL,
  `email` varchar(50) NOT NULL,
  `date_of_birth` date NOT NULL,
  `netid` varchar(25) DEFAULT NULL,
  `student_number` char(9) DEFAULT NULL,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `netid` (`netid`),
  UNIQUE KEY `student_number` (`student_number`),
  KEY `university_id` (`university_id`),
  CONSTRAINT `student_ibfk_1` FOREIGN KEY (`university_id`) REFERENCES `UNIVERSITY` (`university_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `STUDENT`
--

LOCK TABLES `STUDENT` WRITE;
/*!40000 ALTER TABLE `STUDENT` DISABLE KEYS */;
INSERT INTO `STUDENT` VALUES (1,1,'Omar','Haddad','omar.haddad@mit.edu','2004-03-12','oh0001','N00000001'),(2,2,'Aisha','Rahman','aisha.rahman@stanford.edu','2003-07-25','ar0002','N00000002'),(3,3,'Daniel','Kim','daniel.kim@harvard.edu','2004-11-02','dk0003','N00000003'),(4,4,'Sofia','Martinez','sofia.martinez@berkeley.edu','2005-01-18','sm0004','N00000004'),(5,5,'Ethan','Clark','ethan.clark@princeton.edu','2003-09-30','ec0005','N00000005'),(6,6,'Noura','Alqahtani','noura.alqahtani@columbia.edu','2004-05-14','na0006','N00000006'),(7,7,'Lucas','Nguyen','lucas.nguyen@uchicago.edu','2004-08-09','ln0007','N00000007'),(8,8,'Hannah','Lee','hannah.lee@yale.edu','2005-02-27','hl0008','N00000008'),(9,9,'Yusuf','Demir','yusuf.demir@cornell.edu','2003-12-05','yd0009','N00000009'),(10,10,'Grace','Patel','grace.patel@cmu.edu','2004-06-21','gp0010','N00000010');
/*!40000 ALTER TABLE `STUDENT` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `STUDENT_PHONE`
--

DROP TABLE IF EXISTS `STUDENT_PHONE`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `STUDENT_PHONE` (
  `student_id` int NOT NULL,
  `phone_number` varchar(15) NOT NULL,
  PRIMARY KEY (`student_id`,`phone_number`),
  CONSTRAINT `student_phone_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `STUDENT` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `STUDENT_PHONE`
--

LOCK TABLES `STUDENT_PHONE` WRITE;
/*!40000 ALTER TABLE `STUDENT_PHONE` DISABLE KEYS */;
INSERT INTO `STUDENT_PHONE` VALUES (1,'617-555-0101'),(1,'617-555-0102'),(2,'650-555-0201'),(3,'617-555-0301'),(4,'510-555-0401'),(5,'609-555-0501'),(6,'212-555-0601'),(6,'212-555-0602'),(7,'312-555-0701'),(8,'203-555-0801'),(9,'607-555-0901'),(10,'412-555-1001');
/*!40000 ALTER TABLE `STUDENT_PHONE` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `UNIVERSITY`
--

DROP TABLE IF EXISTS `UNIVERSITY`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `UNIVERSITY` (
  `university_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `public_key` varchar(255) NOT NULL,
  PRIMARY KEY (`university_id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `UNIVERSITY`
--

LOCK TABLES `UNIVERSITY` WRITE;
/*!40000 ALTER TABLE `UNIVERSITY` DISABLE KEYS */;
INSERT INTO `UNIVERSITY` VALUES (1,'Massachusetts Institute of Technology','key1'),(2,'Stanford University','key2'),(3,'Harvard University','key3'),(4,'University of California, Berkeley','key4'),(5,'Princeton University','key5'),(6,'Columbia University','key6'),(7,'University of Chicago','key7'),(8,'Yale University','key8'),(9,'Cornell University','key9'),(10,'Carnegie Mellon University','key10');
/*!40000 ALTER TABLE `UNIVERSITY` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `VERIFIER`
--

DROP TABLE IF EXISTS `VERIFIER`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `VERIFIER` (
  `verifier_id` int NOT NULL,
  `organization_name` varchar(100) NOT NULL,
  `contact_email` varchar(50) NOT NULL,
  PRIMARY KEY (`verifier_id`),
  UNIQUE KEY `contact_email` (`contact_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `VERIFIER`
--

LOCK TABLES `VERIFIER` WRITE;
/*!40000 ALTER TABLE `VERIFIER` DISABLE KEYS */;
INSERT INTO `VERIFIER` VALUES (1,'Google','hiring@google.com'),(2,'Microsoft','recruiting@microsoft.com'),(3,'Amazon','talent@amazon.com'),(4,'Goldman Sachs','careers@gs.com'),(5,'Deloitte','verify@deloitte.com'),(6,'Meta','recruiting@meta.com'),(7,'Apple','jobs@apple.com'),(8,'JPMorgan Chase','campus@jpmorgan.com'),(9,'IBM','hr@ibm.com'),(10,'NYU Graduate School','admissions@nyu.edu');
/*!40000 ALTER TABLE `VERIFIER` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'sigil'
--
/*!50003 DROP FUNCTION IF EXISTS `is_proof_valid` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE FUNCTION `is_proof_valid`(p_proof_id INT) RETURNS tinyint(1)
    READS SQL DATA
BEGIN
    DECLARE v_student INT DEFAULT NULL;
    DECLARE v_status  VARCHAR(20);
    DECLARE v_expires DATETIME;
    DECLARE v_shown   INT DEFAULT 0;
    DECLARE v_bad     INT DEFAULT 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_student = NULL;

    SELECT student_id, status, expires_at INTO v_student, v_status, v_expires
    FROM DISCLOSURE_PROOF WHERE proof_id = p_proof_id;

    IF v_student IS NULL OR v_status <> 'active' THEN
        RETURN FALSE;
    END IF;
    IF v_expires IS NOT NULL AND v_expires <= NOW() THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*) INTO v_shown FROM DISCLOSED_GRADE WHERE proof_id = p_proof_id;
    IF v_shown = 0 THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*) INTO v_bad
    FROM DISCLOSED_GRADE dg
    JOIN GRADE g ON g.grade_id = dg.grade_id
    WHERE dg.proof_id = p_proof_id
      AND (   g.student_id <> v_student
           OR g.checkpoint_id IS NULL
           OR EXISTS (SELECT 1 FROM GRADE newer
                      WHERE newer.supersedes_grade_id = g.grade_id));

    RETURN v_bad = 0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `publish_checkpoint` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `publish_checkpoint`(
    IN p_university_id INT,
    IN p_term          VARCHAR(50),
    IN p_root_hash     VARCHAR(255),
    IN p_signature     TEXT
)
BEGIN
    DECLARE v_count      INT DEFAULT 0;
    DECLARE v_version    INT DEFAULT 1;
    DECLARE v_checkpoint INT;
    DECLARE v_grade      INT;
    DECLARE v_leaf       INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_count
    FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id = g.course_id
    WHERE g.checkpoint_id IS NULL
      AND c.university_id = p_university_id
      AND c.term = p_term;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No unpublished grades for this term';
    END IF;

    SELECT COALESCE(MAX(version_no), 0) + 1 INTO v_version
    FROM MERKLE_CHECKPOINT
    WHERE university_id = p_university_id AND term = p_term;

    INSERT INTO MERKLE_CHECKPOINT
        (university_id, term, version_no, root_hash, leaf_count, signature, published_at)
    VALUES
        (p_university_id, p_term, v_version, p_root_hash, v_count, p_signature, NOW());
    SET v_checkpoint = LAST_INSERT_ID();

    seal_loop: LOOP
        SET v_grade = NULL;
        SELECT MIN(g.grade_id) INTO v_grade
        FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id = g.course_id
        WHERE g.checkpoint_id IS NULL
          AND c.university_id = p_university_id
          AND c.term = p_term;

        IF v_grade IS NULL THEN
            LEAVE seal_loop;
        END IF;

        UPDATE GRADE
        SET checkpoint_id = v_checkpoint, leaf_index = v_leaf
        WHERE grade_id = v_grade;

        SET v_leaf = v_leaf + 1;
    END LOOP;

    COMMIT;

    SELECT v_checkpoint AS checkpoint_id, v_version AS version_no, v_count AS leaf_count;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `review_correction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `review_correction`(
    IN p_request INT, IN p_registrar_university INT, IN p_approve BOOLEAN,
    IN p_comment VARCHAR(500), IN p_new_grade_id INT
)
BEGIN
    DECLARE v_grade INT DEFAULT NULL;
    DECLARE v_student INT;
    DECLARE v_course INT;
    DECLARE v_letter VARCHAR(2);
    DECLARE v_reason VARCHAR(500);
    DECLARE v_salt CHAR(64);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    SELECT r.grade_id,g.student_id,g.course_id,r.proposed_letter_grade,r.change_reason
        INTO v_grade,v_student,v_course,v_letter,v_reason
    FROM CORRECTION_REQUEST r JOIN GRADE g ON g.grade_id=r.grade_id
    JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE r.request_id=p_request AND r.status='pending'
      AND c.university_id=p_registrar_university FOR UPDATE;
    IF v_grade IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='No pending request for this university';
    END IF;
    IF p_approve IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Approval decision is required';
    END IF;
    IF p_approve THEN
        SET v_salt=HEX(RANDOM_BYTES(32));
        INSERT INTO GRADE
            (grade_id,student_id,course_id,supersedes_grade_id,letter_grade,salt,leaf_hash,change_reason)
        VALUES (p_new_grade_id,v_student,v_course,v_grade,v_letter,v_salt,
            SHA2(CONCAT_WS('|',p_new_grade_id,v_student,v_course,v_letter,v_salt),256),v_reason);
        UPDATE CORRECTION_REQUEST SET status='approved', reviewed_at=NOW(),
            reviewer_comment=p_comment, approved_grade_id=p_new_grade_id WHERE request_id=p_request;
    ELSE
        IF p_comment IS NULL OR CHAR_LENGTH(TRIM(p_comment))=0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Rejecting a request requires a comment';
        END IF;
        UPDATE CORRECTION_REQUEST SET status='rejected', reviewed_at=NOW(),
            reviewer_comment=p_comment WHERE request_id=p_request;
    END IF;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `submit_course_grades` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `submit_course_grades`(IN p_instructor INT,IN p_course INT,IN p_batch JSON)
BEGIN
    DECLARE v_done BOOLEAN DEFAULT FALSE;
    DECLARE v_grade INT;
    DECLARE v_student INT;
    DECLARE v_letter VARCHAR(2);
    DECLARE v_salt CHAR(64);
    DECLARE v_expected INT;
    DECLARE v_seen INT;
    DECLARE v_distinct INT;
    DECLARE v_bad INT;
    DECLARE roster CURSOR FOR
        SELECT grade_id,student_id,letter_grade FROM JSON_TABLE(p_batch,'$[*]' COLUMNS(
            grade_id INT PATH '$.grade_id',student_id INT PATH '$.student_id',
            letter_grade VARCHAR(10) PATH '$.letter_grade')) batch_rows;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done=TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    IF p_batch IS NULL OR JSON_TYPE(p_batch)<>'ARRAY' OR NOT EXISTS (
        SELECT 1 FROM COURSE WHERE course_id=p_course AND instructor_id=p_instructor
        AND (submission_deadline IS NULL OR NOW()<=submission_deadline)
    ) THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid batch, instructor or submission deadline'; END IF;
    SELECT COUNT(*) INTO v_expected FROM ENROLLMENT WHERE course_id=p_course;
    SELECT COUNT(*),COUNT(DISTINCT student_id),
        COALESCE(SUM(grade_id IS NULL OR grade_id<=0 OR student_id IS NULL OR letter_grade IS NULL
            OR letter_grade NOT IN ('A','A-','B+','B','B-','C+','C','C-','D+','D','F')
            OR NOT EXISTS (SELECT 1 FROM ENROLLMENT e WHERE e.course_id=p_course AND e.student_id=b.student_id)),0)
        INTO v_seen,v_distinct,v_bad
    FROM JSON_TABLE(p_batch,'$[*]' COLUMNS(grade_id INT PATH '$.grade_id',student_id INT PATH '$.student_id',
        letter_grade VARCHAR(10) PATH '$.letter_grade')) b;
    IF v_expected=0 OR v_expected<>v_seen OR v_seen<>v_distinct OR v_bad<>0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Batch must contain one valid grade per enrolled student';
    END IF;
    OPEN roster;
    grade_loop: LOOP
        FETCH roster INTO v_grade,v_student,v_letter;
        IF v_done THEN LEAVE grade_loop; END IF;
        SET v_salt=HEX(RANDOM_BYTES(32));
        INSERT INTO GRADE (grade_id,student_id,course_id,letter_grade,salt,leaf_hash)
        VALUES (v_grade,v_student,p_course,v_letter,v_salt,
            SHA2(CONCAT_WS('|',v_grade,v_student,p_course,v_letter,v_salt),256));
    END LOOP;
    CLOSE roster;
    DELETE FROM GRADE_DRAFT WHERE course_id=p_course;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `submit_original_grade` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = cp850 */ ;
/*!50003 SET character_set_results = cp850 */ ;
/*!50003 SET collation_connection  = cp850_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE PROCEDURE `submit_original_grade`(
    IN p_instructor INT, IN p_grade_id INT, IN p_student INT,
    IN p_course INT, IN p_letter VARCHAR(2)
)
BEGIN
    DECLARE v_salt CHAR(64);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
    START TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM COURSE_CONTEXT c JOIN ENROLLMENT e ON e.course_id=c.course_id
        WHERE c.course_id=p_course AND c.instructor_id=p_instructor AND e.student_id=p_student
          AND (c.submission_deadline IS NULL OR NOW()<=c.submission_deadline)) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Unauthorized, unenrolled or past the grade deadline';
    END IF;
    SET v_salt=HEX(RANDOM_BYTES(32));
    INSERT INTO GRADE (grade_id,student_id,course_id,letter_grade,salt,leaf_hash)
    VALUES (p_grade_id,p_student,p_course,p_letter,v_salt,
            SHA2(CONCAT_WS('|',p_grade_id,p_student,p_course,p_letter,v_salt),256));
    DELETE FROM GRADE_DRAFT WHERE student_id=p_student AND course_id=p_course;
    COMMIT;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `sigil`
--

USE `sigil`;

--
-- Final view structure for view `COURSE_CONTEXT`
--

/*!50001 DROP VIEW IF EXISTS `COURSE_CONTEXT`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = cp850 */;
/*!50001 SET character_set_results     = cp850 */;
/*!50001 SET collation_connection      = cp850_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 SQL SECURITY DEFINER */
/*!50001 VIEW `COURSE_CONTEXT` AS select `c`.`course_id` AS `course_id`,`c`.`instructor_id` AS `instructor_id`,`c`.`course_code` AS `course_code`,`c`.`title` AS `title`,`c`.`credit_hours` AS `credit_hours`,`c`.`term` AS `term`,`c`.`section` AS `section`,`c`.`submission_deadline` AS `submission_deadline`,`i`.`university_id` AS `university_id` from (`COURSE` `c` join `INSTRUCTOR` `i` on((`i`.`instructor_id` = `c`.`instructor_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-09 20:45:12


-- Application queries: harsh.sql

-- Harsh Agarwal: verifier screens 13-15 and mobile sharing screen 16.
-- Run AFTER build.sql: mysql -u <user> -p sigil < sql/04_queries/harsh.sql
-- The reads do not modify data. The sharing example ends with ROLLBACK.
-- Applications must bind parameters and authorize student writes server-side.
USE sigil;
SET @proof_token = SHA2('demo-token-1',256);
SET @proof_id = (SELECT proof_id FROM DISCLOSURE_PROOF WHERE share_token=@proof_token);
SET @selected_grade_id = 11;
SET @university_id = 1;
SET @term = 'Fall 2025';
SET @root_prefix = '';

-- Q1. Screen 13: look up a proof and explain its database status.
-- A missing proof returns no rows. No grades are exposed for invalid proofs.
-- This is a status check; the browser must ALSO verify hashes and signatures.
SELECT dp.proof_id, v.organization_name, dp.created_at, dp.expires_at,
       CASE
           WHEN dp.status = 'revoked' THEN 'Revoked'
           WHEN dp.expires_at <= NOW() THEN 'Expired'
           WHEN is_proof_valid(dp.proof_id) = 0 THEN 'Invalid or outdated grades'
           ELSE 'Ready for cryptographic verification'
       END AS verification_status
FROM DISCLOSURE_PROOF dp
JOIN VERIFIER v ON v.verifier_id = dp.verifier_id
WHERE dp.proof_id = @proof_id;

-- Q2. Screens 14/16: the disclosed grades and evidence for a valid proof only.
-- Rebuild each checkpoint tree in leaf_index order using Q4, then return ONLY
-- the selected leaves and sibling paths to the browser. Do not expose Q4 publicly.
SELECT dp.proof_id, s.first_name, s.last_name,
       g.grade_id, g.student_id, g.course_id, c.course_code, c.title,
       c.credit_hours, c.term, g.letter_grade, g.salt, g.leaf_hash, g.leaf_index,
       mc.checkpoint_id, mc.version_no, mc.root_hash, mc.signature,
       mc.published_at, u.name AS university_name, u.public_key
FROM DISCLOSURE_PROOF dp
JOIN STUDENT s ON s.student_id = dp.student_id
JOIN DISCLOSED_GRADE dg ON dg.proof_id = dp.proof_id
JOIN GRADE g ON g.grade_id = dg.grade_id
JOIN COURSE_CONTEXT c ON c.course_id = g.course_id
JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id = g.checkpoint_id
JOIN UNIVERSITY u ON u.university_id = mc.university_id
WHERE dp.proof_id = @proof_id AND is_proof_valid(dp.proof_id) = 1
ORDER BY c.term, c.course_code, g.grade_id;

-- Q3. Screen 15: public checkpoint registry; excludes all student/grade data.
SELECT u.name AS university_name, u.public_key,
       mc.checkpoint_id, mc.term, mc.version_no, mc.root_hash,
       mc.leaf_count, mc.signature, mc.published_at
FROM MERKLE_CHECKPOINT mc
JOIN UNIVERSITY u ON u.university_id = mc.university_id
WHERE mc.university_id = @university_id AND (@term IS NULL OR mc.term = @term)
  AND mc.root_hash LIKE CONCAT(@root_prefix,'%')
ORDER BY mc.version_no DESC;

-- Q4. Backend only: ordered leaf hashes to reconstruct the requested tree.
-- Include superseded leaves: removing one would change the published root.
SELECT g.leaf_index, g.leaf_hash
FROM GRADE g
WHERE g.checkpoint_id = (
    SELECT g.checkpoint_id FROM GRADE g JOIN DISCLOSED_GRADE dg ON dg.grade_id=g.grade_id
    WHERE g.grade_id=@selected_grade_id AND dg.proof_id=@proof_id AND is_proof_valid(@proof_id)=1
)
ORDER BY g.leaf_index;

-- Q5. Screen 16: student's shared proofs, with validity and grade counts.
SET @student_id = 1;
SELECT dp.proof_id, v.organization_name, dp.status, dp.created_at, dp.expires_at,
       COUNT(dg.grade_id) AS disclosed_grade_count,
       is_proof_valid(dp.proof_id) AS database_valid
FROM DISCLOSURE_PROOF dp
JOIN VERIFIER v ON v.verifier_id = dp.verifier_id
LEFT JOIN DISCLOSED_GRADE dg ON dg.proof_id = dp.proof_id
WHERE dp.student_id = @student_id
GROUP BY dp.proof_id, v.organization_name, dp.status, dp.created_at, dp.expires_at
ORDER BY dp.created_at DESC, dp.proof_id DESC;

-- Q6-Q9. Mobile sharing lifecycle (INSERT, DELETE, UPDATE).
-- Demo-only unused ID. Production allocates IDs without MAX(id)+1 races.
-- Keep creation and selection in one transaction; share only after COMMIT.
-- ROLLBACK here makes the example repeatable and preserves the seed data.
SET @new_proof_id = 800001;
SET @selected_grade_id = 11;
START TRANSACTION;
INSERT INTO DISCLOSURE_PROOF
    (proof_id, student_id, verifier_id, status, created_at, expires_at,share_token)
VALUES (@new_proof_id, @student_id, 1, 'active', NOW(), NOW() + INTERVAL 30 DAY,HEX(RANDOM_BYTES(32)));

INSERT INTO DISCLOSED_GRADE (proof_id, grade_id)
SELECT @new_proof_id, g.grade_id
FROM GRADE g
WHERE g.grade_id = @selected_grade_id AND g.student_id = @student_id
  AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE newer WHERE newer.supersedes_grade_id = g.grade_id);
SELECT is_proof_valid(@new_proof_id) AS new_proof_valid;

-- Remove a selection before the newly created proof has been shared.
-- Never alter the disclosed set of an already shared proof; revoke it instead.
DELETE FROM DISCLOSED_GRADE
WHERE proof_id = @new_proof_id AND grade_id = @selected_grade_id;
SELECT is_proof_valid(@new_proof_id) AS empty_proof_invalid;

-- Re-select the grade, then demonstrate revocation with an ownership check.
INSERT INTO DISCLOSED_GRADE (proof_id, grade_id)
SELECT @new_proof_id, g.grade_id
FROM GRADE g
WHERE g.grade_id = @selected_grade_id AND g.student_id = @student_id
  AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE newer WHERE newer.supersedes_grade_id = g.grade_id);
UPDATE DISCLOSURE_PROOF SET status = 'revoked'
WHERE proof_id = @new_proof_id AND student_id = @student_id AND status = 'active';
SELECT is_proof_valid(@new_proof_id) AS revoked_proof_invalid;
ROLLBACK;


-- Application queries: khalid.sql

-- Student screens 2-5.
USE sigil;
SET @student_id=1;
SET @course_id=1;
SET @term=NULL; -- NULL means all terms.

-- S2a. Transcript including enrollment with no submitted grade.
SELECT c.course_id,c.course_code,c.title,c.credit_hours,c.term,
       g.grade_id,g.letter_grade,
       CASE WHEN g.grade_id IS NULL THEN 'In progress'
            WHEN g.checkpoint_id IS NULL THEN 'Awaiting publication' ELSE 'Sealed' END AS grade_status,
       g.supersedes_grade_id IS NOT NULL AS corrected, mc.version_no
FROM ENROLLMENT e JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
LEFT JOIN GRADE g ON g.student_id=e.student_id AND g.course_id=e.course_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
LEFT JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id=g.checkpoint_id
WHERE e.student_id=@student_id AND (@term IS NULL OR c.term=@term)
ORDER BY c.term,c.course_code;

-- S2b. Credit-weighted GPA: current versions only; no grade means no GPA credit.
WITH current_grades AS (
    SELECT g.*,c.credit_hours FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE g.student_id=@student_id
      AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
)
SELECT ROUND(SUM(credit_hours * CASE letter_grade
    WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3 WHEN 'B' THEN 3.0
    WHEN 'B-' THEN 2.7 WHEN 'C+' THEN 2.3 WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7
    WHEN 'D+' THEN 1.3 WHEN 'D' THEN 1.0 ELSE 0.0 END)/NULLIF(SUM(credit_hours),0),2) AS gpa,
    COALESCE(SUM(CASE WHEN letter_grade<>'F' THEN credit_hours ELSE 0 END),0) AS earned_credits,
    COALESCE(SUM(checkpoint_id IS NOT NULL),0) AS sealed_grades,
    (SELECT COUNT(*) FROM DISCLOSURE_PROOF dp WHERE dp.student_id=@student_id
        AND dp.status='active' AND dp.expires_at>NOW()) AS active_links
FROM current_grades;

-- S2c. Credits in progress (enrolled but not yet submitted).
SELECT COALESCE(SUM(c.credit_hours),0) AS in_progress_credits
FROM ENROLLMENT e JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
WHERE e.student_id=@student_id AND NOT EXISTS
    (SELECT 1 FROM GRADE g WHERE g.student_id=e.student_id AND g.course_id=e.course_id);

-- S3. Complete history; never expose a salt in the history UI.
SELECT g.grade_id,g.letter_grade,g.recorded_at,g.supersedes_grade_id,
       g.change_reason,g.checkpoint_id,g.leaf_index,g.leaf_hash,mc.root_hash,mc.signature,
       i.first_name AS instructor_first_name,i.last_name AS instructor_last_name,
       NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id) AS is_current
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
JOIN INSTRUCTOR i ON i.instructor_id=c.instructor_id
LEFT JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id=g.checkpoint_id
WHERE g.student_id=@student_id AND g.course_id=@course_id
ORDER BY g.recorded_at DESC,g.grade_id DESC;

-- S4. Picker/search, organization dropdown and profile contact details.
SET @search='';
SELECT g.grade_id,c.course_code,c.title,c.term,g.letter_grade,
       g.checkpoint_id IS NOT NULL AS selectable
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE g.student_id=@student_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
  AND (c.course_code LIKE CONCAT('%',@search,'%') OR c.title LIKE CONCAT('%',@search,'%'))
ORDER BY c.term,c.course_code;
SELECT verifier_id,organization_name,contact_email FROM VERIFIER ORDER BY organization_name;
SELECT phone_number FROM STUDENT_PHONE WHERE student_id=@student_id ORDER BY phone_number;

-- S4 creation: all selected grades must be owned/current/sealed. Validate the
-- affected row count against the selection count before COMMIT in the app.
-- Demonstration uses an unused proof/verifier ID and rolls back.
START TRANSACTION;
INSERT INTO VERIFIER VALUES (800101,'Example Employer','verify@example.org');
INSERT INTO DISCLOSURE_PROOF
    (proof_id,student_id,verifier_id,status,created_at,expires_at,share_token)
VALUES (800101,@student_id,800101,'active',NOW(),NOW()+INTERVAL 30 DAY,HEX(RANDOM_BYTES(32)));
INSERT INTO DISCLOSED_GRADE (proof_id,grade_id)
SELECT 800101,g.grade_id FROM GRADE g WHERE g.grade_id=11 AND g.student_id=@student_id
    AND g.checkpoint_id IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id);
SELECT is_proof_valid(800101) AS ready_to_share;
ROLLBACK;

-- S5: status tabs, counts, selected proof content, and irreversible revocation.
SELECT dp.proof_id,v.organization_name,dp.created_at,dp.expires_at,
       CASE WHEN dp.status='revoked' THEN 'Revoked' WHEN dp.expires_at<=NOW() THEN 'Expired'
            ELSE 'Active' END AS link_status,
       COUNT(dg.grade_id) AS selected_grades,dp.share_token
FROM DISCLOSURE_PROOF dp JOIN VERIFIER v ON v.verifier_id=dp.verifier_id
LEFT JOIN DISCLOSED_GRADE dg ON dg.proof_id=dp.proof_id
WHERE dp.student_id=@student_id
GROUP BY dp.proof_id,v.organization_name,dp.created_at,dp.expires_at,dp.status,dp.share_token
ORDER BY dp.created_at DESC;
START TRANSACTION;
UPDATE DISCLOSURE_PROOF SET status='revoked'
WHERE proof_id=1 AND student_id=@student_id AND status='active';
SELECT status,revoked_at FROM DISCLOSURE_PROOF WHERE proof_id=1;
ROLLBACK;


-- Application queries: mohammad.sql

-- Registrar screens 9-12.
USE sigil;
SET @university_id=2;
SET @term='Fall 2025';
SET @search='';

-- R9: KPIs and grade submission progress.
SELECT (SELECT COUNT(*) FROM CORRECTION_REQUEST r JOIN GRADE g ON g.grade_id=r.grade_id
        JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
        WHERE c.university_id=@university_id AND r.status='pending') AS pending_requests,
       (SELECT COUNT(*) FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
        WHERE c.university_id=@university_id AND c.term=@term AND g.checkpoint_id IS NULL) AS unpublished_grades,
       (SELECT MAX(published_at) FROM MERKLE_CHECKPOINT WHERE university_id=@university_id) AS last_publication,
       (SELECT COUNT(*) FROM DISCLOSURE_PROOF dp JOIN STUDENT s ON s.student_id=dp.student_id
        WHERE s.university_id=@university_id AND dp.status='active' AND dp.expires_at>NOW()) AS active_links;
SELECT c.course_id,c.course_code,c.title,c.term,c.submission_deadline,i.email,
       COUNT(e.student_id) AS enrolled,COUNT(g.grade_id) AS submitted
FROM COURSE_CONTEXT c JOIN INSTRUCTOR i ON i.instructor_id=c.instructor_id
LEFT JOIN ENROLLMENT e ON e.course_id=c.course_id
LEFT JOIN GRADE g ON g.student_id=e.student_id AND g.course_id=c.course_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
WHERE c.university_id=@university_id AND c.term=@term
GROUP BY c.course_id,c.course_code,c.title,c.term,c.submission_deadline,i.email;

-- R10. Pending approvals with the original value and proposed replacement.
SELECT r.request_id,r.requested_at,r.proposed_letter_grade,r.change_reason,r.evidence_uri,
       g.grade_id,g.letter_grade,s.first_name,s.last_name,c.course_code,
       i.first_name AS instructor_first_name,i.last_name AS instructor_last_name,
       NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id) AS still_current
FROM CORRECTION_REQUEST r JOIN GRADE g ON g.grade_id=r.grade_id
JOIN COURSE_CONTEXT c ON c.course_id=g.course_id JOIN STUDENT s ON s.student_id=g.student_id
JOIN INSTRUCTOR i ON i.instructor_id=r.instructor_id
WHERE c.university_id=@university_id AND r.status='pending'
ORDER BY r.requested_at,r.request_id;
-- Approval/rejection are transactional and exercised in workflow_tests.sql:
-- CALL review_correction(3,2,TRUE,'Exam reviewed and approved',700002);
-- CALL review_correction(4,4,FALSE,'No supporting evidence',NULL);

-- R11. Next version and exact ordered batch to hash and sign outside SQL.
SELECT COALESCE(MAX(version_no),0)+1 AS next_version FROM MERKLE_CHECKPOINT
WHERE university_id=@university_id AND term=@term;
SELECT ROW_NUMBER() OVER (ORDER BY g.grade_id)-1 AS next_leaf_index,
       g.grade_id,g.student_id,c.course_code,g.letter_grade,g.leaf_hash
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE c.university_id=@university_id AND c.term=@term AND g.checkpoint_id IS NULL
ORDER BY g.grade_id;
-- Application supplies a computed root and signature, then calls:
-- CALL publish_checkpoint(@university_id,@term,@computed_root,@signature);

-- R12. Searchable complete ledger, including old versions. CSV export uses
-- these returned rows; roots/signatures are verified by the application.
SELECT g.grade_id,g.recorded_at,s.netid,s.first_name,s.last_name,c.course_code,c.term,
       g.letter_grade,g.supersedes_grade_id,g.change_reason,g.checkpoint_id,g.leaf_hash,
       CASE WHEN EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id) THEN 'Superseded'
            WHEN g.supersedes_grade_id IS NOT NULL THEN 'Correction' ELSE 'Original' END AS entry_type,
       mc.root_hash,mc.signature
FROM GRADE g JOIN STUDENT s ON s.student_id=g.student_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
LEFT JOIN MERKLE_CHECKPOINT mc ON mc.checkpoint_id=g.checkpoint_id
WHERE c.university_id=@university_id AND (@term IS NULL OR c.term=@term)
  AND (s.netid LIKE CONCAT('%',@search,'%') OR s.last_name LIKE CONCAT('%',@search,'%')
       OR CAST(g.grade_id AS CHAR)=@search)
ORDER BY g.recorded_at DESC,g.grade_id DESC;

-- R9 activity feed; the database supplies events, the API sends email reminders.
SELECT * FROM (
    SELECT 'Grade submitted' AS event_type,g.recorded_at AS event_at,g.grade_id AS reference_id
    FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id WHERE c.university_id=@university_id
    UNION ALL
    SELECT 'Correction requested',r.requested_at,r.request_id FROM CORRECTION_REQUEST r
    JOIN GRADE g ON g.grade_id=r.grade_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE c.university_id=@university_id
    UNION ALL
    SELECT CONCAT('Correction ',r.status),r.reviewed_at,r.request_id FROM CORRECTION_REQUEST r
    JOIN GRADE g ON g.grade_id=r.grade_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
    WHERE c.university_id=@university_id AND r.reviewed_at IS NOT NULL
    UNION ALL
    SELECT 'Checkpoint published',published_at,checkpoint_id FROM MERKLE_CHECKPOINT WHERE university_id=@university_id
    UNION ALL
    SELECT 'Proof created',dp.created_at,dp.proof_id FROM DISCLOSURE_PROOF dp
    JOIN STUDENT s ON s.student_id=dp.student_id WHERE s.university_id=@university_id
    UNION ALL
    SELECT 'Proof revoked',dp.revoked_at,dp.proof_id FROM DISCLOSURE_PROOF dp
    JOIN STUDENT s ON s.student_id=dp.student_id WHERE s.university_id=@university_id AND dp.revoked_at IS NOT NULL
) events ORDER BY event_at DESC,reference_id DESC LIMIT 50;


-- Application queries: pratyush.sql

-- Instructor screens 6-8.
USE sigil;
SET @instructor_id=1;
SET @term='Fall 2026';
SET @course_id=11;

-- I6. Course cards, enrollment/grade progress, deadlines and request counts.
SELECT c.course_id,c.course_code,c.title,c.section,c.credit_hours,c.term,c.submission_deadline,
       COUNT(e.student_id) AS enrollment,
       COUNT(g.grade_id) AS submitted,
       COUNT(d.student_id) AS saved_drafts,
       (SELECT COUNT(*) FROM CORRECTION_REQUEST r JOIN GRADE old ON old.grade_id=r.grade_id
        WHERE old.course_id=c.course_id AND r.status='pending') AS pending_corrections
FROM COURSE_CONTEXT c LEFT JOIN ENROLLMENT e ON e.course_id=c.course_id
LEFT JOIN GRADE g ON g.course_id=c.course_id AND g.student_id=e.student_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
LEFT JOIN GRADE_DRAFT d ON d.course_id=c.course_id AND d.student_id=e.student_id
WHERE c.instructor_id=@instructor_id AND (@term IS NULL OR c.term=@term)
GROUP BY c.course_id,c.course_code,c.title,c.section,c.credit_hours,c.term,c.submission_deadline
ORDER BY c.term,c.course_code;

-- I7. Roster exists independently of final grades. Invalid CSV cells are
-- rejected by UI validation; valid cells may be saved to GRADE_DRAFT.
SELECT s.student_id,s.netid,s.student_number,s.first_name,s.last_name,
       d.letter_grade AS draft_grade,g.letter_grade AS submitted_grade,
       CASE WHEN g.grade_id IS NOT NULL THEN 'Submitted'
            WHEN d.student_id IS NOT NULL THEN 'Entered' ELSE 'Missing' END AS entry_state
FROM ENROLLMENT e JOIN STUDENT s ON s.student_id=e.student_id
JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
LEFT JOIN GRADE_DRAFT d ON d.student_id=e.student_id AND d.course_id=e.course_id
LEFT JOIN GRADE g ON g.student_id=e.student_id AND g.course_id=e.course_id
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
WHERE c.instructor_id=@instructor_id AND c.course_id=@course_id
ORDER BY s.last_name,s.first_name,s.student_id;

-- Autosave, edit, and remove an unsubmitted draft; never modify a final Grade.
START TRANSACTION;
INSERT INTO GRADE_DRAFT (student_id,course_id,letter_grade,saved_at)
SELECT e.student_id,e.course_id,'A-',NOW() FROM ENROLLMENT e
JOIN COURSE_CONTEXT c ON c.course_id=e.course_id
WHERE e.student_id=1 AND e.course_id=@course_id AND c.instructor_id=@instructor_id
  AND NOT EXISTS (SELECT 1 FROM GRADE g WHERE g.student_id=e.student_id AND g.course_id=e.course_id)
ON DUPLICATE KEY UPDATE letter_grade='A-',saved_at=NOW();
UPDATE GRADE_DRAFT d JOIN COURSE_CONTEXT c ON c.course_id=d.course_id
SET d.letter_grade='A',d.saved_at=NOW()
WHERE d.student_id=1 AND d.course_id=@course_id AND c.instructor_id=@instructor_id;
DELETE d FROM GRADE_DRAFT d JOIN COURSE_CONTEXT c ON c.course_id=d.course_id
WHERE d.student_id=1 AND d.course_id=@course_id AND c.instructor_id=@instructor_id;
ROLLBACK;
-- Original-grade submission is tested in workflow_tests.sql:
-- CALL submit_original_grade(1,700001,1,11,'A');
-- Whole-roster submission (including imported CSV after application parsing):
-- CALL submit_course_grades(1,11,JSON_ARRAY(JSON_OBJECT('grade_id',700001,'student_id',1,'letter_grade','A')));
-- The batch routine validates every enrolled row and commits all or nothing.

-- I8: current sealed grade selector and the instructor's request history.
SELECT g.grade_id,s.student_id,s.first_name,s.last_name,c.course_code,c.term,
       g.letter_grade,g.checkpoint_id,g.leaf_index
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id JOIN STUDENT s ON s.student_id=g.student_id
WHERE c.instructor_id=@instructor_id AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id)
ORDER BY c.term,s.last_name;
SELECT r.*,g.letter_grade AS original_letter,c.course_code FROM CORRECTION_REQUEST r
JOIN GRADE g ON g.grade_id=r.grade_id JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE r.instructor_id=@instructor_id ORDER BY r.requested_at DESC,r.request_id DESC;
START TRANSACTION;
INSERT INTO CORRECTION_REQUEST
    (grade_id,instructor_id,proposed_letter_grade,change_reason,status,requested_at)
SELECT g.grade_id,@instructor_id,'A-','Exam rubric review','pending',NOW()
FROM GRADE g JOIN COURSE_CONTEXT c ON c.course_id=g.course_id
WHERE g.grade_id=11 AND c.instructor_id=@instructor_id AND g.checkpoint_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM GRADE n WHERE n.supersedes_grade_id=g.grade_id);
ROLLBACK;
