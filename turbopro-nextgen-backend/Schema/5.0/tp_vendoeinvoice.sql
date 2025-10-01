DROP procedure IF EXISTS `VENDOR_updateInvoive`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `VENDOR_updateInvoive`(
IN _action varchar(20),
IN _vebillID INT,
IN _vePOID INT,
IN _rxMasterID INT,
IN _joReleaseDetailID INT,
IN _BillDate date,
IN _APAccountID INT,
IN _DueDate date,
IN _ShipDate date,
IN _PostDate date,
IN _UsePostDate INT,
IN _TrackingNumber varchar(50),
IN _veShipViaID int,
IN _ReceiveDate date,
IN _InvoiceNumber varchar(20),
IN _Freight decimal(19,4),
IN _subTotal decimal(19,4),
IN _taxAmount decimal(19,4),
IN _joReleaseID INT,
IN _joMasterID INT,
IN _reason varchar(10000),
IN _updatePO INT,
IN _changedByID INT
)
VENDOR_updateInvoive:BEGIN
declare _count int;
declare _billAmount decimal(19,4);
DECLARE commaNeeded INT DEFAULT 0;
		
		update joMaster set ChangedOn = now() where joMasterID = _joMasterID;
		set _billAmount = _subTotal+ifnull(_taxAmount,0)+ifnull(_Freight,0);
		if (_action = 'UPDATE') THEN
			if(_vebillID is null) then
				if (_joReleaseID >0 and _joMasterID>0) THEN
						if(_joReleaseDetailID is not null) then 
						
							update joReleaseDetail set VendorInvoiceDate = Date(now()), VendorInvoiceAmount = _billAmount where joReleaseDetailID = _joReleaseDetailID;
						else
						-- create the releaseDetail
						insert into joReleaseDetail (joReleaseID,joMasterID,ShipDate,VendorInvoiceDate,VendorInvoiceAmount,
						CustomerInvoiceDate,CustomerInvoiceAmount)
						values
						(_joReleaseID,_joMasterID,_ShipDate,_ReceiveDate,_billAmount,null,null);
						
						SELECT LAST_INSERT_ID() INTO _joReleaseDetailID;
						end if;
				end if;
            
					 insert into veBill 
					  (rxMasterID,vePOID,joReleaseDetailID,BillDate,UsePostDate,ReceiveDate,
					  PostDate,DueDate,ShipDate,BillAmount,TaxAmount,FreightAmount, 
					  InvoiceNumber,APAccountID,veShipViaID,TrackingNumber,CreatedByID,CreatedOn,Void,Applied)
					  values
					  (_rxMasterID,_vePOID,_joReleaseDetailID,date(_BillDate),_UsePostDate,date(_ReceiveDate),
					  date(_PostDate),date(_DueDate),date(_ShipDate),_billAmount,ifnull(_taxAmount,0),ifnull(_Freight,0),
					  _InvoiceNumber,_APAccountID,_veShipViaID,_TrackingNumber,_changedByID,now(),0,0);
                      
                      select last_insert_id() into _vebillID;
                      select _vebillID;
              else

						if(_joReleaseDetailID is not null) then 
							update joReleaseDetail set  VendorInvoiceAmount = _billAmount where joReleaseDetailID = _joReleaseDetailID;
						end if;

					  SET  @l_sql ='update veBill set ';
                      
						  IF (_rxMasterID IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' rxMasterID =', _rxMasterID); 
							SET commaNeeded =1;
						  END IF;
                            IF (_BillDate IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' BillDate =\'', date(_BillDate),'\''); 
							SET commaNeeded =1;
						  END IF;
                            IF (_UsePostDate IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' UsePostDate =', _UsePostDate); 
							SET commaNeeded =1;
						  END IF;
                            IF (_ReceiveDate IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' ReceiveDate =\'', date(_ReceiveDate),'\''); 
							SET commaNeeded =1;
						  END IF;
                            IF (_PostDate IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' PostDate =\'', date(_PostDate),'\''); 
							SET commaNeeded =1;
						  END IF;
                            IF (_DueDate IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' DueDate =\'', date(_DueDate),'\''); 
							SET commaNeeded =1;
						  END IF;
                            IF (_ShipDate IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' ShipDate =\'', date(_ShipDate),'\''); 
							SET commaNeeded =1;
						  END IF;
                            IF (_billAmount IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' BillAmount =', _billAmount); 
							SET commaNeeded =1;
						  END IF;
                            IF (_taxAmount IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' TaxAmount =', _taxAmount); 
							SET commaNeeded =1;
						  END IF;
                            IF (_Freight IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' FreightAmount =', _Freight); 
							SET commaNeeded =1;
						  END IF;
                            IF (_InvoiceNumber IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' InvoiceNumber =\'', _InvoiceNumber,'\''); 
							SET commaNeeded =1;
						  END IF;
                          IF (_APAccountID IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' APAccountID =', _APAccountID); 
							SET commaNeeded =1;
						  END IF;
                          IF (_veShipViaID IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' veShipViaID =', _veShipViaID); 
							SET commaNeeded =1;
						  END IF;
                          IF (_TrackingNumber IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' TrackingNumber =\'', _TrackingNumber,'\''); 
							SET commaNeeded =1;
						  END IF;
                          IF (_reason IS NOT NULL) THEN 
							IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
							SET @l_sql = CONCAT(@l_sql,' Reason =\'', _reason,'\''); 
							SET commaNeeded =1;
						  END IF;
                          
                          IF (commaNeeded>0) THEN
							
								SET @l_sql = CONCAT(@l_sql,',ChangedOn =\'', NOW(),'\''); 
								SET @l_sql = CONCAT(@l_sql,',ChangedByID =', _changedByID);
                                SET @l_sql = CONCAT(@l_sql,' ,TransactionStatus = 1');
								SET @l_sql = CONCAT(@l_sql,' where veBillID=', _vebillID); 
								-- select @l_sql;
									
								PREPARE stmt FROM @l_sql;
								EXECUTE stmt;
								DEALLOCATE PREPARE stmt;
							
						END IF;
								select  _vebillID;
              end if;
              if (_updatePO = 1) then 
					update vePO set TransactionStatus = 2 where vePOID = _vePOID;
				end if;
                
			elseif (_action = 'VOID') then 
				update veBill set TransactionStatus = -1 , ChangedOn = now() , Reason = _reason where veBillID = _vebillID;
                select InvoiceNumber into _InvoiceNumber from veBill where veBillID = _vebillID;
                CALL GL_reverseGLTransaction(NULL,_InvoiceNumber,_changedByID,_vebillID,"VB",null,null);
                select  _vebillID;

			elseif (_action = 'HOLD') then 
				update veBill set TransactionStatus = -2 , ChangedOn = now() , Reason = _reason where veBillID = _vebillID;
                select  _vebillID;
		
        end if;
