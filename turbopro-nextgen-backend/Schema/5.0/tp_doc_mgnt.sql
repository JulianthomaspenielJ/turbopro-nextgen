

-- ==================================================================

DROP procedure IF EXISTS `DOC_setup`;

DELIMITER $$
CREATE PROCEDURE `DOC_setup`(IN _action varchar(100) )
DOC_setup: BEGIN

DECLARE DEBUG INT DEFAULT 0;
DECLARE _count INT;
DECLARE _tempTableName varchar(100);

	-- call DOC_setup(null); -- create if does not exist
	-- call DOC_setup('DROP'); -- force a drop, all data lost

	set _tempTableName = concat('DOC_documents');

		SELECT COUNT(*) into _count
		FROM information_schema.tables 
		WHERE table_name = _tempTableName;

    IF (_action = 'DROP' ) THEN
 		set _action = 'CREATE'; -- do nothing   
    ELSEIF (_count >0 ) THEN
		set _action = null; -- do nothing
	ELSE
		set _action = 'CREATE';
    END IF;

	if (_action='CREATE') THEN

			SET @drop = CONCAT('DROP TABLE IF EXISTS ',_tempTableName,';');

			-- CREATE TEMPORARY TABLE _tempTableName (
			SET @table = CONCAT('CREATE TABLE IF NOT EXISTS ',_tempTableName,' (');
			SET @table = CONCAT(@table,'');

			SET @table = CONCAT(@table,'documentId INT NOT NULL AUTO_INCREMENT,');
			SET @table = CONCAT(@table,'document_docTypeId INT  NULL,');
			SET @table = CONCAT(@table,'document_name  varchar(255) NOT NULL,');
			SET @table = CONCAT(@table,'document_description  varchar(1000) NULL,');
			SET @table = CONCAT(@table,'document_extension varchar(10) DEFAULT NULL,');
-- 			SET @table = CONCAT(@table,'document_aws_uri varchar(255)  NULL,');
-- 			SET @table = CONCAT(@table,'document_google_uri varchar(255)  NULL,');
			SET @table = CONCAT(@table,'document_storage_provider varchar(255)  NULL,');
			SET @table = CONCAT(@table,'document_uri varchar(255)  NULL,');
			
			-- TP specific variables, lookups
            -- joMasterID,joReleaseID,UserLoginID,vePOID,cuSOID,cuInvoiceID,veBillID,rxMasterID,rxContactID,joQuoteHeaderID
			SET @table = CONCAT(@table,'joMasterID INT  NULL,');            
			SET @table = CONCAT(@table,'joReleaseID INT  NULL,');
			SET @table = CONCAT(@table,'vePOID INT  NULL,');
			SET @table = CONCAT(@table,'cuSOID INT  NULL,');
			SET @table = CONCAT(@table,'cuInvoiceID INT  NULL,');
			SET @table = CONCAT(@table,'veBillID INT  NULL,');
			SET @table = CONCAT(@table,'rxMasterID INT  NULL,');
			SET @table = CONCAT(@table,'rxContactID INT  NULL,');
			SET @table = CONCAT(@table,'joQuoteHeaderID INT  NULL,');

			
			-- TODO: handle google, sharepoint, and aws links.
			SET @table = CONCAT(@table,'');

			-- TODO: handle permissions
			-- SET @table = CONCAT(@table,'');
			
			SET @table = CONCAT(@table,'document_version INT  NULL DEFAULT 1,');
			-- SET @table = CONCAT(@table,'document_legacyPath  varchar(255)  NULL,');
			SET @table = CONCAT(@table,'document_relatedTo  varchar(1000) NULL,');
			SET @table = CONCAT(@table,'document_uploadById INT NOT NULL,');
 			SET @table = CONCAT(@table,'document_editById INT  NULL,');
 			SET @table = CONCAT(@table,'document_createDate datetime DEFAULT now(),');
			SET @table = CONCAT(@table,'document_updateDate datetime DEFAULT now(),');
			-- SET @table = CONCAT(@table,'document_syncDate datetime DEFAULT NULL,');
			-- SET @table = CONCAT(@table,'document_syncLog varchar(255) NULL,');
			-- SET @table = CONCAT(@table,'');

            -- joMasterID,joReleaseID,UserLoginID,vePOID,cuSOID,cuInvoiceID,veBillID,rxMasterID,rxContactID,joQuoteHeaderID

			SET @table = CONCAT(@table,'PRIMARY KEY (`documentId`),');
			SET @table = CONCAT(@table,'  INDEX UPLOAD_IDX(document_uploadById),');
			SET @table = CONCAT(@table,'  INDEX JOMASTER_IDX(joMasterID),');
			SET @table = CONCAT(@table,'  INDEX PO_IDX(vePOID),');
			SET @table = CONCAT(@table,'  INDEX SO_IDX(cuSOID),');
			SET @table = CONCAT(@table,'  INDEX INVOICE_IDX(cuInvoiceID),');
			SET @table = CONCAT(@table,'  INDEX BILL_IDX(veBillID),');
			SET @table = CONCAT(@table,'  INDEX RXMASTER_IDX(rxMasterID)');
			-- SET @table = CONCAT(@table,'  INDEX {tp}_IDX(document_{tp}Id),'); 
			SET @table = CONCAT(@table,')');
			SET @table = CONCAT(@table,' ENGINE = InnoDB AUTO_INCREMENT=5000 DEFAULT CHARSET=utf8mb4;');

			select @drop,@table;

			PREPARE stmt from @drop; 
			EXECUTE stmt; 
			DEALLOCATE PREPARE stmt; 

			PREPARE stmt from @table; 
			EXECUTE stmt; 
			DEALLOCATE PREPARE stmt; 

            
			SET @drop=null;
			SET @table=null;

			set _tempTableName = concat('DOC_types');

			SET @drop = CONCAT('DROP TABLE IF EXISTS ',_tempTableName,';');

			-- CREATE TEMPORARY TABLE _tempTableName (
			SET @table = CONCAT('CREATE TABLE IF NOT EXISTS ',_tempTableName,' (');
			SET @table = CONCAT(@table,'  typeId int(11) NOT NULL AUTO_INCREMENT,');
			SET @table = CONCAT(@table,'  name varchar(45) NOT NULL,');
			SET @table = CONCAT(@table,'  createDate datetime DEFAULT now(),');
			SET @table = CONCAT(@table,'  PRIMARY KEY (`typeId`),');
			SET @table = CONCAT(@table,'  UNIQUE KEY `type_UNIQUE` (`name`)');
			SET @table = CONCAT(@table,') ENGINE=InnoDB   AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb4;');

			select @drop,@table;

			PREPARE stmt from @drop; 
			EXECUTE stmt; 
			DEALLOCATE PREPARE stmt; 

			PREPARE stmt from @table; 
			EXECUTE stmt; 
			DEALLOCATE PREPARE stmt; 


			SET @drop=null;
			SET @table=null;

		insert into DOC_types(typeId,`name`) values (10,'Contract');
		insert into DOC_types(typeId,`name`) values (11,'Job');
		insert into DOC_types(typeId,`name`) values (12,'Invoice');
		insert into DOC_types(typeId,`name`) values (13,'Sales Order');
		insert into DOC_types(typeId,`name`) values (14,'Purchase Order');

	END IF;


END$$

DELIMITER ;


-- ==================================================================
-- call ATT_getPicklist(null, null, 1); -- returns all the picklists
-- call ATT_getPicklist('doc_type', null,0); 

DROP procedure IF EXISTS `ATT_getPicklist`;

DELIMITER $$
CREATE PROCEDURE `ATT_getPicklist`( IN _tables varchar(1000), _roleId INT, _returnAll INT)
ATT_getPicklist: BEGIN

DECLARE allTables TEXT DEFAULT 'manufacturer,joQuoteCategory';
	
    IF _returnAll = 1 THEN
		set _tables = allTables;
    END IF;
    -- select allTables, _tables;
	    
    IF LOCATE('manufacturer', _tables) > 0 OR LOCATE('joQuoteCategory', _tables) > 0 OR LOCATE('joQuoteType', _tables) > 0 THEN
        SELECT DISTINCT 'submittal_manufacturer' AS tableName, rm.Name AS VALUE
		FROM joQuoteDetailMstr AS jqd
		LEFT JOIN rxMaster AS rm ON(jqd.manufacturer=rm.rxMasterID)
		WHERE jqd.type IN (2, 3) AND jqd.manufacturer IS NOT NULL AND jqd.manufacturer <> '' AND LOCATE('manufacturer', _tables) > 0
        UNION ALL
        SELECT 'joQuoteCategory' AS tableName, description AS VALUE FROM joQuoteCategory WHERE LOCATE('joQuoteCategory', _tables) > 0
        ORDER BY tableName, VALUE;
    END IF; 

END$$

DELIMITER ;





-- ==================================================================
DROP PROCEDURE IF EXISTS DOCUMENT_search;

DELIMITER $$

CREATE PROCEDURE DOCUMENT_search(
IN _action VARCHAR(50),
IN _documentName varchar(255),
IN _jobNumber varchar(255),
IN _jobName varchar(255),
IN _rolodexId int, -- joMaster(rxCustomerID or cuAssignmentID0 or cuAssignmentID1) , vePO ( rxVendorID ), cuSO (rxCustomerID,cuAssignmentID0, cuAssignmentID1), cuInvoice(rxCustomerID,cuAssignmentID0, cuAssignmentID1), veBill (rxMasterID)
IN _tsUserId int, -- edited or created 
IN _DEBUG TINYINT

)
DOCUMENT_search: BEGIN

		DECLARE _version varchar(10) DEFAULT '1.0';
        
		DECLARE _documentLimit int default 100;


-- ==================================
/*
call DOCUMENT_search(_action,_documentName,_jobNumber,_jobName,_rolodexId,_tsUserId,_DEBUG);
call DOCUMENT_search('SEARCH',null,'CBS',null,null,null,1);
call DOCUMENT_search('SEARCH',null,null,'Martin',null,null,1);
call DOCUMENT_search('SEARCH','test',null,null,null,null,1);
*/
-- ==================================

DECLARE _dateFormat varchar(100) DEFAULT '%m-%d-%Y';
DECLARE _timeFormat varchar(100) DEFAULT '%H:%m';

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

IF (_DEBUG in (2,3)) THEN SELECT _action,_DEBUG; END IF;



IF(_action='SEARCH') THEN
    
		IF(_documentLimit IS NULL) THEN
			SET _documentLimit = 100;
		END IF;
-- examples
/*
-- jobDescription
select * from DOC_documents doc
left join joMaster jm on ( jm.joMasterID = doc.joMasterID)
where jm.Description like '%Martin %';

-- if jobNumber
select ty.name as docType, c.FullName as uploadedBy, e.FullName as editedBy, doc.*  from DOC_documents doc
left join joMaster jm on ( jm.joMasterID = doc.joMasterID)
left join joRelease jr on ( jr.joMasterID = jm.joMasterID)
left join cuSO so on ( so.joReleaseID = jr.joReleaseID)
left join vePO po on ( po.joReleaseID = jr.joReleaseID)
left join cuInvoice cu on (cu.joReleaseDetailID  = jr.joReleaseID)
-- left join veBill on
left join  DOC_types ty on (ty.typeId = doc.document_docTypeId)
left join tsUserLogin c on (c.UserLoginID = doc.document_uploadById)
left join tsUserLogin e on (e.UserLoginID = doc.document_editById)
where jm.JobNumber like '%CBS%' or so.SONumber like '%CBS%' or po.PONumber  like '%CBS%' or InvoiceNumber   like '%CBS%' ;

*/    
			set  @l_sql = 'select ty.name as docType, c.FullName as uploadedBy, e.FullName as editedBy, doc.*  from DOC_documents doc ';


				if (_jobNumber is not null) THEN
					set @l_sql = 'select ty.name as docType, jm.FullName as uploadedBy, e.FullName as editedBy,jm.JobNumber as JobNumber,rx.Name as Customer , jm.description as jobName, doc.* from DOC_documents doc ';
					set @l_sql = CONCAT(@l_sql,' left join joMaster jm on ( jm.joMasterID = doc.joMasterID)');
					set @l_sql = CONCAT(@l_sql,' left join rxMaster rx on ( jm.rxCustomerID = rx.rxMasterID)');
					set @l_sql = CONCAT(@l_sql,' left join joRelease jr on ( jr.joMasterID = jm.joMasterID)');
					set @l_sql = CONCAT(@l_sql,' left join cuSO so on ( so.joReleaseID = jr.joReleaseID)');
					set @l_sql = CONCAT(@l_sql,' left join vePO po on ( po.joReleaseID = jr.joReleaseID)');
					set @l_sql = CONCAT(@l_sql,' left join cuInvoice cu on (cu.joReleaseDetailID  = jr.joReleaseID)');

                elseif (_jobName is not null) THEN
					set @l_sql = CONCAT(@l_sql,' left join joMaster jm on ( jm.joMasterID = doc.joMasterID)');
                elseif (_rolodexId is not null) THEN
					set @l_sql = 'select ty.name as docType, jm.Description as uploadedBy, jm.JobNumber as JobNumber,rx.Name as Customer, jm.description as jobName, doc.* from DOC_documents doc ';
					SET @l_sql = CONCAT(@l_sql, ' LEFT JOIN rxMaster rx ON (rx.rxMasterID = ', _rolodexId, ')');
                    SET @l_sql = CONCAT(@l_sql, ' LEFT JOIN joMaster jm ON (jm.rxCustomerID =rx.rxMasterID)');
					SET @l_sql = CONCAT(@l_sql, ' LEFT JOIN joRelease jr ON (jr.joMasterID = jm.joMasterID)');
					SET @l_sql = CONCAT(@l_sql, ' LEFT JOIN cuSO so ON (so.joReleaseID = jr.joReleaseID)');
					SET @l_sql = CONCAT(@l_sql, ' LEFT JOIN vePO po ON (po.joReleaseID = jr.joReleaseID)');
					SET @l_sql = CONCAT(@l_sql, ' LEFT JOIN cuInvoice cu ON (cu.joReleaseDetailID = jr.joReleaseID)');
					-- SET @l_sql = CONCAT(@l_sql, ' LEFT JOIN rxMaster rolodex ON (rolodex.rxMasterID like \'%', _rolodexId,'%\'');
                    -- TBD - do left joins base on all the ID's to search the following fields
					-- joMaster(rxCustomerID or cuAssignmentID0 or cuAssignmentID1) , vePO ( rxVendorID ), 
                    -- cuSO (rxCustomerID,cuAssignmentID0, cuAssignmentID1), cuInvoice(rxCustomerID,cuAssignmentID0, cuAssignmentID1), 
                    -- veBill (rxMasterID)
					set @l_sql = CONCAT(@l_sql,''); -- replace when figured out

                elseif (_documentName is not null) THEN
					set @l_sql = CONCAT(@l_sql,'');                
                elseif (_tsUserId is not null) THEN
					set @l_sql = CONCAT(@l_sql,'');
                END IF;

				set @l_sql = CONCAT(@l_sql,' left join  DOC_types ty on (ty.typeId = doc.document_docTypeId)');
				set @l_sql = CONCAT(@l_sql,' left join tsUserLogin c on (c.UserLoginID = doc.document_uploadById)');
				set @l_sql = CONCAT(@l_sql,' left join tsUserLogin e on (e.UserLoginID = doc.document_editById)');


				set @l_sql = CONCAT(@l_sql,' where ');
				
                if (_jobNumber is not null) THEN
				
					set @l_sql = CONCAT(@l_sql,' jm.JobNumber like \'%',_jobNumber,'%\'');
					set @l_sql = CONCAT(@l_sql,' or so.SONumber like \'%',_jobNumber,'%\'');
					set @l_sql = CONCAT(@l_sql,' or po.PONumber like \'%',_jobNumber,'%\'');
					set @l_sql = CONCAT(@l_sql,' or cu.InvoiceNumber like \'%',_jobNumber,'%\'');
                
                elseif (_jobName is not null) THEN
					
                    set @l_sql = CONCAT(@l_sql,' jm.Description like \'%',_jobName,'%\'');

                elseif (_documentName is not null) THEN
                
					set @l_sql = CONCAT(@l_sql,' doc.document_name like \'%',_documentName,'%\'');

                elseif (_rolodexId is not null) THEN
                    -- TBD - do left joins base on all the ID's to search the following fields
					-- joMaster(rxCustomerID or cuAssignmentID0 or cuAssignmentID1) , vePO ( rxVendorID ), 
                    -- cuSO (rxCustomerID,cuAssignmentID0, cuAssignmentID1), cuInvoice(rxCustomerID,cuAssignmentID0, cuAssignmentID1), 
                    -- veBill (rxMasterID)
					set @l_sql = CONCAT(@l_sql,'doc.rxMasterID like \'%', _rolodexId,'%\''); -- replace with the proper or clause for all these attributes.                elseif (_tsUserId is not null) THEN
				END IF;

                
				set @l_sql = CONCAT(@l_sql,' order by document_name asc ;'); 
				-- set @l_sql = CONCAT(@l_sql,' limit ', _limit); -- consider adding. 

			IF (_DEBUG in (1,2,3)) THEN select _action,@l_sql; END IF;

			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			set @l_sql = null;

	END IF;


END$$


DELIMITER ;



-- ==================================================================
DROP PROCEDURE IF EXISTS DOCUMENT_document;

DELIMITER $$

CREATE PROCEDURE DOCUMENT_document(
IN _action VARCHAR(50),
IN _documentId int,
IN _document_docTypeId int,
IN _document_name varchar(255),
IN _document_description varchar(1000),
IN _document_extension varchar(10),
-- IN _document_aws_uri varchar(255),
-- IN _document_google_uri varchar(255),
IN _document_storage_provider varchar(255),
IN _document_uri varchar(255),
IN _joMasterID int,
IN _joReleaseID int,
IN _vePOID int,
IN _cuSOID int,
IN _cuInvoiceID int,
IN _veBillID int,
IN _rxMasterID int,
IN _rxContactID int,
IN _joQuoteHeaderID int,
IN _document_version int,
IN _document_relatedTo varchar(1000),
-- IN _document_uploadById int,
-- IN _document_editById int,
IN _updateById int,
-- IN _documentLimit int,
IN _DEBUG TINYINT
)
DOCUMENT_document: BEGIN

		DECLARE _version varchar(10) DEFAULT '1.0';
        
		-- DECLARE _commaNeeded INT DEFAULT 0;
		DECLARE _relatedTo VARCHAR(1000);
		DECLARE _documentLimit int default 100;
        
		-- DECLARE _clientName VARCHAR(1000);
		-- DECLARE _entityName VARCHAR(1000);
		-- DECLARE updateCommaNeeded INT DEFAULT 0;

-- ==================================
/*
call DOCUMENT_document(_action,_documentId,_document_docTypeId,_document_name,_document_description,_document_extension,_document_aws_uri,_document_google_uri,_joMasterID,_joReleaseID,_vePOID,_cuSOID,_cuInvoiceID,_veBillID,_rxMasterID,_rxContactID,_joQuoteHeaderID,_document_version,_document_relatedTo,_updateById,_DEBUG);
call DOCUMENT_document('GET',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
call DOCUMENT_document('CREATE',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
call DOCUMENT_document('UPDATE',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
call DOCUMENT_document('DELETE',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
call DOCUMENT_document('UPDATE_DOCUMENT_URI',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
*/
-- ==================================

DECLARE _dateFormat varchar(100) DEFAULT '%m-%d-%Y';
DECLARE _timeFormat varchar(100) DEFAULT '%H:%m';

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

-- IF (_DEBUG in (1,2,3)) THEN SELECT _action,_documentId,_document_docTypeId,_document_name,_document_description,_document_extension,_document_aws_uri,_document_google_uri,_joMasterID,_joReleaseID,_vePOID,_cuSOID,_cuInvoiceID,_veBillID,_rxMasterID,_rxContactID,_joQuoteHeaderID,_document_version,_document_relatedTo,_updateById,_DEBUG; END IF;
--
IF (_DEBUG in (1,2,3)) THEN SELECT _action,_documentId,_document_docTypeId,_document_name,_document_description,_document_extension,_document_storage_provider,_document_uri,_joMasterID,_joReleaseID,_vePOID,_cuSOID,_cuInvoiceID,_veBillID,_rxMasterID,_rxContactID,_joQuoteHeaderID,_document_version,_document_relatedTo,_updateById,_DEBUG; END IF;



	IF (_action = 'UPDATE' AND _documentId IS NOT NULL) THEN
    IF (_documentId IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE DOC_documents requires documentId';
        LEAVE DOCUMENT_document;
    END IF;

    IF (_document_name IS NULL) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE DOC_documents requires document_name';
        LEAVE DOCUMENT_document;
    END IF;

    SET @l_sql = 'UPDATE DOC_documents SET document_updateDate = NOW()';

    IF (_document_name IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_name = "', _document_name, '"');
    END IF;

    IF (_document_docTypeId IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_docTypeId = ', _document_docTypeId);
    END IF;

    IF (_document_description IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_description = "', _document_description, '"');
    END IF;

    IF (_document_extension IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_extension = "', _document_extension, '"');
    END IF;

    IF (_document_storage_provider IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_storage_provider = "', _document_storage_provider, '"');
    END IF;

    IF (_document_uri IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_uri = "', _document_uri, '"');
    END IF;

    IF (_joMasterID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', joMasterID = ', _joMasterID);
    END IF;

    IF (_joReleaseID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', joReleaseID = ', _joReleaseID);
    END IF;

    IF (_vePOID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', vePOID = ', _vePOID);
    END IF;

    IF (_cuSOID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', cuSOID = ', _cuSOID);
    END IF;

    IF (_cuInvoiceID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', cuInvoiceID = ', _cuInvoiceID);
    END IF;

    IF (_veBillID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', veBillID = ', _veBillID);
    END IF;

    IF (_rxMasterID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', rxMasterID = ', _rxMasterID);
    END IF;

    IF (_rxContactID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', rxContactID = ', _rxContactID);
    END IF;

    IF (_joQuoteHeaderID IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', joQuoteHeaderID = ', _joQuoteHeaderID);
    END IF;

    IF (_document_version IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_version = ', _document_version);
    END IF;

    IF (_document_relatedTo IS NOT NULL) THEN
        SET @l_sql = CONCAT(@l_sql, ', document_relatedTo = "', _document_relatedTo, '"');
    END IF;

    -- IF (_document_uploadById IS NOT NULL) THEN
    --     SET @l_sql = CONCAT(@l_sql, ', document_uploadById = ', _document_uploadById);
    -- END IF;

    -- IF (_document_editById IS NOT NULL) THEN
    --     SET @l_sql = CONCAT(@l_sql, ', document_editById = ', _document_editById);
    -- END IF;

    SET @l_sql = CONCAT(@l_sql, ' WHERE documentId = ', _documentId);

    IF (_DEBUG IN (1, 2, 3)) THEN
        SELECT _action, @l_sql;
    END IF;

    PREPARE stmt FROM @l_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    SET @l_sql = NULL;

    SELECT * FROM DOC_documents WHERE documentId = _documentId;

	ELSEIF(_action='CREATE' AND _documentId IS  NULL) THEN
				
                SET _relatedTo='';
                /* BUILDING THE RELATED TO
				IF (_clientId IS NOT NULL AND _clientId>0) THEN
					SELECT client_clientName INTO _clientName FROM `client` WHERE clientId=_clientId;
					IF(_clientName IS NOT NULL) THEN
						IF (updateCommaNeeded>0) THEN SET _relatedTo = CONCAT(_relatedTo,'-'); END IF;
						SET _relatedTo=CONCAT(_relatedTo,_clientName);
						SET updateCommaNeeded =1;
					END IF;
				END IF;
                
				IF (_contractId IS NOT NULL AND _contractId>0) THEN
					IF (updateCommaNeeded>0) THEN SET _relatedTo = CONCAT(_relatedTo,'-'); END IF;
					SET _relatedTo=CONCAT(_relatedTo,' Contract#:',_contractId);
					SET updateCommaNeeded =1;
				END IF;
				IF (_orderId IS NOT NULL AND _orderId>0) THEN
					IF (updateCommaNeeded>0) THEN SET _relatedTo = CONCAT(_relatedTo,'-'); END IF;
					SET _relatedTo=CONCAT(_relatedTo,' Order#:',_orderId);
					SET updateCommaNeeded =1;
				END IF;
				IF (_entityId IS NOT NULL AND _entityId>0) THEN
					SELECT ENTITY_formatName(LEFT(entity_firstName,50), LEFT(entity_middleName,50), LEFT(entity_lastName,50),NULL,NULL) AS fullName INTO _entityName FROM `entity` WHERE entityId=_entityId;
					IF (updateCommaNeeded>0) THEN SET _relatedTo = CONCAT(_relatedTo,'-'); END IF;			
					SET _relatedTo=CONCAT(_relatedTo,' ',_entityName);
					SET updateCommaNeeded =1;
				END IF;
			*/

			if (_document_name is null) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CREATE DOC_documents requires document_name';
				LEAVE DOCUMENT_document;
			END IF;
			-- if (_document_uploadById is null) THEN
			-- 	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CREATE DOC_documents requires document_uploadById';
			-- 	LEAVE DOCUMENT_document;
			-- END IF;

-- 			insert into DOC_documents (
-- 				document_docTypeId,document_name,document_description,document_extension,document_aws_uri,document_google_uri,joMasterID,joReleaseID,vePOID,cuSOID,cuInvoiceID,veBillID,rxMasterID,rxContactID,joQuoteHeaderID,document_version,document_relatedTo,document_uploadById,document_editById,document_createDate,document_updateDate
-- 				) values (
-- 				_document_docTypeId,_document_name,_document_description,_document_extension,_document_aws_uri,_document_google_uri,_joMasterID,_joReleaseID,_vePOID,_cuSOID,_cuInvoiceID,_veBillID,_rxMasterID,_rxContactID,_joQuoteHeaderID,_document_version,_document_relatedTo,_updateById,_updateById,now(),now()
-- 				);
			insert into DOC_documents (
				document_docTypeId,document_name,document_description,document_extension,document_storage_provider,document_uri,joMasterID,joReleaseID,vePOID,cuSOID,cuInvoiceID,veBillID,rxMasterID,rxContactID,joQuoteHeaderID,document_version,document_relatedTo,document_uploadById,document_editById,document_createDate,document_updateDate
				) values (
				_document_docTypeId,_document_name,_document_description,_document_extension,_document_storage_provider,_document_uri,_joMasterID,_joReleaseID,_vePOID,_cuSOID,_cuInvoiceID,_veBillID,_rxMasterID,_rxContactID,_joQuoteHeaderID,_document_version,_document_relatedTo,_updateById,_updateById,now(),now()
				);

			SET _documentId = LAST_INSERT_ID();

			select _documentId as documentId;
    
			SELECT * FROM DOC_documents WHERE documentId=_documentId;

	ELSEIF(_action='DELETE') THEN

		if (_documentId is null) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE DOC_documents requires documentId';
			LEAVE DOCUMENT_document;
		END IF;

		DELETE FROM DOC_documents where documentId = _documentId;

    ELSEIF(_action='GET') THEN
    
		IF(_documentLimit IS NULL) THEN
			SET _documentLimit = 100;
		END IF;
    
			set  @l_sql = 'SELECT d.*,jm.Description as jobName,jm.JobNumber,ty.name as docType, rx.Name as Customer FROM DOC_documents d LEFT JOIN joMaster jm ON d.joMasterID = jm.joMasterID LEFT Join rxMaster rx ON rx.rxMasterID = jm.rxCustomerID left join  DOC_types ty on (ty.typeId = d.document_docTypeId) where d.documentId is NOT NULL ';
			 

				if (_document_docTypeId is not null) THEN
					set @l_sql = CONCAT(@l_sql,'and d.document_docTypeId= ',_document_docTypeId);
				END IF;

				if (_document_name is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.document_name= \'',_document_name,'\'');
				END IF;

				if (_document_description is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.document_description like \'%',_document_description,'%\'');
				END IF;

				if (_document_extension is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.document_extension= \'',_document_extension,'\'');
				END IF;

				if (_joMasterID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.joMasterID= ',_joMasterID);
				END IF;

				if (_joReleaseID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.joReleaseID= ',_joReleaseID);
				END IF;

				if (_vePOID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.vePOID= ',_vePOID);
				END IF;

				if (_cuSOID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.cuSOID= ',_cuSOID);
				END IF;

				if (_cuInvoiceID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.cuInvoiceID= ',_cuInvoiceID);
				END IF;

				if (_veBillID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.veBillID= ',_veBillID);
				END IF;

				if (_rxMasterID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.rxMasterID= ',_rxMasterID);
				END IF;

				if (_rxContactID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.rxContactID= ',_rxContactID);
				END IF;

				if (_joQuoteHeaderID is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.joQuoteHeaderID= ',_joQuoteHeaderID);
				END IF;

				if (_document_version is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and d.document_version= ',_document_version);
				END IF;


				if (_updateById is not null) THEN
					set @l_sql = CONCAT(@l_sql,' and (d.document_uploadById= ',_updateById,')');
				END IF;

				-- set @l_sql = CONCAT(@l_sql,' documentId= ',_documentId);

				set @l_sql = CONCAT(@l_sql,' order by d.document_name asc ');

			IF (_DEBUG in (1,2,3)) THEN select _action,@l_sql; END IF;

			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
			set @l_sql = null;
 
 
    ELSEIF(_action='UPDATE_DOCUMENT_URI') THEN
 
		if (_documentId is null) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE DOC_documents requires documentId';
			LEAVE DOCUMENT_document;
		END IF;

		set  @l_sql = 'update DOC_documents set document_updateDate=now()';
-- 		if (_document_aws_uri is not null) THEN
-- 			set @l_sql = CONCAT(@l_sql,', document_aws_uri= \'',_document_aws_uri,'\'');
-- 		ELSE
-- 			set @l_sql = CONCAT(@l_sql,', document_aws_uri= NULL');
-- 		END IF;
--
-- 		if (_document_google_uri is not null) THEN
-- 			set @l_sql = CONCAT(@l_sql,', document_google_uri= \'',_document_google_uri,'\'');
-- 		ELSE
-- 			set @l_sql = CONCAT(@l_sql,', document_google_uri= NULL');
-- 		END IF;

		if (_document_storage_provider is not null) THEN
			set @l_sql = CONCAT(@l_sql,', document_storage_provider= \'',_document_storage_provider,'\'');
		ELSE
			set @l_sql = CONCAT(@l_sql,', document_storage_provider= NULL');
		END IF;

		if (_document_uri is not null) THEN
			set @l_sql = CONCAT(@l_sql,', document_uri= \'',_document_uri,'\'');
		ELSE
			set @l_sql = CONCAT(@l_sql,', document_uri= NULL');
		END IF;

		set @l_sql = CONCAT(@l_sql,' where documentId= ',_documentId);

		IF (_DEBUG in (1,2,3)) THEN select _action,@l_sql; END IF;

		PREPARE stmt FROM @l_sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
		set @l_sql = null;
	
	END IF;


END$$

DELIMITER ; 
