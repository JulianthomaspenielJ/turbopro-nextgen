-- ==================================================================
-- openSalesOrders will add up all cuSODetailID's for a prMasterID and prWarehouseID
--    and update the bin with the correct allocated amount
--
-- call FIX_tool('openSalesOrders',280,2, 'REVIEW_FIRST'); -- 'REVIEW_FIRST or COMMIT'
-- call FIX_tool('openSalesOrders',280,2, 'REVIEW_FIRST'); -- 'REVIEW_FIRST or COMMIT'

-- ==================================================================
DELIMITER ;

DROP procedure IF EXISTS `FIX_tool`;

DELIMITER $$

CREATE  PROCEDURE FIX_tool(
IN _action VARCHAR(100),
IN _prMasterId INT,
IN _prWarehouseId INT,
IN _reviewChange varchar(25), -- 'REVIEW_FIRST or COMMIT'
IN _binId INT
)
FIX_tool: BEGIN

DECLARE _correctAllocation DECIMAL(19,4);
DECLARE _binToUpdateId INT;
DECLARE _currentBinAllocation INT;
DECLARE _ItemCode varchar(200);
DECLARE _prWarehouse varchar(200);
DECLARE _version INT;
DECLARE _binNumber INT;
DECLARE _prInventoryAllocated INT;

DECLARE _AverageCost decimal(19,4);
DECLARE _applyGovenor int DEFAULT 1;
DECLARE _inventories text;
DECLARE _salesOrderBinAlloc decimal(19,4);
DECLARE _transferAllocated decimal(19,4);
DECLARE _count int;

DECLARE _ids    text;
DECLARE _id    INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;



-- call FIX_tool('openSalesOrders',280,2, 'REVIEW_FIRST',null); -- 'REVIEW_FIRST or COMMIT'
-- call FIX_tool('AVERAGECOST_BIN',280,null,  'REVIEW_FIRST',null); -- 'REVIEW_FIRST or COMMIT'
-- call FIX_tool('BIN_ALLOCATION',280,null,  'REVIEW_FIRST',null); -- 'REVIEW_FIRST or COMMIT'
-- call FIX_tool('AVERAGECOST_PRODUCT',1005,null,  'REVIEW_FIRST',null); -- 'REVIEW_FIRST or COMMIT'
-- call FIX_tool('AVERAGECOST_PRODUCT_NO_GOVENOR',1005,null,  'REVIEW_FIRST',null); -- 'REVIEW_FIRST or COMMIT'
-- call FIX_tool('veBill_lineItemCount',null,null,  'REVIEW_FIRST',null); -- 'REVIEW_FIRST or COMMIT'

if (_action ='AVERAGECOST_PRODUCT_NO_GOVENOR') then 
	set _applyGovenor=0; 
    set _action ='AVERAGECOST_PRODUCT';
END IF;

if (_action ='veBill_lineItemCount') then 


	select GROUP_CONCAT(distinct(v.veBillID))
	into _ids
	from veBillDetail d 
    left join veBill v on (v.veBillID = d.veBillID)
    where 
    -- d.prMasterID = _prMasterId and 
    v.lineItemCount is null 
    -- group by d.veBillID 
    order by v.veBillID;
	
            do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);

	set _count=0;
	select count(*) into _count from veBillDetail where veBillID = _id;

	if (_reviewChange = 'REVIEW_FIRST') THEN
		select _id as veBillID, _count as lineItemCount;
	ELSEif (_reviewChange = 'COMMIT') THEN
        update veBill set lineItemCount =_count  where veBillID =  _id;
	END IF;
	
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 	
            
elseif (_action ='AVERAGECOST_PRODUCT') then


	select GROUP_CONCAT(distinct(v.veBillID))
	into _ids
	from veBillDetail d 
    left join veBill v on (v.veBillID = d.veBillID)
    where d.prMasterID = _prMasterId and v.lineItemCount is null 
    -- group by d.veBillID 
    order by v.veBillID;
	
            do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);

	set _count=0;
	select count(*) into _count from veBillDetail where veBillID = _id;

	if (_reviewChange = 'REVIEW_FIRST') THEN
		select _id as veBillID, _count as lineItemCount,_ids;
	ELSEif (_reviewChange = 'COMMIT') THEN
        update veBill set lineItemCount =_count  where veBillID =  _id;
	END IF;
	
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 	
	
	if (_reviewChange = 'COMMIT') THEN
		call INVOICE_recalculate_avgCost(null,_prMasterId,_applyGovenor,null);
	END IF;


