DROP PROCEDURE IF EXISTS `upgradeTPDatabaseFor_submittal_details`;

DELIMITER $$ 

CREATE PROCEDURE `upgradeTPDatabaseFor_submittal_details` (IN _schema VARCHAR(255)) BEGIN 
-- Drop the table
        SET @dropStmt = CONCAT('DROP TABLE IF EXISTS ',_schema,'.joSubmittal;');
        PREPARE dropStmt FROM @dropStmt;
        EXECUTE dropStmt;
        DEALLOCATE PREPARE dropStmt;
        SELECT 'Table dropped successfully.' AS Result;

-- Drop the table
        SET @dropStmt = CONCAT('DROP TABLE IF EXISTS ',_schema,'.joSubmittalDetail;');
        PREPARE dropStmt FROM @dropStmt;
        EXECUTE dropStmt;
        DEALLOCATE PREPARE dropStmt;
        SELECT 'Table dropped successfully.' AS Result;

-- Create new table
        SET @createTable = CONCAT('CREATE TABLE `joSubmittal` (
                                  `joSubmittalID` int(10) NOT NULL AUTO_INCREMENT,
                                  `joMasterID` int(10) DEFAULT NULL,
                                  `totalCost` int(30) DEFAULT 0,
                                  `createdDate` datetime not NULL default CURRENT_TIMESTAMP(),
                                  `updateDate` datetime not NULL default CURRENT_TIMESTAMP(),
                                  PRIMARY KEY (`joSubmittalID`)
                                ) ENGINE=InnoDB  AUTO_INCREMENT=1000 DEFAULT CHARSET=latin1;');
        PREPARE createStmt FROM @createTable;
        EXECUTE createStmt;
        DEALLOCATE PREPARE createStmt;

-- Create new table
        SET @createTable = CONCAT('CREATE TABLE ',_schema,'.joSubmittalDetail (
                                    `joSubmittalDetailID` int(10) NOT NULL AUTO_INCREMENT,
                                    `joMasterID` int(10) DEFAULT NULL,
                                    `joSubmittalID` int(10) DEFAULT NULL,
                                    `category` varchar(100) DEFAULT NULL,
                                    `description` text DEFAULT NULL,
                                    `texteditor` text,
                                    `quantity` int(11) DEFAULT NULL,
                                    `statusDate` varchar(30) DEFAULT NULL,
                                    `vendorname` varchar(100) DEFAULT NULL,                                    
                                    `status` varchar(30) DEFAULT NULL,
                                    `cost` decimal(19,4) DEFAULT NULL,
                                    `inlineNote` longtext DEFAULT NULL,
                                    `rxManufacturerID` int(10) DEFAULT NULL,
                                    `FFA` tinyint(4) DEFAULT 0,
                                    `Paragraph` varchar(50) DEFAULT NULL,
                                    `createdDate` datetime not NULL default CURRENT_TIMESTAMP(),
                                    `updateDate` datetime not NULL default CURRENT_TIMESTAMP(), 
                                    PRIMARY KEY (`joSubmittalDetailID`)
                                    ) ENGINE=InnoDB  AUTO_INCREMENT=1000 DEFAULT CHARSET=latin1;');
        PREPARE createStmt FROM @createTable;
        EXECUTE createStmt;
        DEALLOCATE PREPARE createStmt;
        
        SELECT 'Table created successfully.' AS Result;
END$$ 


DELIMITER ;

-- =============================================
-- USE `dbbackup_BartosProd1_27032023`$$

DROP PROCEDURE IF EXISTS `SUBMITTAL_submittal`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `SUBMITTAL_submittal`(
IN _action VARCHAR(50),
IN _joMasterID INT,
IN _joSubmittalDetailID INT,
IN _category VARCHAR(100),
IN _description TEXT,
IN _texteditor LONGTEXT,
IN _quantity VARCHAR(8),
IN _vendorname VARCHAR(300),
IN _Status VARCHAR(30),
IN _statusDate VARCHAR(30),
IN _cost DECIMAL,
IN _inlineNote LONGTEXT,
IN _rxManufacturerID INT,
IN _FFA TINYINT,
IN _Paragraph VARCHAR(50),
IN _updateById INT,
IN _DEBUG TINYINT
)
SUBMITTAL_submittal: BEGIN


