
-- call INVOICE_recalculate('CUSTOMERINVOICE',290560,0,1);
-- call GL_updateGLTransaction('INSERT',null,'TR',100,1,2,'transDesc','ref',null,null,5,null,null);
-- call GL_print('INVOICED BEFORE EDIT 100 glTransaction','\'BT\',\'CP\'',enteredBy,403,limit);	


-- adding lineItemCount of veBillDetail based on veBilllID

DROP procedure IF EXISTS `upgradeTPDatabaseForAvgCost`;

DELIMITER $$
CREATE PROCEDURE `upgradeTPDatabaseForAvgCost` (IN _schema  varchar(255))
upgradeTPDatabaseForAvgCost: BEGIN
DECLARE colName varchar(25) default null;

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'veBill' AND column_name = 'lineItemCount' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
    -- ALTER TABLE `veBill` ADD COLUMN `lineItemCount` INT NULL DEFAULT NULL AFTER `assignCuinvoiceId`;
     ALTER TABLE  veBill  ADD  lineItemCount INT;
     
    select 'SUCCESS TABLE UPGRADE FOR AVERAGE COST !!';
 
    END IF;

END$$

DELIMITER ;

DROP procedure IF EXISTS `upgradeTPDatabaseForAvgCost`;


-- ==============================================  

-- call GL_print(_description,null,'mdunn',veBillID,limit);
-- call GL_print('INVOICED BEFORE EDIT 100 glTransaction','\'BT\',\'CP\'',enteredBy,403,limit);	

DROP procedure IF EXISTS `GL_print`;

DELIMITER $$
CREATE PROCEDURE `GL_print` (
	_description varchar(100),
	_journalIDs varchar(100),
	_enteredBy varchar(100),
	_veBillID varchar(100),
	_limit int
)
GL_print: BEGIN

DECLARE _DEBUG tinyint default 0;

	if (_limit is null) THEN set _limit =12; END IF;

