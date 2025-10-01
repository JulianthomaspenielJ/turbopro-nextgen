DROP procedure IF EXISTS `INV_testInventoryService`;

-- https://docs.google.com/spreadsheets/d/1vUwR0BC35ZNjUIxymGSRo2o_mWVOj_NBvfO1CUHxQeA/edit#gid=1245640104     "Test cards link"
-- ============== TESTING THIS SHOULD BE THE LAST PROCEDURE

-- ==============================================
-- call INV_testCreateDelete('DELETE_GL_DEBUG'); -- GL and DEBUG are optional.  w/o GL, GL not deleted.

--  PASS call TEST_inventoryService('SO_TO_VOID_DEBUG');
--  PASS call TEST_inventoryService('SO_ONHOLD_TO_OPEN_DEBUG');
--  NOT WRITTEN - call TEST_inventoryService('SO_CLOSED_TO_OPEN_DEBUG');

-- PASS call TEST_inventoryService('SO_2_INVOICE_DEBUG');
-- CONFIRM call TEST_inventoryService('SO_2_PARTIAL_INVOICE_DEBUG');
-- CONFIRM call TEST_inventoryService('SO_2_QP_INVOICE_DEBUG');

-- PASS call TEST_inventoryService('SO_TICKET_ONLY'); -- so=150, printticket  
-- PASS call TEST_inventoryService('SO_TICKET_VOID_DEBUG'); -- so=150, VOID  
-- PASS call TEST_inventoryService('SO_TICKET_INVOICE_VOID'); -- so=150, invoice=100, VOID 
-- PASS call TEST_inventoryService('SO_TICKET_INVOICE_ALL_DEBUG'); -- so=150, invoice=150
-- PASS call TEST_inventoryService('SO_TICKET_INVOICE_PARTIAL'); -- so=150, invoice=100
-- PASS call TEST_inventoryService('SO_TICKET_INVOICE_REPRINT_TICKET'); -- so=150, invoice=100, reprint ticket
-- PASS call TEST_inventoryService('SO_FINAL_2INVOICE_DEBUG'); -- so=150, partial invoice=100, final invoice 50
-- PASS GL WRONG call TEST_inventoryService('SO_TICKET_INVOICE_ADJUSTDOWN_DEBUG'); -- set quantityBilled=150 then edit down by 50
-- PASS GL WRONG call TEST_inventoryService('SO_TICKET_INVOICE_ADJUSTUP_DEBUG'); -- invoice quantityBilled then edit up by 25
-- PASS call TEST_inventoryService('SO_TICKET_INVOICE_CHANGE_SO2INVOICE'); -- so=150, bill 100, then change so to 100
-- PASS call TEST_inventoryService('SO_NEGATIVE1'); -- cuSODetail = -100
-- MISSING call TEST_inventoryService('SO_NEGATIVE2_TICKET'); -- cuSODetail=-100 and invoice = -100
-- PASS call TEST_inventoryService('SO_MULTIPLE_INVOICE_PARTIAL'); -- cuSODetail1=150 cuSODetail2=100 and invoice = 50
-- PASS call TEST_inventoryService('SO_TICKET_BACKORDER_DEBUG'); -- so=250, printticket

-- customer invoices
-- PASS call TEST_inventoryService('INVOICE_CHANGELINE_DEBUG');
-- FAIL call TEST_inventoryService('INVOICE_DELETELINE_DEBUG');
-- call TEST_inventoryService('INVOICE_ADDLINE_DEBUG');

-- PASS call TEST_inventoryService('ADJUSTMENT_DECREASE_DEBUG');
-- PASS call TEST_inventoryService('ADJUSTMENT_INCREASE_DEBUG');
-- PASS call TEST_inventoryService('COUNT_DECREASE_DEBUG');
-- PASS call TEST_inventoryService('COUNT_INCREASE_DEBUG');


-- PASS call TEST_inventoryService('TRANSFER_ONLY_DEBUG');
-- PASS call TEST_inventoryService('TRANSFER-CANCEL_DEBUG');
-- PASS call TEST_inventoryService('TRANSFER-THEN-RECEIVE_DEBUG');
-- PASS call TEST_inventoryService('TRANSFER-RECEIVE-UNDO_DEBUG');

-- PASS call TEST_inventoryService('RECEIVE-ITEM_DEBUG');
-- PASS call TEST_inventoryService('RECEIVE-TWICE_DEBUG');

-- vendor invoices
-- PASS call TEST_inventoryService('VePO_to_veBill_nonInventory_joRelease');
-- PASS call TEST_inventoryService('VePO_to_veBill_Inventory_joRelease');
--  call TEST_inventoryService('VePO_to_veBill_Inventory_nojoRelease_stockOrder');
-- PASS call TEST_inventoryService('VeBill_AVGCOST');
-- PASS call TEST_inventoryService('Vendor_Invoice_Insert_DEBUG');
-- PASS call TEST_inventoryService('Vendor_Invoice_Edit_Values_DEBUG');
-- IGNORE call TEST_inventoryService('Vendor_Invoice_Edit_Non-Values_DEBUG');


DROP procedure IF EXISTS `TEST_inventoryService`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `TEST_inventoryService`(
	IN _action varchar(100)
)
TEST_inventoryService : BEGIN
DECLARE _coTaxTerritoryID INT;
DECLARE _prMasterID INT;
DECLARE _prMasterID2 INT DEFAULT -1;
DECLARE _coDivisionID INT;
DECLARE _cuTermsID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _prToWarehouseID INT;
DECLARE _fromBinID INT;
DECLARE _fromBinID2 INT;
DECLARE _toBinID INT;
DECLARE _prFromWarehouesInventoryID INT;
DECLARE _prToWarehouesInventoryID INT;
DECLARE _found INT; -- used to help determine pass/fail
DECLARE _found2 INT;
DECLARE _found3 INT;
DECLARE _found4 INT;
DECLARE _found5 INT;
DECLARE _found6 INT;
DECLARE _message varchar(500);
DECLARE _startingGlTransactionID INT;
DECLARE _startingTransferID INT;
DECLARE _qty INT;
DECLARE _theCall varchar(500);
DECLARE _prTransferDetailID INT;
DECLARE _vePOID INT;
DECLARE _vePOID2 INT;
DECLARE _vePODetailID INT;
DECLARE _vePODetailID2 INT;
DECLARE _veBillID INT;
DECLARE _veBillID2 INT;
DECLARE _veBillDetailID INT;
DECLARE _veBillDetailID2 INT;
DECLARE _veReceiveID INT;
DECLARE _veReceiveID2 INT;
DECLARE _veReceiveDetailID INT;
DECLARE _veReceiveDetailID2 INT;
DECLARE _cuSOID INT;
DECLARE _cuSOID2 INT;
DECLARE _cuSODetailID INT  DEFAULT -1;
DECLARE _cuSODetailID2 INT DEFAULT -1;
DECLARE _cuSODetailBinID INT;
DECLARE _cuInvoiceID INT;
DECLARE _cuInvoiceID2 INT;
DECLARE _cuInvoiceDetailID INT;
DECLARE _cuInvoiceDetailID2 INT;
DECLARE _cuInvoiceDetailBinID INT;
DECLARE _userID INT;
DECLARE _SONumber varchar(500);
DECLARE _SONumber2 varchar(500);
DECLARE _joMasterID INT;
DECLARE _joReleaseID INT;
DECLARE _joReleaseDetailID INT;
DECLARE _prDepartmentID INT;
DECLARE _delete INT default 0;
DECLARE _dumpTables INT default 0;
DECLARE _freight decimal(19,4);
DECLARE _UsePostDate INT;
DECLARE _rxMasterID INT;
DECLARE _freightAmount  decimal(19,4);
DECLARE _priceMultiplier  decimal(19,4);
DECLARE _taxAmount  decimal(19,4);
DECLARE _APAccountID INT;
DECLARE _lastCost decimal(19,4);
DECLARE _amount decimal(19,4);
DECLARE _subTotal  decimal(19,4);
DECLARE _result1 INT;
DECLARE _reference varchar(255);
DECLARE _reason varchar(255);
DECLARE _DEBUG tinyint;

set _userID = 1;  -- no user

set _coTaxTerritoryID=1;
set _coDivisionID =3;
set _cuTermsID =1;
set _prMasterID=10;
set _prMasterID2=11;
set _prDepartmentID=1;
set _prFromWarehouseID=1;
set _prToWarehouseID=2;
set _prFromWarehouesInventoryID=1;
set _prToWarehouesInventoryID=2;
set _rxMasterID=3;
set _vePOID2=2;
set _vePODetailID2=2;
set _vePOID=1;
set _vePODetailID=1;
set _veBillID=1;
set _veBillID2=2;
set _veBillDetailID=1;
set _veReceiveID=1;
set _veReceiveID2=2;
set _veReceiveDetailID=1;
set _veReceiveDetailID2=2;
set _cuSOID=1;
set _cuSODetailID=1;
set _cuSOID2=2;
set _cuSODetailID2=2;
set _SONumber = 'TEST_NUMBER-1';
set _SONumber2 = 'TEST_NUMBER-2';
set _joReleaseID=1;
set _joReleaseDetailID=1;
set _joMasterID=1;
set _freight=20;
set _UsePostDate = 1;
set _fromBinID=100000; 
set _fromBinID2=100001;
set _toBinID=100002;
set _cuInvoiceID=1;
set _cuInvoiceDetailID2=2;
set _cuInvoiceID2=2;
set _cuInvoiceDetailID=1;
set _freightAmount = 0.00;
set _reference = 'AUTOMATEDTEST-REFERENCE';
set _reason = 'AUTOMATEDTEST-REASONCODE';

-- select _action, LOCATE ('ADJUSTMENT',_action), LOCATE ('DECREASE',_action),LOCATE ('INCREASE',_action),LOCATE ('DEBUG',_action);

select _action;

if (LOCATE ('DEBUG',_action)>1) THEN set _DEBUG=1; END IF;

-- ======================================================
--  


IF( LOCATE ('SO_TICKET_VOID',_action)>0) THEN

	-- so=150, VOID

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSODetailID,null );
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
   -- void
   call SO_updateSO('SET_STATUS',_cuSOID,-1,_userID, CASE WHEN LOCATE ('DEBUG',_action)>0 THEN 1 ELSE null END);
 
 	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER VOID cuSO', d.* from cuSO d where cuSOID=_cuSOID;
		select 'AFTER VOID cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER VOID cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;        
		select 'AFTER VOID ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;


	-- quick test which should not reprint ticket
	-- call INV_createPickTicket_v2('CREATE',_cuSODetailID,1 );
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );
    
	select 'REPRINT AFTER VOID ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);

    
    
		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=100 and InventoryAllocated=15 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=100 and Allocated=15 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=100 and InventoryAllocated=15 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=100 and Allocated=15 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' ', _message);
 
	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

	call INV_testCreateDelete('DELETE');

ELSEIF( LOCATE ('SO_TICKET_INVOICE_VOID',_action)>0) THEN

	-- so=150, VOID

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSODetailID,null );
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;

    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	-- creates a new cuInvoiceDetailID
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	-- call INV_createPickTicket_v2('INVOICE',_cuSODetailID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );
	call INV_createPickTicket_v2('INVOICE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- select 'AFTER INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
	END IF;
    
   -- void
   call SO_updateSO('SET_STATUS',_cuSOID,-1,_userID, CASE WHEN LOCATE ('DEBUG',_action)>0 THEN 1 ELSE null END);
 
 	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER VOID cuSO', d.* from cuSO d where cuSOID=_cuSOID;
		select 'AFTER VOID cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER VOID cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;        
		select 'AFTER VOID ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;

    
    
		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=15 and InventoryAllocated=15 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=15 and Allocated=15 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=85 and InventoryAllocated=15 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=85 and Allocated=15 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' ', _message);
 
	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('VePO_to_veBill_Inventory_joRelease',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	-- 1. create vePO and vePODetail    
    set _qty = 100;
    set _amount = 10.14;
	set _freightAmount = 0;   
    set _priceMultiplier = 2;
    set _joReleaseID = 1;
    
	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,_joReleaseID,_prFromWarehouseID,3,_SONumber); -- no joRelease

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description,PriceMultiplier) 
	values (_vePODetailID,_vePOID,_prMasterID,_qty,_amount,_reason,_priceMultiplier); -- priceMultiplier =2

	set _subTotal=0;

    call VENDOR_updateInvoive("UPDATE",null,_vePOID, _rxMasterID,_joReleaseID, now(),_APAccountID,now(),
	now(),now(),0,null,0,now(),null,_freightAmount,
    _subTotal,0.00,_joReleaseID,null,_SONumber,null, _userID);
	
    select max(veBillID) into _veBillID from veBill;

	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID,_prMasterID,_qty,_amount,_priceMultiplier,0,'Note',_SONumber,_userID);
	call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select _joReleaseID;
		SELECT 'AFTER BILL vePODetail',vePOID,p.* FROM vePODetail p where vePODetailID= _vePODetailID; 
		SELECT 'AFTER BILL veBill',vePOID,p.* FROM veBill p where  veBillID= _veBillID; 
		SELECT 'AFTER BILL veBillDetail',vePOID,p.* FROM veBillDetail p where  veBillID= _veBillID; 
		select 'AFTER BILL veBillHistory',v.* from veBillHistory v  where vePODetailID in (_vePODetailID,_vePODetailID2);
		SELECT 'AFTER BILL prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID = _prMasterID;  -- 1
		call GL_print('AFTER BILL glTransaction','\'VB\'',null,null,12);	
	END IF;
	-- ================================================================================
 
 /*
 COST OF GOODS - DALLAS	2028.0000	0.0000
ACCOUNTS PAYABLE	0.0000	2028.0000
 */
		-- expected results
		set _found=null;
		select count(*) into _found from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 2028.0000 and veBillID=_veBillID;
		select count(*) into _found2 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where  g.journalID='VB' and veBillID=_veBillID;

        -- select 'Checking Results',_found , _found2   , _found3  , _found4  , _found5 ;
        
        if (_found = 1 and _found2 = 2) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL - Expected: g.credit = 2649.0100, g.credit = 100.0000, g.debit = 100.0100, g.debit = 1635.0000, g.debit = 1014.0000)';
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.reference = _SONumber2
			UNION ALL -- 1
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillID = _veBillID2 and p.journalId ='VB'; -- 1
        END IF;

	delete from veBill where veBillID in (_veBillID,_veBillID2);
	delete from veBillDetail where veBillID in (_veBillID,_veBillID2);
	delete from veBill where vePOID=_vePOID;
	delete from veBillDetail where  vePODetailID in (_vePODetailID,_vePODetailID2);
	delete from veBillHistory where vePODetailID in (_vePODetailID,_vePODetailID2);

	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('VePO_to_veBill_Inventory_nojoRelease_stockOrder',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	set _subTotal=0;

    set _qty = 100;
    set _amount = 10.14;
	-- set _lastCost = 10; -- comes from UI poCost
	set _freightAmount = 0;   
    set _priceMultiplier = 2;
    set _joReleaseID = null;
    
	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,_joReleaseID,_prFromWarehouseID,3,_SONumber); -- no joRelease

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description,PriceMultiplier) 
	values (_vePODetailID,_vePOID,_prMasterID2,_qty,_amount,_reason,_priceMultiplier); -- priceMultiplier =2

    -- 2. veReceive and veReceiveDetail
	insert IGNORE into veReceive (veReceiveID, rxMasterID, vePOID, ReceiveDate) 
	values (_veReceiveID,_rxMasterID,_vePOID,now()); -- ADP - BAS-dont use under automatic data 

	insert IGNORE into veReceiveDetail (veReceiveDetailID, veReceiveID, vePODetailID, prMasterID, Description, Note, QuantityReceived, vePOID) 
	values (_veReceiveDetailID,_veReceiveID,_vePODetailID,_prMasterID,_reason,'note',_qty,_vePOID);

	call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID,null,_userID);


    call VENDOR_updateInvoive("UPDATE",null,_vePOID, _rxMasterID,_joReleaseID, now(),_APAccountID,now(),
	now(),now(),0,null,0,now(),null,_freightAmount,
    _subTotal,0.00,_joReleaseID,null,_SONumber,null, _userID);
	
    select max(veBillID) into _veBillID from veBill;

	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID,_prMasterID,_qty,_amount,_priceMultiplier,0,'Note',_SONumber,_userID);
	call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT _joReleaseID;
		SELECT 'AFTER BILL vePODetail',_joReleaseID,vePOID,p.* FROM vePODetail p where vePODetailID= _vePODetailID; 
		SELECT 'AFTER BILL veBill',_joReleaseID,vePOID,p.* FROM veBill p where  veBillID= _veBillID; 
		SELECT 'AFTER BILL veBillDetail',vePOID,p.* FROM veBillDetail p where  veBillID= _veBillID; 
		select 'AFTER BILL veBillHistory',v.* from veBillHistory v  where vePODetailID in (_vePODetailID,_vePODetailID2);
		SELECT 'AFTER BILL prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID = _prMasterID;  -- 1
		call GL_print('AFTER BILL glTransaction','\'RI\',\'VB\'',null,null,12);	

	END IF;
	-- ================================================================================
 
 /*
 COST OF GOODS - DALLAS	2028.0000	0.0000
ACCOUNTS PAYABLE	0.0000	2028.0000
 */

		-- expected results
		set _found=null;
		select count(*) into _found from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1368.0000 and veBillID=_veBillID;
		select count(*) into _found2 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.journalID = 'VB' and veBillID=_veBillID;

        -- select 'Checking Results',_found , _found2   , _found3  , _found4  , _found5 ;
        
        if (_found = 1 and _found2 = 4) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL - Expected: g.credit = 2649.0100, g.credit = 100.0000, g.debit = 100.0100, g.debit = 1635.0000, g.debit = 1014.0000)';
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.reference = _SONumber2
			UNION ALL -- 1
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillID = _veBillID2 and p.journalId ='VB'; -- 1
        END IF;

	delete from veBill where veBillID in (_veBillID,_veBillID2);
	delete from veBillDetail where veBillID in (_veBillID,_veBillID2);
	delete from veBill where vePOID=_vePOID;
	delete from veBillDetail where  vePODetailID in (_vePODetailID,_vePODetailID2);
	delete from veBillHistory where vePODetailID in (_vePODetailID,_vePODetailID2);

	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('VePO_to_veBill_nonInventory_joRelease',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');
    
	-- 1. create vePO and vePODetail    
    set _qty = 100;
    set _amount = 10.14;
	-- set _lastCost = 10; -- comes from UI poCost
	set _freightAmount = 0;   
    set _priceMultiplier = 2;
    set _joReleaseID =1;
    
	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,_joReleaseID,_prFromWarehouseID,3,_SONumber);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description,PriceMultiplier) 
	values (_vePODetailID,_vePOID,_prMasterID2,_qty,_amount,_reason,_priceMultiplier); -- priceMultiplier =2

	set _subTotal=0;

    call VENDOR_updateInvoive("UPDATE",null,_vePOID, _rxMasterID,_joReleaseID, now(),_APAccountID,now(),
	now(),now(),0,null,0,now(),null,_freightAmount,
    _subTotal,0.00,_joReleaseID,null,_SONumber,null, _userID);
	
    select max(veBillID) into _veBillID from veBill;

	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID,_prMasterID2,_qty,_amount,_priceMultiplier,0,'Note',_SONumber,_userID);
	
    set _qty = 50;
    set _amount = 10.14;
	set _freightAmount = 0;   
    set _priceMultiplier = .5;
    
    call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID,_prMasterID2,_qty,_amount,_priceMultiplier,0,'Note',_SONumber,_userID);

	call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT _joReleaseID; 
		SELECT 'AFTER BILL vePODetail',vePOID,p.* FROM vePODetail p where vePODetailID= _vePODetailID; 
		SELECT 'AFTER BILL veBill',vePOID,p.* FROM veBill p where  veBillID= _veBillID; 
		SELECT 'AFTER BILL veBillDetail',vePOID,p.* FROM veBillDetail p where  veBillID= _veBillID; 
		select 'AFTER BILL veBillHistory',v.* from veBillHistory v  where vePODetailID in (_vePODetailID,_vePODetailID2);
		SELECT 'AFTER BILL prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID = _prMasterID2;  -- 1
		call GL_print('AFTER BILL glTransaction','\'VB\'',null,null,12);	
	END IF;
	-- ================================================================================
 
 /*
 253.5000	0.0000
2028.0000	0.0000
0.0000	2281.5000
 */
		-- expected results
		set _found=null;
		select count(*) into _found from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 2281.5000 and veBillID=_veBillID;

        -- select 'Checking Results',_found , _found2   , _found3  , _found4  , _found5 ;
        
        if (_found = 1 ) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL - Expected: g.credit = 2649.0100, g.credit = 100.0000, g.debit = 100.0100, g.debit = 1635.0000, g.debit = 1014.0000)',_veBillID;
        END IF;

	delete from veBill where veBillID in (_veBillID,_veBillID2);
	delete from veBillDetail where veBillID in (_veBillID,_veBillID2);
	delete from veBill where vePOID=_vePOID;
	delete from veBillDetail where  vePODetailID in (_vePODetailID,_vePODetailID2);
	delete from veBillHistory where vePODetailID in (_vePODetailID,_vePODetailID2);

	call INV_testCreateDelete('DELETE');