-- ==================================
/*
call SUBMITTAL_submittal(_action,_joMasterID,_joSubmittalDetailID,_category,_description,_texteditor,_quantity,_vendorname,_Status,_statusDate,_cost,_inlineNote,_rxManufacturerID,_FFA,_Paragraph,_updateById,_DEBUG);
CALL SUBMITTAL_submittal('GET', 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
CALL SUBMITTAL_submittal('INSERT',1, 'NULL', 'category', 'description', 'text_editor', 12, 'manufacturer', 'APPROVED', '03-12-2023', 670, 'inline_note', NULL, NULL, NULL, NULL, NULL);
CALL SUBMITTAL_submittal('UPDATE',1, 'NULL', 'category', 'description', 'text_editor', 12, 'manufacturer', 'APPROVED', '03-12-2023', 670, 'inline_note', NULL, NULL, NULL, NULL, NULL);
call SUBMITTAL_submittal('DELETE',1,1017, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
*/
-- ==================================

DECLARE _dateFormat VARCHAR(100) DEFAULT '%m-%d-%Y';
DECLARE _timeFormat VARCHAR(100) DEFAULT '%H:%m';

-- =========== for loops =======
/*
DECLARE _strLen    INT DEFAULT 0;
DECLARE _subStrLen INT DEFAULT 0;
DECLARE _recordIDs TEXT;
DECLARE _recordID INT;
DECLARE _finished INTEGER DEFAULT 0;
DECLARE _columns CURSOR FOR select MY_COLUMN_NAME from table;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
*/
-- =========== for loops =======

IF (_DEBUG IN (1,2,3)) THEN SELECT _action,@joSubmittalID,_joMasterID,_description,_texteditor,_quantity,_rxManufacturerID,_Status,_cost,_FFA,_Paragraph,_updateById,_DEBUG; END IF;

set @joSubmittalID=null;

