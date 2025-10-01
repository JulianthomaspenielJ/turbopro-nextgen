-- ============================================== PROCEDURES

-- AUDIT_inventory
-- AUDIT_updateProductAllocations
-- INV_updateInventoryOH
-- INV_updateOH
-- INV_createPickTicket_v2
-- INVOICE_updateInvoiceDetail
-- INVOICE_updateInvoiceDetail_binplan
-- SO_updateSO  -- new
-- INV_releaseSOAllocation -- new

-- ==============================================



DROP procedure IF EXISTS `AUDIT_inventory`;

-- https://docs.google.com/spreadsheets/d/1vUwR0BC35ZNjUIxymGSRo2o_mWVOj_NBvfO1CUHxQeA/edit#gid=1245640104     "Test cards link"
-- ============== TESTING THIS SHOULD BE THE LAST PROCEDURE

-- ==============================================

-- call AUDIT_inventory('TEST-CREATE',null,null,null,10,25,30,100,50);
-- call AUDIT_inventory('TEST-PRFIX',null,null,null,10,25,30,100,50);
-- call AUDIT_inventory('TEST-REMOVE',null,null,null,null,null,null,null,null);
-- TBD: call AUDIT_inventory('TEST-SOFIX',null,null,null,10,25,30,100,50);

-- call AUDIT_inventory('SOFIX',1,null,null,null,null,null,null,null);
-- call AUDIT_inventory('DISPLAY',1,490,null,null,null,null,null,null);
-- call AUDIT_inventory('PRFIX-DISPLAY',1,63,null,null,null,null,null,null);


DROP procedure IF EXISTS `AUDIT_inventory`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `AUDIT_inventory`(
	IN _action varchar(100),
    IN _userID INT,
    IN _prMasterID INT,
    IN _SOID INT,
    IN _testbin1OH INT,
    IN _testbin2OH INT,
    IN _testbin3OH INT,
    IN _testSO1 INT,
    IN _testSO2 INT
)
AUDIT_inventory : BEGIN

DECLARE _version varchar(10) DEFAULT '1.1'; -- added _DEBUG

DECLARE _DEBUG TINYINT DEFAULT 0;

-- DECLARE _userID INT;
DECLARE _coTaxTerritoryID INT;
DECLARE _prMasterID1 INT;
DECLARE _prMasterID2 INT DEFAULT -1;
DECLARE _coDivisionID INT;
DECLARE _cuTermsID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _prToWarehouseID INT;

DECLARE _fromBinID1 INT;
DECLARE _fromBinID2 INT;
DECLARE _fromBinID3 INT;
DECLARE _toBinID INT;

DECLARE _prFromWarehouesInventoryID INT;
DECLARE _prToWarehouesInventoryID INT;
DECLARE _found INT;

DECLARE _message varchar(500);
DECLARE _startingGlTransactionID INT;
DECLARE _startingTransferID INT;
DECLARE _qty INT;
DECLARE _theCall varchar(500);
DECLARE _prTransferDetailID INT;
DECLARE _transfered int;

DECLARE _vePOID1 INT;
DECLARE _vePODetailID1 INT;
DECLARE _cuSOID1 INT;
DECLARE _cuSOID2 INT;
DECLARE _cuSODetailID1 INT  DEFAULT -1;
DECLARE _cuSODetailID2 INT DEFAULT -1;
DECLARE _cuSODetailBinID1 INT;
DECLARE _cuSODetailBinID2 INT;
DECLARE _cuSODetailBinID3 INT;
DECLARE _cuInvoiceDetailBinID1 INT; -- same values used for cuInvoice and cuInvoiceDetail
DECLARE _cuInvoiceDetailBinID2 INT; -- same values used for cuInvoice and cuInvoiceDetail
DECLARE _cuInvoiceDetailID1 INT;
DECLARE _cuInvoiceDetailID2 INT;
DECLARE _prDepartmentID INT;
DECLARE _joReleaseID INT;
DECLARE _freight decimal(19,4);
DECLARE _result1 INT;

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _prMasterIDs TEXT;


    set _prDepartmentID=1;
    set _coTaxTerritoryID = 10;
	set _prMasterID1 = 10;
	set _prMasterID2 = 11;    
    set _prFromWarehouseID=1;
	set _prFromWarehouesInventoryID=10;
    set _prToWarehouseID=2;
	set _prToWarehouesInventoryID=11;
	set _vePOID1 = 10;
	set _vePODetailID1 = 10;
	set _cuSOID1 = 10;
	set _cuSOID2 = 11;
    set _coDivisionID =3;
	set _cuTermsID =1;
	set _freight=20;
	set _cuSODetailID1 = 10;
	set _cuSODetailID2 = 11;
	set _joReleaseID=1;
	set _transfered = 5;
    set _cuInvoiceDetailBinID1 =1;
    set _cuInvoiceDetailBinID2 =2;    
    -- INV_updateInventoryLog
    -- prWHtransfer
    -- prWHtransferDetail

if (LOCATE ('TEST-CREATE',_action)=1 or LOCATE ('TEST-REMOVE',_action)=1) THEN

	set _userID = 1;

    delete from coTaxTerritory where _coTaxTerritoryID=_coTaxTerritoryID;
    delete from prMaster where prMasterID=_prMasterID1;
    delete from prMaster where prMasterID=_prMasterID2;
    delete from prWarehouseInventory where prWarehouseInventoryID=_prFromWarehouesInventoryID;
    delete from prWarehouseInventory where prWarehouseInventoryID=_prToWarehouesInventoryID;
	delete from bin where prMasterID = _prMasterID1;
	delete from bin where prMasterID = _prMasterID2;
	delete from vePO where vePOID=_vePOID1;
	delete from vePODetail where vePODetailID=_vePODetailID1;
	delete from cuSO where cuSOID=_cuSOID1;
	delete from cuSODetail where cuSODetailID=_cuSODetailID1;
	delete from cuSODetailBin where cuSODetailID=_cuSODetailID1;
	delete from cuSO where cuSOID=_cuSOID2;
	delete from cuSODetail where cuSODetailID=_cuSODetailID2;
	delete from cuSODetailBin where cuSODetailID=_cuSODetailID2;
    
    delete from cuInvoiceDetailBin where cuInvoiceDetailBinID in (_cuInvoiceDetailBinID1,_cuInvoiceDetailBinID2);
    delete from cuInvoiceDetail where cuInvoiceDetailID in (_cuInvoiceDetailBinID1,_cuInvoiceDetailBinID2);
    delete from cuInvoice where cuInvoiceID in (_cuInvoiceDetailBinID1,_cuInvoiceDetailBinID2);
    -- delete from glLinkage where glTransactionId in (select glTransactionId from glTransaction where enteredBy= _userID);
	-- delete from glTransaction where enteredBy= _userID;	
    delete from prWHtransferDetail where prTransferID in (select prTransferID from prWHtransfer where createdById= _userID);
	delete from prWHtransfer where createdById= _userID;	
    delete from tpInventoryLogMaster where userId  =_userID;
    delete from tpInventoryLog where userId = _userID;
    
    select _action, 'TABLES REMOVED!';
    
	set _prMasterID = null; -- to assist with the display working for the test case

END IF;

if (LOCATE ('TEST-PRFIX',_action)=1) THEN

	set _userID = 1; -- force to 1

	if (_testbin1OH is not null ) THEN
	SELECT binId into _fromBinID1 from bin  where prMasterID=_prMasterID1 and prWarehouseID=_prFromWarehouseID and binSequence=1;
	SELECT binId into _fromBinID2 from bin  where prMasterID=_prMasterID1 and prWarehouseID=_prFromWarehouseID and binSequence=2;
	SELECT binId into _fromBinID3 from bin  where prMasterID=_prMasterID1 and prWarehouseID=_prFromWarehouseID and binSequence=3;

	update bin set InventoryOnHand = _testbin1OH where binId =_fromBinID1;
	update bin set InventoryOnHand = _testbin2OH where binId =_fromBinID2;
	update bin set InventoryOnHand = _testbin3OH where binId =_fromBinID3;
    

	update cuSODetail set QuantityOrdered=_testSO1 where cuSODetailID=_cuSODetailID1;
	update cuSODetail set QuantityOrdered=_testSO2 where cuSODetailID=_cuSODetailID2;
	END IF;

	select concat('prMaster(ABC-Product) Bin1=',_testbin1OH,',  Bin2=',_testbin2OH,',  Bin3=',_testbin3OH,',  SO1','(TEST-SONumber1)','=',_testSO1,',  SO2','(TEST-SONumber2)','=',_testSO2,',  Transfer(TEST-TRANSFER)=',_transfered, ' Invoices: TEST-Invoice1 and TEST-Invoice2') as arguments;

	call AUDIT_updateProductAllocations (null,_prMasterID1,_userID,null);  
    
    set _prMasterID = null; -- to assist with the display working for the test case
            
END IF;

if (LOCATE ('TEST-CREATE',_action)=1) THEN

 	set _userID = 1;
   
	select concat('prMaster(ABC-Product) Bin1=',_testbin1OH,',  Bin2=',_testbin2OH,',  Bin3=',_testbin3OH,',  SO1','(TEST-SONumber1)','=',_testSO1,',  SO2','(TEST-SONumber2)','=',_testSO2,',  Transfer(TEST-TRANSFER)=',_transfered, ' Invoices: TEST-Invoice1 and TEST-Invoice2') as arguments;

	insert into coTaxTerritory (coTaxTerritoryID,TaxRate,TaxShipping,taxfreight,inActive) values 
    (_coTaxTerritoryID,8.2500,1,1,0);
    
	insert into prMaster (prMasterID,prDepartmentID,prCategoryID,ItemCode,IsInventory, AverageCost,Description) values 
    (_prMasterID1,_prDepartmentID,1,'ABC-Product',1,5,'1/2 Round Nut');
	
    insert into prMaster (prMasterID,prDepartmentID,prCategoryID,ItemCode,IsInventory, AverageCost,Description) values 
    (_prMasterID2,_prDepartmentID,1,'TEST_NON_STOCK_ITM',0,5,'Bolt Not Stocked');
	
	insert IGNORE into prWarehouseInventory (prWarehouseInventoryID, prMasterID,prWarehouseID) values 
    (_prFromWarehouesInventoryID,_prMasterID1,_prFromWarehouseID);
	insert IGNORE into prWarehouseInventory (prWarehouseInventoryID, prMasterID,prWarehouseID) values 
    (_prToWarehouesInventoryID,_prMasterID1,_prToWarehouseID);

	insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_prFromWarehouseID,_prFromWarehouesInventoryID,_prMasterID1,1,null,null,null,concat('Bin1-',_prMasterID1,'-from-',_prFromWarehouesInventoryID),concat('Bin1-',_prMasterID1,'-from-',_prFromWarehouesInventoryID),null,_testbin1OH,0,0,10,1,now());
	SELECT LAST_INSERT_ID() INTO _fromBinID1;

	insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_prFromWarehouseID,_prFromWarehouesInventoryID,_prMasterID1,2,null,null,null,concat('Bin2-',_prMasterID1,'-from-',_prFromWarehouesInventoryID),concat('Bin2-',_prMasterID1,'-from-',_prFromWarehouesInventoryID),null,_testbin2OH,0,0,10,1,now());
	SELECT LAST_INSERT_ID() INTO _fromBinID2;

	insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_prFromWarehouseID,_prFromWarehouesInventoryID,_prMasterID1,3,null,null,null,concat('Bin3-',_prMasterID1,'-from-',_prFromWarehouesInventoryID),concat('Bin3-',_prMasterID1,'-from-',_prFromWarehouesInventoryID),null,_testbin3OH,0,0,10,1,now());
	SELECT LAST_INSERT_ID() INTO _fromBinID3;

	insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_prToWarehouseID,_prToWarehouesInventoryID,_prMasterID1,1,null,null,null,concat('Bin1-',_prMasterID1,'-to-',_prToWarehouesInventoryID),concat('Bin1-',_prMasterID1,'-to',_prToWarehouesInventoryID),null,_testbin1OH,0,0,10,1,now());
	SELECT LAST_INSERT_ID() INTO _toBinID;
	
    insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID1,1,_prFromWarehouseID,3,'TEST-PONumber1');

	insert IGNORE into vePODetail (vePODetailID, vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID1,_vePOID1,_prMasterID1,200,10,'Vulcan Mind Weld');

	insert IGNORE into cuSO (cuSOID,prFromWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID) 
	values (_cuSOID1,_prFromWarehouseID,_joReleaseID,'TEST-SONumber1',962,_coTaxTerritoryID,'TEST-SONumber1',962,_testSO1,15,10.0,_freight,_coDivisionID, _cuTermsID);

	insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSODetailID1,_cuSOID1,_prMasterID1,_testSO1,10,6,1);

	insert IGNORE into cuSO (cuSOID,prFromWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID) 
	values (_cuSOID2,_prFromWarehouseID,_joReleaseID,'TEST-SONumber2',962,_coTaxTerritoryID,'TEST-SONumber2',962,_testSO2,15,10.0,_freight,_coDivisionID, _cuTermsID);

	insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSODetailID2,_cuSOID2,_prMasterID1,_testSO2,10,6,1);

	-- not creating the invoices for this.. just testing QuantityBilled moving.

	insert IGNORE into cuInvoice(cuInvoiceID,InvoiceNumber,InvoiceDate) values (_cuInvoiceDetailBinID1,'TEST-Invoice1',now());
    
	insert IGNORE into cuInvoiceDetail (cuInvoiceDetailID, cuInvoiceID, cuSODetailID, prMasterID)
	values (_cuInvoiceDetailBinID1, _cuInvoiceDetailBinID1, _cuSODetailID1, _prMasterID1);

	insert IGNORE into cuInvoice(cuInvoiceID,InvoiceNumber,InvoiceDate) values (_cuInvoiceDetailBinID2,'TEST-Invoice2',now());
    
	insert IGNORE into cuInvoiceDetail (cuInvoiceDetailID, cuInvoiceID, cuSODetailID, prMasterID)
	values (_cuInvoiceDetailBinID2, _cuInvoiceDetailBinID2, _cuSODetailID1, _prMasterID1);

	insert IGNORE into cuInvoiceDetailBin (cuInvoiceDetailBinID, cuInvoiceDetailID, cuSODetailBinID, binId, QuantityBilled, txState)
	values (_cuInvoiceDetailBinID1, _cuInvoiceDetailBinID1, _cuInvoiceDetailBinID1, _fromBinID1, 1, 'I');

	insert IGNORE into cuInvoiceDetailBin (cuInvoiceDetailBinID, cuInvoiceDetailID, cuSODetailBinID, binId, QuantityBilled, txState)
	values (_cuInvoiceDetailBinID2, _cuInvoiceDetailBinID2, _cuInvoiceDetailBinID2, _fromBinID1, 2, 'I');
    
	call INV_updateInventoryOH('TRANSFER',now(),now(),_fromBinID1,null,'TEST-TRANSFER', 'TEST-TRANSFER' ,_transfered,null,null,_prToWarehouseID,_userId);

    set _prMasterID = null; -- to assist with the display working for the test case

/*    
    -- select *  from coTaxTerritory where _coTaxTerritoryID=_coTaxTerritoryID;
    select *  from prMaster where prMasterID in (_prMasterID1,_prMasterID2);
    select *  from prWarehouseInventory where prWarehouseInventoryID in (_prFromWarehouesInventoryID,_prToWarehouesInventoryID);
	select *  from bin where prMasterID in (_prMasterID1,_prMasterID2);
	-- select *  from vePO where vePOID=_vePOID1;
	select *  from vePODetail where vePODetailID=_vePODetailID1;
	-- select *  from cuSO where cuSOID in (_cuSOID1,_cuSOID2);
	select *  from cuSODetail where cuSODetailID in (_cuSODetailID1,_cuSODetailID2);
	select *  from cuSODetailBin where cuSODetailID in (_cuSODetailID1,_cuSODetailID2);
    select *  from cuInvoiceDetailBin where cuInvoiceDetailBinID in (_cuInvoiceDetailBinID1,_cuInvoiceDetailBinID2);

    -- select *  from glLinkage where glTransactionId in (select glTransactionId from glTransaction where enteredBy= _userID);
	-- select *  from glTransaction where enteredBy= _userID;	
	-- select *  from prWHtransfer where createdById= _userID;	
    select *  from prWHtransferDetail where prTransferID in (select prTransferID from prWHtransfer where createdById= _userID);
    select * from  tpInventoryLogMaster where userId  =_userID;
    select *  from tpInventoryLog where userId = _userID;
*/
	
END IF;


if (LOCATE ('PRFIX',_action)>0) THEN

	if (LOCATE ('DEBUG',_action)>0) THEN 
        set _DEBUG = 3; 
    END IF;
    
	call AUDIT_updateProductAllocations (null,_prMasterID,_userID,_DEBUG); 
    
END IF;