/*
	if (_journalIDs is not null and _enteredBy is null) THEN

		select _description,
		g.glTransactionId,g.journalId,g.coAccountNumber, a.Description,g.debit, g.credit,g.transactionDate,l.status, l.veBillID, l.vePODetailID, l.veReceiveDetailID
		,g.reference, g.transactionDesc,g.coAccountId, g.enteredBy,l.glLinkageId
		from
		glTransaction g
		left join glLinkage l on (g.glTransactionId = l.glTransactionId)
		left join coAccount a on (a.coAccountID = g.coAccountID)
		-- where g.enteredBy is null;
		where g.journalId in (_journalIDs) and g.enteredBy is null;

	elseif (_enteredBy is null) THEN
		select _description,
		g.glTransactionId,g.journalId,g.coAccountNumber, a.Description,g.debit, g.credit,g.transactionDate,l.status, l.veBillID, l.vePODetailID, l.veReceiveDetailID
		,g.reference, g.transactionDesc,g.coAccountId, g.enteredBy,l.glLinkageId
		from
		glTransaction g
		left join glLinkage l on (g.glTransactionId = l.glTransactionId)
		left join coAccount a on (a.coAccountID = g.coAccountID)
		where g.enteredBy is null;
	else
		select 'GL_print not setup for this query';
	end if;
*/

			set  @l_sql = CONCAT('select \'',_description);		
			set @l_sql = CONCAT(@l_sql,'\',g.glTransactionId,g.journalId,g.coAccountNumber, a.Description,g.debit, g.credit,g.transactionDate,l.status, l.veBillID, l.vePODetailID, l.veReceiveDetailID
				,g.reference, g.transactionDesc,g.coAccountId, g.enteredBy,l.glLinkageId');
				set @l_sql = CONCAT(@l_sql,' from
		glTransaction g
		left join glLinkage l on (g.glTransactionId = l.glTransactionId)
		left join coAccount a on (a.coAccountID = g.coAccountID)');

			set @l_sql = CONCAT(@l_sql,' where ');

			if (_enteredBy is not null) THEN
				set @l_sql = CONCAT(@l_sql,'g.journalId in (',_enteredBy,') ');
			else 
				set @l_sql = CONCAT(@l_sql,'g.enteredBy is null ');
			END IF;

			if (_journalIDs is not null) THEN
				set @l_sql = CONCAT(@l_sql,' and g.journalId in (',_journalIDs,') ');
			END IF;
			
			if (_veBillID is not null) THEN
				set @l_sql = CONCAT(@l_sql,' and l.veBillID =',_veBillID);
			END IF;


			set @l_sql = CONCAT(@l_sql,' order by glTransactionId desc limit ', _limit,';');

		   
			IF (_DEBUG=1) THEN select @l_SQL; END IF;
				
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;

			set @l_sql =null;
END$$

DELIMITER ;


-- ==============================================================================================


-- ============================================================
-- call INVOICE_recalculate('CUSTOMERINVOICE',290560,0,1);
-- call INVOICE_recalculate('VENDORINVOICE',288,0,1,null,null,null,null,null,null);


DROP procedure IF EXISTS `INVOICE_recalculate`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_recalculate`(
IN _action varchar(30), 
IN _cuInvoiceID INT,
IN _ignoreGL INT,
IN _changedByID INT,
IN _transType varchar(50),
IN _lastSubTotal decimal(19,4),
In _lastFreight decimal(19,4),
IN _lastTaxAmount decimal(19,4),
IN _LastcoTaxTerritoryID decimal(19,4),
IN _LastinvoiceDate varchar(20)
)
INVOICE_recalculate: BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.5'; -- Handling lineItemCounts

DECLARE _DEBUG tinyint default 0;

DECLARE _prFromWarehouseID INT;
DECLARE _coTaxTerritoryID INT;
DECLARE _joReleaseDetailID INT;
DECLARE _InvoiceAmount decimal(19,4) default 0;
DECLARE _TaxAmount decimal(19,4) default 0;
DECLARE _CostTotal decimal(19,4) default 0;
DECLARE _Freight decimal(19,4) default 0;
DECLARE _FreightTax decimal(19,4) default 0;
DECLARE _Subtotal decimal(19,4) default 0;
DECLARE _TaxTotal decimal(19,4) default 0;
DECLARE _TaxRate decimal(19,6) default 0;
DECLARE _TaxableSales decimal(19,4) default 0;

DECLARE _NonTaxableSales decimal(19,4) default 0;
DECLARE _taxfreightFlag INT;
DECLARE _InvoiceNumber varchar(255);
DECLARE _lastCostTotal decimal(19,4);
DECLARE _lastTaxableSales decimal(19,4);
DECLARE _lastNonTaxableSales decimal(19,4);
DECLARE _lastInvoiceAmount decimal(19,4);
DECLARE _lastTaxRate decimal(19,4);
DECLARE _InvoiceDate DATE;
DECLARE _isInvoiceDatechanged INT default 0;
DECLARE _SingleTaxAmount DECIMAL(19,4) DEFAULT 0;

DECLARE _ids    text;
DECLARE _id    INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _totalcost decimal(19,4);
DECLARE _count INT;
DECLARE _prMasterID INT;
DECLARE _QuantityBilled decimal(19,4);
DECLARE _freightDistributionAll decimal(19,4);
DECLARE _freightDistribution decimal(19,4);
DECLARE _averageCost decimal(19,4);
DECLARE _PONumber varchar(20);
DECLARE _tpInventoryLogID INT;
DECLARE _newOnHand decimal(19,4);
DECLARE _oldonHand decimal(19,4);
-- DECLARE _newAverageCost decimal(19,4);
-- DECLARE _avgCost decimal(19,4);
-- DECLARE _OldPrice decimal(19,4);
-- DECLARE _oldAvgCost decimal(19,4);
DECLARE _oldTotalValue decimal(19,4);
-- DECLARE _newTotalValue decimal(19,4);
-- DECLARE _avgCostDifference decimal(19,4);
DECLARE _isInventory INT;
DECLARE _lineItemCount INT DEFAULT 0;
    
SET SESSION group_concat_max_len = 1000000; 
    
	if (_action='CUSTOMERINVOICE') THEN
	
        select CostTotal,TaxableSales,NonTaxableSales,InvoiceAmount,TaxRate,InvoiceDate,Subtotal,TaxAmount
        into 
        _lastCostTotal,_lastTaxableSales,_lastNonTaxableSales,_lastInvoiceAmount,_lastTaxRate,_InvoiceDate,_lastSubTotal,_lastTaxAmount
        from cuInvoice where cuInvoiceID=_cuInvoiceID;
        
        set _LastinvoiceDate=_InvoiceDate; -- OVERRIDE the date, caution!!
        
		SET _SingleTaxAmount=calculateSingleTaxAmount(_cuInvoiceID);

		select i.prFromWarehouseID,i.coTaxTerritoryID,(t.TaxRate*.01),i.joReleaseDetailID,t.taxfreight,i.Freight,i.InvoiceNumber 
		  into  _prFromWarehouseID,_coTaxTerritoryID,_TaxRate,_joReleaseDetailID,_taxfreightFlag,_Freight,_InvoiceNumber
		from cuInvoice i
		left join coTaxTerritory t on (t.coTaxTerritoryID= i.coTaxTerritoryID)
		where cuInvoiceID=_cuInvoiceID;
	
		select IFNULL(Sum(whseCost*QuantityBilled),0) into _CostTotal from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
		select IFNULL(Sum(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier)),0) into _TaxableSales  from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID and Taxable=1;  
		select IFNULL(Sum(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier)),0) into _NonTaxableSales  from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID and Taxable=0;
		set _Subtotal = ROUND_TO_EVEN((ifnull(_TaxableSales,0)+ ifnull(_NonTaxableSales,0)),2);          
		
		if(_taxfreightFlag=1) THEN 			 
			set _TaxableSales = ifnull(_TaxableSales,0) + ifnull(_Freight,0);
		else 			
			set _NonTaxableSales = ifnull(_NonTaxableSales,0) + ifnull(_Freight,0);
		END IF;
		set _TaxAmount = ROUND_TO_EVEN(((ifnull(_TaxableSales,0) *  _TaxRate)),2);
        
        if(_TaxRate = 0) then
         set _NonTaxableSales = _NonTaxableSales+_TaxableSales;
         set _TaxableSales = 0;
         end if;
        
		
        set _TaxTotal = ifnull(_TaxAmount,0);
		set _InvoiceAmount = ifnull(_Subtotal,0) + ifnull(_TaxTotal,0) + ifnull(_Freight,0) + IFNULL(_SingleTaxAmount,0);
		
		update cuInvoice set
		CostTotal = _CostTotal, 
		whseCostTotal = _CostTotal, 
		TaxableSales=_TaxableSales, 
		NonTaxableSales=_NonTaxableSales, 
		Subtotal=_Subtotal,
		TaxAmount=_TaxAmount,
		TaxTotal=_TaxTotal,
		InvoiceAmount=_InvoiceAmount,
		-- ChangedByID = _changedByID,
		TaxRate = (_TaxRate*100),
		-- ChangedOn = now(),
	    SingleItemTaxAmount=IF(_SingleTaxAmount=0,NULL,_SingleTaxAmount)
		where cuInvoiceID = _cuInvoiceID;
		
		
		if (_joReleaseDetailID>0) THEN
			update joReleaseDetail set CustomerInvoiceAmount=_InvoiceAmount  where joReleaseDetailID =_joReleaseDetailID;
		END IF;
        if(_LastinvoiceDate<>DATE_FORMAT(_InvoiceDate,"%Y-%m-%d")) then
			set _isInvoiceDatechanged = 1;
		end if;
        if(_transType is not null) then 
			if(_transType='CI-Created') then
				call INVOICE_tpCuInvoiceLogMaster(_transType,_cuInvoiceID,0,0,0,0,0,0,0,0,_isInvoiceDatechanged);
            
            elseif(_transType='CI-Line Item(s) Deleted') then
				call INVOICE_tpCuInvoiceLogMaster_rollback("CI-ROLLBACK",_cuInvoiceID,0,_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_lastCostTotal,_lastTaxableSales,_lastNonTaxableSales,_lastInvoiceAmount,_lastTaxRate);
				call INVOICE_tpCuInvoiceLogMaster(_transType,_cuInvoiceID,0,_lastInvoiceAmount,_lastSubTotal,_lastFreight,_lastTaxAmount,_lastCostTotal,_lastTaxRate,_LastcoTaxTerritoryID,_isInvoiceDatechanged);
            elseif(_transType='CI-Edited') then
				if(_lastSubTotal <> _Subtotal OR _lastFreight <> _Freight  or _LastinvoiceDate<>DATE_FORMAT(_InvoiceDate,"%Y-%m-%d")) then
					call INVOICE_tpCuInvoiceLogMaster_rollback("CI-ROLLBACK",_cuInvoiceID,0,_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_lastCostTotal,_lastTaxableSales,_lastNonTaxableSales,_lastInvoiceAmount,_lastTaxRate);
					call INVOICE_tpCuInvoiceLogMaster(_transType,_cuInvoiceID,0,_lastInvoiceAmount,_lastSubTotal,_lastFreight,_lastTaxAmount,_lastCostTotal,_lastTaxRate,_LastcoTaxTerritoryID,_isInvoiceDatechanged);
				elseif(_lastTaxAmount <> _TaxAmount OR _LastcoTaxTerritoryID<>_coTaxTerritoryID) then
					call INVOICE_tpCuInvoiceLogMaster_rollback("CI-ROLLBACK-Tax Adjustments",_cuInvoiceID,0,_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_lastCostTotal,_lastTaxableSales,_lastNonTaxableSales,_lastInvoiceAmount,_lastTaxRate);
					call INVOICE_tpCuInvoiceLogMaster("CI-Edited-Tax Adjustments",_cuInvoiceID,0,_lastInvoiceAmount,_lastSubTotal,_lastFreight,_lastTaxAmount,_lastCostTotal,_lastTaxRate,_LastcoTaxTerritoryID,_isInvoiceDatechanged);
				end if;
            end if;
        END if ;
		IF (_lastSubTotal=_Subtotal AND _lastFreight=_Freight AND _lastTaxAmount=_TaxAmount AND _LastinvoiceDate=DATE_FORMAT(_InvoiceDate,"%Y-%m-%d"))THEN
			
            SET _ignoreGL=1;
            if (_DEBUG=1) THEN
				select 'INVOICE_recalculate GL IGNORED',_action,_lastSubTotal,_lastFreight,lastTaxAmount,_LastinvoiceDate,_LastinvoiceDate;
            END IF;
		
        END IF ; 
		
		if (_ignoreGL=0) THEN 
			
			call GL_updateGLTransaction('INSERT',null,'CI',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,_isInvoiceDatechanged,_LastinvoiceDate); 
		
		END IF;
        

        
	ELSEif (_action='VENDORINVOICE') THEN
 
		-- 1. Itterate through all the veBillDetails
        select GROUP_CONCAT(veBillDetailID) into _ids from  veBillDetail  where veBillID = _cuInvoiceID;
        -- select _ids;
        if (_ids is null) THEN
			leave INVOICE_recalculate;
        end if;
                
        set _totalcost = 0;
		set _Subtotal =0;
        set _lineItemCount =0;
        do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);
                
                select ROUND_TO_EVEN(IFNULL(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier),0),2) into _totalcost from veBillDetail where veBillDetailID = _id;
				set _Subtotal = _Subtotal+_totalcost;
                
                set _lineItemCount = _lineItemCount +1;
                
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 

        select FreightAmount,joReleaseDetailID into _Freight,_joReleaseDetailID  from veBill where veBillID =  _cuInvoiceID;

        set _InvoiceAmount = _Subtotal + _Freight;

        update veBill set BillAmount = _InvoiceAmount, lineItemCount =_lineItemCount  where veBillID =  _cuInvoiceID;

		if (_DEBUG=1) THEN
			select 'INVOICE_recalculate  update veBill set BillAmount = _InvoiceAmount, lineItemCount =_lineItemCount ',_InvoiceAmount,_Subtotal,_Freight,_lineItemCount;
		END IF;
        
		-- comment out because we don't know why it is done first.
         -- if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VB',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;
		
         if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 
			
			select GROUP_CONCAT(veBillDetailID) into _ids from  veBillDetail  where veBillID = _cuInvoiceID;
            do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);

			select d.prMasterID, p.IsInventory 
            into _prMasterID, _isInventory 
            from veBillDetail d
            left join prMaster p on (p.prMasterID = d.prMasterID)
            where veBillDetailID = _id;

			if (_isInventory=1) THEN
            
                -- check to see if any lineItemCounts are not calculated
                select count(*) 
                into _count
                from veBillDetail d 
                left join veBill v on (v.veBillID = d.veBillID)
                where d.prMasterID = _prMasterID and v.lineItemCount is null;
                
                if (_count >0) then
					-- need to fix all the effected veBills.
                    -- good place to call our fixTool.. passing the prMasterID
                    -- needs to fix lastAvgCost and lineItemCount and new avgCost.
                    call FIX_tool('AVERAGECOST_PRODUCT',_prMasterID,null,'COMMIT',null); -- 'REVIEW_FIRST or COMMIT'

					if (_DEBUG=1) THEN
						select 'INVOICE_recalculate FIX_tool(AVERAGECOST_PRODUCT) ',_action,_prMasterID,_count;
					END IF;

                END if;
                
				call INVOICE_recalculate_avgCost(null,_prMasterID,1,null);

            END IF; -- isInventory


                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 

			-- uncomment out and comment out call before.. not sure why it was done before.
			if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VB',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;


		ELSE

            if (_DEBUG=1) THEN
				select 'INVOICE_recalculate _joReleaseDetailID INSIDEJOB',_action,_prMasterID;
            END IF;
        
			if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VB',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;
       
		end if;


        
    ELSEif (_action='VENDORINVOICEWITHOUTPO') THEN
    
 
		select GROUP_CONCAT(veBillDistributionID) into _ids from  veBillDistribution  where veBillID = _cuInvoiceID;
        set _totalcost = 0;
		set _Subtotal =0;
        do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);
                select ExpenseAmount into _totalcost from veBillDistribution where veBillDistributionID = _id;
				set _Subtotal = _Subtotal+_totalcost;
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
         
        
        
        set _InvoiceAmount = _Subtotal ;
  
        update veBill 
        set 
        BillAmount = _InvoiceAmount  
        where veBillID =  _cuInvoiceID;

        if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VBD',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;
	
    
    END IF;
END$$

DELIMITER ;
-- ======================================================================




-- ============================================================
-- call INVOICE_recalculate_avgCost(null,1005,0,1);

DROP procedure IF EXISTS `INVOICE_recalculate_avgCost`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_recalculate_avgCost`(
IN _action varchar(30), 
IN _prMasterID INT,
IN _applyPercentChangeRule tinyint,
IN _DEBUG tinyint
)
INVOICE_recalculate: BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.0'; --

DECLARE _ids    text;
DECLARE _id    INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;

DECLARE _newAverageCost decimal(19,4);
DECLARE _avgCost decimal(19,4);
DECLARE _OldPrice decimal(19,4);
DECLARE _oldAvgCost decimal(19,4);
DECLARE _avgCostDifference decimal(19,4);

-- call INVOICE_recalculate_avgCost(null,1005,0,1);
    	
				set _avgCost = 0;

			-- if (_isInventory=1) THEN
              
                -- change this to a function or procedure
				SELECT 
				SUM(((d.PriceMultiplier * d.UnitCost* QuantityBilled) + 
				(case when m.IsInventory=1 THEN
				IFNULL(v.FreightAmount, 0)/ifnull(v.lineItemCount,1)
				ELSE 0 END )
				)) / sum(d.QuantityBilled)
				into _avgCost 
				FROM veBillDetail d 
				LEFT JOIN veBill v ON (v.veBillID = d.veBillID)
				left join prMaster m on (m.prMasterID = d.prMasterID)
				WHERE
				d.prMasterID = _prMasterID AND v.BillDate > 
				(SELECT date_format(MAKEDATE(year(DATE_SUB(NOW(),INTERVAL 1 YEAR)),1),"%y-%m-%d 00:00:00")) GROUP BY m.prMasterID;

				select OldPrice into _oldPrice from prMaster where prMasterID = _prMasterID;

				if (_oldPrice is null) THEN
					select AverageCost into _oldPrice from prMaster where prMasterID=_prMasterID;
					-- select LastCost into _oldPrice from prMaster where prMasterID=_prMasterID;
					-- select v.UnitCost into _oldPrice from veBillDetail v where prMasterID=_prMasterID order by veBillDetailID desc limit 1;                
					if (_oldPrice is null) THEN set _oldPrice=0; END IF;
					update prMaster set OldPrice =_oldPrice where prMasterID = _prMasterID;
               END IF;

				if (_DEBUG=1) THEN
                
					select 'INVOICE_recalculate ISINVENTORY',_action,_prMasterID,m.isInventory, m.AverageCost , m.oldAverageCost, 
                    abs(m.oldAverageCost-m.AverageCost) as avgCostDiffernce,
                    (abs(m.oldAverageCost-m.AverageCost)/m.AverageCost) * 100 as percentDifference,
					SUM(((d.PriceMultiplier * d.UnitCost* QuantityBilled) + 
					(case when m.IsInventory=1 THEN
					IFNULL(v.FreightAmount, 0)/ifnull(v.lineItemCount,1)
					ELSE 0 END )
					)) / sum(d.QuantityBilled) as newAverageCost_no12PercentRuleApplied,
                    m.OldPrice as afterLastAdjustment
					FROM veBillDetail d 
					LEFT JOIN veBill v ON (v.veBillID = d.veBillID)
					left join prMaster m on (m.prMasterID = d.prMasterID)
					WHERE
					d.prMasterID = _prMasterID AND v.BillDate > 
					(SELECT date_format(MAKEDATE(year(DATE_SUB(NOW(),INTERVAL 1 YEAR)),1),"%y-%m-%d 00:00:00")) GROUP BY m.prMasterID;
				
 					select 'INVOICE_recalculate ISINVENTORY DETAIL',
                    d.veBillDetailID,m.IsInventory,d.PriceMultiplier,d.UnitCost,QuantityBilled,v.FreightAmount,v.lineItemCount,
                    (d.PriceMultiplier * d.UnitCost* QuantityBilled)+(v.FreightAmount/v.lineItemCount),
                    ((d.PriceMultiplier * d.UnitCost* QuantityBilled)+(v.FreightAmount/v.lineItemCount))/d.QuantityBilled
					FROM veBillDetail d 
					LEFT JOIN veBill v ON (v.veBillID = d.veBillID)
					left join prMaster m on (m.prMasterID = d.prMasterID)
					WHERE
					d.prMasterID = _prMasterID AND v.BillDate > 
					(SELECT date_format(MAKEDATE(year(DATE_SUB(NOW(),INTERVAL 1 YEAR)),1),"%y-%m-%d 00:00:00")) GROUP BY m.prMasterID;
               
                END IF;

				-- we will need oldAverageCost for GL calculations, so we should make sure
				-- it is populated and use a new field to help with this calculation below.

				-- oldAverageCost 12%%
				-- select oldAverageCost into _oldAvgCost from prMaster where prMasterID = _prMasterID;
                
                
				-- smoothing test
				-- if (_avgCost=_oldAvgCost or _oldAvgCost=0) THEN 
				if (_avgCost=_oldPrice or _oldPrice=0) THEN 
					-- set _oldAvgCost = 0;  -- 0 means we are caught up.
					set _oldPrice = 0;  -- 0 means we are caught up.
				ELSE
					-- update_avgCost by a % change
					
                    if (_applyPercentChangeRule=1) THEN
                    
						-- set _avgCostDifference = (_avgCost-_oldAvgCost) / (_oldAvgCost);
						set _avgCostDifference = (_avgCost-_oldPrice) / (_oldPrice);
						if ( abs(_avgCostDifference) > 0.08) THEN
							
							if (_avgCostDifference)  >0 THEN
								set _avgCost =  _oldPrice + (_oldPrice * .08);
							ELSE
								set _avgCost = _oldPrice - (_oldPrice * .08);
							END IF;
							set _oldPrice = _avgCost; -- set this for the next starting point.

						ELSE
							set _oldPrice = 0;
						END IF;
					
                    END IF; -- applyRUle
                    
				END IF; -- if (_avgCost=_oldPrice or _oldPrice=0)
            
            -- END IF; -- isInventory
            
            if (_DEBUG=1) THEN
				select _action,_prMasterID,_avgCost, _oldPrice, '_oldPrice=0 means no 8% governor';
            END IF;
            
			-- update prMaster set averageCost =_avgCost, oldAverageCost=_oldAvgCost where prMasterID = _prMasterID;
			update prMaster set oldAverageCost = averageCost, averageCost =_avgCost, OldPrice =_oldPrice
            where prMasterID = _prMasterID;

		-- end IF;

END$$

DELIMITER ;
-- ======================================================================


-- ==============================================
-- TODO - fix invoice negatives.  need to understand how it works.

-- call GL_updateGLTransaction('INSERT',null,'TR',100,1,2,'transDesc','ref',null,null,5,null,null);
-- call GL_updateGLTransaction('INSERT',null,'VB',100,null,null,null,null,null,190045,5,null,null);
-- call GL_updateGLTransaction('INSERT',null,'CI',100,null,null,null,null,null,291955,5,null,null);

DROP procedure IF EXISTS `GL_updateGLTransaction`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `GL_updateGLTransaction`(
	IN _action varchar(25),
	IN _coFiscalPeriodId INT,    
    IN _journalId varchar(10),
    IN _amount  decimal(19,4),
    IN _prFromWarehouse INT,
    IN _prToWarehouse INT,
    IN _transDesc varchar(255),
    IN _reference varchar(255),
    IN _veReceiveDetailBinID INT,
    IN _itemDetailID INT,
    IN _changedByID INT,
	IN _isInvoiceDatechanged INT,
	IN _LastinvoiceDate date	    
)
GL_updateGLTransaction : BEGIN

DECLARE _VERSION varchar(20) DEFAULT '1.2'; -- added condition for _PriceMultiplier

DECLARE _DEBUG TINYINT DEFAULT 0;

DECLARE _debit_coAccountId  int;
DECLARE _debit_coAccountNumber varchar(255);
DECLARE _debit_transDesc varchar(255);
DECLARE _debit_reference varchar(255);
DECLARE _credit_coAccountId  int;
DECLARE _credit_coAccountNumber varchar(255);
DECLARE _credit_transDesc varchar(255);
DECLARE _credit_reference varchar(255);
DECLARE _coLedgerSourceID INT;
DECLARE _coFiscalYearId INT;
DECLARE _glTransactionId INT;
DECLARE _period INT;
DECLARE _fyear varchar(25);
DECLARE _pStartDate DATETIME;
DECLARE _pEndDate DATETIME;
DECLARE _yStartDate DATETIME;
DECLARE _yEndDate DATETIME;
DECLARE _journalDesc varchar(50);
DECLARE _message varchar(255);
DECLARE _changedByName varchar(255);
DECLARE _veBillID INT;
DECLARE _veBillDetailID INT;
DECLARE _cuInvoiceDetailID INT;
DECLARE _debit decimal(19,4);
DECLARE _credit decimal(19,4);
DECLARE _veReverse INT;
DECLARE _InvoiceAmount  decimal(19,4);
DECLARE _Subtotal  decimal(19,4);
DECLARE _itemCost  decimal(19,4);
DECLARE _TaxTotal  decimal(19,4);
DECLARE _Freight  decimal(19,4);
DECLARE _PriceMultiplier decimal(19,4);
DECLARE _joReleaseDetailID INT;
DECLARE _prDepartmentID INT;
DECLARE _coDivisionID INT;
DECLARE _coDivisionSubAccount varchar(10);
DECLARE _PONumber varchar(20);
DECLARE _coAccountIDAccrual INT;
DECLARE _coAccountIDCurEarnings INT; -- new
DECLARE _coAccountIDShipInventory INT;
DECLARE _coAccountIDShipping INT;
DECLARE _coAccountIDSalesTaxInv INT;
DECLARE _coAccountIDAR INT;
DECLARE _coAccountIDShipInventoryNumber varchar(50);
DECLARE _coAccountIDShippingNumber varchar(50);
DECLARE _coAccountIDARNumber varchar(50);
DECLARE _coAccountIDSalesTaxInvNumber varchar(50);
DECLARE _coAccountIDInvTotal_debit  decimal(19,4); -- handle inv and cogs
DECLARE _coAccountIDInvTotal_credit  decimal(19,4);
DECLARE _vePODetailID INT DEFAULT null;
DECLARE _veReceiveDetailID INT DEFAULT null;
DECLARE _vePOID INT;
DECLARE _releaseType INT;

DECLARE _accuralAmount decimal(19,4);

DECLARE _coAccountIDFreight INT;
DECLARE _coAccountIDSalesTaxPaid INT;
DECLARE _coAccountIDAP INT;
DECLARE _coAccountIDInventory INT;
DECLARE _coAccountIDCogs INT;
DECLARE _coAccountIDInventoryNumber varchar(50);
DECLARE _coAccountIDCogsNumber varchar(50);

DECLARE _addedtill decimal(19,4);
DECLARE _totaltill decimal(19,4);

DECLARE _glTransactions longtext;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _furtherUpdatesNeeded INT DEFAULT 1;
DECLARE _isInventory INT Default 0;
DECLARE _transactionDate DATE;
DECLARE _permissiontoPreviousPeriod INT;
DECLARE _isAdmin INT;
DECLARE _isPeriodOpenStatus INT;
DECLARE _createdOn date;
DECLARE _UsePostDate INT;
DECLARE _fromWarehouse varchar(50);
DECLARE _toWarehouse varchar(50);

DECLARE _AverageCost_Old decimal(19,4);
DECLARE _AverageCost_New decimal(19,4);
DECLARE _qty int;
DECLARE _inventory  decimal(19,4);
DECLARE _apAcccrual  decimal(19,4);
DECLARE _onHand INT;

DECLARE _debitTotal decimal(19,4);
DECLARE _creditTotal decimal(19,4);


SET SESSION group_concat_max_len = 1000000; 
if (_amount is null) THEN set _amount=0; END IF;
if(_journalId<>'CI' AND _journalId<>'VB' AND _journalId<>"VBD") THEN
 if (_amount=0) THEN LEAVE GL_updateGLTransaction; END IF;
END IF;

select UsePostDate into _UsePostDate from veBill where veBillID = _itemDetailID;

IF (_journalId='CI') THEN
	SELECT CreatedOn INTO _createdOn  FROM cuInvoice WHERE cuInvoiceID=_itemDetailID ;
	if(_isInvoiceDatechanged=1) then
  
    SELECT InvoiceDate INTO _transactionDate  FROM cuInvoice WHERE cuInvoiceID=_itemDetailID ;
    elseif(date(_createdOn) = date(now())) then
	SET _transactionDate=NOW();
	 ELSE
		 SET _transactionDate=NOW();
	 END IF;
ELSEIF((_journalId='VB'or _journalId="VBD") and _UsePostDate=1) then
		SELECT PostDate INTO _transactionDate  FROM veBill WHERE veBillID=_itemDetailID ;
ELSE
	SET _transactionDate=NOW();
END IF;

select ifnull(FullName,_changedByID) into _changedByName from tsUserLogin where UserLoginID = _changedByID;

if (_coFiscalPeriodId is null) THEN
	select p.coFiscalPeriodID, p.coFiscalYearID, p.period, p.StartDate as pStartDate,p.EndDate as pEndDate,y.StartDate as yStartDate,y.EndDate as yEndDate,y.fiscalYear
	into
	_coFiscalPeriodId,_coFiscalYearId,_period,_pStartDate,_pEndDate,_yStartDate,_yEndDate,_fyear
	from coFiscalPeriod p
	left join coFiscalYear `y` on (y.coFiscalYearID = p.coFiscalYearID)
	where Date(_transactionDate) >= Date(p.StartDate) and Date(_transactionDate) <= Date(p.EndDate) and p.openStatus=1
    order by p.StartDate Desc limit 1;	
ELSE 
	select p.coFiscalPeriodID, p.coFiscalYearID, p.period, p.StartDate as pStartDate,p.EndDate as pEndDate,y.StartDate as yStartDate,y.EndDate as yEndDate,y.fiscalYear
	into
	_coFiscalPeriodId,_coFiscalYearId,_period,_pStartDate,_pEndDate,_yStartDate,_yEndDate,_fyear
	from coFiscalPeriod p
	left join coFiscalYear `y` on (y.coFiscalYearID = p.coFiscalYearID)
	where coFiscalPeriodId=_coFiscalPeriodId and p.openStatus=1;
END IF;

if (_period is NULL) THEN
		set _message = concat('GL_updateGLTransaction: coFiscalPeriodID not open or needs creation');
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = _message;
		LEAVE GL_updateGLTransaction; 
END IF;

CASE 
WHEN _journalId='IA' THEN 

	set _journalDesc='Inventory Adjustment';

    if ( _amount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_amount);
    ELSEif ( _amount <0 ) THEN
    	set _debit = ABS(_amount);
    	set _credit = 0;
 	ElSE
 		-- nothing to do since the value is zero
		LEAVE GL_updateGLTransaction; 
 	END IF;
    
	select w.coAccountIDAsset, w.adjustCogAccountID, ac.Number, ad.Number into _credit_coAccountId,_debit_coAccountId, _debit_coAccountNumber,_credit_coAccountNumber 
    from prWarehouse w
    left join coAccount ad on (ad.coAccountID = w.coAccountIDAsset)
    left join coAccount ac on (ac.coAccountID = w.adjustCogAccountID)    
    where prWarehouseID = _prFromWarehouse;
	
	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(concat('ADJ:',_transDesc),'ADJ:');
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(concat('ADJ:',_transDesc),'ADJ:');
    
    set _veBillID = _reference;

-- ==========================================================================    
WHEN _journalId='VB' THEN 

	set _journalDesc='Vendor Bills';
    set _veBillID = _itemDetailID;

    select c.InvoiceNumber, r.`Name`, ve.prWarehouseID as prFromWarehouseID, c.BillAmount, c.TaxAmount, c.FreightAmount, c.joReleaseDetailID,ve.PONumber    
    into _reference,_transDesc,_prFromWarehouse,_InvoiceAmount, _TaxTotal, _Freight , _joReleaseDetailID,_PONumber
    from veBill c
    left join rxMaster r on (r.rxMasterID = c.rxMasterID)
	left join joReleaseDetail jord on (jord.joReleaseDetailID = c.joReleaseDetailID)
	left join joMaster jom on (jom.joMasterID = jord.joMasterID)
	left join coDivision cDiv on (cDiv.coDivisionID = jom.coDivisionID)
    left join vePO ve on (ve.vePOID = c.vePOID)
    where c.veBillID = _veBillID;

	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(_transDesc,null);
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(_transDesc,null);

    
	-- will perform a reversal if not already done.
	CALL GL_reverseGLTransaction(NULL,_reference,_changedByID,_veBillID,_journalId,null,null);
	
	select coLedgerSourceID into _coLedgerSourceID from coLedgerSource where JournalID=_journalId;

-- quick insert
-- A 2000-00-000	ACCOUNTS PAYABLE	VB	1221-1	$0.00	$600.00      (_InvoiceAmount)
-- B 14410-00 VB debit (Freight) sysAccountLinkage.coAccountIDFreight (_Freight)
-- C 02360-00 VB debit (Sales Tax Payable) sysAccountLinkage.coAccountIDSalesTaxPaid  (_TaxTotal)

-- itterate over items
-- D 1350-00-000	INVENTORY	VB	1221-1	$1,953.25	$0.00  (OnHand * (New AvgCost - OldAvgCost))
-- E 2001-00-000	ACCOUNTS PAYABLE ACCRUAL (coAccountIDAccrual)	VB	1221-1	$470.00	$0.00  (qty * oldAvgCost)

-- final calculation
-- F 3110-01-000	COST VARIANCE - DAL (coAccountIDCurEarnings)	VB	1221-1	$0.00	$1,823.25  (B+C+D+E+F-A)

	select coAccountIDFreight,coAccountIDSalesTaxPaid, coAccountIDAP , coAccountIDAccrual, coAccountIDCurEarnings
    into _coAccountIDFreight,_coAccountIDSalesTaxPaid, _coAccountIDAP,_coAccountIDAccrual,_coAccountIDCurEarnings 
    from sysAccountLinkage limit 1;

	if (_DEBUG=1) THEN
	select 'VB',_veBillID,_reference,_transDesc,_prFromWarehouse,_InvoiceAmount, _TaxTotal, _Freight ,
    _joReleaseDetailID,_PONumber,_debit_reference,_credit_reference,_credit_transDesc,
    _coAccountIDFreight,_coAccountIDSalesTaxPaid, _coAccountIDAP,_coAccountIDAccrual,_coAccountIDCurEarnings;
	END IF;

	set _debitTotal = 0;
    set _creditTotal = 0;
    
-- A 2000-00-000	ACCOUNTS PAYABLE	VB	1221-1	$0.00	$600.00      (_InvoiceAmount)

	set _credit = 0;
	set _debit = 0;
	if ( _InvoiceAmount >0 ) THEN
    	set _debit = 0;
    	set _credit = ROUND_TO_EVEN(ABS(_InvoiceAmount),2);
    ELSEif ( _InvoiceAmount <0 ) THEN
    	set _debit = ROUND_TO_EVEN(ABS(_InvoiceAmount),2);
    	set _credit = 0;
 	END IF;

	if (_debit >0 or _credit>0) THEN
        
        set _credit_coAccountId = _coAccountIDAP;
        select  `Number` into _credit_coAccountNumber from coAccount where coAccountID=_coAccountIDAP;
        
		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,_debit,_credit,_credit_reference,_journalId,_journalDesc);
		-- values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_credit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
	
		set _creditTotal = _creditTotal + _credit;
		set _debitTotal = _debitTotal + _debit;
        
		if (_DEBUG=1) THEN select concat('VBA ACCOUNTS PAYABLE (_InvoiceAmount)',' N:',_credit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;
    END IF;

-- B 14410-00 VB debit (Freight) sysAccountLinkage.coAccountIDFreight (_Freight)
    
	set _credit = 0;
	set _debit = 0;
	if ( _Freight >0 ) THEN
    	set _debit = ROUND_TO_EVEN(ABS(_Freight),2);
    	set _credit = 0;
    ELSEif ( _Freight <0 ) THEN
    	set _debit = 0;
    	set _credit = ROUND_TO_EVEN(ABS(_Freight),2);
 	END IF;

	if (_debit >0 or _credit>0) THEN

        
        select  `Number` into _debit_coAccountNumber from coAccount where coAccountID=_coAccountIDFreight;
		set _debit_coAccountId = _coAccountIDFreight;
        
        -- if((_joReleaseDetailID is null or _joReleaseDetailID =0)) then 
        
			 -- select w.coAccountIDAsset, ac.Number into _debit_coAccountId, _debit_coAccountNumber
			 -- from prWarehouse w
			 -- left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
			 -- where prWarehouseID = _prFromWarehouse;
        -- else 
        
			-- select  GL_buildAccountName(a.Number,_coDivisionSubAccount) into _debit_coAccountNumber from coAccount a where coAccountID=_coAccountIDFreight;
			-- set _debit_coAccountId = GL_determineAccountNumber( GL_buildAccountName(_debit_coAccountNumber,_coDivisionSubAccount),_coAccountIDFreight);

        -- end if;

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,_debit,_credit,_debit_reference,_journalId,_journalDesc);
		-- values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

		set _creditTotal = _creditTotal + _credit;
		set _debitTotal = _debitTotal + _debit;
 
 		if (_DEBUG=1) THEN select concat('VBB  debit (Freight) sysAccountLinkage.coAccountIDFreight (_Freight)',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

	END IF;
 

-- C 02360-00 VB debit (Sales Tax Payable) sysAccountLinkage.coAccountIDSalesTaxPaid  (_TaxTotal)

	set _credit = 0;
	set _debit = 0;
   if ( _TaxTotal >0 ) THEN
    	set _debit = ROUND_TO_EVEN(ABS(_TaxTotal),2);
    	set _credit = 0;
    ELSEif ( _TaxTotal <0 ) THEN
    	set _debit = 0;
    	set _credit = ROUND_TO_EVEN(ABS(_TaxTotal),2);
 	END IF;

	if (_debit >0 or _credit>0) THEN

		set _debit_coAccountId = _coAccountIDSalesTaxPaid;
        select  `Number` into _debit_coAccountNumber from coAccount where coAccountID=_coAccountIDSalesTaxPaid;

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,_debit,_credit,_debit_reference,_journalId,_journalDesc);
		-- values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

		set _creditTotal = _creditTotal + _credit;
		set _debitTotal = _debitTotal + _debit;
 
 		if (_DEBUG=1) THEN select concat('VBC debit (Sales Tax Payable) sysAccountLinkage.coAccountIDSalesTaxPaid  (_TaxTotal)',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

	END IF;
 

-- D 1350-00-000	INVENTORY	VB	1221-1	$1,953.25	$0.00  (OnHand * (New AvgCost - OldAvgCost))
-- E 2001-00-000	ACCOUNTS PAYABLE ACCRUAL (coAccountIDAccrual)	VB	1221-1	$470.00	$0.00  (qty * oldAvgCost)


    -- itterate over the details
	select group_concat(veBillDetailID) into _glTransactions from veBillDetail t where veBillID = _veBillID;

		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_glTransactions);
				set _veBillDetailID=SUBSTRING_INDEX(_glTransactions, ',', 1);

				select  
                -- dept.coAccountIDCOGS as coAccountID, 
				-- (select Number from coAccount where coAccountID= dept.coAccountIDCOGS) as AccountName,
                d.QuantityBilled, d.UnitCost,
                p.InventoryOnHand,
                p.oldAverageCost,p.AverageCost, 
                p.IsInventory,d.vePODetailID,bill.vePOID,d.PriceMultiplier
				into 
                -- _debit_coAccountId,_debit_coAccountNumber,
                _qty,_itemCost, _onHand,_AverageCost_Old, _AverageCost_New,
                _isInventory,_vePODetailID,_vePOID, _PriceMultiplier
				from veBillDetail  d
				left join veBill bill on (bill.veBillID = d.veBillID)
				left join prMaster p on (p.prMasterID = d.prMasterID)
				left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
				left join coAccount a on (a.coAccountID = dept.coAccountIDCOGS)
				where d.veBillDetailID=_veBillDetailID; 

	-- prMasterhas these 4 fields, we are only using AverageCost, oldAverageCost
	-- AverageCost, oldAverageCost, AverageCost_Old, AverageCost_New
	-- select AverageCost, oldAverageCost into _AverageCost_Old, _AverageCost_New  from prMaster where prMasterID = 
	-- REMINDER OF AVGCOST UPDATE - set oldAverageCost = averageCost, averageCost =_avgCost, OldPrice =_oldPrice
    
-- D 1350-00-000	INVENTORY	VB	1221-1	$1,953.25	$0.00  (OnHand * (New AvgCost - OldAvgCost))
-- E 2001-00-000	ACCOUNTS PAYABLE ACCRUAL (coAccountIDAccrual)	VB	1221-1	$470.00	$0.00  (qty * oldAvgCost)

-- joRelease = null then hanlde these two, else skip
				if(_PriceMultiplier is null or _PriceMultiplier = 0) then
					set _PriceMultiplier = 1;
				end if;

				if (_AverageCost_Old is null or _AverageCost_Old = 0) THEN set _AverageCost_Old=_AverageCost_New; END IF;
				
				-- if(_isInventory >0) then 

				if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 

					if(_isInventory >0) then 
                    
						set _inventory = _onHand * ( _AverageCost_New - _AverageCost_Old);
                    
						select w.coAccountIDAsset, ac.Number 
                        into _debit_coAccountId, _debit_coAccountNumber
						from prWarehouse w
						left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
						where prWarehouseID = _prFromWarehouse;
					else
                    
						set _inventory = _qty * _itemCost * ifnull(_PriceMultiplier,1);
                        
						select dept.coAccountIDCOGS as coAccountID, 
						(select Number from coAccount where coAccountID= dept.coAccountIDCOGS) as AccountName
						into _debit_coAccountId,_debit_coAccountNumber
						from veBillDetail  d
						left join veBill bill on (bill.veBillID = d.veBillID)
						left join prMaster p on (p.prMasterID = d.prMasterID)
						left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
						left join coAccount a on (a.coAccountID = dept.coAccountIDCOGS)
						where d.veBillDetailID=_veBillDetailID; 
                        
					END IF;
                    
				ELSE
                
						-- automatically treat as non-inventory
 						set _inventory = _qty * _itemCost * ifnull(_PriceMultiplier,1);
                        
						select dept.coAccountIDCOGS as coAccountID, 
						(select Number from coAccount where coAccountID= dept.coAccountIDCOGS) as AccountName
						into _debit_coAccountId,_debit_coAccountNumber
						from veBillDetail  d
						left join veBill bill on (bill.veBillID = d.veBillID)
						left join prMaster p on (p.prMasterID = d.prMasterID)
						left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
						left join coAccount a on (a.coAccountID = dept.coAccountIDCOGS)
						where d.veBillDetailID=_veBillDetailID; 
                        
                END IF;
                
					set _credit = 0;
					set _debit = 0;
					
					if ( _inventory > 0 ) THEN
							set _debit = ROUND_TO_EVEN(ABS(_inventory),2);
							set _credit = 0;
					ELSEif ( _inventory < 0 ) THEN
							set _debit = 0;
							set _credit = ROUND_TO_EVEN(ABS(_inventory),2);
					END IF;
                    
 					if (_debit >0 or _credit>0) THEN
                   
						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,_debit,_credit,_debit_reference,_journalId,_journalDesc);
						-- values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

						set _creditTotal = _creditTotal + _credit;
						set _debitTotal = _debitTotal + _debit;
						
                        if (_DEBUG=1) THEN 
                        
								select'coAccountIDAsset isInv=1', _isInventory,_joReleaseDetailID, w.coAccountIDAsset, ac.Number 
								from prWarehouse w
								left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
								where prWarehouseID = _prFromWarehouse;

								select 'coAccountIDCOGS isInv=0',_isInventory,_joReleaseDetailID,dept.coAccountIDCOGS as coAccountID, 
								(select Number from coAccount where coAccountID= dept.coAccountIDCOGS) as AccountName
								from veBillDetail  d
								left join veBill bill on (bill.veBillID = d.veBillID)
								left join prMaster p on (p.prMasterID = d.prMasterID)
								left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
								left join coAccount a on (a.coAccountID = dept.coAccountIDCOGS)
								where d.veBillDetailID=_veBillDetailID; 						
							select concat('VBD INVENTORY (_onHand * ( _AverageCost_New - _AverageCost_Old)) Detail:',_veBillDetailID,' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit,' isInv:',_isInventory,' oh=',  _onHand ,' nac=',_AverageCost_New, ' oac=', _AverageCost_Old, ' q:',_qty,' cost:',_itemCost); 
                            END IF;
						
                        
                        
					END IF;
 
				if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 
 
 					if(_isInventory >0) then 

						set _apAcccrual = _qty * _AverageCost_Old;
	 
						set _credit = 0;
						set _debit = 0;
						
						if ( _apAcccrual >0 ) THEN
								set _debit = ROUND_TO_EVEN(ABS(_apAcccrual),2);
								set _credit = 0;
						ELSEif ( _apAcccrual <0 ) THEN
								set _debit = 0;
								set _credit = ROUND_TO_EVEN(ABS(_apAcccrual),2);
						END IF;

						if (_debit >0 or _credit>0) THEN

							set _debit_coAccountId = _coAccountIDAccrual;
							select  `Number` into _debit_coAccountNumber from coAccount where coAccountID=_coAccountIDAccrual;

							insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
							values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,_debit,_credit,_debit_reference,_journalId,_journalDesc);
							-- values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

							SELECT LAST_INSERT_ID() INTO _glTransactionId;

							insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
							
							if (_DEBUG=1) THEN select concat('VBE ACCOUNTS PAYABLE ACCRUAL _coAccountIDAccrual (_qty * _AverageCost_Old) Detail:',_veBillDetailID,' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit,'    qty=',  _qty ,' oac=',_AverageCost_Old); END IF;

							set _creditTotal = _creditTotal + _credit;
							set _debitTotal = _debitTotal + _debit;

						END IF;
                   
                   END IF;
                   
				end if; -- _joReleaseDetailID is null
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_glTransactions, ',', 1))+2;
				SET _glTransactions = MID(_glTransactions, SubStrLen, strLen);
				IF (_glTransactions = '' or _glTransactions is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  



-- F 3110-01-000	COST VARIANCE - DAL (coAccountIDCurEarnings)	VB	1221-1	$0.00	$1,823.25  (B+C+D+E+F-A)

	if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 
    
	set _credit = 0;
	set _debit = 0;
	-- set _credit = ABS(_debitTotal-_creditTotal);

					if ( _debitTotal-_creditTotal > 0 ) THEN
							set _debit = 0;
							set _credit = ROUND_TO_EVEN(ABS(_debitTotal-_creditTotal),2);
					ELSE 
							set _debit = ROUND_TO_EVEN(ABS(_debitTotal-_creditTotal),2);
							set _credit = 0;
					END IF;

	if (_debit >0 or _credit>0) THEN

		set _credit_coAccountId = _coAccountIDCurEarnings;
        select  `Number` into _credit_coAccountNumber from coAccount where coAccountID=_coAccountIDCurEarnings;

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,_debit,_credit,_debit_reference,_journalId,_journalDesc);
		-- values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

 		if (_DEBUG=1) THEN select concat('VBF COST VARIANCE (coAccountIDCurEarnings)',' N:',_credit_coAccountNumber,' D:',_debit,' C:',_credit,'    _debitTotal=',  _debitTotal ,' _creditTotal=',_creditTotal,' total=',_debitTotal-_creditTotal); END IF;

	END IF;
    
    END IF; -- joRelease is null
    
    
	set _furtherUpdatesNeeded=0;
    
    if (_DEBUG=1) THEN
    
	select g.glTransactionId,l.veBillID, journalId,journalDesc,l.veBillID,a.coAccountId, g.coAccountNumber, a.Description reference, debit, credit 
	from glTransaction g
	left join glLinkage l on (g.glTransactionId=l.glTransactionId)
	left join coAccount a on (a.coAccountID = g.coAccountID)
	where l.veBillID = _veBillID
	order by glTransactionId ASC; 
    
    END IF;