IF (_joMasterID IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Submittal requires joMasterID';
		LEAVE SUBMITTAL_submittal;
ELSE
	SELECT joSubmittalID INTO @joSubmittalID FROM joSubmittal WHERE joMasterID = _joMasterID;
END IF;


IF (_action = 'GET' ) THEN
	IF (@joSubmittalID IS NOT NULL) THEN
		SELECT category,cost,description,joSubmittalDetailID,quantity,`status`,statusDate,texteditor,vendorname,inlineNote FROM joSubmittalDetail WHERE joSubmittalID = @joSubmittalID;
	ELSE
		INSERT INTO joSubmittal(joMasterID) VALUES (_joMasterID);
        END IF;

ELSEIF (_action = 'INSERT' ) THEN
    
	INSERT INTO joSubmittalDetail (
		joMasterID,description,texteditor,quantity,rxManufacturerID,STATUS,cost,FFA,Paragraph,category,statusDate,vendorname,joSubmittalID
		) VALUES (
		_joMasterID,_description,_texteditor,_quantity,_rxManufacturerID,_Status,_cost,_FFA,_Paragraph,_category,_statusDate,_vendorname,@joSubmittalID
		);
        
	UPDATE joSubmittal SET totalCost = (SELECT SUM(cost) FROM joSubmittalDetail WHERE joSubmittalID = @joSubmittalID) WHERE joSubmittalID = @joSubmittalID;
	SELECT category,cost,description,joSubmittalDetailID,quantity,`status`,statusDate,texteditor,vendorname,inlineNote FROM joSubmittalDetail WHERE joSubmittalID = @joSubmittalID;        
        
ELSEIF (_action = 'UPDATE') THEN

	IF (_joSubmittalDetailID IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joSubmittal requires joSubmittalDetailID';
		LEAVE SUBMITTAL_submittal;
	END IF;

UPDATE joSubmittalDetail
SET
    DESCRIPTION = CASE WHEN _description IS NOT NULL THEN _description ELSE DESCRIPTION END,
    texteditor = CASE WHEN _texteditor IS NOT NULL THEN _texteditor ELSE texteditor END,
    cost = CASE WHEN _cost IS NOT NULL THEN _cost ELSE cost END,
    vendorname = CASE WHEN _vendorname IS NOT NULL THEN _vendorname ELSE vendorname END,
    category = CASE WHEN _category IS NOT NULL THEN _category ELSE category END,
    quantity = CASE WHEN _quantity IS NOT NULL THEN _quantity ELSE quantity END,
    STATUS = CASE WHEN _status IS NOT NULL THEN _status ELSE STATUS END,
    statusDate = CASE WHEN _statusDate IS NOT NULL THEN _statusDate ELSE statusDate END,
    inlineNote = CASE WHEN _inlineNote IS NOT NULL THEN _inlineNote ELSE inlineNote END,
    updateDate = NOW()
WHERE
    joSubmittalDetailID = _joSubmittalDetailID;
    UPDATE joSubmittal SET totalCost = (SELECT SUM(cost) FROM joSubmittalDetail WHERE joSubmittalID = @joSubmittalID),updateDate = NOW() WHERE joSubmittalID = @joSubmittalID;
    SELECT category,cost,description,joSubmittalDetailID,quantity,`status`,statusDate,texteditor,vendorname,inlineNote FROM joSubmittalDetail WHERE joSubmittalID = @joSubmittalID;

ELSEIF (_action = 'DELETE') THEN

	IF (_joSubmittalDetailID IS NULL) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE joSubmittalDetail requires joSubmittalDetailID';
		LEAVE SUBMITTAL_submittal;
	END IF;

	DELETE FROM joSubmittalDetail WHERE joSubmittalDetailID = _joSubmittalDetailID;
    UPDATE joSubmittal SET totalCost = (SELECT SUM(cost) FROM joSubmittalDetail WHERE joSubmittalID = @joSubmittalID) WHERE joSubmittalID = @joSubmittalID;
	SELECT category,cost,description,joSubmittalDetailID,quantity,`status`,statusDate,texteditor,vendorname,inlineNote FROM joSubmittalDetail WHERE joSubmittalID = @joSubmittalID;
ELSE

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ACTION NOT SUPPORTED for SUBMITTAL_submittal';
	LEAVE SUBMITTAL_submittal;

END IF;

IF (_DEBUG IN (1,2,3)) THEN SELECT _action, t.* FROM joSubmittal t WHERE joSubmittalID = @joSubmittalID; END IF;

-- ============== EXAMPLE LOOP CODE ========
/*
	set _finished=0;
	OPEN _columns;
		readRecords: LOOP
			FETCH _columns INTO _MY_COLUMN_NAME;

			IF _finished = 1 THEN LEAVE readRecords; END IF;

			[ put code here ]

			IF _finished = 1 THEN LEAVE readRecords; END IF;

		END LOOP readRecords;
	    
	CLOSE _columns;
		
        
	select GROUP_CONCAT(valueId) into _recordIDs from myTable;
	do_records:
		LOOP
			set _recordID = null;
			SET _strLen = CHAR_LENGTH(_recordIDs);
			set _recordID=SUBSTRING_INDEX(_recordIDs, ',', 1);

			[ put code here ]
    
			SET _subStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_recordIDs, ',', 1))+2;
			SET _recordIDs = MID(_recordIDs, _subStrLen, _strLen);
			IF (_recordIDs = ' or _recordIDs is null) THEN LEAVE do_records; END IF;
                    
	END LOOP do_records; 	
*/
-- ============== EXAMPLE LOOP CODE ========

END$$

DELIMITER ;