if (LOCATE ('SOFIX',_action)>0) THEN

	if (LOCATE ('DEBUG',_action)>0) THEN set _DEBUG = 3; END IF;

        select group_concat(distinct(prMasterID)) into _prMasterIDs from cuSODetail where cuSOID=_SOID; 

        IF (_prMasterIDs IS NOT NULL) THEN
        
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_prMasterIDs);
				set _prMasterID=SUBSTRING_INDEX(_prMasterIDs, ',', 1);

	call AUDIT_updateProductAllocations (null,_prMasterID,_userID,_DEBUG);  
		
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_prMasterIDs, ',', 1))+2;
				SET _prMasterIDs = MID(_prMasterIDs, SubStrLen, strLen);
				IF (_prMasterIDs = '' or _prMasterIDs is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;        
			
            END IF;

END IF;


if (LOCATE ('DISPLAY',_action)>0 or LOCATE ('TEST-',_action)=1) THEN

	if (_prMasterID is not null) THEN
		select *  from bin where prMasterID = _prMasterID;    
		select *  from cuSODetail where prMasterID = _prMasterID order by cuSODetailID DESC limit 10;
		select *  from cuSODetailBin where binId in (select binId  from bin where prMasterID = _prMasterID) order by cuSODetailBinID DESC;
		select prMasterID, InventoryOnHand, InventoryAllocated, InventoryOnOrder  from prMaster where prMasterID in (_prMasterID);
		select prWarehouseInventoryID,prMasterID,prWarehouseID, InventoryOnHand, InventoryAllocated, InventoryOnOrder  from prWarehouseInventory where prMasterID in (_prMasterID);
		-- select *  from  tpInventoryLogMaster where prMasterID  =_prMasterID order by tpInventoryLogID DESC;
    ELSEif (_SOID is not null) THEN
		select *,_SOID  from bin where prMasterID in (select distinct(prMasterID) from cuSODetail where cuSOID=_SOID);    
		select *,_SOID  from cuSODetailBin where binId in (select binId  from bin where prMasterID in (select distinct(prMasterID) from cuSODetail where cuSOID=_SOID)) order by cuSODetailBinID DESC;
		select prMasterID, InventoryOnHand, InventoryAllocated, InventoryOnOrder  from prMaster where prMasterID in (select distinct(prMasterID) from cuSODetail where cuSOID=_SOID);
		select prWarehouseInventoryID,prMasterID,prWarehouseID, InventoryOnHand, InventoryAllocated, InventoryOnOrder  from prWarehouseInventory where prMasterID in (select distinct(prMasterID) from cuSODetail where cuSOID=_SOID);
    ELSE

	select *  from bin where prMasterID in (_prMasterID1,_prMasterID2);
    select *  from cuInvoiceDetailBin where cuInvoiceDetailBinID in (_cuInvoiceDetailBinID1,_cuInvoiceDetailBinID2);
	select *  from cuSODetail where cuSODetailID in (_cuSODetailID1,_cuSODetailID2);
	select *  from cuSODetailBin where cuSODetailID in (_cuSODetailID1,_cuSODetailID2);
    select prMasterID, InventoryOnHand, InventoryAllocated, InventoryOnOrder  from prMaster where prMasterID in (_prMasterID1,_prMasterID2);
    select prWarehouseInventoryID,prMasterID,prWarehouseID, InventoryOnHand, InventoryAllocated, InventoryOnOrder  from prWarehouseInventory where prWarehouseInventoryID in (_prFromWarehouesInventoryID,_prToWarehouesInventoryID);
    -- select *  from  tpInventoryLogMaster where userId  =_userID;
    -- select *  from tpInventoryLog where userId = _userID;
    -- select *  from  tpInventoryLogMaster where prMasterID  =_prMasterID1;
    -- select *  from tpInventoryLog where prMasterID  =_prMasterID1;

	END IF;

END IF;





END$$

DELIMITER ;


-- ==============================================

-- 	call AUDIT_updateProductAllocations (null,281,1,1);  


DROP procedure IF EXISTS `AUDIT_updateProductAllocations`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `AUDIT_updateProductAllocations`(
	IN _action varchar(100),
    IN _prMasterID INT,
    IN _userID INT,
    IN _DEBUG TINYINT
)
AUDIT_updateProductAllocations : BEGIN

DECLARE _version varchar(10) DEFAULT '1.1'; -- debug statements added

DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE strLen2    INT DEFAULT 0;
DECLARE SubStrLen2 INT DEFAULT 0;
DECLARE strLen3    INT DEFAULT 0;
DECLARE SubStrLen3 INT DEFAULT 0;
DECLARE _prWarehouseID INT;
DECLARE _prWarehouseIDs VARCHAR(255);
DECLARE _binId int;
DECLARE _binIdS VARCHAR(2000);
DECLARE _cuSODetailIDs VARCHAR(2000);
DECLARE _cuSODetailID INT;
DECLARE _cuSODetailBinIDs VARCHAR(2000);
DECLARE _cuSODetailBinID INT;
DECLARE _cuInvoiceDetailBinIDs varchar(2000);
DECLARE _cuInvoiceDetailBinID INT;
DECLARE _allocated int;
DECLARE _transfered int;
DECLARE _availableToBill INT;
DECLARE _QuantityBilledLeft INT;
DECLARE _QuantityBilled INT;
DECLARE _prOH INT;
DECLARE _prIA INT;
DECLARE _prIOO INT;
DECLARE _whOH INT;
DECLARE _whIA INT;
DECLARE _whIOO INT;

	IF (_prMasterID is null) THEN LEAVE AUDIT_updateProductAllocations; END IF;

	if (_userID is null) THEN
		set _userID = 1;
    END IF;


   -- 1. Clear out allocated for this product

		-- clear out allocateds, get ready for an update.
		update bin set InventoryAllocated = 0, inTransfer=null where prMasterID= _prMasterID;
        /*
		update prMaster set InventoryAllocated=0, LastUpdatedTime=now() where prMasterID=_prMasterID;
		update prWarehouseInventory set InventoryAllocated=0, LastUpdatedTime=now() where prMasterID=_prMasterID;
		*/
        
		-- select concat('update bin,prMaster,prWarehouseInventory allocated=0 where prMasterID = ',_prMasterID);
	

	-- 2. remove SODetailBins for this product
        -- select group_concat(binId) into _binIds from bin where prMasterID=_prMasterID; 

		-- if (_DEBUG =1) THEN select '1',_binIds,_cuSODetailIDs; END IF;
		delete from cuSODetailBin where binId in (select binId from bin where prMasterID=_prMasterID);

		if (_DEBUG in (3)) THEN select 'AUDIT_updateProductAllocations 1. remove all cuSODetailBin and set bin.InventoryAllocated=0 for prMaster=', _prMasterID; END IF;

/*        
        
        IF (_binIds IS NOT NULL) THEN

		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _binId=SUBSTRING_INDEX(_binIds, ',', 1);
		
				select ifnull(sum(allocated),0) into _allocated from cuSODetailBin where binId = _binId and allocated <> QuantityBilled;                
                call INV_updateInventoryLog('INSERT',_binId,'SO',null,null,null,_allocated,0,'Fix SO Allocations',_userID,null,null);
				-- select concat('REMOVE SODetailbins - call INV_updateInventoryLog where binId = ',_binId, ' and allocated=' , _allocated);

				-- QUESTION is it okay to delete where allocated=QuantityBilled
                -- QUESTION what is the meaning of QuantityBilled (partial) - may need to resore QuantityBilled
				-- select 'REMOVE',c.*, concat('SODetailBins  delete from cuSODetailBin where binId = ',_binId) from cuSODetailBin c where binId = _binId;
				delete from cuSODetailBin where binId = _binId;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;        
			
            END IF;
*/


	-- 2. Handle transfers
		
        select group_concat(distinct(fromBinId)) into _binIds from  prWHtransferDetail d
			left join prWHtransfer t on (d.prTransferID=t.prTransferID)
			where d.prMasterID = _prMasterID and d.fromBinId is not null and d.toBinId is null
            and t.reasonCode='Transfer' and d.ReceivedDate is null ;

 		if (_DEBUG in (1,2,3)) THEN select 'AUDIT_updateProductAllocations: 2. Handle transfers for binIds=', _binIds; END IF;

		 if (_binIds is not null) THEN
         
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _binId=SUBSTRING_INDEX(_binIds, ',', 1);
		
			-- select ifnull(sum(QuantityTransfered),0) into _transfered  
			-- from prWHtransferDetail where fromBinId = _binId and toBinId is null;

			select ifnull(sum(d.QuantityTransfered),0) 
            into _transfered  
			from prWHtransferDetail d
            left join prWHtransfer t on (d.prTransferID=t.prTransferID)
            where fromBinId = _binId and toBinId is null and t.reasonCode = 'Transfer' ;    
            
			-- select '2-inside',_binId, _transfered;

			if (_transfered>0) THEN
				call INV_updateOH('ADJUST',_binId,null,_transfered,null,_userID);
				if (_DEBUG in (1,2,3)) THEN select 'AUDIT_updateProductAllocations: transfer found from binId=', _binId, ' for ', _transfered; END IF;
			END IF;
            
			-- select '2-after INV_updateOH',_binId, _transfered;
			
            -- QUESTION: this seems broken in the INV_updateInvnetoryOH  line 678
                     -- select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
					 -- update bin set inTransfer = inTransfer+_quantityChanged where binId = _virtualbinId;
			
            -- below seems correct
            -- update bin set inTransfer = (inTransfer+_transfered) where binId = _binId;
            
			-- select concat('TRANSFER - update bin set inTransfer = ',_transfered ,' where binId =', _binId);
            
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  

			END IF;
            

 
	-- 3. Handle rewritteing the cuSODetailBin

        select group_concat(cuSODetailID) into _cuSODetailIDs from cuSODetail d
			left join cuSO s on (s.cuSOID = d.cuSOID)
			where d.prMasterID=_prMasterID and d.QuantityOrdered <> d.QuantityBilled
            and s.TransactionStatus=1; 


 		if (_DEBUG in (3)) THEN select 'AUDIT_updateProductAllocations 3. Handle rewritteing the cuSODetailBin for _cuSODetailIDs=', _cuSODetailIDs,' call INV_updateInventoryOH(SALESORDER)'; END IF;
        
        IF (_cuSODetailIDs is not null) THEN
        
         do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_cuSODetailIDs);
				set _cuSODetailID=SUBSTRING_INDEX(_cuSODetailIDs, ',', 1);

				call INV_updateInventoryOH('SALESORDER',null,null,null,null,null,null,null,null,_cuSODetailID,null,_userID);
    
				-- select sum(QuantityBilled),binId into _QuantityBilled,_binId from cuInvoiceDetailBin where cuSODetailID=_cuSODetailID;
	    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_cuSODetailIDs, ',', 1))+2;
				SET _cuSODetailIDs = MID(_cuSODetailIDs, SubStrLen, strLen);
				IF (_cuSODetailIDs = '' or _cuSODetailIDs is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;        

			END IF;

	-- 4. Handle QuantityBilled

/*  Maybe it is not necessary to do this

        select group_concat(cuSODetailID) into _cuSODetailIDs from cuSODetail d
			left join cuSO s on (s.cuSOID = d.cuSOID)
			where d.prMasterID=_prMasterID and d.QuantityOrdered <> d.QuantityBilled
            and s.TransactionStatus=1; 

 		if (_DEBUG =1) THEN select 'AUDIT_updateProductAllocations 4. Handle QuantityBilled for _cuSODetailIDs=', _cuSODetailIDs; END IF;

		-- if (_DEBUG =1) THEN select '4', _cuSODetailIDs; END IF;
         
         -- select 'do_SODetailID', _cuSODetailIDs;
         
         IF (_cuSODetailIDs is not null) THEN
         
         do_SODetailID:
		   LOOP
				SET strLen = CHAR_LENGTH(_cuSODetailIDs);
				set _cuSODetailID=SUBSTRING_INDEX(_cuSODetailIDs, ',', 1);

				select group_concat(b.cuInvoiceDetailBinID) 
                into _cuInvoiceDetailBinIDs 
                from cuInvoiceDetailBin b 
                left join cuInvoiceDetail d on (d.cuInvoiceDetailID = b.cuInvoiceDetailID)
					 where d.cuSODetailID=_cuSODetailID; 


         -- select 'do_cuInvoiceDetailBinID', _cuInvoiceDetailBinIDs,_cuSODetailID;
 		if (_DEBUG =1) THEN select 'AUDIT_updateProductAllocations: Found previous billing for _cuInvoiceDetailBinIDs=', _cuInvoiceDetailBinIDs, d.* from cuInvoiceDetailBin d where d.cuInvoiceDetailBinID in 
				(select b.cuInvoiceDetailBinID 
                from cuInvoiceDetailBin b 
                left join cuInvoiceDetail d on (d.cuInvoiceDetailID = b.cuInvoiceDetailID)
					 where d.cuSODetailID=_cuSODetailID); 
		END IF;

		 if (_cuInvoiceDetailBinIDs is not null) THEN
         
				 do_cuInvoiceDetailBinID:
				   LOOP
						SET strLen2 = CHAR_LENGTH(_cuInvoiceDetailBinIDs);
						set _cuInvoiceDetailBinID=SUBSTRING_INDEX(_cuInvoiceDetailBinIDs, ',', 1);
				
						select QuantityBilled,binId into _QuantityBilled,_binId from cuInvoiceDetailBin 
						where cuInvoiceDetailBinID = _cuInvoiceDetailBinID;
						
                        set _QuantityBilledLeft = _QuantityBilled;
                        
						select group_concat(cuSODetailBinID) into _cuSODetailBinIDs from cuSODetailBin 
								where cuSODetailID = _cuSODetailID and allocated> QuantityBilled ; 

	
         -- select 'do_cuSODetailBin', _cuSODetailID,_cuInvoiceDetailBinIDs,_cuInvoiceDetailBinID,_cuSODetailBinIDs,_QuantityBilled,_QuantityBilledLeft,_binId;

							 do_cuSODetailBin:
							   LOOP
									SET strLen3 = CHAR_LENGTH(_cuSODetailBinIDs);
									set _cuSODetailBinID=SUBSTRING_INDEX(_cuSODetailBinIDs, ',', 1);
							

									select (allocated - QuantityBilled) into _availableToBill from cuSODetailBin 
                                    where cuSODetailBinID=_cuSODetailBinID;

        -- select 'inside do_cuSODetailBin', _cuSODetailBinIDs,_cuSODetailBinID,_availableToBill,_QuantityBilledLeft;
									
									if ( _availableToBill>0 and _QuantityBilledLeft>0) THEN

										if (_availableToBill >= _QuantityBilledLeft) THEN
											
                                            update cuSODetailBin set QuantityBilled=QuantityBilled+_QuantityBilledLeft 
                                            where cuSODetailBinID=_cuSODetailBinID;
											
                                            update cuInvoiceDetailBin set cuSODetailBinID= _cuSODetailBinID 
                                            where cuInvoiceDetailBinID=_cuInvoiceDetailBinID;

											leave do_cuSODetailBin;
											
										ELSEIF (_availableToBill < _QuantityBilledLeft) THEN
										
											set _QuantityBilledLeft = (_QuantityBilledLeft - _availableToBill); 
											
                                            update cuSODetailBin set QuantityBilled=QuantityBilled+_QuantityBilledLeft 
                                            where cuSODetailBinID=_cuSODetailBinID;
											
                                            update cuInvoiceDetailBin set cuSODetailBinID= _cuSODetailBinID 
                                            where cuInvoiceDetailBinID=_cuInvoiceDetailBinID;
										
										END IF;
										
									END IF;

							
									SET SubStrLen3 = CHAR_LENGTH(SUBSTRING_INDEX(_cuSODetailBinIDs, ',', 1))+2;
									SET _cuSODetailBinIDs = MID(_cuSODetailBinIDs, SubStrLen3, strLen3);
									IF (_cuSODetailBinIDs = '' or _cuSODetailBinIDs is null) THEN
									   LEAVE do_cuSODetailBin;
									END IF;
										
								END LOOP do_cuSODetailBin;   

                
						SET SubStrLen2 = CHAR_LENGTH(SUBSTRING_INDEX(_cuInvoiceDetailBinIDs, ',', 1))+2;
						SET _cuInvoiceDetailBinIDs = MID(_cuInvoiceDetailBinIDs, SubStrLen2, strLen2);
						IF (_cuInvoiceDetailBinIDs = '' or _cuInvoiceDetailBinIDs is null) THEN
						   LEAVE do_cuInvoiceDetailBinID;
						END IF;
							
					END LOOP do_cuInvoiceDetailBinID;        

 		if (_DEBUG =1) THEN 
        select 'AUDIT_updateProductAllocations update cuSODetailBin _cuInvoiceDetailBinIDs=', _cuInvoiceDetailBinIDs, d.* from cuInvoiceDetailBin d where d.cuInvoiceDetailBinID in 
        (select cuSODetailBinID  from cuSODetailBin where cuSODetailID = _cuSODetailID ); 
        END IF;

					END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_cuSODetailIDs, ',', 1))+2;
				SET _cuSODetailIDs = MID(_cuSODetailIDs, SubStrLen, strLen);
				IF (_cuSODetailIDs = '' or _cuSODetailIDs is null) THEN
				   LEAVE do_SODetailID;
				END IF;
                    
			END LOOP do_SODetailID;        
         
			END IF;
*/
         
	-- 5. Clean up the bins based on QuantityBilled - including print tickets
/*
        select group_concat(binId) into _binIds from bin where prMasterID=_prMasterID; 

		-- if (_DEBUG =1) THEN select '5', _binIds; END IF;

		IF (_binIds is not null) THEN
        
         do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _binId=SUBSTRING_INDEX(_binIds, ',', 1);

				select ifnull(sum(QuantityBilled),0) into _QuantityBilled  from cuSODetailBin where binId=_binId and
					allocated <> QuantityBilled;
                    
				if (_QuantityBilled <> 0) THEN
					-- don't like this.. should call updateOH
					update bin set InventoryAllocated = (InventoryAllocated-_QuantityBilled) where binId=_binId;
                END IF;
                
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;        

			END IF;
*/

            
	-- 6. update the inventory rollups.

    select sum(InventoryOnHand),sum(InventoryAllocated),sum(InventoryOnOrder) into _prOH,_prIA,_prIOO from bin where prMasterID = _prMasterID;
    
    update prMaster set InventoryOnHand = _prOH,InventoryAllocated=_prIA,InventoryOnOrder=_prIOO, LastUpdatedTime=now() where prMasterID=_prMasterID;

	if (_DEBUG in (3)) THEN select 'AUDIT_updateProductAllocations update prMaster ',_prMasterID,_prOH,_prIA,_prIOO,p.* from prMaster p where prMasterID=_prMasterID; END IF;
	

	select group_concat( distinct(prWarehouseID) ) into _prWarehouseIDs from bin where prMasterID=_prMasterID; 

		-- select _prWarehouseIDs;
        
        IF (_prWarehouseIDs is not null) THEN
        
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_prWarehouseIDs);
				set _prWarehouseID=SUBSTRING_INDEX(_prWarehouseIDs, ',', 1);
		
				select sum(InventoryOnHand),sum(InventoryAllocated),sum(InventoryOnOrder) 
                into _whOH,_whIA,_whIOO from bin where prMasterID = _prMasterID and prWarehouseID=_prWarehouseID;
			   
				-- select _prMasterID1,_prWarehouseID,_prWarehouseIDs;
				update prWarehouseInventory set InventoryOnHand = _whOH,InventoryAllocated=_whIA,InventoryOnOrder=_whIOO, LastUpdatedTime=now() 
                where prMasterID = _prMasterID and prWarehouseID=_prWarehouseID;

	if (_DEBUG in (3)) THEN select 'AUDIT_updateProductAllocations update prWarehouseInventory ',_prMasterID,_prWarehouseID,_whOH,_whIA,_whIOO; END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_prWarehouseIDs, ',', 1))+2;
				SET _prWarehouseIDs = MID(_prWarehouseIDs, SubStrLen, strLen);
				IF (_prWarehouseIDs = '' or _prWarehouseIDs is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
    
			END IF;

	-- 7 MARK ANY TICKETS WHERE ORDERED=BILLED
	update  cuSODetailTicket t
	left join cuSODetail d on (d.cuSODetailID = t.cuSODetailId )
    left join cuSO s on (s.cuSOID = d.cuSOID)
	 set t.ticketStatus=2  
	where t.ticketStatus=1 and d.QuantityOrdered = d.QuantityBilled and s.TransactionStatus=2;

-- if (_DEBUG in (1,2,3)) THEN select 'AUDIT_updateProductAllocations prMaster=', _prMasterID; END IF;

END$$

DELIMITER ;



-- ====================================================
-- MODIFICATIONS TO EXISTING PROCEDURES
-- ====================================================

-- call INV_updateInventoryOH('SALESORDER',null,null,null,null,null,null,null,null,438518,null,1);


DROP procedure IF EXISTS `INV_updateInventoryOH`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_updateInventoryOH`(

	IN _action  varchar(25),
    IN _transferDate DATE,
    IN _estimatedDate DATE,
    IN _fromBinID INT,
    IN _toBinID INT,
	IN _reference varchar(100),
    IN _resonCode varchar(25),
    IN _quantityChanged decimal(19,4),
    IN _prTransferDetailID INT,
    IN _lineItemDetailID INT,
    IN _prToWarehouseID INT,
    IN _changedByID INT	
)
INV_updateInventoryOH: BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.2'; -- added  and binSequence=1 limit 1

DECLARE _DEBUG TINYINT DEFAULT 0;


DECLARE _prMasterID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _prFromWarehouseInventoryID INT;

DECLARE _prToWarehouseInventoryID INT;
DECLARE _prOH INT;
DECLARE _prIA INT;
DECLARE _prIOO INT;
DECLARE _whOH INT;
DECLARE _whIA INT;
DECLARE _whIOO INT;
DECLARE _lastOH INT;
DECLARE _lastAllocated INT;
DECLARE _lastAvailable INT;
DECLARE _description varchar(1000);
DECLARE _itemcode varchar(500);
DECLARE _inventoryCost  decimal(19,4);
DECLARE _prTransferId INT;

DECLARE _transNumber INT;
DECLARE _journalID varchar(25);
DECLARE _glAmount   decimal(19,4);
DECLARE _glDescription varchar(500);
DECLARE _found INT;
DECLARE _aBinId INT;
DECLARE _acuSODetailBinId INT;
DECLARE _binIds varchar(255);
DECLARE _InActive INT;
DECLARE _IsInventory INT;

DECLARE _outBinId INT(11);
DECLARE _sumInventory decimal(19,4);
DECLARE _vePODetailBinID INT;
DECLARE _cuSODetailID INT;
DECLARE _cuSODetailBinID INT;
DECLARE _vePOID INT;
DECLARE _rxMasterID INT;
DECLARE _veReceiveID INT;
DECLARE _VendorNumber varchar(25);
DECLARE _veReceiveDetailID INT;
DECLARE _veReceiveDetailBinID INT;
DECLARE _quantityBilled decimal(19,4);
DECLARE _quantityReceived decimal(19,4);
DECLARE _quantityOrdered decimal(19,4);
DECLARE _unitCost decimal(19,4);
DECLARE _PONumber varchar(100);
DECLARE _newReceivedItems decimal(19,4);
DECLARE _availabetoReceive decimal(19,4);
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _totalOrdered INT;
DECLARE _totalReceived INT;
DECLARE _refRelatedNo varchar(25);
DECLARE _PriceMultiplier decimal(19,4);
DECLARE _virtualbinId INT;
DECLARE _TransactionStatus INT;


     if ( _changedByID is null) THEN 
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updateInventoryOH:_changedByID missing';
		LEAVE INV_updateInventoryOH; 
	 END IF;


if (_action='SALESORDER') THEN

	-- NOTE:  _quantityChanged will be overwritte if given.  it was not necessary to pass.
    
	set _journalID='SO';
	SET _transNumber = 1;

	select d.prMasterID, s.prFromWarehouseID, p.InActive, p.IsInventory,d.QuantityOrdered,d.QuantityBilled,s.TransactionStatus 
    into _prMasterID, _prFromWarehouseID, _InActive,_IsInventory, _quantityChanged,_quantityBilled,_TransactionStatus 
	from cuSODetail d 
	left join cuSO s on (s.cuSOID = d.cuSOID)
	left join prMaster p on (d.prMasterID = p.prMasterID)
	 where d.cuSODetailID=_lineItemDetailID;
 
 -- 	case 'Void' setStatus = -1; 
-- 	case 'Quote' setStatus = -2; -- same as onhold
-- 	case 'OnHold' setStatus = 0; -- quote are the same thing
-- 	case 'Open' setStatus = 1;
-- 	case 'Book as Job' setStatus = 3;
-- 	case 'Import to Job' setStatus = 4;
-- 	case 'Closed' setStatus = 2;

	-- void or closed cuSO
	if (_TransactionStatus=0 or  _TransactionStatus=-2 or  _TransactionStatus=-1 or _TransactionStatus=2) THEN
		IF (_DEBUG in (1,2,3)) THEN 
			select 'INV_updateInventoryOH VOID or CLOSED - EXITITNG '; 
 		END IF;
        LEAVE INV_updateInventoryOH; 
    END IF;

 
	IF (_DEBUG in (2,3)) THEN 
		select 'INV_updateInventoryOH START ', _action, _lineItemDetailID,_prMasterID, _prFromWarehouseID, _InActive,_IsInventory, _quantityChanged,_quantityBilled; 
		select 'INV_updateInventoryOH START BIN', b.* from bin b where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID order by binSequence;
		-- select _quantityChanged,b.* from bin b where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID order by binSequence;
	END IF;
    
    -- need to allow SO that are negative
	-- if (_quantityChanged <=0) THEN
	--  	LEAVE INV_updateInventoryOH; 
    -- END IF;

		-- if ( _IsInventory is null or _IsInventory =0 or (_quantityChanged<=_quantityBilled) ) THEN 
	 if ( _IsInventory is null or _IsInventory =0 or _quantityChanged=0) THEN 
		LEAVE INV_updateInventoryOH; 
	 END IF;

 
 	 if ( (_quantityChanged>0 and _quantityBilled>=_quantityChanged) ) THEN 
		LEAVE INV_updateInventoryOH; 
	 END IF;

	 if ( (_quantityChanged<0 and _quantityBilled<=_quantityChanged) ) THEN 
		LEAVE INV_updateInventoryOH; 
	 END IF;

	-- THis will clear out the potentially bad records so it can be regenerated
	-- delete from cuSODetailBin where binId in (select binId from bin where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID);

      select group_concat(cuSODetailBinID) into _binIds from cuSODetailBin where cuSODetailID=_lineItemDetailID; 

	  if (_DEBUG in (3) ) THEN select 'INV_updateInventoryOH Backing out old cuSODetailBins (delete cuInvoiceDetailIDs) =', _binIds, b.* from cuSODetailBin b where cuSODetailID=_lineItemDetailID; END IF;

		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _acuSODetailBinId=SUBSTRING_INDEX(_binIds, ',', 1);
               
				select binId, allocated into _aBinId,_lastAllocated from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;
				
                if (_lastAllocated <> 0) THEN
                    -- DEBUGGING
                    -- select 'DELETE ALLOCATIONS', _aBinId,(-1*_lastAllocated),_acuSODetailBinId;
                    -- =======================
					call INV_updateOH('ADJUST',_aBinId,null,(-1*_lastAllocated),null,_changedByID);
                    set _whOH = _whOH + _lastAllocated;
                END IF;

				-- does this create an issue for invoice changes later?
                delete from cuInvoiceDetailBin where cuSODetailBinID = _acuSODetailBinId;
				
                delete from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;   



	-- only build a plan with what is remaining.  No need to carry quantityBilled forward.
    
	set _lastAllocated = _quantityChanged - _quantityBilled;
	if (_DEBUG in (2,3)) THEN select 'INV_updateInventoryOH create new cuSODetailBins ', _lastAllocated,_quantityChanged,_quantityBilled; END IF;
    
    -- if neg, then don't spread out, put all in bin1
    if (_quantityChanged<0) then
    
			select binId,InventoryOnHand, InventoryAllocated  
			into _aBinId,_prOH, _prIA
			from bin
			where 
			prMasterID= _prMasterID and prWarehouseID =_prFromWarehouseID
			and binSequence =1;

			call INV_updateOH('ADJUST',_aBinId,null,_lastAllocated,null,_changedByID);
			
			-- update or insert
			select cuSODetailBinID into _cuSODetailBinID from cuSODetailBin 
            where cuSODetailID = _lineItemDetailID and binId = _aBinId;
			
			if (_cuSODetailBinID is not null) THEN
				update cuSODetailBin set allocated = allocated+_lastAllocated where cuSODetailBinID=_cuSODetailBinID;
			ELSE
				insert into cuSODetailBin (cuSODetailID,binId,allocated) values (_lineItemDetailID,_aBinId,_lastAllocated);        
			END IF;

			call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,0,_lastAllocated,'Sales Order',_changedByID,_VendorNumber,_refRelatedNo);

			if (_DEBUG in (3)) THEN select 'INV_updateInventoryOH NEGATIVE handled ',_aBinId, _lastAllocated,_quantityChanged,_quantityBilled; END IF;
		
    ELSE
    
	while_allocation_left:  LOOP
    
		IF  _lastAllocated <=0 THEN 
			LEAVE  while_allocation_left;
		END  IF;
	
        set _aBinId=null,_prOH=null, _prIA = null;
  
		select binId, InventoryOnHand, InventoryAllocated 
		into _aBinId,_prOH, _prIA
		from bin
		where 
		prMasterID= _prMasterID and prWarehouseID =_prFromWarehouseID
		and  InventoryOnHand > InventoryAllocated
		order by binSequence ASC limit 1;

		-- IF (_DEBUG=1) THEN select 'INV_updateInventoryOH', _lineItemDetailID,_lastAllocated,_aBinId,_prOH, _lastAvailable; END IF;

		-- is there inventory left?
		if (_aBinId is not null) THEN

			select binId, InventoryOnHand, InventoryAllocated 
			into _aBinId,_prOH, _prIA
			from bin
			where binId =_aBinId;
		
			if (_lastAllocated <= (_prOH-_prIA)) THEN
            
				call INV_updateOH('ADJUST',_aBinId,null,_lastAllocated,null,_changedByID);
				insert into cuSODetailBin (cuSODetailID,binId,allocated) 
                values (_lineItemDetailID,_aBinId,_lastAllocated); 
				call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,0,_lastAllocated,'Sales Order',_changedByID,_VendorNumber,_refRelatedNo);
                set _lastAllocated = 0;
    
    -- IF (_DEBUG=1) THEN select 'INV_updateInventoryOH ENOUGH FOUND', _lineItemDetailID,_lastAllocated,_aBinId,_prOH, _lastAvailable; END IF;
                
                leave while_allocation_left;
            
            ELSE

				call INV_updateOH('ADJUST',_aBinId,null,(_prOH-_prIA),null,_changedByID);
                
				insert into cuSODetailBin (cuSODetailID,binId,allocated) 
                values (_lineItemDetailID,_aBinId,(_prOH-_prIA));
                
				call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,0,(_prOH-_prIA),'Sales Order',_changedByID,_VendorNumber,_refRelatedNo);

				set _lastAllocated = _lastAllocated - (_prOH-_prIA);

    -- IF (_DEBUG=1) THEN select 'INV_updateInventoryOH PARTIAL FOUND', _lineItemDetailID,(_prOH-_lastAvailable) as available ,_lastAllocated as _lastAllocatedLeft,_aBinId,_prOH, _lastAvailable; END IF;
				ITERATE  while_allocation_left;

            END IF;
			
        
        -- no inventory left so, just fill in bin1 with needs.
		ELSE

    
			-- put the remaining in the first bin and exit.
			select binId,InventoryOnHand, InventoryAllocated  
			into _aBinId,_prOH, _prIA
			from bin
			where 
			prMasterID= _prMasterID and prWarehouseID =_prFromWarehouseID
			and binSequence =1;

			call INV_updateOH('ADJUST',_aBinId,null,_lastAllocated,null,_changedByID);
			
			-- update or insert
			select cuSODetailBinID into _cuSODetailBinID from cuSODetailBin 
            where cuSODetailID = _lineItemDetailID and binId = _aBinId;
			
			if (_cuSODetailBinID is not null) THEN
				update cuSODetailBin set allocated = allocated+_lastAllocated where cuSODetailBinID=_cuSODetailBinID;
			ELSE
				insert into cuSODetailBin (cuSODetailID,binId,allocated) values (_lineItemDetailID,_aBinId,_lastAllocated);        
			END IF;

			call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,0,_lastAllocated,'Sales Order',_changedByID,_VendorNumber,_refRelatedNo);

			leave while_allocation_left;
            
		END IF;
		
	END LOOP;		

	if (_DEBUG in (3)) THEN select 'INV_updateInventoryOH POSITIVE handled '; END IF;

	END IF; -- end condition for positive _quantityChanged
    
 	
    IF (_DEBUG in (1,2,3)) THEN 
		select 'INV_updateInventoryOH Final cuSODetailBins after creating new=', b.* from cuSODetailBin b where cuSODetailID=_lineItemDetailID;
		select 'INV_updateInventoryOH Final BIN - Bin plan complete', b.* from bin b where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID order by binSequence;
	END IF;
        
elseif (_action='SALESORDER_ORIGINAL') THEN

	-- ORIGINAL
    
	set _journalID='SO';

	-- TODO check to see if this is a valid SO to adjust inventory.  
	-- if in the cuSODetail table then it should pull from inventory.

	select d.prMasterID, s.prFromWarehouseID, p.InActive, p.IsInventory,d.QuantityOrdered,d.QuantityBilled 
    into _prMasterID, _prFromWarehouseID, _InActive,_IsInventory, _quantityChanged,_quantityBilled 
	from cuSODetail d 
	left join cuSO s on (s.cuSOID = d.cuSOID)
	left join prMaster p on (d.prMasterID = p.prMasterID)
	 where d.cuSODetailID=_lineItemDetailID;
 
    
    -- if it violates some checks, then leave function
     if ( _IsInventory is null or _IsInventory =0 or _quantityBilled>0 ) THEN 
		LEAVE INV_updateInventoryOH; 
	 END IF;
   

        -- ========================================================
		-- get list of cuSODetailID's to try and undo any allocations.
        -- ========================================================

 		set _whOH = 0;  -- this will hold total amount needed to reverse
        select group_concat(cuSODetailBinID) into _binIds from cuSODetailBin where cuSODetailID=_lineItemDetailID; 
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _acuSODetailBinId=SUBSTRING_INDEX(_binIds, ',', 1);
               
				select binId, allocated into _aBinId,_lastAllocated from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;
				
                if (_lastAllocated <> 0) THEN
                    set _whOH = _whOH + _lastAllocated;
                END IF;
				
                delete from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;        

			call INV_updateOH('ADJUST',_aBinId,null,(-1*_whOH),null,_changedByID);
 
 			call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,_whOH,0,'Sales Order Reverse Allocation',_changedByID,_VendorNumber,_refRelatedNo);

        
        -- ========================================================
        -- get list of bins to loop and try to fill allocations
        -- ========================================================
		set _prIA = _quantityChanged;
        set _binIds = null;
        
        if (_IsInventory=1) THEN
			select group_concat(binId) into _binIds from bin where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID order by binSequence; 
		END IF;
        
        SET _transNumber =0;
        
        do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _aBinId=SUBSTRING_INDEX(_binIds, ',', 1);
				
                if(_transNumber=0) THEN set _fromBinID = _aBinId; END IF; -- used to help know what is the first bin.
               
				SET _transNumber = 1;
                
				select InventoryOnHand,InventoryAllocated,(InventoryOnHand-InventoryAllocated) into _lastOH,_lastAllocated,_lastAvailable from bin where binId = _aBinId;
				if (_lastAvailable >= _prIA) THEN

                    -- DEBUGGING
                    -- select 'CREATE ALLOCATIONS 1 bin', _aBinId,_prIA,_lineItemDetailID;
                    -- =======================

					-- assign everything
					call INV_updateOH('ADJUST',_aBinId,null,_prIA,null,_changedByID);
                    insert into cuSODetailBin (cuSODetailID,binId,allocated) values (_lineItemDetailID,_aBinId,_prIA);
					-- call FIX_tool("BIN_ALLOCATION",null,null,null,_aBinId);

                    set _prIA = 0;
                ELSE
                
					if ( _lastAvailable > 0 ) THEN

						-- DEBUGGING
						-- select 'CREATE ALLOCATIONS multi bin', _aBinId,_lastAvailable,_prIA,_lineItemDetailID;
						-- =======================

						-- assign partial
						call INV_updateOH('ADJUST',_aBinId,null,_lastAvailable,null,_changedByID);
						insert into cuSODetailBin (cuSODetailID,binId,allocated) values (_lineItemDetailID,_aBinId,_lastAvailable);
						-- call FIX_tool("BIN_ALLOCATION",null,null,null,_aBinId);
						set _prIA = _prIA - _lastAvailable;

					END IF;

                END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null or _prIA<=0) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;
 
			-- if anything is left over, the put onto the first bin.
			if (_prIA>0) THEN

                    -- DEBUGGING
                    -- select 'UPDATE ALLOCATIONS', _fromBinID,_prIA,_lineItemDetailID;
                    -- =======================
            
                    
                    
            
					call INV_updateOH('ADJUST',_fromBinID,null,_prIA,null,_changedByID);
                    
                    select cuSODetailBinID into _found from cuSODetailBin where cuSODetailID=_lineItemDetailID and binId=_fromBinID limit 1;

					-- call INV_updateOH('ADJUST',_fromBinID,null,_lastAvailable,null,_changedByID);
                    
                    
                    if (_found is not null) THEN
						update cuSODetailBin set allocated = (allocated + _prIA) where cuSODetailID=_lineItemDetailID and binId=_fromBinID;
                    ELSE
						insert into cuSODetailBin (cuSODetailID,binId,allocated) values (_lineItemDetailID,_fromBinID,_prIA);
                    END IF;
                  --  call FIX_tool("BIN_ALLOCATION",null,null,null,_aBinId);

            END IF;
    
			call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,0,_quantityChanged,'Sales Order',_changedByID,_VendorNumber,_refRelatedNo);


elseif (_action='INVOICE') THEN

	set _journalID='CI';
	set _reference = 'Customer Invoice';

	select d.prMasterID, c.prFromWarehouseID, p.InActive, p.IsInventory,sd.QuantityOrdered, d.QuantityBilled, sd.cuSODetailID, d.UnitPrice 
    into _prMasterID, _prFromWarehouseID, _InActive,_IsInventory, _quantityChanged, _quantityBilled, _cuSODetailID, _inventoryCost 
	from cuInvoiceDetail d
	left join cuInvoice c on (c.cuInvoiceID = d.cuInvoiceID)
	left join prMaster p on (p.prMasterID = d.prMasterID)
    left join cuSODetail sd on (sd.cuSODetailID = d.cuSODetailID)
	left join cuSO s on (s.cuSOID = sd.cuSOID)
	where d.cuInvoiceDetailID=_lineItemDetailID;
     
	
    select sum(allocated) into _lastAllocated from cuSODetailBin  where cuSODetailID = _cuSODetailID;
    select sum(InventoryOnHand), sum(InventoryAllocated) into _prOH,_prIA from bin where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID;
    if (_quantityChanged>(_prOH-_prIA)+ IFNULL(_lastAllocated,0)) THEN
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient Inventory to Invoice';
		LEAVE INV_updateInventoryOH; 
    END IF;
    
    
    
    
	if (_cuSODetailID is not null) THEN
		
        
 		set _whOH = 0;  
        select group_concat(cuSODetailBinID) into _binIds from cuSODetailBin where cuSODetailID=_cuSODetailID and txState='A'; 
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _acuSODetailBinId=SUBSTRING_INDEX(_binIds, ',', 1);
               
				select binId, allocated into _aBinId,_lastAllocated from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;
				if (_aBinId > 0) THEN
					call INV_updateOH('ADJUST',_aBinId,null,(-1*_lastAllocated),null,_changedByID);
                    update cuSODetailBin set txState = 'UA'  where cuSODetailBinID = _acuSODetailBinId;
                    set _whOH = _whOH + _lastAllocated;
                    
                END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  
            

 			call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,0,_whOH,'Sales Order Reverse Allocation',_changedByID,null,null);
            
    END IF;
 
         
		set _glAmount = 0;
		set _whOH = 0;  

       select group_concat(cuInvoiceDetailBinID) into _binIds from cuInvoiceDetailBin where cuInvoiceDetailBinID=_lineItemDetailID; 
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _acuSODetailBinId=SUBSTRING_INDEX(_binIds, ',', 1);
               
				select binId, QuantityBilled into _aBinId,_lastOH from cuInvoiceDetailBin where cuInvoiceDetailBinID = _acuSODetailBinId;
				if (_aBinId > 0) THEN
					call INV_updateOH('ADJUST',_aBinId,_lastOH,null,null,_changedByID);
                    set _glAmount = _glAmount + _lastOH;
                    set _whOH = _whOH + _lastOH;
                END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;    

			if (_whOH>0) THEN
				
				set _glAmount = -1*_glAmount*_inventoryCost;

				if(_lineItemDetailID is not null and _lineItemDetailID != 0) then
					call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,null,null,null,_lineItemDetailID,_changedByID,null,null);
                end if;

				call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,_whOH,0,'Customer Invoice Remove',_changedByID,null,null);
            END IF;
            
    
		
            
            
		set _prOH = _quantityBilled;
        set _lastOH = 0;
        set _lastAllocated = 0;
        set _lastAvailable = 0;
        
        
        set _binIds = null;
        
		select group_concat(binId) into _binIds from bin where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID order by binSequence; 
        
        do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _aBinId=SUBSTRING_INDEX(_binIds, ',', 1);
				
                if(_prOH=_quantityBilled) THEN set _fromBinID = _aBinId; END IF;
               
				select InventoryOnHand,InventoryAllocated,(InventoryOnHand-InventoryAllocated) into _lastOH,_lastAllocated,_lastAvailable from bin where binId = _aBinId;
				if (_lastAvailable >= _prOH) THEN
					
					call INV_updateOH('ADJUST',_aBinId,(-1*_prOH),null,null,_changedByID);
                    insert into cuInvoiceDetailBin (cuInvoiceDetailID,binId,QuantityBilled) values (_lineItemDetailID,_aBinId,_prOH);
                    set _prOH = 0;
                ELSE
					
					call INV_updateOH('ADJUST',_aBinId,(-1*_lastAvailable),null,null,_changedByID);
                    insert into cuInvoiceDetailBin (cuInvoiceDetailID,binId,QuantityBilled) values (_lineItemDetailID,_aBinId,_lastAvailable);
                    set _prOH = _prOH - _lastAvailable;
                END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null or _prOH<=0) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;




			set _glAmount = _quantityBilled*_inventoryCost;

			if(_lineItemDetailID is not null and _lineItemDetailID != 0) then
				call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,null,null,null,_lineItemDetailID,_changedByID,null,null);
			end if;

			call INV_updateInventoryLog('INSERT',_fromBinID,_journalID,null,null,null,_quantityBilled,0,'Customer Invoice',_changedByID,null,null);
    
    
    
elseif (_action='ADJUSTMENT' or _action='COUNT') THEN


     if ( _quantityChanged is null or _quantityChanged < 0) THEN 
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updateInventoryOH: ADJUSTMENT: _quantityChanged <0';
		LEAVE INV_updateInventoryOH; 
	 END IF;

	select b.prMasterID,b.prWarehouseID,b.prWarehouseInventoryID,b.InventoryOnHand,b.InventoryAllocated,p.AverageCost,
    p.Description, p.ItemCode
    into _prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_lastOH,_lastAllocated,_inventoryCost,_description,_itemcode 
    from bin b
    left join prMaster p on (p.prMasterID = b.prMasterID)
    where binId=_fromBinID;

	if (_lastOH is null) THEN set _lastOH=0; END IF;

	if(_lastOH = _quantityChanged) then 
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updateInventoryOH:there is no change in the onhand value';
	 LEAVE INV_updateInventoryOH;
    end if;

     if ( _prMasterID is null or _prFromWarehouseID is null or _prFromWarehouseInventoryID is null or _fromBinID is null) THEN 
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updateInventoryOH:_prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_fromBinID REQUIRED';
		LEAVE INV_updateInventoryOH; 
	 END IF;

	if (_action='ADJUSTMENT' ) THEN 
		set _journalID='IA';
	ELSE 
		set _journalID='IC';
		set _reference = CONCAT(DATE_FORMAT(now(), '%m-%d-%Y'),'  Count');
		set _resonCode = "item count"; 
    END IF;


	
 	
    select prTransferID into _prTransferId from prWHtransfer where 
    
	Description=_reference and reasonCode =_resonCode and Date(CreatedOn) = Date(now()) and prFromWareHouseID = _prFromWarehouseID;
    
    if(_prTransferId is null) THEN
		
        insert into prWHtransfer (TransferDate,prFromWareHouseID,Description,reasonCode,screenno,CreatedOn,CreatedById) values 
		(now(),_prFromWarehouseID,_reference,_resonCode,2,Date(now()),_changedByID);
		SELECT LAST_INSERT_ID() INTO _prTransferId;
    
    END IF;
    
    if(_prTransferId is not null) THEN
		UPDATE prWHtransfer SET TransferDate = now()  WHERE prTransferID = _prTransferId;
	end if;
   
	

	
	
    set _glAmount = ((_quantityChanged-_lastOH)*_inventoryCost);
	call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,_reference,_prTransferId,null,null,_changedByID,null,null);

 
	
    
    
    
		insert into prWHtransferDetail (prTransferID,prMasterID,Description,QuantityTransfered,InventoryCost,QuantityAvailable,ItemCode,difference,fromBinId) values 
		(_prTransferId,_prMasterID,_description,_quantityChanged,_inventoryCost,_lastOH,_itemcode,(_quantityChanged-_lastOH),_fromBinID);
		SELECT LAST_INSERT_ID() INTO _prTransferDetailID;
	
	
    

	
    

	call INV_updateOH('REPLACE',_fromBinID,_quantityChanged,_lastAllocated,null,_changedByID);

    call INV_updateInventoryLog('INSERT',_fromBinID,_journalID,_prTransferId,_prTransferDetailID,_prTransferId,_quantityChanged,0,'IA Created',_changedByID,null,null);




	 select * from v_INV_WHtransferDetail where prTransferID = _prTransferId;

ELSEIF (_action='TRANSFER-RECEIVE-UNDO') THEN 

	set _journalID='TR';

	
    select prTransferDetailID,prTransferId,prTransferDetailID,toBinId,QuantityTransfered,InventoryCost,fromBinId
    into _found,_prTransferId,_prTransferDetailID,_toBinID,_quantityChanged,_inventoryCost,_fromBinID
    from prWHtransferDetail where prTransferDetailID=_prTransferDetailID and ReceivedDate is not null;
	
    select TransNumber,prFromWareHouseID into _reference,_prFromWarehouseID from prWHtransfer where prTransferID = _prTransferId;
    
    select prMasterID,prWarehouseID,prWarehouseInventoryID,InventoryOnHand 
    into _prMasterID,_prToWarehouseID,_prToWarehouseInventoryID,_lastOH from bin where binId=_toBinID;

     if ( _found is null) THEN 
		select * from v_INV_WHtransferDetail where prTransferDetailID=_prTransferDetailID;
		LEAVE INV_updateInventoryOH; 
	 END IF;

	 
	
    set _glAmount = -1*_quantityChanged*_inventoryCost;
	call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,_prToWarehouseID,_reference,_reference,null,null,_changedByID,null,null);
	
	call INV_updateOH('ADJUST',_fromBinID,_quantityChanged,_quantityChanged,null,_changedByID);
       
    call INV_updateOH('ADJUST',_toBinID,(-1*_quantityChanged),null,null,_changedByID);
    
    -- select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
    select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null  and binSequence=1 limit 1;
        if (_virtualbinId is null) THEN
			select Description into _itemcode from prWarehouse where prWarehouseID = _prFromWarehouseID;
            
			insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
			values (_prFromWarehouseID,null,null,1,null,null,null,concat('VIRTUAL-',_itemcode),concat('VIRTUAL-',_itemcode),null,null,null,null,null,_changedByID,now());
            
            select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null  and binSequence=1 limit 1;
        END IF;
        
	-- update bin set inTransfer = ifnull(inTransfer,0)+_quantityChanged where binId = _virtualbinId;
	update bin set inTransfer = (case when (ifnull(inTransfer,0)+_quantityChanged < 0) THEN 0 ELSE (ifnull(inTransfer,0)+_quantityChanged) END) where binId = _virtualbinId;

    call INV_updateInventoryLog('INSERT',_toBinID,_journalID,_prTransferId,_prTransferDetailID,_reference,0,-1*_quantityChanged,'TR UNDO',_changedByID,null,null);

    update prWHtransferDetail set ReceivedDate=null,toBinId = null where prTransferDetailID=_prTransferDetailID;
	update prWHtransfer set ReceivedDate=NULL where prTransferID=_prTransferId;
	select * from v_INV_WHtransferDetail where prTransferId=_prTransferId;
	call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID);
ELSEIF (_action='TRANSFER-CANCEL') THEN 

	set _journalID='TR';

	
    select prTransferDetailID,prTransferId,prTransferDetailID,fromBinId,QuantityTransfered,InventoryCost ,fromBinId
    into _found,_prTransferId,_prTransferDetailID,_fromBinID,_quantityChanged,_inventoryCost,_fromBinID from prWHtransferDetail 
    where prTransferDetailID=_prTransferDetailID and ReceivedDate is null;
	select TransNumber into _reference from prWHtransfer where prTransferID = _prTransferId;
     if ( _found is null) THEN 
		select 'Already Received' as info, v_INV_WHtransferDetail.* from v_INV_WHtransferDetail where prTransferDetailID=_prTransferDetailID;
		LEAVE INV_updateInventoryOH; 
	 END IF;
     
 	select b.prMasterID,b.prWarehouseID,b.prWarehouseInventoryID,b.InventoryOnHand,b.InventoryAllocated,b.AverageCost,
    p.Description, p.ItemCode
    into _prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_lastOH,_lastAllocated,_inventoryCost,_description,_itemcode 
    from bin b
    left join prMaster p on (p.prMasterID = b.prMasterID)
    where binId=_fromBinID;   


	call INV_updateOH('ADJUST',_fromBinID,null,(-1*_quantityChanged),null,_changedByID);
    
    call INV_updateInventoryLog('INSERT',_fromBinID,_journalID,_prTransferId,_prTransferDetailID,_reference,0,_quantityChanged,'TR Cancel',_changedByID,null,null);
	-- select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
	select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 limit 1;
         if (_virtualbinId is null) THEN
			select Description into _itemcode from prWarehouse where prWarehouseID = _prFromWarehouseID;
            
			insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
			values (_prFromWarehouseID,null,null,1,null,null,null,concat('VIRTUAL-',_itemcode),concat('VIRTUAL-',_itemcode),null,null,null,null,null,_changedByID,now());
            
            select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null  and binSequence=1 limit 1;
        END IF;
       
        -- update bin set inTransfer = ifnull(inTransfer,0)-_quantityChanged where binId = _virtualbinId;
		update bin set inTransfer = (case when (ifnull(inTransfer,0)-_quantityChanged < 0) THEN 0 ELSE (ifnull(inTransfer,0)-_quantityChanged) END) where binId = _virtualbinId;
   
	
    DELETE FROM prWHtransferDetail  WHERE prTransferDetailID=_prTransferDetailID;

	select * from v_INV_WHtransferDetail where prTransferId=_prTransferId;
	call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID);
    
ELSEIF (_action='TRANSFER-RECEIVE') THEN 


	set _journalID='TR';

    select prTransferId,prTransferDetailID,QuantityTransfered,InventoryCost,fromBinId 
    into _prTransferId,_prTransferDetailID,_quantityChanged,_inventoryCost,_fromBinID from prWHtransferDetail where prTransferDetailID=_prTransferDetailID;
	
    select TransNumber,prFromWareHouseID into _reference,_prFromWarehouseID from prWHtransfer where prTransferID = _prTransferId;
    
 	select b.prMasterID,b.prWarehouseID,b.prWarehouseInventoryID,b.InventoryOnHand,b.InventoryAllocated,b.AverageCost,
    p.Description, p.ItemCode
    into _prMasterID,_prToWarehouseID,_prToWarehouseInventoryID,_lastOH,_lastAllocated,_inventoryCost,_description,_itemcode 
    from bin b
    left join prMaster p on (p.prMasterID = b.prMasterID)
    where binId=_toBinID;   
    
     if ( _prTransferId is null or _prTransferDetailID is null or _toBinID is null or _quantityChanged is null  or _inventoryCost is null or _prToWarehouseID is null) THEN 
		select _prTransferId,_prTransferDetailID,_toBinID,_quantityChanged, _inventoryCost,_prToWarehouseID;
        SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'INV_updateInventoryOH:_prTransferId,_prTransferDetailID,_toBinID,_quantityChanged,_inventoryCost,_prToWarehouseID REQUIRED';
		LEAVE INV_updateInventoryOH; 
	 END IF;
    
    
    select prTransferDetailID into _found from prWHtransferDetail where prTransferDetailID =_prTransferDetailID and ReceivedDate is not null  limit 1;
     
     if ( _found is not null) THEN 
		SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'INV_updateInventoryOH:Inventory Already Received';
		LEAVE INV_updateInventoryOH; 
	 END IF;
    
	
    set _glAmount = _quantityChanged*_inventoryCost;
	call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,_prToWarehouseID,_reference,_reference,null,null,_changedByID,null,null);

	
	
	
	call INV_updateOH('ADJUST',_fromBinID,(-1*_quantityChanged),(-1*_quantityChanged),null,_changedByID);
    
    
    call INV_updateOH('ADJUST',_toBinID,_quantityChanged,null,null,_changedByID);
    
    -- select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
    select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null  and binSequence=1 limit 1;
        if (_virtualbinId is null) THEN
			select Description into _itemcode from prWarehouse where prWarehouseID = _prFromWarehouseID;
            
			insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
			values (_prFromWarehouseID,null,null,1,null,null,null,concat('VIRTUAL-',_itemcode),concat('VIRTUAL-',_itemcode),null,null,null,null,null,_changedByID,now());
            
            select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 limit 1;
        END IF;
        
        -- update bin set inTransfer = ifnull(inTransfer,0)-_quantityChanged where binId = _virtualbinId;
		update bin set inTransfer = (case when (ifnull(inTransfer,0)-_quantityChanged < 0) THEN 0 ELSE (ifnull(inTransfer,0)-_quantityChanged) END) where binId = _virtualbinId;
    
    call INV_updateInventoryLog('INSERT',_toBinID,_journalID,_prTransferId,_prTransferDetailID,_reference,0,_quantityChanged,'TR Created',_changedByID,null,null);
    
    update prWHtransferDetail set ReceivedDate=Date(now()),toBinId = _toBinID  where prTransferDetailID=_prTransferDetailID;
    
    select count(*) into _totalOrdered from prWHtransferDetail where prTransferID = _prTransferId;
	select count(*) into _totalReceived from  prWHtransferDetail where prTransferID = _prTransferId and ReceivedDate is not null;
	if(_totalOrdered = _totalReceived) THEN
    update prWHtransfer set ReceivedDate=Date(now()) where prTransferID=_prTransferId;
	end if;
	call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID);
	select * from v_INV_WHtransferDetail where prTransferId=_prTransferId;

ELSEif (_action='TRANSFER') THEN 

	set _journalID='IT';

	


 	select b.prMasterID,b.prWarehouseID,b.prWarehouseInventoryID,b.InventoryOnHand,b.InventoryAllocated,b.AverageCost,
    p.Description, p.ItemCode
    into _prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_lastOH,_lastAllocated,_inventoryCost,_description,_itemcode 
    from bin b
    left join prMaster p on (p.prMasterID = b.prMasterID)
    where binId=_fromBinID;   

	

     if ( _quantityChanged > (_lastOH - _lastAllocated) )  THEN 
		 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'INV_updateInventoryOH:qty transfered is greater than onHand-allocated';
		LEAVE INV_updateInventoryOH; 
	 END IF;

     if ( _prMasterID is null or _prFromWarehouseID is null or _prFromWarehouseInventoryID is null or _fromBinID is null   or _prToWarehouseID is null ) THEN 
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INV_updateInventoryOH:_prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_prToWarehouseID,,_fromBinID, REQUIRED';
		LEAVE INV_updateInventoryOH; 
	 END IF;

    select prTransferID into _prTransferId from prWHtransfer where TransferDate= _transferDate and Description=_reference and Date(CreatedOn) = Date(now()) and prFromWareHouseID = _prFromWarehouseID and prToWareHouseID = _prToWarehouseID;
    
    if(_prTransferId is not  null) THEN
    
    select TransNumber into _transNumber from prWHtransfer where prTransferID = _prTransferId;
    end if;
    if(_prTransferId is null) THEN
		
        select (max(TransNumber)+1) into _transNumber from prWHtransfer;
       
        insert into prWHtransfer (TransferDate,prFromWareHouseID,prToWareHouseID, TransNumber, EstreceiveDate, Description,reasonCode,screenno,CreatedOn,CreatedById) values 
		(Date(_transferDate),_prFromWarehouseID,_prToWarehouseID,_transNumber, Date(_estimatedDate), _reference,'Transfer',1,Date(now()),_changedByID);
		SELECT LAST_INSERT_ID() INTO _prTransferId;
    
    END IF;
    
    select tpInventoryLogID into _found from tpInventoryLogMaster where transDetailID =_prTransferDetailID and receiveDate is not null  limit 1;
     
     if ( _found is not null) THEN 
		SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'INV_updateInventoryOH:Inventory Already Transfered';
		LEAVE INV_updateInventoryOH; 
	 END IF;
    
    select prTransferDetailID into _prTransferDetailID from prWHtransferDetail where prTransferId=_prTransferId and fromBinId =_fromBinID ; 

		set _reference = _transNumber;

		insert into prWHtransferDetail (prTransferID,prMasterID,Description,QuantityTransfered,InventoryCost,QuantityAvailable,ItemCode,difference,fromBinId,toBinId) values 
		(_prTransferId,_prMasterID,_description,_quantityChanged,_inventoryCost,(_lastOH-_lastAllocated),_itemcode,(_quantityChanged-_lastOH),_fromBinID,null);
		SELECT LAST_INSERT_ID() INTO _prTransferDetailID;

		call INV_updateOH('ADJUST',_fromBinID,null,_quantityChanged,null,_changedByID);
        
        -- select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
        select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 limit 1;
        if (_virtualbinId is null) THEN
			select Description into _itemcode from prWarehouse where prWarehouseID = _prFromWarehouseID;
            
			insert IGNORE into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
			values (_prFromWarehouseID,null,null,1,null,null,null,concat('VIRTUAL-',_itemcode),concat('VIRTUAL-',_itemcode),null,null,null,null,null,_changedByID,now());
            
            select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 limit 1;
        END IF;
        
        -- update bin set inTransfer = ifnull(inTransfer,0)+_quantityChanged where binId = _virtualbinId;
		update bin set inTransfer = (case when (ifnull(inTransfer,0)+_quantityChanged < 0) THEN 0 ELSE (ifnull(inTransfer,0)+_quantityChanged) END) where binId = _virtualbinId;

		call INV_updateInventoryLog('INSERT',_fromBinID,_journalID,_prTransferId,_prTransferDetailID,_reference,_quantityChanged,0,'IT Created',_changedByID,null,null);

		call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID);

	select * from v_INV_WHtransferDetail where prTransferId=_prTransferId;

ELSEif (_action='RECEIVE-ITEM') THEN 

	set _journalID='RI';

	if (_fromBinID is null or _lineItemDetailID is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updateInventoryOH:_binId and vePODetailID required';
		LEAVE INV_updateInventoryOH; 
	END IF;
	
	
	select b.prMasterID,b.prWarehouseID,b.prWarehouseInventoryID,b.InventoryAllocated,
   
    p.Description,p.AverageCost
    into _prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_lastAllocated,
   
    _description ,_inventoryCost
    from bin b
    left join prMaster p on (p.prMasterID = b.prMasterID)
    where binId=_fromBinID limit 1;
    
    
    select b.veReceiveDetailBinID, d.veReceiveDetailID, b.InventoryPutAway, d.veReceiveID 
    into _veReceiveDetailBinID, _veReceiveDetailID, _lastOH, _veReceiveID 
    from veReceiveDetail d
    left join veReceiveDetailBin b on (d.veReceiveDetailID = b.veReceiveDetailID)
    where b.vePODetailID=_lineItemDetailID and b.binId=_fromBinID and b.reversed=0 limit 1;
    
	select d.vePOID, p.rxVendorID, p.VendorOrderNumber, d.QuantityReceived, d.QuantityBilled, d.QuantityOrdered,r.Name,p.PONumber,d.PriceMultiplier,d.UnitCost
    into _vePOID, _rxMasterID, _VendorNumber,_quantityReceived, _quantityBilled, _quantityOrdered,_glDescription,_PONumber,_PriceMultiplier,_unitCost
    from vePODetail d 
	left join vePO p on p.vePOID = d.vePOID
    left join rxMaster r on (r.rxMasterID = p.rxVendorID)
	where d.vePODetailID=_lineItemDetailID  limit 1;

	set _reference = _PONumber;
    
	if (_quantityChanged>0) THEN

		select d.veReceiveID into  _reference 
        from veReceiveDetailBin b
        left join veReceiveDetail d on (d.veReceiveDetailID = b.veReceiveDetailID)
        where b.veReceiveDetailBinID=_veReceiveDetailBinID limit 1;
        
        
        if(_quantityReceived+_quantityChanged > _quantityOrdered) THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updateInventoryOH:can not receive more than ordered quantity';
			LEAVE INV_updateInventoryOH;
		END IF;
		
		call INV_updateOH('ADJUST',_fromBinID,_quantityChanged,null,null,_changedByID);
		call PO_initReceiveDetail('INIT',_lineItemDetailID,_fromBinID,_quantityChanged,_changedByID,_resonCode,_veReceiveDetailBinID);	
        
		set _glAmount = _quantityChanged*if(_inventoryCost=0,_unitCost,_inventoryCost);
		
		if(_lineItemDetailID is not null and _lineItemDetailID != 0) then
			call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,_glDescription,_reference,_veReceiveDetailBinID,_lineItemDetailID,_changedByID,null,null);
		end if;

		if(_inventoryCost=0) then 
			update prMaster set AverageCost = _unitCost where prMasterID = _prMasterID;
		end if;
	
	END IF;


ELSEif (_action='RECEIVE-BATCH') THEN 

		 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'INV_updateInventoryOH:RECEIVE-BATCH deprecated';
		LEAVE INV_updateInventoryOH; 
  
END IF;

END$$

DELIMITER ;





-- ==================================================================
-- ==================================================================
-- ==================================================================

DROP procedure IF EXISTS `INV_updateOH`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_updateOH`(
	IN _action varchar(25),
    IN _binID INT,
    IN _adjust decimal(19,4),
    IN _adjustAllocated decimal(19,4),
    IN _adjustOnOrder decimal(19,4),
    IN _changedByID INT	    
)
INV_updateOH : BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.0';


DECLARE _prOH INT;
DECLARE _prIA INT;
DECLARE _prIOO INT;
DECLARE _whOH INT;
DECLARE _whIA INT;
DECLARE _whIOO INT;
DECLARE _prMasterID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _prFromWarehouseInventoryID INT;
DECLARE _lastOH decimal(19,4);
DECLARE _lastAllocated decimal(19,4);
DECLARE _lastOnOrder decimal(19,4);
DECLARE _quantityChanged decimal(19,4);
DECLARE _quantityChangedAllocated decimal(19,4);
DECLARE _quantityChangedOnOrder decimal(19,4);
DECLARE commaNeeded INT DEFAULT 0;

	
	select prMasterID,prWarehouseID,prWarehouseInventoryID,InventoryOnHand,InventoryAllocated,InventoryOnOrder 
    into _prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_lastOH,_lastAllocated,_lastOnOrder 
    from bin where binId=_binID;



	if ( _action = 'ADJUST' ) THEN
		set _quantityChanged = ifnull(_lastOH,0) + ifnull(_adjust,0);
		set _quantityChangedAllocated = ifnull(_lastAllocated,0) + ifnull(_adjustAllocated,0);
		set _quantityChangedOnOrder=0;
        
    ELSEIF( _action = 'REPLACE' ) THEN
		set _quantityChanged = _adjust;
 		set _quantityChangedAllocated = ifnull(_adjustAllocated,0);
 		set _quantityChangedOnOrder = ifnull(_adjustOnOrder,0);
    END IF;
	
	if (_quantityChanged<0) THEN set _quantityChanged = 0; END IF;
	if (_quantityChangedAllocated<0) THEN set _quantityChangedAllocated = 0; END IF;
	

			set  @l_sql ='update bin set ';
		   
			 if (_adjust is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'InventoryOnHand =', _quantityChanged); 
				set commaNeeded =1;
			END IF;
			 if (_adjustAllocated is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'InventoryAllocated =', _quantityChangedAllocated); 
				set commaNeeded =1;
			END IF;
			 if (_adjustOnOrder is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'InventoryOnOrder =', _quantityChangedOnOrder); 
				set commaNeeded =1;
			END IF;            

             
			IF (commaNeeded>0) THEN
			
				set @l_sql = CONCAT(@l_sql,',changedByID =', _changedByID); 
				set @l_sql = CONCAT(@l_sql,',LastUpdatedTime =\'', now(),'\''); 
				set @l_sql = CONCAT(@l_sql,' where binId=', _binId); 

				PREPARE stmt FROM @l_sql;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
				
			END IF;

    
    select sum(InventoryOnHand),sum(InventoryAllocated),sum(InventoryOnOrder) into _prOH,_prIA,_prIOO from bin where prMasterID = _prMasterID;
    
    update prMaster set InventoryOnHand = _prOH,InventoryAllocated=_prIA,InventoryOnOrder=_prIOO, LastUpdatedTime=now() where prMasterID=_prMasterID;
	
    select sum(InventoryOnHand),sum(InventoryAllocated),sum(InventoryOnOrder) into _whOH,_whIA,_whIOO from bin where prMasterID = _prMasterID and prWarehouseID=_prFromWarehouseID;

   
    
	update prWarehouseInventory set InventoryOnHand = _whOH,InventoryAllocated=_whIA,InventoryOnOrder=_whIOO, LastUpdatedTime=now() where prWarehouseInventoryID=_prFromWarehouseInventoryID;
   

END$$



DELIMITER ;


DROP procedure IF EXISTS `INV_createPickTicket_v2`;

DELIMITER $$

-- call INV_createPickTicket_v2('CREATE',107384,1);
CREATE DEFINER=`root`@`%` PROCEDURE `INV_createPickTicket_v2`(
IN _action varchar(25),
IN _cuSOID INT,
IN _DEBUG INT
)
INV_createPickTicket_v2 : BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.6';  -- add else block to update toPick and backorder for 0 toPick


DECLARE _ids    text;
DECLARE _id    INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;

DECLARE _tickets    text;
DECLARE _pickTicketId INT;
DECLARE _bids    text;
DECLARE _bid    INT;
DECLARE bstrLen    INT DEFAULT 0;
DECLARE bSubStrLen INT DEFAULT 0;

DECLARE _foundID INT;
DECLARE _printID INT;
DECLARE _cuSODetailID INT;
DECLARE _cuSODetailBinID INT;
DECLARE _binId INT;
DECLARE _prMasterID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _binName varchar(100);
DECLARE _ItemCode varchar(100);
DECLARE _Description varchar(100);
DECLARE _QuantityOrdered decimal(19,4);
DECLARE _QuantityBilled decimal(19,4);

DECLARE _promised decimal(19,4);
DECLARE _binAllocated decimal(19,4);
DECLARE _availableToPick decimal(19,4);  -- holds the toPick
DECLARE _backOrdered decimal(19,4);
DECLARE _InventoryOnHand decimal(19,4);
DECLARE _InventoryAllocated decimal(19,4);
DECLARE _quantityDesired decimal(19,4);
DECLARE _totalAvailableToPickThisBin decimal(19,4);
DECLARE _avaliableBeyondAllocated decimal(19,4);
DECLARE _binCount INT;
DECLARE _leftToBePicked decimal(19,4);

DECLARE _cuSODetailIDs varchar(2000);
DECLARE _notEnoughInventory TINYINT;
DECLARE _multiBinAllocationIssue TINYINT;
DECLARE _sumSODetailBinAllocated decimal(19,4);
DECLARE _partialBilled TINYINT DEFAULT 0;
DECLARE _TransactionStatus INT;


if(_action = 'CREATE') THEN
	
        select cuSOID,TransactionStatus into _foundID,_TransactionStatus from cuSO where cuSOID=_cuSOID;

-- 	case 'Void' setStatus = -1; 
-- 	case 'Quote' setStatus = -2;
-- 	case 'OnHold' setStatus = 0;
-- 	case 'Open' setStatus = 1;
-- 	case 'Book as Job' setStatus = 3;
-- 	case 'Import to Job' setStatus = 4;
-- 	case 'Closed' setStatus = 2;

		-- consider allowing the clean up code to exexute before leaving.
       if (_foundID is null or _TransactionStatus in (-1,-2,0,2,3,4)) THEN
			if (_DEBUG in (1,2,3)) THEN select 'INV_createPickTicket_v2: Missing or NOT OPEN (EXITING)=' ,_cuSOID,_TransactionStatus; END IF;
			leave INV_createPickTicket_v2;
        END IF;


		-- clean up any tickets that should not be considered
		-- catch any open tickets that should be closed
        -- and cuOSID says it is closed.
		update  cuSODetailTicket t
		left join cuSODetail d on (d.cuSODetailID = t.cuSODetailId )
        left join cuSO s on (s.cuSOID = d.cuSOID)
		set t.ticketStatus=2  
		where t.ticketStatus=1 and (d.QuantityOrdered = d.QuantityBilled ) and s.TransactionStatus=2;

		-- handle missing cuSODetail's?
		update  cuSODetailTicket t
		left join cuSODetail d on (d.cuSODetailID = t.cuSODetailId )
		set t.ticketStatus=9 -- ERROR  
		where t.ticketStatus=1 and (d.QuantityOrdered is null);

		-- clean up so quotes where -2,-1 is the transStatus
		update  cuSODetailTicket t
        left join cuSO s on (s.cuSOID = t.cuSOID)
		set t.ticketStatus=s.transactionStatus -- ERROR  
		where t.ticketStatus=1 and (s.transactionStatus in (-1,-2) );    
    
        update cuSODetailTicket set ticketStatus=0, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;
			
		select count(*)  INTO _printID from cuSODetailTicket where cuSOID=_cuSOID;

			-- get list of cuSODetailID's to process
		select GROUP_CONCAT(d.cuSODetailID) 
		into _cuSODetailIDs
		from cuSODetail d
		left join cuSO cu   on (d.cuSOID = cu.cuSOID)
		left join prMaster p on (p.prMasterID = d.prMasterID)
		where d.cuSOID=_cuSOID and p.isInventory=1;

		 if (_DEBUG in (3)) THEN select 'INV_createPickTicket_v2: Delete bad tickets and set tickets=1 to zero: working on cuSODetailIDs=',_cuSODetailIDs ,_cuSOID; END IF;
         
		 do_cusodetailids:
		   LOOP
				set _cuSODetailID = null;
				SET strLen = CHAR_LENGTH(_cuSODetailIDs);
				set _cuSODetailID=SUBSTRING_INDEX(_cuSODetailIDs, ',', 1);

			
			-- test if bin recomendation matches quantity ordered
			select sum(sob.allocated), d.QuantityOrdered, d.QuantityBilled, d.prMasterID 
            into _sumSODetailBinAllocated, _QuantityOrdered,_QuantityBilled, _prMasterID
            from cuSODetailBin sob
			left join cuSODetail d on (d.cuSODetailID = sob.cuSODetailID)
			where d.cuSODetailID = _cuSODetailID;


			-- test if allocated >= oh for bin seq>1
			-- check if any issues with soDetailBin.allocated to oh recomendation
            -- an issue could be that there is not enough inventory as previous thought.
			select count(*) 
            into _multiBinAllocationIssue 
            from cuSODetailBin sob
			left join cuSODetail d on (d.cuSODetailID = sob.cuSODetailID)
			left join bin b on (sob.binId = b.binId)
			where (sob.allocated - d.QuantityBilled) > b.InventoryOnHand and sob.cuSODetailID = _cuSODetailID
            and b.binSequence>1;
			
            -- find out if partial build, need to recreate a new plan
			select count(*) 
            into _partialBilled 
            from cuSODetail d
			where d.QuantityBilled>0 and d.cuSODetailID = _cuSODetailID;
            
			-- if mis match on allocations and ordered, then fix - some issue has caused this?
            
			if (_sumSODetailBinAllocated <> _QuantityOrdered or _multiBinAllocationIssue=1 or _partialBilled>0) then 
                -- call AUDIT_inventory('PRFIX',1,_prMasterID,null,null,null,null,null,null);
				if (_DEBUG in (3)) THEN 
					select 'INV_createPickTicket_v2 call AUDIT_updateProductAllocations for:',_prMasterID as prMasterIDFixed,_multiBinAllocationIssue,_partialBilled,_sumSODetailBinAllocated, _QuantityOrdered; 
                END IF;
				call AUDIT_updateProductAllocations (null,_prMasterID,1,_DEBUG); -- this will start over.
				if (_DEBUG in (3)) THEN 
					select 'INV_createPickTicket_v2 after call cuSODetail ', d.* from cuSODetail d where cuSODetailID = _cuSODetailID;
					select 'INV_createPickTicket_v2 after call cuSODetailBin', d.* from cuSODetailBin d where cuSODetailID = _cuSODetailID;
                END IF;

			end if;

			-- determine how much is already promosed from earlier tickets.
            
			select count(*) 
            into _notEnoughInventory 
            from cuSODetailBin sob
            left join cuSODetail d on (d.cuSODetailID = sob.cuSODetailID)
			left join bin b on (sob.binId = b.binId)
			where (sob.allocated-d.quantityBilled) > b.InventoryOnHand 
            and sob.cuSODetailID = _cuSODetailID;

			-- NOTE: promised will be handled after the below block.

			-- if no issue, then do a straight ticket insert - easiest case
			if (_notEnoughInventory = 0 and _QuantityOrdered >0 ) then 

				if (_DEBUG in (3)) THEN select 'INV_createPickTicket_v2 SIMPLE INSERT bin inventory',_cuSODetailID,_prMasterID; END IF;
							
				set _promised =0; -- since inventory available to allocated
                
				insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,
                ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
                select _printID,_cuSOID,_cuSODetailID,1,(sob.allocated-sob.QuantityBilled),
                -- select _printID,_cuSOID,_cuSODetailID,1,(sob.allocated-(cd.QuantityOrdered - cd.QuantityBilled)),
                cd.QuantityOrdered - cd.QuantityBilled,0,_promised, b.InventoryOnHand,pr.ItemCode,cd.Description,b.searchName,b.binId
                from cuSODetailBin sob
                left join cuSODetail cd on (cd.cuSODetailID = sob.cuSODetailID)
                left join bin b on (b.binId = sob.binId)
                left join prMaster pr on (pr.prMasterID = cd.prMasterID)
                where cd.cuSODetailID = _cuSODetailID 
                and cd.QuantityOrdered <> cd.QuantityBilled;
    
			ELSEif ( _notEnoughInventory > 0 and  _QuantityOrdered > 0) THEN

            
				if (_DEBUG in (3)) THEN select 'INV_createPickTicket_v2 MUTILEVEL insert bin inventory',_cuSODetailID,_prMasterID; END IF;
				
                -- 1. assumption is not enough inventory on bin #1
                -- insert for all sodetailbins
				insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,
                toPick,
                ordered,
                backOrdered,
                alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
                select _printID,_cuSOID,_cuSODetailID,1,
                IF ( (sob.allocated- cd.QuantityBilled-b.InventoryOnHand - (sob.allocated - b.InventoryAllocated))<0, (sob.allocated- cd.QuantityBilled),b.InventoryOnHand + (sob.allocated - b.InventoryAllocated) ), -- backing out earlier allocations
                -- IF ( (sob.allocated- cd.QuantityBilled-b.InventoryOnHand)<0, (sob.allocated- cd.QuantityBilled),b.InventoryOnHand), -- previous
                -- IF ( ((sob.allocated-(cd.QuantityOrdered - cd.QuantityBilled))-b.InventoryOnHand)<0, (sob.allocated-(c.QuantityOrdered - cd.QuantityBilled)),b.InventoryOnHand), -- oldest
                cd.QuantityOrdered - cd.QuantityBilled, 
                IF ( ((sob.allocated - cd.QuantityBilled)-b.InventoryOnHand - (sob.allocated - b.InventoryAllocated))>0, ((sob.allocated - cd.QuantityBilled)-b.InventoryOnHand - (sob.allocated - b.InventoryAllocated)),0), -- adding in earlier allocations.
                -- IF ( ((sob.allocated - cd.QuantityBilled)-b.InventoryOnHand)>0, ((sob.allocated - cd.QuantityBilled)-b.InventoryOnHand),0), -- previous
                -- IF ( ((sob.allocated-(cd.QuantityOrdered - cd.QuantityBilled))-b.InventoryOnHand)>0, ((sob.allocated-(c.QuantityOrdered - cd.QuantityBilled))-b.InventoryOnHand),0), -- oldest
                0, b.InventoryOnHand,pr.ItemCode,cd.Description,b.searchName,b.binId
                from cuSODetailBin sob
                left join cuSODetail cd on (cd.cuSODetailID = sob.cuSODetailID)
                left join bin b on (b.binId = sob.binId)
                left join prMaster pr on (pr.prMasterID = cd.prMasterID)
                where cd.cuSODetailID = _cuSODetailID
                and cd.QuantityOrdered <> cd.QuantityBilled;
            
            ELSEIF (_QuantityOrdered < 0) THEN
            
				-- select binId into _binId where  prMasterID =_prMasterID order by binSequence asc limit 1;
				-- need to get the warehouse prWarehouseID
                
                select prFromWarehouseID into _prFromWarehouseID from cuSO where cuSOID = _cuSOID;
                
				insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,
                ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
                select _printID,_cuSOID,_cuSODetailID,1,_QuantityOrdered,
                _QuantityOrdered,0,0, b.InventoryOnHand,pr.ItemCode,pr.Description,b.searchName,b.binId
                from bin b 
                left join prMaster pr on (pr.prMasterID = b.prMasterID)
                where b.prMasterID =_prMasterID and b.prWarehouseID = _prFromWarehouseID order by binSequence asc limit 1;
            
			END IF;
            
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_cuSODetailIDs, ',', 1))+2;
				SET _cuSODetailIDs = MID(_cuSODetailIDs, SubStrLen, strLen);
				IF (_cuSODetailIDs = '' or _cuSODetailIDs is null) THEN
				   LEAVE do_cusodetailids;
				END IF;
                    
			END LOOP do_cusodetailids; 

		select GROUP_CONCAT(t.pickTicketId) 
		into _tickets
		from cuSODetailTicket t
		where t.cuSOID=_cuSOID and t.ticketStatus=1 order by pickTicketId;

		if (_DEBUG  in (2,3)) THEN select 'INV_createPickTicket_v2 before adjustment', _tickets, t.* from cuSODetailTicket t where cuSOID = _cuSOID and ticketStatus=1; END IF;

		set _leftToBePicked = 0; -- keep track of non-picked amount
        
		 do_tickets:
		   LOOP
				set _pickTicketId = null;
				SET strLen = CHAR_LENGTH(_tickets);
				set _pickTicketId=SUBSTRING_INDEX(_tickets, ',', 1);

				select binId into _binId from cuSODetailTicket where pickTicketId=_pickTicketId;

				select t.toPick, t.inventoryOHAtTime, b.allocated, d.QuantityBilled, t.binId 
                into _availableToPick,_InventoryOnHand,_QuantityOrdered,_QuantityBilled ,_binId
                from cuSODetailTicket t
                left join cuSODetail d on (d.cuSODetailID = t.cuSODetailID) 
                left join cuSODetailBin b on (b.cuSODetailID = d.cuSODetailID)
                where pickTicketId=_pickTicketId and b.binId = _binId;

				-- don't change/adjust anything as this is a put back.
                -- SELECT _availableToPick,_pickTicketId;
			if ( _availableToPick > 0) THEN
                
				-- this represents if there is any inventory beyond what was allocated.
				set _avaliableBeyondAllocated = 0;
                select InventoryOnHand-InventoryAllocated into _avaliableBeyondAllocated from bin where binId=_binId;
                if (_avaliableBeyondAllocated<0) then set _avaliableBeyondAllocated=0; END IF;

                -- this is if there is already prommised product on this bin due to an early print.
				set _promised=0;
				select ifnull(sum(toPick),0) into _promised from cuSODetailTicket where binId =_binId and ticketStatus=1 and pickTicketId<_pickTicketId;


				-- calculate total availble to pick
                set _totalAvailableToPickThisBin = (_InventoryOnHand - _promised + _avaliableBeyondAllocated);