END$$

DELIMITER ;

-- =======================================================


DROP procedure IF EXISTS `VENDOR_updateInvoiveDetail`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `VENDOR_updateInvoiveDetail`(
IN _action varchar(20),
IN _veBillID INT,
IN _veBillDetailID INT,
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
VENDOR_updateInvoiveDetail:BEGIN
DECLARE _alreadyBilled decimal(19,4) default 0;
DECLARE _orderBilled decimal(19,4) default 0;
DECLARE _vePOID INT;
DECLARE _veBilllineItemCount INT;

if (_action = 'UPDATE') THEN
	if (_veBillID is not null) THEN
		if (_QuantityBilled is null or _UnitCost is null or _PriceMultiplier is null or  _Taxable is null)
		THEN 
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call VENDOR_updateInvoiveDetail:Required: QuantityBilled,UnitCost,PriceMultiplier,Taxable';
			leave VENDOR_updateInvoiveDetail; 
		END IF;
			if(_veBillDetailID is null) then
            
            if(_vePODetailID is not null) then 
            select sum(QuantityBilled) into _alreadyBilled from veBillDetail where vePODetailID = _vePODetailID;
            select QuantityOrdered into _orderBilled from vePODetail where vePODetailID = _vePODetailID;
            select vePOID into _vePOID from vePODetail where vePODetailID = _vePODetailID; 
            update vePODetail set QuantityBilled = QuantityBilled+_QuantityBilled where vePODetailID = _vePODetailID;
            insert into veBillHistory 
			(vePOID, veBillID, vePODetailID, quantityInvoiced, invoiceAmount, entryDate, enteredBy) 
			values 
			(_vePOID,_veBillID,_vePODetailID,_QuantityBilled,_QuantityBilled*_UnitCost*IF((_PriceMultiplier IS NULL || _PriceMultiplier=0),1,_PriceMultiplier), now(),_changedByID);
            
            end if;
				 insert into veBillDetail 
				 (veBillID,vePODetailID,prMasterID,Description,Note,QuantityBilled,UnitCost,PriceMultiplier,Taxable) 
				 values
				 (_veBillID,_vePODetailID,_prMasterID,_Description,_Note,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable);
				 select count(*) into _veBilllineItemCount from veBillDetail where veBillID = _veBillID;
				 update veBill set  lineItemCount = _veBilllineItemCount where veBillID = _veBillID;
			 else
				
				update veBillDetail set prMasterID = _prMasterID,Description=_Description,Note=_Note,QuantityBilled=_QuantityBilled,UnitCost=_UnitCost,PriceMultiplier=_PriceMultiplier,Taxable=_Taxable where veBillDetailID = _veBillDetailID;
                if (_vePODetailID is not null) Then			
					select Sum(QuantityBilled) into  _orderBilled from veBillDetail where vePODetailID = _vePODetailID;
                    
					update vePODetail set QuantityBilled = _orderBilled where vePODetailID = _vePODetailID;
                    update veBillHistory set quantityInvoiced = _QuantityBilled, invoiceAmount = _QuantityBilled*_UnitCost*IF((_PriceMultiplier IS NULL || _PriceMultiplier=0),1,_PriceMultiplier) where vePODetailID = _vePODetailID and veBillID = _veBillID;
                    
				END IF;
             end if;
		END IF;
        elseif(_action = 'DELETE' and _veBillDetailID is not null) THEN 
	select vePODetailID into _vePODetailID from veBillDetail where veBillDetailID = _veBillDetailID;
    delete from veBillDetail where veBillDetailID = _veBillDetailID;
	select count(*) into _veBilllineItemCount from veBillDetail where veBillID = _veBillID;
	update veBill set  lineItemCount = _veBilllineItemCount where veBillID = _veBillID;
	
     IF (_vePODetailID is not null) THEN
 
            select Sum(QuantityBilled) into  _QuantityBilled from veBillDetailID where vePODetailID = _vePODetailID;
			
			update vePODetail set QuantityBilled =  _QuantityBilled where vePODetailID = _vePODetailID;
            delete from veBillHistory  where vePODetailID = _vePODetailID and veBillID = _veBillID;
		end if;
        call INVOICE_recalculate('VENDORINVOICE',_veBillID,0,_changedByID,null,null,null,null,null,null);
		END IF;
END$$

DELIMITER ;

-- ===================================================


DROP procedure IF EXISTS `VENDOR_updateVeBillDistribution`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `VENDOR_updateVeBillDistribution`(
	IN _action varchar(20),
	IN _veBillID INT,
	IN _veBillDistributionID INT,
	IN _coExpenseAccountID INT,
	IN _ExpenseAmount decimal(19,4),
    IN _joMasterID INT,
    IN _ecInvoicePeriodID INT,
	IN _changedByID INT
)
BEGIN
		
        if (_action = 'UPDATE') THEN 
			if (_veBillID is not null && _veBillID !=0) THEN
				if(_veBillDistributionID is null) then
					if (_coExpenseAccountID  != 0) then
						insert into veBillDistribution 
                    		(veBillID,coExpenseAccountID,ExpenseAmount,joMasterID,ecInvoicePeriodID)
                    	values
                    		(_veBillID,_coExpenseAccountID,_ExpenseAmount,_joMasterID,_ecInvoicePeriodID);
					end if;
					
				else
					update veBillDistribution set coExpenseAccountID=_coExpenseAccountID,ExpenseAmount=_ExpenseAmount,
                    joMasterID=_joMasterID,ecInvoicePeriodID=_ecInvoicePeriodID where veBillDistributionID = _veBillDistributionID;
				end if;
			end if;
		ELSEIF(_action = 'DELETE' and _veBillDistributionID is not null) THEN 
			DELETE from veBillDistribution where veBillDistributionID = _veBillDistributionID;
            call INVOICE_recalculate('VENDORINVOICEWITHOUTPO',_veBillID,0,_changedByID,null,null,null,null,null,null);
		end if;
END$$

DELIMITER ;