ELSEIF( LOCATE ('VeBill_AVGCOST',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');


	set _APAccountID = 160;
	set _subTotal=0;

	-- setting oldAverageCost = 0 will turn off smoothing.  oldAverageCost will be set to 0 once caught up.
	update prMaster set AverageCost=0, LastCost=0, oldAverageCost= 15 where prMasterID=_prMasterID;
	call `INV_updateOH`('REPLACE',_fromBinID,0,0,0,_userID);
	call `INV_updateOH`('REPLACE',_fromBinID2,0,0,0,_userID);
	call `INV_updateOH`('REPLACE',_toBinID,0,0,0,_userID);
    
	-- ==============================BLOCK ONE===============================
	-- 1. create vePO and vePODetail    
    set _qty = 100;
    set _amount = 10.14;
	-- set _lastCost = 10; -- comes from UI poCost
	set _freightAmount = 0;   
    
	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,1,_prFromWarehouseID,3,_SONumber);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID,_vePOID,_prMasterID,_qty,_amount,_reason);

    -- 2. veReceive and veReceiveDetail
	insert IGNORE into veReceive (veReceiveID, rxMasterID, vePOID, ReceiveDate) 
	values (_veReceiveID,_rxMasterID,_vePOID,now()); -- ADP - BAS-dont use under automatic data 

	insert IGNORE into veReceiveDetail (veReceiveDetailID, veReceiveID, vePODetailID, prMasterID, Description, Note, QuantityReceived, vePOID) 
	values (_veReceiveDetailID,_veReceiveID,_vePODetailID,_prMasterID,_reason,'note',_qty,_vePOID);

	call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID,null,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER RECEIVE prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID = _prMasterID;  -- 1
		SELECT 'AFTER RECEIVE vePODetail',vePOID,p.* FROM vePODetail p where vePODetailId = _vePODetailID  order by vePOID DESC;  -- 1
		-- SELECT 'AFTER RECEIVE veReceiveDetail',vePOID,p.* FROM veReceiveDetail p where veReceiveDetailId = _veReceiveDetailID  order by vePOID DESC; -- 1
		-- SELECT 'AFTER RECEIVE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId DESC limit 10; -- 1
		call GL_print('INVOICED BEFORE EDIT 100 glTransaction','\'RI\'',null,null,10);	
        -- SELECT 'AFTER RECEIVE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.reference = _SONumber; -- 1
	END IF;
   
    -- 3. veBill and veBillDetail

	-- set _freightAmount = 0;

    -- select LastCost into _lastCost from prMaster where prMasterID = _prMasterID;
	-- set _lastCost = 10; -- was 5 not 10;
	-- set _subTotal = 100 * _lastCost;
    
    call VENDOR_updateInvoive("UPDATE",null,_vePOID, _rxMasterID,null, now(),_APAccountID,now(),
	now(),now(),0,null,0,now(),null,_freightAmount,
    _subTotal,0.00,null,null,_SONumber,null, _userID);
	
    select max(veBillID) into _veBillID from veBill;

	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID,_prMasterID,_qty,_amount,1,0,'Note',_SONumber,_userID);
	call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER BILL veBillDetail',vePOID,p.* FROM veBillDetail p where  veBillID= _veBillID; 
		select 'AFTER BILL veBillHistory',v.* from veBillHistory v  where vePODetailID in (_vePODetailID,_vePODetailID2);
		SELECT 'AFTER BILL prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID = _prMasterID;  -- 1
		-- SELECT 'AFTER RECEIVE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId DESC limit 10; -- 1
		call GL_print('AFTER RECEIVE glTransaction','\'RI\',\'VB\'',null,null,12);	
		-- call GL_print('AFTER BILL glTransaction','RI,VB',null);

		-- SELECT 'AFTER BILL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.reference = _SONumber
        -- UNION ALL -- 1
		-- SELECT 'AFTER BILL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillID = _veBillID and p.journalId ='VB'; -- 1

		SELECT 'STARTING BLOCK 2'; 

	END IF;
	-- ================================================================================
    

	-- ==============================BLOCK TWO===============================
    
    set _qty = 100;
    set _amount = 25.49;
	-- set _lastCost = 15; -- PASSED FROM THE UI but is poCost
	set _freightAmount = 100.008;
    
	-- 1. create vePO and vePODetail    
	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID2,2,_prFromWarehouseID,3,_SONumber2);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID2,_vePOID2,_prMasterID,_qty,_amount,'Weld2');

    -- 2. veReceive and veReceiveDetail
	insert IGNORE into veReceive (veReceiveID, rxMasterID, vePOID, ReceiveDate) 
	values (_veReceiveID2,_rxMasterID,_vePOID2,now()); -- ADP - BAS-dont use under automatic data 

	insert IGNORE into veReceiveDetail (veReceiveDetailID, veReceiveID, vePODetailID, prMasterID, Description, Note, QuantityReceived, vePOID) 
	values (_veReceiveDetailID2,_veReceiveID2,_vePODetailID2,_prMasterID,'Weld','note',_qty,_vePOID2);

	call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID2,null,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER RECEIVE2 prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost FROM prMaster p where prMasterID = _prMasterID;  -- 1
		SELECT 'AFTER RECEIVE2 vePODetail',vePOID,p.* FROM vePODetail p where vePODetailId = _vePODetailID2  order by vePOID DESC;  -- 1
		-- SELECT 'AFTER RECEIVE2 veReceiveDetail',vePOID,p.* FROM veReceiveDetail p where veReceiveDetailId = _veReceiveDetailID2  order by vePOID DESC; -- 1
		-- SELECT 'AFTER RECEIVE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId DESC limit 10; -- 1
		call GL_print('AFTER RECEIVE2 glTransaction','\'RI\'',null,null,12);	
		-- SELECT 'AFTER RECEIVE2 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.reference = _SONumber2; -- 1
	END IF;
   
    -- 3. veBill and veBillDetail
	-- set _freightAmount = 0;

    -- select LastCost into _lastCost from prMaster where prMasterID = _prMasterID;
	-- set _lastCost = 15; -- PASSED FROM THE UI
	-- set _subTotal = (20 * _lastCost);
    
    call VENDOR_updateInvoive("UPDATE",null,_vePOID2, _rxMasterID,null, now(),_APAccountID,now(),
	now(),now(),0,null,0,now(),null,_freightAmount,
    _subTotal,0.00,null,null,_SONumber2,null, _userID);
	
    select max(veBillID) into _veBillID2 from veBill;

	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID2,null,_vePODetailID2,_prMasterID,_qty,_amount,1,0,'Note',_SONumber2,_userID);
	call INVOICE_recalculate("VENDORINVOICE",_veBillID2,0,_userID,null,null,null,null,null,null);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER BILL2 veBillDetail',vePOID,p.* FROM veBillDetail p where  veBillID= _veBillID2; 
		select 'AFTER BILL2 veBillHistory',v.* from veBillHistory v  where vePODetailID in (_vePODetailID,_vePODetailID2);
		SELECT 'AFTER BILL2 prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost FROM prMaster p where prMasterID = _prMasterID;  -- 1
		-- SELECT 'AFTER RECEIVE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId DESC limit 10; -- 1
		-- call GL_print('AFTER BILL2 glTransaction','VB',null);
		call GL_print('AFTER BILL2 glTransaction',null,null,null,12);	
		-- SELECT 'AFTER BILL2 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.reference = _SONumber2
        -- UNION ALL -- 1
		-- SELECT 'AFTER BILL2 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillID = _veBillID2 and p.journalId ='VB'; -- 1
	END IF;
	-- ================================================================================

        
		-- expected results
		set _found=null;
		select count(*) into _found from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 2649.0100 and veBillID=_veBillID2;
		select count(*) into _found2 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 100.0000 and veBillID=_veBillID2;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 100.0100 and veBillID=_veBillID2;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1635.0000 and veBillID=_veBillID2;
		select count(*) into _found5 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1014.0000 and veBillID=_veBillID2;

        -- select 'Checking Results',_found , _found2   , _found3  , _found4  , _found5 ;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1 and _found5 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL - Expected: g.credit = 2649.0100, g.credit = 100.0000, g.debit = 100.0100, g.debit = 1635.0000, g.debit = 1014.0000)';
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.reference = _SONumber2
			UNION ALL -- 1
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillID = _veBillID2 and p.journalId ='VB'; -- 1
        END IF;

	delete from veBill where veBillID in (_veBillID,_veBillID2);
	delete from veBillDetail where veBillID in (_veBillID,_veBillID2);
	delete from veBill where vePOID=_vePOID;
	delete from veBillDetail where  vePODetailID in (_vePODetailID,_vePODetailID2);
	delete from veBillHistory where vePODetailID in (_vePODetailID,_vePODetailID2);

	call INV_testCreateDelete('DELETE');


-- ======================================================
-- SO for 200 BO=50. 
ELSEIF( LOCATE ('SO_TICKET_BACKORDER',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	call TP_cuSODetail_update('UPDATE',_userID,_cuSOID,_cuSODetailID,null,null,null,250,null,null,null,null,null,null,null,@out);

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);

	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSO', d.* from cuSODetail d where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
	call getBinBackOrder(null,null,_prFromWarehouseID,null,null,null); 

/*
100.0000	180.0000
100.0000	100.0000

85.0000	250.0000	80.0000 -- should be 85 -- bo=80
85.0000	250.0000	0.0000 -- should be 85
*/    
		set _message = _action;
		set _found=null;
		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=100 and InventoryAllocated=180;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=100 and InventoryAllocated=100;
		select count(*) into _found3 from cuSODetailTicket where cuSOID = _cuSOID and toPick=85 and ordered=250 and backOrdered=80;
		select count(*) into _found4 from cuSODetailTicket where cuSOID = _cuSOID and toPick=85 and ordered=250 and backOrdered=0;
		-- select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 562.9000 and veBillID=_cuInvoiceID2;
 
        -- select 'Checking Results',_found , _found2   , _found3  , _found4  , _found5 ;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
			select 'FAIL', p.* from  cuSODetailTicket p where cuSOID = _cuSOID;
			select 'FAIL', p.* from  bin p where binId in (_fromBinID,_fromBinID2);
        END IF;


	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('SO_MULTIPLE_INVOICE_PARTIAL',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	insert IGNORE into cuSO (cuSOID,prFromWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID) 
	values (_cuSOID2,_prFromWarehouseID,_joReleaseID,_SONumber2,962,_coTaxTerritoryID,_SONumber,962,100,15,10.0,_freight,_coDivisionID, _cuTermsID);

	insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSODetailID2,_cuSOID2,_prMasterID,100,10,6,1);

	call TP_cuSODetail_update('UPDATE',_userID,_cuSOID,_cuSODetailID,null,null,null,150,null,null,null,null,null,null,null,@out);
	call TP_cuSODetail_update('UPDATE',_userID,_cuSOID2,_cuSODetailID2,null,null,null,100,null,null,null,null,null,null,null,@out);

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START bin',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID in (_cuSODetailID,_cuSODetailID2);

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID2,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSODetailID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );
	-- call INV_createPickTicket_v2('CREATE',_cuSODetailID2,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );

	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		-- select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID in (_cuSODetailID,_cuSODetailID2);
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID in (_cuSODetailID,_cuSODetailID2);
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID in (_cuSOID,_cuSOID2);
		select 'AFTER TICKET bin ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;


    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	-- creates a new cuInvoiceDetailID
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
	-- add invoicing.
    
		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=15 and InventoryAllocated=95 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=15 and Allocated=95 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=85 and InventoryAllocated=85 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=85 and Allocated=85 not correct');  END IF;

 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where  cuSODetailID in (_cuSODetailID,_cuSODetailID2);
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where cuSODetailID in (_cuSODetailID,_cuSODetailID2);
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID in (_cuSOID,_cuSOID2);
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;


	select concat(_action,' ', _message);
 

	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

	call INV_testCreateDelete('DELETE');