if (_DEBUG in (3)) THEN 
select 'INV_createPickTicket_v2 adjusting0',_availableToPick,_avaliableBeyondAllocated,
_totalAvailableToPickThisBin as '(_InventoryOnHand - _promised + _avaliableBeyondAllocated)',
_InventoryOnHand,_promised,_avaliableBeyondAllocated,
_leftToBePicked;
END IF;  

-- select _InventoryOnHand,_promised,_avaliableBeyondAllocated,_totalAvailableToPickThisBin,_availableToPick,_leftToBePicked,_binId,_pickTicketId;

                if (_totalAvailableToPickThisBin<0) then set _totalAvailableToPickThisBin=0; end if;
                
               --  SELECT _availableToPick,_leftToBePicked,_totalAvailableToPickThisBin,_pickTicketId,"BEFORE IF";
                if ((_availableToPick+_leftToBePicked)<=_totalAvailableToPickThisBin) then

if (_DEBUG in (3)) THEN 
select 'INV_createPickTicket_v2 adjusting1',_totalAvailableToPickThisBin as '_InventoryOnHand - _promised + _avaliableBeyondAllocated',
      (_availableToPick+_leftToBePicked),_availableToPick,_leftToBePicked;
END IF;  

					set _availableToPick=_availableToPick+_leftToBePicked;
                    set _leftToBePicked=0;
		-- SELECT "IF",_leftToBePicked,_availableToPick,_totalAvailableToPickThisBin;
                else
                -- SELECT "ELSE",_leftToBePicked,_availableToPick,_totalAvailableToPickThisBin;
					set _leftToBePicked = _availableToPick+_leftToBePicked - _totalAvailableToPickThisBin;
                    -- SELECT "ELSE",_leftToBePicked_availableToPick_totalAvailableToPickThisBin;

