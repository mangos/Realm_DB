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
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <https://www.gnu.org/licenses/>.
--
-- World of Warcraft, and all World of Warcraft or Warcraft art, images,
-- and lore are copyrighted by Blizzard Entertainment, Inc.

-- ----------------------------------------------------------------
-- Extend Realm Warden evidence with exact Cata client identity fields.
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
    SET @cNewComment = 'Separate authenticated platform, Warden architecture and client variant';

    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurVersion = @cOldVersion
        AND @cCurStructure = @cOldStructure
        AND @cCurContent = @cOldContent
        AND @cCurResult = 'Warden audit') THEN
        -- ALTER TABLE implicitly commits in MariaDB. Add each column only when
        -- absent and validate it immediately so a partial run is safely resumed.
        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_audit'
              AND `COLUMN_NAME` = 'client_architecture') = 0 THEN
            ALTER TABLE `warden_audit`
                ADD COLUMN `client_architecture` VARBINARY(4) NOT NULL
                    DEFAULT 'unk' COMMENT 'Warden architecture: unk, x86 or x64'
                    AFTER `client_platform`;
        END IF;

        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_audit'
              AND `COLUMN_NAME` = 'client_architecture'
              AND LOWER(`COLUMN_TYPE`) = 'varbinary(4)'
              AND `IS_NULLABLE` = 'NO'
              AND (BINARY `COLUMN_DEFAULT` = BINARY 'unk'
                   OR BINARY `COLUMN_DEFAULT` = BINARY '''unk''')) <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'warden_audit.client_architecture has an unexpected schema';
        END IF;

        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_audit'
              AND `COLUMN_NAME` = 'client_variant') = 0 THEN
            ALTER TABLE `warden_audit`
                ADD COLUMN `client_variant` VARBINARY(16) NOT NULL
                    DEFAULT 'unclassified'
                    COMMENT 'Warden variant: unclassified, stock, grunt or legacy-grunt'
                    AFTER `client_locale`;
        END IF;

        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_incident'
              AND `COLUMN_NAME` = 'client_architecture') = 0 THEN
            ALTER TABLE `warden_incident`
                ADD COLUMN `client_architecture` VARBINARY(4) NOT NULL
                    DEFAULT 'unk' COMMENT 'Warden architecture: unk, x86 or x64'
                    AFTER `client_platform`;
        END IF;

        IF (SELECT COUNT(*) FROM `INFORMATION_SCHEMA`.`COLUMNS`
            WHERE `TABLE_SCHEMA` = DATABASE()
              AND `TABLE_NAME` = 'warden_incident'
              AND `COLUMN_NAME` = 'client_architecture'
              AND LOWER(`COLUMN_TYPE`) = 'varbinary(4)'
              AND `IS_NULLABLE` = 'NO'
              AND (BINARY `COLUMN_DEFAULT` = BINARY 'unk'
                   OR BINARY `COLUMN_DEFAULT` = BINARY '''unk''')) <> 1 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'warden_incident.client_architecture has an unexpected schema';
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
                    DEFAULT 'unclassified'
                    COMMENT 'Warden variant: unclassified, stock, grunt or legacy-grunt'
                    AFTER `client_locale`;
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

        -- Before this migration client_platform held the Warden architecture.
        -- x86/x64 therefore prove a Windows client, but legacy unk discarded
        -- the authenticated operating system and must remain unknown. Convert
        -- only that vocabulary, including rows written by an old core between
        -- an interrupted ALTER and this resumable retry.
        UPDATE `warden_audit`
           SET `client_architecture` = CASE
                   WHEN BINARY `client_architecture` = BINARY 'unk'
                    AND (BINARY `client_platform` = BINARY 'x86'
                      OR BINARY `client_platform` = BINARY 'x64')
                       THEN `client_platform`
                   ELSE `client_architecture`
               END,
               `client_platform` = CASE
                   WHEN BINARY `client_platform` = BINARY 'x86'
                     OR BINARY `client_platform` = BINARY 'x64'
                       THEN 'Win'
                   ELSE 'unk'
               END
         WHERE BINARY `client_platform` = BINARY 'x86'
            OR BINARY `client_platform` = BINARY 'x64'
            OR BINARY `client_platform` = BINARY 'unk';
        UPDATE `warden_incident`
           SET `client_architecture` = CASE
                   WHEN BINARY `client_architecture` = BINARY 'unk'
                    AND (BINARY `client_platform` = BINARY 'x86'
                      OR BINARY `client_platform` = BINARY 'x64')
                       THEN `client_platform`
                   ELSE `client_architecture`
               END,
               `client_platform` = CASE
                   WHEN BINARY `client_platform` = BINARY 'x86'
                     OR BINARY `client_platform` = BINARY 'x64'
                       THEN 'Win'
                   ELSE 'unk'
               END
         WHERE BINARY `client_platform` = BINARY 'x86'
            OR BINARY `client_platform` = BINARY 'x64'
            OR BINARY `client_platform` = BINARY 'unk';

        START TRANSACTION;
        INSERT INTO `db_version`
            (`version`,`structure`,`content`,`description`,`comment`)
        VALUES
            (@cNewVersion,@cNewStructure,@cNewContent,
             @cNewDescription,@cNewComment);
        COMMIT;

        SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);
        SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,
               @cNewResult AS `===== DB is now on Version =====`;
    ELSEIF (@cCurVersion = @cNewVersion
        AND @cCurStructure = @cNewStructure
        AND @cCurContent = @cNewContent
        AND @cCurResult = @cNewDescription) THEN
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