-- ======================================================
-- SO for -100.  Print Ticket

elseIF( LOCATE ('SO_NEGATIVE1',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	call TP_cuSODetail_update('UPDATE',_userID,_cuSOID,_cuSODetailID,null,null,null,-100,null,null,null,null,null,null,null,@out);

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSODetailID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=100 and InventoryAllocated=0 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=100 and Allocated=0 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=100 and InventoryAllocated=15 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=100 and Allocated=15 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' ', _message);
 

	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;


	call INV_testCreateDelete('DELETE');

-- ======================================================
-- SO for -100.  TICKET -100

ELSEIF( LOCATE ('SO_NEGATIVE2_INVOICE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	call TP_cuSODetail_update('UPDATE',_userID,_cuSOID,_cuSODetailID,null,null,null,-100,null,null,null,null,null,null,null,@out);

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSODetailID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;


    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	-- creates a new cuInvoiceDetailID
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,-100,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
        
		select 'AFTER INVOICE BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);

	END IF;

		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=200 and InventoryAllocated=0 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=200 and Allocated=0 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' ', _message);
 

	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;

	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('SO_TICKET_ONLY',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
-- 	call INV_createPickTicket_v2('CREATE',_cuSODetailID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );
	call INV_createPickTicket_v2('CREATE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=100 and InventoryAllocated=100 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=100 and Allocated=100 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=100 and InventoryAllocated=80 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=100 and Allocated=80 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' ', _message);
 
	select _message;

	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

	call INV_testCreateDelete('DELETE');

-- ======================================================
-- SO for 150.  Invoice for 150. 

ELSEIF( LOCATE ('SO_TICKET_INVOICE_ALL',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_createPickTicket_v2('CREATE',_cuSOID,null);

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	-- creates a new cuInvoiceDetailID
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,150,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
        
		select 'AFTER INVOICE BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);

	END IF;

		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=15 and InventoryAllocated=15 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=15 and Allocated=15 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=35 and InventoryAllocated=15 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=35 and Allocated=15 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
			select 'DUMP INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' ', _message);
 
	select _message;
    
	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;
    
    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
    
	call INV_testCreateDelete('DELETE');

-- ======================================================
-- SO for 150.  Invoice for 100. 

ELSEIF( LOCATE ('SO_TICKET_INVOICE_PARTIAL',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START SO',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_createPickTicket_v2('CREATE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END);

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
        -- select * from cuSO where cuSOID=_cuSOID;
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	-- creates a new cuInvoiceDetailID
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	call INV_createPickTicket_v2('INVOICE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- select 'AFTER INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
	END IF;

		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=15 and InventoryAllocated=15 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=15 and Allocated=15 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=85 and InventoryAllocated=65 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=85 and Allocated=65 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
			select 'DUMP INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' 2 ', _message);
 
	select _message;
    
	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;
    
    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
    
	call INV_testCreateDelete('DELETE');

-- ======================================================
-- SO for 150.  Invoice for 100. Reprint Ticket.  

ELSEIF( LOCATE ('SO_TICKET_INVOICE_REPRINT_TICKET',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_createPickTicket_v2('CREATE',_cuSOID,null);
    
    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	-- creates a new cuInvoiceDetailID
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
		select 'AFTER PARTIAL ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'AFTER PARTIAL cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER PARTIAL cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER PARTIAL cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;

	END IF;

	call INV_createPickTicket_v2('CREATE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
		select 'AFTER REPRINT cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
		select 'AFTER REPRINT cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER REPRINT cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER REPRINT cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
        
	END IF;


		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=15 and InventoryAllocated=15 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=15 and Allocated=15 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=85 and InventoryAllocated=35 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=85 and Allocated=35 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
			select 'DUMP INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' ', _message);
 
	select _message;
    
	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;
 
    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;

    
	call INV_testCreateDelete('DELETE');

-- ======================================================
-- SO for 150.  Invoice for 100. Reprint Ticket.  Invoice 50 (final owned)

ELSEIF( LOCATE ('SO_FINAL_2INVOICE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_createPickTicket_v2('CREATE',_cuSOID,null);

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
		select 'SO cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'SO cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'SO cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
		select 'SO bin',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);

	END IF;
    
    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	-- creates a new cuInvoiceDetailID for 100
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);
	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	-- set ticketStatus=2.  This is causing a problem for later consumption from this ticket.
	-- call INV_createPickTicket_v2('INVOICE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
		select 'AFTER 100 cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID in (_cuInvoiceDetailID,_cuInvoiceDetailID2);
		select 'AFTER 100 cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID in (_cuInvoiceDetailID,_cuInvoiceDetailID2);
		select 'AFTER 100  cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER 100  cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER 100 bin ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- SELECT 'AFTER 100 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 8; -- 1
		call GL_print('AFTER 100  glTransaction',null,null,null,12);

	END IF;

	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID2 from cuInvoice where cuSOID = _cuSOID order by cuInvoiceID desc limit 1;

	-- final bill 50
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID2,null,_cuSODetailID,null,null,50,10,1,1,null,null,_userID);
	select max(cuInvoiceDetailID) into _cuInvoiceDetailID2 from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID2;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID2,0,_userID,null,0,0,0,0,0);

	-- set ticketStatus=2
	call INV_createPickTicket_v2('INVOICE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END );

	IF( LOCATE ('DEBUG',_action)>1) THEN
    
		select 'AFTER 50 INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID in (_cuInvoiceDetailID2);
		select 'AFTER 50 INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID in (_cuInvoiceDetailID2);
		select 'AFTER 50 INVOICE  cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER 50 INVOICE  cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER 50 INVOICE cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
		select 'AFTER 50 INVOICE bin',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- SELECT 'AFTER 50 INVOICE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 15; -- 1
		call GL_print('AFTER 50 INVOICE glTransaction',null,null,null,12);	
	END IF;

/*
B1 100 15
B2 100 15

B1 100 100
B2 100 80

pick 85/65

B1 15 15
B2 85 65

B1 15 15
B2 35 15
*/

		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=15 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=35 and InventoryAllocated=15;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1104.1500 and veBillID=_cuInvoiceID;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 562.9000 and veBillID=_cuInvoiceID2;
                
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
			SELECT 'FAIL bin', b.* from bin b where binId in (_fromBinID,_fromBinID2); -- 1
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 12; -- 1
        END IF;


	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID in (_cuInvoiceID,_cuInvoiceID2);
    delete from cuInvoiceDetail where cuInvoiceID in (_cuInvoiceID,_cuInvoiceID2);
    delete from cuInvoiceDetailBin where cuInvoiceDetailID in (_cuInvoiceDetailID,_cuInvoiceDetailID2);
    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID2 order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
        
	call INV_testCreateDelete('DELETE');

-- ======================================================
-- SO for 150.  Invoice for 150..  Edit Invoice to 100 (-50)
-- product is put back into the primary bin
ELSEIF( LOCATE ('SO_TICKET_INVOICE_ADJUSTDOWN',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'SETUP',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
		select 'SETUP',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END);
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG);
 
    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,150,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'INVOICED BEFORE EDIT 150 cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'INVOICED BEFORE EDIT 150 cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'INVOICED BEFORE EDIT 150 bin',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- SELECT 'INVOICED BEFORE EDIT 150 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillId = _cuInvoiceID; -- 1
		call GL_print('AINVOICED BEFORE EDIT 150 glTransaction',null,null,null,12);	
	END IF;
   
    -- edit to remove 50
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,_cuInvoiceDetailID,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER EDIT INVOICE 100 cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER EDIT INVOICE 100 cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER EDIT INVOICE 100 cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER EDIT INVOICE 100 BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		call GL_print('AFTER EDIT INVOICE 100 glTransaction',null,null,null,12);	
		-- SELECT 'AFTER EDIT INVOICE 100 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillId = _cuInvoiceID; -- 1
	END IF;

		set _message = _action;
        
/*
B1 100 15
B2 100 15

B1 100 100
B2 100 80

pick 85/65

B1 15 15
B2 35 15

B1 15 15
B2 85 65
*/

		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=15 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=85 and InventoryAllocated=65;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1104.1500 and veBillID=_cuInvoiceID;
		-- select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 562.9000 and veBillID=_cuInvoiceID2;
                
        if (_found = 1 and _found2 = 1  and _found3 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3;
			SELECT 'FAIL bin', b.* from bin b where binId in (_fromBinID,_fromBinID2); -- 1
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 12; -- 1
        END IF;

	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;


	call INV_testCreateDelete('DELETE');


-- ======================================================
-- SO for 150.  Invoice for 100..  Edit Invoice to 175 (+25)
-- 
ELSEIF( LOCATE ('SO_TICKET_INVOICE_ADJUSTUP',_action)>0) THEN


	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'SETUP',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
		select 'SETUP',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END);
	call INV_createPickTicket_v2('CREATE',_cuSOID,null);
 
    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
    -- bill for all of it.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'INVOICED BEFORE EDIT 100 cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'INVOICED BEFORE EDIT 100 cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'INVOICED BEFORE EDIT 100 bin',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- SELECT 'INVOICED BEFORE EDIT 100 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillId = _cuInvoiceID; -- 1
		call GL_print('INVOICED BEFORE EDIT 100 glTransaction',null,null,_cuInvoiceID,null);	
	END IF;
   
    -- edit to add 25
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,_cuInvoiceDetailID,_cuSODetailID,null,null,125,10,1,1,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER EDIT INVOICE 125 cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER EDIT INVOICE 125 cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER EDIT INVOICE 125 cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER EDIT INVOICE 125 BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		call GL_print('AFTER EDIT INVOICE 125 glTransaction',null,null,_cuInvoiceID,null);	

		-- SELECT 'AFTER EDIT INVOICE 125 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where l.veBillId = _cuInvoiceID; -- 1
	END IF;


/*
B1 100 15
B2 100 15
pick 85/15

100
15.0000	15.0000
85.0000	65.0000

125
invoice 85/40

15.0000	15.0000
60.0000	40.0000

1374.7800
*/

		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=15 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=60 and InventoryAllocated=40;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1374.7800 and veBillID=_cuInvoiceID;
		-- select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 562.9000 and veBillID=_cuInvoiceID2;
                
        if (_found = 1 and _found2 = 1  and _found3 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3;
			SELECT 'FAIL bin', b.* from bin b where binId in (_fromBinID,_fromBinID2); -- 1
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 12; -- 1
        END IF;
  
	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;


	call INV_testCreateDelete('DELETE');
        

-- ======================================================
-- SO for 150.  Invoice for 100..  Edit SO to 100
ELSEIF( LOCATE ('SO_TICKET_INVOICE_CHANGE_SO2INVOICE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'SETUP',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
		select 'SETUP',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);

	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSOID,CASE WHEN LOCATE ('DEBUG',_action)>1 THEN 1 ELSE null END);
	call INV_createPickTicket_v2('CREATE',_cuSOID,null);
 
    -- rxCustomerID=625
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,Date(now()) );

	-- get the invoice that was created
	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
    -- bill for all of it.null
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,100,10,1,1,null,null,_userID);

	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'BEFORE EDIT cuSODetail',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'BEFORE EDIT cuSODetail',cuSODetail.* from cuSODetail where cuSOID in (_cuSOID);
	END IF;
   
	-- find the update SO command
    
	call TP_cuSODetail_update('UPDATE',_userID,_cuSOID,_cuSODetailID,null,null,null,100,null,null,null,null,null,null,null,@out);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER SO EDIT INVOICE cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER SO EDIT INVOICE BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;

		set _message = _action;
        
		-- expected results
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=15 and InventoryAllocated=15 ) and binId=_fromBinID;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID expected OH=15 and Allocated=15 not correct');  END IF;
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=85 and InventoryAllocated=65 ) and binId=_fromBinID2;		
        IF (_found is null) THEN set _message=concat(_message,', FAIL fromBinID2 expected OH=65 and Allocated=15 not correct');  END IF;
 
		if (CHAR_LENGTH(_message)<50) THEN 
			set _message = ' PASS'; 
		ELSE
			select 'DUMP cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
			select 'DUMP cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
			select 'DUMP INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
			select 'DUMP INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
			select 'DUMP ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
        END IF;

	select concat(_action,' 2 ', _message);
 
	select _message;
    
	-- delete cuInvoice, detail, detailBin
    delete from cuInvoice where  cuInvoiceID=_cuInvoiceID;
    delete from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
    delete from cuInvoiceDetailBin where cuInvoiceDetailID=_cuInvoiceDetailID;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
	
    call INV_testCreateDelete('DELETE');

        
ELSEIF( LOCATE ('Vendor_Invoice_Insert',_action)>0) THEN
        
	call INV_testCreateDelete('CREATETESTTABLES');

	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,1,_prFromWarehouseID,3,_SONumber);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID,_vePOID,_prMasterID,100,10,'Vulcan Mind Weld');

 	-- IF( LOCATE ('DEBUG',_action)>1) THEN
		-- select 'START BIN',_prToWarehouseID,v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
		-- select 'START vePO',s.* from vePO s where vePOID=_vePOID;
		-- select 'START vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
	-- END IF;

	set _qty=100;
    call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID,_prToWarehouseID,_userID);	
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( RECEIVE-ITEM,',_fromBinID,',','null',',',_qty,') ','_vePODetailID:',_vePODetailID,_prToWarehouseID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		-- select 'AFTER RECEIVE vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
		-- select 'AFTER RECEIVE veReceive',v.* from veReceive v where vePOID=_vePOID;
		select 'AFTER RECEIVE veReceiveDetail',v.* from veReceiveDetail v where vePOID=_vePOID;
		select 'AFTER RECEIVE bin ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
        -- SELECT 'AFTER RECEIVE-VENDOR_updateInvoiveDetail  glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.journalID in ('RI') and p.enteredBy is null  order by p.glTransactionId desc; -- 1		
		call GL_print('AFTER RECEIVE glTransaction','\'RI\'',null,null,null);	
    END IF;
    
	set _freightAmount = 10;
	set _taxAmount = 1;
	set _subTotal = 0;
	set _qty = 1;
    
    call VENDOR_updateInvoive("UPDATE",null,_vePOID, _rxMasterID,null, now(),_APAccountID,now(),
	now(),now(),0,null,0,now(),_SONumber,_freightAmount,
    _subTotal,_taxAmount,null,null,'testing',null, _userID);
	
    select max(veBillID) into _veBillID from veBill;

	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID,_prMasterID,_qty,(select LastCost from prMaster where prMasterID = _prMasterID),1,1,'Inventory',_SONumber,-998);
	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID2,_prMasterID2,_qty,(select LastCost from prMaster where prMasterID = _prMasterID2),1,1,'Non-Inventory',_SONumber,-998);
	-- note: recalculate appears to be called in VENDOR_updateInvoiveDetail as well!?
    call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);

 	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER VENDOR_updateInvoiveDetail BIN',_prToWarehouseID,v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
		-- select 'AFTER VENDOR_updateInvoiveDetail prMaster',p.LastCost,AverageCost,oldAverageCost, p.* from prMaster p where prMasterID in (_prMasterID, _prMasterID2);
		SELECT 'AFTER VENDOR_updateInvoiveDetail prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID in (_prMasterID, _prMasterID2);  -- 1
		select 'AFTER VENDOR_updateInvoiveDetail vePO',s.* from vePO s where vePOID=_vePOID;
		select 'AFTER VENDOR_updateInvoiveDetail vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
		select 'AFTER VENDOR_updateInvoiveDetail veBill',s.* from veBill s where veBillID=_veBillID;
		select 'AFTER VENDOR_updateInvoiveDetail veBillDetail',v.* from veBillDetail v  where veBillID=_veBillID;
		select 'AFTER VENDOR_updateInvoiveDetail veBillHistory',v.* from veBillHistory v  where vePODetailID in (_vePODetailID,_vePODetailID2);
        -- SELECT 'AFTER VENDOR_updateInvoiveDetail glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.journalID in ('VB','RI') and p.enteredBy is null  order by p.glTransactionId desc; -- 1		
		call GL_print('AFTER VENDOR_updateInvoiveDetail glTransaction','\'RI\',\'VB\'',null,null,null);	
	END IF;

    
/*
10-from-1	100.0000	15.0000
10-from2-1	100.0000	15.0000
Received 90
10-from-1	190.0000	15.0000
10-from2-1	100.0000	15.0000

1350-00-000	450.0000	0.0000
2001-00-000	0.0000	450.0000

*/
		set _found=null;
        -- select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=190 and InventoryAllocated=15;
        -- select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=100 and InventoryAllocated=15;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 500.0000 and enteredBy is null and journalId='RI';
 		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 161.0000 and enteredBy is null and journalId='VB';
       
        if (_found3 = 1 and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 12; -- 1
        END IF;

	delete from veReceive where vePOID=_vePOID;
	delete from veReceiveDetail where  vePOID=_vePOID;
	delete from veReceiveDetailBin where  vePODetailID=_vePODetailID;
	delete from veBill where vePOID=_vePOID;
	delete from veBillDetail where  vePODetailID in (_vePODetailID,_vePODetailID2);
	delete from veBillHistory where vePODetailID in (_vePODetailID,_vePODetailID2);

	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='RI' and enteredBy is null);
    delete FROM glTransaction where journalId='RI'  and enteredBy is null;    
	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='VB' and enteredBy is null);
    delete FROM glTransaction where journalId='VB'  and enteredBy is null;    
    
  
		call INV_testCreateDelete('DELETE');
        
ELSEIF( LOCATE ('Vendor_Invoice_Edit_Values',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,1,_prFromWarehouseID,3,_SONumber);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID,_vePOID,_prMasterID,100,10,'Vulcan Mind Weld');

	set _qty=100;
    call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID,_prToWarehouseID,_userID);	
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( RECEIVE-ITEM,',_fromBinID,',','null',',',_qty,') ','_vePODetailID:',_vePODetailID,_prToWarehouseID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER RECEIVE veReceiveDetail',v.* from veReceiveDetail v where vePOID=_vePOID;
		select 'AFTER RECEIVE-ITEM bin ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
		call GL_print('AFTER RECEIVE-VENDOR_updateInvoiveDetail glTransaction','\'RI\'',null,null,12);	
    END IF;

	set _freightAmount = 10;
	set _taxAmount = 1;
	set _subTotal = 0;
    
    call VENDOR_updateInvoive("UPDATE",null,_vePOID, _rxMasterID,null, now(),_APAccountID,now(),
	now(),now(),0,null,0,now(),_SONumber,_freightAmount,
    _subTotal,_taxAmount,null,null,'testing',null, _userID);

    select max(veBillID) into _veBillID from veBill;
	
	-- 2 item billed
    set _qty = 2;
	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,null,_vePODetailID,_prMasterID,_qty,(select LastCost from prMaster where prMasterID = _prMasterID),1,1,'Inventory',_SONumber,_userID);
	call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);

    select max(veBillDetailID) into _veBillDetailID from veBillDetail where veBillID = _veBillID;

 	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'INVOICE 2 VENDOR_updateInvoiveDetail veBill',s.* from veBill s where veBillID=_veBillID;
		select 'INVOICE 2 VENDOR_updateInvoiveDetail veBillDetail',v.* from veBillDetail v  where veBillID=_veBillID;
		select 'INVOICE 2 VENDOR_updateInvoiveDetail veBillHistory',v.* from veBillHistory v  where vePODetailID in (_vePODetailID,_vePODetailID2);
		call GL_print('INVOICE 2 VENDOR_updateInvoiveDetail glTransaction','\'RI\',\'VB\'',null,null,20);	
        SELECT 'INVOICE 2 VENDOR_updateInvoiveDetail prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID in (_prMasterID, _prMasterID2);  -- 1
		-- select 'INVOICE 2 ',_veBillID, _veBillDetailID;
	END IF;

	-- update to only 1 item billed
	set _qty = 1;
	call VENDOR_updateInvoive("UPDATE",_veBillID,_vePOID, _rxMasterID,null, now(),_APAccountID,now(),
			now(),now(),0,null,0,now(),_SONumber,_freightAmount,
			_subTotal,_taxAmount,null,null,'testing',null, _userID);
	call VENDOR_updateInvoiveDetail("UPDATE",_veBillID,_veBillDetailID,null,_prMasterID,_qty,(select LastCost from prMaster where prMasterID = _prMasterID),1,1,'Inventory',_SONumber,_userID);
	call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);
 
  	IF( LOCATE ('DEBUG',_action)>1) THEN
        SELECT 'INVOICE 1 VENDOR_updateInvoiveDetail prMaster',prMasterID, InventoryOnHand, LastCost, AverageCost, oldAverageCost, OldPrice FROM prMaster p where prMasterID in (_prMasterID, _prMasterID2);  -- 1
		select 'INVOICE 1 VENDOR_updateInvoiveDetail veBill',s.* from veBill s where veBillID=_veBillID;
		select 'INVOICE 1 VENDOR_updateInvoiveDetail veBillDetail',v.* from veBillDetail v  where veBillID=_veBillID;
		call GL_print('INVOICE 1 VENDOR_updateInvoiveDetail glTransaction','\'RI\',\'VB\'',null,null,20);	

	END IF;

    