if (_DEBUG in (3)) THEN 
select 'INV_createPickTicket_v2 adjusting2',_totalAvailableToPickThisBin as '_InventoryOnHand - _promised + _avaliableBeyondAllocated',
      _availableToPick,
      _leftToBePicked as '_availableToPick+_leftToBePicked - _totalAvailableToPickThisBin';
END IF;

                    set _availableToPick = _totalAvailableToPickThisBin;


				END IF;
              
				if (_availableToPick<0) THEN set _availableToPick=0; END IF;
				if (_leftToBePicked<0) THEN set _leftToBePicked=0; END IF;
				-- if(_leftToBePicked != 0) then
					set _leftToBePicked = _QuantityOrdered - _availableToPick;
                    if(_QuantityOrdered < _availableToPick) then
						set _availableToPick = _QuantityOrdered;
						set _leftToBePicked = 0;
                    end if;
                    if(_QuantityOrdered = _availableToPick) then
						set _leftToBePicked = _QuantityOrdered - _availableToPick;
					end if;
                    IF(_QuantityOrdered IS NOT NULL && _availableToPick < 0) THEN
						set _availableToPick = _QuantityOrdered;
                        set _leftToBePicked = 0;
					end if;
                     select _availableToPick,_QuantityOrdered, _leftToBePicked, _pickTicketId;
					update cuSODetailTicket set toPick=_availableToPick, backOrdered = _leftToBePicked, alreadyPromised=_promised 
					where pickTicketId=_pickTicketId;
                 -- end if;
				            
