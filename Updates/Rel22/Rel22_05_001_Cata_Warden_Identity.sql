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
-- This is an attempt to create a full transactional MaNGOS update
-- Now compatible with newer MySql Databases (v1.5)
-- ----------------------------------------------------------------
DROP PROCEDURE IF EXISTS `update_mangos`;

DELIMITER $$

CREATE PROCEDURE `update_mangos`()
BEGIN
    DECLARE bRollback BOOL  DEFAULT FALSE ;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `bRollback` = TRUE;

    -- Current Values (TODO - must be a better way to do this)
    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT `structure` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cCurContent := (SELECT `content` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);

    -- Expected Values
    SET @cOldVersion = '22';
    SET @cOldStructure = '04';
    SET @cOldContent = '001';

    -- New Values
    SET @cNewVersion = '22';
    SET @cNewStructure = '05';
    SET @cNewContent = '001';
                            -- DESCRIPTION IS 30 Characters MAX
    SET @cNewDescription = 'Cata Warden identity';

                        -- COMMENT is 150 Characters MAX
    SET @cNewComment = 'Separate authenticated platform, Warden architecture and client variant';

    -- Evaluate all settings
    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `structure` DESC, `content` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version` = @cOldVersion AND `structure` = @cOldStructure AND `content` = @cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version` = @cNewVersion AND `structure` = @cNewStructure AND `content` = @cNewContent);

    IF (@cCurVersion = @cOldVersion
        AND @cCurStructure = @cOldStructure
        AND @cCurContent = @cOldContent
        AND @cCurResult = 'Warden audit') THEN
        -- APPLY UPDATE
        START TRANSACTION;
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
        -- -- PLACE UPDATE SQL BELOW -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

        -- Extend Realm Warden evidence with exact Cata client identity fields.
        -- The conditional ALTER statements make interrupted MariaDB DDL resumable.
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

        -- ALTER TABLE implicitly committed the outer template transaction.
        -- Restart it, and never let a failed preflight reach the conversion.
        START TRANSACTION;
        IF bRollback = FALSE THEN
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
        END IF;

        -- -- PLACE UPDATE SQL ABOVE -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

        -- If we get here ok, commit the changes
        IF bRollback = TRUE THEN
            ROLLBACK;
            SHOW ERRORS;
            SELECT '* UPDATE FAILED *' AS `===== Status =====`,@cCurResult AS `===== DB is on Version: =====`;
        ELSE
            -- Keep evidence conversion and its version marker atomic.
            INSERT INTO `db_version` VALUES (@cNewVersion, @cNewStructure, @cNewContent, @cNewDescription, @cNewComment);
            IF bRollback = TRUE THEN
                ROLLBACK;
                SHOW ERRORS;
                SELECT '* UPDATE FAILED *' AS `===== Status =====`,@cCurResult AS `===== DB is on Version: =====`;
            ELSE
                COMMIT;
                SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version`=@cNewVersion AND `structure`=@cNewStructure AND `content`=@cNewContent);
                SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,@cNewResult AS `===== DB is now on Version =====`;
            END IF;
        END IF;
    ELSE    -- Current version is not the expected version
        IF (@cCurVersion = @cNewVersion
            AND @cCurStructure = @cNewStructure
            AND @cCurContent = @cNewContent
            AND @cCurResult = @cNewResult
            AND @cNewResult = @cNewDescription) THEN    -- Does the current version match the new version
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cCurResult AS `===== DB is already on Version =====`;
        ELSE    -- Current version is not one related to this update
            IF(@cCurResult IS NULL) THEN    -- Something has gone wrong
                SELECT '* UPDATE FAILED *' AS `===== Status =====`,'Unable to locate DB Version Information' AS `============= Error Message =============`;
            ELSE
                IF(@cOldResult IS NULL) THEN    -- Something has gone wrong
                    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurStructure := (SELECT `STRUCTURE` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurContent := (SELECT `Content` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure, '_', @cCurContent, ' - ',@cCurResult);
                    SET @cOldResult = CONCAT('Rel',@cOldVersion, '_', @cOldStructure, '_', @cOldContent, ' - ','IS NOT APPLIED');
                    SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cOldResult AS `=== Expected ===`,@cCurOutput AS `===== Found Version =====`;
                ELSE
                    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurStructure := (SELECT `STRUCTURE` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurContent := (SELECT `Content` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
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
