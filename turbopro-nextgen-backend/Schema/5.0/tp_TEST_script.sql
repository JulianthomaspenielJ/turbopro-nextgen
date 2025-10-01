-- ==================================================================
/*
call TEST_manager(null,null,null);
call TEST_manager('CREATE',null,null);
call TEST_manager('CLEAN-ALL',null,null);
call TEST_manager('RUN-ALL',null,3);
call TEST_manager('RESULTS',null,null);

select * from TEST_results;
select * from TEST_ids;
*/
-- ==================================================================

DROP procedure IF EXISTS `TEST_cardSetup`;

DELIMITER $$
CREATE PROCEDURE `TEST_cardSetup`(IN _action varchar(100), _batch varchar(100), _tableList varchar(255), _DEBUG tinyint )
TEST_cardSetup: BEGIN

DECLARE _strLen  int;
DECLARE _subStrLen int;
DECLARE _table varchar(100);
DECLARE _output text DEFAULT '';

-- ==================================================================
-- call TEST_cardSetup(null,null,null,null); -- HELP
-- call TEST_cardSetup('CREATE','123','BASETABLES',null); -- HELP
-- call TEST_cardSetup('DELETE','123',null,null); -- HELP
-- ==================================================================


-- select _batch,_action,_tableList;

    IF (_action = 'CREATE' ) THEN

		do_records:
			LOOP
				set _table = null;
				SET _strLen = CHAR_LENGTH(_tableList);
				set _table=TRIM(SUBSTRING_INDEX(_tableList, ',', 1));

-- select _action, _tableList, _table;
			if (LOCATE(_table,'BASETABLES')>0) THEN
 
				insert ignore into tsUserLogin (UserLoginID, LoginName) values (TEST_Id('GET','UserLoginID',null,null),'TEST_CARD');
-- select 1;
				insert ignore into coTaxTerritory (coTaxTerritoryID,TaxRate,TaxShipping,taxfreight,inActive) 
                values (TEST_Id('GET','coTaxTerritoryID',null,null),8.2500,1,1,0);
-- select 'a';
				insert ignore into rxMaster (rxMasterID,Name,SearchName,inActive,phone1) 
                values (TEST_Id('GET','rxMasterID',null,null),'TESTING-Rays equipmnet','TESTING',0,'(972) 538-1513');
				
				insert ignore into rxContact (rxContactID,rxMasterID,FirstName,LastName)
                values (TEST_Id('GET','rxContactID',null,null),TEST_Id('GET','rxMasterID',null,null),"FirstName","LastName");