if (_DEBUG in (3)) THEN 
select 'INV_createPickTicket_v2 adjusting3',_totalAvailableToPickThisBin,_availableToPick,_leftToBePicked,_binId,_pickTicketId;
-- select concat('INV_createPickTicket_v2 adjusting.. BinId=',_binId,' ticket=',_pickTicketId,_availableToPick,_avaliableBeyondAllocated,_totalAvailableToPickThisBin,_leftToBePicked );
END IF;

	 ELSE 
		SELECT toPick, ordered, backOrdered INTO _availableToPick, _QuantityOrdered, _leftToBePicked from cuSODetailTicket where pickTicketId=_pickTicketId;
		if(_availableToPick < 0 or _availableToPick >_QuantityOrdered) then
			set _availableToPick = _QuantityOrdered;
			set _leftToBePicked  = 0; 

			update cuSODetailTicket set toPick = _availableToPick, backOrdered = _leftToBePicked where pickTicketId=_pickTicketId;

		end if;
	END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_tickets, ',', 1))+2;
				SET _tickets = MID(_tickets, SubStrLen, strLen);
				IF (_tickets = '' or _tickets is null) THEN
				   LEAVE do_tickets;
				END IF;
                    
			END LOOP do_tickets; 

			if (_DEBUG in (3)) THEN 
			select 'INV_createPickTicket_v2 adjusting4  _leftToBePicked',_leftToBePicked;
			END IF;

			-- put all the backorders on the bin1 ticket
			if (_leftToBePicked>0) THEN
				
                select t.pickTicketId into _pickTicketId
					from cuSODetailTicket t
					left join bin b on (b.binId = t.binId)
					where t.cuSOID=_cuSOID and t.ticketStatus=1 order by b.binSequence limit 1;

 				--  update cuSODetailTicket set backOrdered =  _leftToBePicked
                --  where pickTicketId=_pickTicketId;

				if (_DEBUG in (3)) THEN 
				select concat('INV_createPickTicket_v2 adjusting5 backorder added to ticket=',_pickTicketId );
				END IF;

            END IF;

		if (_DEBUG in (2,3)) THEN select 'INV_createPickTicket_v2 after adjustment', _tickets, t.* from cuSODetailTicket t where cuSOID = _cuSOID and ticketStatus=1; END IF;
            
	ELSEif(_action = 'INVOICE') THEN
		update cuSODetailTicket set ticketStatus=2, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;
	
	ELSEif(_action = 'VOID') THEN
		update cuSODetailTicket set ticketStatus=0, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;

	ELSEif(_action = 'DELETE') THEN
		UPDATE cuSODetailTicket  SET ticketStatus = 2 where cuSODetailId = _cuSOID and ticketStatus=1;
	
	END IF;