-- MODIFICATION TO GL TO HANLDE INVENTORY CHANGES -- this is code before modification above was made.
WHEN _journalId='VB-OLD' THEN 

	set _journalDesc='Vendor Bills';
    set _veBillID = _itemDetailID;



    select c.InvoiceNumber, r.`Name`, ve.prWarehouseID as prFromWarehouseID, c.BillAmount, c.TaxAmount, c.FreightAmount, c.joReleaseDetailID,ve.PONumber
    
    into _reference,_transDesc,_prFromWarehouse,_InvoiceAmount, _TaxTotal, _Freight , _joReleaseDetailID,_PONumber
    from veBill c
    left join rxMaster r on (r.rxMasterID = c.rxMasterID)
	left join joReleaseDetail jord on (jord.joReleaseDetailID = c.joReleaseDetailID)
	left join joMaster jom on (jom.joMasterID = jord.joMasterID)
	left join coDivision cDiv on (cDiv.coDivisionID = jom.coDivisionID)
    left join vePO ve on (ve.vePOID = c.vePOID)
    where c.veBillID = _veBillID;

	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(_transDesc,null);
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(_transDesc,null);

	-- will perform a reversal if not already done.
	CALL GL_reverseGLTransaction(NULL,_reference,_changedByID,_veBillID,_journalId,null,null);
	
	select coLedgerSourceID into _coLedgerSourceID from coLedgerSource where JournalID=_journalId;

	-- VB TransDesc=Company, Ref=InvoiceNumber
	-- 14410-00 VB debit (Freight) sysAccountLinkage.coAccountIDFreight
	-- 14410-03 VB debit (Parts Purchase) concat(prDepartmentID.coAccountIDCOGS (coAccount.Number) "-" coDivisionID.subAccount)
	-- 02360-00 VB debit (Sales Tax Payable) sysAccountLinkage.coAccountIDSalesTaxPaid
	-- 02080-00 VB credit  sysAccountLinkage.coAccountIDAP (Accounts Payable)


	select coAccountIDFreight,coAccountIDSalesTaxPaid, coAccountIDAP , coAccountIDAccrual
    into _coAccountIDFreight,_coAccountIDSalesTaxPaid, _coAccountIDAP,_coAccountIDAccrual from sysAccountLinkage limit 1;
 

	-- 02080-00 VB credit  sysAccountLinkage.coAccountIDAP (Accounts Payable)


	set _credit = 0;
	set _debit = 0;
	if ( _InvoiceAmount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_InvoiceAmount);
    ELSEif ( _InvoiceAmount <0 ) THEN
    	set _debit = ABS(_InvoiceAmount);
    	set _credit = 0;
 	END IF;

	if (_debit >0 or _credit>0) THEN
        
        set _credit_coAccountId = _coAccountIDAP;
        select  `Number` into _credit_coAccountNumber from coAccount where coAccountID=_coAccountIDAP;
        
		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_credit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
	
		if (_DEBUG=1) THEN select concat('VB sysAccountLinkage.coAccountIDAP (Accounts Payable)',' N:',_credit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;
    END IF;
    
	-- 14410-00 VB debit (Freight) sysAccountLinkage.coAccountIDFreight
   
    
	set _credit = 0;
	set _debit = 0;
	if ( _Freight >0 ) THEN
    	set _debit = ABS(_Freight);
    	set _credit = 0;
    ELSEif ( _Freight <0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_Freight);
 	END IF;

	if (_debit >0 or _credit>0) THEN
		
        if((_joReleaseDetailID is null or _joReleaseDetailID =0)) then 
        
			 select w.coAccountIDAsset, ac.Number into _debit_coAccountId, _debit_coAccountNumber
			 from prWarehouse w
			 left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
			 where prWarehouseID = _prFromWarehouse;
        else 
        
			select  GL_buildAccountName(a.Number,_coDivisionSubAccount) into _debit_coAccountNumber from coAccount a where coAccountID=_coAccountIDFreight;
			set _debit_coAccountId = GL_determineAccountNumber( GL_buildAccountName(_debit_coAccountNumber,_coDivisionSubAccount),_coAccountIDFreight);

        end if;

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

 		if (_DEBUG=1) THEN select concat('VB (Freight) sysAccountLinkage.coAccountIDFreight',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

	END IF;
 

	-- 02360-00 VB debit (Sales Tax Payable) sysAccountLinkage.coAccountIDSalesTaxPaid
    
    
	set _credit = 0;
	set _debit = 0;
   if ( _TaxTotal >0 ) THEN
    	set _debit = ABS(_TaxTotal);
    	set _credit = 0;
    ELSEif ( _TaxTotal <0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_TaxTotal);
 	END IF;

	if (_debit >0 or _credit>0) THEN

		set _debit_coAccountId = _coAccountIDSalesTaxPaid;
        select  `Number` into _debit_coAccountNumber from coAccount where coAccountID=_coAccountIDSalesTaxPaid;

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

 		if (_DEBUG=1) THEN select concat('VB (Sales Tax Payable) sysAccountLinkage.coAccountIDSalesTaxPaid',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

	END IF;
 

	-- 14410-03 VB debit (Parts Purchase) concat(prDepartmentID.coAccountIDCOGS (coAccount.Number) "-" coDivisionID.subAccount)
   
    
	if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 
    
		set _itemCost = 0;
        
        select vePOID into _vePOID from veBill where veBillID = _veBillID;
		set _debit_coAccountId = _coAccountIDAccrual;
		select Number into _debit_coAccountNumber from coAccount where coAccountID= _debit_coAccountId;
        
		select ifnull(sum(debit),0) into _addedtill from veBill ve
           left join vePO vp on (ve.vePOID = vp.vePOID)
			left join glLinkage gl on (gl.veBillID = ve.veBillID and coLedgerSourceId = 6220)
			left join glTransaction gt on (gt.glTransactionId = gl.glTransactionId )  
			where  gt.coAccountId = _coAccountIDAccrual  and ve.vePOID = _vePOID and gl.status = 0;
            
		select ifnull(sum(credit),0) into _totaltill from 
			glLinkage gl 
			left join vePODetail vd on (gl.vePODetailID = vd.vePODetailID and coLedgerSourceId = 9101)
			left join vePO vp on (vd.vePOID = vp.vePOID)
			left join glTransaction gt on (gt.glTransactionId = gl.glTransactionId )  where  gt.coAccountId = _coAccountIDAccrual  
            and vp.vePOID = _vePOID;
            
		set  _accuralAmount = _totaltill - _addedtill;
        set _itemCost = _InvoiceAmount - (_accuralAmount+_TaxTotal+_Freight) ;
        set _Subtotal = _accuralAmount;
	
		set _credit = 0;
		set _debit = 0;
	   if ( _Subtotal >0 ) THEN
			set _debit = ABS(_Subtotal);
			set _credit = 0;
		ELSEif ( _Subtotal <0 ) THEN
			set _debit = 0;
			set _credit = ABS(_Subtotal);
		END IF;

		if (_debit >0 or _credit>0) THEN
			insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
			values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

			SELECT LAST_INSERT_ID() INTO _glTransactionId;

			insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

			if (_DEBUG=1) THEN select concat('VB (_joReleaseDetailID=0 Parts Purchase) concat(prDepartmentID.coAccountIDCOGS (coAccount.Number) "-" coDivisionID.subAccount',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

		END IF;
    
		select group_concat(veBillDetailID) into _glTransactions from veBillDetail t where veBillID = _veBillID;
    
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_glTransactions);
				set _veBillDetailID=SUBSTRING_INDEX(_glTransactions, ',', 1);
               
				select (d.UnitCost * d.QuantityBilled*IF((d.PriceMultiplier IS NULL || d.PriceMultiplier=0),1,d.PriceMultiplier)), dept.coAccountIDCOGS as coAccountID, 
				(select Number from coAccount where coAccountID= dept.coAccountIDCOGS) as AccountName,p.IsInventory,d.vePODetailID,bill.vePOID

				into _Subtotal,_debit_coAccountId,_debit_coAccountNumber,_isInventory,_vePODetailID,_vePOID
				from veBillDetail  d
				left join veBill bill on (bill.veBillID = d.veBillID)
				left join prMaster p on (p.prMasterID = d.prMasterID)
				left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
				left join coAccount a on (a.coAccountID = dept.coAccountIDCOGS)
				where d.veBillDetailID=_veBillDetailID; 

				if(_isInventory = 0) then 
					-- select _itemCost,_Subtotal;-- DEBUG?
					set _itemCost = _itemCost - _Subtotal;
					-- select _itemCost,_Subtotal; -- DEBUG?
					set _credit = 0;
					set _debit = 0;
					
					if ( _Subtotal >0 ) THEN
							set _debit = ABS(_Subtotal);
							set _credit = 0;
					ELSEif ( _Subtotal <0 ) THEN
							set _debit = 0;
							set _credit = ABS(_Subtotal);
					END IF;

					if (_debit >0 or _credit>0) THEN

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
						
                        if (_DEBUG=1) THEN select concat('VB (_joReleaseDetailID=0 Parts Purchase) concat(prDepartmentID.coAccountIDCOGS (coAccount.Number) "-" coDivisionID.subAccount',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

					END IF;
					
				end if; -- is inventory
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_glTransactions, ',', 1))+2;
				SET _glTransactions = MID(_glTransactions, SubStrLen, strLen);
				IF (_glTransactions = '' or _glTransactions is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  

    else -- if(_joReleaseDetailID is null or _joReleaseDetailID =0)
    
		select group_concat(veBillDetailID) into _glTransactions from veBillDetail t where veBillID = _veBillID;
    
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_glTransactions);
				set _veBillDetailID=SUBSTRING_INDEX(_glTransactions, ',', 1);
               
				select (d.UnitCost * d.QuantityBilled*IF((d.PriceMultiplier IS NULL || d.PriceMultiplier=0),1,d.PriceMultiplier)), dept.coAccountIDCOGS as coAccountID, 
				(select Number from coAccount where coAccountID= dept.coAccountIDCOGS) as AccountName,p.IsInventory,d.vePODetailID,bill.vePOID

				into _Subtotal,_debit_coAccountId,_debit_coAccountNumber,_isInventory,_vePODetailID,_vePOID
				from veBillDetail  d
				left join veBill bill on (bill.veBillID = d.veBillID)
				left join prMaster p on (p.prMasterID = d.prMasterID)
				left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
				left join coAccount a on (a.coAccountID = dept.coAccountIDCOGS)
				where d.veBillDetailID=_veBillDetailID; 

				set _credit = 0;
				set _debit = 0;
				if ( _Subtotal >0 ) THEN
					set _debit = ABS(_Subtotal);
					set _credit = 0;
				ELSEif ( _Subtotal <0 ) THEN
					set _debit = 0;
					set _credit = ABS(_Subtotal);
				END IF;

				if (_debit >0 or _credit>0) THEN

					insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
					values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

					SELECT LAST_INSERT_ID() INTO _glTransactionId;

					insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

					if (_DEBUG=1) THEN select concat('VB (_joReleaseDetailID>0 Parts Purchase) concat(prDepartmentID.coAccountIDCOGS (coAccount.Number) "-" coDivisionID.subAccount',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

				END IF;
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_glTransactions, ',', 1))+2;
				SET _glTransactions = MID(_glTransactions, SubStrLen, strLen);
				IF (_glTransactions = '' or _glTransactions is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  
            
	end if;  -- ELSE END
            
            
            
	if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 
        
			set _credit = 0;
			set _debit = 0;
			if ( _itemCost >0 ) THEN
				set _debit = ABS(_itemCost);
				set _credit = 0;
			ELSEif ( _itemCost <0 ) THEN
				set _debit = 0;
				set _credit = ABS(_itemCost);
			END IF;
    
			 select w.coAccountIDAsset, ac.Number into _debit_coAccountId, _debit_coAccountNumber
				from prWarehouse w
				left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
				where prWarehouseID = _prFromWarehouse;

			if (_debit >0 or _credit>0) THEN

				insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
				values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

				SELECT LAST_INSERT_ID() INTO _glTransactionId;

				insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);

				if (_DEBUG=1) THEN select concat('VB (_joReleaseDetailID=0 Parts Purchase) concat(prDepartmentID.coAccountIDCOGS (coAccount.Number) "-" coDivisionID.subAccount',' N:',_debit_coAccountNumber,' D:',_debit,' C:',_credit); END IF;

			END IF;
            
    end if;

	set _furtherUpdatesNeeded=0;
    
    if (_DEBUG=1) THEN
    
select g.glTransactionId,journalId,journalDesc,l.veBillID,a.coAccountId, g.coAccountNumber, a.Description reference, debit, credit 
from glTransaction g
left join glLinkage l on (g.glTransactionId=l.glTransactionId)
left join coAccount a on (a.coAccountID = g.coAccountID)
where l.veBillID = _veBillID
order by glTransactionId ASC; 
    
    END IF;



WHEN _journalId='VBD' THEN 
	set _journalId = "VB";
	set _journalDesc='Vendor Bills';
    set _veBillID = _itemDetailID;
    
    select c.InvoiceNumber, r.`Name`, null as prFromWarehouseID, c.BillAmount, c.TaxAmount, c.FreightAmount
    into _reference,_transDesc,_prFromWarehouse,_InvoiceAmount, _TaxTotal, _Freight 
    from veBill c
    left join rxMaster r on (r.rxMasterID = c.rxMasterID)
    where c.veBillID = _veBillID;
    
    
	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(_transDesc,null);
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(_transDesc,null);

	-- will perform a reversal if not already done.
	CALL GL_reverseGLTransaction(NULL,_reference,_changedByID,_veBillID,_journalId,null,null);
    
    select coLedgerSourceID into _coLedgerSourceID from coLedgerSource where JournalID=_journalId;

	

	select coAccountIDFreight,coAccountIDSalesTaxPaid, coAccountIDAP , coAccountIDAccrual
    into _coAccountIDFreight,_coAccountIDSalesTaxPaid, _coAccountIDAP,_coAccountIDAccrual from sysAccountLinkage limit 1;
 

	-- 02080-00 VB credit  sysAccountLinkage.coAccountIDAP (Accounts Payable)


	set _credit = 0;
	set _debit = 0;
	if ( _InvoiceAmount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_InvoiceAmount);
    ELSEif ( _InvoiceAmount <0 ) THEN
    	set _debit = ABS(_InvoiceAmount);
    	set _credit = 0;
 	END IF;

	if (_debit >0 or _credit>0) THEN
        
        set _credit_coAccountId = _coAccountIDAP;
        select  `Number` into _credit_coAccountNumber from coAccount where coAccountID=_coAccountIDAP;
        
		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_credit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
	END IF;
    -- select all the vebill distribution 
	select group_concat(veBillDistributionID) into _glTransactions from veBillDistribution t where veBillID = _veBillID;
    
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_glTransactions);
				set _veBillDetailID=SUBSTRING_INDEX(_glTransactions, ',', 1);
               
	-- debit from the account as per the distribution 

		select IFNULL(d.ExpenseAmount,0), d.coExpenseAccountID as coAccountID, 
		(select Number from coAccount where coAccountID= d.coExpenseAccountID) as AccountName

		into _Subtotal,_debit_coAccountId,_debit_coAccountNumber
        
		from veBillDistribution  d
		where d.veBillDistributionID=_veBillDetailID; 



	set _credit = 0;
	set _debit = 0;
   if ( _Subtotal >0 ) THEN
    	set _debit = ABS(_Subtotal);
    	set _credit = 0;
    ELSEif ( _Subtotal <0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_Subtotal);
 	END IF;

	if (_debit >0 or _credit>0) THEN

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
	END IF;
        
				
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_glTransactions, ',', 1))+2;
				SET _glTransactions = MID(_glTransactions, SubStrLen, strLen);
				IF (_glTransactions = '' or _glTransactions is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  


	set _furtherUpdatesNeeded=0;
 

	
    
    
WHEN _journalId='CI' THEN 

/*
	5788914	CI	186	3100-01-000	COST OF GOODS - DALLAS	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	99.0454	0.0000 (prMasterID.avCost*qty) prDepartment.coAccountIDCOGS  not prWarehouse.adjustCogAccountID
		if( inventory) sysAccountLinkage.coAccountIDShipInventory (this includes freight)
		if( non inventory) sysAccountLinkage.coAccountIDShipping (this includes freight)
	-- what if freight:  sysAccountLinkage.coAccountIDShipInventory
	5788913	CI	181	3000-01-000	SALES - DALLAS	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	160.0000 (unitCost*qty*mult) 
	5788912	CI	166	2150-00-000	SALES TAX PAYABLE	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	13.2000 sysAccountLinkage.coAccountIDSalesTaxInv
	5788911	CI	141	1350-00-000	INVENTORY	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	99.0454  prWarehouse.coAccountIDAsset
	5788910	CI	130	1150-00-000	ACCOUNTS RECEIVABLE - TRADE	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	173.2000	0.0000 invoiceAmount sysAccountLinkage.coAccountIDAR 
*/
	-- _amount<0 REVERSAL  _amount>0 NORMAL
    
	set _journalDesc='Customer Invoices';

    set _veBillID = _itemDetailID; -- itemDetailId is equal to the cuInvoiceID

	-- call INVOICE_recalculate('CUSTOMERINVOICE',_veBillID,1,_changedByID); -- ignoreGL=1

    select c.InvoiceNumber, r.`Name`, c.prFromWarehouseID, c.InvoiceAmount, c.Subtotal, c.TaxTotal, c.Freight, c.coDivisionID, cDiv.SubAccount
    into _reference,_transDesc,_prFromWarehouse,_InvoiceAmount, _Subtotal, _TaxTotal,_freight, _coDivisionID, _coDivisionSubAccount 
    from cuInvoice c
    left join rxMaster r on (r.rxMasterID = c.rxCustomerID)
    left join coDivision cDiv on (c.coDivisionID = cDiv.coDivisionID)
    where c.cuInvoiceID = _itemDetailID;

	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(_transDesc,null);
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(_transDesc,null);

	-- will perform a reversal if not already done.
	-- call GL_reverseGLTransaction(null,_reference,_changedByID);
	CALL GL_reverseGLTransaction(NULL,_reference,_changedByID,_veBillID,_journalId,_isInvoiceDatechanged,_LastinvoiceDate);


	select coLedgerSourceID into _coLedgerSourceID from coLedgerSource where JournalID=_journalId limit 1;

-- sysAccountLinkage.coAccountIDAR 
-- 	5788910	CI	130	1150-00-000	ACCOUNTS RECEIVABLE - TRADE	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	173.2000	0.0000 invoiceAmount sysAccountLinkage.coAccountIDAR 

	select s.coAccountIDShipping,s.coAccountIDShipInventory,s.coAccountIDSalesTaxInv, s.coAccountIDAR,
    aShip.Number,aShipInv.Number,aTax.Number,aAR.Number
    into
    _coAccountIDShipping,_coAccountIDShipInventory,_coAccountIDSalesTaxInv, _coAccountIDAR, 
    _coAccountIDShippingNumber,_coAccountIDShipInventoryNumber,_coAccountIDSalesTaxInvNumber, _coAccountIDARNumber 
    from sysAccountLinkage s
    left join coAccount aShip on (s.coAccountIDShipping = aShip.coAccountID)
    left join coAccount aShipInv on (s.coAccountIDShipInventory = aShipInv.coAccountID)
    left join coAccount aAR on (s.coAccountIDAR = aAR.coAccountID)
    left join coAccount aTax on (s.coAccountIDSalesTaxInv = aTax.coAccountID)
    limit 1;
 

	-- invoice t DEBIT  541       (130	1150-00-000) sysAccountLinkage.coAccountIDAR
	set _credit = 0;
	set _debit = 0;
	if ( _amount >0 ) THEN
    	set _debit = ABS(_InvoiceAmount);
    	set _credit = 0;
    ELSEif ( _amount <0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_InvoiceAmount);
 	END IF;

	if (_debit >0 or _credit>0) THEN
        
        set _debit_coAccountId = _coAccountIDAR;
        set _debit_coAccountNumber = _coAccountIDARNumber;
        -- select  `Number` into _debit_coAccountNumber from coAccount where coAccountID=_coAccountIDAR;
        
		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
	END IF;


	-- freight
	-- subtotal  CREDIT 500       (181	3000-01-000) sysAccountLinkage.coAccountIDShipInventory
	set _credit = 0;
	set _debit = 0;
   if ( _amount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_freight);
    ELSEif ( _amount <0 ) THEN
    	set _debit = ABS(_freight);
    	set _credit = 0;
 	END IF;

	if (_debit >0 or _credit>0) THEN

       
		select  GL_buildAccountName(_coAccountIDShipInventoryNumber,_coDivisionSubAccount) into _credit_coAccountNumber;
		set _credit_coAccountId = GL_determineAccountNumber( GL_buildAccountName(_credit_coAccountNumber,_coDivisionSubAccount),_coAccountIDShipInventory);

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_credit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
	END IF;


	-- SALES TAX
	-- tax       CREDIT 41        (166	2150-00-000) sysAccountLinkage.coAccountIDSalesTaxInv
	set _credit = 0;
	set _debit = 0;
   if ( _amount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_TaxTotal);
    ELSEif ( _amount <0 ) THEN
    	set _debit = ABS(_TaxTotal);
    	set _credit = 0;
 	END IF;

	if (_debit >0 or _credit>0) THEN

		set _debit_coAccountId = _coAccountIDSalesTaxInv;
        set _debit_coAccountNumber = _coAccountIDSalesTaxInvNumber;

		insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
		values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

		SELECT LAST_INSERT_ID() INTO _glTransactionId;

		insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);
	END IF;
 
 
  select jr.ReleaseType INTO _releaseType from cuInvoice ci left join joReleaseDetail jd on (ci.joReleaseDetailID = jd.joReleaseDetailID)
	  left join joRelease jr on (jr.joReleaseID = jd.joReleaseID)  where ci.cuInvoiceID = _itemDetailID;
    
      if(_releaseType = 2 or _releaseType = 3 or _releaseType = 5 or _releaseType is null) then 

     -- INVENTORY and COGS and SALES
     select group_concat(cuInvoiceDetailID) into _glTransactions from cuInvoiceDetail t where cuInvoiceID = _veBillID;

	set _coAccountIDInvTotal_debit=0;
	set _coAccountIDInvTotal_credit=0;
 
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_glTransactions);
				set _cuInvoiceDetailID=SUBSTRING_INDEX(_glTransactions, ',', 1);
               
				select (p.AverageCost * d.QuantityBilled),( d.QuantityBilled*d.UnitCost*IF((d.PriceMultiplier IS NULL || d.PriceMultiplier=0),1,d.PriceMultiplier)),
				ainv.coAccountID as coAccountID_asset, 
				GL_determineAccountNumber(GL_buildAccountName(acogs.Number,cDiv.SubAccount),acogs.coAccountID) as coAccountID_cogs, 
				ainv.Number as AccountName_asset,
				GL_buildAccountName(acogs.Number,cDiv.SubAccount) as AccountName_cogs,
				p.IsInventory
				into _itemCost,_Subtotal,_coAccountIDInventory,_coAccountIDCogs,_coAccountIDInventoryNumber,_coAccountIDCogsNumber,_isInventory
				from cuInvoiceDetail  d
				left join cuInvoice bill on (bill.cuInvoiceID = d.cuInvoiceID)
				left join prMaster p on (p.prMasterID = d.prMasterID)
				left join prWarehouse w on (w.prWarehouseID = bill.prFromWarehouseID)
				left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
				left join coAccount ainv on (ainv.coAccountID = w.coAccountIDAsset)
				left join coAccount acogs on (acogs.coAccountID = dept.coAccountIDCOGS)
				left join coDivision cDiv on (cDiv.coDivisionID = bill.coDivisionID)
				where d.cuInvoiceDetailID=_cuInvoiceDetailID;