-- select 'b';
				insert ignore into prMaster (prMasterID,prDepartmentID,prCategoryID,ItemCode,IsInventory, AverageCost,LastCost, Description,rxMasterIDPrimaryVendor) 
				values (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prDepartmentID',null,null),1,'STOCK_ITM',1,5,5,'1/2 Round Nut',TEST_Id('GET','rxMasterID',null,null));
-- select 'c';
				insert ignore into prMaster (prMasterID,prDepartmentID,prCategoryID,ItemCode,IsInventory, AverageCost,LastCost, Description,rxMasterIDPrimaryVendor) 
				values (TEST_Id('GET','prMasterID2',null,null),TEST_Id('GET','prDepartmentID',null,null),1,'TEST_NOT_STOCK_ITM',0,5,5,'Bolt Not Stocked',TEST_Id('GET','rxMasterID',null,null));
-- select 'd';
				insert IGNORE into prWarehouseInventory (prWarehouseInventoryID, prMasterID,prWarehouseID) 
				values (TEST_Id('GET','prFromWarehouesInventoryID',null,null),TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prFromWarehouseID',null,null));
-- select 'e';
				insert IGNORE into prWarehouseInventory (prWarehouseInventoryID, prMasterID,prWarehouseID)
				values (TEST_Id('GET','prToWarehouesInventoryID',null,null),TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prToWarehouseID',null,null));
-- select 'f';
                insert IGNORE into bin (binId, prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
				values (TEST_Id('GET','fromBinID1',null,null),TEST_Id('GET','prFromWarehouseID',null,null),TEST_Id('GET','prFromWarehouesInventoryID',null,null),TEST_Id('GET','prMasterID1',null,null),1,null,null,null,
                concat(TEST_Id('GET','prMasterID1',null,null),'-from-',TEST_Id('GET','prFromWarehouesInventoryID',null,null)),concat(TEST_Id('GET','prMasterID1',null,null),'-from-',TEST_Id('GET','prFromWarehouesInventoryID',null,null)),null,100,15,0,10,1,now());

				insert IGNORE into bin (binId, prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
				values (TEST_Id('GET','fromBinID2',null,null),TEST_Id('GET','prFromWarehouseID',null,null),TEST_Id('GET','prFromWarehouesInventoryID',null,null),TEST_Id('GET','prMasterID1',null,null),2,null,null,null,
                concat(TEST_Id('GET','prMasterID1',null,null),'-from2-',TEST_Id('GET','prFromWarehouesInventoryID',null,null)),concat(TEST_Id('GET','prMasterID1',null,null),'-from2-',TEST_Id('GET','prFromWarehouesInventoryID',null,null)),null,100,15,0,10,1,now());

-- select bin.*,TEST_Id('GET','fromBinID1',null,null),TEST_Id('GET','fromBinID2',null,null) from bin where binId in (100000,100001);
 
				insert IGNORE into bin (binId, prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
				values (TEST_Id('GET','toBinID1',null,null),TEST_Id('GET','prToWarehouseID',null,null),TEST_Id('GET','prToWarehouesInventoryID',null,null),TEST_Id('GET','prMasterID1',null,null),1,null,null,null,
                concat(TEST_Id('GET','prMasterID1',null,null),'-to-',TEST_Id('GET','prToWarehouesInventoryID',null,null)),concat(TEST_Id('GET','prMasterID1',null,null),'-to-',TEST_Id('GET','prToWarehouesInventoryID',null,null)),null,100,15,0,10,1,now());
-- select 3;
				update TEST_ids set
                coTaxTerritoryID=TEST_Id('GET','coTaxTerritoryID',null,null),prMasterID1=TEST_Id('GET','prMasterID1',null,null),prMasterID2=TEST_Id('GET','prMasterID2',null,null),
                rxMasterID=TEST_Id('GET','rxMasterID',null,null)
                where batch=_batch;
                
            END IF;

			IF (LOCATE(_table,'JOMASTER')>0) THEN

				insert IGNORE into joMaster (joMasterID,JobNumber,cuAssignmentID0)
				values (TEST_Id('GET','joMasterID',null,null),"ABC123",TEST_Id('GET','userId',null,null));
				
				insert IGNORE into joQuoteHeader (joQuoteHeaderID,joMasterID,cuMasterTypeID)
				values (TEST_Id('GET','joQuoteHeaderID',null,null),TEST_Id('GET','joMasterID',null,null),TEST_Id('GET','cuMasterTypeID',null,null));

				insert IGNORE into joQuoteDetailMstr (joQuoteHeaderID,quantity,texteditor,cost,category) 
				values (TEST_Id('GET','joQuoteHeaderID',null,null),10,"texteditor",450,"category");

				insert IGNORE into joSubmittal (joMasterID,joSubmittalID)
				values (TEST_Id('GET','joMasterID',null,null),TEST_Id('GET','joSubmittalID',null,null));

				insert IGNORE into joSubmittalDetail (joMasterID,quantity,texteditor,cost,category,description,status,statusDate,vendorname,inlineNote,joSubmittalID) 
				values (TEST_Id('GET','joMasterID',null,null),12,"texteditor",670,"category","description","APPROVED","03-12-2023","vendorName","inlineNote",TEST_Id('GET','joSubmittalID',null,null));

				insert IGNORE into joQuoteDetailMstr (joQuoteHeaderID,quantity,texteditor,cost,category) 
				values (TEST_Id('GET','joQuoteHeaderID',null,null),12,"texteditor",125,"category");
                
				update TEST_ids set
                joQuoteHeaderID = TEST_Id('GET','joQuoteHeaderID',null,null),joQuoteDetailMstrID=TEST_Id('GET','joQuoteDetailMstrID',null,null),
                rxMasterID=TEST_Id('GET','rxMasterID',null,null),joMasterID=TEST_Id('GET','joMasterID',null,null)
                where batch=_batch;
			END IF;

			IF (LOCATE(_table,'USER')>0) THEN
				insert into tsUserLogin (UserLoginID,`signature`,emailNotes,FullName) 
				values (TEST_Id('GET','userId',null,null),"signature","email_Notes","Full Name");
				
				insert into tsUser_global_notification (UserLoginID) 
				values (TEST_Id('GET','userId',null,null));

				update TEST_ids set
                UserLoginID = TEST_Id('GET','userId',null,null)
                where batch=_batch;
			END IF;

           
            IF (LOCATE(_table,'CUSO')>0) THEN

-- select _action,_table;

				insert IGNORE into cuSO (cuSOID,prFromWarehouseID,prToWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID,CreatedOn,cuAssignmentID0) 
				values (TEST_Id('GET','cuSOID1',null,null),TEST_Id('GET','prFromWarehouseID',null,null),TEST_Id('GET','prToWarehouseID',null,null),TEST_Id('GET','joReleaseID',null,null),TEST_Id('GET','SONumber',null,null),962,TEST_Id('GET','coTaxTerritoryID',null,null),TEST_Id('GET','SONumber',null,null),962,150,15,10.0,0,TEST_Id('GET','coDivisionID',null,null), TEST_Id('GET','cuTermsID',null,null),NOW(),TEST_Id('GET','userId',null,null));

				-- 1 stock
				insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
				values (TEST_Id('GET','cuSODetailID1',null,null),TEST_Id('GET','cuSOID1',null,null),TEST_Id('GET','prMasterID1',null,null),150,10,6,1);

				-- 1 non-stock
				insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
				values (TEST_Id('GET','cuSODetailID2',null,null),TEST_Id('GET','cuSOID1',null,null),TEST_Id('GET','prMasterID2',null,null),150,10,6,1);

-- select * from cuSO where cuSOID=TEST_Id('GET','cuSOID1',null,null);

				update TEST_ids set cuSOID1=TEST_Id('GET','cuSOID1',null,null) where batch=_batch;
            
			END IF;
            
			IF (LOCATE(_table,'VEPO')>0) THEN

				insert IGNORE into vePO (vePOID,PONumber,joReleaseID,rxVendorID) 
				values (TEST_Id('GET','vePOID',null,null),TEST_Id('GET','PONumber',null,null),TEST_Id('GET','joReleaseID',null,null),TEST_Id('GET','rxMasterID',null,null));

				-- need to update the vePODetail TEST_Id('GET','prMasterID2',null,null)
				insert IGNORE into vePODetail (vePODetailID, vePOID, prMasterID, Description, QuantityOrdered, UnitCost, PriceMultiplier) 
				values (TEST_Id('GET','vePODetailID1',null,null),TEST_Id('GET','vePOID1',null,null),TEST_Id('GET','prMasterID2',null,null),'Test Item',150,10,1);
                
				update TEST_ids set vePOID1=TEST_Id('GET','vePOID1',null,null) where batch=_batch;
                        
			END IF;
            
            IF (LOCATE(_table,'CUSO-MULTIPLE')>0) THEN

				insert IGNORE into cuSO (cuSOID,prFromWarehouseID,prToWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID,CreatedOn,cuAssignmentID0)
				values (TEST_Id('GET','cuSOID2',null,null),TEST_Id('GET','prFromWarehouseID',null,null),TEST_Id('GET','prToWarehouseID',null,null),TEST_Id('GET','joReleaseID',null,null),TEST_Id('GET','SONumber',null,null),962,TEST_Id('GET','coTaxTerritoryID',null,null),TEST_Id('GET','SONumber',null,null),962,150,15,10.0,0,TEST_Id('GET','coDivisionID',null,null), TEST_Id('GET','cuTermsID',null,null),NOW(),TEST_Id('GET','userId',null,null));

				-- 1 stock
				insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
				values (TEST_Id('GET','cuSODetailID3',null,null),TEST_Id('GET','cuSOID2',null,null),TEST_Id('GET','prMasterID1',null,null),150,10,6,1);

				-- 1 non-stock
				insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
				values (TEST_Id('GET','cuSODetailID4',null,null),TEST_Id('GET','cuSOID2',null,null),TEST_Id('GET','prMasterID2',null,null),150,10,6,1);

				update TEST_ids set cuSOID2=TEST_Id('GET','cuSOID2',null,null) where batch=_batch;

			END IF;

				SET _subStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_tableList, ',', 1))+2;
				SET _tableList = MID(_tableList, _subStrLen, _strLen);
				IF (_tableList = '' or _tableList is null) THEN LEAVE do_records; END IF;
						
			END LOOP do_records; 	


-- select 4;    
            
    
    ELSEIF  (_action = 'DELETE' ) THEN

		delete from tsUserLogin where UserLoginID = TEST_Id('GET','UserLoginID',null,null);

-- select 'delete base1',TEST_Id('GET','coTaxTerritoryID',null,null);
		-- DELETE BASETABLES 
		delete from coTaxTerritory where coTaxTerritoryID = TEST_Id('GET','coTaxTerritoryID',null,null);
-- select 'delete base2',TEST_Id('GET','coTaxTerritoryID',null,null);
		delete from rxMaster where rxMasterID = TEST_Id('GET','rxMasterID',null,null);
-- select 'delete base3',TEST_Id('GET','rxMasterID',null,null);
        
		delete from prWarehouseInventory where prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));
-- select 'delete base4',TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null);
		delete from bin where prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));