END$$

DELIMITER ;
-- ==================================================================== INV_createPickTicket_v2



-- ==============================================
DROP procedure IF EXISTS `INVOICE_updateInvoiceDetail`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_updateInvoiceDetail`(
IN _action varchar(20),
IN _cuInvoiceID INT,
IN _cuInvoiceDetailID INT,
IN _cuSODetailID INT,
IN _vePODetailID INT,
IN _prMasterID INT,
IN _QuantityBilled  decimal(19,4),
IN _UnitCost decimal(19,4),
IN _PriceMultiplier decimal(19,4),
IN _Taxable INT,
IN _Note LONGTEXT,
IN _Description varchar(500),
IN _changedByID INT
)
INVOICE_updateInvoiceDetail: BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.2 - Debugging added';

DECLARE _DEBUG INT DEFAULT 0; -- 1,2,3

DECLARE _stopBilling TINYINT DEFAULT 0;
DECLARE _isNew TINYINT DEFAULT 0;
DECLARE _count INT DEFAULT 0;
DECLARE _HasSingleItemTaxAmount INT DEFAULT 1;
DECLARE _whseCost decimal(19,4);
DECLARE _onOrder decimal(19,4);
DECLARE _LastQuantityBilled decimal(19,4);
DECLARE _position INT DEFAULT 1;

DECLARE _prWarehouseID INT;

DECLARE _IsTaxable INT;
DECLARE _InActive INT;
DECLARE _IsInventory INT;
DECLARE _cuSOID INT;
DECLARE _vePOID INT;
DECLARE _cuSODetailBinID INT;
DECLARE _cuInvoiceDetailBinID INT;
DECLARE _binId INT;
DECLARE _InventoryOnHand decimal(19,4);
DECLARE _quantityChanged decimal(19,4);
DECLARE _soDetailOrdered decimal(19,4);
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _ids varchar(255);
DECLARE _ID INT;
DECLARE _AvailableToBillInThisBin  decimal(19,4);
DECLARE _TotalLeftTobeBilled  decimal(19,4);
DECLARE _AmountTobeBilledThisTime  decimal(19,4);
DECLARE _isQPItemCode INT DEFAULT 0;
DECLARE _isQPItemCodeQty INT DEFAULT 1;
DECLARE _lastSubTotal decimal(19,4);
DECLARE _lastFreight decimal(19,4);
DECLARE _lastTaxAmount decimal(19,4);
DECLARE _LastcoTaxTerritoryID decimal(19,4);
DECLARE _LastinvoiceDate varchar(20);
DECLARE _joReleaseType VARCHAR(255);
DECLARE _referenceNo VARCHAR(100);
DECLARE _joReleaseDetailID INT;
DECLARE _refRelatedNo varchar(25);
DECLARE _ReleaseTypeNum int;


if (_cuInvoiceID is null) THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:missing cuInvoiceID';
				LEAVE INVOICE_updateInvoiceDetail; 
END IF;

select InvoiceNumber,cuSOID,joReleaseDetailID into _referenceNo,_vePOID,_joReleaseDetailID from cuInvoice where cuInvoiceID = _cuInvoiceID;
if(_vePOID is null) then 
set _refRelatedNo = null;
end if;

if(_vePOID is not null and _joReleaseDetailID is null) then
select SONumber into _refRelatedNo from cuSO where cuSOID = _vePOID;
end if;

if(_vePOID is not null and _joReleaseDetailID is not null) then
select jr.ReleaseType into _ReleaseTypeNum from joReleaseDetail jd
left join joRelease jr on jr.joReleaseID = jd.joReleaseID
where jd.joReleaseDetailID = _joReleaseDetailID;

if(_ReleaseTypeNum = 1 or _ReleaseTypeNum = 4) then 
select PONumber into _refRelatedNo  from vePO where vePOID = _vePOID;
else 
select SONumber into _refRelatedNo from cuSO where cuSOID = _vePOID;
end if;

end if;


if (_action = 'UPDATE') THEN

	if (_cuInvoiceID is not null) THEN
		
        if (_QuantityBilled is null or _UnitCost is null or _PriceMultiplier is null or  _Taxable is null)
			THEN 
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:Required: QuantityBilled,UnitCost,PriceMultiplier,Taxable';
				leave INVOICE_updateInvoiceDetail; 
			END IF;


-- select  '1',_action,_cuInvoiceDetailID,_cuSODetailID;

		if (  _cuInvoiceDetailID is null ) THEN 
        
					if (_cuSODetailID is not null) THEN
						                        
                        set _count=0;
			
						SELECT IF(pm.ItemCode='QP',1,(QuantityOrdered-QuantityBilled)),IF(pm.ItemCode='QP',1,0) 
                        INTO _count,_isQPItemCode  
                        FROM cuSODetail sod 
                        LEFT JOIN prMaster pm ON(sod.prMasterID=pm.prMasterID) 
                        WHERE cuSODetailID = _cuSODetailID;
/*						
                        if (_count =0) THEN 
							SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:cuInvoiceDetail not found';
                            leave INVOICE_updateInvoiceDetail; 
                        END IF;
*/						
/*                      -- not sure whay it was preventing additional records.  comment out for now.  
						set _count=0;
                        select cuInvoiceDetailID into _count from cuInvoiceDetail where cuSODetailID=_cuSODetailID and cuInvoiceID = _cuInvoiceID;
                        
                        if (_count >0) THEN 
							SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:cuInvoiceDetail not found';
							leave INVOICE_updateInvoiceDetail; 
						END IF;
*/                        
						select
						so.cuSOID, p.prMasterID, so.prFromWarehouseID,
                        p.IsInventory,detail.HasSingleItemTaxAmount,detail.whseCost,0
                        into
						_cuSOID, _prMasterID, _prWarehouseID,
                        _IsInventory,_HasSingleItemTaxAmount,_whseCost,_onOrder           
						from cuSODetail detail  
						left join cuSO so on (so.cuSOID = detail.cuSOID)
						left join prMaster p on (p.prMasterID = detail.prMasterID)
						where detail.cuSODetailID =_cuSODetailID;
						
                        if (_prMasterID is null)
						THEN 
							SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:Required: _prMasterID after cuSO not found';
							leave INVOICE_updateInvoiceDetail; 
						END IF;
						
						select count(*) into _position from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
										
						insert into cuInvoiceDetail 
							(cuInvoiceID,cuSODetailID,prMasterID,Description,Note,QuantityBilled,UnitCost,PriceMultiplier,Taxable,HasSingleItemTaxAmount,whseCost,position,onOrder) 
							values 
							(_cuInvoiceID,_cuSODetailID,_prMasterID,_Description,_Note,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,_HasSingleItemTaxAmount,_whseCost,_position,_onOrder);
				 
							SELECT LAST_INSERT_ID() INTO _cuInvoiceDetailID;
						   
						if(_isQPItemCode=1) then 
								if(_QuantityBilled >= 0) then
									set _isQPItemCodeQty = 1;
								else
									set _isQPItemCodeQty = -1;
								end if;
							end if;
						
						update cuSODetail set QuantityBilled=IF(_isQPItemCode=1,_isQPItemCodeQty,QuantityBilled+_QuantityBilled) where cuSODetailID=_cuSODetailID;
						
												
						if (_IsInventory=1 and _QuantityBilled<>0 and _isQPItemCode = 0) THEN

							set _quantityChanged = _QuantityBilled;
                            set _isNew =1 ; -- this is an insert.
                            
						END IF; 
					
					elseif (_vePODetailID is not null) THEN
											
						select
						so.vePOID, p.prMasterID, so.prWarehouseID,
                        
                        p.IsInventory,0 as HasSingleItemTaxAmount,p.POCost as whseCost,0
                        into
						_cuSOID, _prMasterID, _prWarehouseID, 
                       
                        _IsInventory,_HasSingleItemTaxAmount,_whseCost,_onOrder           
						from vePODetail detail  
						left join vePO so on (so.vePOID = detail.vePOID)
						left join prMaster p on (p.prMasterID = detail.prMasterID)
						where detail.vePODetailID =_vePODetailID;
						
						if (_prMasterID is null)
						THEN 
							SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:Required: _prMasterID after vePO not found';
							leave INVOICE_updateInvoiceDetail; 
						END IF;
						
						select count(*) into _position from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
						
						insert into cuInvoiceDetail 
							(cuInvoiceID,cuSODetailID,prMasterID,Description,Note,QuantityBilled,UnitCost,PriceMultiplier,Taxable,HasSingleItemTaxAmount,whseCost,position,onOrder) 
							values 
							(_cuInvoiceID,_vePODetailID,_prMasterID,_Description,_Note,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,_HasSingleItemTaxAmount,_whseCost,_position,_onOrder);
				 
							SELECT LAST_INSERT_ID() INTO _cuInvoiceDetailID;
                            				
					ELSEIF (_cuSODetailID is null and  _vePODetailID is null and _prMasterID is not null) THEN
					
							
						select 
						
                        p.IsInventory 
                        into 
                        
                        _IsInventory
						from prMaster p 
						where p.prMasterID = _prMasterID;
						select count(*) into _position from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
                        
						insert into cuInvoiceDetail 
						(cuInvoiceID,cuSODetailID,prMasterID,Description,Note,QuantityBilled,UnitCost,PriceMultiplier,Taxable,HasSingleItemTaxAmount,whseCost,position,onOrder) 
						values 
						(_cuInvoiceID,null,_prMasterID,_Description,_Note,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,0,0,_position+1,0);
			 
						SELECT LAST_INSERT_ID() INTO _cuInvoiceDetailID;
					
                    else
                    
							SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:Required: _prMasterID ';
							leave INVOICE_updateInvoiceDetail; 
					END IF;
                    
		ELSE  -- _cuInvoiceDetailID is not null
        
				select d.QuantityBilled,d.prMasterID, i.prFromWarehouseID, s.cuSOID, d.cuSODetailID, p.IsInventory, s.QuantityOrdered 
				into _LastQuantityBilled,_prMasterID, _prWarehouseID, _cuSOID, _cuSODetailID ,  _IsInventory, _soDetailOrdered
				from cuInvoiceDetail d 
				left join cuInvoice i on (i.cuInvoiceID = d.cuInvoiceID)
                left join cuSODetail s on (s.cuSODetailID = d.cuSODetailID)
				left join prMaster p on (p.prMasterID = d.prMasterID)
				where cuInvoiceDetailID = _cuInvoiceDetailID;

			if (_DEBUG  in (3)) THEN 
				select 'INVOICE_updateInvoiceDetail _cuInvoiceDetailID is not null',_IsInventory,_LastQuantityBilled,_QuantityBilled,_soDetailOrdered,_soDetailOrdered;
			END IF;				
        
				if (_IsInventory =1 and _LastQuantityBilled <> _QuantityBilled) THEN
 
					if (_soDetailOrdered is not null and _QuantityBilled > _soDetailOrdered) THEN
							SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoiceDetail:QuantityBilled can not be greater than OrderQuantity ';
 							leave INVOICE_updateInvoiceDetail;                    
                    END IF;
                    					
					set _quantityChanged = _QuantityBilled - _LastQuantityBilled;
					set _isNew =0;
                    
				ELSE
					set _quantityChanged = 0;
                END IF;
      
		END IF;          

                
		if (_isNew=0 and _IsInventory =1 and _QuantityBilled <> 0 and _quantityChanged <>0 and _isQPItemCode=0) THEN

			if (_DEBUG  in (3)) THEN 
				select 'INVOICE_updateInvoiceDetail NOT NEW, EDIT INVOICE before CREDIT',_QuantityBilled,_quantityChanged,bin.* from bin where prMasterID = _prMasterID;
			END IF;				
					
			call INVOICE_updateInvoiceDetail_binplan('CREDIT',_cuSODetailID,null,_cuInvoiceDetailID,null,null,null,_changedByID,_DEBUG);

			if (_DEBUG  in (3)) THEN 
				select 'INVOICE_updateInvoiceDetail NOT NEW, EDIT after CREDIT ',bin.* from bin where prMasterID = _prMasterID;
			END IF;				

			call INVOICE_updateInvoiceDetail_binplan('BUILD',_cuSODetailID,_cuInvoiceID,_cuInvoiceDetailID,_QuantityBilled,_referenceNo,_refRelatedNo,_changedByID,_DEBUG);

			if (_DEBUG  in (3)) THEN 
				select 'INVOICE_updateInvoiceDetail NOT NEW, after BUILD ',_QuantityBilled,bin.* from bin where prMasterID = _prMasterID;
			END IF;				
							
													
		ELSEif (_isNew=1 and _IsInventory =1 and _cuSODetailID is not null and _QuantityBilled <> 0  and _isQPItemCode=0) THEN
							
			if (_DEBUG  in (3)) THEN 
				select 'INVOICE_updateInvoiceDetail NEW',_QuantityBilled;
			END IF;				

			call INVOICE_updateInvoiceDetail_binplan('BUILD',_cuSODetailID,_cuInvoiceID,_cuInvoiceDetailID,_QuantityBilled,_referenceNo,_refRelatedNo,_changedByID,_DEBUG);

		ELSEif (_IsInventory =1 and _cuSODetailID is not null and _quantityChanged= 0 and _isQPItemCode=0) THEN

			if (_DEBUG  in (3)) THEN 
				select 'INVOICE_updateInvoiceDetail NOTHING CHANGED',_QuantityBilled,_quantityChanged;
			END IF;				
							
			-- NOTHING HAS CHANGED IN THE QUANTITY.                        
			set _quantityChanged = 0;
							
		END IF;
									
		-- global operations
		update cuInvoiceDetail set QuantityBilled = _QuantityBilled,UnitCost=_UnitCost,Taxable=_Taxable,PriceMultiplier=_PriceMultiplier,Note=_Note,Description=_Description where cuInvoiceDetailID = _cuInvoiceDetailID;
		
		if (_cuSODetailID is not null and  _isQPItemCode=0) Then	
					
			select Sum(QuantityBilled) into  _QuantityBilled 
			from cuInvoiceDetail d
            left join cuInvoice i on (i.cuInvoiceID = d.cuInvoiceID)
			left join prMaster p on (p.prMasterID = d.prMasterID)
			where d.cuSODetailID = _cuSODetailID and p.isInventory=1 and i.TransactionStatus =1;
							
			update cuSODetail set QuantityBilled = _QuantityBilled where cuSODetailID = _cuSODetailID; 
					
		END IF;

		if (_DEBUG  in (2,3)) THEN 

			select 'INVOICE_updateInvoiceDetail cuSODetail',d.* from cuSODetail d where cuSODetailID=_cuSODetailID; 
			select 'INVOICE_updateInvoiceDetail cuSODetailBin',d.* from cuSODetailBin d where cuSODetailID=_cuSODetailID; 
			select 'INVOICE_updateInvoiceDetail cuSODetailTicket',d.* from cuSODetailTicket d where cuSODetailId = _cuSODetailID and ticketStatus=1 ;
			select 'INVOICE_updateInvoiceDetail cuInvoiceDetail',d.* from cuInvoiceDetail d where cuInvoiceDetailID = _cuInvoiceDetailID; 
			select 'INVOICE_updateInvoiceDetail cuInvoiceDetailBin',d.* from cuInvoiceDetailBin d where cuInvoiceDetailID = _cuInvoiceDetailID;
			
			if (_binId is null) THEN select binId into _binId from bin where prMasterID=_prMasterID and prWarehouseID =  _prWarehouseID order by binSequence limit 1; END IF;
			
			select 'INVOICE_updateInvoiceDetail bin',d.* from bin d where binId = _binId;
			select 'INVOICE_updateInvoiceDetail',_isNew, _cuInvoiceDetailID,_cuSODetailID,_QuantityBilled,_quantityChanged,_LastQuantityBilled,_isQPItemCode,_prMasterID,_prWarehouseID;
			
		END IF;
		
    END IF;
   
ELSEif (_action = 'DELETE' and _cuInvoiceDetailID is not null) THEN
	
	SELECT CASE jr.ReleaseType WHEN 1 THEN "DropShip" WHEN 2 THEN "StockOrder" WHEN 3 THEN "BillOnly" WHEN 4 THEN "CommissionOrder" WHEN 5 THEN "ServiceOrder" ELSE "SalesOrder" END AS releaseType INTO _joReleaseType
	FROM cuInvoiceDetail cid 
	LEFT JOIN cuInvoice ci ON(cid.cuInvoiceId=ci.cuInvoiceId)
	LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID) 
	LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
	WHERE cid.cuInvoiceDetailId=_cuInvoiceDetailID;
 

	select d.QuantityBilled,d.prMasterID, i.prFromWarehouseID, d.cuSODetailID, p.IsInventory
    into _LastQuantityBilled,_prMasterID, _prWarehouseID, _cuSODetailID ,  _IsInventory
    from cuInvoiceDetail d 
    left join cuInvoice i on (i.cuInvoiceID = d.cuInvoiceID)
    left join prMaster p on (p.prMasterID = d.prMasterID)
    where cuInvoiceDetailID = _cuInvoiceDetailID;
    
    if (_IsInventory =1 AND (_joReleaseType <> ('DropShip' || 'CommissionOrder') )) THEN
    
		
		LEAVE INVOICE_updateInvoiceDetail;
        
        
		delete from cuInvoiceDetailBin where cuInvoiceDetailBinID = _cuInvoiceDetailBinID;
		
		select binId into _binId from bin where prMasterID=_prMasterID and prWarehouseID =  _prWarehouseID order by binSequence limit 1;
            
        
		call INV_updateOH('ADJUST',_binId,(_LastQuantityBilled),null,null,_changedByID);
								
		call INV_updateInventoryLog('INSERT',_binId,'CI',_cuInvoiceID,_cuInvoiceDetailID,_referenceNo,_LastQuantityBilled,0,'Customer Invoice Delete',_changedByID,null,_refRelatedNo);
		
    
    END IF; 
	delete from cuInvoiceDetail where cuInvoiceDetailID = _cuInvoiceDetailID;
	
     IF (_vePODetailID is not null) THEN
 
            select Sum(QuantityBilled) into  _QuantityBilled from cuInvoiceDetail where cuSODetailID = _vePODetailID;
			
			update vePODetail set QuantityBilled =  _QuantityBilled where vePODetailID = _vePODetailID;
     ELSEIF (_cuSODetailID is not null) THEN
             select Sum(QuantityBilled) into  _QuantityBilled from cuInvoiceDetail where cuSODetailID = _cuSODetailID;
			
			update cuSODetail set QuantityBilled = _QuantityBilled where cuSODetailID = _cuSODetailID;
 
	END IF;
	select Subtotal,Freight,TaxAmount,coTaxTerritoryID,InvoiceDate 
    into _lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastinvoiceDate  from cuInvoice where cuInvoiceID = _cuInvoiceID;
	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_changedByID,'CI-Line Item(s) Deleted',_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastinvoiceDate);
    
END IF; 
select _cuInvoiceDetailID;
END$$

DELIMITER ;
-- ==================================================================== INVOICE_recalculate


-- ====================================================================
-- call INVOICE_updateInvoiceDetail_binplan('BUILD',cuSODetailID,_cuInvoiceID,cuInvoiceDetailID,QuantityBilled,_referenceNo,_refRelatedNo,userId,debug);
-- call INVOICE_updateInvoiceDetail_binplan('CREDIT',cuSODetailID,_cuInvoiceID,cuInvoiceDetailID,QuantityBilled,_referenceNo,_refRelatedNo,userId,debug);

DROP procedure IF EXISTS `INVOICE_updateInvoiceDetail_binplan`;

DELIMITER $$



CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_updateInvoiceDetail_binplan`(
IN _action varchar(20),
IN _cuSODetailID INT,
IN _cuInvoiceID INT,
IN _cuInvoiceDetailID INT,
IN _QuantityBilled  decimal(19,4),
IN _referenceNo VARCHAR(100),
IN _refRelatedNo VARCHAR(100),
IN _changedByID INT,
IN _DEBUG tinyint
)
INVOICE_updateInvoiceDetail_binplan: BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.1'; -- initial