/*
10-from-1	100.0000	15.0000
10-from2-1	100.0000	15.0000
Received 90
10-from-1	190.0000	15.0000
10-from2-1	100.0000	15.0000

GL
0.0000	174.2000
5.4000	0.0000
172.8000	0.0000
1.0000	0.0000
10.0000	0.0000
0.0000	15.0000

*/
		set _found=null;
        -- select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=190 and InventoryAllocated=15;
        -- select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=100 and InventoryAllocated=15;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 174.2000 and veBillID=_veBillID;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 15.0000 and veBillID=_veBillID;
        
        if (_found3 = 1 and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
        END IF;

	delete from veReceive where vePOID=_vePOID;
	delete from veReceiveDetail where  vePOID=_vePOID;
	delete from veReceiveDetailBin where  vePODetailID=_vePODetailID;
	delete from veBill where vePOID=_vePOID;
	delete from veBillHistory where vePOID=_vePOID;
	delete from veBillHistory where vePODetailID in (_vePODetailID,_vePODetailID2);

	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='RI' and enteredBy is null);
    delete FROM glTransaction where journalId='RI'  and enteredBy is null;    
	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='VB' and enteredBy is null);
    delete FROM glTransaction where journalId='VB'  and enteredBy is null;  

		call INV_testCreateDelete('DELETE');
        