-- select 'delete base5',TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null);
		delete from prMaster where prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));
-- select 'delete base6',TEST_Id('GET','tpInventoryLogID','start',_batch),TEST_Id('GET','tpInventoryLogID','end',_batch);
		delete from tpInventoryLogMaster where tpInventoryLogID >= TEST_Id('GET','tpInventoryLogID','start',_batch) and tpInventoryLogID <= TEST_Id('GET','tpInventoryLogID','end',_batch) ;  -- full table scan
-- select 'delete base7',TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null);
		delete from prWHtransferDetail where prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));
		delete from prWHtransfer where prToWareHouseID = TEST_Id('GET','prToWareHouseID',null,null) or prFromWareHouseID=TEST_Id('GET','prFromWareHouseID',null,null);
		
		-- delete from cuInvoice where coTaxTerritoryID = TEST_Id('GET','coTaxTerritoryID',null,null);
		delete from cuInvoice where cuSOID = TEST_Id('GET','cuSOID',null,null);
		delete from cuInvoiceDetail where  prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));
-- select 'delete base8';
		delete from cuSO where cuSOID in (TEST_Id('GET','cuSOID1',null,null),TEST_Id('GET','cuSOID2',null,null) );
		delete from vePO where vePOID in (TEST_Id('GET','vePOID1',null,null));
		delete from veBill where vePOID in (TEST_Id('GET','veBillID1',null,null));
		delete from vePODetail where  prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));
        
		delete from cuSODetail where    cuSODetailID in (TEST_Id('GET','cuSODetailID1',null,null),TEST_Id('GET','cuSODetailID2',null,null),TEST_Id('GET','cuSODetailID3',null,null),TEST_Id('GET','cuSODetailID4',null,null) );
		delete from cuSODetailBin where cuSODetailID in (TEST_Id('GET','cuSODetailID1',null,null),TEST_Id('GET','cuSODetailID2',null,null),TEST_Id('GET','cuSODetailID3',null,null),TEST_Id('GET','cuSODetailID4',null,null) );

		delete from cuSODetailTicket where cuSOID in (TEST_Id('GET','cuSOID1',null,null),TEST_Id('GET','cuSOID2',null,null) );

		-- delete from veBill where SONumber = TEST_Id('GET','SONumber1',null,null);
		-- delete from veBillDetailID where  prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));

		-- delete from cuInvoice where coTaxTerritoryID = TEST_Id('GET','coTaxTerritoryID',null,null);
        
-- select 'delete base9',TEST_Id('GET','glTransactionId','start',_batch),TEST_Id('GET','glTransactionId','end',_batch);
        
		-- delete from cuInvoiceDetail where  prMasterID in (TEST_Id('GET','prMasterID1',null,null),TEST_Id('GET','prMasterID2',null,null));
		-- delete from cuInvoiceDetailBin where ;

		-- delete from joMaster where joMasterID=TEST_Id('GET','joMasterID',null,null);
		-- delete from joRelease where joMasterID=TEST_Id('GET','joMasterID',null,null);
		-- delete from joReleaseDetail where joMasterID=TEST_Id('GET','joMasterID',null,null);

		delete from glTransactionReversal where glTransactionId>=TEST_Id('GET','glTransactionId','start',_batch) and glTransactionID<TEST_Id('GET','glTransactionId','end',_batch); 
		delete from glLinkage where   glTransactionId>=TEST_Id('GET','glTransactionId','start',_batch) and glTransactionID<TEST_Id('GET','glTransactionId','end',_batch); 
		delete from glTransaction where glTransactionId>=TEST_Id('GET','glTransactionId','start',_batch) and glTransactionID<TEST_Id('GET','glTransactionId','end',_batch);    

		delete from joMaster where joMasterID=TEST_Id('GET','joMasterID',null,_batch);
		delete from joQuoteDetailMstr where joQuoteHeaderID=TEST_Id('GET','joQuoteHeaderID',null,_batch);
		delete from joQuoteHeader where joQuoteHeaderID=TEST_Id('GET','joQuoteHeaderID',null,_batch);
		delete from joSubmittal where joMasterID=TEST_Id('GET','joMasterID',null,_batch);
		delete from joSubmittalDetail where joMasterID=TEST_Id('GET','joMasterID',null,_batch);
		delete from tsUser_global_notification where UserLoginID=TEST_Id('GET','userId',null,_batch);
		delete from tsUserLogin where UserLoginID=TEST_Id('GET','userId',null,_batch);