DECLARE _stopBilling TINYINT DEFAULT 0;
DECLARE _isNew TINYINT DEFAULT 0;

DECLARE _cuSOID INT;
DECLARE _cuSODetailBinID INT;
DECLARE _cuInvoiceDetailBinID INT;
DECLARE _binId INT;
DECLARE _InventoryOnHand decimal(19,4);
DECLARE _quantityChanged decimal(19,4);
DECLARE _soDetailOrdered decimal(19,4);
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _ids varchar(255);
DECLARE _ID INT;
DECLARE _AvailableToBillInThisBin  decimal(19,4);
DECLARE _TotalLeftTobeBilled  decimal(19,4);
DECLARE _AmountTobeBilledThisTime  decimal(19,4);
DECLARE _alreadyBilled  decimal(19,4);
DECLARE _issue tinyint;

if (_action = 'CREDIT') THEN

							select GROUP_CONCAT(cuInvoiceDetailBinID) into _ids from  cuInvoiceDetailBin
                            where cuInvoiceDetailID = _cuInvoiceDetailID;
							                            
                            do_this:
							LOOP
								 SET strLen = CHAR_LENGTH(_ids);										
								 set _ID=SUBSTRING_INDEX(_ids, ',', 1);

						select QuantityBilled, binId, cuSODetailBinID into _AmountTobeBilledThisTime, _binId,_cuSODetailBinID from cuInvoiceDetailBin where cuInvoiceDetailBinID = _ID;

		if (_DEBUG  in (3)) THEN 
			select 'INVOICE_updateInvoiceDetail_binplan credit back',_AmountTobeBilledThisTime,_binId,_cuSODetailID,_cuSODetailBinID,_cuInvoiceDetailID,_ids,_ID;
		END IF;
                        
                        if (_binId is not null) THEN
                        
							call INV_updateOH('ADJUST',_binId,( _AmountTobeBilledThisTime),(_AmountTobeBilledThisTime),null,_changedByID);
							update cuSODetail set QuantityBilled = QuantityBilled - _AmountTobeBilledThisTime where cuSODetailID = _cuSODetailID;
							update cuSODetailBin set QuantityBilled = QuantityBilled - _AmountTobeBilledThisTime where cuSODetailBinID = _cuSODetailBinID;
                            
                            -- make sure it does not go neg
                            set _issue = 0;
                            select count(*) into _issue from cuSODetail where QuantityBilled <0 and cuSODetailID = _cuSODetailID;
							if (_issue>0) THEN update cuSODetail set QuantityBilled = 0 where cuSODetailID = _cuSODetailID; END IF;
                            
                            set _issue = 0;
                            select count(*) into _issue from cuSODetailBin where QuantityBilled <0 and cuSODetailBinID = _cuSODetailBinID;
							if (_issue>0) THEN update cuSODetailBin set QuantityBilled = 0 where cuSODetailBinID = _cuSODetailBinID; END IF;

							call INV_updateInventoryLog('INSERT',_binId,'CI',_cuInvoiceID,_cuInvoiceDetailID,_referenceNo,0,_AmountTobeBilledThisTime,'Customer Invoice Change',_changedByID,null,_refRelatedNo);
                            
						END IF;
                        

								 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
								 SET _ids = MID(_ids, SubStrLen, strLen);
								 IF _ids = '' or _ids is null THEN
								   LEAVE do_this;
								 END IF;
								 
							END LOOP do_this;

                        delete from cuInvoiceDetailBin where cuInvoiceDetailID =_cuInvoiceDetailID;


