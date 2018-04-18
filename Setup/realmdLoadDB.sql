-- MySQL dump 10.13  Distrib 5.5.34, for debian-linux-gnu (x86_64)
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
  `version` int(3) NOT NULL,
  `structure` int(3) NOT NULL,
  `content` int(3) NOT NULL,
  `description` varchar(30) NOT NULL DEFAULT '',
  `comment` varchar(150) DEFAULT '',
  PRIMARY KEY (`version`,`structure`,`content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='Used DB version notes';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `db_version`
--

LOCK TABLES `db_version` WRITE;
/*!40000 ALTER TABLE `db_version` DISABLE KEYS */;
INSERT  INTO `db_version`(`version`,`structure`,`content`,`description`,`comment`) VALUES (21,1,4,'Remove dbDocs','Base Database from 20150409 to Rel21_1_4');
/*!40000 ALTER TABLE `db_version` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Account identifier',
  `username` varchar(32) NOT NULL DEFAULT '' COMMENT 'User name',
  `sha_pass_hash` varchar(40) NOT NULL DEFAULT '' COMMENT 'SHA1 password Hash',
  `gmlevel` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `sessionkey` longtext,
  `v` longtext,
  `s` longtext COMMENT 'password salt',
  `email` text COMMENT 'Email address',
  `joindate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Account Created Date',
  `last_ip` varchar(30) NOT NULL DEFAULT '0.0.0.0',
  `failed_logins` int(11) unsigned NOT NULL DEFAULT '0',
  `locked` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `last_login` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `active_realm_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'last realm id',
  `expansion` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'max game expansion',
  `mutetime` bigint(40) unsigned NOT NULL DEFAULT '0',
  `locale` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `os` varchar(3) DEFAULT '' COMMENT 'Client OS Version',
  `playerBot` bit(1) NOT NULL DEFAULT b'0' COMMENT 'Whether the account is a playerbot account',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  KEY `idx_gmlevel` (`gmlevel`)
) ENGINE=MyISAM AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Account System';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account`
--

LOCK TABLES `account` WRITE;
/*!40000 ALTER TABLE `account` DISABLE KEYS */;
insert  into `account`(`id`,`username`,`sha_pass_hash`,`gmlevel`,`sessionkey`,`v`,`s`,`email`,`joindate`,`last_ip`,`failed_logins`,`locked`,`last_login`,`active_realm_id`,`expansion`,`mutetime`,`locale`,`os`,`playerBot`) values (1,'ADMINISTRATOR','a34b29541b87b7e4823683ce6c7bf6ae68beaaac',3,'','0','0','','2006-04-25 13:18:56','127.0.0.1',0,0,'0000-00-00 00:00:00',0,0,0,0,'','\0');
insert  into `account`(`id`,`username`,`sha_pass_hash`,`gmlevel`,`sessionkey`,`v`,`s`,`email`,`joindate`,`last_ip`,`failed_logins`,`locked`,`last_login`,`active_realm_id`,`expansion`,`mutetime`,`locale`,`os`,`playerBot`) values (2,'GAMEMASTER','7841e21831d7c6bc0b57fbe7151eb82bd65ea1f9',2,'','0','0','','2006-04-25 13:18:56','127.0.0.1',0,0,'0000-00-00 00:00:00',0,0,0,0,'','\0');
insert  into `account`(`id`,`username`,`sha_pass_hash`,`gmlevel`,`sessionkey`,`v`,`s`,`email`,`joindate`,`last_ip`,`failed_logins`,`locked`,`last_login`,`active_realm_id`,`expansion`,`mutetime`,`locale`,`os`,`playerBot`) values (3,'MODERATOR','a7f5fbff0b4eec2d6b6e78e38e8312e64d700008',1,'','0','0','','2006-04-25 13:19:35','127.0.0.1',0,0,'0000-00-00 00:00:00',0,0,0,0,'','\0');
insert  into `account`(`id`,`username`,`sha_pass_hash`,`gmlevel`,`sessionkey`,`v`,`s`,`email`,`joindate`,`last_ip`,`failed_logins`,`locked`,`last_login`,`active_realm_id`,`expansion`,`mutetime`,`locale`,`os`,`playerBot`) values (4,'PLAYER','3ce8a96d17c5ae88a30681024e86279f1a38c041',0,'','0','0','','2006-04-25 13:19:35','127.0.0.1',0,0,'0000-00-00 00:00:00',0,0,0,0,'','\0');

/*!40000 ALTER TABLE `account` ENABLE KEYS */;
UNLOCK TABLES;
--
-- Table structure for table `account_banned`
--

DROP TABLE IF EXISTS `account_banned`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_banned` (
  `id` int(11) unsigned NOT NULL COMMENT 'Account identifier',
  `bandate` bigint(40) NOT NULL DEFAULT '0',
  `unbandate` bigint(40) NOT NULL DEFAULT '0',
  `bannedby` varchar(50) NOT NULL,
  `banreason` varchar(255) NOT NULL,
  `active` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`,`bandate`),
  CONSTRAINT `account_banned_ibfk_1` FOREIGN KEY (`id`) REFERENCES `account` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Ban List';
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
  `ip` varchar(32) NOT NULL DEFAULT '0.0.0.0',
  `bandate` bigint(40) NOT NULL,
  `unbandate` bigint(40) NOT NULL,
  `bannedby` varchar(50) NOT NULL DEFAULT '[Console]',
  `banreason` varchar(255) NOT NULL DEFAULT 'no reason',
  PRIMARY KEY (`ip`,`bandate`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Banned IPs';
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
  `realmid` int(11) unsigned NOT NULL COMMENT 'Realm identifier',
  `acctid` int(11) unsigned NOT NULL COMMENT 'Account identifier',
  `numchars` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`realmid`,`acctid`),
  KEY `acctid` (`acctid`),
  CONSTRAINT `realmcharacters_ibfk_1` FOREIGN KEY (`realmid`) REFERENCES `realmlist` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Realm Character Tracker';
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
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Realm identifier',
  `name` varchar(32) NOT NULL DEFAULT '',
  `address` varchar(32) NOT NULL DEFAULT '127.0.0.1',
  `localAddress` varchar(255) NOT NULL DEFAULT '127.0.0.1',
  `localSubnetMask` varchar(255) NOT NULL DEFAULT '255.255.255.0',
  `port` int(11) NOT NULL DEFAULT '8085',
  `icon` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `realmflags` tinyint(3) unsigned NOT NULL DEFAULT '2' COMMENT 'Supported masks: 0x1 (invalid, not show in realm list), 0x2 (offline, set by mangosd), 0x4 (show version and build), 0x20 (new players), 0x40 (recommended)',
  `timezone` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `allowedSecurityLevel` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `population` float unsigned NOT NULL DEFAULT '0',
  `realmbuilds` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Realm System';
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
  `realmid` int(11) unsigned NOT NULL COMMENT 'Realm identifier',
  `starttime` bigint(20) unsigned NOT NULL DEFAULT '0',
  `startstring` varchar(64) NOT NULL DEFAULT '',
  `uptime` bigint(20) unsigned NOT NULL DEFAULT '0',
  `maxplayers` smallint(5) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`realmid`,`starttime`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Uptime system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uptime`
--

LOCK TABLES `uptime` WRITE;
/*!40000 ALTER TABLE `uptime` DISABLE KEYS */;
/*!40000 ALTER TABLE `uptime` ENABLE KEYS */;
UNLOCK TABLES;

--
-- table structure for warden_log
--

DROP TABLE IF EXISTS `warden_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `warden_log` (
  `entry` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log entry ID',
  `check` smallint(5) unsigned NOT NULL COMMENT 'Failed Warden check ID',
  `action` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT 'Action taken (enum WardenActions)',
  `account` int(11) unsigned NOT NULL COMMENT 'Account ID',
  `guid` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'Player GUID',
  `map` int(11) unsigned DEFAULT NULL COMMENT 'Map ID',
  `position_x` float DEFAULT NULL COMMENT 'Player position X',
  `position_y` float DEFAULT NULL COMMENT 'Player position Y',
  `position_z` float DEFAULT NULL COMMENT 'Player position Z',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date of the log entry',
  PRIMARY KEY (`entry`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='Warden log of failed checks';
/*!40101 SET character_set_client = @saved_cs_client */;


/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
