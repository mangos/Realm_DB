-- --------------------------------------------------------------------------------
-- This is an attempt to create a full transactional MaNGOS update (v1.4)
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `update_mangos`; 

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE bRollback BOOL  DEFAULT FALSE ;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `bRollback` = TRUE;

    -- Current Values (TODO - must be a better way to do this)
    SET @cCurVersion := (SELECT `version` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT structure FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
    SET @cCurContent := (SELECT content FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);

    -- Expected Values
    SET @cOldVersion = '21'; 
    SET @cOldStructure = '01'; 
    SET @cOldContent = '004';

    -- New Values
    SET @cNewVersion = '21';
    SET @cNewStructure = '02'; -- If The Update contains any 'ALTER DATABASE' statements, increment this and set cNewContent to 001
    SET @cNewContent = '001';
                            -- DESCRIPTION IS 30 Characters MAX    
    SET @cNewDescription = 'Add_field_comments';

                        -- COMMENT is 150 Characters MAX
    SET @cNewComment = 'Add_field_comments_from_Dbdocs';

    -- Evaluate all settings
    SET @cCurResult := (SELECT description FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
    SET @cOldResult := (SELECT description FROM db_version WHERE `version`=@cOldVersion AND `structure`=@cOldStructure AND `content`=@cOldContent);
    SET @cNewResult := (SELECT description FROM db_version WHERE `version`=@cNewVersion AND `structure`=@cNewStructure AND `content`=@cNewContent);

    IF (@cCurResult = @cOldResult) THEN    -- Does the current version match the expected version
        -- APPLY UPDATE
        START TRANSACTION;

        -- UPDATE THE DB VERSION
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
        INSERT INTO `db_version` VALUES (@cNewVersion, @cNewStructure, @cNewContent, @cNewDescription, @cNewComment);
        SET @cNewResult := (SELECT description FROM db_version WHERE `version`=@cNewVersion AND `structure`=@cNewStructure AND `content`=@cNewContent);

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
        -- -- PLACE UPDATE SQL BELOW -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

ALTER TABLE account MODIFY COLUMN `active_realm_id` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Which maximum expansion content a user has access to.';
ALTER TABLE account MODIFY COLUMN `email` TEXT COMMENT 'The e-mail address associated with this account.';
ALTER TABLE account MODIFY COLUMN `expansion` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Which maximum expansion content a user has access to.';
ALTER TABLE account MODIFY COLUMN `failed_logins` INT(11) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The number of failed logins attempted on the account.';
ALTER TABLE account MODIFY COLUMN `gmlevel` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The account security level.';
ALTER TABLE account MODIFY COLUMN `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'The unique account ID.';
ALTER TABLE account MODIFY COLUMN `joindate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The date when the account was created.';
ALTER TABLE account MODIFY COLUMN `last_ip` VARCHAR(30) NOT NULL DEFAULT '0.0.0.0' COMMENT 'The last IP used by the person who last logged into the account.';
ALTER TABLE account MODIFY COLUMN `last_login` TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'The date when the account was last logged into.';
ALTER TABLE account MODIFY COLUMN `locale` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The locale used by the client logged into this account.';
ALTER TABLE account MODIFY COLUMN `locked` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Indicates whether the account has been locked or not.';
ALTER TABLE account MODIFY COLUMN `mutetime` BIGINT(40) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The time, in Unix time, when the account will be unmuted.';
ALTER TABLE account MODIFY COLUMN `os` VARCHAR(3) DEFAULT '' COMMENT 'The Operating System of the connected client';
ALTER TABLE account MODIFY COLUMN `playerBot` BIT(1) NOT NULL DEFAULT b'0' COMMENT 'Determines whether the account is a User or a PlayerBot';
ALTER TABLE account MODIFY COLUMN `s` LONGTEXT COMMENT 'Password ''Salt'' Value.';
ALTER TABLE account MODIFY COLUMN `sessionkey` LONGTEXT COMMENT 'The Session Key.';
ALTER TABLE account MODIFY COLUMN `sha_pass_hash` VARCHAR(40) NOT NULL DEFAULT '' COMMENT 'This field contains the encrypted SHA1 password.';
ALTER TABLE account MODIFY COLUMN `username` VARCHAR(32) NOT NULL DEFAULT '' COMMENT 'The account user name.';
ALTER TABLE account MODIFY COLUMN `v` LONGTEXT COMMENT 'The validated Hash Value.';
ALTER TABLE account_banned MODIFY COLUMN `active` TINYINT(4) NOT NULL DEFAULT '1' COMMENT 'Is the ban is currently active or not.';
ALTER TABLE account_banned MODIFY COLUMN `bandate` BIGINT(40) NOT NULL DEFAULT '0' COMMENT 'The date when the account was banned, in Unix time.';
ALTER TABLE account_banned MODIFY COLUMN `bannedby` VARCHAR(50) NOT NULL COMMENT 'The character that banned the account.';
ALTER TABLE account_banned MODIFY COLUMN `banreason` VARCHAR(255) NOT NULL COMMENT 'The reason for the ban.';
ALTER TABLE account_banned MODIFY COLUMN `id` INT(11) UNSIGNED NOT NULL COMMENT 'The account ID (See account.id).';
ALTER TABLE account_banned MODIFY COLUMN `unbandate` BIGINT(40) NOT NULL DEFAULT '0' COMMENT 'The date when the account will be automatically unbanned.';
ALTER TABLE db_version MODIFY COLUMN `comment` VARCHAR(150) DEFAULT '' COMMENT 'A comment about the latest database revision.';
ALTER TABLE db_version MODIFY COLUMN `content` INT(3) NOT NULL COMMENT 'The current core content level.';
ALTER TABLE db_version MODIFY COLUMN `description` VARCHAR(30) NOT NULL DEFAULT '' COMMENT 'A short description of the latest database revision.';
ALTER TABLE db_version MODIFY COLUMN `structure` INT(3) NOT NULL COMMENT 'The current core structure level.';
ALTER TABLE db_version MODIFY COLUMN `version` INT(3) NOT NULL COMMENT 'The Version of the Release';
ALTER TABLE ip_banned MODIFY COLUMN `bandate` BIGINT(40) NOT NULL COMMENT 'The date when the IP was first banned, in Unix time.';
ALTER TABLE ip_banned MODIFY COLUMN `bannedby` VARCHAR(50) NOT NULL DEFAULT '[Console]' COMMENT 'The name of the character that banned the IP.';
ALTER TABLE ip_banned MODIFY COLUMN `banreason` VARCHAR(255) NOT NULL DEFAULT 'no reason' COMMENT 'The reason given for the IP ban.';
ALTER TABLE ip_banned MODIFY COLUMN `ip` VARCHAR(32) NOT NULL DEFAULT '0.0.0.0' COMMENT 'The IP address that is banned.';
ALTER TABLE ip_banned MODIFY COLUMN `unbandate` BIGINT(40) NOT NULL COMMENT 'The date when the IP will be unbanned in Unix time.';
ALTER TABLE realmcharacters MODIFY COLUMN `acctid` INT(11) UNSIGNED NOT NULL COMMENT 'The account ID (See account.id).';
ALTER TABLE realmcharacters MODIFY COLUMN `numchars` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The number of characters the account has on the realm.';
ALTER TABLE realmcharacters MODIFY COLUMN `realmid` INT(11) UNSIGNED NOT NULL COMMENT 'The ID of the realm (See realmlist.id).';
ALTER TABLE realmlist MODIFY COLUMN `address` VARCHAR(32) NOT NULL DEFAULT '127.0.0.1' COMMENT 'The public IP address of the world server.';
ALTER TABLE realmlist MODIFY COLUMN `allowedSecurityLevel` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Minimum account (see account.gmlevel) required for accounts to log in.';
ALTER TABLE realmlist MODIFY COLUMN `icon` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The icon of the realm.';
ALTER TABLE realmlist MODIFY COLUMN `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'The realm ID.';
ALTER TABLE realmlist MODIFY COLUMN `localAddress` VARCHAR(255) NOT NULL DEFAULT '127.0.0.1' COMMENT 'The local IP address of the world server.';
ALTER TABLE realmlist MODIFY COLUMN `localSubnetMask` VARCHAR(255) NOT NULL DEFAULT '255.255.255.0' COMMENT 'The subnet mask used for the local network. ';
ALTER TABLE realmlist MODIFY COLUMN `name` VARCHAR(32) NOT NULL DEFAULT '' COMMENT 'The name of the realm.';
ALTER TABLE realmlist MODIFY COLUMN `population` FLOAT UNSIGNED NOT NULL DEFAULT '0' COMMENT 'Show the current population.';
ALTER TABLE realmlist MODIFY COLUMN `port` INT(11) NOT NULL DEFAULT '8085' COMMENT 'The port that the world server is running on.';
ALTER TABLE realmlist MODIFY COLUMN `realmbuilds` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'The accepted client builds that the realm will accept.';
ALTER TABLE realmlist MODIFY COLUMN `realmflags` TINYINT(3) UNSIGNED NOT NULL DEFAULT '2' COMMENT 'Supported masks for the realm.';
ALTER TABLE realmlist MODIFY COLUMN `timezone` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The realm timezone.';
ALTER TABLE uptime MODIFY COLUMN `maxplayers` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The maximum number of players connected';
ALTER TABLE uptime MODIFY COLUMN `realmid` INT(11) UNSIGNED NOT NULL COMMENT 'The realm id (See realmlist.id).';
ALTER TABLE uptime MODIFY COLUMN `startstring` VARCHAR(64) NOT NULL DEFAULT '' COMMENT 'The time when the server started, formated as a readable string.';
ALTER TABLE uptime MODIFY COLUMN `starttime` BIGINT(20) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The time when the server was started, in Unix time.';
ALTER TABLE uptime MODIFY COLUMN `uptime` BIGINT(20) UNSIGNED NOT NULL DEFAULT '0' COMMENT 'The uptime of the server, in seconds.';
ALTER TABLE warden_log MODIFY COLUMN `account` INT(11) UNSIGNED NOT NULL COMMENT 'The account ID of the player.';
ALTER TABLE warden_log MODIFY COLUMN `date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'The date/time when the log entry was raised, in Unix time.';
ALTER TABLE warden_log MODIFY COLUMN `map` INT(11) UNSIGNED COMMENT 'The map id. [See Map.dbc]. ';
ALTER TABLE warden_log MODIFY COLUMN `map` INT(11) UNSIGNED COMMENT 'The map id. (See map.dbc)';
ALTER TABLE warden_log MODIFY COLUMN `position_x` FLOAT COMMENT 'The x location of the player.';
ALTER TABLE warden_log MODIFY COLUMN `position_y` FLOAT COMMENT 'The y location of the player.';
ALTER TABLE warden_log MODIFY COLUMN `position_z` FLOAT COMMENT 'The z location of the player.';

        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
        -- -- PLACE UPDATE SQL ABOVE -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

        -- If we get here ok, commit the changes
        IF bRollback = TRUE THEN
            ROLLBACK;
            SHOW ERRORS;
            SELECT '* UPDATE FAILED *' AS `===== Status =====`,@cCurResult AS `===== DB is on Version: =====`;



        ELSE
            COMMIT;
            SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,@cNewResult AS `===== DB is now on Version =====`;
        END IF;
    ELSE    -- Current version is not the expected version
        IF (@cCurResult = @cNewResult) THEN    -- Does the current version match the new version
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cCurResult AS `===== DB is already on Version =====`;
        ELSE    -- Current version is not one related to this update
            IF(@cCurResult IS NULL) THEN    -- Something has gone wrong
                SELECT '* UPDATE FAILED *' AS `===== Status =====`,'Unable to locate DB Version Information' AS `============= Error Message =============`;
            ELSE
		IF(@cOldResult IS NULL) THEN    -- Something has gone wrong
		    SET @cCurVersion := (SELECT `version` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
		    SET @cCurStructure := (SELECT `STRUCTURE` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
		    SET @cCurContent := (SELECT `Content` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
                    SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure, '_', @cCurContent, ' - ',@cCurResult);
                    SET @cOldResult = CONCAT('Rel',@cOldVersion, '_', @cOldStructure, '_', @cOldContent, ' - ','IS NOT APPLIED');
                    SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cOldResult AS `=== Expected ===`,@cCurOutput AS `===== Found Version =====`;
		ELSE
		    SET @cCurVersion := (SELECT `version` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
		    SET @cCurStructure := (SELECT `STRUCTURE` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
		    SET @cCurContent := (SELECT `Content` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
                    SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure, '_', @cCurContent, ' - ',@cCurResult);
                    SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cOldResult AS `=== Expected ===`,@cCurOutput AS `===== Found Version =====`;
                END IF;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;

-- Execute the procedure
CALL update_mangos();

-- Drop the procedure
DROP PROCEDURE IF EXISTS `update_mangos`;