-- select 'delete base9';

            if (_DEBUG=1) THEN
				-- set _output = concat(_output,'DELETING RECORDS for batch ',_batch,'\n');
				-- set _output = concat(_output,'\t',' GL= ',TEST_Id('GET','glTransactionId','start',_batch),'-', TEST_Id('GET','glTransactionId','end',_batch));
                select _action, TEST_ids.* from TEST_ids;
                -- select _output as 'DELETE';
            END IF;
 
		delete from TEST_ids where batch is not null;
 
    END IF;
        
END$$

DELIMITER ;


-- ==================================================================
-- ==================================================================
-- ==================================================================
DROP procedure IF EXISTS `TEST_manager`;

DELIMITER $$
CREATE PROCEDURE `TEST_manager`(IN _action varchar(100), _card varchar(100), _DEBUG tinyint )
TEST_manager: BEGIN

DECLARE _batch varchar(100); -- each time it is run.

DECLARE _strLen  int;
DECLARE _subStrLen int;
DECLARE _cardList varchar(5000);

SELECT DATE_FORMAT(now(), "%M-%d-%Y_%H_%i_%s") into _batch;

set _cardList = 'CARD_so_void_out_ticket,CARD_so_onhold_to_open,CARD_so_ticket_invoice_full,CARD_so_ticket_invoice_partial'; -- add all cards to this list

-- ==================================================================
-- call TEST_manager(null,null,null); -- HELP
-- call TEST_manager('DROP',null,null);
-- ==================================================================


    IF (_action = 'DROP' ) THEN
 		
        set _action = 'CREATE'; -- do nothing   

    ELSEIF (_action = 'RESULTS' ) THEN
    
		select * from TEST_results; 
    
    ELSEIF (_action = 'CLEAN-ALL' ) THEN
    
		-- code to clean up all batches removed.
		call TEST_card ('CLEANUP',null,null,_DEBUG); -- insert into test results
        truncate TEST_results;
        truncate TEST_ids;
        
    ELSEIF (_action = 'RUN-ALL' ) THEN
    
		-- override the _card
		set _card = _cardList; 
		set _action = 'RUN';
        
    ELSEIF (_action = '?' or _action is null ) THEN
    
		select '[RUN|RUN-ALL|CREATE|CLEANUP-ALL]' as Action, _cardList as 'Cards';
		select 'call TEST_manager(\'CREATE\',null,null);' as   'will recreate all supporting tables';
		select 'call TEST_manager(\'CLEAN-ALL\',null,null);'  as 'will remove any test data left behind';
		select 'call TEST_manager(\'RUN\',\'CARD_so_void_out_ticket\',1);' as   'Create SO, Then void out SO.';
        
    END IF;
    
	IF (_action = 'RUN' ) THEN
    
		-- select _batch as batchNumber; -- to show the user.
		
        insert into TEST_ids (batch) values (_batch);  -- create the record to later delete id's

		-- UPDATE DYNAMIC IDS
		update TEST_ids set starting_glTransactionId=TEST_Id('GET','glTransactionId','latest',null)+1,
            starting_tpInventoryLogID =TEST_Id('GET','tpInventoryLogID','latest',null)+1
            where batch=_batch;

        
		set _cardList = _card;
		do_records:
			LOOP
				set _card = null;
				SET _strLen = CHAR_LENGTH(_cardList);
				set _card=TRIM(SUBSTRING_INDEX(_cardList, ',', 1));
-- select _batch,_cardList,_card;
				call TEST_card ('RUN',_batch,_card,_DEBUG); -- insert into test results
				call TEST_card ('CLEANUP',_batch,_card,_DEBUG); -- insert into test results

				SET _subStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_cardList, ',', 1))+2;
				SET _cardList = MID(_cardList, _subStrLen, _strLen);
				IF (_cardList = '' or _cardList is null) THEN LEAVE do_records; END IF;
						
			END LOOP do_records; 	
 
 		-- UPDATE DYNAMIC IDS
		update TEST_ids set ending_glTransactionId=TEST_Id('GET','glTransactionId','latest',null)+1,
            ending_tpInventoryLogID =TEST_Id('GET','tpInventoryLogID','latest',null)+1
            where batch=_batch;

 
    END IF;


	if (_action='CREATE' or _action='DROP') THEN
		DROP TABLE IF EXISTS TEST_results;
        
        CREATE TABLE IF NOT EXISTS TEST_results (
        testId INT NOT NULL AUTO_INCREMENT,
        batch varchar(100) NOT NULL,
        card varchar(100) NOT NULL,
		passFail varchar(20),
		startTime time,
		endTIme time,
		results text,
        PRIMARY KEY (`testId`))
		ENGINE = InnoDB AUTO_INCREMENT=5000 DEFAULT CHARSET=utf8mb4;

		-- Might be a good place to call the delete function in case there are left over ids;
		DROP TABLE IF EXISTS TEST_ids;
        
        CREATE TABLE IF NOT EXISTS TEST_ids (
			testId INT NOT NULL AUTO_INCREMENT,
            batch varchar(100),
		  `starting_glTransactionId` int(11) DEFAULT NULL,
		  `ending_glTransactionId` int(11) DEFAULT NULL,
		  `starting_tpInventoryLogID` int(11) DEFAULT NULL,
		  `ending_tpInventoryLogID` int(11) DEFAULT NULL,
		   coTaxTerritoryID int(11) DEFAULT NULL,
		  `prMasterID1` int(11) DEFAULT NULL,
		  `prMasterID2` int(11) DEFAULT NULL,
		  `joMasterID` int(11) DEFAULT NULL,
		  `joReleaseID` int(11) DEFAULT NULL,
		  `joSubmittalID` int(11) DEFAULT NULL,
		  `vePOID1` int(11) DEFAULT NULL,
		  `vePOID2` int(11) DEFAULT NULL,
		  `cuSOID1` int(11) DEFAULT NULL,
		  `cuSOID2` int(11) DEFAULT NULL,
		  `cuInvoiceID1` int(11) DEFAULT NULL,
		  `cuInvoiceID2` int(11) DEFAULT NULL,
		  `cuInvoiceID3` int(11) DEFAULT NULL,
		  `cuInvoiceID4` int(11) DEFAULT NULL,
		  `cuInvoiceID5` int(11) DEFAULT NULL,
		  `cuInvoiceID6` int(11) DEFAULT NULL,
		  `cuInvoiceID7` int(11) DEFAULT NULL,
		  `veBillID1` int(11) DEFAULT NULL,
		  `veBillID2` int(11) DEFAULT NULL,
		  `veBillID3` int(11) DEFAULT NULL,
		  `veBillID4` int(11) DEFAULT NULL,
		  `veBillID5` int(11) DEFAULT NULL,
		  `veBillID6` int(11) DEFAULT NULL,
		  `rxMasterID` int(11) DEFAULT NULL,
		  `rxContactID` int(11) DEFAULT NULL,
		  `joQuoteHeaderID` int(11) DEFAULT NULL,
		  `joQuoteDetailMstrID` int(11) DEFAULT NULL,
		  `UserLoginID` int(11) DEFAULT NULL,
		  `cuMasterTypeID` int(11) DEFAULT NULL,
		  PRIMARY KEY (`testId`))
		ENGINE = InnoDB AUTO_INCREMENT=5000 DEFAULT CHARSET=utf8mb4;

		select _action, 'TEST tables created';
        
	END IF;