-- select _Subtotal,_credit_coAccountId,_debit_coAccountId,_credit_coAccountNumber,_debit_coAccountNumber,_isInventory;

     
				if (_isInventory=1) THEN
				
                  set _debit = 0;
                  set _credit = 0;
				   if ( _itemCost >0 ) THEN
						set _debit = 0;
						set _credit = _itemCost;
						set _coAccountIDInvTotal_credit = _coAccountIDInvTotal_credit + _credit;
					ELSEif ( _itemCost <0 ) THEN
						set _debit = _itemCost;
						set _credit = 0;
						set _coAccountIDInvTotal_debit = _coAccountIDInvTotal_debit + _debit;
					END IF;
				 END IF;
/*
					if (_debit >0 or _credit>0) THEN

	-- 5788911	CI	141	1350-00-000	INVENTORY	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	99.0454  prWarehouse.coAccountIDAsset

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,now(),ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_credit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


	-- 5788914	CI	186	3100-01-000	COST OF GOODS - DALLAS	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	99.0454	0.0000 (prMasterID.avCost*qty) prDepartment.coAccountIDCOGS  not prWarehouse.adjustCogAccountID

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,now(),ROUND_TO_EVEN(_credit,2),ROUND_TO_EVEN(_debit,2),_debit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


					END IF;
*/
				
				

		-- if( inventory) sysAccountLinkage.coAccountIDShipInventory
		-- if( non inventory) sysAccountLinkage.coAccountIDShipping 
 
				
                  set _debit = 0;
                  set _credit = 0;
				   if ( _Subtotal >0 ) THEN
						set _debit = 0;
						set _credit = ABS(_Subtotal);
					ELSEif ( _Subtotal <0 ) THEN
						set _debit = ABS(_Subtotal);
						set _credit = 0;
					END IF;

				if (_isInventory=1) THEN
					select  GL_buildAccountName(_coAccountIDShipInventoryNumber,_coDivisionSubAccount) into _credit_coAccountNumber;
					set _credit_coAccountId = GL_determineAccountNumber( GL_buildAccountName(_credit_coAccountNumber,_coDivisionSubAccount),_coAccountIDShipInventory);

				else 
					select  GL_buildAccountName(_coAccountIDShippingNumber,_coDivisionSubAccount) into _credit_coAccountNumber;
					set _credit_coAccountId = GL_determineAccountNumber( GL_buildAccountName(_credit_coAccountNumber,_coDivisionSubAccount),_coAccountIDShipping);
                END IF;
                
					if (_debit >0 or _credit>0) THEN

