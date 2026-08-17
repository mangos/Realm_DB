-- --------------------------------------------------------------------------------
-- Preserve the exact authenticated client locale independently of the numeric
-- DBC locale. This is a structural Realm DB update from 22/01/001 to 22/02/001.
-- Apply it with realmd and mangosd stopped, then deploy the corresponding
-- realmd before restart. Accounts intentionally remain profileless until their
-- next successful full or reconnect proof publishes the exact locale claim.
-- --------------------------------------------------------------------------------
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
    SET @cOldStructure = '01';
    SET @cOldContent = '001';

    SET @cNewVersion = '22';
    SET @cNewStructure = '02';
    SET @cNewContent = '001';
    SET @cNewDescription = 'Exact client locale';
    SET @cNewComment = 'Preserve the exact authenticated client locale';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        START TRANSACTION;

        -- DDL commits immediately. A retry after an interrupted ADD must
        -- recognize and canonicalize the already-created column before the
        -- database version advances.
        IF NOT EXISTS (
            SELECT 1 FROM `information_schema`.`columns`
            WHERE `table_schema` = DATABASE()
              AND `table_name` = 'account'
              AND `column_name` = 'client_locale'
        ) THEN
            ALTER TABLE `account`
            ADD COLUMN `client_locale` BINARY(4) NULL DEFAULT NULL
            COMMENT 'The exact locale reported by the authenticated client.'
            AFTER `locale`;
        ELSE
            ALTER TABLE `account`
            MODIFY COLUMN `client_locale` BINARY(4) NULL DEFAULT NULL
            COMMENT 'The exact locale reported by the authenticated client.'
            AFTER `locale`;
        END IF;

        -- An interrupted pre-release migration may have populated a live
        -- profile default. Clear every row so only a later successful proof
        -- can assign an exact client claim.
        UPDATE `account` SET `client_locale` = NULL;

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