elseif (_action ='openSalesOrders') then


	select count(*) into _binNumber from bin where prMasterID= _prMasterId and prWarehouseID = _prWarehouseId;
    
    if (_binNumber>1) THEN
		select 'MULTIPLE BINS FOUND', _binNumber,_prMasterId,_prWarehouseId, 'RESEARCH BEFOR CONTINUING';
        select group_concat(binId) into  _inventories from bin where prMasterID= _prMasterId and prWarehouseID = _prWarehouseId;
        do_this:
		   LOOP
		 
		 SET strLen = CHAR_LENGTH(_inventories);
								
		 set _binId=SUBSTRING_INDEX(_inventories, ',', 1);

		select sum(SO_QuantityOrdered) - sum(SO_QuantityBilled), binId,InventoryAllocated 
		into _salesOrderBinAlloc,_binToUpdateId,_prInventoryAllocated
		from
		(
			select p.ItemCode, p.IsInventory, p.prMasterID, so.prFromWarehouseID, so.cuSOID, s.cuSODetailID, so.SONumber, 
			so.OrderDate, so.CreatedOn,  
			s.QuantityOrdered as SO_QuantityOrdered, s.QuantityBilled as SO_QuantityBilled,
			sob.allocated as SODETAILBIN_QuantityOrdered, sob.QuantityBilled SODETAILBIN_QuantityBilled,
			sob.binId, b.InventoryAllocated as BIN_Allocated,p.InventoryAllocated
			from cuSODetail s
			left join cuSO so on (so.cuSOID = s.cuSOID)
			left join prMaster p on (p.prMasterID = s.prMasterID)
			left join cuSODetailBin sob on (sob.cuSODetailID = s.cuSODetailID)
			left join bin b on (b.binId = sob.binId)
			where s.QuantityOrdered<> s.QuantityBilled
			and p.prMasterID not in (19,2) and p.IsInventory=1 and so.TransactionStatus=1 
			and sob.binId = _binId
		) raw;
        
        
        select sum(pwd.QuantityTransfered) into _transferAllocated
        from prWHtransferDetail pwd 
		left join prWHtransfer pw on (pw.prTransferID = pwd.prTransferID ) 
		where pwd.toBinId is null and pwd.ReceivedDate is null and pw.screenno = 1 and pwd . fromBinId = _binId;
        
        set _binToUpdateId = _binId;
         set _correctAllocation = ifnull(_salesOrderBinAlloc,0)+ifnull(_transferAllocated,0);
			call INV_updateOH('REPLACE',_binToUpdateId,null,_correctAllocation,null,1);
		 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_inventories, ',', 1))+2;
		 SET _inventories = MID(_inventories, SubStrLen, strLen);

		 IF _inventories = '' or _inventories is null  THEN
		   LEAVE do_this;
		 END IF;
		END LOOP do_this;
        leave FIX_tool;
    else


		select sum(SO_QuantityOrdered) - sum(SO_QuantityBilled), binId,InventoryAllocated 
		into _correctAllocation,_binToUpdateId,_prInventoryAllocated
		from
		(
			select p.ItemCode, p.IsInventory, p.prMasterID, so.prFromWarehouseID, so.cuSOID, s.cuSODetailID, so.SONumber, 
			so.OrderDate, so.CreatedOn,  
			s.QuantityOrdered as SO_QuantityOrdered, s.QuantityBilled as SO_QuantityBilled,
			sob.allocated as SODETAILBIN_QuantityOrdered, sob.QuantityBilled SODETAILBIN_QuantityBilled,
			sob.binId, b.InventoryAllocated as BIN_Allocated,p.InventoryAllocated
			from cuSODetail s
			left join cuSO so on (so.cuSOID = s.cuSOID)
			left join prMaster p on (p.prMasterID = s.prMasterID)
			left join cuSODetailBin sob on (sob.cuSODetailID = s.cuSODetailID)
			left join bin b on (b.binId = sob.binId)
			where s.QuantityOrdered<> s.QuantityBilled
			and p.prMasterID not in (19,2) and p.IsInventory=1 and so.TransactionStatus=1 
			and p.prMasterID = _prMasterId and so.prFromWarehouseID =_prWarehouseId
		) raw;

		select InventoryAllocated into _currentBinAllocation from bin where binId = _binToUpdateId;

		select  ItemCode,InventoryAllocated into _ItemCode,_prInventoryAllocated from prMaster where prMasterID = _prMasterId;
		select Description into _prWarehouse from prWarehouse where prWarehouseID = _prWarehouseId;

		if (_binToUpdateId is null) THEN
					select binId, 0 into _binToUpdateId,_correctAllocation from bin where prMasterID=_prMasterId and prWarehouseID=_prWarehouseId limit 1;
					select InventoryAllocated into _currentBinAllocation from bin where binId = _binToUpdateId;
		END IF;


		
		if (_reviewChange = 'REVIEW_FIRST') THEN

			select _reviewChange,_binToUpdateId, _currentBinAllocation, _correctAllocation,_prInventoryAllocated as allProductWHAddedUp,_ItemCode, _prWarehouse;

		elseif (_reviewChange = 'COMMIT' and _binToUpdateId is not null) THEN

			select procedureVersion into _version from tp_version;
		
			if (_version < 42) THEN 

				select "PROCEDURE VERSION IS LESS THAN 42.  PLEASE APPLY UPDATES BEFORE COMMIT WILL HAPPEN";
			
			else

				-- select 'update';
				call INV_updateOH('REPLACE',_binToUpdateId,null,_correctAllocation,null,1);
				-- update bin set InventoryAllocated=_correctAllocation where binId=_binToUpdateId;
				select _reviewChange,_binToUpdateId, _currentBinAllocation, _correctAllocation,_prInventoryAllocated as allProductWHAddedUp,_ItemCode, _prWarehouse;

			END IF;
			
		END IF;
	END IF;