--    5788913	CI	181	3000-01-000	SALES - DALLAS	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	160.0000 (unitCost*qty*mult) 

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_credit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


					END IF;



								
			SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_glTransactions, ',', 1))+2;
			SET _glTransactions = MID(_glTransactions, SubStrLen, strLen);
			IF (_glTransactions = '' or _glTransactions is null) THEN
					LEAVE do_this;
			END IF;
									
			END LOOP do_this;  


			-- COGS and INVENTORY
					-- handle if inventory is being pulled
                  
					if (_coAccountIDInvTotal_credit >0) THEN

	-- 5788911	CI	141	1350-00-000	INVENTORY	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	99.0454  prWarehouse.coAccountIDAsset

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_coAccountIDInventory,_coAccountIDInventoryNumber,_credit_transDesc,_transactionDate,0,ROUND_TO_EVEN(_coAccountIDInvTotal_credit,2),_credit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


	-- 5788914	CI	186	3100-01-000	COST OF GOODS - DALLAS	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	99.0454	0.0000 (prMasterID.avCost*qty) prDepartment.coAccountIDCOGS  not prWarehouse.adjustCogAccountID

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_coAccountIDCogs,_coAccountIDCogsNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_coAccountIDInvTotal_credit,2),0,_debit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


					END IF;

					-- handle if inventory is being put back
					if (_coAccountIDInvTotal_debit <>0) THEN

	-- 5788911	CI	141	1350-00-000	INVENTORY	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	99.0454  prWarehouse.coAccountIDAsset

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_coAccountIDInventory,_coAccountIDInventoryNumber,_credit_transDesc,_transactionDate,ABS(ROUND_TO_EVEN(_coAccountIDInvTotal_debit,2)),0,_credit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


	-- 5788914	CI	186	3100-01-000	COST OF GOODS - DALLAS	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	99.0454	0.0000 (prMasterID.avCost*qty) prDepartment.coAccountIDCOGS  not prWarehouse.adjustCogAccountID

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_coAccountIDCogs,_coAccountIDCogsNumber,_debit_transDesc,_transactionDate,0,ABS(ROUND_TO_EVEN(_coAccountIDInvTotal_debit,2)),_debit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


					END IF;
     
      else 
      
       --  SALES
     select group_concat(cuInvoiceDetailID) into _glTransactions from cuInvoiceDetail t where cuInvoiceID = _veBillID;

	
 
		 do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_glTransactions);
				set _cuInvoiceDetailID=SUBSTRING_INDEX(_glTransactions, ',', 1);
               
				select (p.AverageCost * d.QuantityBilled),( d.QuantityBilled*d.UnitCost*IF((d.PriceMultiplier IS NULL || d.PriceMultiplier=0),1,d.PriceMultiplier)),
				ainv.coAccountID as coAccountID_asset, 
				GL_determineAccountNumber(GL_buildAccountName(acogs.Number,cDiv.SubAccount),acogs.coAccountID) as coAccountID_cogs, 
				ainv.Number as AccountName_asset,
				GL_buildAccountName(acogs.Number,cDiv.SubAccount) as AccountName_cogs,
				p.IsInventory
				into _itemCost,_Subtotal,_coAccountIDInventory,_coAccountIDCogs,_coAccountIDInventoryNumber,_coAccountIDCogsNumber,_isInventory
				from cuInvoiceDetail  d
				left join cuInvoice bill on (bill.cuInvoiceID = d.cuInvoiceID)
				left join prMaster p on (p.prMasterID = d.prMasterID)
				left join prWarehouse w on (w.prWarehouseID = bill.prFromWarehouseID)
				left join prDepartment dept on (dept.prDepartmentID = p.prDepartmentID) 
				left join coAccount ainv on (ainv.coAccountID = w.coAccountIDAsset)
				left join coAccount acogs on (acogs.coAccountID = dept.coAccountIDCOGS)
				left join coDivision cDiv on (cDiv.coDivisionID = bill.coDivisionID)
				where d.cuInvoiceDetailID=_cuInvoiceDetailID;