ELSEIF( LOCATE ('Vendor_Invoice_Edit_Non-Values',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');
        
        delete from veBill where vePOID = _veBillID;

        call VENDOR_updateInvoive('UPDATE',null,_vePOID ,52,_joReleaseDetailID , '2021-12-09 00:00:00', 160, '2021-12-09 00:00:00', '2021-12-09 00:00:00', '2021-12-09 00:00:00', _UsePostDate, '', null, '2021-12-09 00:00:00', '528252', 0, 100, 0,_joReleaseID,_joMasterID,null,0,_userID);
		-- (_joReleaseDetailID,_joReleaseID,_joMasterID)
        
        select veBillID into _veBillID   from veBill where vePOID = _vePOID;
        
		call VENDOR_updateInvoiveDetail('UPDATE',_veBillID,null , null, 2, 1, 100, 1, 0, '', 'test', _userID);
        
        select veBillDetailID into _veBillDetailID from veBillDetail where veBillID = _veBillID;
        
		call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);
        
        select * from veBill where veBillID=_veBillID;
        select * from veBillDetail where veBillID=_veBillID;
        select * from glTransaction where glTransactionId in (select glTransactionId from glLinkage where veBillID = _veBillID and coLedgerSourceId=6220);
        
        
        
        -- update 
        call VENDOR_updateInvoive('UPDATE',_veBillID,_vePOID ,52,_joReleaseDetailID , '2021-12-10 00:00:00', 160, '2021-12-10 00:00:00', '2021-12-10 00:00:00', '2021-12-10 00:00:00', _UsePostDate, '', null, '2021-12-10 00:00:00', '123456', 0, 100, 0,_joReleaseID,_joMasterID,null,0,_userID);
		-- (_joReleaseDetailID,_joReleaseID,_joMasterID)
        
      --  select veBillID into _veBillID   from veBill where vePOID = _vePOID;
        
		call VENDOR_updateInvoiveDetail('UPDATE',_veBillID,_veBillDetailID , null, 2, 1, 100, 1, 0, '', 'test', _userID);
        
      --  select * from veBillDetail where veBillID = _veBillID;
        
		call INVOICE_recalculate("VENDORINVOICE",_veBillID,0,_userID,null,null,null,null,null,null);
        
        
		set _message = '';
        
		-- expected results
		set _found=null;
        select count(*) into _found from veBill where veBillID=_veBillID and BillAmount = 100.0000;
		IF (_found = 0) THEN set _message=concat(_message,',FAIL - veBill not created with correct amount');  END IF;
		set _found=null;
        select count(*) into _found from veBillDetail where veBillID=_veBillID and QuantityBilled = 1;
		IF (_found = 0) THEN set _message=concat(_message,',FAIL - veBillDetail not created');  END IF;
        set _found=null;
        select count(*) into _found from glTransaction where glTransactionId in (select glTransactionId from glLinkage where veBillID = _veBillID);
		IF (_found = 0) THEN set _message=concat(_message,',FAIL - glTransaction not created');  END IF;
		 
        
		if (CHAR_LENGTH(_message)<2) THEN set _message = concat(_action,' PASS'); END IF;
        
        select * from veBill where veBillID=_veBillID;
        select * from veBillDetail where veBillID=_veBillID;
        select * from glTransaction where glTransactionId in (select glTransactionId from glLinkage where veBillID = _veBillID and coLedgerSourceId=6220);
        
	select _message;
	call INV_testCreateDelete('DELETE');
    
        
        
        
ELSEIF( LOCATE ('SEND_MAIL',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');


 	call NOTIFICATION_notification('INSERT',5,3250,'baggarisiva@gmail.com','baggarisiva@gmail.com','Pick Ticket #111127 [test4]','test','javax.net.ssl.SSLSocketFactory','','',111127,'PickTicket_111127_[test4].pdf','','SalesOrder_111127.pdf',NULL,'SO');
  
		SELECT * FROM tsUser_global_notification;
	
	call NOTIFICATION_notification('MAILSEND',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

	call NOTIFICATION_notification('GETMAIL',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
	
	call NOTIFICATION_notification('FAILEDUPDATE',null,null,null,null,null,null,null,null,null,null,null,null,'FAILED',null,null);
	
		SELECT * FROM ts_Correspondance WHERE message = 'FAILED';
	
	call NOTIFICATION_notification('UPDATE',null,null,null,null,null,null,null,null,null,null,null,null,'SUCCESS',null,null);
	
		SELECT * FROM ts_Correspondance WHERE message = 'SUCCESS';
	
	call NOTIFICATION_notification('CREATE',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
	
	call NOTIFICATION_notification('RESEND',null,null,null,'baggarisiva@gmail.com','Testing','Pick Ticket #111127 [test4]','test',null,null,null,null,null,null,378,null);

			set _message = '';
			
			set _found = null;
			SELECT  COUNT(*) INTO _found FROM tsUser_global_notification WHERE statusId = 1;
			IF (_found is null) THEN set _message=concat(_message,',FAIL - statusId <> 1');  END IF;
			set _found=null;
			SELECT COUNT(*) INTO _found FROM ts_Correspondance;
			IF (_found is null) THEN set _message=concat(_message,',FAIL - ts_Correspondance is empty');  END IF;
			set _found = null;
			SELECT COUNT(*)INTO _found FROM att_configuration;
			IF (_found is null) THEN set _message=concat(_message,',FAIL - att_configuration is empty');  END IF; 
			
			if (CHAR_LENGTH(_message)<2) THEN set _message = concat(_action,' PASS'); END IF;

	select _message;
	call INV_testCreateDelete('DELETE');
    
    

    
ELSEIF( LOCATE ('SO_2_QP_INVOICE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	delete from cuSODetail where cuSOID = _cuSOID;
	delete from cuSO where cuSOID = _cuSOID;

	insert IGNORE into cuSO (cuSOID,prFromWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID) 
	values (_cuSOID,_prFromWarehouseID,_joReleaseID,_SONumber,962,_coTaxTerritoryID,_SONumber,962,150,15,10.0,20,_coDivisionID, _cuTermsID);

	insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSODetailID,_cuSOID,_prMasterID,150,0,6,1);
	
	insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSODetailID2,_cuSOID,_prMasterID2,1,2000,6,0);
    
	-- SELECT LAST_INSERT_ID() INTO _cuSODetailID2;

	call INV_createPickTicket_v2('CREATE',_cuSOID,null );

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSOID=_cuSOID;
		select 'START cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID in (_cuSODetailID,_cuSODetailID2);
		select 'START cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID2,null,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSOID=_cuSOID;
		-- select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );

	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,150,0,1,1,null,null,_userID);
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID2,null,null,1,2000,1,1,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE_recalculate BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'AFTER INVOICE_recalculate cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE_recalculate cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		-- select 'AFTER INVOICE_recalculate cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		-- select 'AFTER INVOICE_recalculate cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		-- select 'AFTER INVOICE_recalculate joReleaseDetail', r.* from joReleaseDetail r where joReleaseDetailID =_joReleaseDetailID;
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 6; -- 1
		call GL_print('AFTER INVOICE_recalculate glTransaction',null,null,null,12);	
	END IF;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
  
	call INV_testCreateDelete('DELETE');

ELSEIF( LOCATE ('SO_ONHOLD_TO_OPEN',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

-- 	case 'Void' setStatus = -1; 
-- 	case 'Quote' setStatus = -2; -- same as onhold
-- 	case 'OnHold' setStatus = 0; -- quote are the same thing
-- 	case 'Open' setStatus = 1;
-- 	case 'Book as Job' setStatus = 3;
-- 	case 'Import to Job' setStatus = 4;
-- 	case 'Closed' setStatus = 2;

	call SO_updateSO('SET_STATUS',_cuSOID,0,_userID,_DEBUG);
	call SO_updateSO('SET_STATUS',_cuSOID,1,_userID,_DEBUG);

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER  ONHOLD OPEN cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'AFTER ONHOLD OPEN BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
/*

100.0000	15.0000
100.0000	15.0000

-- SO 150
100.0000	100.0000
100.0000	80.0000

-- ONHOLD
100.0000	15.0000
100.0000	15.0000

-- OPEN
100.0000	100.0000
100.0000	80.0000

*/
		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=100 and InventoryAllocated=100;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=100 and InventoryAllocated=80;        
        select count(*) into _found3 from cuSO  where cuSOID=_cuSOID and TransactionStatus=1;        
        
        if (_found = 1 and _found2 = 1  and _found3 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL bin',p.* from bin p where binId in (_fromBinID,_fromBinID2); -- 1
        END IF;
        
	call INV_testCreateDelete('DELETE');



ELSEIF( LOCATE ('SO_TO_VOID',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	-- call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'BEFORE VOID cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'BEFORE VOID cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'BEFORE VOID bin',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;

-- 	case 'Void' setStatus = -1; 
-- 	case 'Quote' setStatus = -2;
-- 	case 'OnHold' setStatus = 0;
-- 	case 'Open' setStatus = 1;
-- 	case 'Book as Job' setStatus = 3;
-- 	case 'Import to Job' setStatus = 4;
-- 	case 'Closed' setStatus = 2;

	call SO_updateSO('SET_STATUS',_cuSOID,-1,_userID,_DEBUG);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'AFTER VOID BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
/*

100.0000	15.0000
100.0000	15.0000

-- SO 150
100.0000	100.0000
100.0000	80.0000

-- VOID
100.0000	15.0000
100.0000	15.0000


*/
		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=100 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=100 and InventoryAllocated=15;        
        select count(*) into _found3 from cuSO  where cuSOID=_cuSOID and TransactionStatus=-1;        
        
        if (_found = 1 and _found2 = 1  and _found3 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL bin',p.* from bin p where binId in (_fromBinID,_fromBinID2); -- 1
        END IF;
        
	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('SO_2_INVOICE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH bin',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;

	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );

	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,150,10,1,1,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	select joReleaseDetailID into _joReleaseDetailID from cuInvoice where cuSOID=_cuSOID; 

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE_recalculate cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE_recalculate cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE_recalculate cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE_recalculate cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE_recalculate joReleaseDetail', r.* from joReleaseDetail r where joReleaseDetailID =_joReleaseDetailID;
		select 'AFTER INVOICE_recalculate BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
		call GL_print('AFTER INVOICE_recalculate glTransaction',null,null,null,12);	
	END IF;
/*

-- BIN FAILED

4 gl's
0.0000	1500.0000
0.0000	125.4000
0.0000	20.0000
1645.4000	0.0000

15.0000	15.0000
35.0000	15.0000

1 joRelease 1645.4000
*/
		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=15 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=35 and InventoryAllocated=15;        
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 20.0000 and veBillID=_cuInvoiceID;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1645.4000 and veBillID=_cuInvoiceID;

		select count(*) into _found5 from joReleaseDetail  where joReleaseDetailID =_joReleaseDetailID and CustomerInvoiceAmount = 1645.4000;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1 and _found5 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
			SELECT 'FAIL bin',p.* from bin p where binId in (_fromBinID,_fromBinID2); -- 1
        END IF;
        
    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
   
	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('SO_2_PARTIAL_INVOICE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;

	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );

	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,75,10,1,1,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	select joReleaseDetailID into _joReleaseDetailID from cuInvoice where cuSOID=_cuSOID; 

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE_recalculate BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'AFTER INVOICE_recalculate cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE_recalculate cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		-- select 'AFTER INVOICE_recalculate cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		-- select 'AFTER INVOICE_recalculate cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE_recalculate joReleaseDetail', r.* from joReleaseDetail r where joReleaseDetailID =_joReleaseDetailID;
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
		call GL_print('AFTER INVOICE_recalculate glTransaction',null,null,null,4);	
	END IF;

/*
0.0000	750.0000
0.0000	63.5200
0.0000	20.0000
833.5200	0.0000

		set _found=null;
		select count(*) into _found from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 750 and veBillID=_cuInvoiceID;
		select count(*) into _found2 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 63.5200 and veBillID=_cuInvoiceID;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 20.0000 and veBillID=_cuInvoiceID;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 833.5200 and veBillID=_cuInvoiceID;

		select count(*) into _found5 from joReleaseDetail  where joReleaseDetailID =_joReleaseDetailID and CustomerInvoiceAmount = 833.5200;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1 and _found5 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
        END IF;
*/

	select 'NEEDS COMFORMATION';
    

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
        
	call INV_testCreateDelete('DELETE');

ELSEIF( LOCATE ('INVOICE_CHANGELINE',_action)>0) THEN

	-- WARNING - need to find out when call INV_createPickTicket_v2('INVOICE',_cuSOID,_DEBUG );  is called, as it will close a ticket.
    
	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_createPickTicket_v2('CREATE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER TICKET cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER TICKET cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;        
		select 'AFTER TICKET ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;

	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );

	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID = _cuInvoiceID;
    
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,150,10,1,1,null,null,_userID);
 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);
	-- call INV_createPickTicket_v2('INVOICE',_cuSOID,_DEBUG ); -- this sets the status to complete.. when is this called in the UI?

	-- select joReleaseDetailID into _joReleaseDetailID from cuInvoice where cuSOID=_cuSOID; 

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		-- select 'AFTER INVOICE cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER INVOICE cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
		-- SELECT 'AFTER INVOICE_glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order By glTransaction desc limit 8; -- 1
		-- SELECT 'AFTER INVOICE_glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where journalId ='CI' and enteredBy is null; -- 1
		-- SELECT 'AFTER INVOICE_glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where  l.veBillID=_cuInvoiceID; -- 1
		call GL_print('AFTER INVOICE glTransaction',null,null,_cuInvoiceID,12);	
	END IF;

	-- modify a line item to a different value
	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuSODetailID = _cuSODetailID;	
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,_cuInvoiceDetailID,null,null,null,100,10,1,1,'Changed',null,_userID);
 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);
	-- call INV_createPickTicket_v2('INVOICE',_cuSOID,_DEBUG );

	IF( LOCATE ('DEBUG',_action)>1) THEN
		-- select 'AFTER ADJUSTMENT cuSODetailTicket', d.* from cuSODetailTicket d where cuSOID = _cuSOID;
		select 'AFTER ADJUSTMENT BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'AFTER ADJUSTMENT cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER ADJUSTMENT cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER ADJUSTMENT cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		select 'AFTER ADJUSTMENT cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		-- select 'AFTER INVOICE_recalculate2 joReleaseDetail', r.* from joReleaseDetail r where joReleaseDetailID =_joReleaseDetailID;
		-- SELECT 'AFTER ADJUSTMENT glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where  l.veBillID=_cuInvoiceID; -- 1
		call GL_print('AFTER INVOICE glTransaction',null,null,_cuInvoiceID,12);	
	END IF;


/*
10-from-1	100.0000	15.0000
10-from2-1	100.0000	15.0000
so
10-from-1	100.0000	100.0000
10-from2-1	100.0000	80.0000
ticket
85.0000	150.0000
65.0000	150.0000
invoiced
10-from-1	15.0000	15.0000
10-from2-1	35.0000	15.0000
GL
1645.4000	0.0000
0.0000	20.0000
0.0000	125.4000
0.0000	1500.0000
adjust invoice
10-from-1	15.0000	15.0000
10-from2-1	85.0000	65.0000
GL
1104.1500	0.0000
0.0000	20.0000
0.0000	84.1500
0.0000	1000.0000
*/

		set _found=null;
        
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=15 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=85 and InventoryAllocated=65;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1104.1500 and veBillID=_cuInvoiceID;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 1645.4000 and veBillID=_cuInvoiceID;
                
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
			select 'FAIL BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 12; -- 1
        END IF;

	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='CI' and enteredBy is null);
    delete FROM glTransaction where journalId='CI'  and enteredBy is null;
    
		call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('INVOICE_DELETELINE',_action)>0) THEN

	delete from prMaster where prMasterID=_prMasterID;
	delete from bin where binId in (_fromBinID,_fromBinID2,_toBinID);
	delete from cuSO where  cuSOID = _cuSOID;
	delete from cuSODetail where  cuSODetailID = _cuSODetailID;
	delete from cuSODetailBin where  cuSODetailID = _cuSODetailID and cuSODetailBinID>0;

	insert into prMaster (prMasterID,prDepartmentID,prCategoryID,ItemCode,IsInventory, AverageCost,Description) values (_prMasterID,_prDepartmentID,1,'ABC-Product',0,5,'1/2 Round Nut');
	
    insert into cuSO (cuSOID,prFromWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID) 
	values (_cuSOID,_prFromWarehouseID,_joReleaseID,_SONumber,962,_coTaxTerritoryID,_SONumber,962,150,15,10.0,20,_coDivisionID, _cuTermsID);
	
    insert into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSODetailID,_cuSOID,_prMasterID,150,10,6,1);


	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
	END IF;

	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    
	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );

	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,150,10,1,1,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	select joReleaseDetailID into _joReleaseDetailID from cuInvoice where cuSOID=_cuSOID; 

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE_recalculate BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'AFTER INVOICE_recalculate cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE_recalculate cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		-- select 'AFTER INVOICE_recalculate cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		-- select 'AFTER INVOICE_recalculate cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE_recalculate joReleaseDetail', r.* from joReleaseDetail r where joReleaseDetailID =_joReleaseDetailID;
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
		call GL_print('AFTER INVOICE_recalculate glTransaction',null,null,null,12);	
	END IF;
	
    
    -- remove the item and run the test
	select cuInvoiceDetailID into _cuInvoiceDetailID from cuInvoiceDetail where cuSODetailID = _cuSODetailID;	
	call INVOICE_updateInvoiceDetail('DELETE',_cuInvoiceID,_cuInvoiceDetailID,null,null,null,null,null,null,null,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	select joReleaseDetailID into _joReleaseDetailID from cuInvoice where cuSOID=_cuSOID; 

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE_recalculate2 BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'AFTER INVOICE_recalculate2 cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE_recalculate2 cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		-- select 'AFTER INVOICE_recalculate cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		-- select 'AFTER INVOICE_recalculate cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE_recalculate2 joReleaseDetail', r.* from joReleaseDetail r where joReleaseDetailID =_joReleaseDetailID;
		-- SELECT 'AFTER INVOICE_recalculate2 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
		call GL_print('AFTER INVOICE_recalculate2 glTransaction',null,null,null,4);	
	END IF;

/*
		set _found=null;
		select count(*) into _found from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 1500 and veBillID=_cuInvoiceID;
		select count(*) into _found2 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 125.4000 and veBillID=_cuInvoiceID;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 20.0000 and veBillID=_cuInvoiceID;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1645.4000 and veBillID=_cuInvoiceID;

		select count(*) into _found5 from joReleaseDetail  where joReleaseDetailID =_joReleaseDetailID and CustomerInvoiceAmount = 1645.4000;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1 and _found5 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
        END IF;
*/


		-- expected results
		set _message = '';
        
		set _found=null;
		select joReleaseDetailID into _found from joReleaseDetail where (CustomerInvoiceAmount=1104.1500) and joReleaseDetailID=(select joReleaseDetailID from cuInvoice where cuSOID=_cuSOID limit 1);
		IF (_found is null) THEN set _message=concat(_message,',FAIL - joReleaseDetail.CustomerInvoiceAmount');  END IF;

		-- cuInvoiceDetailBin
		set _found=null;
		select cuInvoiceID into _found from cuInvoice where (InvoiceAmount=1104.1500 and TaxAmount=84.1500 and Freight=20 and CostTotal=600.0000 and Subtotal=1000.0000 and TaxTotal=84.1500 and TaxableSales=1020.0000) and cuInvoiceID=_cuInvoiceID;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - cuInvoice.totals off');  END IF;
		set _found=null;
		select cuInvoiceDetailID into _found from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
		IF (_found is not null) THEN set _message=concat(_message,',FAIL - cuInvoiceDetailID not removed');  END IF;        
        
        -- glTransaction
        
        -- just see if the reversal is there.
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and credit=1645.4000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.credit reverse off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and debit=20.0000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.debit freight reverse off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and debit=125.4000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.debit tax reverse off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and debit=1500.0000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.debit sales reverse off');  END IF;        
        -- note, there are glTransactionRecords that may need to be checked.


		set _found=null;
        select count(*) into _found from glTransaction where (reference=concat(_SONumber,'1'));
		IF (_found >8) THEN set _message=concat(_message,',FAIL - glTransaction too many found');  END IF;        
        
		if (CHAR_LENGTH(_message)<2) THEN set _message = concat(_action,' PASS'); END IF;

	select _message;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;

	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('INVOICE_ADDLINE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	insert into cuSODetail (cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSOID,_prMasterID2,50,10,6,1);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'START cuSO',s.* from cuSO s where cuSOID=_cuSOID;
		select 'START cuSODetail',s.* from cuSODetail s where cuSODetailID=_cuSODetailID;
	END IF;

	-- call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,null,_userID);
	call INV_updateInventoryOH('SALESORDER',null,null,null,null,_reference,_reason,null,null,_cuSODetailID,_prToWarehouseID,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER INV_updateInventoryOH ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
	END IF;
    

	call INVOICE_updateInvoice('UPDATE',null,_cuSOID, null, 625, null, null, null,null,null, null,null,null, null, null, null, null, null, null,_coDivisionID, null, null, _coTaxTerritoryID, _cuTermsID, null,_userID,_freight,null, null,null,null,null,null,null,null,null,null,null,null,null,null,null,null );

	select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
   
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,150,10,1,1,null,null,_userID);

 	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	-- ADD call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,null,null,null,null,'A Note',null,1);
	-- ADD call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,null,null,null,100,1,null,1,'A Note',null,1);

	-- need to create a new product to add.
	call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,null,null,_prMasterID2,50,10,1,1,null,null,_userID);

	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_userID,null,0,0,0,0,0);

	select joReleaseDetailID into _joReleaseDetailID from cuInvoice where cuSOID=_cuSOID; 

	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'AFTER INVOICE_recalculate BIN',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2);
		select 'AFTER INVOICE_recalculate cuInvoice', d.* from cuInvoice d where cuInvoiceID=_cuInvoiceID;
		select 'AFTER INVOICE_recalculate cuInvoiceDetail', d.* from cuInvoiceDetail d where cuInvoiceID=_cuInvoiceID;
		-- select 'AFTER INVOICE_recalculate cuInvoiceDetailBin', d.* from cuInvoiceDetailBin d where  cuInvoiceDetailID=_cuInvoiceDetailID;
		-- select 'AFTER INVOICE_recalculate cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		select 'AFTER INVOICE_recalculate joReleaseDetail', r.* from joReleaseDetail r where joReleaseDetailID =_joReleaseDetailID;
		call GL_print('AFTER INVOICE_recalculate glTransaction',null,null,null,4);	
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
	END IF;
/*
		set _found=null;
		select count(*) into _found from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 1500 and veBillID=_cuInvoiceID;
		select count(*) into _found2 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 125.4000 and veBillID=_cuInvoiceID;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.credit = 20.0000 and veBillID=_cuInvoiceID;
		select count(*) into _found4 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 1645.4000 and veBillID=_cuInvoiceID;

		select count(*) into _found5 from joReleaseDetail  where joReleaseDetailID =_joReleaseDetailID and CustomerInvoiceAmount = 1645.4000;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1 and _found5 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4, _found5;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
        END IF;
*/

		-- expected results
		set _message = '';
        
		set _found=null;
        select binId into _found from v_INV_bin where (InventoryOnHand=100 and InventoryAllocated=15 and  AverageCost=10) and binId=_toBinID;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - _toBinID');  END IF;
		set _found=null;
		select binId into _found from v_INV_bin where (InventoryOnHand=65 and InventoryAllocated=15 and  AverageCost=10) and binId=_fromBinID;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - _fromBinID');  END IF;
		set _found=null;
		select binId into _found from v_INV_bin where (InventoryOnHand=35 and InventoryAllocated=15 and  AverageCost=10) and binId=_fromBinID2;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - _fromBinID2');  END IF;
		set _found=null;
		select cuSODetailID into _found from cuSODetail where (QuantityBilled=100) and cuSODetailID=_cuSODetailID;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - cuSODetail.QuantityBilled');  END IF;        
		set _found=null;
		select joReleaseDetailID into _found from joReleaseDetail where (CustomerInvoiceAmount=1104.1500) and joReleaseDetailID=(select joReleaseDetailID from cuInvoice where cuSOID=_cuSOID limit 1);
		IF (_found is null) THEN set _message=concat(_message,',FAIL - joReleaseDetail.CustomerInvoiceAmount');  END IF;
		set _found=null;
		select cuSODetailBinID into _found from cuSODetailBin where (QuantityBilled=35) and cuSODetailID=_cuSODetailID and binID=_fromBinID;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - cuSODetailBin.QuantityBilled');  END IF;        
		set _found=null;
		select cuSODetailBinID into _found from cuSODetailBin where (QuantityBilled=65) and cuSODetailID=_cuSODetailID and binID=_fromBinID2;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - cuSODetailBin.QuantityBilled');  END IF;        

		-- cuInvoiceDetailBin
		set _found=null;
		select cuInvoiceID into _found from cuInvoice where (InvoiceAmount=1104.1500 and TaxAmount=84.1500 and Freight=20 and CostTotal=600.0000 and Subtotal=1000.0000 and TaxTotal=84.1500 and TaxableSales=1020.0000) and cuInvoiceID=_cuInvoiceID;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - cuInvoice.totals off');  END IF;
		set _found=null;
		select cuInvoiceDetailBinID into _found from cuInvoiceDetailBin where (QuantityBilled=35) and  binID=_fromBinID;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - cuInvoiceDetailBin.QuantityBilled');  END IF;        
		set _found=null;
		select cuInvoiceDetailBinID into _found from cuInvoiceDetailBin where (QuantityBilled=65) and  binID=_fromBinID2;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - cuInvoiceDetailBin.QuantityBilled');  END IF;        
        
        -- glTransaction
        
        -- just see if the reversal is there.
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and credit=1645.4000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.credit reverse off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and debit=20.0000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.debit freight reverse off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and debit=125.4000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.debit tax reverse off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and debit=1500.0000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.debit sales reverse off');  END IF;        
        -- note, there are glTransactionRecords that may need to be checked.

		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and debit=1104.1500 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.debit off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and credit=20.0000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.creditFreight off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and credit=84.1500 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.creditTax off');  END IF;        
		set _found=null;
		select glTransactionID into _found from glTransaction where (reference=concat(_SONumber,'1')) and credit=1000.0000 limit 1;
		IF (_found is null) THEN set _message=concat(_message,',FAIL - glTransaction.creditSales off');  END IF;        
        
		if (CHAR_LENGTH(_message)<2) THEN set _message = concat(_action,' PASS'); END IF;

	select _message;

    select glTransactionId into _startingGlTransactionID from glLinkage where veBillId = _cuInvoiceID order by glLinkageId desc limit 1;
	delete FROM glTransaction where glTransactionId = _startingGlTransactionID;
	delete FROM glLinkage where glTransactionId = _startingGlTransactionID;
    
	call INV_testCreateDelete('DELETE');


	-- add a non-inventory line item.    
 	-- call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,null,_cuSODetailID,null,null,null,null,null,null,null,null,1);



    
