-- SPDX-License-Identifier: GPL-3.0-or-later
--
-- MaNGOS is a full featured server for World of Warcraft, supporting
-- the following clients: 1.12.x, 2.4.3, 3.3.5a, 4.3.4a and 5.4.8
--
-- Copyright (C) 2005-2026 MaNGOS <https://www.getmangos.eu>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.

-- ----------------------------------------------------------------
-- Extend Realm Warden evidence with the Cata client-variant identity.
-- The conditional ALTER statements make interrupted MariaDB DDL resumable.
-- ----------------------------------------------------------------
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
    SET @cOldStructure = '04';
    SET @cOldContent = '001';

    SET @cNewVersion = '22';
    SET @cNewStructure = '05';
    SET @cNewContent = '001';
    SET @cNewDescription = 'Cata Warden identity';
    SET @cNewComment = 'Record the exact Cata client variant on Warden evidence';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurResult = @cOldResult) THEN
        -- ALTER TABLE implicitly commits in MariaDB. Add each column only when
        -- absent and validate it immediately so a partial run is safely resumed.
        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_audit'
              AND `COLUMN_NAME` = 'client_variant') = 0 THEN
            ALTER TABLE `warden_audit`
                ADD COLUMN `client_variant` VARBINARY(16) NOT NULL
                    DEFAULT 'unclassified' AFTER `client_locale`;
        END IF;

        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_audit'
              AND `COLUMN_NAME` = 'client_variant'
              AND LOWER(`COLUMN_TYPE`) = 'varbinary(16)'
              AND `IS_NULLABLE` = 'NO'
              AND (BINARY `COLUMN_DEFAULT` = BINARY 'unclassified'
                   OR BINARY `COLUMN_DEFAULT` = BINARY '''unclassified''')) <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'warden_audit.client_variant has an unexpected schema';
        END IF;

        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_incident'
              AND `COLUMN_NAME` = 'client_variant') = 0 THEN
            ALTER TABLE `warden_incident`
                ADD COLUMN `client_variant` VARBINARY(16) NOT NULL
                    DEFAULT 'unclassified' AFTER `client_locale`;
        END IF;

        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_incident'
              AND `COLUMN_NAME` = 'client_variant'
              AND LOWER(`COLUMN_TYPE`) = 'varbinary(16)'
              AND `IS_NULLABLE` = 'NO'
              AND (BINARY `COLUMN_DEFAULT` = BINARY 'unclassified'
                   OR BINARY `COLUMN_DEFAULT` = BINARY '''unclassified''')) <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'warden_incident.client_variant has an unexpected schema';
        END IF;

        START TRANSACTION;
        UPDATE `warden_audit`
            SET `client_variant` = 'unclassified';
        UPDATE `warden_incident`
            SET `client_variant` = 'unclassified';

        IF (SELECT COUNT(*) FROM `warden_audit`
            WHERE BINARY `client_variant` <> BINARY 'unclassified'
               OR OCTET_LENGTH(`client_variant`) <> 12) <> 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'warden_audit.client_variant backfill failed';
        END IF;
        IF (SELECT COUNT(*) FROM `warden_incident`
            WHERE BINARY `client_variant` <> BINARY 'unclassified'
               OR OCTET_LENGTH(`client_variant`) <> 12) <> 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'warden_incident.client_variant backfill failed';
        END IF;

        INSERT INTO `db_version`
            (`version`,`structure`,`content`,`description`,`comment`)
        VALUES
            (@cNewVersion,@cNewStructure,@cNewContent,
             @cNewDescription,@cNewComment);
        COMMIT;

        SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);
        SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,
               @cNewResult AS `===== DB is now on Version =====`;
    ELSEIF (@cCurResult = @cNewResult) THEN
        SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
               @cCurResult AS `===== DB is already on Version =====`;
    ELSEIF (@cCurResult IS NULL) THEN
        SELECT '* UPDATE FAILED *' AS `===== Status =====`,
               'Unable to locate DB Version Information' AS `============= Error Message =============`;
    ELSE
        SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure, '_', @cCurContent, ' - ', @cCurResult);
        SET @cOldOutput = CONCAT('Rel', @cOldVersion, '_', @cOldStructure, '_', @cOldContent, ' - IS NOT CURRENT');
        SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,
               @cOldOutput AS `=== Expected ===`,
               @cCurOutput AS `===== Found Version =====`;
    END IF;
END $$

DELIMITER ;

CALL update_mangos();
DROP PROCEDURE IF EXISTS `update_mangos`;