elseif (_action = 'AVERAGECOST_BIN') THEN

		select group_concat(b.binId) into  _inventories
		from bin b
		left join prMaster pr on pr.prMasterID = b.prMasterID 
		where b.AverageCost <> pr.AverageCost;
		select _inventories;
		 do_this:
		   LOOP
		 
		 SET strLen = CHAR_LENGTH(_inventories);
								
		 set _binId=SUBSTRING_INDEX(_inventories, ',', 1);

		select prMasterID into _prMasterID from bin where binId = _binId;
        
        select AverageCost into _AverageCost   from prMaster where prMasterID = _prMasterID;
		
		if (_AverageCost is  null) THEN set _AverageCost = 0; end if;
		
        update bin set AverageCost = _AverageCost where binId = _binId;
			
		 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_inventories, ',', 1))+2;
		 SET _inventories = MID(_inventories, SubStrLen, strLen);

		 IF _inventories = '' or _inventories is null  THEN
		   LEAVE do_this;
		 END IF;
		END LOOP do_this;

elseif(_action = 'BIN_ALLOCATION') then
	
        select sum(SO_QuantityOrdered) - sum(SO_QuantityBilled), binId,InventoryAllocated 
		into _salesOrderBinAlloc,_binToUpdateId,_prInventoryAllocated
		from
		(
			select p.ItemCode, p.IsInventory, p.prMasterID, so.prFromWarehouseID, so.cuSOID, s.cuSODetailID, so.SONumber, 
			so.OrderDate, so.CreatedOn,  
			s.QuantityOrdered as SO_QuantityOrdered, s.QuantityBilled as SO_QuantityBilled,
			sob.allocated as SODETAILBIN_QuantityOrdered, sob.QuantityBilled SODETAILBIN_QuantityBilled,
			sob.binId, b.InventoryAllocated as BIN_Allocated,p.InventoryAllocated
			from cuSODetail s
			left join cuSO so on (so.cuSOID = s.cuSOID)
			left join prMaster p on (p.prMasterID = s.prMasterID)
			left join cuSODetailBin sob on (sob.cuSODetailID = s.cuSODetailID)
			left join bin b on (b.binId = sob.binId)
			where s.QuantityOrdered<> s.QuantityBilled
			and p.prMasterID not in (19,2) and p.IsInventory=1 and so.TransactionStatus=1 
			and sob.binId = _binId
		) raw;
		
        select sum(pwd.QuantityTransfered) into _transferAllocated
        from prWHtransferDetail pwd 
		left join prWHtransfer pw on (pw.prTransferID = pwd.prTransferID ) 
		where pwd.toBinId is null and pwd.ReceivedDate is null and pw.screenno = 1 and pwd . fromBinId = _binId;
        
        set _binToUpdateId = _binId;
         set _correctAllocation = ifnull(_salesOrderBinAlloc,0)+ifnull(_transferAllocated,0);
        --  select ifnull(_binToUpdateId,0),ifnull(_correctAllocation,0);
         call INV_updateOH('REPLACE',_binToUpdateId,null,_correctAllocation,null,1);