ELSEIF( LOCATE ('RECEIVE-TWICE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,1,_prFromWarehouseID,3,_SONumber);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID,_vePOID,_prMasterID,100,10,'Vulcan Mind Weld');

 
 	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',_prToWarehouseID,v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
		select 'START vePO',s.* from vePO s where vePOID=_vePOID;
		select 'START vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
	END IF;

	set _qty=10;
    call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID,_prToWarehouseID,_userID);	
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( RECEIVE-ITEM,',_fromBinID,',','null',',',_qty,') ','_vePODetailID:',_vePODetailID,_prToWarehouseID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		-- select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		-- select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER RECEIVE10 vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
		select 'AFTER RECEIVE10 veReceive',v.* from veReceive v where vePOID=_vePOID;
		select 'AFTER RECEIVE10 veReceiveDetail',v.* from veReceiveDetail v where vePOID=_vePOID;
		select 'AFTER RECEIVE10 bin ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
        -- SELECT 'AFTER RECEIVE10 glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 8; -- 1
		call GL_print('AFTER RECEIVE10 glTransaction',null,null,null,8);	
		
    END IF;

	set _qty=80;
    call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID,_prToWarehouseID,_userID);	
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( RECEIVE-ITEM,',_fromBinID,',','null',',',_qty,') ','_vePODetailID:',_vePODetailID,_prToWarehouseID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		-- select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		-- select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER RECEIVE80 vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
		select 'AFTER RECEIVE80 veReceive',v.* from veReceive v where vePOID=_vePOID;
		select 'AFTER RECEIVE80 veReceiveDetail',v.* from veReceiveDetail v where vePOID=_vePOID;
		select 'AFTER RECEIVE80 bin ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
        -- SELECT 'AFTER RECEIVE80  glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 8; -- 1
		call GL_print('AFTER RECEIVE8 glTransaction',null,null,null,8);	
		
    END IF;

/*
10-from-1	100.0000	15.0000
10-from2-1	100.0000	15.0000
Received 10
10-from2-1	100.0000	15.0000
10-from-1	110.0000	15.0000

RI	50.0000	0.0000
RI	0.0000	50.0000

10-from-1	190.0000	15.0000
10-from2-1	100.0000	15.0000

RI	1350-00-000	400.0000	0.0000
RI	2001-00-000	0.0000	400.0000
RI	1350-00-000	50.0000	0.0000
RI	2001-00-000	0.0000	50.0000

*/
		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=190 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=100 and InventoryAllocated=15;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 400 and vePODetailID=_vePODetailID;
        select count(*) into _found4 from vePODetail where vePOID=_vePOID and QuantityOrdered=100 and QuantityReceived=90;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
        END IF;
        
        
	delete  from veReceive where vePOID=_vePOID;
	delete from veReceiveDetail where  vePOID=_vePOID;
	delete from veReceiveDetailBin where  vePODetailID=_vePODetailID;

	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='RI' and enteredBy is null);
    delete FROM glTransaction where journalId='RI'  and enteredBy is null;
     
	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('RECEIVE-ITEM',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,1,_prFromWarehouseID,3,_SONumber);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID,_vePOID,_prMasterID,100,10,'Vulcan Mind Weld');

 
 	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',_prToWarehouseID,v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
		select 'START vePO',s.* from vePO s where vePOID=_vePOID;
		select 'START vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
	END IF;

	set _qty=90;
    call INV_updateInventoryOH('RECEIVE-ITEM',null,null,_fromBinID,null,_reference,_reason,_qty,null,_vePODetailID,_prToWarehouseID,_userID);	
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( RECEIVE-ITEM,',_fromBinID,',','null',',',_qty,') ','_vePODetailID:',_vePODetailID,_prToWarehouseID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		-- select 'AFTER INV_updateInventoryOH cuSODetail', d.* from cuSODetail d where cuSODetailID=_cuSODetailID;
		-- select 'AFTER INV_updateInventoryOH cuSODetailBin', d.* from cuSODetailBin d where  cuSODetailID=_cuSODetailID;
		select 'AFTER RECEIVE vePODetail',v.* from vePODetail v  where vePOID=_vePOID;
		select 'AFTER RECEIVE veReceive',v.* from veReceive v where vePOID=_vePOID;
		select 'AFTER RECEIVE veReceiveDetail',v.* from veReceiveDetail v where vePOID=_vePOID;
		select 'AFTER RECEIVE-ITEM bin ',v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
        -- SELECT 'AFTER RECEIVE-ITEM  glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 8; -- 1
        -- SELECT 'AFTER RECEIVE-ITEM  glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) where p.journalID in ('RI') and p.enteredBy is null  order by p.glTransactionId desc; -- 1		
		call GL_print('AFTER RECEIVE-ITEM glTransaction','\'RI\'',null,null,8);	
		
    END IF;
/*
10-from-1	100.0000	15.0000
10-from2-1	100.0000	15.0000
Received 90
10-from-1	190.0000	15.0000
10-from2-1	100.0000	15.0000

1350-00-000	450.0000	0.0000
2001-00-000	0.0000	450.0000

*/
		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=190 and InventoryAllocated=15;
        select count(*) into _found2 from bin where binId=_fromBinID2 and InventoryOnHand=100 and InventoryAllocated=15;
		select count(*) into _found3 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where g.debit = 450 and vePODetailID=_vePODetailID;
        select count(*) into _found4 from vePODetail where vePOID=_vePOID and QuantityOrdered=100 and QuantityReceived=90;
        
        if (_found = 1 and _found2 = 1  and _found3 = 1 and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
			SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
			SELECT 'FAIL glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
        END IF;

	delete  from veReceive where vePOID=_vePOID;
	delete from veReceiveDetail where  vePOID=_vePOID;
	delete from veReceiveDetailBin where  vePODetailID=_vePODetailID;

	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='RI' and enteredBy is null);
    delete FROM glTransaction where journalId='RI'  and enteredBy is null;
    
	call INV_testCreateDelete('DELETE');