-- select _Subtotal,_credit_coAccountId,_debit_coAccountId,_credit_coAccountNumber,_debit_coAccountNumber,_isInventory;

     
   
 
				
                  set _debit = 0;
                  set _credit = 0;
				   if ( _Subtotal >0 ) THEN
						set _debit = 0;
						set _credit = ABS(_Subtotal);
					ELSEif ( _Subtotal <0 ) THEN
						set _debit = ABS(_Subtotal);
						set _credit = 0;
					END IF;

				if (_isInventory=1) THEN
					select  GL_buildAccountName(_coAccountIDShipInventoryNumber,_coDivisionSubAccount) into _credit_coAccountNumber;
					set _credit_coAccountId = GL_determineAccountNumber( GL_buildAccountName(_credit_coAccountNumber,_coDivisionSubAccount),_coAccountIDShipInventory);

				else 
					select  GL_buildAccountName(_coAccountIDShippingNumber,_coDivisionSubAccount) into _credit_coAccountNumber;
					set _credit_coAccountId = GL_determineAccountNumber( GL_buildAccountName(_credit_coAccountNumber,_coDivisionSubAccount),_coAccountIDShipping);
                END IF;
                
					if (_debit >0 or _credit>0) THEN

--    5788913	CI	181	3000-01-000	SALES - DALLAS	DJD200306B1	Credit Card Sales	2020-04-20 00:00:00	0.0000	160.0000 (unitCost*qty*mult) 

						insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
						values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_credit_reference,_journalId,_journalDesc);

						SELECT LAST_INSERT_ID() INTO _glTransactionId;

						insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID);


					END IF;

		

								
			SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_glTransactions, ',', 1))+2;
			SET _glTransactions = MID(_glTransactions, SubStrLen, strLen);
			IF (_glTransactions = '' or _glTransactions is null) THEN
					LEAVE do_this;
			END IF;
									
			END LOOP do_this;  
      end if;
 
	
 	





	set _furtherUpdatesNeeded=0;


