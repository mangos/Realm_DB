-- -------------------------------------------------------------------------
-- Separate confirmed Warden audit findings from actionable incidents.
-- IMPORTANT: export any custom `warden_log` rows before applying this
-- intentionally destructive update. No automatic conversion is safe.
-- -------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `update_mangos`;

DELIMITER $$

CREATE PROCEDURE `update_mangos`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SHOW ERRORS;
        SELECT '* UPDATE FAILED *' AS `===== Status =====`,
               @cCurResult AS `===== DB is on Version: =====`;
        RESIGNAL;
    END;

    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT `structure` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurContent := (SELECT `content` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);

    SET @cOldVersion = '22';
    SET @cOldStructure = '03';
    SET @cOldContent = '001';

    SET @cNewVersion = '22';
    SET @cNewStructure = '04';
    SET @cNewContent = '001';
    SET @cNewDescription = 'Warden audit';
    SET @cNewComment = 'Separate Warden audit from actionable incidents';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        CREATE TABLE `warden_audit` (
          `audit_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
          `account_id` INT UNSIGNED NOT NULL,
          `occurred_at` BIGINT UNSIGNED NOT NULL,
          `realm_id` INT UNSIGNED NOT NULL,
          `client_build` SMALLINT UNSIGNED NOT NULL,
          `client_platform` VARBINARY(4) NOT NULL,
          `client_locale` BINARY(4) NOT NULL,
          `check_id` INT UNSIGNED NOT NULL,
          `check_type` TINYINT UNSIGNED NOT NULL,
          `evidence_class` TINYINT UNSIGNED NOT NULL,
          `outcome` TINYINT UNSIGNED NOT NULL
            COMMENT '1=Mismatch, 2=Unavailable',
          PRIMARY KEY (`audit_id`),
          KEY `idx_warden_audit_account_time` (`account_id`,`occurred_at`),
          KEY `idx_warden_audit_check_time` (`check_id`,`occurred_at`),
          CONSTRAINT `warden_audit_account_fk`
            FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
            ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC
          COMMENT='Confirmed non-actionable Warden findings';

        ALTER TABLE `warden_incident`
          ADD COLUMN `client_platform` VARBINARY(4) NOT NULL DEFAULT 0x57696E
            AFTER `client_build`,
          MODIFY COLUMN `client_locale` BINARY(4) NOT NULL,
          ADD COLUMN `check_type` TINYINT UNSIGNED NOT NULL DEFAULT 243
            AFTER `check_id`,
          ADD COLUMN `evidence_class` TINYINT UNSIGNED NOT NULL DEFAULT 1
            AFTER `check_type`,
          MODIFY COLUMN `outcome` TINYINT UNSIGNED NOT NULL
            COMMENT '1=Mismatch, 2=Historical Unavailable',
          COMMENT='Confirmed actionable Warden enforcement incidents';

        UPDATE `warden_incident`
        SET `client_platform` = 0x57696E,
            `check_type` = 243,
            `evidence_class` = CASE WHEN `check_id` = 1566 THEN 2 ELSE 1 END;

        ALTER TABLE `warden_incident`
          ALTER COLUMN `client_platform` DROP DEFAULT,
          ALTER COLUMN `check_type` DROP DEFAULT,
          ALTER COLUMN `evidence_class` DROP DEFAULT;

        DROP TABLE IF EXISTS `warden_log`;

        INSERT INTO `db_version` VALUES (@cNewVersion, @cNewStructure,
            @cNewContent, @cNewDescription, @cNewComment);
        SET @cNewResult := (SELECT `description` FROM `db_version`
            WHERE `version` = @cNewVersion AND `structure` = @cNewStructure
              AND `content` = @cNewContent);
        COMMIT;
        SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,
               @cNewResult AS `===== DB is now on Version =====`;
    ELSE
        IF (@cCurResult = @cNewResult) THEN
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
                   @cCurResult AS `===== DB is already on Version =====`;
        ELSE
            IF (@cCurResult IS NULL) THEN
                SELECT '* UPDATE FAILED *' AS `===== Status =====`,
                       'Unable to locate DB Version Information' AS `============= Error Message =============`;
            ELSE
                SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure,
                    '_', @cCurContent, ' - ', @cCurResult);
                SET @cOldOutput = CONCAT(@cOldVersion, '_', @cOldStructure,
                    '_', @cOldContent, ' - ',
                    COALESCE(@cOldResult, 'IS NOT APPLIED'));
                SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
                       @cOldOutput AS `=== Expected ===`,
                       @cCurOutput AS `===== Found Version =====`;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;

CALL update_mangos();

DROP PROCEDURE IF EXISTS `update_mangos`;
