-- MySQL dump 10.13  Distrib 5.5.37, for Win32 (x86)
--
-- Host: localhost    Database: realmd
-- ------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@SESSION.TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `db_version`
--

DROP TABLE IF EXISTS `db_version`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `db_version` (
  `version` INT(3) NOT NULL COMMENT 'The Version of the Release',
  `structure` INT(3) NOT NULL COMMENT 'The current core structure level.',
  `content` INT(3) NOT NULL COMMENT 'The current core content level.',
  `description` VARCHAR(30) NOT NULL DEFAULT '' COMMENT 'A short description of the latest database revision.',
  `comment` VARCHAR(150) DEFAULT '' COMMENT 'A comment about the latest database revision.',
  PRIMARY KEY (`version`,`structure`,`content`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='Used DB version notes';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `db_version`
--

LOCK TABLES `db_version` WRITE;
/*!40000 ALTER TABLE `db_version` DISABLE KEYS */;
INSERT  INTO `db_version`(`version`,`structure`,`content`,`description`,`comment`) VALUES 
(21,2,1,'Add_field_comments','Base Database from 20150409 to Rel21_2_1');
/*!40000 ALTER TABLE `db_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'The unique account ID.',
  `username` VARCHAR(32) NOT NULL DEFAULT '' COMMENT 'The account user name.',
  `sha_pass_hash` VARCHAR(40) NOT NULL DEFAULT '' COMMENT 'This field contains the encrypted SHA1 password.',
  `gmlevel` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The account security level.',
  `sessionkey` LONGTEXT DEFAULT NULL COMMENT 'The Session Key.',
  `v` LONGTEXT DEFAULT NULL COMMENT 'The validated Hash Value.',
  `s` LONGTEXT DEFAULT NULL COMMENT 'Password ''Salt'' Value.',
  `email` TEXT DEFAULT NULL COMMENT 'The e-mail address associated with this account.',
  `joindate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'The date when the account was created.',
  `last_ip` VARCHAR(30) NOT NULL DEFAULT '0.0.0.0' COMMENT 'The last IP used by the person who last logged into the account.',
  `failed_logins` INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The number of failed logins attempted on the account.',
  `locked` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Indicates whether the account has been locked or not.',
  `last_login` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'The date when the account was last logged into.',
  `active_realm_id` INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Which maximum expansion content a user has access to.',
  `expansion` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Which maximum expansion content a user has access to.',
  `mutetime` BIGINT(40) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The time, in Unix time, when the account will be unmuted.',
  `locale` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The locale used by the client logged into this account.',
  `os` VARCHAR(3) DEFAULT '' COMMENT 'The Operating System of the connected client',
  `playerBot` BIT(1) NOT NULL DEFAULT b'0' COMMENT 'Determines whether the account is a User or a PlayerBot',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  KEY `idx_gmlevel` (`gmlevel`)
) ENGINE=INNODB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Account System';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
INSERT INTO `account` (`id`, `username`, `sha_pass_hash`, `gmlevel`, `sessionkey`, `v`, `s`, `email`, `joindate`, `last_ip`, `failed_logins`, `locked`, `last_login`, `active_realm_id`, `expansion`, `mutetime`, `locale`, `os`, `playerBot`) VALUES 
(1,'ADMINISTRATOR','a34b29541b87b7e4823683ce6c7bf6ae68beaaac',3,'','0','0','','2021-01-01 13:18:56','127.0.0.1',0,0,'2021-01-01 13:18:56',0,0,0,0,'','\0'),
(2,'GAMEMASTER','7841e21831d7c6bc0b57fbe7151eb82bd65ea1f9',2,'','0','0','','2021-01-01 13:18:56','127.0.0.1',0,0,'2021-01-01 13:18:56',0,0,0,0,'','\0'),
(3,'MODERATOR','a7f5fbff0b4eec2d6b6e78e38e8312e64d700008',1,'','0','0','','2021-01-01 13:19:35','127.0.0.1',0,0,'2021-01-01 13:19:35',0,0,0,0,'','\0'),
(4,'PLAYER','3ce8a96d17c5ae88a30681024e86279f1a38c041',0,'','0','0','','2021-01-01 13:19:35','127.0.0.1',0,0,'2021-01-01 13:19:35',0,0,0,0,'','\0');
/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;
--
-- Table structure for table `account_banned`
--

DROP TABLE IF EXISTS `account_banned`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_banned` (
  `id` INT(11) UNSIGNED NOT NULL COMMENT 'The account ID (See account.id).',
  `bandate` BIGINT(40) NOT NULL DEFAULT 0 COMMENT 'The date when the account was banned, in Unix time.',
  `unbandate` BIGINT(40) NOT NULL DEFAULT 0 COMMENT 'The date when the account will be automatically unbanned.',
  `bannedby` VARCHAR(50) NOT NULL COMMENT 'The character that banned the account.',
  `banreason` VARCHAR(255) NOT NULL COMMENT 'The reason for the ban.',
  `active` TINYINT(4) NOT NULL DEFAULT 1 COMMENT 'Is the ban is currently active or not.',
  PRIMARY KEY (`id`,`bandate`),
  CONSTRAINT `account_banned_ibfk_1` FOREIGN KEY (`id`) REFERENCES `account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Ban List';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_banned`
--

LOCK TABLES `account_banned` WRITE;
/*!40000 ALTER TABLE `account_banned` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_banned` ENABLE KEYS */;
UNLOCK TABLES;


--
-- Table structure for table `ip_banned`
--

DROP TABLE IF EXISTS `ip_banned`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ip_banned` (
  `ip` VARCHAR(32) NOT NULL DEFAULT '0.0.0.0' COMMENT 'The IP address that is banned.',
  `bandate` BIGINT(40) NOT NULL COMMENT 'The date when the IP was first banned, in Unix time.',
  `unbandate` BIGINT(40) NOT NULL COMMENT 'The date when the IP will be unbanned in Unix time.',
  `bannedby` VARCHAR(50) NOT NULL DEFAULT '[Console]' COMMENT 'The name of the character that banned the IP.',
  `banreason` VARCHAR(255) NOT NULL DEFAULT 'no reason' COMMENT 'The reason given for the IP ban.',
  PRIMARY KEY (`ip`,`bandate`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Banned IPs';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ip_banned`
--

LOCK TABLES `ip_banned` WRITE;
/*!40000 ALTER TABLE `ip_banned` DISABLE KEYS */;
/*!40000 ALTER TABLE `ip_banned` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `realmcharacters`
--

DROP TABLE IF EXISTS `realmcharacters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `realmcharacters` (
  `realmid` INT(11) UNSIGNED NOT NULL COMMENT 'The ID of the realm (See realmlist.id).',
  `acctid` INT(11) UNSIGNED NOT NULL COMMENT 'The account ID (See account.id).',
  `numchars` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The number of characters the account has on the realm.',
  PRIMARY KEY (`realmid`,`acctid`),
  KEY `acctid` (`acctid`),
  CONSTRAINT `realmcharacters_ibfk_1` FOREIGN KEY (`realmid`) REFERENCES `realmlist` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Realm Character Tracker';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `realmcharacters`
--

LOCK TABLES `realmcharacters` WRITE;
/*!40000 ALTER TABLE `realmcharacters` DISABLE KEYS */;
/*!40000 ALTER TABLE `realmcharacters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `realmlist`
--

DROP TABLE IF EXISTS `realmlist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `realmlist` (
  `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'The realm ID.',
  `name` VARCHAR(32) NOT NULL DEFAULT '' COMMENT 'The name of the realm.',
  `address` VARCHAR(32) NOT NULL DEFAULT '127.0.0.1' COMMENT 'The public IP address of the world server.',
  `localAddress` VARCHAR(255) NOT NULL DEFAULT '127.0.0.1' COMMENT 'The local IP address of the world server.',
  `localSubnetMask` VARCHAR(255) NOT NULL DEFAULT '255.255.255.0' COMMENT 'The subnet mask used for the local network. ',
  `port` INT(11) NOT NULL DEFAULT 8085 COMMENT 'The port that the world server is running on.',
  `icon` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The icon of the realm.',
  `realmflags` TINYINT(3) UNSIGNED NOT NULL DEFAULT 2 COMMENT 'Supported masks for the realm.',
  `timezone` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The realm timezone.',
  `allowedSecurityLevel` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Minimum account (see account.gmlevel) required for accounts to log in.',
  `population` FLOAT UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Show the current population.',
  `realmbuilds` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'The accepted client builds that the realm will accept.',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Realm System';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `realmlist`
--

LOCK TABLES `realmlist` WRITE;
/*!40000 ALTER TABLE `realmlist` DISABLE KEYS */;
/*!40000 ALTER TABLE `realmlist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uptime`
--

DROP TABLE IF EXISTS `uptime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `uptime` (
  `realmid` INT(11) UNSIGNED NOT NULL COMMENT 'The realm id (See realmlist.id).',
  `starttime` BIGINT(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The time when the server was started, in Unix time.',
  `startstring` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'The time when the server started, formated as a readable string.',
  `uptime` BIGINT(20) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The uptime of the server, in seconds.',
  `maxplayers` SMALLINT(5) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'The maximum number of players connected',
  PRIMARY KEY (`realmid`,`starttime`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Uptime system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uptime`
--

LOCK TABLES `uptime` WRITE;
/*!40000 ALTER TABLE `uptime` DISABLE KEYS */;
/*!40000 ALTER TABLE `uptime` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `warden_log`
--

DROP TABLE IF EXISTS `warden_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `warden_log` (
  `entry` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Log entry ID',
  `check` SMALLINT(5) UNSIGNED NOT NULL COMMENT 'Failed Warden check ID',
  `action` TINYINT(3) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Action taken (enum WardenActions)',
  `account` INT(11) UNSIGNED NOT NULL COMMENT 'The account ID of the player.',
  `guid` INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Player GUID',
  `map` INT(11) UNSIGNED DEFAULT NULL COMMENT 'The map id. (See map.dbc)',
  `position_x` FLOAT DEFAULT NULL COMMENT 'The x location of the player.',
  `position_y` FLOAT DEFAULT NULL COMMENT 'The y location of the player.',
  `position_z` FLOAT DEFAULT NULL COMMENT 'The z location of the player.',
  `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP() COMMENT 'The date/time when the log entry was raised, in Unix time.',
  PRIMARY KEY (`entry`)
) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Warden log of failed checks';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Data for the table `warden_log`
--

LOCK TABLES `warden_log` WRITE;
/*!40000 ALTER TABLE `warden_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `warden_log` ENABLE KEYS */;
UNLOCK TABLES;

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