WHEN _journalId='JE' THEN set _journalDesc='Journal Entry';
WHEN _journalId='TR' THEN 

	set _journalDesc='Transfer Received';

	-- set _credit = ABS(_amount);
	-- set _debit = 0;
    
     if ( _amount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_amount);
    ELSEif ( _amount <0 ) THEN
    	set _debit = ABS(_amount);
    	set _credit = 0;
 	ElSE
 		-- nothing to do since the value is zero
		LEAVE GL_updateGLTransaction; 
 	END IF;
    
	
	-- select w.coAccountIDMisc, ad.Number into _debit_coAccountId, _debit_coAccountNumber 
    -- from sysAccountLinkage w
    -- left join coAccount ad on (ad.coAccountID = w.coAccountIDMisc);
	
    select w.coAccountIDAsset, ac.Number, w.SearchName into _debit_coAccountId, _debit_coAccountNumber, _toWarehouse
    from prWarehouse w
    left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
    where prWarehouseID = _prToWarehouse;
    
     select w.coAccountIDAsset, ac.Number, w.SearchName into _credit_coAccountId, _credit_coAccountNumber, _fromWarehouse
    from prWarehouse w
    left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
    where prWarehouseID = _prFromWarehouse;

	set _debit_reference = IFNULL(_reference,null);
  --   set _debit_transDesc = IFNULL(concat('hold:',_transDesc),'xferhold');
	set _credit_reference = IFNULL(_reference,null);
  --   set _credit_transDesc = IFNULL(concat('xfer:',_transDesc),'xfer');
	if ( _amount >0 ) THEN
    	set _debit_transDesc = concat("From ",_fromWarehouse);
        set _credit_transDesc = concat("To ",_toWarehouse);
    ELSEif ( _amount <0 ) THEN
    	 set _debit_transDesc = concat("To ",_fromWarehouse);
        set _credit_transDesc = concat("From ",_toWarehouse);
 	end if;
    
    set _veBillID = _reference;
    