elseif (_action = 'BUILD') THEN
                        
                        set _stopBilling=0;
                        set _TotalLeftTobeBilled = _QuantityBilled;
                        
                        -- THIS IS AN INSERT, so base on the ticket plan
                        delete from cuInvoiceDetailBin where cuInvoiceDetailID =_cuInvoiceDetailID;
                        
							-- set _TotalLeftTobeBilled = _onOrder;
							set _ids = null;
							set _ID = null;
                            
							select GROUP_CONCAT(pickTicketId) into _ids from cuSODetailTicket 
                            where ticketStatus=1 and cuSODetailId=_cuSODetailID;
							
                            
                            do_this:
							LOOP
								 SET strLen = CHAR_LENGTH(_ids);										
								 set _ID=SUBSTRING_INDEX(_ids, ',', 1);

						select (t.toPick-b.QuantityBilled) ,t.binId,b.cuSODetailBinID,b.QuantityBilled 
                        into _AmountTobeBilledThisTime,_binId,_cuSODetailBinID,_alreadyBilled 
                        from cuSODetailTicket t
                        left join cuSODetailBin b on (b.cuSODetailID = _cuSODetailID and b.binId = t.binId) 
                        where  pickTicketId = _ID;

	if (_DEBUG  in (3)) THEN 
		select 'INVOICE_updateInvoiceDetail_binplan BUILD cuSODetailTicket ',_action,_ids,_ID as pickTicketId,_QuantityBilled,_alreadyBilled,_AmountTobeBilledThisTime as toPick,_binId,_cuSODetailBinID,_cuInvoiceDetailID; 
	END IF;
    
					-- CHECK IF toPick<0 THEN special insert/create  ELSE normal
					if (_AmountTobeBilledThisTime<0) THEN

							insert into cuInvoiceDetailBin (cuInvoiceDetailID,cuSODetailBinID,binId,QuantityBilled,txState,lastUpdated)
							values (_cuInvoiceDetailID,_cuSODetailBinID,_binId,_AmountTobeBilledThisTime,'I',now());
						   
						-- set QuantityBilled in cuInvoiceDetailBin and update cuSODetailBin
							call INV_updateOH('ADJUST',_binId,(-1*_AmountTobeBilledThisTime),null,null,_changedByID);
							call INV_updateInventoryLog('INSERT',_binId,'CI',_cuInvoiceID,_cuInvoiceDetailID,_referenceNo,0,_AmountTobeBilledThisTime,'Customer Invoice Change',_changedByID,null,_refRelatedNo);

							update cuSODetailBin set QuantityBilled = QuantityBilled+_AmountTobeBilledThisTime where cuSODetailBinID  = _cuSODetailBinID;
                    
                    ELSE


						if (_AmountTobeBilledThisTime> _TotalLeftTobeBilled) THEN    
							set _AmountTobeBilledThisTime = _TotalLeftTobeBilled;
							-- we will stop billing after this is appllied.
                            set _TotalLeftTobeBilled = -1;
                        END IF;    
					
						set _TotalLeftTobeBilled = _TotalLeftTobeBilled  - _AmountTobeBilledThisTime;
                        
						if (_binId is not null) THEN 
                   

						if (_stopBilling =0) THEN

							select cuSODetailBinID into _cuSODetailBinID from cuSODetailBin where cuSODetailID  = _cuSODetailID and binId=_binId;
                        
							insert into cuInvoiceDetailBin (cuInvoiceDetailID,cuSODetailBinID,binId,QuantityBilled,txState,lastUpdated)
							values (_cuInvoiceDetailID,_cuSODetailBinID,_binId,_AmountTobeBilledThisTime,'I',now());
						   
						-- set QuantityBilled in cuInvoiceDetailBin and update cuSODetailBin
							call INV_updateOH('ADJUST',_binId,(-1*_AmountTobeBilledThisTime),(-1*_AmountTobeBilledThisTime),null,_changedByID);
							call INV_updateInventoryLog('INSERT',_binId,'CI',_cuInvoiceID,_cuInvoiceDetailID,_referenceNo,0,_AmountTobeBilledThisTime,'Customer Invoice Change',_changedByID,null,_refRelatedNo);

							update cuSODetailBin set QuantityBilled = QuantityBilled + _AmountTobeBilledThisTime where cuSODetailBinID  = _cuSODetailBinID;
						
                        END IF;
                        
                    end if;   
                    
                    if (_TotalLeftTobeBilled<0) THEN set _stopBilling = 1; END IF;    

					END IF;

								 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
								 SET _ids = MID(_ids, SubStrLen, strLen);
								 IF _ids = '' or _ids is null THEN
								   LEAVE do_this;
								 END IF;
								 
							END LOOP do_this;
                
	-- global operations
	update cuInvoiceDetail set QuantityBilled = _QuantityBilled where cuInvoiceDetailID = _cuInvoiceDetailID;
    
	if (_cuSODetailID is not null) Then	
                
					select Sum(QuantityBilled) 
					into  _QuantityBilled 
					from cuInvoiceDetail d
					left join prMaster p on (p.prMasterID = d.prMasterID)
					where d.cuSODetailID = _cuSODetailID and p.isInventory=1;
						
					update cuSODetail set QuantityBilled = _QuantityBilled where cuSODetailID = _cuSODetailID; 
				
	END IF;


	if (_DEBUG  in (2,3)) THEN 

		select 'INVOICE_updateInvoiceDetail_binplan BUILD cuSODetail',d.* from cuSODetail d where cuSODetailID=_cuSODetailID; 
		select 'INVOICE_updateInvoiceDetail_binplan BUILD cuSODetailBin',d.* from cuSODetailBin d where cuSODetailID=_cuSODetailID; 
		select 'INVOICE_updateInvoiceDetail_binplan BUILD cuSODetailTicket',d.* from cuSODetailTicket d where cuSODetailId = _cuSODetailID and ticketStatus=1 ;
		select 'INVOICE_updateInvoiceDetail_binplan BUILD cuInvoiceDetail',d.* from cuInvoiceDetail d where cuInvoiceDetailID = _cuInvoiceDetailID; 
		
		-- if (_binId is null) THEN select binId into _binId from bin where prMasterID=_prMasterID and prWarehouseID =  _prWarehouseID order by binSequence limit 1; END IF;
		
		-- select 'INVOICE_updateInvoiceDetail',_cuInvoiceDetailID,_cuSODetailID,_QuantityBilled,_quantityChanged,_LastQuantityBilled,_prMasterID,_prWarehouseID;
		
	END IF;

	if (_DEBUG  in (1,2,3)) THEN 
		select 'INVOICE_updateInvoiceDetail_binplan BUILD cuInvoiceDetailBin',d.* from cuInvoiceDetailBin d where cuInvoiceDetailID = _cuInvoiceDetailID;
		-- select 'INVOICE_updateInvoiceDetail_binplan',d.* from bin d where prMasterID = _prMasterID;
	END IF;

END IF;		
        
END$$

DELIMITER ;
-- ==================================================================== INVOICE_updateInvoiceDetail_binplan





-- ====================================================================
-- call SO_updateSO('SET_STATUS',cuSOID,_TransactionStatus,userId,debug);

DROP procedure IF EXISTS `SO_updateSO`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `SO_updateSO`(
IN _action varchar(20),
IN _cuSOID INT,
IN _TransactionStatus INT,
IN _changedByID INT,
IN _DEBUG tinyint
)
SO_updateSO: BEGIN

DECLARE _version varchar(10) DEFAULT '1.1';
DECLARE _current int;

if (_DEBUG  in (1)) THEN 
	select 'SO_updateSO ',_version,_cuSOID,_TransactionStatus;
END IF;


if (_action = 'SET_STATUS') THEN
   
-- 	case 'Void' setStatus = -1; 
-- 	case 'Quote' setStatus = -2;
-- 	case 'OnHold' setStatus = 0;
-- 	case 'Open' setStatus = 1;
-- 	case 'Book as Job' setStatus = 3;
-- 	case 'Import to Job' setStatus = 4;
-- 	case 'Closed' setStatus = 2;

	-- TODO validate 3,4
	if ( _TransactionStatus in (-1,-2,0,2,3,4) ) THEN

		-- currently only handles VOID and CLOSED.  Will mark tickets
        
        select TransactionStatus into _current from cuSO where cuSOID = _cuSOID;
        
        if (_current <> _TransactionStatus) THEN
			call INV_releaseSOAllocation(null,_cuSOID,null,_changedByID,_DEBUG);		
			update cuSO set TransactionStatus=_TransactionStatus,ChangedByID=_changedByID,ChangedOn=now()  where cuSOID=_cuSOID;
		END IF;
        
        -- TODO - handle any tickets? or if it is currently invoiced, etc...
        
        
	ELSEif (_TransactionStatus=1) THEN -- OPEN the SO
 
         select TransactionStatus into _current from cuSO where cuSOID = _cuSOID;

         if (_current is null or _current = -2 or _current = 0) THEN
			update cuSO set TransactionStatus=_TransactionStatus,ChangedByID=_changedByID,ChangedOn=now()  where cuSOID=_cuSOID;
		END IF;
   
        -- we will let the user hit the printTicket to generate the bins.
    END IF;
    
END IF;		
        
END$$

DELIMITER ;
-- ==================================================================== SO_updateSO



-- call INV_testCreateDelete('DELETE');
-- call TEST_inventoryService('SO_TICKET_VOID_DEBUG'); -- so=150, VOID
-- call TEST_inventoryService('SO_TICKET_INVOICE_VOID_DEBUG'); -- so=150, invoice=100, VOID

-- ====================================================================
-- call INV_releaseSOAllocation(null,cuSOID,cuSODetailID,1,1);

DROP procedure IF EXISTS `INV_releaseSOAllocation`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_releaseSOAllocation`(
IN _action varchar(20),
IN _cuSOID INT, -- if null, then only the detail is released.  
IN _cuSODetailID INT, -- trumps cuSOID
IN _changedByID INT,
IN _DEBUG tinyint
)
INV_releaseSOAllocation: BEGIN

DECLARE _version varchar(10) default '2.0'; -- added code to initialize some variables.

DECLARE _allocatedReturned INT;
DECLARE _QuantityBilled INT;
DECLARE _TransactionStatus INT;
DECLARE _binIdS VARCHAR(2000);
DECLARE _detailIDs  VARCHAR(2000);
DECLARE _aBinId INT;
DECLARE _acuSODetailBinId INT;
DECLARE _acuSODetailID INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE strLen2    INT DEFAULT 0;
DECLARE SubStrLen2 INT DEFAULT 0;

if (_DEBUG in (1) ) THEN select 'INV_releaseSOAllocation',_version,_cuSOID,_cuSODetailID; END IF;

if ( _cuSODetailID is NULL and _cuSOID is null) THEN
	leave INV_releaseSOAllocation;
END IF;

-- get the cuSOID if it was passed in null
if (_cuSOID is null) THEN
	select cuSOID into _cuSOID from cuSODetail where cuSODetailID = _cuSODetailID limit 1;
END IF;

if ( _cuSOID is null) THEN
	if (_DEBUG in (1) ) THEN select 'INV_releaseSOAllocation cuSOID not found _cuSODetailID=', _cuSODetailID; END IF;
	leave INV_releaseSOAllocation;
END IF;

-- 	case 'Void' setStatus = -1; 
-- 	case 'Quote' setStatus = -2;
-- 	case 'OnHold' setStatus = 0;
-- 	case 'Open' setStatus = 1;
-- 	case 'Book as Job' setStatus = 3;
-- 	case 'Import to Job' setStatus = 4;
-- 	case 'Closed' setStatus = 2;

-- find out if already voided or closed.
select TransactionStatus into _TransactionStatus from cuSO where cuSOID = _cuSOID;
if ( _TransactionStatus in (-1,-2,0,2,3,4) ) THEN
	if (_DEBUG in (1) ) THEN select 'INV_releaseSOAllocation already RELEASED =', _cuSOID; END IF;
	leave INV_releaseSOAllocation;
END IF;

	-- now iterate the cuSODetails
     select group_concat(cuSODetailID) into _detailIDs from cuSODetail where cuSOID=_cuSOID; 

		 details_loop:
		   LOOP
				SET strLen = CHAR_LENGTH(_detailIDs);
				set _acuSODetailID=SUBSTRING_INDEX(_detailIDs, ',', 1);
               
               -- process either just the identified cuSODeatilID or all of them
               if (_cuSODetailID is null or _acuSODetailID=_cuSODetailID) THEN
               
				-- get the bins for this detail
				  select group_concat(cuSODetailBinID) into _binIds from cuSODetailBin where cuSODetailID=_acuSODetailID; 

				  if (_DEBUG in (2) ) THEN select 'INV_releaseSOAllocation Backing out _cuSODetailID =',_acuSODetailID,_cuSOID, _binIds, b.* from cuSODetailBin b where cuSODetailID=_acuSODetailID; END IF;

					 bin_loop:
					   LOOP
							set _aBinId = null;
                            set _allocatedReturned=0;
							SET strLen2 = CHAR_LENGTH(_binIds);
							set _acuSODetailBinId=SUBSTRING_INDEX(_binIds, ',', 1);
						   
                           -- get home much is left to return (figure out how to handle already billed)
							select b.binId, (b.allocated- ifnull(d.QuantityBilled,0)),ifnull(d.QuantityBilled,0) into _aBinId,_allocatedReturned,_QuantityBilled 
                            from cuSODetailBin b
							left join cuInvoiceDetailBin d on (d.cuSODetailBinID = b.cuSODetailBinID)
							where b.cuSODetailBinID = _acuSODetailBinId;
							
							if (_aBinId is not null and _allocatedReturned > 0) THEN
								if (_DEBUG in (3) ) THEN select 'INV_releaseSOAllocation Backing out cuSODetailBins and REMOVING cuSODetailBin =', _aBinId, _allocatedReturned, _QuantityBilled, b.* from cuSODetailBin b where cuSODetailBinID=_acuSODetailBinId; END IF;
								call INV_updateOH('ADJUST',_aBinId,null,(-1*_allocatedReturned),null,_changedByID);

								-- does this create an issue for invoice changes later?
								-- delete from cuInvoiceDetailBin where cuSODetailBinID = _acuSODetailBinId;				
								delete from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;
							END IF;


							SET SubStrLen2 = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
							SET _binIds = MID(_binIds, SubStrLen2, strLen2);
							IF (_binIds = '' or _binIds is null) THEN
							   LEAVE bin_loop;
							END IF;
								
						END LOOP bin_loop;  
 
               END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_detailIDs, ',', 1))+2;
				SET _detailIDs = MID(_detailIDs, SubStrLen, strLen);
				IF (_detailIDs = '' or _detailIDs is null) THEN
				   LEAVE details_loop;
				END IF;
                    
			END LOOP details_loop; 

		if (_cuSODetailID is null) THEN
			update  cuSODetailTicket t set t.ticketStatus=2 where t.ticketStatus=1 and cuSOID=_cuSOID ;
		ELSE
			update  cuSODetailTicket t set t.ticketStatus=2 where t.ticketStatus=1 and cuSODetailID = _cuSODetailID;
        END IF;
END$$

DELIMITER ;

-- ==================================================================== INV_releaseSOAllocation

            