END$$

DELIMITER ;


-- ==================================================================
-- ==================================================================
-- ==================================================================
DROP FUNCTION IF EXISTS `TEST_Id`;

DELIMITER //
CREATE  FUNCTION TEST_Id(_action varchar(20),_idType varchar(100), _hint varchar(100), _batch varchar(100))
 RETURNS int(11)
    DETERMINISTIC
BEGIN

DECLARE _formatted int(11) default -1;

DECLARE _userId INT DEFAULT 10000000;
DECLARE _UserLoginID INT DEFAULT 1; -- used for areas where a user needs to be specific

DECLARE _coTaxTerritoryID INT DEFAULT 1;
DECLARE _prDepartmentID INT DEFAULT 1;
DECLARE _coDivisionID INT DEFAULT 3;
DECLARE _cuTermsID INT DEFAULT 1;
DECLARE _rxMasterID INT DEFAULT 1;
DECLARE _rxContactID INT DEFAULT 10000000;

DECLARE _prMasterID1 INT DEFAULT 10; -- stock
DECLARE _prMasterID2 INT DEFAULT 11; -- nonstock
DECLARE _prFromWarehouseID INT DEFAULT 1;
DECLARE _prToWarehouseID INT DEFAULT 2;
DECLARE _prFromWarehouesInventoryID INT DEFAULT 1;
DECLARE _prToWarehouesInventoryID INT DEFAULT 2;
DECLARE _fromBinID1 INT DEFAULT 100000;
DECLARE _fromBinID2 INT DEFAULT 100001;
DECLARE _toBinID1 INT DEFAULT 100002;

DECLARE _SONumber varchar(10) DEFAULT '12345';
DECLARE _PONumber varchar(10) DEFAULT '6789';

DECLARE _vePOID1 INT DEFAULT 1;

DECLARE _veBillID2 INT DEFAULT 2;
DECLARE _veBillID2 INT DEFAULT 2;
DECLARE _veBillID3 INT DEFAULT 3;
DECLARE _veBillID4 INT DEFAULT 4;
DECLARE _veBillID5 INT DEFAULT 5;
DECLARE _veBillID6 INT DEFAULT 6;

DECLARE _cuSOID1 INT DEFAULT 1;
DECLARE _cuSOID2 INT DEFAULT 2;
DECLARE _cuSODetailID1 INT DEFAULT 1;
DECLARE _cuSODetailID2 INT DEFAULT 2;
DECLARE _cuSODetailID3 INT DEFAULT 3;
DECLARE _cuSODetailID4 INT DEFAULT 4;

DECLARE _joMasterID INT DEFAULT 1;
DECLARE _joSubmittalID INT DEFAULT 100000;
DECLARE _joQuoteDetailMstrID INT ;
DECLARE _joQuoteHeaderID INT DEFAULT 10;
DECLARE _cuMasterTypeID INT DEFAULT 1; -- MC
DECLARE _joReleaseID INT DEFAULT 1;

DECLARE _cuInvoiceID1 INT DEFAULT -1;
DECLARE _cuInvoiceID2 INT DEFAULT -1;
DECLARE _cuInvoiceID3 INT DEFAULT -1;
DECLARE _cuInvoiceID4 INT DEFAULT -1;
DECLARE _cuInvoiceID5 INT DEFAULT -1;
DECLARE _cuInvoiceID6 INT DEFAULT -1;


-- might use _batch to pull an id, or hint to pull a type of id.

if (_action ='SET') THEN

	if (_idType='cuInvoiceID1' and _hint='cuSOID1') THEN
		select max(cuInvoiceID) into _cuInvoiceID1 from cuInvoice where cuSOID = _cuSOID1;
		update TEST_ids set cuInvoiceID1=_cuInvoiceID1 where batch=_batch;
        set _formatted = _cuInvoiceID1;

	elseif (_idType='joQuoteDetailMstrID') THEN
		select max(joQuoteDetailMstrID) into _joQuoteDetailMstrID from joQuoteDetailMstr;
		update TEST_ids set joQuoteDetailMstrID=_joQuoteDetailMstrID where batch=_batch;
        set _formatted = _joQuoteDetailMstrID;
	END IF;

