-- --------------------------------------------------------------------------------
-- Persist confirmed Warden memory enforcement incidents for rolling-window
-- escalation. This is a structural Realm DB update from 22/02/001 to 22/03/001.
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `update_mangos`;

DELIMITER $$

CREATE PROCEDURE `update_mangos`()
BEGIN
    DECLARE bRollback BOOL DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `bRollback` = TRUE;

    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT `structure` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurContent := (SELECT `content` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);

    SET @cOldVersion = '22';
    SET @cOldStructure = '02';
    SET @cOldContent = '001';

    SET @cNewVersion = '22';
    SET @cNewStructure = '03';
    SET @cNewContent = '001';
    SET @cNewDescription = 'Warden incidents';
    SET @cNewComment = 'Persist confirmed Warden memory enforcement incidents';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        CREATE TABLE `warden_incident` (
          `incident_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
          `account_id` INT UNSIGNED NOT NULL,
          `occurred_at` BIGINT UNSIGNED NOT NULL,
          `realm_id` INT UNSIGNED NOT NULL,
          `client_build` SMALLINT UNSIGNED NOT NULL,
          `client_locale` CHAR(4) NOT NULL,
          `check_id` INT UNSIGNED NOT NULL,
          `outcome` TINYINT UNSIGNED NOT NULL,
          `ban_triggered` TINYINT UNSIGNED NOT NULL DEFAULT 0,
          PRIMARY KEY (`incident_id`),
          KEY `idx_warden_incident_account_time` (`account_id`, `occurred_at`),
          CONSTRAINT `warden_incident_account_fk`
            FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
            ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=INNODB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC
          COMMENT='Confirmed Warden memory enforcement incidents';

        IF bRollback = FALSE THEN
            INSERT INTO `db_version` VALUES (@cNewVersion, @cNewStructure, @cNewContent, @cNewDescription, @cNewComment);
            SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);
        END IF;

        IF bRollback = TRUE THEN
            ROLLBACK;
            SHOW ERRORS;
            SELECT '* UPDATE FAILED *' AS `===== Status =====`, @cCurResult AS `===== DB is on Version: =====`;
        ELSE
            COMMIT;
            SELECT '* UPDATE COMPLETE *' AS `===== Status =====`, @cNewResult AS `===== DB is now on Version =====`;
        END IF;
    ELSE
        IF (@cCurResult = @cNewResult) THEN
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`, @cCurResult AS `===== DB is already on Version =====`;
        ELSE
            IF (@cCurResult IS NULL) THEN
                SELECT '* UPDATE FAILED *' AS `===== Status =====`, 'Unable to locate DB Version Information' AS `============= Error Message =============`;
            ELSE
                SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure, '_', @cCurContent, ' - ', @cCurResult);
                SET @cOldOutput = CONCAT(@cOldVersion, '_', @cOldStructure, '_', @cOldContent, ' - ', COALESCE(@cOldResult, 'IS NOT APPLIED'));
                SELECT '* UPDATE SKIPPED *' AS `===== Status =====`, @cOldOutput AS `=== Expected ===`, @cCurOutput AS `===== Found Version =====`;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;

CALL update_mangos();

DROP PROCEDURE IF EXISTS `update_mangos`;