WHEN _journalId='IT' THEN 
	
    SET _journalDesc='Inventory Transfer';
	SET _debit = ABS(_amount);
	SET _credit = 0;
	-- SELECT w.coAccountIDAsset, ad.Number INTO _debit_coAccountId, _debit_coAccountNumber 
    SELECT w.coAccountIDAsset, ad.Number INTO _credit_coAccountId, _credit_coAccountNumber
    FROM prWarehouse w
    LEFT JOIN coAccount ad ON (ad.coAccountID = w.coAccountIDAsset)
    WHERE prWarehouseID = _prFromWarehouse;
	SELECT w.coAccountIDMisc, ad.Number INTO _debit_coAccountId, _debit_coAccountNumber 
    FROM sysAccountLinkage w
    LEFT JOIN coAccount ad ON (ad.coAccountID = w.coAccountIDMisc);
	
	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(concat('xfer:',_transDesc),'xfer');
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(concat('Hold:',_transDesc),'xferhold');

    set _veBillID = _reference;
    
WHEN _journalId='CP' THEN set _journalDesc='Customer Payment';
WHEN _journalId='WC' THEN set _journalDesc='Write Checks';
WHEN _journalId='BT' THEN set _journalDesc='Bank Transaction';
WHEN _journalId='IC' THEN set _journalDesc='Inventory Count';

	set _journalDesc='Inventory Count';

    if ( _amount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_amount);
    ELSEif ( _amount <0 ) THEN
    	set _debit = ABS(_amount);
    	set _credit = 0;
 	ElSE
 		-- nothing to do since the value is zero
		LEAVE GL_updateGLTransaction; 
 	END IF;
    
	select w.coAccountIDAsset, w.adjustCogAccountID, ad.Number, ac.Number into _credit_coAccountId,_debit_coAccountId,_credit_coAccountNumber, _debit_coAccountNumber 
    from prWarehouse w
    left join coAccount ad on (ad.coAccountID = w.coAccountIDAsset)
    left join coAccount ac on (ac.coAccountID = w.adjustCogAccountID)    
    where prWarehouseID = _prFromWarehouse;
	
	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(concat('ADJ:',_transDesc),'ADJ:');
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(concat('ADJ:',_transDesc),'ADJ:');
    
    set _veBillID = _reference;

WHEN _journalId='RI' THEN 

	set _journalDesc='Receive Inventory';

	if (_veReceiveDetailBinID is NULL) THEN
			set _message = concat('GL_updateGLTransaction: _veReceiveDetailID required to receive');
			 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = _message;
			LEAVE GL_updateGLTransaction; 
	END IF;


    if ( _amount >0 ) THEN
    	set _debit = 0;
    	set _credit = ABS(_amount);
    	set _veReverse=0;
    ELSEif ( _amount <0 ) THEN
    	set _debit = ABS(_amount);
    	set _credit = 0;
    	set _veReverse=1;
 	ElSE
 		-- nothing to do since the value is zero
		LEAVE GL_updateGLTransaction; 
 	END IF;
	-- sysAccountLinkage.coAccountIDAccrual
/*	 select w.coAccountIDAsset, w.adjustCogAccountID, ad.Number, ac.Number into _credit_coAccountId,_debit_coAccountId, _debit_coAccountNumber,_credit_coAccountNumber 
    from prWarehouse w
    left join coAccount ad on (ad.coAccountID = w.coAccountIDAsset)
    left join coAccount ac on (ac.coAccountID = w.adjustCogAccountID)    
    where prWarehouseID = _prFromWarehouse;
*/
	set _vePODetailID = _itemDetailID;
	select  ac.coAccountID, ac.Number
    into
    _credit_coAccountId,_credit_coAccountNumber 
    from prWarehouse w
    left join coAccount ac on (ac.coAccountID = w.coAccountIDAsset)
    where prWarehouseID = _prFromWarehouse;
    
    select s.coAccountIDAccrual,ad.Number
    into
    
    _debit_coAccountId, _debit_coAccountNumber 
    from sysAccountLinkage s
    left join coAccount ad on (ad.coAccountID = s.coAccountIDAccrual) ;
    
    -- set _reference = _veReceiveDetailBinID;
	set _debit_reference = IFNULL(_reference,null);
    set _debit_transDesc = IFNULL(_transDesc,null);
	set _credit_reference = IFNULL(_reference,null);
    set _credit_transDesc = IFNULL(_transDesc,null);
    
    set _veBillID = _reference;
    
    select veReceiveDetailID into _veReceiveDetailID from veReceiveDetailBin where veReceiveDetailBinID=_veReceiveDetailBinID;
    
    

	if (_veReverse is not null and _veReceiveDetailBinID is not null) THEN
		update veReceiveDetailBin set reversed=_veReverse, GlRecordedTime = now() where veReceiveDetailBinID=_veReceiveDetailBinID;
	END IF;



WHEN _journalId='RE' THEN set _journalDesc='Retained Earnings';


ELSE set _journalDesc=null;
END CASE;

IF (_furtherUpdatesNeeded > 0 and (_debit >0 or _credit>0)) THEN

	if (_journalDesc is NULL) THEN
			-- ,_journalId
			set _message = concat('GL_updateGLTransaction: journalId not found');
			 SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = _message;
			LEAVE GL_updateGLTransaction; 
	END IF;

	if (_credit_coAccountId is NULL or _debit_coAccountId is null ) THEN
			-- ,_journalDesc
			set _message = concat('GL_updateGLTransaction: coAccounts not found');
			 SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = _message;
			LEAVE GL_updateGLTransaction; 
	END IF;


	select coLedgerSourceID into _coLedgerSourceID from coLedgerSource where JournalID=_journalId;

	-- select _coLedgerSourceID,_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_credit_coAccountId, _debit_coAccountNumber,_credit_coAccountNumber,now(),ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_credit_reference,_journalId,_journalDesc,_debit_transDesc,_credit_transDesc;

	-- debit
	insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
	values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,ROUND_TO_EVEN(_debit,2),ROUND_TO_EVEN(_credit,2),_debit_reference,_journalId,_journalDesc);

	SELECT LAST_INSERT_ID() INTO _glTransactionId;

	insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID,vePODetailID,veReceiveDetailID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID,_vePODetailID,_veReceiveDetailID);



	-- credit (reverse debit/credit)
	insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
	values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_credit_coAccountId,_credit_coAccountNumber,_credit_transDesc,_transactionDate,ROUND_TO_EVEN(_credit,2),ROUND_TO_EVEN(_debit,2),_credit_reference,_journalId,_journalDesc);

	SELECT LAST_INSERT_ID() INTO _glTransactionId;

	insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID,vePODetailID,veReceiveDetailID) values (now(),_glTransactionId,0,_coLedgerSourceID,_veBillID,_vePODetailID,_veReceiveDetailID);

END IF;

END$$

DELIMITER ;