ELSE -- GET




-- LATEST
if (_idType='glTransactionId' and _hint='latest') THEN
	select max(glTransactionId) into _formatted from glTransaction;
elseif (_idType='veBillID' and _hint='latest') THEN
	select max(veBillID) into _formatted from veBill;
elseif (_idType='cuSODetailBinID' and _hint='latest') THEN
	select max(cuSODetailBinID) into _formatted from cuSODetailBin;
elseif (_idType='cuInvoiceDetailBinID' and _hint='latest') THEN
	select max(cuInvoiceDetailBinID) into _formatted from cuInvoiceDetailBin;
elseif (_idType='tpInventoryLogID' and _hint='latest') THEN
	select max(tpInventoryLogID) into _formatted from tpInventoryLogMaster;

-- BATCH
elseif (_idType='glTransactionId' and _hint='start' and _batch is not null) THEN
	select ifnull(starting_glTransactionId,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='glTransactionId' and _hint='end' and _batch is not null) THEN
	select ifnull(ending_glTransactionId,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='tpInventoryLogID' and _hint='start' and _batch is not null) THEN
	select ifnull(starting_tpInventoryLogID,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='tpInventoryLogID' and _hint='end' and _batch is not null) THEN
	select ifnull(ending_tpInventoryLogID,-1) into _formatted from TEST_ids where batch=_batch;

elseif (_idType='cuInvoiceID1' and _batch is not null) THEN
	select ifnull(cuInvoiceID1,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='cuInvoiceID2' and _batch is not null) THEN
	select ifnull(cuInvoiceID2,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='cuInvoiceID3' and _batch is not null) THEN
	select ifnull(cuInvoiceID3,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='cuInvoiceID4' and _batch is not null) THEN
	select ifnull(cuInvoiceID4,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='cuInvoiceID5' and _batch is not null) THEN
	select ifnull(cuInvoiceID5,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='cuInvoiceID6' and _batch is not null) THEN
	select ifnull(cuInvoiceID6,-1) into _formatted from TEST_ids where batch=_batch;

elseif (_idType='veBillID1' and _batch is not null) THEN
	select ifnull(veBillID1,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='veBillID2' and _batch is not null) THEN
	select ifnull(veBillID2,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='veBillID3' and _batch is not null) THEN
	select ifnull(veBillID3,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='veBillID4' and _batch is not null) THEN
	select ifnull(veBillID4,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='veBillID5' and _batch is not null) THEN
	select ifnull(veBillID5,-1) into _formatted from TEST_ids where batch=_batch;
elseif (_idType='veBillID6' and _batch is not null) THEN
	select ifnull(veBillID6,-1) into _formatted from TEST_ids where batch=_batch;

    
elseif (_idType='joQuoteDetailMstrID' and _batch is not null) THEN
	select ifnull(joQuoteDetailMstrID,-1) into _formatted from TEST_ids where batch=_batch;

-- OTHER
elseif (_idType='toBinID1') THEN
	set _formatted = _toBinID1;
elseif (_idType='fromBinID2') THEN
	set _formatted = _fromBinID2;
elseif (_idType='fromBinID1') THEN
	set _formatted = _fromBinID1;
elseif (_idType='prToWarehouesInventoryID') THEN
	set _formatted = _prToWarehouesInventoryID;
elseif (_idType='coTaxTerritoryID') THEN
	set _formatted = _coTaxTerritoryID;
elseif (_idType='vePOID1') THEN
	set _formatted = _vePOID1;
elseif (_idType='prFromWarehouesInventoryID') THEN
	set _formatted = _prFromWarehouesInventoryID;
elseif (_idType='prToWarehouseID') THEN
	set _formatted = _prToWarehouseID;
elseif (_idType='prFromWarehouseID') THEN
	set _formatted = _prFromWarehouseID;
elseif (_idType='prMasterID2') THEN
	set _formatted = _prMasterID2;
elseif (_idType='prMasterID1') THEN
	set _formatted = _prMasterID1;
elseif (_idType='rxMasterID') THEN
	set _formatted = _rxMasterID;
elseif (_idType='rxContactID') THEN
	set _formatted = _rxContactID;
elseif (_idType='cuTermsID') THEN
	set _formatted = _cuTermsID;
elseif (_idType='coDivisionID') THEN
	set _formatted = _coDivisionID;
elseif (_idType='prDepartmentID') THEN
	set _formatted = _prDepartmentID;
elseif (_idType='joMasterID') THEN
	set _formatted = _joMasterID;
elseif (_idType='joReleaseID') THEN
	set _formatted = _joReleaseID;
elseif (_idType='cuSOID1') THEN
	set _formatted = _cuSOID1;
elseif (_idType='SONumber') THEN
	set _formatted = _SONumber;
elseif (_idType='cuSOID2') THEN
	set _formatted = _cuSOID2;
elseif (_idType='cuSODetailID1') THEN
	set _formatted = _cuSODetailID1;
elseif (_idType='cuSODetailID2') THEN
	set _formatted = _cuSODetailID2;    
elseif (_idType='cuSODetailID3') THEN
	set _formatted = _cuSODetailID3;    
elseif (_idType='cuSODetailID4') THEN
	set _formatted = _cuSODetailID4;    
elseif (_idType='userId') THEN
	set _formatted = _userId;
elseif (_idType='UserLoginID') THEN
	set _formatted = _UserLoginID;
elseif (_idType='reference') THEN
	set _formatted = '777777777';  
elseif (_idType='reason') THEN
	set _formatted = '555555555';      
elseif (_idType='PONumber') THEN
	set _formatted = _PONumber;
elseif (_idType='joQuoteHeaderID') THEN
	set _formatted = _joQuoteHeaderID;
elseif (_idType='cuMasterTypeID') THEN
	set _formatted = _cuMasterTypeID;
