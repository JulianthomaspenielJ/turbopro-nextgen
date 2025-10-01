-- ===============================================================================================================================================================
--                                                                         DOCUMENT_processor 
-- ===============================================================================================================================================================
-- Developer: Devendra
-- Date: 2025-07-15
-- Procedure Name: DOCUMENT_processor
-- Description: Handle acknowledgment and processing of AI-extracted document types (e.g., Acknowledgement, BidList, etc.)
--              Validates JSON and updates related system tables (e.g., cePO)
-- ===============================================================================================================================================================
DROP PROCEDURE IF EXISTS `DOCUMENT_processor`;

DELIMITER $$
CREATE PROCEDURE `DOCUMENT_processor`(
    IN _action VARCHAR(225),
    IN _docJson JSON,
    IN _userId INT,
    IN _debug TINYINT
)
DOCUMENT_processor:BEGIN

    -- ===============================================================================================================================================================
    -- CALL DOCUMENT_processor(_action, _docJson, _userId, _debug);
    
    -- Example:
    /*
    SET @_docJson = '{
        "documentType": null,
        "poNumber": "KKT230903M",
        "items": [
            {
            "position": 1,
            "vendorOrderNumber": "104071",
            "ackDate": "07/09/2025",
            "shipDate": "07/15/2025"
            },
            {
            "position": 817003,
            "vendorOrderNumber": "104078",
            "ackDate": "07/29/2025",
            "shipDate": "07/29/2025"
            }
        ]
     }';
     CALL DOCUMENT_processor("ACKNOWLEDGEMENT", @_docJson, 5, 15);
    */
    -- Smart Debug Levels: 1 --> Main SQL query & key variables
    --                     2 --> Inside conditions
    --                     3 --> Nested Conditions
    --                     4 --> Inside loops
    --                     5 --> All debug info
    -- 1, (2,10,12,15),(3,11,13,15),(4, 12, 13, 15),(4,15)
    -- ===============================================================================================================================================================

    DECLARE _version VARCHAR(10) DEFAULT '1.0';
    DECLARE _debugStatement LONGTEXT DEFAULT '';
    DECLARE _startTime TIMESTAMP;
    DECLARE _endTime TIMESTAMP;

    DECLARE _isValid BOOLEAN DEFAULT TRUE;
    DECLARE _errorMsg TEXT;
    
    -- Acknowledgement Fields
	DECLARE _documentType VARCHAR(100);
	DECLARE _vendorOrderNumber VARCHAR(100);
	DECLARE _ackDate DATE;
	DECLARE _shipDate DATE;
	DECLARE _vePoid INT;
	DECLARE _vePodetailId INT;
	DECLARE _itemCount INT DEFAULT 0;
	DECLARE _counter INT DEFAULT 0;
	DECLARE _poNumber VARCHAR(50);
    DECLARE _position INT;
	DECLARE _note TEXT DEFAULT '';
	DECLARE _skipped INT DEFAULT 0;
    DECLARE _fileProcessingRecordLocator LONGTEXT;
    DECLARE _totalAmount DECIMAL(19,4);
    DECLARE _totalPoAmount DECIMAL(19,4);
    DECLARE _lineItemCount INT;
    DECLARE _itemIndex INT;
    DECLARE _qty INT;
    DECLARE _unitCost DECIMAL(19,4);
    DECLARE _description LONGTEXT;
    
    DECLARE _result JSON;

    -- ----------------------------------------------
    -- Step 1: Input & Document Type Validation
    -- ----------------------------------------------
    SELECT NOW() INTO _startTime;

    -- Extract documentType from JSON
    SET _documentType = TRIM(JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.documentType')));

    -- ------------------------------------------
    -- Debug Level 1: Initial Request Info
    -- ------------------------------------------
    IF _debug >= 1 THEN
        SET _debugStatement = CONCAT_WS(
            CHAR(10),
            "============================================",
            "DEBUG LEVEL: MAIN ENTRY",
            "--------------------------------------------",
            "Timestamp           : ", _startTime,
            "Procedure Name      : DOCUMENT_processor",
            "Action              : ", _action,
            "User ID             : ", _userId,
            "Extracted docType   : ", IFNULL(_documentType, 'NULL'),
            "============================================"
        );
    END IF;

    -- ----------------------------------------------
    -- Step 2: Document Type Routing & Validation
    -- ----------------------------------------------

    -- Case 1: Missing or empty documentType
    IF _documentType IS NULL OR _documentType = '' THEN
        SET _result = JSON_OBJECT(
            'fileProcessingStatus', 'FAILED',
            'fileProcessingType', 'Unknown',
            'fileProcessingMsg', 'We were unable to process this file. Missing or empty documentType',
            'fileProcessingRecordLocator', NULL,
            'note', 'Ensure the field "documentType" exists and is not blank.'
        );

		-- ------------------------------------------
		-- Debug Level2:documentType Validation
		-- ------------------------------------------	
        IF _debug  IN (2,10,12,15) THEN
            SET _debugStatement = CONCAT_WS(
                CHAR(10),
                _debugStatement,
                "DEBUG: documentType validation failed - documentType is NULL or empty.",
                "============================================"
            );
        END IF;

        SELECT _result AS result;
        LEAVE DOCUMENT_processor;
    END IF;

    -- Case 2: Unsupported documentType
    IF _documentType NOT IN ('PO_Acknowledgement', 'BidList') THEN
        SET _result = JSON_OBJECT(
            'fileProcessingStatus', 'FAILED',
            'fileProcessingType', _documentType,
            'fileProcessingMsg', CONCAT('We were unable to process this file. Unsupported documentType: "', _documentType, '".'),
            'fileProcessingRecordLocator', NULL,
            'note', 'Only the following types are supported: PO_Acknowledgement, BidList.'
        );
		
        -- ------------------------------------------
		-- Debug Level2:documentType Validation
		-- ------------------------------------------
        IF _debug IN (2,10,12,15) THEN
            SET _debugStatement = CONCAT_WS(
                CHAR(10),
                _debugStatement,
                CONCAT("DEBUG: Unsupported documentType encountered: ", _documentType),
                "============================================"
            );
        END IF;

        SELECT _result AS result;
        LEAVE DOCUMENT_processor;
    END IF;

    -- -----------------------------------
    -- Valid Types: Route accordingly
    -- -----------------------------------
    IF _documentType = 'PO_Acknowledgement' THEN  -- poNumber
		-- ----------------------------------
        -- Begin transaction
        -- ----------------------------------
        START TRANSACTION;
        
        -- Extract PO Number
        SET _poNumber = TRIM(JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.poNumber')));
        IF _poNumber IS NULL OR _poNumber = '' THEN
            SET _result = JSON_OBJECT(
                'fileProcessingStatus', 'FAILED',
                'fileProcessingType', _documentType,
                'fileProcessingMsg', 'We were unable to acknowledge this document. Missing poNumber in Acknowledgement document.',
                'fileProcessingRecordLocator', NULL,
                'fileProcessingNote', 'Ensure poNumber is present and not empty.'
            );
            ROLLBACK;
            SELECT _result AS result;
            LEAVE DOCUMENT_processor;
        END IF;

        -- Extract totalAmount
        SET _totalAmount = TRIM(JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.totalAmount')));
        IF _totalAmount IS NULL OR _totalAmount = '' THEN
            SET _result = JSON_OBJECT(
                'fileProcessingStatus', 'FAILED',
                'fileProcessingType', _documentType,
                'fileProcessingMsg', 'Unable to process the document. The totalAmount field is missing or empty in the Acknowledgement document.',
                'fileProcessingRecordLocator', NULL,
                'fileProcessingNote', 'Ensure that the totalAmount field is included in the document and is not empty.'
            );
            ROLLBACK;
            SELECT _result AS result;
            LEAVE DOCUMENT_processor;
        END IF;
 
 		-- Lookup vePOID
        SELECT vePOID,MATH_bankers_round(null,(Subtotal+TaxTotal+Freight),2) INTO _vePOId,_totalPoAmount FROM vePO WHERE PONumber = _poNumber LIMIT 1;
        
        IF _vePOID IS NULL THEN
            SET _result = JSON_OBJECT(
                'fileProcessingStatus', 'FAILED',
                'fileProcessingType', _documentType,
                'fileProcessingMsg', CONCAT('Unable to process the document. No matching purchase order found for PO number: ', _poNumber),
                'fileProcessingRecordLocator', _fileProcessingRecordLocator,
                'fileProcessingNote', 'Verify that the PO number exists in the system and is correctly provided in the document.'
            );
            ROLLBACK;
            SELECT _result AS result;
            LEAVE DOCUMENT_processor;
        END IF;
		
        IF _totalPoAmount<>_totalAmount  THEN
            SET _result = JSON_OBJECT(
                'fileProcessingStatus', 'FAILED',
                'fileProcessingType', _documentType,
                'fileProcessingMsg',CONCAT('Unable to process the document. The totalAmount:',_totalAmount,' in the document does not match the total amount:',_totalPoAmount,'  for the purchase order in our records.'),
                'fileProcessingRecordLocator', _fileProcessingRecordLocator,
                'fileProcessingNote', 'Review the totalAmount in the document and ensure it matches the PO total (subtotal + tax + freight) in the system.'
            );
            ROLLBACK;
            SELECT _result AS result;
            LEAVE DOCUMENT_processor;
        END IF;
        
		-- Loop and update
        SET _itemCount = JSON_LENGTH(_docJson, '$.items');
        IF _itemCount IS NULL OR _itemCount = 0 THEN
            SET _result = JSON_OBJECT(
                'fileProcessingStatus', 'FAILED',
                'fileProcessingType', _documentType,
                'fileProcessingMsg', 'Unable to process the document. No item details found in the Acknowledgement document.',
                'fileProcessingRecordLocator', _fileProcessingRecordLocator,
				'fileProcessingNote', 'Make sure that the document includes at least one item entry before uploading.'
            );
            ROLLBACK;
            SELECT _result AS result;
            LEAVE DOCUMENT_processor;
        END IF;
        
        select COUNT(*) INTO _lineItemCount from vePODetail where vePOID=_vePOId;
        IF _itemCount <>_lineItemCount THEN
            SET _result = JSON_OBJECT(
                'fileProcessingStatus', 'FAILED',
                'fileProcessingType', _documentType,
                'fileProcessingMsg', 'Unable to process the document. The number of items in the document does not match the purchase order records.',
                'fileProcessingRecordLocator', _fileProcessingRecordLocator,
				'fileProcessingNote', 'Verify that the items in the document match the PO details, including quantity and count.'
            );
            ROLLBACK;
            SELECT _result AS result;
            LEAVE DOCUMENT_processor;
        END IF;
        
	
		-- ------------------------
        -- Extract fields
        -- ------------------------
		SET @vendorOrderNumberStr = JSON_UNQUOTE(JSON_EXTRACT(_docJson,'$.vendorOrderNumber'));
		SET _vendorOrderNumber = IF(@vendorOrderNumberStr IS NULL OR TRIM(@vendorOrderNumberStr) = '', NULL, @vendorOrderNumberStr);

		SET @ackDateStr = JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.ackDate'));
		SET _ackDate = IF(@ackDateStr IS NULL OR TRIM(@ackDateStr) = '', NULL, STR_TO_DATE(@ackDateStr, '%m/%d/%Y'));

		SET @shipDateStr = JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.shipDate'));
		SET _shipDate = IF(@shipDateStr IS NULL OR TRIM(@shipDateStr) = '', NULL, STR_TO_DATE(@shipDateStr, '%m/%d/%Y'));
    
    /*        
        SET _itemIndex = 0;
		WHILE _itemIndex < _itemCount DO
			-- Extract fields from JSON item
			SET _qty = JSON_UNQUOTE(JSON_EXTRACT(_docJson, CONCAT('$.items[', _itemIndex, '].qty')));
			SET _unitCost = JSON_UNQUOTE(JSON_EXTRACT(_docJson, CONCAT('$.items[', _itemIndex, '].UnitCost')));
			SET _description = JSON_UNQUOTE(JSON_EXTRACT(_docJson, CONCAT('$.items[', _itemIndex, '].Description')));

			SET @vendorOrderNumberStr = JSON_UNQUOTE(JSON_EXTRACT(_docJson,'$.items[', _itemIndex, '].vendorOrderNumber'));
			SET _vendorOrderNumber = IF(@vendorOrderNumberStr IS NULL OR TRIM(@vendorOrderNumberStr) = '', NULL, @vendorOrderNumberStr);

			SET @ackDateStr = JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.items[', _itemIndex, '].ackDate'));
			SET _ackDate = IF(@ackDateStr IS NULL OR TRIM(@ackDateStr) = '', NULL, STR_TO_DATE(@ackDateStr, '%m/%d/%Y'));

			SET @shipDateStr = JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.items[', _itemIndex, '].shipDate'));
			SET _shipDate = IF(@shipDateStr IS NULL OR TRIM(@shipDateStr) = '', NULL, STR_TO_DATE(@shipDateStr, '%m/%d/%Y'));	
            
            SELECT vePODetailID INTO _vePODetailId  FROM vePODetail  
            WHERE vePOID = _vePOId AND QuantityOrdered = _qty AND UnitCost = _unitCost AND Description = _description LIMIT 1;			

			IF _vePODetailId IS NOT NULL THEN
				UPDATE vePODetail
				SET
					AcknowledgementDate = _ackDate,
					EstimatedShipDate = _shipDate,
					VendorOrderNumber = _vendorOrderNumber
				WHERE vePODetailID=_vePODetailId;			
			END IF;
    
            -- Next item
			SET _itemIndex = _itemIndex + 1;

		END WHILE;    
	*/

        -- CALL PO_Acknowledgement_processor(...?, _userId, _debug, _result);

		-- Update vePODetail
		UPDATE vePODetail
		SET
			AcknowledgementDate = _ackDate,
			EstimatedShipDate = _shipDate,
			VendorOrderNumber = _vendorOrderNumber
		WHERE vePOID=_vePOId;
          
		-- ------------------------------------------
		-- Debug Level4:Iterate over line items
		-- ------------------------------------------
		IF _debug IN (4, 12, 13, 15) THEN
			SET _debugStatement = CONCAT(_debugStatement,
				", vePOID: ", IFNULL(_vePOId, 'N/A'),
				", AckDate: ", IFNULL(DATE_FORMAT(_ackDate, '%Y-%m-%d'), 'NULL'),
				", ShipDate: ", IFNULL(DATE_FORMAT(_shipDate, '%Y-%m-%d'), 'NULL'),
				", VendorOrder#: ", IFNULL(_vendorOrderNumber, 'NULL'), CHAR(10)
			);
		END IF;                
        
		-- ---------------------------------------------
        -- Final result depending on warning status
        -- ---------------------------------------------
		SET _result = JSON_OBJECT(
				'fileProcessingStatus', 'SUCCESS',
				'fileProcessingType', _documentType,
				'fileProcessingMsg', CONCAT('PO Number: ', _poNumber, ' acknowledged successfully.'),
				'fileProcessingRecordLocator', _fileProcessingRecordLocator,
				'fileProcessingNote', 'All line items were successfully updated with the provided details.'
		);
        COMMIT;
        SELECT _result AS result;
    
    ELSEIF _documentType = 'BidList' THEN
			START TRANSACTION;
			SET _result = JSON_OBJECT(
				'fileProcessingStatus', 'SUCCESS',
				'fileProcessingType', _documentType,
				'fileProcessingMsg', CONCAT('Bid List processed successfully.'),
				'fileProcessingRecordLocator', _fileProcessingRecordLocator,
				'fileProcessingNote', ''
			);
			COMMIT;
            SELECT _result AS result;
    END IF;
    -- ------------------------------------------------------------------ Flow Ends --------------------------------------------------------------------------
END$$
DELIMITER ;
-- ===============================================================END OF DOCUMENT_processor ================================================================


-- ===============================================================================================================================================================
--                                                                         JOB_bidllist_processor 
-- ===============================================================================================================================================================
-- Developer: Devendra
-- Date: 2025-07-25
-- Procedure Name: JOB_bidllist_processor
-- Description: Creates a job/project using data extracted from AI-processed BidList PDF. Inserts records into joMaster, joBidder, and Quotes tables as part of job setup.
-- ===============================================================================================================================================================
DROP PROCEDURE IF EXISTS `JOB_bidllist_processor`;

DELIMITER $$
CREATE PROCEDURE `JOB_bidllist_processor`(
    IN _action VARCHAR(225),
    IN _docJson JSON,
    IN _userId INT,
    IN _debug TINYINT
)
JOB_bidllist_processor:BEGIN
    -- ===============================================================================================================================================================
    -- CALL JOB_bidllist_processor(_action, _docJson, _userId, _debug);
    
    -- Example:
    /*
    SET @_docJson = '{
     }';
    CALL JOB_bidllist_processor("BidList", @_docJson, 5, 15);
    */
    -- Smart Debug Levels: 1 --> Main SQL query & key variables
    --                     2 --> Inside conditions
    --                     3 --> Nested Conditions
    --                     4 --> Inside loops
    --                     5 --> All debug info
    -- 1, (2,10,12,15),(3,11,13,15),(4, 12, 13, 15),(4,15)
    -- ===============================================================================================================================================================

    DECLARE _version VARCHAR(10) DEFAULT '1.0';
    DECLARE _debugStatement LONGTEXT DEFAULT '';
    DECLARE _startTime TIMESTAMP;
    DECLARE _endTime TIMESTAMP;

    DECLARE _isValid BOOLEAN DEFAULT TRUE;
    DECLARE _errorMsg TEXT;
    
    DECLARE _documentType VARCHAR(100);
    DECLARE _result JSON;
    DECLARE jobCount INT DEFAULT 0;
    DECLARE jobIndex INT DEFAULT 0;

    DECLARE jobJson LONGTEXT;
    DECLARE jobRow LONGTEXT;

    DECLARE _jobNumber VARCHAR(100);
    DECLARE _joMasterId INT;
    DECLARE _customerName VARCHAR(255);
    DECLARE _customerId INT;
    DECLARE _bidDate VARCHAR(100);
    DECLARE _jobStatus INT;
    DECLARE _salesRep INT;

    DECLARE _responseJson LONGTEXT;
    -- json array
    DECLARE newJobResponses LONGTEXT DEFAULT '[]';
    DECLARE existingJobResponses LONGTEXT DEFAULT '[]';
    DECLARE jobErrors LONGTEXT DEFAULT '[]';
    DECLARE newBidderResponses LONGTEXT DEFAULT '[]';
    DECLARE existingBidderResponses LONGTEXT DEFAULT '[]';
    DECLARE bidderErrors LONGTEXT DEFAULT '[]';
    DECLARE responseCode VARCHAR(10);
    DECLARE bidderJson LONGTEXT;
    DECLARE bidderCount, bidderIndex INT DEFAULT 0;
    DECLARE bidderRow LONGTEXT;

    DECLARE bidderName VARCHAR(255);
    DECLARE contactName VARCHAR(255);
    -- ------------------------------------------------------------------ Flow Starts --------------------------------------------------------------------------
    -- ----------------------------------------------
    -- Step 1: Input & Document Type Validation
    -- ----------------------------------------------
    SELECT NOW() INTO _startTime;

    -- Extract documentType from JSON
    SET _documentType = TRIM(JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.documentType')));
    SET jobJson = TRIM(JSON_UNQUOTE(JSON_EXTRACT(_docJson, '$.job')));
    -- ------------------------------------------
    -- Debug Level 1: Initial Request Info
    -- ------------------------------------------
    IF _debug >= 1 THEN
        SET _debugStatement = CONCAT_WS(
            CHAR(10),
            "============================================",
            "DEBUG LEVEL: MAIN ENTRY",
            "--------------------------------------------",
            "Timestamp           : ", _startTime,
            "Procedure Name      : JOB_create",
            "Action              : ", _action,
            "User ID             : ", _userId,
            "Extracted docType   : ", IFNULL(_documentType, 'NULL'),
            "============================================"
        );
    END IF;

    -- ----------------------------------------------
    -- Step 2: Document Type Routing & Validation
    -- ----------------------------------------------

    -- Case 1: Missing or empty documentType
    IF _documentType IS NULL OR _documentType = '' THEN
        SET _result = JSON_OBJECT(
            'fileProcessingStatus', 'FAILED',
            'fileProcessingType', 'Unknown',
            'fileProcessingMsg', 'We were unable to process this file. Missing or empty documentType',
            'fileProcessingRecordLocator', NULL,
            'note', 'Ensure the field "documentType" exists and is not blank.'
        );

		-- ------------------------------------------
		-- Debug Level2:documentType Validation
		-- ------------------------------------------	
        IF _debug  IN (2,10,12,15) THEN
            SET _debugStatement = CONCAT_WS(
                CHAR(10),
                _debugStatement,
                "DEBUG: documentType validation failed - documentType is NULL or empty.",
                "============================================"
            );
        END IF;

        SELECT _result AS result;
        LEAVE JOB_bidllist_processor;
    END IF;

    -- Case 2: Unsupported documentType
    IF _documentType NOT IN ('BidList') THEN
        SET _result = JSON_OBJECT(
            'fileProcessingStatus', 'FAILED',
            'fileProcessingType', _documentType,
            'fileProcessingMsg', CONCAT('We were unable to process this file. Unsupported documentType: "', _documentType, '".'),
            'fileProcessingRecordLocator', NULL,
            'note', 'Only the following types are supported: BidList.'
        );
		
        -- ------------------------------------------
		-- Debug Level2:documentType Validation
		-- ------------------------------------------
        IF _debug IN (2,10,12,15) THEN
            SET _debugStatement = CONCAT_WS(
                CHAR(10),
                _debugStatement,
                CONCAT("DEBUG: Unsupported documentType encountered: ", _documentType),
                "============================================"
            );
        END IF;

        SELECT _result AS result;
        LEAVE JOB_bidllist_processor;
    END IF;

    -- -----------------------------------
    -- Valid Types: Route accordingly
    -- -----------------------------------
    IF _documentType = 'BidList' THEN  -- poNumber
		-- ----------------------------------
        -- Begin transaction
        -- ----------------------------------
        START TRANSACTION;
          -- Loop through jobs
        SET jobCount = JSON_LENGTH(jobJson);
        SET jobIndex = 0;

        WHILE jobIndex < jobCount DO
            SET jobRow = JSON_EXTRACT(jobJson, CONCAT('$[', jobIndex, ']'));

            SET _jobNumber     = TRIM(JSON_UNQUOTE(JSON_EXTRACT(jobRow, '$.jobNumber')));
            SET _joMasterId    = NULL;
            SET _customerName  = TRIM(JSON_UNQUOTE(JSON_EXTRACT(jobRow, '$.customerName')));
            SET _customerId    = NULL;
            SET _bidDate       = TRIM(JSON_UNQUOTE(JSON_EXTRACT(jobRow, '$.bidDate')));
            SET _jobStatus     = 0;
            SET _salesRep      = NULL;

            -- Call Job upsert
            CALL JOB_bidllist_upsert(
                _jobNumber, _joMasterId, _customerName, _customerId,
                _bidDate, _jobStatus, _salesRep, _userId, _debug,
                _responseJson
            );

            -- Extract response code
            SET responseCode = JSON_UNQUOTE(JSON_EXTRACT(_responseJson, '$.code'));

            IF responseCode = '1' THEN
                SET newJobResponses = JSON_ARRAY_APPEND(IFNULL(newJobResponses, '[]'), '$', JSON_EXTRACT(_responseJson, '$'));
            ELSEIF responseCode = '0' THEN
                SET existingJobResponses = JSON_ARRAY_APPEND(IFNULL(existingJobResponses, '[]'), '$', JSON_EXTRACT(_responseJson, '$'));
            ELSE
                SET jobErrors = JSON_ARRAY_APPEND(IFNULL(jobErrors, '[]'), '$', JSON_EXTRACT(_responseJson, '$'));
            END IF;

            -- Update job number & master ID from response
            SET _joMasterId = CAST(JSON_UNQUOTE(JSON_EXTRACT(_responseJson, '$.joMasterId')) AS SIGNED);
            SET _jobNumber  = JSON_UNQUOTE(JSON_EXTRACT(_responseJson, '$.jobNumber'));

            -- Get bidders for this job
            SET bidderJson   = JSON_EXTRACT(jobRow, '$.bidders');
            SET bidderCount  = JSON_LENGTH(bidderJson);
            SET bidderIndex  = 0;

            -- Loop through bidders
            WHILE bidderIndex < bidderCount DO
                SET bidderRow   = JSON_EXTRACT(bidderJson, CONCAT('$[', bidderIndex, ']'));
                SET bidderName  = TRIM(JSON_UNQUOTE(JSON_EXTRACT(bidderRow, '$.bidder')));
                SET contactName = TRIM(JSON_UNQUOTE(JSON_EXTRACT(bidderRow, '$.contact')));

                CALL JOB_bidllist_bidder_upsert(
                    _joMasterId, _jobNumber, contactName, bidderName,
                    _userId, _debug, _responseJson
                );

                SET responseCode = JSON_UNQUOTE(JSON_EXTRACT(_responseJson, '$.code'));

                IF responseCode = '1' THEN
                    SET newBidderResponses = JSON_ARRAY_APPEND(IFNULL(newBidderResponses, '[]'), '$', JSON_EXTRACT(_responseJson, '$'));
                ELSEIF responseCode = '0' THEN
                    SET existingBidderResponses = JSON_ARRAY_APPEND(IFNULL(existingBidderResponses, '[]'), '$', JSON_EXTRACT(_responseJson, '$'));
                ELSE
                    SET bidderErrors = JSON_ARRAY_APPEND(IFNULL(bidderErrors, '[]'), '$', JSON_EXTRACT(_responseJson, '$'));
                END IF;

                SET bidderIndex = bidderIndex + 1;
            END WHILE;

            SET jobIndex = jobIndex + 1;
        END WHILE;

        SET _result = JSON_OBJECT(
            'fileProcessingStatus', 'SUCCESS',
            'fileProcessingType', _documentType,
            'fileProcessingMsg', 'Job created successfully.',
            'fileProcessingRecordLocator', NULL,
             'fileProcessingJson', JSON_OBJECT(
                'newJobs', IFNULL(newJobResponses,'[]'),
                'updatedJobs', IFNULL(existingJobResponses,'[]'),
                'errorJobs', IFNULL(jobErrors, '[]'),
                'newBidders', IFNULL(newBidderResponses, '[]'),
                'updatedBidders', IFNULL(existingBidderResponses, '[]'),
                'errorBidders', IFNULL(bidderErrors, '[]')
            ),
            'fileProcessingNote', ''
        );
    	COMMIT;
        SELECT _result AS result;
    END IF;
    -- ------------------------------------------------------------------ Flow Starts --------------------------------------------------------------------------
END$$
DELIMITER ;
-- ===============================================================END OF JOB_create ============================================================================


-- ===============================================================================================================================================================
--                                                                         JOB_bidllist_upsert 
-- ===============================================================================================================================================================
-- Developer: Devendra
-- Date: 2025-07-25
-- Procedure Name: JOB_bidllist_upsert
-- Description: Creates or updates a job/project using data extracted from an AI-processed BidList PDF. Performs upsert logic on joMaster tables as part of job setup and maintenance.
-- ===============================================================================================================================================================
DROP PROCEDURE IF EXISTS `JOB_bidllist_upsert`;


DELIMITER $$

CREATE PROCEDURE `JOB_bidllist_upsert`(
	IN _action varchar(50),
    IN _jobNumber VARCHAR(50),
    IN _jobName VARCHAR(100),
    IN _joMasterId INT,
    IN _customerName VARCHAR(255),
    IN _customerId INT,
    IN _bidDate VARCHAR(100),
    IN _jobStatus INT,
    IN _salesRep INT,
    IN _userId INT,
    IN _debug TINYINT,
    OUT _responseJson LONGTEXT
)
BEGIN
    DECLARE _result LONGTEXT DEFAULT '{}';
    DECLARE _coDivisionId INT DEFAULT 0;
    DECLARE _nextSequence INT;
    DECLARE _coTaxTerritoryID INT;
    DECLARE _locationAddress1 VARCHAR(255);
    DECLARE _locationAddress2 VARCHAR(255);
    DECLARE _locationCity VARCHAR(255);
    DECLARE _locationState VARCHAR(255);
    DECLARE _locationZip VARCHAR(255);
    DECLARE _csr INT;
    DECLARE _salesMgr INT;
    DECLARE _engr INT;
    DECLARE _promgr INT;
    DECLARE _allSalesReps TINYINT;
    DECLARE _createdByName VARCHAR(100);
	DECLARE _changedByName VARCHAR(100);
	DECLARE _code INT DEFAULT 0;
	DECLARE _status VARCHAR(255) DEFAULT 'successfully updated';
    
    IF _action = 'UPSERT' THEN
    
			-- assume _jobNumber, _joMasterId are already SET before this point
			SET _bidDate = PARSE_DATE_STRING(TRIM(_bidDate));
			-- Check if it's new
			IF _jobNumber IS NULL OR LENGTH(TRIM(_jobNumber)) = 0 OR LOWER(TRIM(_jobNumber)) = 'null' THEN
				-- New job - generate jobNumber
				SELECT Sequence + 1 INTO _nextSequence FROM sysSequence WHERE TableName = 'joMaster';
				SET _jobNumber = INT_TO_LETTER('joMaster', _nextSequence);
				UPDATE sysSequence SET Sequence = _nextSequence WHERE TableName = 'joMaster';
				SET _code = 1;
				SET _status = 'successfully created';
			ELSE
				-- Check if existing jobNumber already exists
				SELECT joMasterID INTO _joMasterId FROM joMaster WHERE jobNumber = _jobNumber LIMIT 1;

				IF _joMasterId IS NULL THEN
					-- jobNumber provided but doesn't exist in DB – treat as insert
					SET _code = 1;
					SET _status = 'successfully created';
				ELSE
					-- job exists – treat as update
					SET _code = 0;
					SET _status = 'successfully updated';
				END IF;
			END IF;

			-- Future: Add validation check here
			-- IF (_customerId IS NULL OR _bidDate IS NULL) THEN
			--     SET _code = -1;
			--     SET _status = 'Missing required fields';
			--     -- You can skip the INSERT/UPDATE logic below
			-- END IF;
			SET _jobName = REPLACE(REPLACE(IFNULL(_jobName, ''), '"', ''), "'", '');

			-- Insert or update based on _code
			IF _code = 1 THEN
				-- INSERT logic
				SELECT 
					ra.coTaxTerritoryID, ra.Address1, ra.Address2, ra.City, ra.State, ra.Zip
				INTO 
					_coTaxTerritoryID, _locationAddress1, _locationAddress2, _locationCity, _locationState, _locationZip
				FROM rxAddress ra
				LEFT JOIN coTaxTerritory COT ON ra.coTaxTerritoryID = COT.coTaxTerritoryID
				WHERE ra.rxMasterID = _customerId AND ra.IsDefault = 1;

				IF _salesRep IS NOT NULL AND LENGTH(TRIM(_salesRep)) > 0 THEN
					SELECT UserLoginId INTO @resolvedSalesRepId
					FROM tsUserLogin
					WHERE Employee0 = 1 AND inactive = 0 AND LoginName != 'admin'
					  AND FullName LIKE CONCAT('%', _salesRep, '%')
					ORDER BY FullName ASC
					LIMIT 1;

					SET _salesRep = @resolvedSalesRepId;

					SELECT cuAssignmentID1, cuAssignmentID2, cuAssignmentID3, cuAssignmentID4
					INTO _csr, _salesMgr, _engr, _promgr
					FROM cuMaster WHERE cuMasterID = _customerId;
				ELSE
					SELECT cuAssignmentID0, cuAssignmentID1, cuAssignmentID2, cuAssignmentID3, cuAssignmentID4
					INTO _salesRep, _csr, _salesMgr, _engr, _promgr
					FROM cuMaster WHERE cuMasterID = _customerId;
				END IF;
				 INSERT INTO joMaster (
							JobNumber, Description, rxCustomerID, JobStatus, BidDate,
							CreatedByID, CreatedOn,
							coDivisionID,
							coTaxTerritoryID, LocationAddress1, LocationAddress2, LocationCity, LocationState, LocationZip,
							cuAssignmentID0, cuAssignmentID1, cuAssignmentID2, cuAssignmentID3, cuAssignmentID4
						) VALUES (
							_jobNumber, _jobName, _customerId, _jobStatus, _bidDate,
							_userId, NOW(),
							_coDivisionId,
							_coTaxTerritoryID, _locationAddress1, _locationAddress2, _locationCity, _locationState, _locationZip,
							_salesRep, _csr, _salesMgr, _engr, _promgr
						);


				SET _joMasterId = LAST_INSERT_ID();
				SET _status = 'successfully created ';
			ELSEIF _code = 0 THEN
					-- Initialize update statement and field collector
					SET @update_sql = 'UPDATE joMaster SET ';
					SET @fields = '';

					-- Conditionally add fields only if value is provided (not NULL)
					IF _jobName IS NOT NULL THEN
						SET @fields = CONCAT(@fields, 'Description = ', QUOTE(_jobName), ',');
					END IF;
					
					IF _customerId IS NOT NULL THEN
						SET @fields = CONCAT(@fields, 'rxCustomerID = ', _customerId, ',');
					END IF;

					IF _jobStatus IS NOT NULL THEN
						SET @fields = CONCAT(@fields, 'JobStatus = ', _jobStatus, ',');
					END IF;

					IF _bidDate IS NOT NULL THEN
						SET @fields = CONCAT(@fields, 'BidDate = ', QUOTE(_bidDate), ',');
					END IF;

					IF _coDivisionId IS NOT NULL THEN
						SET @fields = CONCAT(@fields, 'coDivisionID = ', _coDivisionId, ',');
					END IF;

					IF _allSalesReps IS NOT NULL THEN
						SET @fields = CONCAT(@fields, 'isAllSalesRep = ', _allSalesReps, ',');
					END IF;

					-- Always update audit fields
					SET @fields = CONCAT(@fields, 'ChangedByID = ', _userId, ', ChangedOn = NOW(),');

					-- Remove trailing comma
					IF RIGHT(@fields, 1) = ',' THEN
						SET @fields = LEFT(@fields, LENGTH(@fields) - 1);
					END IF;

					-- Only run the update if at least one field is present
					IF LENGTH(@fields) > 0 THEN
						SET @update_sql = CONCAT(@update_sql, @fields, ' WHERE joMasterID = ', _joMasterId);

						PREPARE stmt FROM @update_sql;
						EXECUTE stmt;
						DEALLOCATE PREPARE stmt;
					END IF;
			END IF;
	ELSEIF _action = 'DELETE' THEN
         -- NEED TO DISCUSS ABOUT DELETION
		 DELETE FROM joMaster WHERE joMasterID = _joMasterId;
		 SET _code = 2;
		 SET _status = 'successfully deleted';
		
    END IF;
	-- Final response
	SET _responseJson = CONCAT(
	  '{',
		'"joMasterId": ', IFNULL(_joMasterId, 'null'), ',',
        '"jobName": "', _jobName, '",'
		'"jobNumber": "', IFNULL(_jobNumber, ''), '",',
		'"customerId": ', IFNULL(_customerId, 'null'), ',',
		'"customerName": "', IFNULL(_customerName, ''), '",',
		'"bidDate": "', IFNULL(DATE_FORMAT(_bidDate, '%m/%d/%Y'), ''), '",',
		'"code": ', _code, ',',
		'"status": "', _status, '"',
	  '}'
	);


END$$


DELIMITER ;

-- ===============================================================END OF JOB_bidllist_upsert ============================================================================


-- ===============================================================================================================================================================
--                                                                         JOB_bidllist_bidder_upsert 
-- ===============================================================================================================================================================
-- Developer: Devendra
-- Date: 2025-07-25
-- Procedure Name: JOB_bidllist_bidder_upsert
-- Description: Creates or updates a job/project using data extracted from an AI-processed BidList PDF. Performs upsert logic on joBidder tables as part of job setup and maintenance.
-- ===============================================================================================================================================================
DROP PROCEDURE IF EXISTS `JOB_bidllist_bidder_upsert`;

DELIMITER $$
CREATE PROCEDURE `JOB_bidllist_bidder_upsert`(
    IN _joMasterId INT,
    IN _jobNumber VARCHAR(100),
    IN _contact VARCHAR(150),
    IN _bidder VARCHAR(150),
    IN _userId INT,
    IN _debug TINYINT,
    OUT _responseJson LONGTEXT
)
JOB_bidllist_bidder_upsert:BEGIN
    -- ===============================================================================================================================================================
    -- CALL JOB_bidllist_bidder_upsert(_action, .....?, _userId, _debug);
    
    -- Example:
    /*

    CALL JOB_bidllist_bidder_upsert("INSERT_JOB",....?, 5, 15);
    */
    -- Smart Debug Levels: 1 --> Main SQL query & key variables
    --                     2 --> Inside conditions
    --                     3 --> Nested Conditions
    --                     4 --> Inside loops
    --                     5 --> All debug info
    -- 1, (2,10,12,15),(3,11,13,15),(4, 12, 13, 15),(4,15)
    -- ===============================================================================================================================================================

      DECLARE _cuMasterTypeID INT;
    DECLARE _rxMasterId INT;
    DECLARE _rxContactId INT;
    DECLARE _joBidderId INT;
    DECLARE _result TEXT;
    DECLARE _email VARCHAR(150);
    DECLARE _quoteTypeCode VARCHAR(50);
    DECLARE _contactName VARCHAR(150);
    DECLARE _code INT DEFAULT 0;
    DECLARE _status VARCHAR(255) DEFAULT '';

    -- ------------------------------------------------------------------ Flow Starts --------------------------------------------------------------------------
    -- ----------------------------------------------
    -- Step 1: Input & Document Type Validation
    -- ----------------------------------------------
    SELECT NOW() INTO _startTime;

    -- ------------------------------------------
    -- Debug Level 1: Initial Request Info
    -- ------------------------------------------
    IF _debug >= 1 THEN
        SET _debugStatement = CONCAT_WS(
            CHAR(10),
            "============================================",
            "DEBUG LEVEL: MAIN ENTRY",
            "--------------------------------------------",
            "Timestamp           : ", _startTime,
            "Procedure Name      : JOB_create",
            "Action              : ", _action,
            "User ID             : ", _userId,
            "============================================"
        );
    END IF;

    -- ----------------------------------------------
    -- Step 2: Validate action
    -- ----------------------------------------------

       -- Step 1: Lookup rxContactID and rxMasterID from contact full name
    IF _contact IS NOT NULL AND LENGTH(TRIM(_contact)) > 0 AND LOWER(TRIM(_contact)) != 'null' THEN
        SELECT rxContactID, rxMasterID
        INTO _rxContactId, _rxMasterId
        FROM rxContact
        WHERE CONCAT(FirstName, ' ', LastName) = _contact
        LIMIT 1;
    END IF;

    -- Step 2: Lookup cuMasterTypeID if rxMasterID exists
    IF _rxMasterId IS NOT NULL THEN
        SELECT cuMasterTypeID
        INTO _cuMasterTypeID
        FROM cuMaster
        WHERE cuMasterID = _rxMasterId
        LIMIT 1;
    END IF;

    -- Step 3: Check if bidder exists
    IF _joMasterId IS NOT NULL AND _rxMasterId IS NOT NULL AND _rxContactId IS NOT NULL THEN
        SELECT joBidderID
        INTO _joBidderId
        FROM joBidder
        WHERE joMasterID = _joMasterId
        AND rxMasterID = _rxMasterId
        AND rxContactID = _rxContactId
        LIMIT 1;
    END IF;
   
    -- Step 4: Add or update bidder
    IF _joMasterId IS NOT NULL AND _rxMasterId IS NOT NULL AND _rxContactId IS NOT NULL THEN
        IF _joBidderId IS NULL THEN
            -- INSERT NEW
            INSERT INTO joBidder (
                joMasterId,
                cuMasterTypeID,
                rxMasterID,
                rxContactID,
                userLoginID,
                CreatedByID,
                CreatedOn
            )
            VALUES (
                _joMasterId,
                _cuMasterTypeID,
                _rxMasterId,
                _rxContactId,
                _userId,
                _userId,
                NOW()
            );

            SET _joBidderId = LAST_INSERT_ID();

            SET _code = 1;
            SET _status = 'Successfully created';

        ELSE
            -- UPDATE EXISTING
            UPDATE joBidder
            SET
                cuMasterTypeID = IFNULL(_cuMasterTypeID, cuMasterTypeID),
                userLoginID = _userId,
                updatedByID = _userId,
                updatedOn = NOW()
            WHERE joBidderID = _joBidderId;

            SET _code = 0;
            SET _status = 'Successfully updated';
        END IF;

        -- Update joMaster changedOn
        UPDATE joMaster
        SET changedOn = NOW()
        WHERE joMasterID = _joMasterId;

    ELSE
        -- Not enough info to insert or update
        SET _code = -1;
        SET _status = 'Unable to add/update: Missing contact or bidder info';
    END IF;

    -- Step 5: Get additional info for output
    IF _joBidderId IS NOT NULL THEN
        SELECT rc.Email, cmt.Code, CONCAT(rc.FirstName, ' ', rc.LastName)
        INTO _email, _quoteTypeCode, _contactName
        FROM joBidder jb
        LEFT JOIN rxContact rc ON rc.rxContactID = jb.rxContactID
        LEFT JOIN cuMasterType cmt ON cmt.cuMasterTypeID = jb.cuMasterTypeID
        WHERE jb.joBidderID = _joBidderId;
    ELSE
        SET _email = NULL;
        SET _quoteTypeCode = NULL;
        SET _contactName = _contact;
    END IF;

    -- Step 6: Build the response JSON
    SET _result = CONCAT(
        '{',
            '"joMasterId": ', IFNULL(_joMasterId, 'null'), ',',
            '"jobNumber": ', IFNULL(CONCAT('"', _jobNumber, '"'), 'null'), ',',
            '"bidder": ', IFNULL(CONCAT('"', _bidder, '"'), 'null'), ',',
            '"contact": ', IFNULL(CONCAT('"', _contactName, '"'), 'null'), ',',
			'"code": ', _code, ',',
			'"status": "', _status, '"',
        '}'
    );

    SET _responseJson = _result;

    -- ------------------------------------------------------------------ Flow Starts --------------------------------------------------------------------------
END$$
DELIMITER ;
-- ===============================================================END OF JOB_bidllist_bidder_upsert ============================================================================