ELSEIF( LOCATE ('TRANSFER-RECEIVE-UNDO',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	set _qty=20; -- from UI
    
	call INV_updateInventoryOH('TRANSFER',now(),now(),_fromBinID,null, _reference,_reason,_qty,null,null,_prToWarehouseID,_userID); -- toBin is not used when starting the transfer
    
	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER XFER INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'AFTER XFER prWHtransfer',p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'AFTER XFER prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'AFTER XFER virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'AFTER XFER NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
	END IF;

    select max(prTransferDetailID) into  _prTransferDetailID from prWHtransferDetail;
	call INV_updateInventoryOH('TRANSFER-RECEIVE',null,null,_fromBinID,_toBinID,null,_reference,_reason,_prTransferDetailID,null,_prToWarehouseID,_userID);
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( TRANSFER-RECEIVE,',_fromBinID,',',_toBinID,',',_qty,')');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'RECEIVE INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'RECEIVE prWHtransfer',p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'RECEIVE prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'RECEIVE virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'RECEIVE NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
		-- SELECT 'RECEIVE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
		call GL_print('AFTER RECEIVE glTransaction','\'RI\'',null,null,8);	
	END IF;

    select max(prTransferDetailID) into     _prTransferDetailID from prWHtransferDetail;
	call INV_updateInventoryOH('TRANSFER-RECEIVE-UNDO',null,null,_toBinID,null,_reference,_reason,_qty,_prTransferDetailID,null,_prToWarehouseID,_userID);
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( TRANSFER-RECEIVE-UNDO,',_fromBinID,',',_toBinID,',',_qty,')');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'UNDO INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'UNDO prWHtransfer',p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'UNDO prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'UNDO virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'UNDO NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
		-- SELECT 'UNDO glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 8; -- 1
		call GL_print('UNDO glTransaction','\'RI\'',null,null,8);	
	END IF;

        
/*
qty=20

from1 100.0000	15.0000
from2 100.0000	15.0000
To    100.0000	15.0000

transfer

10-to-2	100.0000	15.0000
10-from-1	100.0000	20.0000
10-from2-1	100.0000	15.0000

receive

To    120.0000	15.0000
from1 80.0000	0.0000
from2 100.0000	15.0000

undo

to    100.0000	15.0000
from1 100.0000	20.0000
from2 100.0000	15.0000

To DALLAS	200.0000	0.0000	3211
From FT WORTH	0.0000	200.0000	3211
*/

		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=100 and InventoryAllocated=20; -- note 15 was removed by the fix tool 
        select count(*) into _found2 from bin where binId=_toBinID and InventoryOnHand=100 and InventoryAllocated=15;        
        select count(*) into _found3 from prWHtransferDetail where prMasterID=_prMasterID and QuantityTransfered=20 and toBinId is null and ReceivedDate is null;        
        select count(*) into _found4 from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 and inTransfer=20;        

		select TransNumber into _startingGlTransactionID from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID limit 1;

		select count(*) into _found5 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where journalId='TR' and veBillID=_startingGlTransactionID and g.debit = 200.0000;
		-- select count(*)  from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where journalId='TR' and veBillID=3211 and g.debit = 200.0000;

        if (_found = 1 and _found2 = 1  and _found3 = 1  and _found4 = 1 and _found5=2) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
        
        SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4 , _found5;
		SELECT 'FAIL INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'FAIL prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'FAIL virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'FAIL glTransaction',_startingGlTransactionID as TransNumber, g.* from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) order by g.glTransactionID desc limit 4;
        
        END IF;

	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='TR' and enteredBy is null);
    delete FROM glTransaction where journalId='TR'  and enteredBy is null;
	delete from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1;
    
	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('TRANSFER-THEN-RECEIVE',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	set _qty=20; -- from UI
    
	call INV_updateInventoryOH('TRANSFER',now(),now(),_fromBinID,null, _reference,_reason,_qty,null,null,_prToWarehouseID,_userID); -- toBin is not used when starting the transfer
    
	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER XFER INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'AFTER XFER prWHtransfer',p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'AFTER XFER prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'AFTER XFER virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'AFTER XFER NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
	END IF;

    select max(prTransferDetailID) into  _prTransferDetailID from prWHtransferDetail;
	call INV_updateInventoryOH('TRANSFER-RECEIVE',null,null,_fromBinID,_toBinID,null,_reference,_reason,_prTransferDetailID,null,_prToWarehouseID,_userID);
	-- set _theCall = concat(_action, ' INV_updateInventoryOH( TRANSFER-RECEIVE,',_fromBinID,',',_toBinID,',',_qty,')');

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'RECEIVE INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'RECEIVE prWHtransfer',p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'RECEIVE prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'RECEIVE virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'RECEIVE NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
		-- SELECT 'RECEIVE glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 8; -- 1
		call GL_print('RECEIVE glTransaction','\'RI\'',null,null,8);	
	END IF;
    
/*
qty=20

from1 100.0000	15.0000
from2 100.0000	15.0000
To    100.0000	15.0000

from1 100.0000	0.0000 -- fix tool removed bad 15
from2 100.0000	15.0000
To    100.0000	15.0000

To    120.0000	15.0000
from1 80.0000	0.0000
from2 100.0000	15.0000

To DALLAS	200.0000	0.0000	3211
From FT WORTH	0.0000	200.0000	3211
*/

		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=80 and InventoryAllocated=0; -- note 15 was removed by the fix tool 
        select count(*) into _found2 from bin where binId=_toBinID and InventoryOnHand=120 and InventoryAllocated=15;        
        select count(*) into _found3 from prWHtransferDetail where prMasterID=_prMasterID and QuantityTransfered=20 and toBinId = _toBinID;        
        select count(*) into _found4 from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 and inTransfer=0;        

		select TransNumber into _startingGlTransactionID from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID limit 1;

		select count(*) into _found5 from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where journalId='TR' and veBillID=_startingGlTransactionID and g.debit = 200.0000;
		-- select count(*)  from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) where journalId='TR' and veBillID=3211 and g.debit = 200.0000;

        if (_found = 1 and _found2 = 1  and _found3 = 1  and _found4 = 1 and _found5>=1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
        
        SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4 , _found5;
		SELECT 'FAIL INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'FAIL prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'FAIL virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'FAIL glTransaction',_startingGlTransactionID as TransNumber, g.* from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID) order by g.glTransactionID desc limit 4;
        
        END IF;

	delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='TR' and enteredBy is null);
	-- delete FROM glLinkage where glTransactionId in (select glTransactionID from glTransaction where journalId='TR' and veBillID=_startingGlTransactionID);
    delete FROM glTransaction where journalId='TR'  and enteredBy is null;
    
	delete from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1;
    
 	call INV_testCreateDelete('DELETE');


ELSEIF( LOCATE ('TRANSFER-CANCEL',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	set _qty=20; -- from UI
	set _theCall = concat(_action, ' INV_updateInventoryOH( TRANSFER, prMaster=',_prMasterID,' toWH=',_prToWarehouseID,' bins:',_fromBinID,',',_toBinID,', qty=',_qty,')');
 
 	-- IF( LOCATE ('DEBUG',_action)>1) THEN
		-- select 'START BIN',_qty as ToBeTransferred,_prToWarehouseID,v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
		-- select 'START _theCall',_theCall;
	-- END IF;
    
	call INV_updateInventoryOH('TRANSFER',now(),now(),_fromBinID,null, _reference,_reason,_qty,null,null,_prToWarehouseID,_userID); -- toBin is not used when starting the transfer
    
	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER XFER INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'AFTER XFER prWHtransfer',p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'AFTER XFER prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'AFTER XFER virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'AFTER XFER NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
	END IF;

    select max(prTransferDetailID) into  _prTransferDetailID from prWHtransferDetail;
	call INV_updateInventoryOH('TRANSFER-CANCEL',null,null,_fromBinID,null,_reference,_reason,null,_prTransferDetailID,null,_prToWarehouseID,_userID);

	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'CANCEL INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'CANCEL prWHtransfer',_prTransferDetailID as toBeRemovedTransferDetailID,p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'CANCEL prWHtransferDetail (should be removed)',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'CANCEL virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'CANCEL NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
	END IF;

/*
qty=20

from1 100.0000	15.0000
from2 100.0000	15.0000
To    100.0000	15.0000

after

from1 100.0000	0.0000 -- fix tool removed bad 15
from2 100.0000	15.0000
To    100.0000	15.0000

Not GL expected
*/

		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=100 and InventoryAllocated=0; -- note 15 was removed by the fix tool 
        select count(*) into _found2 from bin where binId=_toBinID and InventoryOnHand=100 and InventoryAllocated=15;        
        select count(*) into _found3 from prWHtransferDetail where prMasterID=_prMasterID and QuantityTransfered=20 and fromBinId = _fromBinID;        
        select count(*) into _found4 from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 and inTransfer=0;        

        
        if (_found = 1 and _found2 = 1  and _found3 = 0  and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
        SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
		SELECT 'FAIL INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'FAIL prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'FAIL virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
        END IF;
    
		delete from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1;

		call INV_testCreateDelete('DELETE');

    
ELSEIF( LOCATE ('TRANSFER_ONLY',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	set _qty=20; -- from UI
	set _theCall = concat(_action, ' INV_updateInventoryOH( TRANSFER, prMaster=',_prMasterID,' toWH=',_prToWarehouseID,' bins:',_fromBinID,',',_toBinID,', qty=',_qty,')');
 
 	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',_qty as ToBeTransferred,_prToWarehouseID,v_INV_bin.* from v_INV_bin where binId in (_fromBinID,_fromBinID2,_toBinID);
		-- select 'START _theCall',_theCall;
	END IF;
    
	call INV_updateInventoryOH('TRANSFER',now(),now(),_fromBinID,null, _reference,_reason,_qty,null,null,_prToWarehouseID,_userID); -- toBin is not used when starting the transfer
    
	IF( LOCATE ('DEBUG',_action)>1) THEN
		SELECT 'AFTER INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'AFTER prWHtransfer',p.* from prWHtransfer p where prFromWareHouseID = _prFromWarehouseID or prToWareHouseID = _prToWarehouseID;
		select 'AFTER prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'AFTER virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
		select 'AFTER NOTE: call FIX_tool("BIN_ALLOCATION",null,null,null,_fromBinID); done in INV_updateInventoryOH TO FIX BAD 15 ALLOCATION.';
		-- SELECT 'AFTER INVOICE_recalculate glTransaction',p.*,l.* FROM glTransaction p left join glLinkage l on (l.glTransactionId = p.glTransactionId) order by p.glTransactionId desc limit 4; -- 1
	END IF;

/*
qty=20

from1 100.0000	15.0000
from2 100.0000	15.0000
To    100.0000	15.0000

after

from1 100.0000	20.0000 -- fix tool removed bad 15
from2 100.0000	15.0000
To    100.0000	15.0000

Not GL expected
*/

		set _found=null;
        select count(*) into _found from bin where binId=_fromBinID and InventoryOnHand=100 and InventoryAllocated=20; -- note 15 was removed by the fix tool 
        select count(*) into _found2 from bin where binId=_toBinID and InventoryOnHand=100 and InventoryAllocated=15;        
        select count(*) into _found3 from prWHtransferDetail where prMasterID=_prMasterID and QuantityTransfered=20 and fromBinId = _fromBinID;        
        select count(*) into _found4 from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1 and inTransfer=20;        

        
        if (_found = 1 and _found2 = 1  and _found3 = 1  and _found4 = 1) THEN
			set _message = ' PASS'; 
			select concat(_action,' ', _message);
		ELSE
        SELECT 'FAIL' , _found , _found2 ,_found3 ,  _found4;
		SELECT 'FAIL INV_updateInventoryOH',_action,b.* FROM v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID); -- 1
		select 'FAIL prWHtransferDetail',p.* from prWHtransferDetail p where prMasterID=_prMasterID;
        select 'FAIL virtualbin', b.* from bin b where prWarehouseID = _prFromWarehouseID and prMasterID is null;
        END IF;
        
		delete from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and binSequence=1;
        

	call INV_testCreateDelete('DELETE');

ELSEIF ( LOCATE ('ADJUSTMENT',_action)>0 or LOCATE ('COUNT',_action)>0) THEN

	call INV_testCreateDelete('CREATETESTTABLES');

	IF( LOCATE ('DECREASE',_action)>1) THEN 
		set _qty=20;
	ELSEIF( LOCATE ('INCREASE',_action)>1) THEN 
		set _qty=120; 
    END IF;
    -- select _fromBinID,_qty, LOCATE ('DECREASE',_action);


	IF( LOCATE ('DEBUG',_action)>1) THEN
		select 'START BIN',b.* from v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID);
	END IF;
    
	IF( LOCATE ('ADJUSTMENT',_action)>0 ) THEN 
		call INV_updateInventoryOH('ADJUSTMENT',now(),null,_fromBinID,_toBinID, _reference,_reason,_qty,null,null,_prToWarehouseID, _userID);
		-- set _theCall = concat(_action, ' INV_updateInventoryOH( ADJUSTMENT,',_fromBinID,',',_qty,')');
	ELSEIF ( LOCATE ('COUNT',_action)>0) THEN
		call INV_updateInventoryOH('COUNT',now(),null,_fromBinID,_toBinID,_reference,_reason,_qty,null,null,_prToWarehouseID, _userID);
		-- set _theCall = concat(_action, ' INV_updateInventoryOH( COUNT,',_fromBinID,',',_qty,')');
    END IF;

	IF( LOCATE ('DEBUG',_action)>1) THEN

		select 'AFTER BIN',b.* from v_INV_bin b where binId in (_fromBinID,_fromBinID2,_toBinID);
		call GL_print('AFTER glTransaction',null,null,null,12);	

	END IF;

		-- expected results
		set _message = '';
        
		set _found=null;

    
    IF( LOCATE ('DECREASE',_action)>1) THEN
		select binId into _found from v_INV_bin where InventoryOnHand=20 and InventoryAllocated=15 and  AverageCost=10 and binId=_fromBinId;
		IF (_found is null) THEN set _message=concat(_message,' FAIL - bin');  END IF;
		select prTransferDetailID  into _found from prWHtransferDetail where QuantityTransfered=20 and QuantityAvailable = 100 and difference=-80 and prTransferID=_startingTransferID+1;
		IF (_found is null) THEN set _message=concat(_message,' FAIL - prTransfer');  END IF;


		select glTransactionId  into _found from glTransaction where debit=800 and credit=0 and coAccountId=187 and glTransactionId=_startingGlTransactionID+1;
		IF (_found is null) THEN set _message=concat(_message,' FAIL - glDebit');  END IF;
		select glTransactionId into _found from glTransaction where debit=0 and credit=800 and coAccountId=141 and glTransactionId=_startingGlTransactionID+2;
		IF (_found is null) THEN set _message=concat(_message,' FAIL - glCredit');  END IF;
	END IF;
    
    IF( LOCATE ('INCREASE',_action)>1) THEN
		select binId into _found from v_INV_bin where InventoryOnHand=120 and InventoryAllocated=15 and  AverageCost=10 and binId=_fromBinId;
		IF (_found is null) THEN set _message=concat(_message,'FAIL - bin');  END IF;
		select prTransferDetailID  into _found from prWHtransferDetail where QuantityTransfered=120 and QuantityAvailable = 100 and difference=20 and prTransferID=_startingTransferID+1;
		IF (_found is null) THEN set _message=concat(_message,' FAIL - prTransfer');  END IF;
		select glTransactionId  into _found from glTransaction where debit=0 and credit=200 and coAccountId=187 and glTransactionId=_startingGlTransactionID+1;
		IF (_found is null) THEN set _message=concat(_message,' FAIL - glDebit');  END IF;
		select glTransactionId into _found from glTransaction where debit=200 and credit=0 and coAccountId=141 and glTransactionId=_startingGlTransactionID+2;
		IF (_found is null) THEN set _message=concat(_message,' FAIL - glCredit');  END IF;
    END IF;

        
		if (CHAR_LENGTH(_message)<2) THEN set _message = concat(_action,' PASS'); END IF;
        
        select _message;

    
		call INV_testCreateDelete('DELETE');

END IF;

END$$

DELIMITER ;


-- =================================================================================
-- call INV_testCreateDelete('TEST-IDS');
-- call INV_testCreateDelete('DELETE');
-- call INV_testCreateDelete('DUMPTABLES');
-- call INV_testCreateDelete('CREATETESTTABLES');
-- =================================================================================

DROP procedure IF EXISTS `INV_testCreateDelete`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_testCreateDelete`(
	IN _action varchar(100)
)
INV_testCreateDelete : BEGIN
DECLARE _DEBUG tinyint;
DECLARE _coTaxTerritoryID INT;
DECLARE _prMasterID INT;
DECLARE _prMasterID2 INT DEFAULT -1;
DECLARE _coDivisionID INT;
DECLARE _cuTermsID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _prToWarehouseID INT;
DECLARE _fromBinID INT;
DECLARE _fromBinID2 INT;
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
DECLARE _vePOID INT;
DECLARE _vePODetailID INT;
DECLARE _veReceiveID INT;
DECLARE _veReceiveDetailID INT;
DECLARE _vePOID2 INT;
DECLARE _vePODetailID2 INT;
DECLARE _veReceiveID2 INT;
DECLARE _veReceiveDetailID2 INT;
DECLARE _veBillID INT;
DECLARE _veBillDetailID INT;
DECLARE _veBillID2 INT;
DECLARE _veBillDetailID2 INT;
DECLARE _cuSOID INT;
DECLARE _cuSOID2 INT;
DECLARE _cuSODetailID INT  DEFAULT -1;
DECLARE _cuSODetailID2 INT DEFAULT -1;
DECLARE _cuSODetailBinID INT;
DECLARE _cuInvoiceID INT;
DECLARE _cuInvoiceDetailID INT;
DECLARE _cuInvoiceID2 INT;
DECLARE _cuInvoiceDetailID2 INT;
DECLARE _cuInvoiceDetailBinID INT;
DECLARE _userID INT;
DECLARE _SONumber varchar(500);
DECLARE _SONumber2 varchar(500);
DECLARE _joMasterID INT;
DECLARE _joReleaseID INT;
DECLARE _joReleaseDetailID INT;
DECLARE _prDepartmentID INT;
DECLARE _delete INT default 0;
DECLARE _dumpTables INT default 0;
DECLARE _freight decimal(19,4);
DECLARE _UsePostDate INT;
DECLARE _reference varchar(255);
DECLARE _reason varchar(255);

DECLARE _result1 INT;

set _userID = 5;
set _coTaxTerritoryID=1;
set _coDivisionID =3;
set _cuTermsID =1;
set _prMasterID=10;
set _prMasterID2=11;
set _prDepartmentID=1;
set _prFromWarehouseID=1;
set _prToWarehouseID=2;
set _prFromWarehouesInventoryID=1;
set _prToWarehouesInventoryID=2;
set _vePOID=1;
set _vePODetailID=1;
set _vePOID2=2;
set _vePODetailID2=2;
set _veBillID=1;
set _veBillDetailID=1;
set _veReceiveID=1;
set _veReceiveDetailID=1;
set _veReceiveID2=2;
set _veReceiveDetailID2=2;
set _cuSOID=1;
set _cuSOID2=2;
set _cuSODetailID=1;
set _cuSODetailID2=2;
set _SONumber = 'TEST_NUMBER-1';
set _SONumber2 = 'TEST_NUMBER-2';
set _joReleaseID=1;
set _joReleaseDetailID=1;
set _joMasterID=1;
set _freight=20;
set _UsePostDate = 1;
set _fromBinID=100000; 
set _fromBinID2=100001;
set _toBinID=100002;
set _cuInvoiceID=1;
set _cuInvoiceDetailID=1;
set _cuInvoiceDetailID2=2;
set _cuInvoiceID2=2;
set _reference = 'AUTOMATEDTEST-REFERENCE';
set _reason = 'AUTOMATEDTEST-REASONCODE';


-- SETUP OF ALL DATA BEFORE TEST ===================================================
if (LOCATE ('DUMPTABLES',_action)=1) THEN
	set _dumpTables=1;
ELSEif (LOCATE ('TEST-IDS',_action)=1) THEN

		select * from prMaster where prMasterID in (_prMasterID,_prMasterID2);
		select * from prDepartment where prDepartmentID=prDepartmentID;
		select * from joRelease where joReleaseID=_joReleaseID;
		select * from joReleaseDetail where joReleaseDetailID=_joReleaseDetailID;
		select * from vePO where vePOID=_vePOID;
		select * from vePODetail where vePODetailID=_vePODetailID;
		select * from cuSO where cuSOID=_cuSOID;
		select * from cuSODetail where cuSODetailID=_cuSODetailID;
		select * from cuInvoice where cuInvoiceID=_cuInvoiceID;
		select * from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
		select * from veBill where veBillID=_veBillID;
		select * from veBillDetail where veBillDetailID=_veBillDetailID;
        
ELSEif (LOCATE ('DELETE',_action)=1) THEN
	set _delete =1;
    IF( LOCATE ('DEBUG',_action)>1) THEN set _DEBUG=1; END IF;

elseif (LOCATE ('CREATETESTTABLES',_action)=1) THEN
    
	-- TEST TO SEE IF ID's ARE AVAILABLE FOR TESTING.
	select cuSOID into _found from cuSO where cuSOID=_cuSOID;
	if (_found is NOT NULL) THEN

			select * from cuSO order by cuSOID asc limit 10 ;

			set _message = concat('cuSOID ALREADY EXISTS run DELETE',_cuSOID);
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;

	select cuSODetailID into _found from cuSODetail where cuSODetailID=_cuSODetailID;
	if (_found is NOT NULL) THEN

			select * from cuSODetail order by cuSODetailID asc limit 10 ;

			set _message = concat('cuSODetailID ALREADY EXISTS  run DELETE',_cuSODetailID);
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;


	select cuInvoiceID into _found from cuInvoice where cuSOID=_cuSOID;
	if (_found is NOT NULL) THEN

			select * from cuInvoice order by cuInvoiceID asc limit 10 ;

			set _message = concat('cuInvoice ALREADY EXISTS  run DELETE',_found);
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;

	/*
	select cuInvoiceDetailID into _found from cuInvoiceDetail where cuInvoiceDetailID=_cuInvoiceDetailID;
	if (_found is NOT NULL) THEN

			select * from cuInvoiceDetail order by cuInvoiceDetailID asc limit 10 ;

			set _message = concat('cuInvoiceDetail ALREADY EXISTS ',_cuInvoiceDetailID);
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;
	*/

	select vePOID into _found from vePO where vePOID=_vePOID;
	if (_found is NOT NULL) THEN

			select * from vePO order by vePOID asc limit 10 ;

			set _message = concat('VEPO ALREADY EXISTS  run DELETE',_vePOID);
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;


	select prMasterID into _found from prMaster where prMasterID=_prMasterID;
	if (_found is NOT NULL) THEN

			select * from prMaster;
			SELECT * FROM prWarehouseInventory;
			select * from bin order by binId desc;

			set _message = concat('PRODUCT ALREADY EXISTS  run DELETE',_prMasterID);
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;

	set _found = null;
	select prWarehouseInventoryID into _found from prWarehouseInventory where prWarehouseInventoryID in (_prFromWarehouesInventoryID,_prToWarehouesInventoryID) limit 1;
	if (_found is NOT NULL) THEN

			select * from prMaster;
			SELECT * FROM prWarehouseInventory;
			select * from bin order by binId desc;

			set _message = concat('prWarehouseInventory ALREADY EXISTS  run DELETE',_prFromWarehouesInventoryID, ' or ',_prToWarehouesInventoryID );
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;

/*
	set _found = null;
	select binId into _found from bin where binId in (_fromBinID,_fromBinID2,_toBinID) limit 1;
	if (_found is NOT NULL) THEN

			select * from prMaster;
			SELECT * FROM prWarehouseInventory;
			select * from bin order by binId desc;

			set _message = concat('BIN ALREADY EXISTS ',_fromBinID, ' or ',_fromBinID,' or ', _toBinID);
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE INV_testCreateDelete; 
	END IF;
*/
	-- GET MAX ID's before starting    
	select max(glTransactionID) into _startingGlTransactionID from glTransaction; 
	select max(prTransferID) into _startingTransferID from prWHtransfer; 
	select _startingGlTransactionID as LastGLTransaction;
/*
	if (_startingGlTransactionID is null or _startingGlTransactionID <100 or _startingTransferID is null or _startingTransferID <100) THEN
				set _message = concat('GL/Transfer Max invalid ',_startingGlTransactionID, ' or ', _startingTransferID );
				 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
				LEAVE INV_testCreateDelete; 
	END IF;
*/
	-- SETUP
	insert into coTaxTerritory (coTaxTerritoryID,TaxRate,TaxShipping,taxfreight,inActive) values (_coTaxTerritoryID,8.2500,1,1,0);
    
    -- insert into prDepartment () values ();

	insert into prMaster (prMasterID,prDepartmentID,prCategoryID,ItemCode,IsInventory, AverageCost,LastCost, Description) values (_prMasterID,_prDepartmentID,1,'ABC-Product',1,5,5,'1/2 Round Nut');
	insert into prMaster (prMasterID,prDepartmentID,prCategoryID,ItemCode,IsInventory, AverageCost,LastCost, Description) values (_prMasterID2,_prDepartmentID,1,'TEST_NOT_STOCK_ITM',0,5,5,'Bolt Not Stocked');
	-- SELECT LAST_INSERT_ID() INTO _prMasterID2;    

	insert IGNORE into prWarehouseInventory (prWarehouseInventoryID, prMasterID,prWarehouseID) values (_prFromWarehouesInventoryID,_prMasterID,_prFromWarehouseID);
	insert IGNORE into prWarehouseInventory (prWarehouseInventoryID, prMasterID,prWarehouseID) values (_prToWarehouesInventoryID,_prMasterID,_prToWarehouseID);

	insert IGNORE into bin (binId, prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_fromBinID,_prFromWarehouseID,_prFromWarehouesInventoryID,_prMasterID,1,null,null,null,concat(_prMasterID,'-from-',_prFromWarehouesInventoryID),concat(_prMasterID,'-from-',_prFromWarehouesInventoryID),null,100,15,0,10,1,now());

	insert IGNORE into bin (binId, prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_fromBinID,_prFromWarehouseID,_prFromWarehouesInventoryID,_prMasterID,1,null,null,null,concat(_prMasterID,'-from-',_prFromWarehouesInventoryID),concat(_prMasterID,'-from-',_prFromWarehouesInventoryID),null,100,15,0,10,1,now());
	-- SELECT LAST_INSERT_ID() INTO _fromBinID;

	insert IGNORE into bin (binId, prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_fromBinID2,_prFromWarehouseID,_prFromWarehouesInventoryID,_prMasterID,2,null,null,null,concat(_prMasterID,'-from2-',_prFromWarehouesInventoryID),concat(_prMasterID,'-from2-',_prFromWarehouesInventoryID),null,100,15,0,10,1,now());
	-- SELECT LAST_INSERT_ID() INTO _fromBinID2;

	insert IGNORE into bin (binId, prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
	values (_toBinID,_prToWarehouseID,_prToWarehouesInventoryID,_prMasterID,1,null,null,null,concat(_prMasterID,'-to-',_prToWarehouesInventoryID),concat(_prMasterID,'-to-',_prToWarehouesInventoryID),null,100,15,0,10,1,now());
	-- SELECT LAST_INSERT_ID() INTO _toBinID;

	insert ignore into joMaster (joMasterID,JobNumber) values (_joMasterID,_SONumber);
	insert ignore into joRelease (joReleaseID, joMasterID,coDivisionID) values (_joReleaseID,_joMasterID,1); -- keep it on, as it will be changed to the real _coDivisionID
	insert ignore into joReleaseDetail (joReleaseDetailID, joReleaseID, joMasterID) values (_joReleaseDetailID,_joReleaseID,_joMasterID);

/*
	insert IGNORE into vePO (vePOID,joReleaseID,prWarehouseID,rxVendorID,PONumber) 
	values (_vePOID,1,_prFromWarehouseID,3,_SONumber);

	insert IGNORE into vePODetail (vePODetailID,vePOID,prMasterID,QuantityOrdered,UnitCost,Description) 
	values (_vePODetailID,_vePOID,_prMasterID,100,10,'Vulcan Mind Weld');


	-- need to find the function to create receive, as it creates GL.
	insert IGNORE into veReceive (veReceiveID, rxMasterID, vePOID, ReceiveDate) 
	values (_veReceiveID,1,_vePOID,now());

	insert IGNORE into veReceiveDetail (veReceiveDetailID, veReceiveID, vePODetailID, prMasterID, Description, Note, QuantityReceived, vePOID) 
	values (_veReceiveDetailID,_veReceiveID,_vePODetailID,_prMasterID,'Vulcan Mind Weld','note',100,_vePOID);
*/


	insert IGNORE into cuSO (cuSOID,prFromWarehouseID,prToWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID) 
	values (_cuSOID,_prFromWarehouseID,_prToWarehouseID,_joReleaseID,_SONumber,962,_coTaxTerritoryID,_SONumber,962,150,15,10.0,_freight,_coDivisionID, _cuTermsID);

	insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	values (_cuSODetailID,_cuSOID,_prMasterID,150,10,6,1);


-- 	insert IGNORE into cuSO (cuSOID,prFromWarehouseID, joReleaseID, SONumber,rxBillToID,coTaxTerritoryID,Tag,rxCustomerID,SubTotal,TaxTotal,TaxRate,Freight,coDivisionID,cuTermsID) 
-- 	values (_cuSOID2,_prFromWarehouseID,_joReleaseID,_SONumber2,962,_coTaxTerritoryID,_SONumber,962,100,15,10.0,_freight,_coDivisionID, _cuTermsID);

-- 	insert IGNORE into cuSODetail (cuSODetailID,cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
-- 	values (_cuSODetailID2,_cuSOID2,_prMasterID,100,10,6,1);


	-- insert IGNORE into cuSODetail (cuSOID,prMasterID,QuantityOrdered,UnitCost,whseCost,Taxable) 
	-- values (_cuSOID,_prMasterID,150,10,6,1);
	-- SELECT LAST_INSERT_ID() INTO cuSODetailID2;

	-- insert IGNORE into veBill (veBillID,vePOID, joReleaseDetailID, InvoiceNumber,BillAmount,TaxAmount,FreightAmount) 
	-- values (_veBillID,_vePOID,_joReleaseDetailID,_SONumber,150,15,20);

	-- insert IGNORE into veBillDetail (veBillDetailID,veBillID,prMasterID,QuantityBilled,UnitCost,FreightCost,Taxable,PriceMultiplier,vePOID) 
	-- values (_veBillDetailID,_veBillID,_prMasterID,150,10,6,1,1,_vePOID);

	select 'SETTING UP FOR TEST',_fromBinID,_fromBinID2,_toBinID,_prFromWarehouesInventoryID,_prToWarehouesInventoryID,_coTaxTerritoryID,_prMasterID;

	/*
	insert IGNORE into cuInvoice (cuInvoiceID,prFromWarehouseID,rxBillToID,InvoiceNumber) 
	values (_cuInvoiceID,_prFromWarehouseID,844,'ABC123-C');

	insert IGNORE into cuInvoiceDetail (cuInvoiceDetailID,cuInvoiceID,prMasterID,QuantityBilled,UnitPrice) 
	values (_cuInvoiceDetailID,_cuInvoiceID,_prMasterID,150,10);
	*/
    

END IF;

if (_dumpTables=1) THEN

		select 'DUMPING TABLES';
        
		select * from prMaster where prMasterID in (_prMasterID,_prMasterID2);
		select * from prDepartment where prDepartmentID=prDepartmentID;
		select * from joRelease where joReleaseID=_joReleaseID;
		select * from joReleaseDetail where joReleaseDetailID=_joReleaseDetailID;

		select v_INV_bin.* from v_INV_bin where prMasterID = _prMasterID;
		
		select 'GL BY STARTING',g.*,a.Description from glTransaction g left join coAccount a on (a.coAccountID = g.coAccountID) where glTransactionID > _startingGlTransactionID;
		select 'GL BY STARTING',g.* from glLinkage g where  glTransactionID > _startingGlTransactionID;
		select 'GL BY STARTING',g.* from glTransactionReversal g where glTransactionID > _startingGlTransactionID;
	
		select 'GL BY REF',g.* from glTransaction g left join coAccount a on (a.coAccountID = g.coAccountID) where (reference=concat(_SONumber,'1'));
		select 'GLR BY REF',g.* from glTransactionReversal g where glTransactionID in (select glTransactionID from glTransaction where reference=concat(_SONumber,'1'));
    
		select veReceiveDetailID into _veReceiveDetailID from veReceiveDetail where vePODetailID = _vePODetailID;

		select * from vePO where vePOID=_vePOID;
		select * from vePODetail where vePOID=_vePOID;
		select * from cuSO where cuSOID=_cuSOID;
		select * from cuSODetail where cuSODetailID=_cuSODetailID;
		select * from cuSODetailBin where  cuSODetailID=_cuSODetailID;
		select * from cuSO where cuSOID=_cuSOID2;
		select * from cuSODetail where cuSODetailID=_cuSODetailID2;
		select * from cuSODetailBin where  cuSODetailID=_cuSODetailID2;


		select * from veReceive where vePOID=_vePOID;
		select * from veReceiveDetail where veReceiveDetailID=_veReceiveDetailID;
		select * from veReceiveDetailBin where veReceiveDetailID=_veReceiveDetailID;
		-- select * from vePODetailBin where  vePODetailID in (select vePODetailID from vePODetail where vePOID = _vePOID) order by LastUpdatedTime DESC limit 10;
	
		select cuInvoiceID into _cuInvoiceID from cuInvoice where cuSOID = _cuSOID;
		select * from cuInvoice where cuInvoiceID=_cuInvoiceID;
		select * from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
		select * from cuInvoiceDetailBin where  cuInvoiceDetailID in (select cuInvoiceDetailID from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID);
		select * from veBill where veBillID=_veBillID;
		select * from veBillDetail where veBillDetailID=_veBillDetailID;

		select * from prWHtransfer where prTransferID > _startingTransferID;
		select * from prWHtransferDetail where prTransferID > _startingTransferID;

		select * from tpInventoryLogMaster where prMasterID=_prMasterID  order by tpInventoryLogID DESC;
        
        set _message = 'TABLE DUMPED';
    
END IF;


-- DELETE AFTER EACH RUN'

if (_delete=1) THEN

	if (_DEBUG=1) THEN select 'delete product related'; end if;
    
	delete from prWarehouseInventory where prMasterID in (_prMasterID,_prMasterID2);
	delete from bin where binId in (_fromBinID,_fromBinID2,_toBinID);
	delete from prMaster where prMasterID in (_prMasterID,_prMasterID2);
	delete from tpInventoryLogMaster where prMasterID = _prMasterID ;

	if (_DEBUG=1) THEN select 'delete transfer related',_startingTransferID; end if;
	delete from prWHtransferDetail where prMasterID = _prMasterID and prTransferDetailID>0;
	delete from prWHtransfer where prToWareHouseID = _prToWareHouseID or prFromWareHouseID=_prFromWareHouseID;

/*    
    if (_startingGlTransactionID>0) THEN

		if (_DEBUG=1) THEN select 'delete glTransaction related',_startingGlTransactionID; end if;
		delete from glLinkage where  glTransactionID > _startingGlTransactionID and glLinkageID >0;
		delete from glTransaction where glTransactionID > _startingGlTransactionID;
		delete from glTransactionReversal where glTransactionID > _startingGlTransactionID and glTransactionID >0;
	END IF;
*/

		delete from glLinkage where  glTransactionID in (select glTransactionID from glTransaction where enteredBy is null);
		delete from glTransaction where enteredBy is null;    

    IF( LOCATE ('GL',_action)>1) THEN 
   
	if (_SONumber is not null) then

		if (_DEBUG=1) THEN select 'delete glTransaction _SONumber',_SONumber; end if;

		delete from glTransactionReversal where glTransactionID in (select glTransactionID from glTransaction where LOCATE(_SONumber, reference)>0);
		delete from glTransactionReversal where glTransactionID in (select glTransactionID from glTransaction where LOCATE(_SONumber2, reference)>0);
		delete from glLinkage where  glTransactionID in (select glTransactionID from glTransaction where LOCATE(_SONumber, reference)>0);
		delete from glLinkage where  glTransactionID in (select glTransactionID from glTransaction where LOCATE(_SONumber2, reference)>0);
		delete from glTransaction where LOCATE(_SONumber, reference)>0 and glTransactionID>0;    
		delete from glTransaction where LOCATE(_SONumber2, reference)>0 and glTransactionID>0;    
    END IF;
    
    if (_reference is not null) THEN
	
		if (_DEBUG=1) THEN select 'delete glTransaction _reference',_reference; end if;

		delete from glLinkage where  glTransactionID in (select glTransactionID from glTransaction where LOCATE (_reference,reference)>0);
		delete from glTransaction where LOCATE (_reference,reference)>0 and glTransactionID>0;    
    END if;
    
     if (_reason is not null) THEN
     
		if (_DEBUG=1) THEN select 'delete glTransaction _reason',_reason; end if;
     
		delete from glLinkage where  glTransactionID in (select glTransactionID from glTransaction where LOCATE (_reason,transactionDesc)>0);
		delete from glTransaction where LOCATE (_reason,transactionDesc)>0 and glTransactionID>0;        
    END if;   
   

	END IF; -- IF GL
    
	-- delete from vePODetailBin where  vePODetailID in (select vePODetailID from vePODetail where vePOID = _vePOID);
    -- select vePODetailID into _vePODetailID from vePODetail where vePOID = _vePOID;

	if (_DEBUG=1) THEN select 'delete vePO '; end if;
	 
	delete from vePODetail where  vePOID = _vePOID and vePODetailID>0;
	delete from vePO where  vePOID = _vePOID;
	delete from vePODetail where  vePOID = _vePOID2 and vePODetailID>0;
	delete from vePO where  vePOID = _vePOID2;

	-- select joReleaseDetailID into _joReleaseDetailID from cuInvoice where cuSOID=_cuSOID;
	-- delete from joReleaseDetail where joReleaseDetailID in 
    -- ( select joReleaseDetailID from cuInvoice where cuSOID=_cuSOID );

	if (_DEBUG=1) THEN select 'delete cuInvoice ',_cuSOID,_cuSODetailID; end if;

	if(_cuSODetailID is not null) THEN 
		delete from cuInvoiceDetail where  cuSODetailID = _cuSODetailID and _cuInvoiceDetailID>0; 
		delete from cuInvoiceDetail where  cuSODetailID = _cuSODetailID2 and _cuInvoiceDetailID>0; 
		delete from cuInvoice where  cuSOID = _cuSOID and cuInvoiceID>0; 
		delete from cuInvoice where  cuSOID = _cuSOID2 and cuInvoiceID>0; 
	END IF;

	if (_cuInvoiceID is not null) THEN
		delete from cuInvoice where  cuInvoiceID in (_cuInvoiceID,_cuInvoiceID2) ;
	END IF;

	if (_cuInvoiceDetailID is not null) THEN
		-- delete from cuInvoiceDetail where  cuInvoiceDetailID = _cuInvoiceDetailID;
		delete from cuInvoiceDetail where  cuInvoiceID = _cuInvoiceID and cuInvoiceDetailID>0;
		delete from cuInvoiceDetailBin where  cuInvoiceDetailID = _cuInvoiceDetailID and cuInvoiceDetailBinID>0;
		-- delete from cuInvoiceDetailBin where  cuSODetailBinID in (select cuSODetailBinID from cuSODetailBin where cuSODetailID=_cuSODetailID);
	END IF;


	select veBillID into _veBillID from veBill where CreatedByID=-999;
	if (_DEBUG=1) THEN select 'delete veBill ',_veBillID; end if;
    
	delete from veBill where  veBillID = _veBillID;
	delete from veBillDetail where  veBillID = _veBillID;

	select veBillID into _veBillID2 from veBill where CreatedByID=-998;

	delete from veBill where  veBillID = _veBillID2;
	delete from veBillDetail where  veBillID = _veBillID2;

    
	delete from veBillDetail where description=_SONumber;
	-- delete from veBill where  veBillID = _veBillID2;
	-- delete from veBillDetail where  veBillDetailID = _veBillDetailID2;
	delete from veBillDetail where description=_SONumber2;
	delete from veReceiveDetail where  vePODetailID = _vePODetailID;
	delete from veReceiveDetail where  vePODetailID = _vePODetailID2;
	delete from veReceive where  vePOID = _vePOID and veReceiveID>0;
	delete from veReceive where  vePOID = _vePOID2 and veReceiveID>0;
    
	if (_DEBUG=1) THEN select 'delete cuSO '; end if;
    
	delete from cuSO where  cuSOID = _cuSOID;
	delete from cuSO where  cuSOID = _cuSOID2;
	delete from cuSODetail where  cuSODetailID in ( _cuSODetailID,_cuSODetailID2);
	delete from cuSODetailBin where  cuSODetailID = _cuSODetailID and cuSODetailBinID>0;
	delete from cuSODetailTicket where  cuSOID = _cuSOID;

	delete from cuSODetailBin where  cuSODetailID = _cuSODetailID2 and cuSODetailBinID>0;
	delete from cuSODetailTicket where  cuSOID = _cuSOID2;


/*    
	select veReceiveDetailID into _veReceiveDetailID from veReceiveDetail where vePODetailID = _vePODetailID;
	delete from veReceiveDetail where  veReceiveDetailID = _veReceiveDetailID;
	delete from veReceiveDetailBin where  veReceiveDetailID = _veReceiveDetailID and veReceiveDetailBinID>0;
	delete from veReceive where  vePOID = _vePOID and veReceiveID>0;
*/
	delete from joReleaseDetail where joReleaseDetailID=_joReleaseDetailID;
	delete from joRelease where joReleaseID=_joReleaseID;
	delete from joMaster where joMasterID=_joMasterID;

	delete from coTaxTerritory where coTaxTerritoryID=_coTaxTerritoryID;

	-- select 'DELETING',_prFromWarehouesInventoryID,_prToWarehouesInventoryID,_fromBinID,_fromBinID2,_toBinID,_prMasterID,_cuSOID,
    -- _cuSODetailID,_cuInvoiceID,_cuInvoiceDetailID,_veReceiveDetailID,_veReceiveDetailID2,_vePOID,_vePOID2,
    -- _startingTransferID,_startingGlTransactionID,_coTaxTerritoryID,
    -- _veBillID,_veBillDetailID,_veBillID2,_veBillDetailID2,_joMasterID,_joReleaseID,_joReleaseDetailID;
	call GL_print('DELETING glTransaction',null,null,null,12);	

end if;


END$$

DELIMITER ;