END IF;

END IF; -- end GET


RETURN _formatted;

END //
DELIMITER ;

DROP FUNCTION IF EXISTS `TEST_print`;

DELIMITER //
CREATE  FUNCTION TEST_print(_action varchar(20), _batch varchar(100))
 RETURNS varchar(1000)
    DETERMINISTIC
BEGIN

DECLARE _formatted varchar(1000) default '';
DECLARE _starting_glTransactionId int(11);

select starting_glTransactionId into _starting_glTransactionId from TEST_ids where batch=_batch;

select GROUP_CONCAT('\t\t',g.glTransactionId,'\t',g.journalId,'\t',g.coAccountNumber,'\t', a.Description,'\t',g.debit,'\t', g.credit,'\t',g.transactionDate
		-- ,'\t',l.status,'\t', ifnull(l.veBillID,''), ifnull(l.vePODetailID,''), ifnull(l.veReceiveDetailID,''),'\t',g.reference,'\t', g.transactionDesc,'\t',g.coAccountId,'\t', g.enteredBy,'\t',l.glLinkageId
        ,'\n') 
        into _formatted
		from glTransaction g
		left join glLinkage l on (g.glTransactionId = l.glTransactionId)
		left join coAccount a on (a.coAccountID = g.coAccountID)
		where g.glTransactionId>=_starting_glTransactionId
        order by g.glTransactionId desc;

RETURN _formatted;

END //


DELIMITER ;



DROP FUNCTION IF EXISTS `TEST_output`;

DELIMITER //
CREATE  FUNCTION TEST_output(_action varchar(20), _indent varchar(10), _title varchar(25), _output varchar(5000),_batch varchar(100))
 RETURNS varchar(5000)
    DETERMINISTIC
BEGIN

DECLARE _formatted varchar(5000) default '';