END IF;

END$$


DELIMITER ;


-- ==================================================================
-- Tool to move gl records from one period to another on a specific date.
-- 	will also change veBill records related to these gl's
--
-- call FIX_tool_GL('MOVE_PERIOD_REVIEW',1,'VB', '2022-02-17', 1); 
-- call FIX_tool_GL('MOVE_PERIOD_COMMIT',1,'VB', '2022-02-17', 1); 
-- ==================================================================

DROP procedure IF EXISTS `FIX_tool_GL`;

DELIMITER $$

CREATE  PROCEDURE FIX_tool_GL(
IN _action VARCHAR(100),
IN _oldPeriod INT,
IN _journalId varchar(100),
IN _entrydate date,
IN _newPeriod INT
)
FIX_tool_GL: BEGIN

DECLARE _finished INTEGER DEFAULT 0;
DECLARE _recordFound int;
 
DECLARE _glTransactionId,_coFiscalPeriodId,  _coFiscalYearId, _veBillID int ;
DECLARE _pStartDate, _pEndDate,_yStartDate, _yEndDate datetime;
DECLARE _fyear varchar(10); 

DECLARE _targetGl CURSOR FOR 
select glTransactionId from glTransaction where period = _oldPeriod 
and journalId=_journalId and Date(entrydate) = _entrydate;


DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET _finished = 1;

	

if (locate('MOVE_PERIOD',_action)>0) then


		select 'BEFORE', t.*,v.veBillID, v.UsePostDate, v.BillDate, v.ReceiveDate 
			from glTransaction t
			left join glLinkage l on (l.glTransactionId = t.glTransactionId and l.coLedgerSourceId=6220)
            left join veBill v on (v.veBillID = l.veBillID )
			where t.period = _oldPeriod and t.journalId=_journalId 
            and Date(t.entrydate) = _entrydate;
            
	if (locate('COMMIT',_action)>0) THEN


	select p.coFiscalPeriodID,p.StartDate, p.EndDate, p.coFiscalYearID,y.fiscalYear, y.StartDate, y.EndDate 
	into 
	_coFiscalPeriodId, _pStartDate, _pEndDate, _coFiscalYearId, _fyear, _yStartDate, _yEndDate
	from coFiscalPeriod p 
	left join coFiscalYear y on (y.coFiscalYearID  =p.coFiscalYearID)  where p.period=_newPeriod;

	select _coFiscalPeriodId, _pStartDate, _pEndDate, _coFiscalYearId, _fyear, _yStartDate, _yEndDate;

	OPEN _targetGl;
		readRecords: LOOP
			-- FETCH _recruitIds INTO _recruitId;
            FETCH _targetGl INTO _glTransactionId;
			IF _finished = 1 THEN 
				LEAVE readRecords;
			END IF;

			update glTransaction set coFiscalPeriodId = _coFiscalPeriodId, 
			period = _newPeriod, 
			pStartDate = _pStartDate, 
			pEndDate = _pEndDate, 
			coFiscalYearId = _coFiscalYearId, 
			fyear = _fyear, 
			yStartDate = _yStartDate, 
			yEndDate = _yEndDate,
            transactionDate=_pStartDate
			where glTransactionID = _glTransactionId;
			
			select count(*) into _recordFound from glLinkage 
            where coLedgerSourceId = 6220 and glTransactionId=_glTransactionId;
			
            if (_recordFound>0) THEN
            
				select veBillID into _veBillID from glLinkage 
                where coLedgerSourceId = 6220 and glTransactionId=_glTransactionId limit 1;
			
				update veBill set UsePostDate=1, ReceiveDate = BillDate where veBillID=_veBillID;
            
            END IF;

			set _recordFound=0;

		END LOOP readRecords;
		
	CLOSE _targetGl;


		select 'AFTER', t.*,v.veBillID, v.UsePostDate, v.BillDate, v.ReceiveDate from glTransaction t
			left join glLinkage l on (l.glTransactionId = t.glTransactionId and coLedgerSourceId=6220)
            left join veBill v on (v.veBillID = l.veBillID )
			where t.period = _newPeriod and t.journalId=_journalId and Date(t.entrydate) = _entrydate;

    END IF;


END IF;

END$$
DELIMITER ;
