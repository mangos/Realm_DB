-- --------------------------------------------------------------------------------
-- This is an attempt to create a full transactional update
-- --------------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS `update_mangos`; 

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos` ()

BEGIN
    DECLARE bRollback BOOL  DEFAULT FALSE ;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `bRollback` = TRUE;

    -- Current Values (TODO - must be a better way to do this)
    SET @cCurVersion := (SELECT `version` FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT structure FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);
    SET @cCurContent := (SELECT content FROM db_version ORDER BY `version` DESC, STRUCTURE DESC, CONTENT DESC LIMIT 0,1);

    -- Expected Values
    SET @cOldVersion = '21'; 
    SET @cOldStructure = '1'; 
    SET @cOldContent = '0'; 

    -- New Values
    SET @cNewVersion = '21';
    SET @cNewStructure = '1';
    SET @cNewContent = '1';
                            -- DESCRIPTION IS 30 Characters MAX    
    SET @cNewDescription = 'dbdocs update'; 

                        -- COMMENT is 150 Characters MAX
    SET @cNewComment = 'Added some dbdocs updates';

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

DELETE FROM `dbdocsfields` WHERE fieldid=59;
INSERT  INTO `dbdocsfields` (`languageId`,`tableName`,`fieldName`,`fieldComment`,`fieldNotes`) VALUES (0,'account','os','The Operating System of the connect client','The Operating System of the connect client. This is used by the Warden Module');
DELETE FROM `dbdocsfields` WHERE fieldid=60;
INSERT  INTO `dbdocsfields` (`languageId`,`tableName`,`fieldName`,`fieldComment`,`fieldNotes`) VALUES (0,'account','playerBot','Determines whether the account is a User or a PlayerBot','Determines whether the account is a User or a PlayerBot.<br /><br />¬subtable:11¬');

UPDATE `dbdocsfields` SET `FieldComment` = 'The account security level.', `fieldNotes` = 'The account security level. Different levels have access to different commands. The individual level required for a command is defined in the Mangos command table. Valid values are:<br /><br />¬subtable:1¬<br />' WHERE `fieldId`= '5' AND `languageId`= 0;
UPDATE `dbdocsfields` SET `FieldComment` = 'Which expansion\'s content a user has access to.', `fieldNotes` = 'The field controls to which expansion\'s content a user has access. By default this is set to 0, allowing access to vanilla WoW content. In mangos-zero, other values can be ignored, since there is no expansion.<br /><br />¬subtable:2¬' WHERE `fieldId`= '3' AND `languageId`= 0;
UPDATE `dbdocsfields` SET `FieldComment` = 'Is the ban is currently active or not.', `fieldNotes` = 'This is a Boolean field controlling if the ban is currently active or not.<br /><br />¬subtable:4¬' WHERE `fieldId`= '18' AND `languageId`= 0;

DELETE FROM `dbdocssubtables` WHERE `subtableId`= 11 AND languageId=0;
INSERT  INTO `dbdocssubtables`(`subtableId`,`languageId`,`subtableName`,`subtablecontent`,`subtableTemplate`) VALUES (11,0,'Account Types','<table border=\'1\' cellspacing=\'1\' cellpadding=\'3\' bgcolor=\'#f0f0f0\'>
<tr bgcolor=\'#f0f0ff\'>
<th><b>Value</b></th>
<th align=\'left\'><b>Account Type</b></th>
<tr bgcolor=\'#FFFFEE\'><td align=\'center\' valign=\'middle\'>0</td><td align=\'left\' valign=\'middle\'>Normal User</td></tr>
<tr bgcolor=\'#FEFEFF\'><td align=\'center\' valign=\'middle\'>1</td><td align=\'left\' valign=\'middle\'>Playerbot account</td></tr>
</table>
','Value|<Account Type
0|Normal User
1|Playerbot account');

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
                SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cOldResult AS `=== Expected ===`,@cCurResult AS `===== Found Version =====`;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;

-- Execute the procedure
CALL update_mangos();

-- Drop the procedure
DROP PROCEDURE IF EXISTS `update_mangos`;