-- set _formatted=_output;

	if (_action='Bin') THEN
			set _formatted = concat(_formatted,_indent, _title,' Bin=',(select concat(binId,' binSequence=', binSequence,' InventoryOnHand=', InventoryOnHand, ' InventoryAllocated=',InventoryAllocated,' ') from bin where binId=TEST_Id('GET','fromBinID1',null,null)),'\n');
			set _formatted = concat(_formatted,_indent, _title,' Bin=',(select concat(binId,' binSequence=', binSequence,' InventoryOnHand=', InventoryOnHand, ' InventoryAllocated=',InventoryAllocated,' ') from bin where binId=TEST_Id('GET','fromBinID2',null,null)),'\n');
	elseif (_action='cuSO') THEN
			set _formatted = concat(_formatted,_indent, _title,' cuSO=',(select concat(cuSOID,' TransactionStatus=', TransactionStatus,' Freight=',Freight) from cuSO where cuSOID=TEST_Id('GET','cuSOID1',null,null)),'\n');
			set _formatted = concat(_formatted,_indent, _title,' cuSODetail=',(select concat(cuSODetailID,' prMasterID=',prMasterID,' QuantityOrdered=', QuantityOrdered,' UnitCost=',UnitCost,' Taxable=',Taxable) from cuSODetail where cuSODetailID=TEST_Id('GET','cuSODetailID1',null,null)),'\n');
			set _formatted = concat(_formatted,_indent, _title,' cuSODetail=',(select concat(cuSODetailID,' prMasterID=',prMasterID,' QuantityOrdered=', QuantityOrdered,' UnitCost=',UnitCost,' Taxable=',Taxable) from cuSODetail where cuSODetailID=TEST_Id('GET','cuSODetailID2',null,null)),'\n');
	elseif (_action='cuSODetail') THEN
			set _formatted = concat(_formatted,_indent, _title,' cuSODetail=',(select concat(cuSODetailID,' prMasterID=',prMasterID,' QuantityOrdered=', QuantityOrdered,' UnitCost=',UnitCost,' Taxable=',Taxable) from cuSODetail where cuSODetailID=TEST_Id('GET','cuSODetailID1',null,null)),'\n');
			set _formatted = concat(_formatted,_indent, _title,' cuSODetail=',(select concat(cuSODetailID,' prMasterID=',prMasterID,' QuantityOrdered=', QuantityOrdered,' UnitCost=',UnitCost,' Taxable=',Taxable) from cuSODetail where cuSODetailID=TEST_Id('GET','cuSODetailID2',null,null)),'\n');
	elseif (_action='cuSODetailBin') THEN
            set _formatted = concat(_formatted,_indent, _title,' cuSODetailBin=',(select concat(cuSODetailBinID,' cuSODetailID=',cuSODetailID ,' binId=',binId,' allocated =',allocated,' QuantityBilled=',QuantityBilled) from cuSODetailBin where cuSODetailID=TEST_Id('GET','cuSODetailID1',null,null) and binId=TEST_Id('GET','fromBinID1',null,null)),'\n');
            set _formatted = concat(_formatted,_indent, _title,' cuSODetailBin=',(select concat(cuSODetailBinID,' cuSODetailID=',cuSODetailID ,' binId=',binId,' allocated =',allocated,' QuantityBilled=',QuantityBilled) from cuSODetailBin where cuSODetailID=TEST_Id('GET','cuSODetailID1',null,null) and binId=TEST_Id('GET','fromBinID2',null,null)),'\n');
	elseif (_action="cuSODetailTicket") THEN
			set _formatted = concat(_formatted,(select GROUP_CONCAT(_indent, _title,' cuSODetailTicket ',pickTicketId ,' ticketStatus=',ticketStatus,' toPick =',toPick,' ordered=',ordered,' backOrdered=',backOrdered,' inventoryOHAtTime=',inventoryOHAtTime,' binId=',binId,'\n') 
				from cuSODetailTicket where cuSOID=TEST_Id('GET','cuSOID1',null,null) or cuSOID=TEST_Id('GET','cuSOID2',null,null)));
	elseif (_action='cuInvoice') THEN
            set _formatted = concat(_formatted,(select GROUP_CONCAT(_indent, _title,' cuInvoiceID=', cuInvoiceID,' joReleaseDetailID=',joReleaseDetailID,'  cuSOID=',cuSOID,' InvoiceAmount=',InvoiceAmount,' Freight=',Freight,' TaxTotal=',TaxTotal,' Subtotal=',Subtotal,'\n') 
				from cuInvoice where cuInvoiceID =  TEST_Id('GET','cuInvoiceID1',null,_batch) or cuInvoiceID =  TEST_Id('GET','cuInvoiceID2',null,_batch) ));
	elseif (_action='cuInvoiceDetail') THEN
            set _formatted = concat(_formatted,(select GROUP_CONCAT(_indent, _title,' cuInvoiceID=', cuInvoiceID,' cuInvoiceDetailID=',cuInvoiceDetailID,'  cuSODetailID=',cuSODetailID,'QuantityBilled =',QuantityBilled,' UnitCost=',UnitCost,' PriceMultiplier=',PriceMultiplier,' Taxable=',Taxable,'\n') 
				from cuInvoiceDetail where cuInvoiceID=TEST_Id('GET','cuInvoiceID1',null,_batch) or cuInvoiceID=TEST_Id('GET','cuInvoiceID2',null,_batch)));
	elseif (_action='joSubmittal') THEN
             SET _formatted = CONCAT(_formatted, (SELECT GROUP_CONCAT(_indent, _title,' joSubmittal: joMasterID=', s.joMasterID,' joSubmittalID=',s.joSubmittalID,'  joSubmittalDetailID=',d.joSubmittalDetailID
				,' totalCost =',s.totalCost,' description=',d.description,' quantity=',d.quantity,' cost=',d.cost,' status=',d.status,'\n') 
				FROM joSubmittalDetail d LEFT JOIN joSubmittal s ON (s.joSubmittalID = d.joSubmittalID) 
                WHERE s.joMasterID=TEST_Id('GET','joMasterID',null,null) LIMIT 10));

	elseif (_action='joQuoteHeader') THEN

             SET _formatted = CONCAT(_formatted, (SELECT GROUP_CONCAT(_indent, _title, ' joQuoteHeader: joMasterID=', s.joMasterID,' joQuoteHeaderID=',s.joQuoteHeaderID,'  joQuoteDetailMstrID=',d.joQuoteDetailMstrID
            ,' cuMasterTypeID=',s.cuMasterTypeID,' quantity=',d.quantity,' cost=',d.cost,'\n') 
				FROM joQuoteDetailMstr d LEFT JOIN joQuoteHeader s ON (s.joQuoteHeaderID = d.joQuoteHeaderID) 
                WHERE s.joMasterID=TEST_Id('GET','joMasterID',null,null) LIMIT 10));

	elseif (_action='signature_quotenote') THEN
             SET _formatted = CONCAT(_formatted, (select GROUP_CONCAT(_indent, _title,' signature= ', signature,' emailNotes= ',emailNotes,'  UserLoginID= ',UserLoginID,'\n') 
				from tsUserLogin where UserLoginID =  TEST_Id('GET','userId',null,_batch)));

	elseif (_action='batch_email') THEN
             SET _formatted = CONCAT(_formatted, (select GROUP_CONCAT(_indent, _title,' toAddress= ', toEmailId,' subject= ',`subject`,' filename= ', `filename`,' content= ', content,'  UserLoginID= ',UserLoginID,'\n') 
				from tsUser_global_notification where UserLoginID =  TEST_Id('GET','userId',null,_batch)));

	elseif (_action='batch_email_setup') THEN
             SET _formatted = CONCAT(_formatted, (select GROUP_CONCAT(_indent, _title,'  UserLoginID= ',UserLoginID,'\n') 
				from tsUser_global_notification where UserLoginID =  TEST_Id('GET','userId',null,_batch)));
	
	elseif (_action='search_engine') THEN
             SET _formatted = CONCAT(_formatted, (select GROUP_CONCAT(_indent, _title,(SELECT CONCAT(' joMasterID= ', joMasterID, ' jobNumber= ', JobNumber, '\n') FROM joMaster WHERE joMasterID = 1),
			 (SELECT CONCAT('\t\trxMasterID= ', rxMasterID, ' phone1= ', phone1, '\n') FROM rxMaster WHERE rxMasterID = 1),(SELECT CONCAT('\t\tprMasterID= ', prMasterID,' ItemCode= ',ItemCode,' Description= ',`Description`, '\n') FROM prMaster WHERE prMasterID = 10)
			 ,(SELECT CONCAT('\t\tcuSOID= ', cuSOID,' SONumber= ',SONumber,' Tag= ',Tag, '\n') FROM cuSO WHERE cuSOID = 1),(SELECT CONCAT('\t\tvePOID= ', vePOID,' PONumber= ',PONumber, '\n') FROM vePO WHERE vePOID = 3))));
                
	elseif (_action='glTransaction') THEN

		select GROUP_CONCAT(_indent, _title,' GL=',g.glTransactionId,'\t',g.journalId,'\t',g.coAccountNumber,'\t', a.Description,'\t',g.debit,'\t', g.credit,'\t',g.transactionDate,'\t', ifnull(l.veBillID,'')
				-- ,'\t',l.status,'\t', ifnull(l.veBillID,''), ifnull(l.vePODetailID,''), ifnull(l.veReceiveDetailID,''),'\t',g.reference,'\t', g.transactionDesc,'\t',g.coAccountId,'\t', g.enteredBy,'\t',l.glLinkageId
				,'\n') 
				into _formatted
				from glTransaction g
				left join glLinkage l on (g.glTransactionId = l.glTransactionId)
				left join coAccount a on (a.coAccountID = g.coAccountID)
				where g.glTransactionId>=TEST_Id('GET','glTransactionId','start',_batch)
				order by g.glTransactionId desc;
        
    end if;

RETURN _formatted;

END //
