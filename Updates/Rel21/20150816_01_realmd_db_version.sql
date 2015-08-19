/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 50624
Source Host           : localhost:3306
Source Database       : realmd

Target Server Type    : MYSQL
Target Server Version : 50624
File Encoding         : 65001

Date: 2015-05-31 00:09:12
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `realmd_db_version`
-- ----------------------------
DROP TABLE IF EXISTS `realmd_db_version`;
CREATE TABLE `realmd_db_version` (
  `version` int(3) NOT NULL,
  `structure` int(3) NOT NULL,
  `content` int(3) NOT NULL,
  `description` varchar(30) NOT NULL DEFAULT '',
  `comment` varchar(150) DEFAULT '',
  PRIMARY KEY (`version`,`structure`,`content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='Used DB version notes';

-- ----------------------------
-- Records of db_version
-- ----------------------------
INSERT INTO `realmd_db_version` VALUES ('21', '1', '0', 'revision_refactor', '');
