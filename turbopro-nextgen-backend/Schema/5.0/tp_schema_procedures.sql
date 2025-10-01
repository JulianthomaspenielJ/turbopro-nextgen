

update tp_version set procedureVersion=58,procedureVersionDesc='Get proper single cusotmer details in reports' where versionId >0;

-- ==================================================================
-- call COMMISSION_TIER_createReport('REBUILD');
-- drop table tempTierCommissions;

DROP procedure IF EXISTS `COMMISSION_TIER_createReport`;

DELIMITER $$
CREATE PROCEDURE `COMMISSION_TIER_createReport` ( IN _action  varchar(25))
COMMISSION_TIER_createReport: BEGIN
DECLARE _tableExists varchar(255);
DECLARE _buildDay int;
DECLARE _commissionID int;
DECLARE _GetsBonus int;
DECLARE _GetsCommission int;
DECLARE _BookedProjectProfit decimal(19,4);
DECLARE _TotalCredit  decimal(19,4);
DECLARE _BonusLevel1  decimal(19,4);
DECLARE _BonusLevel2  decimal(19,4);
DECLARE _BonusComm1  decimal(19,4);
DECLARE _BonusCOmm2  decimal(19,4);
DECLARE _customerPaidDate DATETIME;
DECLARE _splitUserID INT;
DECLARE _coFiscalYearID INT;
DECLARE _CommissionableProfitToDate decimal(19,4);
DECLARE _BookedSalesCommission decimal(19,4);
DECLARE _CommissionableProfit decimal(19,4);
DECLARE _bonusUsed  decimal(19,4) default 0;

DECLARE bDone INT DEFAULT 0;
DECLARE curs CURSOR FOR 
	SELECT commissionID,GetsBonus,GetsCommission,BookedProjectProfit,TotalCredit,BonusLevel1,BonusLevel2,BonusComm1,BonusCOmm2,customerPaidDate,splitUserID,coFiscalYearID ,CommissionableProfit
	FROM tempTierCommissions where customerPaidDate is not null;
	-- SELECT commissionID,GetsBonus,GetsCommission,BookedProjectProfit,TotalCredit,BonusLevel1,BonusLevel2,BonusComm1,BonusCOmm2 FROM tempTierCommissions where customerPaidDate is not NULL;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET bDone = 1;

if (_action='REBUILD') THEN
	DROP TABLE IF EXISTS tempTierCommissions;
END IF;

if (_action='BUILD' or _action='REBUILD') THEN


	SELECT TABLE_NAME into _tableExists  FROM information_schema.tables WHERE table_name = 'tempTierCommissions' LIMIT 1;	
	if (_tableExists is NULL) THEN
	
		CREATE TABLE tempTierCommissions (
		  commissionID int auto_increment,
		  `InvoiceNumber` varchar(100) NULL,
		  `InvoiceSubtotal` decimal(19,4)  NULL default 0.000,
		  `Freight` decimal(19,4)  NULL default 0.000,
		  `BookProjectSellPrice` decimal(19,4)  NULL default 0.000,
		  `InvoiceCostStock` decimal(19,4)  NULL default 0.000,
		  `InvoiceCostDrop` decimal(19,4)  NULL default 0.000,
		  `BookedProjectProfit` decimal(19,4)  NULL default 0.000,
		  `TotalCredit` decimal(19,4)  NULL default 0.000,
		  `CommissionableProfit` decimal(19,4)  NULL default 0.000,
		  `CommissionableProfitToDate` decimal(19,4)  NULL default 0.000,
		  `bonusUsed` decimal(19,4)  NULL default 0.000,
		  `BookedSalesCommission` decimal(19,4)  NULL default 0.000,
		  `CustomerPaidDate` datetime NULL,
		  `OwnerCredit` decimal(19,4)  NULL default 0.000,
		  `EngineerCredit` decimal(19,4)  NULL default 0.000,
		  `ContractorCredit` decimal(19,4)  NULL default 0.000,
		  `GetsCommission` int default 0,
		  `GetsBonus` int default 0,
		  `splitUserID` int(11) NULL,
		  `splitUserName` varchar(100) NULL,
		  `CommPaidDate` datetime NULL,          
		  `fiscalYear` varchar(100) NULL,
		  `coFiscalYearID` INT NULL,
		  `FactoredSales` decimal(19,4)  NULL default 0.000,
		  `BonusLevel1` decimal(19,4)  NULL default 0.000,
		  `BonusComm1` decimal(19,4)  NULL default 0.000,
		  `BonusLevel2` decimal(19,4)  NULL default 0.000,
		  `BonusCOmm2` decimal(19,4)  NULL default 0.000,
		  `JobNumber` varchar(100) NULL,
		  `JobName` varchar(100) NULL,
		  `InvoiceDate` datetime NULL,
		  `createdDate` datetime not NULL default CURRENT_TIMESTAMP(),
		  PRIMARY KEY (`commissionID`),
		  INDEX `splitUserName_IDX` (splitUserName)
		) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
        
        set _buildDay = -1;
        
	ELSE
        
        -- determine if the table needs to be rebuilt
        select DATE(max(createdDate)) - DATE(now()) into _buildDay from tempTierCommissions;

        
	END IF;

        IF (_buildDay <> 0) THEN
        
			truncate table tempTierCommissions;
 
            INSERT into tempTierCommissions 
				(JobNumber, JobName, InvoiceNumber,InvoiceDate, InvoiceSubtotal,Freight,BookProjectSellPrice, InvoiceCostStock,InvoiceCostDrop,
				BookedProjectProfit, splitUserID, splitUserName,
                OwnerCredit,
                EngineerCredit,
                ContractorCredit,
                TotalCredit,
                CommissionableProfit,GetsCommission,GetsBonus,
                 FactoredSales,CustomerPaidDate,CommPaidDate,BonusLevel1,BonusComm1,BonusLevel2,BonusCOmm2,coFiscalYearID, fiscalYear)
				select 
                JobNumber, JobName, InvoiceNumber,InvoiceDate, InvoiceSubtotal,Freight,BookProjectSellPrice, InvoiceCostStock,InvoiceCostDrop,
				BookedProjectProfit, splitUserID, splitUserName,
                (case WHEN OwnerCredit is null THEN 0 ELSE OwnerCredit END) as OwnerCredit,
                (case WHEN EngineerCredit is null THEN 0 ELSE EngineerCredit END) as EngineerCredit,
                (case WHEN ContractorCredit is null THEN 0 ELSE ContractorCredit END) as ContractorCredit,
                (case WHEN TotalCredit is null THEN 0 ELSE TotalCredit END) as TotalCredit,
                CommissionableProfit,GetsCommission,GetsBonus,
                FactoredSales,CustomerPaidDate,CommPaidDate,
                (case WHEN BonusLevel1 is null THEN 0 ELSE BonusLevel1 END) as BonusLevel1,
                BonusComm1,BonusLevel2,BonusCOmm2,coFiscalYearID, fiscalYear
                from v_TIER_commission order by CustomerPaidDate ASC;

			-- select _tableExists,_buildDay, count(*) as inserted from tempTierCommissions;
            
        END IF;
        
	-- calculate toDate 
 
            OPEN curs;
            
            REPEAT
            set bDone=0;
            FETCH curs INTO _commissionID,_GetsBonus,_GetsCommission,_BookedProjectProfit,_TotalCredit,_BonusLevel1,_BonusLevel2,_BonusComm1,_BonusCOmm2, _customerPaidDate,_splitUserID,_coFiscalYearID,_CommissionableProfit ;

				if (bDone !=1) THEN
 					-- select _commissionID,_GetsBonus,_GetsCommission,_BookedProjectProfit,_TotalCredit,_BonusLevel1,_BonusLevel2,_BonusComm1,_BonusCOmm2, _customerPaidDate,_splitUserID ;
					select (case WHEN sum(CommissionableProfit) is null THEN 0 ELSE sum(CommissionableProfit) END)
                    into _CommissionableProfitToDate
						from tempTierCommissions where CustomerPaidDate is not null and CustomerPaidDate <= _customerPaidDate and splitUserID=_splitUserID and coFiscalYearID = _coFiscalYearID;
					
                    set _BookedSalesCommission = (case when _GetsBonus=1 and _GetsCommission=1 THEN

							(case when _CommissionableProfitToDate >= _BonusLevel2 THEN
								( _CommissionableProfit ) * (_BonusCOmm2/100)
								ELSE
								( _CommissionableProfit ) * (_BonusComm1/100)
							END)
                            
						ELSE
							0
						END);
 
                    set _bonusUsed = (case when _GetsBonus=1 and _GetsCommission=1 THEN

							(case when _CommissionableProfitToDate >= _BonusLevel2 THEN
								_BonusCOmm2
								ELSE
								_BonusComm1
							END)
                            
						ELSE
							0
						END);
                        
                    -- update tempTierCommissions set bounusUsed = _bonusUsed, CommissionableProfitToDate=_CommissionableProfitToDate, BookedSalesCommission=FORMAT(_BookedSalesCommission,3) where commissionID=_commissionID;
                    update tempTierCommissions set CommissionableProfitToDate=_CommissionableProfitToDate, BookedSalesCommission=_BookedSalesCommission, bonusUsed=_bonusUsed where commissionID=_commissionID;
                
                END IF;
 
            UNTIL bDone=1
            END REPEAT;
            set bDone=0;
            
            CLOSE curs;	
 
 
    -- select sum(CommissionableProfit) from tempTierCommissions where CustomerPaidDate is not NULL and CUstomerPaidDate <'2019-07-09 00:00:00' and splitUserID=224;

ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_TIER_createReport:_action must be BUILD or REBUILD';
	LEAVE COMMISSION_TIER_createReport; 
END IF;

END$$

DELIMITER ;


-- select * from tempTierCommissions where splitUserID=8;

-- SELECT * FROM EMS_Production.ecStatement where RepLoginID=8 and ecPeriodID=448;

-- select distinct(splitUserID) from tempTierCommissions;


-- ==================================================================
-- call COMMISSION_clearCommissions(null, 449);

DROP procedure IF EXISTS `COMMISSION_clearCommissions`;

DELIMITER $$
CREATE PROCEDURE `COMMISSION_clearCommissions` ( IN _action  varchar(50), IN _ecPeriodID INT)
COMMISSION_clearCommissions: BEGIN

if ( _ecPeriodID is null ) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_clearCommissions:_ecPeriodID not found';
	LEAVE COMMISSION_clearCommissions; 
END IF;

 
DELETE FROM ecInvoiceRepSplit WHERE ecStatementID IN (SELECT ecStatementID FROM ecStatement WHERE ecPeriodID = _ecPeriodID) and ecInvoiceRepSplitID >0;

UPDATE joInvoiceCost SET ecInvoicePeriodID = NULL WHERE ecInvoicePeriodID IN 
	(SELECT ecInvoicePeriodID FROM ecInvoicePeriod WHERE ecPeriodID = _ecPeriodID ) and joInvoiceCostID >0;
    
UPDATE veCommDetail SET ecInvoicePeriodID = NULL WHERE ecInvoicePeriodID IN 
	(SELECT ecInvoicePeriodID FROM ecInvoicePeriod WHERE ecPeriodID = _ecPeriodID) and veCommDetailID >0;

UPDATE veBillDistribution SET ecInvoicePeriodID = NULL WHERE ecInvoicePeriodID IN 
	(SELECT ecInvoicePeriodID FROM ecInvoicePeriod WHERE ecPeriodID = _ecPeriodID) and veBillDistributionID >0;
    
DELETE FROM ecInvoicePeriod WHERE ecPeriodID = _ecPeriodID and ecInvoicePeriodID >0;

DELETE FROM ecJobs WHERE ecStatementID IN 
	(SELECT ecStatementID FROM ecStatement WHERE ecPeriodID = _ecPeriodID) and ecJobsID >0;
    
DELETE FROM ecInvoices WHERE ecStatementID IN 
	(SELECT ecStatementID FROM ecStatement WHERE ecPeriodID = _ecPeriodID) and ecInvoicesID >0;
    
DELETE FROM ecSalesMgrOverride WHERE ecStatementID IN 
	(SELECT ecStatementID FROM ecStatement WHERE ecPeriodID = _ecPeriodID) and ecSalesMgrOverrideID >0;


END$$

DELIMITER ;

-- ==================================================================
-- call COMMISSION_TIER_updateStatement('REVERSEPERIOD', '2019-06-30 00:00:00');
-- call COMMISSION_TIER_updateStatement('NEWPERIOD', '2019-07-31 00:00:00');
-- call COMMISSION_TIER_updateStatement('RECALCULATE-ZEROOUTPAYMENTS', '2019-08-31 00:00:00');
-- call COMMISSION_TIER_updateStatement('RECALCULATE-LEAVEPAYMENTS', '2019-08-31 00:00:00');

DROP procedure IF EXISTS `COMMISSION_TIER_updateStatement`;

DELIMITER $$
CREATE PROCEDURE `COMMISSION_TIER_updateStatement` ( IN _action  varchar(100), IN _ecPeriod DATE)
COMMISSION_TIER_updateStatement: BEGIN
DECLARE _tableExists varchar(255);
DECLARE _RepLoginIDs varchar(300);
DECLARE _RepLoginID INT;
DECLARE _ecPeriodID INT;
DECLARE _ecStatementID INT;
DECLARE _OpeningBlance INT;
DECLARE _OtherCommissions INT;
DECLARE _Payment INT;
DECLARE _Adjustments INT;
DECLARE _BookedSalesCommission INT;
DECLARE _CommissionableProfit INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _maxPeriodEndingDate DATETIME;
DECLARE _periodEndDate DATE;
DECLARE _periodStartDate DATE;

if ( _action != 'REVERSEPERIOD' and _action != 'RECALCULATE-LEAVEPAYMENTS' and _action != 'RECALCULATE-ZEROOUTPAYMENTS' and _action!='NEWPERIOD' ) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_TIER_updateStatement:_action not supported';
	LEAVE COMMISSION_TIER_updateStatement; 
END IF;

	select ecPeriodID into _ecPeriodID from ecPeriod where PeriodEndingDate = _ecPeriod;


	if (_action='REVERSEPERIOD') THEN

		if ( _ecPeriodID is null ) THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_TIER_updateStatement:REVERSEPERIOD period not found';
			LEAVE COMMISSION_TIER_updateStatement; 
		END IF;

		call COMMISSION_clearCommissions(null,_ecPeriodID);

		delete from ecStatement where ecPeriodID = _ecPeriodID and ecStatementID > 0;

		delete from ecPeriod where ecPeriodID = _ecPeriodID;

	END IF;
    
    if (_action='NEWPERIOD') THEN

		if (_ecPeriodID is not null) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_TIER_updateStatement: NEWPERIOD period already exists';
			LEAVE COMMISSION_TIER_updateStatement; 
		END IF;
        
        select max(PeriodEndingDate) into _maxPeriodEndingDate from ecPeriod;
        
        if (_ecPeriod <= _maxPeriodEndingDate) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_TIER_updateStatement: NEWPERIOD must be greater than previous period';
			LEAVE COMMISSION_TIER_updateStatement; 
        END IF;
        
        insert ecPeriod (PeriodEndingDate) values (_ecPeriod);
        
        SELECT LAST_INSERT_ID() INTO _ecPeriodID;
	
    END IF;
    
    if ( LOCATE('RECALCULATE', _action)>0 or _action='NEWPERIOD') THEN
    -- if ( LOCATE('RECALCULATE', _action)>0) THEN
    

		if ( _ecPeriodID is null ) THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_TIER_updateStatement:RECALCULATE ecPeriodID not found';
			LEAVE COMMISSION_TIER_updateStatement; 
		END IF;



select date_add((select periodEndingDate from ecPeriod where ecPeriodID=_ecPeriodID), interval 24*60*60 - 1 second) as periodEndDate, 
(select periodEndingDate from ecPeriod where periodEndingDate<(select periodEndingDate 
from ecPeriod where ecPeriodID=_ecPeriodID) order by periodEndingDate desc limit 1) as periodStartDate
into _periodEndDate,_periodStartDate;

if (_periodStartDate is null) THEN set _periodStartDate=DATE('1900-01-01 00:00:00'); END IF;

		call COMMISSION_clearCommissions(null,_ecPeriodID);

		call COMMISSION_TIER_createReport('REBUILD');

		call COMMISSION_updatePayments(null, _ecPeriodID);

		if (_action ='RECALCULATE-LEAVEPAYMENTS') THEN
			set _Payment=-1;        
			set _Adjustments=-1;
		ELSEif (_action='RECALCULATE-ZEROOUTPAYMENTS') THEN
			set _Payment=0;
			set _Adjustments=0;  
		ELSE
			set _Payment=0;
			set _Adjustments=0;  
        END IF;

		-- payments left alone calculatePayment=no(set to zero for current period)  /yes(left alone)
        -- payments set to 0 
        
		select GROUP_CONCAT(distinct(splitUserID)) into _RepLoginIDs from tempTierCommissions;


				-- Looping through comma separated data

			do_this:
			LOOP
				 SET strLen = CHAR_LENGTH(_RepLoginIDs);
										
				 set _RepLoginID=SUBSTRING_INDEX(_RepLoginIDs, ',', 1);

						set _ecStatementID = null;
						set _OpeningBlance=0;
						set _OtherCommissions=0;

						-- select sum(BookedSalesCommission), sum(CommissionableProfit) into _BookedSalesCommission,_CommissionableProfit
						-- 	from tempTierCommissions where splitUserID = _RepLoginID and DATE(CustomerPaidDate)<=DATE(_ecPeriod) and CommPaidDate is null;

select sum(BookedSalesCommission), sum(CommissionableProfit) into _BookedSalesCommission,_CommissionableProfit
		from tempTierCommissions where splitUserID = _RepLoginID
		and DATE(CustomerPaidDate)>DATE(_periodStartDate) 
		and DATE(CustomerPaidDate)<=DATE(_periodEndDate) and CommPaidDate is null;

						 select ecStatementID into _ecStatementID from ecStatement where RepLoginID = _RepLoginID and ecPeriodID = _ecPeriodID;
						 
						 if (_ecStatementID is null) THEN
                         
							insert into ecStatement (ecPeriodID, RepLoginID, OpeningBalance, JobCommissions, Adjustments, Payment, Profit, ecStatementEnteredDate) value 
							(_ecPeriodID, _RepLoginID, _OpeningBlance, _BookedSalesCommission, _Adjustments, _Payment, _CommissionableProfit, now());
                            
                            SELECT LAST_INSERT_ID() INTO _ecStatementID;
                            
						 ELSE
							if (_payment=0) THEN
								update ecStatement set OpeningBalance=_OpeningBlance, JobCommissions=_BookedSalesCommission, Adjustments=_Adjustments, Payment=_Payment, Profit=_CommissionableProfit, CalculatedDate=now() where ecStatementID = _ecStatementID;
							ELSE 
								update ecStatement set OpeningBalance=_OpeningBlance, JobCommissions=_BookedSalesCommission, Profit=_CommissionableProfit, CalculatedDate=now() where ecStatementID = _ecStatementID;
                            END IF;
                         END IF;

						select (sum(JobCommissions) - sum(Payment)) into _OpeningBlance from ecStatement where RepLoginID=_RepLoginID and ecPeriodID <= _ecPeriodID;

						update ecStatement set OpeningBalance=_OpeningBlance where ecStatementID = _ecStatementID;

-- 		select _action,_ecPeriod,_ecPeriodID,_payment,_BookedSalesCommission,_CommissionableProfit,_OpeningBlance,_RepLoginIDs,_RepLoginID,_ecStatementID;

						set _ecStatementID = null;
                        
				 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_RepLoginIDs, ',', 1))+2;
				 SET _RepLoginIDs = MID(_RepLoginIDs, SubStrLen, strLen);

				 IF _RepLoginIDs = '' or _RepLoginIDs is null THEN
				   LEAVE do_this;
				 END IF;
                 
			END LOOP do_this;
            
    
    END IF;

END$$

DELIMITER ;

-- ==================================================================
-- call COMMISSION_updatePayments(null, 448);

DROP procedure IF EXISTS `COMMISSION_updatePayments`;

DELIMITER $$
CREATE PROCEDURE `COMMISSION_updatePayments` ( IN _action  varchar(50), IN _ecPeriodID INT)
COMMISSION_updatePayments: BEGIN

# variables
DECLARE v_done INT DEFAULT FALSE;

DECLARE _RecordType varchar(25);
DECLARE _CustomerStatus varchar(25);
DECLARE _IsCommPaid varchar(25);
DECLARE _cuInvoiceId INT;
DECLARE _CommAvailableDate DATETIME;
DECLARE _InvoiceNumber varchar (100);
DECLARE _joReleaseType INT;
DECLARE _info_rxCustomerID INT;
DECLARE _InvoiceAmount DOUBLE;
DECLARE _appliedAmount DOUBLE;
DECLARE _CommPercent DOUBLE;
DECLARE _AmountDue DOUBLE;
DECLARE _info_userLoginID INT;
DECLARE _PayType INT;
DECLARE _StatementID INT;
DECLARE _Info_ReleasedetailID INT;
DECLARE _CalcRevShare DOUBLE;
DECLARE _info_joReleaseID INT;
DECLARE _joMasterID INT;
DECLARE _info_veCommDetailID INT;
DECLARE _veBillID INT;
DECLARE _ecType varchar(10);
DECLARE _periodStartDate DATETIME;
DECLARE _periodEndDate DATETIME;
DECLARE _ecInvoicePeriodID INT;

#cursors
DECLARE cursorForCommission CURSOR FOR 
SELECT RecordType,CustomerStatus,IsCommPaid,info_cuInvoiceID,CommAvailableDate,InvoiceNumber,
				CAST(ReleaseTypes AS SIGNED) as joReleaseType,info_rxCustomerID,InvoiceAmount,CAST(CalcRawInvoiceProfit AS DECIMAL(19,4)) as appliedAmount,CommPercent,
				CAST(CalcSplitRev AS DECIMAL(19,4)) AS AmountDue,
				info_userLoginID, (SELECT CommAfterPayment FROM emMaster WHERE UserLoginID = info_userLoginID LIMIT 1) AS PayType,
				login.StatementID,Info_ReleasedetailID,CAST(CalcRevShare AS DECIMAL(19,4)),info_joReleaseID, joMasterID, 
				 info_veCommDetailID, veBillID 
                 FROM SalesCommissionView scv 
                 LEFT JOIN (SELECT ecstm.repLoginID AS repid,ecstm.ecStatementID 
				AS StatementID FROM  ecStatement ecstm WHERE ecstm.ecPeriodID =  _ecPeriodID ) AS login ON 
				login.repid = scv.info_userLoginID 
                WHERE isCommPaid='no'  
                AND CommAvailableDate >= _periodStartDate 
                AND CommAvailableDate <= _periodEndDate;

#handlers
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
    SELECT 'ROLLBACK';
  END;  

if ( _ecPeriodID is null ) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_updatePayments:_ecPeriodID not found';
	LEAVE COMMISSION_updatePayments; 
END IF;


select date_add((select periodEndingDate from ecPeriod where ecPeriodID=_ecPeriodID), interval 24*60*60 - 1 second) as periodEndDate, 
(select periodEndingDate from ecPeriod where periodEndingDate<(select periodEndingDate 
from ecPeriod where ecPeriodID=_ecPeriodID) order by periodEndingDate desc limit 1) as periodStartDate
into _periodEndDate,_periodStartDate;

select _ecPeriodID,_periodStartDate, _periodEndDate;

  OPEN cursorForCommission;
  
  START TRANSACTION;

  read_loop: LOOP
  
    FETCH cursorForCommission INTO _RecordType,_CustomerStatus,_IsCommPaid,_cuInvoiceId,_CommAvailableDate,_InvoiceNumber,
                 _joReleaseType,_info_rxCustomerID,_InvoiceAmount, _appliedAmount,  _CommPercent,
                 _AmountDue,
                 _info_userLoginID, _PayType, _StatementID, _Info_ReleasedetailID, _CalcRevShare, _info_joReleaseID, _joMasterID,
                 _info_veCommDetailID, _veBillID;
                 
					if (_RecordType='Invoice') THEN
						set _ecType='I';
  						set _joMasterID=null;
 						set _veBillID=null;
                   ELSEIF (_RecordType='AddCost') THEN
						set _ecType='A';
 						set _joMasterID=null;
 						set _veBillID=null;
					ELSEIF (_RecordType='VendorComm') THEN
						set _ecType='V';
 						set _joMasterID=null;
 						set _veBillID=null;
					ELSEIF (_RecordType='VendorExpense') THEN
						set _ecType='VE';
                    END IF;


    IF v_done THEN
      LEAVE read_loop;
    END IF;

-- select v_done,_RecordType,_CustomerStatus,_IsCommPaid,_cuInvoiceId,_CommAvailableDate,_InvoiceNumber,
--                 _joReleaseType,_info_rxCustomerID,_InvoiceAmount, _appliedAmount,  _CommPercent,
--                 _AmountDue,
--                 _info_userLoginID, _PayType, _StatementID, _Info_ReleasedetailID, _CalcRevShare, _info_joReleaseID, _joMasterID,
--                 _info_veCommDetailID, _veBillID,_ecType;
                 


	INSERT IGNORE ecInvoicePeriod (cuInvoiceID,ecPeriodID,Modified,rxCustomerID,ReleaseType,Reference,DatePaid,Sales,Profit,
    joReleaseID,cuTrueInvoiceID,ExpjoMasterID,ExprxMasterID,enteredDate,ecType)
    values (_cuInvoiceId,_ecPeriodID,true,_info_rxCustomerID,_joReleaseType,_InvoiceNumber,DATE(_periodEndDate),_InvoiceAmount,_appliedAmount,
    _info_joReleaseID,null,_joMasterID,_joMasterID,now(),_ecType);
    
	SELECT LAST_INSERT_ID() INTO _ecInvoicePeriodID;

    INSERT IGNORE ecInvoiceRepSplit (ecInvoicePeriodID,ecStatementID,Profit,CommissionRate,AmountDue) 
    VALUES (_ecInvoicePeriodID,_StatementID,_appliedAmount,_CommPercent,_InvoiceAmount);
    
					IF (_RecordType='AddCost') THEN
                    
                    UPDATE joInvoiceCost SET ecInvoicePeriodID =_ecInvoicePeriodID WHERE joReleaseDetailID=_Info_ReleasedetailID
                    AND enteredDate <= _periodEndDate AND ecInvoicePeriodID IS NULL AND joInvoiceCostID>0;
                    
					ELSEIF (_RecordType='VendorComm') THEN
                    
                    UPDATE veCommDetail SET ecInvoicePeriodID =_ecInvoicePeriodID WHERE joReleaseDetailID=_Info_ReleasedetailID 
                    AND ShipDate <= _periodEndDate AND ecInvoicePeriodID IS NULL AND veCommDetailID>0;
                
					ELSEIF (_RecordType='VendorExpense') THEN
                    
                    UPDATE veBillDistribution vBD LEFT JOIN 
                    (SELECT ecInvoicePeriodID, vBD.veBillDistributionID,vB.BillDate FROM veBillDistribution vBD
					LEFT JOIN veBill vB ON vB.veBillId = vBD.veBillId WHERE vBD.veBillDistributionID = _veBillID 
                    AND vB.BillDate >= _periodStartDate AND vB.BillDate <= _periodStartDate 
                    AND vBD.ecInvoicePeriodID IS NULL) d  ON d.veBillDistributionID = vBD.veBillDistributionID 
                    SET vBD.ecInvoicePeriodID = _ecInvoicePeriodID WHERE vBD.veBillDistributionID = _veBillID 
                    AND d.BillDate >= _periodStartDate AND d.BillDate <= _periodEndDate AND vBD.ecInvoicePeriodID IS NULL
                    AND veBillDistributionID>0;
                
                    END IF;

	  END LOOP;
	  
	  COMMIT; 
	  CLOSE cursorForCommission;


END$$

DELIMITER ;


-- ==================================================================
-- call COMMISSION_strategy(null);

DROP procedure IF EXISTS `COMMISSION_strategy`;

DELIMITER $$
CREATE PROCEDURE `COMMISSION_strategy` ( IN _action  varchar(50) )
COMMISSION_strategy: BEGIN

select (CASE 
	WHEN max(GetsBonus)=1 THEN 'TIERED'
	WHEN max(GetsBonus)=0 THEN 'JOBCOMMISSION'
    END) as commissionStrategy
    from emMaster;


END$$

DELIMITER ;

-- ======================================
-- call COMMISSION_TIER_getCalculations(null, 8, '2019-10-31 00:00:00');


DROP procedure IF EXISTS `COMMISSION_TIER_getCalculations`;

DELIMITER $$
CREATE PROCEDURE COMMISSION_TIER_getCalculations (
IN _action varchar(20),
IN _userId INT,
IN _ecPeriod DATE
)
COMMISSION_TIER_getCalculations: BEGIN
DECLARE _ecPeriodID INT;
DECLARE _periodEndDate DATE;
DECLARE _periodStartDate DATE;
 
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call COMMISSION_TIER_getCalculations:_userId not given';
	LEAVE COMMISSION_TIER_getCalculations; 
END IF;
if ( _ecPeriod is null) THEN 
    SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'call COMMISSION_TIER_getCalculations:_ecPeriod not given';
	LEAVE COMMISSION_TIER_getCalculations; 
END IF;

select ecPeriodID into _ecPeriodID from ecPeriod where PeriodEndingDate = _ecPeriod;
if ( _ecPeriodID is null) THEN 
    SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'call COMMISSION_TIER_getCalculations:ecPeriodID not found';
	LEAVE COMMISSION_TIER_getCalculations; 
END IF;


select date_add((select periodEndingDate from ecPeriod where ecPeriodID=_ecPeriodID), interval 24*60*60 - 1 second) as periodEndDate, 
(select periodEndingDate from ecPeriod where periodEndingDate<(select periodEndingDate 
from ecPeriod where ecPeriodID=_ecPeriodID) order by periodEndingDate desc limit 1) as periodStartDate
into _periodEndDate,_periodStartDate;

if (_periodStartDate is null) THEN set _periodStartDate=DATE('1900-01-01 00:00:00'); END IF;


-- select _ecPeriod,_periodStartDate,_periodEndDate,_userId;

call COMMISSION_TIER_createReport('BUILD');

SELECT * FROM tempTierCommissions where splitUserID=_userId
		and DATE(CustomerPaidDate)>DATE(_periodStartDate) 
		and DATE(CustomerPaidDate)<=DATE(_periodEndDate)  order by customerPaidDate;



END$$

DELIMITER ;


-- ==================================

-- call getPicklist('WAREHOUSE');
-- call getPicklist('DEPARTMENT');
-- call getPicklist('CATEGORY');

DROP procedure IF EXISTS `getPicklist`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `getPicklist`( IN _type  varchar(25))
BEGIN

if (_type='WAREHOUSE') THEN
	select distinct(prWarehouseID) as id, _type as obj, Description as name, null as Value, 1 as orderBy, 0 as isDefault from prWarehouse where InActive=0 order by Description;
ELSEif (_type='DEPARTMENT') THEN
	select prDepartmentID as id, _type as obj, Description as name, null as Value, 1 as orderBy, 0 as isDefault from prDepartment where InActive=0 order by Description;
ELSEif (_type='CATEGORY') THEN
	select prCategoryID as id, _type as obj, Description as name, null as Value, 1 as orderBy, 0 as isDefault from prCategory where InActive=0 order by Description;
Elseif(_type = 'DIVISION') THEN
	select coDivisionID as id, _type as obj, Description as name, null as Value, 1 as orderBy, 0 as isDefault from coDivision where InActive=0 order by Description;
ELSEif(_type = 'FASCIALPERIODSMONTH') THEN
	select coFiscalPeriodID as id, _type as obj, EndDate as name , StartDate as Value, 1 as orderBy, 0 as isDefault from coFiscalPeriod  group by EndDate order by EndDate desc;
ELSEif(_type = 'FASCIALPERIODSYEAR') THEN
	select cfp.coFiscalPeriodID as id, _type as obj, cfp.EndDate as name , cfy.StartDate as Value, 1 as orderBy, 0 as isDefault from coFiscalPeriod cfp
    left join coFiscalYear cfy on (cfp.coFiscalYearID = cfy.coFiscalYearID)
    group by cfp.EndDate order by cfp.EndDate desc; 
ELSEif(_type = "ITEMCODE") THEN
	select prMasterID as id, _type as obj, ItemCode as name, null as Value, 1 as orderBy, 0 as isDefault from prMaster where InActive=0  order by ItemCode;
ELSEif(_type="VENDORS") THEN
	select rx.rxMasterID as id, rx.Name as name, null as Value, 1 as orderBy, 0 as isDefault from rxMaster rx
	left join prMaster pr on pr.rxMasterIDPrimaryVendor = rx.rxMasterID
	where rx.InActive=0 and pr.prMasterID is not null order by Name;
END IF;

END$$

DELIMITER ;




-- ==================================


-- ============================================================
-- call TP_jobRelease_controller('ADD',1,722,1,now(),54,22.22,1,'vepo ReleaseNote','PO1234',@out);
-- call TP_jobRelease_controller('ADD',1,722,2,now(),null,11.11,1,'ReleaseNote','PO1234',@out);

/*
			@RequestParam(value = "ReleasesName", required = false) Date theReleaseDate,
			@RequestParam(value = "joReleaseName", required = false) Integer theJoreleaseId,
			@RequestParam(value = "joReleaseDetailName", required = false) Integer theJoreleaseDetailId,
			@RequestParam(value = "vePoName", required = false) Integer thevePoId,
			@RequestParam(value = "cuSOID", required = false) Integer thecuSOID,
			@RequestParam(value = "ReleasesTypeName", required = false) Integer theReleaseType,
			@RequestParam(value = "ManufacturerId", required = false) Integer theManuId,
			@RequestParam(value = "ReleasesManuName", required = false) String theManuName,
			@RequestParam(value = "NoteName", required = false) String theNote,
			@RequestParam(value = "AllocatedName", required = false) BigDecimal theAllocatedName,
			@RequestParam(value = "POAmountName", required = false) BigDecimal thePOAmount,
			@RequestParam(value = "ReleasesInvoiceName", required = false) BigDecimal theReleaseInvoiceName,
			@RequestParam(value = "joMasterID", required = false) Integer theJoMasterID,
			@RequestParam(value = "oper", required = false) String theOperation,
			@RequestParam(value = "custPONumber", required = false) String thecustPONumber,
			@RequestParam(value = "jobNumber", required = false) String theJobNumber,
			@RequestParam(value = "rxMasterID", required = false) Integer theRxMasterID,
			@RequestParam(value = "veFactoryId", required = false) Integer theFActoryID,
			@RequestParam(value = "customerPONumberName", required = false) String theCustomerPONumber,
			@RequestParam(value = "divisionId", required = false) Integer coDivisionId,
			@RequestParam(value = "grTaxRateApplied", required = false) Integer grTaxRateApplied, HttpSession session,

*/


DROP procedure IF EXISTS `TP_jobRelease_controller`;

DELIMITER $$
CREATE PROCEDURE TP_jobRelease_controller (
IN _action varchar(20),
IN _userId INT,
IN _joMasterID INT,
IN _releaseType INT, -- releaseTypeName as legacy name
IN _releaseDate DATE,
IN _rxVendorId INT, -- manufacturerId
IN _estimatedBilling DOUBLE, -- Allocated
IN _GRTaxRate INT,
IN _ReleaseNote VARCHAR(2000),
IN _CustomerPONumber varchar(100),
OUT _idUpdated INT
)
TP_jobRelease_controller: BEGIN

DECLARE _shipToMode INT;
DECLARE _shiptTo INT;
DECLARE _transactionStatus INT;
DECLARE _cuTermsID INT;
DECLARE _ShipDate DATE;


if ( _action != 'ADD' and _action != 'DELETE') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_jobRelease_controller:_action must be UPDATE/DELTE';
	LEAVE TP_jobRelease_controller; 
END IF;
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_jobRelease_controller:_userId not given';
	LEAVE TP_jobRelease_controller; 
END IF;


if (_action = 'ADD') THEN

	-- DROPSHIP or -- Commission
	if (_releaseType = 1 or _releaseType = 4) THEN

        -- aVepo.setShipTo(0);
		-- aVepo.setTransactionStatus(1);
        
        -- joRelease
		-- vePO

        -- _manufacturerId  -- rxVendorId
        set _transactionStatus=1;
		set _shipToMode = 2;
        
        call TP_joRelease_update('UPDATE',_userId,null,_joMasterID,_releaseType,_ReleaseDate,_estimatedBilling,_ReleaseNote,null,null,null,null,_CustomerPONumber,null,0,null,_GRTaxRate,@joReleaseId);
		
		call TP_vePO_update('UPDATE',_userId,null,_transactionStatus,@joReleaseId,_rxVendorID,null,null,null,null,null,null,null,_shipToMode,null,null,_CustomerPONumber,null,
			null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,@id);

		-- select _userId,_joMasterID,_releaseType,_ReleaseDate,_estimatedBilling,_rxVendorId,@joReleaseId,@id;
        
        set _idUpdated = @id;
        
	-- Stock Order or  -- Service
	ELSEif (_releaseType = 2 or _releaseType = 5) THEN
	
        -- aCuSO.setShipToMode(2);
		-- aCuSO.setTransactionStatus(1);
		set _shipToMode = 2;
        set _transactionStatus =1;
        set _cuTermsID=1;
        set _ShipDate = DATE(now());
		if (_ReleaseDate is null) THEN set _ReleaseDate = DATE(now()); END IF;

        call TP_joRelease_update('UPDATE',_userId,null,_joMasterID,_releaseType,_ReleaseDate,_estimatedBilling,_ReleaseNote,null,null,null,null,_CustomerPONumber,null,0,null,_GRTaxRate,@joReleaseId);
		
        call TP_cuSO_update('UPDATE',_userId,null,_transactionStatus,@joReleaseId,null,null,null,null,null,null,_cuTermsID, _shipToMode ,null,null,null,null,null,_ShipDate,null,null,null,null,null,0,0,@id);

		-- select _userId,_joMasterID,_releaseType,_ReleaseDate,_estimatedBilling,_rxVendorId,@joReleaseId,@id;

        set _idUpdated = @id;
        
    -- Bill Only
	ELSEif (_releaseType = 3) THEN

		-- nothing
		SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'call TP_jobRelease_controller: releaseType=3(BILL) not supported';
		LEAVE TP_jobRelease_controller; 
 
	ELSE 
		SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'call TP_jobRelease_controller:_releaseType not correct';
		LEAVE TP_jobRelease_controller; 
    END IF;
    
 
elseif  (_action = 'DELETE') THEN

		SIGNAL SQLSTATE '45006' SET MESSAGE_TEXT = 'call TP_jobRelease_controller: DELETE not reported';
		LEAVE TP_jobRelease_controller; 

END IF;

set _idUpdated = @id;

END$$

DELIMITER ;




-- ============================================================
-- call TP_cuSO_update('UPDATE',1,null,2,477,1,1,1,1,1,1,1,1,1,1,1,'CUSTPONUMBER',DATE(now()),DATE(now()),1,1,1,1,1,0,0,@out);
-- call TP_cuSO_update('UPDATE',1,175,2,112,1,1,1,1,1,1,1,1,1,1,1,'CUSTPONUMBER',DATE(now()),DATE(now()),1,1,1,1,1,0,0,@out);

DROP procedure IF EXISTS `TP_cuSO_update`;

DELIMITER $$
CREATE PROCEDURE TP_cuSO_update (
IN _action varchar(20),
IN _userId INT,
IN _cuSOID INT,
IN _TransactionStatus INT,
IN _joReleaseID INT, 
IN _rxCustomerID INT,
IN _rxBillToID INT,
IN _rxShipToID INT,
IN _veShipViaID INT,
IN _prFromWarehouseID INT,
IN _prToWarehouseID INT,
IN _cuTermsID INT,
IN _ShipToMode INT,
IN _coTaxTerritoryID INT,
IN _coDivisionID INT,
IN _rxContactID INT,
-- IN _SONumber VARCHAR(200),
IN _CustomerPONumber VARCHAR(200),
IN _DatePromised DATE,
IN _ShipDate DATE,
IN _cuAssignmentID0 INT,
IN _cuAssignmentID1 INT,
IN _cuAssignmentID2 INT,
IN _cuAssignmentID3 INT,
IN _cuAssignmentID4 INT,
-- IN _Tag VARCHAR(200),
IN _taxfreight INT,
IN _Freight DOUBLE,
OUT _idUpdated INT
)
TP_cuSO_update: BEGIN

DECLARE commaNeeded INT DEFAULT 0;

DECLARE _TaxRate DOUBLE DEFAULT 0; 
DECLARE _CostTotal DOUBLE DEFAULT 0;-- pulled in 
DECLARE _SubTotal DOUBLE DEFAULT 0; -- calculated from lines
DECLARE _TaxTotal DOUBLE DEFAULT 0; -- calc from taxTerritory * SubTotal * (possibly)freight(taxFree)
-- DECLARE _whseCostTotal DOUBLE DEFAULT 0; -- = CostTotal
DECLARE _TaxableSales DOUBLE DEFAULT 0;
DECLARE _NonTaxableSales DOUBLE DEFAULT 0;
DECLARE _Tag VARCHAR(200);
DECLARE _JobNumber VARCHAR(200);
DECLARE _joMasterID INT;

if ( _action != 'UPDATE' and _action != 'DELETE') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_cuSO_update:_action must be UPDATE/DELTE';
	LEAVE TP_cuSO_update; 
END IF;
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_cuSO_update:_userId not given';
	LEAVE TP_cuSO_update; 
END IF;


if (_cuSOId <1) THEN set _cuSOId=null; END IF;
if (_coDivisionID is null) then set _coDivisionID = -1; END IF;

-- pending
if (_action = 'UPDATE') THEN

	-- update record
	if (_cuSOId is not null) THEN
    
		set  @l_sql ='update cuSO set ';
 
/*
		if (_TransactionStatus is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' TransactionStatus =', _TransactionStatus); 
			set commaNeeded =1;
        END IF;
		if (_joReleaseID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' joReleaseID =', _joReleaseID); 
			set commaNeeded =1;
        END IF;
*/
		if (_rxCustomerID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' rxCustomerID =', _rxCustomerID); 
			set commaNeeded =1;
        END IF;		
        if (_rxBillToID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' rxBillToID =', _rxBillToID); 
			set commaNeeded =1;
        END IF;		
        if (_rxShipToID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' rxShipToID =', _rxShipToID); 
			set commaNeeded =1;
        END IF;		
        if (_veShipViaID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' veShipViaID =', _veShipViaID); 
			set commaNeeded =1;
        END IF;		
        if (_prFromWarehouseID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' prFromWarehouseID =', _prFromWarehouseID); 
			set commaNeeded =1;
        END IF;		
        if (_prToWarehouseID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' prToWarehouseID =', _prToWarehouseID); 
			set commaNeeded =1;
        END IF;		
        if (_cuTermsID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' cuTermsID =', _cuTermsID); 
			set commaNeeded =1;
        END IF;		
        if (_ShipToMode is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' ShipToMode =', _ShipToMode); 
			set commaNeeded =1;
        END IF;		
        if (_coTaxTerritoryID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' coTaxTerritoryID =', _coTaxTerritoryID); 
			set commaNeeded =1;
        END IF;		
        if (_coDivisionID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' coDivisionID =', _coDivisionID); 
			set commaNeeded =1;
        END IF;		
        if (_rxContactID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' rxContactID =', _rxContactID); 
			set commaNeeded =1;
        END IF;
        
--         if (_SONumber is not null) THEN 
-- 			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
-- 			set @l_sql = CONCAT(@l_sql,' SONumber =\'', _SONumber,'\''); 
-- 			set commaNeeded =1;
--        END IF;
         if (_CustomerPONumber is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' CustomerPONumber =\'', TRIM(_CustomerPONumber),'\''); 
			set commaNeeded =1;
        END IF;

         if (_DatePromised is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,' DatePromised =\'', DATE(_DatePromised),'\''); 
			set commaNeeded =1;
        END IF;
         if (_ShipDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,' ShipDate =\'', DATE(_ShipDate),'\''); 
			set commaNeeded =1;
        END IF;

        if (_cuAssignmentID0 is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' cuAssignmentID0 =', _cuAssignmentID0); 
			set commaNeeded =1;
        END IF;
        if (_cuAssignmentID1 is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' cuAssignmentID1 =', _cuAssignmentID1); 
			set commaNeeded =1;
        END IF;
        if (_cuAssignmentID2 is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' cuAssignmentID2 =', _cuAssignmentID2); 
			set commaNeeded =1;
        END IF;
        if (_cuAssignmentID3 is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' cuAssignmentID3 =', _cuAssignmentID3); 
			set commaNeeded =1;
        END IF;
        if (_cuAssignmentID4 is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' cuAssignmentID4 =', _cuAssignmentID4); 
			set commaNeeded =1;
        END IF;

--         if (_Tag is not null) THEN 
-- 			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
-- 			set @l_sql = CONCAT(@l_sql,' Tag =\'', _Tag,'\''); 
-- 			set commaNeeded =1;
--        END IF;

        if (_taxfreight is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' taxfreight =', _taxfreight); 
			set commaNeeded =1;
        END IF;		
        if (_Freight is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,' Freight =', _Freight); 
			set commaNeeded =1;
        END IF;		


		IF (commaNeeded>0) THEN
        
        	set @l_sql = CONCAT(@l_sql,',changedOn =\'', now(),'\''); 
			set @l_sql = CONCAT(@l_sql,',ChangedByID =', _userId); 
			set @l_sql = CONCAT(@l_sql,' where cuSOID=', _cuSOId); 

			select @l_sql;
				
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		
            
        END IF;
        
        -- update totals:
		call TP_CalculateTotals (_cuSOId,null,@idUpdated);
        
        set _idUpdated = _cuSOID;
        
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_cuSO_update',_cuSOId);
    
    -- insert
    ELSE
 

        -- for inside job, the joReleaseId will not be null.
		if ( _joReleaseID is not null) THEN 
			select 
            m.description, m.joMasterID, 
            m.coDivisionID, m.rxCustomerID, m.rxCustomerID,
			m.cuAssignmentID0,m.cuAssignmentID1,m.cuAssignmentID2,m.cuAssignmentID3,m.cuAssignmentID4,
			m.coTaxTerritoryID,1,r.POID
            into 
            _Tag, _joMasterID,
			_coDivisionID,_rxCustomerID,_rxBillToID,
			_cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3,_cuAssignmentID4,
			_coTaxTerritoryID,_prFromWarehouseID,_CustomerPONumber            
            from joRelease r left join joMaster m on (m.joMasterID = r.joMasterID) where r.joReleaseID = _joReleaseID limit 1;


		END IF;

		call TP_GenerateName ('cuSO',_joMasterID,@SONumber);
 
		select taxfreight into _taxfreight from coTaxTerritory where coTaxTerritoryID = _coTaxTerritoryID;        

		insert cuSO (TransactionStatus,joReleaseID ,rxCustomerID,rxBillToID,rxShipToID,veShipViaID,prFromWarehouseID
		,prToWarehouseID,cuTermsID,ShipToMode
		,coTaxTerritoryID,coDivisionID,rxContactID
		,SONumber,CustomerPONumber,DatePromised,ShipDate,cuAssignmentID0,cuAssignmentID1,cuAssignmentID2,cuAssignmentID3
		,cuAssignmentID4,Tag,taxfreight
        ,Freight,CostTotal,SubTotal,TaxTotal,whseCostTotal,TaxableSales,NonTaxableSales
        ,CreatedByID,CreatedOn,CreatedDate)
		values (
		_TransactionStatus,_joReleaseID ,_rxCustomerID,_rxBillToID,_rxShipToID,_veShipViaID,_prFromWarehouseID
		,_prToWarehouseID,_cuTermsID,_ShipToMode
		,_coTaxTerritoryID,_coDivisionID,_rxContactID
		,@SONumber,TRIM(_CustomerPONumber),_DatePromised,_ShipDate,_cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3
		,_cuAssignmentID4,_Tag,_taxfreight
        ,_Freight,_CostTotal,_SubTotal,_TaxTotal,_CostTotal,_TaxableSales,_NonTaxableSales
        ,_userId,now(),now());

		SELECT LAST_INSERT_ID() INTO _idUpdated;

		set _cuSOId = _idUpdated;
        
		call TP_tpUsage_insert (_userId,'INSERT','Info','TP_cuSO_update',_cuSOId);
	
    END IF;
    
elseif  (_action = 'DELETE') THEN

	-- need to delete everything that has a cuSOID;
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'call TP_cuSO_update: DELETE NOT SUPPORTED';
	LEAVE TP_cuSO_update;     

END IF;

END$$

DELIMITER ;





-- ============================================================
-- call TP_cuSODetail_update('UPDATE',1,175,null,1,'description,'note',1,1,22,34,1,1,33,1,@out);
-- call TP_cuSODetail_update('UPDATE',1,175,null,1,'description,'note',1,1,22,34,1,1,33,1,@out);

DROP procedure IF EXISTS `TP_cuSODetail_update`;

DELIMITER $$
CREATE PROCEDURE TP_cuSODetail_update (
IN _action varchar(20),
IN _userId INT,
IN _cuSOID INT,
IN _cuSODetailID INT,
IN _prMasterID INT, 
IN _Description VARCHAR(1000),
IN _Note VARCHAR(1000),
IN _QuantityOrdered INT,
IN _QuantityBilled INT,
IN _UnitCost DOUBLE,
IN _UnitPrice DOUBLE,
IN _PriceMultiplier DOUBLE,
IN _Taxable INT,
IN _whseCost DOUBLE,
IN _position INT,
OUT _idUpdated INT
)
TP_cuSODetail_update: BEGIN

DECLARE commaNeeded INT DEFAULT 0;

if ( _action != 'UPDATE' and _action != 'DELETE') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_cuSODetail_update:_action must be UPDATE/DELTE';
	LEAVE TP_cuSODetail_update; 
END IF;
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_cuSODetail_update:_userId not given';
	LEAVE TP_cuSODetail_update; 
END IF;


if (_cuSODetailID <1) THEN set _cuSODetailID=null; END IF;

if (_action = 'UPDATE') THEN

	-- update record
	if (_cuSODetailID is not null) THEN
    
		set  @l_sql ='update cuSODetail set ';
 
		if (_prMasterID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'prMasterID =', _prMasterID); 
			set commaNeeded =1;
        END IF;
		if (_QuantityOrdered is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'QuantityOrdered =', _QuantityOrdered); 
			set commaNeeded =1;
        END IF;

		if (_QuantityBilled is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'QuantityBilled =', _QuantityBilled); 
			set commaNeeded =1;
        END IF;		
        if (_UnitCost is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'UnitCost =', _UnitCost); 
			set commaNeeded =1;
        END IF;		
        if (_UnitPrice is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'UnitPrice =', _UnitPrice); 
			set commaNeeded =1;
        END IF;		
        if (_PriceMultiplier is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'PriceMultiplier =', _PriceMultiplier); 
			set commaNeeded =1;
        END IF;		
        if (_Taxable is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Taxable =', _Taxable); 
			set commaNeeded =1;
        END IF;		
        if (_whseCost is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'whseCost =', _whseCost); 
			set commaNeeded =1;
        END IF;		
        if (_position is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'position =', _position); 
			set commaNeeded =1;
        END IF;	
          if (_Description is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Description =\'', _Description,'\''); 
			set commaNeeded =1;
        END IF;
         if (_Note is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Note =\'', _Note,'\''); 
			set commaNeeded =1;
        END IF;

		IF (commaNeeded>0) THEN
        
			set @l_sql = CONCAT(@l_sql,' where cuSODetailID=', _cuSODetailID); 

			select @l_sql;
				
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		
            
        END IF;
                
        set _idUpdated = _cuSODetailID;
        
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_cuSO_update',_cuSODetailID);
    
    -- insert
    ELSE

		if ( _cuSOID is null) THEN 
			SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'call TP_cuSODetail_update:_cuSOID not given for insert';
			LEAVE TP_cuSODetail_update; 
		END IF;
		
        select count(*)+1 into _position from cuSODetail where cuSOID=_cuSOID;
        
		insert cuSODetail (cuSOID ,prMasterID,Description,Note,QuantityOrdered,QuantityBilled
		,UnitCost,UnitPrice,PriceMultiplier,Taxable,whseCost,position)
		values (
		_cuSOID ,_prMasterID,_Description,_Note,_QuantityOrdered,_QuantityBilled
		,_UnitCost,_UnitPrice,_PriceMultiplier,_Taxable,_whseCost,_position);

		SELECT LAST_INSERT_ID() INTO _idUpdated;

		set _cuSODetailID = _idUpdated;
        
		call TP_tpUsage_insert (_userId,'INSERT','Info','TP_cuSODetail_update',_cuSODetailID);
	
    END IF;
    
   call TP_CalculateTotals (_cuSOId,null,@idUpdated);

elseif  (_action = 'DELETE') THEN

	if ( _cuSODetailID is null) THEN 
		SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'call TP_cuSODetail_update:_cuSODetailID not given';
		LEAVE TP_cuSODetail_update; 
	END IF;


	select cuSOID into _cuSOID from cuSODetail where cuSODetailID = _cuSODetailID;
	
    if (_cuSOID is not null) THEN
		delete from cuSODetail where cuSODetailID = _cuSODetailID;
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_cuSO_update',_cuSOId);
	END IF;

   call TP_CalculateTotals (_cuSOId,null,@idUpdated);

END IF;

END$$

DELIMITER ;



-- ============================================================
-- call TP_joRelease_update('UPDATE',1,null,477,2,'2019-09-11 00:00:00',0,'note',0,null,0,0,'poid','bill',0,null,null,@out);
-- call TP_joRelease_update('UPDATE',1,478,477,2,'2019-09-11 00:00:00',0,'note2',0,null,0,0,'poid2','bill',0,null,null,@out);

DROP procedure IF EXISTS `TP_joRelease_update`;

DELIMITER $$
CREATE PROCEDURE TP_joRelease_update (
IN _action varchar(20),
IN _userId INT,
IN _joReleaseID INT,
IN _joMasterID INT,
IN _ReleaseType INT, 
IN _ReleaseDate DATE,
IN _EstimatedBilling DOUBLE,
IN _ReleaseNote varchar(1000),
IN _CommissionReceived INT,
IN _CommissionDate DATE,
IN _CommissionAmount DOUBLE,
IN _Cancelled INT,
IN _POID varchar(100),
IN _BillNote varchar(5000),
IN _release_status INT,
IN _coDivisionID INT,
IN _grTaxRate DOUBLE,
OUT _idUpdated INT
)
TP_joRelease_update: BEGIN
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _seq_Number INT DEFAULT 0;

if ( _action != 'UPDATE' and _action != 'DELETE') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_joRelease_update:_action must be UPDATE/DELTE';
	LEAVE TP_joRelease_update; 
END IF;
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_joRelease_update:_userId not given';
	LEAVE TP_joRelease_update; 
END IF;


if (_joReleaseID <1) THEN set _joReleaseID=null; END IF;

-- pending
if (_action = 'UPDATE') THEN

	-- update record
	if (_joReleaseID is not null) THEN
    
		set  @l_sql ='update joRelease set ';
 
		if (_ReleaseType is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'ReleaseType =', _ReleaseType); 
			set commaNeeded =1;
        END IF;
		if (_ReleaseDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'ReleaseDate =\'',DATE(_ReleaseDate),'\''); 
			set commaNeeded =1;
        END IF;
		if (_CommissionDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'CommissionDate =\'',DATE(_CommissionDate),'\''); 
			set commaNeeded =1;
        END IF;

		if (_CommissionAmount is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'CommissionAmount =', _CommissionAmount); 
			set commaNeeded =1;
        END IF;		

		if (_EstimatedBilling is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'EstimatedBilling =', _EstimatedBilling); 
			set commaNeeded =1;
        END IF;		
        if (_ReleaseNote is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'ReleaseNote =\'', TRIM(_ReleaseNote),'\''); 
			set commaNeeded =1;
        END IF;		
        if (_CommissionReceived is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'CommissionReceived =', _CommissionReceived); 
			set commaNeeded =1;
        END IF;		
        if (_Cancelled is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Cancelled =', _Cancelled); 
			set commaNeeded =1;
        END IF;		
        if (_POID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'POID =\'', TRIM(_POID),'\''); 
			set commaNeeded =1;
        END IF;		
        if (_BillNote is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'BillNote =\'', TRIM(_BillNote),'\''); 
			set commaNeeded =1;
        END IF;        
        if (_release_status is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'release_status =',_release_status); 
			set commaNeeded =1;
        END IF;	        
        if (_grTaxRate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'grTaxRate =',_grTaxRate); 
			set commaNeeded =1;
        END IF;	  
        
		IF (commaNeeded>0) THEN
        
			set @l_sql = CONCAT(@l_sql,' where joReleaseID=', _joReleaseID); 

			select @l_sql;
				
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		
            
        END IF;
        
        -- update totals:
		-- call TP_CalculateTotals (_cuSOId,null,@idUpdated);
        
        set _idUpdated = _joReleaseID;
        
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_joRelease_update',_joReleaseID);
    
    -- insert
    ELSE
 
		 if ( _joMasterID is null) THEN 
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_joRelease_update:_joMasterID is required to insert';
			LEAVE TP_joRelease_update; 
		END IF;
 
		if ( _coDivisionID is null) THEN 
			select coDivisionID into _coDivisionID from joMaster where joMasterID = _joMasterID;
		END IF;
         
        select count(joReleaseID)+1 into _seq_Number from joRelease where joMasterID= _joMasterID;
        
        set _Cancelled = 0;
        set _CommissionReceived = 0;
        set _CommissionAmount=0;
        if(_grTaxRate is null) THEN set _grTaxRate=0; END IF;
		if(_release_status is null) THEN set _release_status=0; END IF;       
		
        insert joRelease (joMasterID,ReleaseType,ReleaseDate,EstimatedBilling,ReleaseNote,CommissionReceived
		,CommissionDate,CommissionAmount,Cancelled,POID,BillNote,seq_Number,release_status
        ,coDivisionID,GRTaxRate)
        values (_joMasterID,_ReleaseType,DATE(_ReleaseDate),_EstimatedBilling,_ReleaseNote,_CommissionReceived
		,_CommissionDate,_CommissionAmount,_Cancelled,_POID,_BillNote,_seq_Number,_release_status
        ,_coDivisionID,_grTaxRate);

		SELECT LAST_INSERT_ID() INTO _idUpdated;

		set _joReleaseId = _idUpdated;
        
		call TP_tpUsage_insert (_userId,'INSERT','Info','TP_joRelease_update',_joReleaseId);
	
    END IF;
    
elseif  (_action = 'DELETE') THEN

	-- need to delete everything that has a joReleaseId?;
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'call TP_joRelease_update: DELETE NOT SUPPORTED';
	LEAVE TP_joRelease_update;     

END IF;

END$$

DELIMITER ;

-- ============================================================
-- call TP_joReleaseDetail_update('UPDATE',1,null,474,'2019-08-29 00:00:00','2019-08-29 00:00:00','2019-08-29 00:00:00','2019-08-29 00:00:00',0,0,25.01,0,@out);
-- call TP_joReleaseDetail_update('UPDATE',1,465,null,'2019-08-29 00:00:00','2019-08-29 00:00:00','2019-08-29 00:00:00','2019-08-29 00:00:00',0,0,0,0,@out);

DROP procedure IF EXISTS `TP_joReleaseDetail_update`;

DELIMITER $$
CREATE PROCEDURE TP_joReleaseDetail_update (
IN _action varchar(20),
IN _userId INT,
IN _joReleaseID INT,
IN _joReleaseDetailID INT, 
IN _ShipDate DATE, 
IN _VendorInvoiceDate DATE,
IN _CustomerInvoiceDate DATE,
IN _PaymentDate DATE,
IN _VendorInvoiceAmount DOUBLE,
IN _CustomerInvoiceAmount DOUBLE,
IN _CustomerInvoiceCost DOUBLE,
IN _BalanceDue DOUBLE, -- can this be calculated somehow?
OUT _idUpdated INT
)
TP_joReleaseDetail_update: BEGIN

DECLARE commaNeeded INT DEFAULT 0;
DECLARE _joMasterID INT;

if ( _action != 'UPDATE' and _action != 'DELETE') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_joReleaseDetail_update:_action must be UPDATE/DELTE';
	LEAVE TP_joReleaseDetail_update; 
END IF;
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_joReleaseDetail_update:_userId not given';
	LEAVE TP_joReleaseDetail_update; 
END IF;


if (_joReleaseDetailID <1) THEN set _joReleaseDetailID=null; END IF;

if (_action = 'UPDATE') THEN

	-- update record
	if (_joReleaseDetailID is not null) THEN
    
		set  @l_sql ='update joReleaseDetail set ';

         if (_ShipDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'ShipDate =\'', DATE(_ShipDate),'\''); 
			set commaNeeded =1;
        END IF;
         if (_VendorInvoiceDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'VendorInvoiceDate =\'', DATE(_VendorInvoiceDate),'\''); 
			set commaNeeded =1;
        END IF;        
         if (_CustomerInvoiceDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'CustomerInvoiceDate =\'', DATE(_CustomerInvoiceDate),'\''); 
			set commaNeeded =1;
        END IF;        
         if (_PaymentDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'PaymentDate =\'', DATE(_PaymentDate),'\''); 
			set commaNeeded =1;
        END IF;   
		
     
		if (_VendorInvoiceAmount is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'VendorInvoiceAmount =', _VendorInvoiceAmount); 
			set commaNeeded =1;
        END IF;
		if (_CustomerInvoiceAmount is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'CustomerInvoiceAmount =', _CustomerInvoiceAmount); 
			set commaNeeded =1;
        END IF;
		if (_CustomerInvoiceCost is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'CustomerInvoiceCost =', _CustomerInvoiceCost); 
			set commaNeeded =1;
        END IF;

		if (_BalanceDue is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'BalanceDue =', _BalanceDue); 
			set commaNeeded =1;
        END IF;		


		IF (commaNeeded>0) THEN
        
			set @l_sql = CONCAT(@l_sql,' where joReleaseDetailID=', _joReleaseDetailID); 

			select @l_sql;
				
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		
            
        END IF;
                
        set _idUpdated = _joReleaseDetailID;
        
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_joReleaseDetail_update',_joReleaseDetailID);
    
    -- insert
    ELSE

		if ( _joReleaseID is null) THEN 
			SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'call TP_joReleaseDetail_update:_joReleaseID not given for insert';
			LEAVE TP_joReleaseDetail_update; 
		END IF;

		if ( _joMasterID is null) THEN 
			select joMasterID into _joMasterID from joRelease where joReleaseID = _joReleaseID;
		END IF;
            
		insert joReleaseDetail (joMasterID ,joReleaseID,ShipDate,VendorInvoiceDate,CustomerInvoiceDate
		,PaymentDate,VendorInvoiceAmount,CustomerInvoiceAmount,CustomerInvoiceCost,BalanceDue)
		values (
		_joMasterID ,_joReleaseID,_ShipDate,_VendorInvoiceDate,_CustomerInvoiceDate
		,_PaymentDate,_VendorInvoiceAmount,_CustomerInvoiceAmount,_CustomerInvoiceCost,_BalanceDue);


		SELECT LAST_INSERT_ID() INTO _idUpdated;

		set _joReleaseDetailID = _idUpdated;
        
		call TP_tpUsage_insert (_userId,'INSERT','Info','TP_joReleaseDetail_update',_joReleaseDetailID);
	
    END IF;
    
	-- call TP_CalculateTotals (_cuSOId,@idUpdated);

elseif  (_action = 'DELETE') THEN

	if ( _joReleaseID is null) THEN 
		SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'call TP_joReleaseDetail_update:_joReleaseID not given';
		LEAVE TP_joReleaseDetail_update; 
	END IF;


	delete from joReleaseDetailID where  joReleaseID = _joReleaseID;
	
	call TP_tpUsage_insert (_userId,'DELETE','Info','TP_joReleaseDetail_update',_joReleaseID);

END IF;

END$$

DELIMITER ;


-- ============================================================

-- call TP_tpUsage_insert (1,'UPDATE','Info','TP_cuSO_update','');

DROP procedure IF EXISTS `TP_tpUsage_insert`;

DELIMITER $$
CREATE PROCEDURE TP_tpUsage_insert (
IN _userID INT,
IN _action VARCHAR(50),
IN _logLevel VARCHAR(20),
IN _screen VARCHAR(200),
IN _description VARCHAR(200)
)
CalculateTaxTotal: BEGIN


insert TPUsage (createdDate,screen,action,logLevel,userID,description,jobNumber) values (now(),_screen,_action,_logLevel,_userID,_description,null);


END$$

DELIMITER ;



-- ============================================================

-- call TP_CalculateTotals (170,null,@idUpdated);
-- call TP_CalculateTotals (null,707,@idUpdated);

DROP procedure IF EXISTS `TP_CalculateTotals`;

DELIMITER $$
CREATE PROCEDURE TP_CalculateTotals (
IN _cuSOID INT,
IN _vePOID INT,
OUT _idUpdated INT
)
TP_tpUsage_insert: BEGIN

DECLARE _TaxRate DOUBLE DEFAULT 0; 
DECLARE _CostTotal DOUBLE DEFAULT 0;-- pulled in 
DECLARE _SubTotal DOUBLE DEFAULT 0; -- calculated from lines
DECLARE _TaxTotal DOUBLE DEFAULT 0; -- calc from taxTerritory * SubTotal * (possibly)freight(taxFree)
DECLARE _whseCostTotal DOUBLE DEFAULT 0; -- = CostTotal
DECLARE _TaxableSales DOUBLE DEFAULT 0;
DECLARE _NonTaxableSales DOUBLE DEFAULT 0;
DECLARE _Freight DOUBLE DEFAULT 0;
DECLARE _taxfreight INT DEFAULT 0;
DECLARE _coTaxTerritoryID INT;
DECLARE _rxMasterID INT;


	if (_cuSOID is not null) THEN
    
		select coTaxTerritoryID, Freight, taxfreight into  _coTaxTerritoryID, _Freight,_taxfreight from cuSO where cuSOID = _cuSOID;
        
        IF (_coTaxTerritoryID is not null) THEN
			select (TaxRate/100) into _TaxRate from coTaxTerritory where coTaxTerritoryID=_coTaxTerritoryID;
			if(_TaxRate is null) THEN set _TaxRate=0; END IF;
        END IF;
        
        select sum(QuantityOrdered * UnitCost * PriceMultiplier) into _TaxableSales from cuSODetail where  (cuSOID= _cuSOID and Taxable=1) group by cuSOID;
		if (_TaxableSales is null) THEN set _TaxableSales=0; END IF;

		select sum(QuantityOrdered * UnitCost * PriceMultiplier) into _NonTaxableSales from cuSODetail where  (cuSOID= _cuSOID and Taxable=0) group by cuSOID;
		if (_NonTaxableSales is null) THEN set _NonTaxableSales=0; END IF;

        select sum(whseCost) into _whseCostTotal from cuSODetail where  (cuSOID= _cuSOID) group by cuSOID;
		if (_whseCostTotal is null) THEN set _whseCostTotal=0; END IF;
        
        set _SubTotal = _TaxableSales + _NonTaxableSales + _Freight;
        set _TaxTotal= (_TaxableSales * _TaxRate) + (_Freight*_taxfreight);        
        set _CostTotal = _whseCostTotal;
        
        select _CostTotal, _whseCostTotal, _Freight, _SubTotal, _TaxRate, _TaxTotal, _TaxableSales,_NonTaxableSales;
        
		update cuSO set CostTotal = _CostTotal, SubTotal=_SubTotal, TaxTotal=_TaxTotal, TaxableSales=_TaxableSales, NonTaxableSales=_NonTaxableSales,whseCostTotal=_whseCostTotal where cuSoID = _cuSOID;
	
		set _idUpdated = _cuSOID;
        
    ELSEIF (_vePOID is not null) THEN

        select rxBillToID into _rxMasterID from vePO where vePOID = _vePOID;
        
		SELECT coTaxTerritory.TaxRate into _TaxRate FROM rxAddress
		Left JOIN coTaxTerritory ON(rxAddress.coTaxTerritoryID=coTaxTerritory.coTaxTerritoryID)
		WHERE coTaxTerritory.coTaxTerritoryID is not null and rxAddress.rxMasterID=_rxMasterID limit 1;
 		if(_TaxRate is null) THEN set _TaxRate=0; END IF;
       
        -- IF (_coTaxTerritoryID is not null) THEN
		-- 	select (TaxRate/100) into _TaxRate from coTaxTerritory where coTaxTerritoryID=_coTaxTerritoryID;
		-- 	if(_TaxRate is null) THEN set _TaxRate=0; END IF;
        -- END IF;
        
        select sum(QuantityOrdered * UnitCost * PriceMultiplier) into _TaxableSales from vePODetail where  (vePOID= _vePOID and Taxable=1) group by vePOID;
		if (_TaxableSales is null) THEN set _TaxableSales=0; END IF;

		select sum(QuantityOrdered * UnitCost * PriceMultiplier) into _NonTaxableSales from vePODetail where  (vePOID= _vePOID and Taxable=0) group by vePOID;
		if (_NonTaxableSales is null) THEN set _NonTaxableSales=0; END IF;

        -- select sum(whseCost) into _whseCostTotal from vePODetail where  (vePOID= _vePOID) group by vePOID;
		-- if (_whseCostTotal is null) THEN set _whseCostTotal=0; END IF;
        
        set _SubTotal = _TaxableSales + _NonTaxableSales + _Freight;
        set _TaxTotal= (_TaxableSales * (_TaxRate/100)); -- + (_Freight*_taxfreight);        
        -- set _CostTotal = _whseCostTotal;
        
        select _vePOID,_rxMasterID,_Freight, _SubTotal, _TaxRate, _TaxTotal, _TaxableSales,_NonTaxableSales;
        
		-- update vePO set CostTotal = _CostTotal, SubTotal=_SubTotal, TaxTotal=_TaxTotal, TaxableSales=_TaxableSales, NonTaxableSales=_NonTaxableSales,whseCostTotal=_whseCostTotal where vePOID = _vePOID;
		update vePO set SubTotal=_SubTotal, TaxTotal=_TaxTotal, TaxRate=_TaxRate where vePOID = _vePOID;
	
		set _idUpdated = _vePOID;

    
    END IF;

END$$

DELIMITER ;



-- ============================================================

-- call TP_GenerateName ('cuSO',null,@name);

DROP procedure IF EXISTS `TP_GenerateName`;

DELIMITER $$
CREATE PROCEDURE TP_GenerateName (
IN _name INT,
-- IN _baseName VARCHAR(50),
IN _joMasterID INT,
OUT _generated VARCHAR(200)
)
TP_GenerateName: BEGIN

DECLARE _letters varchar(100) DEFAULT 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
DECLARE _nextSequence INT;
DECLARE _lett varchar(10);
DECLARE _JobNumber varchar(200);
DECLARE _sequence INT DEFAULT 0;

if (_name = 'cuSO') THEN

	-- OUTSIDE JOB
	if ( _joMasterID is null) THEN
    
		select Sequence into _sequence from sysSequence where TableName=_name;
        if (_sequence is null) THEN set _sequence=1000; END IF;

		set _generated = CONCAT( (_sequence+1) );
        
        update sysSequence set Sequence= (_sequence+1)  where TableName=_name;
        
    ELSE -- INSIDE FOB

		SELECT (count(joReleaseID)+1) into _nextSequence FROM joRelease WHERE joMasterID=_joMasterID;
		SELECT JobNumber into _JobNumber FROM joMaster WHERE joMasterID=_joMasterID;

		set _lett = SUBSTRING(_letters, _nextSequence, 1);
			
		set _generated = CONCAT(_JobNumber,_lett);

	END IF;

ELSEIF  (_name = 'vePO') THEN   

	if ( _joMasterID is null) THEN
		select Sequence into _sequence from sysSequence where TableName=_name;
        if (_sequence is null) THEN set _sequence=1000; END IF;

		set _generated = CONCAT( (_sequence+1) );
        
        update sysSequence set Sequence= (_sequence+1)  where TableName=_name;
    ELSE --

		SELECT (count(joReleaseID)+1) into _nextSequence FROM joRelease WHERE joMasterID=_joMasterID;
		SELECT JobNumber into _JobNumber FROM joMaster WHERE joMasterID=_joMasterID;

		set _lett = SUBSTRING(_letters, _nextSequence, 1);
			
		set _generated = CONCAT(_JobNumber,_lett);

	END IF;


ELSEIF  (_name = 'JournalEntry') THEN   
		select Sequence into _sequence from sysSequence where TableName=_name;
        if (_sequence is null) THEN set _sequence=1000; END IF;

		set _generated = CONCAT( (_sequence+1) );
        
        update sysSequence set Sequence= (_sequence+1)  where TableName=_name;

ELSEIF  (_name = 'veSO') THEN   
		select Sequence into _sequence from sysSequence where TableName=_name;
        if (_sequence is null) THEN set _sequence=1000; END IF;

		set _generated = CONCAT( (_sequence+1) );
        
        update sysSequence set Sequence= (_sequence+1)  where TableName=_name;

ELSEIF  (_name = 'cuInvoice') THEN   
		select Sequence into _sequence from sysSequence where TableName=_name;
        if (_sequence is null) THEN set _sequence=1000; END IF;

		set _generated = CONCAT( (_sequence+1) );
        
        update sysSequence set Sequence= (_sequence+1)  where TableName=_name;

ELSEIF  (_name = 'joMaster') THEN   
		select Sequence into _sequence from sysSequence where TableName=_name;
        if (_sequence is null) THEN set _sequence=1000; END IF;

		set _generated = CONCAT( (_sequence+1) );
        
        update sysSequence set Sequence= (_sequence+1)  where TableName=_name;

END IF;

    -- select _letters, _nextSequence, _JobNumber, _lett, _sequence, _generated;


END$$

DELIMITER ;



-- ============================================================
-- call TP_vePO_update('UPDATE',1,711,1,482,54,1955,null,null,null,null,null,null,null,null,'VENDORDERNUMBER','CUSTPONUMBER',null,
-- null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,2,2,3,10,@out);

-- call TP_vePO_update('UPDATE',1,null,1,482,54,1955,null,null,null,null,null,null,null,null,'VENDORDERNUMBER','CUSTPONUMBER',null,
-- null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,0,@out);

DROP procedure IF EXISTS `TP_vePO_update`;

DELIMITER $$
CREATE PROCEDURE TP_vePO_update (
IN _action varchar(20),
IN _userId INT,
IN _vePOID INT,
IN _TransactionStatus INT,
IN _joReleaseID INT,

IN _rxVendorID INT, -- manufacturerId
IN _rxBillToID INT, -- rxMasterId
-- IN _rxBillToAddressID INT, -- rxMasterId
IN _rxShipToID INT,
IN _rxShipToAddressID INT,
IN _veShipViaID INT,
IN _prWarehouseID INT,
IN _veFreightChargesID INT,
-- IN _OrderedByID INT, same as userId
IN _BillToMode INT,
IN _ShipToMode INT,
IN _Acknowledged INT,

-- IN _PONumber VARCHAR(20),
IN _VendorOrderNumber VARCHAR(20),
IN _CustomerPONumber VARCHAR(20),
IN _qbPO VARCHAR(20),

IN _AcknowledgementDate DATE,
IN _EstimatedShipDate DATE,
IN _DateWanted DATE,
-- IN _OrderDate DATE,
IN _receiveddate DATE,

-- IN _Tag VARCHAR(4000),
IN _SpecialInstructions VARCHAR(20),
IN _FreightChargeNote VARCHAR(50),

IN _rxVendorAddressID INT,
IN _rxVendorContactID INT,
IN _joSchedDetailID INT,
IN _veFactoryID INT,
IN _MultipleAcks INT,
IN _Consignment INT,
IN _cuSOID INT,
IN _joStockReleaseID INT,

IN _billToIndex INT,
IN _shipToIndex INT,
IN _wantedOnOrBefore INT,

IN _rxShipToOtherAddressID INT,
IN _isCareOfRequired INT,
IN _isFrieghtNotRequired INT,

IN _Freight DOUBLE,
OUT _idUpdated INT
)
TP_vePO_update: BEGIN

DECLARE commaNeeded INT DEFAULT 0;

DECLARE _TaxRate DOUBLE DEFAULT 0; 
DECLARE _CostTotal DOUBLE DEFAULT 0;-- pulled in 
DECLARE _SubTotal DOUBLE DEFAULT 0; -- calculated from lines
DECLARE _TaxTotal DOUBLE DEFAULT 0; -- calc from taxTerritory * SubTotal * (possibly)freight(taxFree)
DECLARE _Tag VARCHAR(200);
DECLARE _JobNumber VARCHAR(200);
DECLARE _joMasterID INT;
DECLARE _emailTimeStamp DATE;
DECLARE _coTaxTerritoryID INT;
DECLARE _coDivisionID INT;
DECLARE _rxCustomerID INT;
DECLARE _rxBillToAddressID INT;

if ( _action != 'UPDATE' and _action != 'DELETE') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_vePO_update:_action must be UPDATE/DELTE';
	LEAVE TP_vePO_update; 
END IF;
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_vePO_update:_userId not given';
	LEAVE TP_vePO_update; 
END IF;


if (_vePOID <1) THEN set _vePOID=null; END IF;

-- pending
if (_action = 'UPDATE') THEN

	-- update record
	if (_vePOID is not null) THEN
    
		set  @l_sql ='update vePO set ';
 
		if (_rxVendorID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxVendorID =', _rxVendorID); 
			set commaNeeded =1;
        END IF;
		if (_rxBillToID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxBillToID =', _rxBillToID); 
			set commaNeeded =1;
        END IF;

		if (_rxBillToID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxBillToAddressID =', _rxBillToID); 
			set commaNeeded =1;
        END IF;		
        if (_rxShipToID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxShipToID =', _rxShipToID); 
			set commaNeeded =1;
        END IF;		
        if (_rxShipToAddressID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxShipToAddressID =', _rxShipToAddressID); 
			set commaNeeded =1;
        END IF;		
        if (_veShipViaID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'veShipViaID =', _veShipViaID); 
			set commaNeeded =1;
        END IF;		
        if (_prWarehouseID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'prWarehouseID =', _prWarehouseID); 
			set commaNeeded =1;
        END IF;		
        if (_veFreightChargesID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'veFreightChargesID =', _veFreightChargesID); 
			set commaNeeded =1;
        END IF;		
        if (_BillToMode is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'BillToMode =', _BillToMode); 
			set commaNeeded =1;
        END IF;		
        if (_ShipToMode is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'ShipToMode =', _ShipToMode); 
			set commaNeeded =1;
        END IF;		
        if (_Acknowledged is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Acknowledged =', _Acknowledged); 
			set commaNeeded =1;
        END IF;
         if (_VendorOrderNumber is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'VendorOrderNumber =\'', TRIM(_VendorOrderNumber),'\''); 
			set commaNeeded =1;
        END IF;
         if (_CustomerPONumber is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'CustomerPONumber =\'', TRIM(_CustomerPONumber),'\''); 
			set commaNeeded =1;
        END IF;
         if (_qbPO is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'qbPO =\'', TRIM(_qbPO),'\''); 
			set commaNeeded =1;
        END IF;
		
         if (_AcknowledgementDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'AcknowledgementDate =\'', DATE(_AcknowledgementDate),'\''); 
			set commaNeeded =1;
        END IF;		
         if (_EstimatedShipDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'EstimatedShipDate =\'', DATE(_EstimatedShipDate),'\''); 
			set commaNeeded =1;
        END IF;		
         if (_DateWanted is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'DateWanted =\'', DATE(_DateWanted),'\''); 
			set commaNeeded =1;
        END IF;		
         if (_receiveddate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'receiveddate =\'', DATE(_receiveddate),'\''); 
			set commaNeeded =1;
        END IF;		

         if (_SpecialInstructions is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'SpecialInstructions =\'', TRIM(_SpecialInstructions),'\''); 
			set commaNeeded =1;
        END IF;
         if (_FreightChargeNote is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'FreightChargeNote =\'', TRIM(_FreightChargeNote),'\''); 
			set commaNeeded =1;
        END IF;


        if (_rxVendorAddressID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxVendorAddressID =', _rxVendorAddressID); 
			set commaNeeded =1;
        END IF;		
        if (_rxVendorContactID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxVendorContactID =', _rxVendorContactID); 
			set commaNeeded =1;
        END IF;		

        if (_joSchedDetailID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'joSchedDetailID =', _joSchedDetailID); 
			set commaNeeded =1;
        END IF;		

        if (_veFactoryID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'veFactoryID =', _veFactoryID); 
			set commaNeeded =1;
        END IF;		

        if (_MultipleAcks is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'MultipleAcks =', _MultipleAcks); 
			set commaNeeded =1;
        END IF;		

        if (_Consignment is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Consignment =', _Consignment); 
			set commaNeeded =1;
        END IF;		

        if (_cuSOID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'cuSOID =', _cuSOID); 
			set commaNeeded =1;
        END IF;		

        if (_billToIndex is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'billToIndex =', _billToIndex); 
			set commaNeeded =1;
        END IF;		

        if (_shipToIndex is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'shipToIndex =', _shipToIndex); 
			set commaNeeded =1;
        END IF;		

        if (_wantedOnOrBefore is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'wantedOnOrBefore =', _wantedOnOrBefore); 
			set commaNeeded =1;
        END IF;		

        if (_rxShipToOtherAddressID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'rxShipToOtherAddressID =', _rxShipToOtherAddressID); 
			set commaNeeded =1;
        END IF;		

        if (_isCareOfRequired is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'isCareOfRequired =', _isCareOfRequired); 
			set commaNeeded =1;
        END IF;		

        if (_isFrieghtNotRequired is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'isFrieghtNotRequired =', _isFrieghtNotRequired); 
			set commaNeeded =1;
        END IF;		

        if (_Freight is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Freight =', _Freight); 
			set commaNeeded =1;
        END IF;	


		IF (commaNeeded>0) THEN
        
        	set @l_sql = CONCAT(@l_sql,',changedOn =\'', now(),'\''); 
			set @l_sql = CONCAT(@l_sql,',ChangedByID =', _userId); 
			set @l_sql = CONCAT(@l_sql,' where vePOID=', _vePOID); 

			select @l_sql;
				
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		
            
        END IF;
        
        -- update totals:
		call TP_CalculateTotals (null,_vePOID, @idUpdated);
        
        set _idUpdated = _vePOID;
        
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_vePO_update',_vePOID);
    
    -- insert
    ELSE
    
        set _MultipleAcks = 0;
        set _Consignment = 0;
        -- set _OrderDate = DATE(now());
		set _rxShipToAddressID = null;
        set _veShipViaID = null;
        -- set _prWarehouseID = null;
        set _veFreightChargesID = null;
        set _BillToMode = 0;
        set _ShipToMode = 0;
        set _Acknowledged = 0;
        set _VendorOrderNumber = null;
        set _AcknowledgementDate = null;
        set _EstimatedShipDate = null;
        set _DateWanted = null;
        set _SpecialInstructions = null;
        set _Subtotal = 0;
        set _TaxTotal = 0;
        set _TaxRate = 0;
		if (_Freight is null) then set _Freight=0; end if;
        set _rxVendorAddressID = null;
        set _rxVendorContactID = null;
        set _joSchedDetailID = null;
        set _veFactoryID = null;
        set _FreightChargeNote = null;
        set _cuSOID = null;
        set _joStockReleaseID = null;
        set _billToIndex = 0;
        set _shipToIndex = 0;
        set _emailTimeStamp = null;
        set _wantedOnOrBefore = -1;
        set _qbPO = null;
        set _receiveddate = null;
        set _rxShipToOtherAddressID = null;
        set _isCareOfRequired = 0;
        set _isFrieghtNotRequired    = 0;   
        
        -- for inside job, the joReleaseId will not be null.
		if ( _joReleaseID is not null) THEN 
			select 
            m.description, m.joMasterID, 
            m.coDivisionID, m.rxCustomerID, m.rxCustomerID,
			-- m.cuAssignmentID0,m.cuAssignmentID1,m.cuAssignmentID2,m.cuAssignmentID3,m.cuAssignmentID4,
			m.coTaxTerritoryID,r.POID,1
            into 
            _Tag, _joMasterID,
			_coDivisionID,_rxBillToAddressID,_rxBillToID,
			-- _cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3,_cuAssignmentID4,
			_coTaxTerritoryID,_CustomerPONumber,_prWarehouseID            
            from joRelease r left join joMaster m on (m.joMasterID = r.joMasterID) where r.joReleaseID = _joReleaseID limit 1;

		END IF;
 
		select TaxRate into _TaxRate from coTaxTerritory where coTaxTerritoryID = _coTaxTerritoryID;        

        -- for inside job, the joReleaseId will not be null.
        call TP_GenerateName ('vePO',_joMasterID,@PONumber);
      
      
		-- _rxCustomerID = rxVendorID?? amd rxBillToID and rxBillTOAddressID
      
		insert vePO (CreatedByID,CreatedOn,ChangedByID,ChangedOn,TransactionStatus,joReleaseID,rxVendorID,rxBillToID
        ,rxBillToAddressID,rxShipToID,rxShipToAddressID,veShipViaID,prWarehouseID,veFreightChargesID,OrderedByID,BillToMode,ShipToMode,Acknowledged
        ,PONumber,VendorOrderNumber,CustomerPONumber,OrderDate,AcknowledgementDate,EstimatedShipDate,DateWanted,Tag,SpecialInstructions,Subtotal
        ,TaxTotal,Freight,TaxRate,rxVendorAddressID,rxVendorContactID,joSchedDetailID,veFactoryID,MultipleAcks,FreightChargeNote,Consignment,cuSOID
        ,joStockReleaseID,billToIndex,shipToIndex,emailTimeStamp,wantedOnOrBefore,qbPO,receiveddate,rxShipToOtherAddressID,isCareOfRequired,isFrieghtNotRequired)
		values (_userId,now(),null,null,_TransactionStatus,_joReleaseID,_rxVendorID,_rxBillToID
        ,_rxBillToAddressID,_rxShipToID,_rxShipToAddressID,_veShipViaID,_prWarehouseID,_veFreightChargesID,_userId,_BillToMode,_ShipToMode,_Acknowledged
        ,@PONumber,_VendorOrderNumber,_CustomerPONumber,DATE(now()),_AcknowledgementDate,_EstimatedShipDate,_DateWanted,_Tag,_SpecialInstructions,_Subtotal
        ,_TaxTotal,_Freight,_TaxRate,_rxVendorAddressID,_rxVendorContactID,_joSchedDetailID,_veFactoryID,_MultipleAcks,_FreightChargeNote,_Consignment,_cuSOID
        ,_joStockReleaseID,_billToIndex,_shipToIndex,_emailTimeStamp,_wantedOnOrBefore,_qbPO,_receiveddate,_rxShipToOtherAddressID,_isCareOfRequired,_isFrieghtNotRequired);

		SELECT LAST_INSERT_ID() INTO _idUpdated;

		set _vePOID = _idUpdated;
        
		call TP_tpUsage_insert (_userId,'INSERT','Info','TP_vePO_update',_vePOID);
	
    END IF;
    
elseif  (_action = 'DELETE') THEN

	-- need to delete everything that has a cuSOID;
    SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'call TP_vePO_update: DELETE NOT SUPPORTED';
	LEAVE TP_vePO_update;     

END IF;

END$$

DELIMITER ;


-- ============================================================
-- call TP_vePODetail_update('UPDATE',1,711,null,1,'description','note',1,22,34,1,1,now(),1,1,now(),'po',1,0,@out);
-- call TP_vePODetail_update('UPDATE',1,711,null,1,'description','note',1,22,34,1,1,now(),1,1,now(),'po',1,0,@out);

DROP procedure IF EXISTS `TP_vePODetail_update`;

DELIMITER $$
CREATE PROCEDURE TP_vePODetail_update (
IN _action varchar(20),
IN _userId INT,
IN _vePOID INT,
IN _vePODetailID INT,
IN _prMasterID INT, 
IN _Description VARCHAR(1000),
IN _Note VARCHAR(1000),
IN _QuantityOrdered INT,
IN _QuantityBilled INT,
IN _UnitCost DOUBLE,
-- IN _UnitPrice DOUBLE,
IN _PriceMultiplier DOUBLE,
IN _Taxable INT,
IN _EstimatedShipDate DATE,
IN _joSchedDetailID INT,
IN _Acknowledged INT,
IN _AcknowledgementDate DATE,
IN _VendorOrderNumber VARCHAR(25),
IN _cuSODetailID INT,
IN _position INT,
OUT _idUpdated INT
)
TP_vePODetail_update: BEGIN

DECLARE commaNeeded INT DEFAULT 0;

if ( _action != 'UPDATE' and _action != 'DELETE') THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_vePODetail_update:_action must be UPDATE/DELTE';
	LEAVE TP_vePODetail_update; 
END IF;
if ( _userId is null) THEN 
    SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call TP_vePODetail_update:_userId not given';
	LEAVE TP_vePODetail_update; 
END IF;


if (_vePODetailID <1) THEN set _vePODetailID=null; END IF;

if (_action = 'UPDATE') THEN

	-- update record
	if (_vePODetailID is not null) THEN
    
		set  @l_sql ='update VEPODetail set ';
 
		if (_prMasterID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'prMasterID =', _prMasterID); 
			set commaNeeded =1;
        END IF;
		if (_QuantityOrdered is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'QuantityOrdered =', _QuantityOrdered); 
			set commaNeeded =1;
        END IF;

		if (_QuantityBilled is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'QuantityBilled =', _QuantityBilled); 
			set commaNeeded =1;
        END IF;		
        if (_UnitCost is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'UnitCost =', _UnitCost); 
			set commaNeeded =1;
        END IF;		
	
        if (_PriceMultiplier is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'PriceMultiplier =', _PriceMultiplier); 
			set commaNeeded =1;
        END IF;		
        if (_Taxable is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Taxable =', _Taxable); 
			set commaNeeded =1;
        END IF;		


         if (_EstimatedShipDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'EstimatedShipDate =\'', DATE(_EstimatedShipDate),'\''); 
			set commaNeeded =1;
        END IF;		
         if (_AcknowledgementDate is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
        	set @l_sql = CONCAT(@l_sql,'AcknowledgementDate =\'', DATE(_AcknowledgementDate),'\''); 
			set commaNeeded =1;
        END IF;		
          if (_VendorOrderNumber is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'VendorOrderNumber =\'', _VendorOrderNumber,'\''); 
			set commaNeeded =1;
        END IF;
        if (_joSchedDetailID is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'joSchedDetailID =', _joSchedDetailID); 
			set commaNeeded =1;
        END IF;	
        if (_Acknowledged is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Acknowledged =', _Acknowledged); 
			set commaNeeded =1;
        END IF;	
        
        
        if (_position is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'position =', _position); 
			set commaNeeded =1;
        END IF;	
          if (_Description is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Description =\'', _Description,'\''); 
			set commaNeeded =1;
        END IF;
         if (_Note is not null) THEN 
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
			set @l_sql = CONCAT(@l_sql,'Note =\'', _Note,'\''); 
			set commaNeeded =1;
        END IF;

		IF (commaNeeded>0) THEN
        
			set @l_sql = CONCAT(@l_sql,' where VEPODetailID=', _vePODetailID); 

			select @l_sql;
				
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
		
            
        END IF;
                
        set _idUpdated = _vePODetailID;
        
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_vePODetail_update',_vePODetailID);
    
    -- insert
    ELSE

		if ( _vePOID is null) THEN 
			SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'call TP_vePODetail_update:_vePOID not given for insert';
			LEAVE TP_vePODetail_update; 
		END IF;
		
        select count(*)+1 into _position from vePODetail where vePOID=_vePOID;
        
		insert vePODetail (vePOID ,prMasterID,Description,Note,QuantityOrdered,QuantityBilled
		,UnitCost,PriceMultiplier,Taxable,posistion
        ,EstimatedShipDate,joSchedDetailID,Acknowledged,AcknowledgementDate,VendorOrderNumber,QuantityInvoiced)
		values (
		_vePOID ,_prMasterID,_Description,_Note,_QuantityOrdered,_QuantityBilled
		,_UnitCost,_PriceMultiplier,_Taxable,_position
        ,null,null,0,null,null,0);

		SELECT LAST_INSERT_ID() INTO _idUpdated;

		set _vePODetailID = _idUpdated;
        
		call TP_tpUsage_insert (_userId,'INSERT','Info','TP_vePODetail_update',_vePODetailID);
	
    END IF;
    
   call TP_CalculateTotals (null,_vePOID,@idUpdated);

elseif  (_action = 'DELETE') THEN

	if ( _vePODetailID is null) THEN 
		SIGNAL SQLSTATE '45003' SET MESSAGE_TEXT = 'call TP_vePODetail_update:_vePODetailID not given';
		LEAVE TP_vePODetail_update; 
	END IF;


	select vePOID into _vePOID from VEPODetail where vePODetailID = _vePODetailID;
	
    if (_vePOID is not null) THEN
		delete from vePODetail where vePODetailID = _vePODetailID;
		call TP_tpUsage_insert (_userId,'UPDATE','Info','TP_vePODetail_update',_vePOID);
	END IF;

   call TP_CalculateTotals (null,_vePOID,@idUpdated);


END IF;

END$$

DELIMITER ;





-- ==================================

-- call INV_updateBin('UPDATE',null,2,3,1,1,4,null,null,null,null,null,null,null,1);
-- call INV_updateBin('UPDATE',5,null,null,1,8,11,null,null,null,null,null,9,null,1);
-- call INV_updateBin('UPDATEPRODUCT',6,2,22,null,null,null,null,null,null,null,null,null,null,1);
-- call INV_updateBin('UPDATEPRODUCT',10,2,8,null,null,null,null,null,null,null,null,null,null,1);
-- call INV_updateBin('UPDATEPRODUCT',40,2,202,null,null,null,null,null,null,null,null,null,null,1);


DROP procedure IF EXISTS `INV_updateBin`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_updateBin`( 
   IN _action  varchar(25),
   IN _binId INT,
   IN _prWarehouseID INT,
   IN _prMasterID INT,
--   IN _binSequence INT,
   IN _rack VARCHAR(100),
   IN _row VARCHAR(100),
   IN _slot VARCHAR(100),
   IN _overrideName VARCHAR(100),
   IN _maxQuantity decimal(19,4),
   IN _InventoryOnHand decimal(19,4),
   IN _InventoryAllocated decimal(19,4),
   IN _InventoryOnOrder decimal(19,4),
   IN _AverageCost decimal(19,4),
   IN _transferBinId INT,
   IN _changedByID INT
)
INV_updateBin: BEGIN
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _searchName VARCHAR(200);
DECLARE _prWarehouseInventoryID INT;
DECLARE _bins INT DEFAULT 0;
DECLARE _maxBin INT DEFAULT 0;
DECLARE _binSequence INT;
DECLARE _lastPrMasterID INT;
DECLARE _lastPrWarehouseID INT;
DECLARE _testInvOH INT;
DECLARE _testPrMasterID INT;
DECLARE _hasInventory INT;

if ( _changedByID is null) THEN 
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call updateBin:_changedByID missing';
	LEAVE INV_updateBin; 
END IF;


	if ( (_action='MOVEUP' OR _action='MOVEDOWN') and _binId is not null) THEN

		call INV_updateBinSequence(_action,_binId);

	ELSEIF (_action='TRANSFER') THEN

		select InventoryOnHand,InventoryAllocated,prMasterID into _testInvOH,_InventoryAllocated,_prMasterID from bin where binId = _binId;
        
        select prMasterID into _testPrMasterID from bin where binId = _transferBinId;
        
        -- OH 10
        -- A 3
        -- Move 6
        
        -- RULE: product must match, proper inventory can only be moved. source/Target bins identified
        -- THIS IS ONLY MOVED FROM WITHIN THE SAME PRODUCT/WAREHOUSE.  So there is no need to call the updateOH function
        IF ( ((_testInvOH - _InventoryAllocated) >= _InventoryOnHand) and _binId is not null and _transferBinId is not null and _testPrMasterID=_prMasterID) THEN
		
			update bin set InventoryOnHand = InventoryOnHand - _InventoryOnHand where binId = _binId;
			update bin set InventoryOnHand = InventoryOnHand + _InventoryOnHand where binId = _transferBinId;
        

        END IF;
        
	ELSEIF (_action='UPDATE') THEN

        
        
		if (_binId is null) THEN

			if (_prMasterID is not null and _prWarehouseID is not null) THEN

				select prWarehouseInventoryID into _prWarehouseInventoryID from prWarehouseInventory  where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID;
			
				if (_prWarehouseInventoryID is null) THEN
					
					insert into prWarehouseInventory (prMasterID,prWarehouseID) values (_prMasterID,_prWarehouseID);
					SELECT LAST_INSERT_ID() INTO _prWarehouseInventoryID;
					
				END IF;
				
				-- select count(*), max(binId) into _bins,_maxBin from bin where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID;
				
				
			END IF;

            select count(*), max(binId) into _bins,_maxBin from bin where prWarehouseInventoryID=_prWarehouseInventoryID;

			if (_rack is not null or _row is not null or _slot is not null) THEN
				set _searchName=concat(_row,'-',_rack,'-',_slot);
            END IF;
        
			if (_overrideName is not null) THEN
				set _searchName=_overrideName;
            END IF;
            
            if (_bins>0) THEN
				set _binSequence = _bins+1;
            ELSE
				set _binSequence = 0;
            END IF;
            
            
            -- if this is the first bin, take the value from the old inventory warehouse table.
            if (_bins is null or _bins=0) THEN 
				select InventoryOnHand,InventoryAllocated,InventoryOnOrder into _InventoryOnHand,_InventoryAllocated,_InventoryOnOrder from prWarehouseInventory where prWarehouseInventoryID=_prWarehouseInventoryID;
            END IF;
            
            
            if (_InventoryOnHand is null) THEN set _InventoryOnHand=0; END IF;
            if (_InventoryAllocated is null) THEN set _InventoryAllocated=0; END IF;
            if (_InventoryOnOrder is null) THEN set _InventoryOnOrder=0; END IF;
          --   if (_AverageCost is null) THEN set _AverageCost=0; END IF;
            
            -- if the inventory table does not have it, check the product table
           -- if (_AverageCost =0) THEN
				select ifnull(AverageCost,0) into _AverageCost from prMaster where prMasterID=_prMasterID;
           -- END IF;
			
           -- if (_AverageCost is null) THEN set _AverageCost=0; END IF;
           
            -- if (_AverageCost is null) THEN set _AverageCost=0; END IF;
           
           
-- select  _prWarehouseID,_prWarehouseInventoryID,_prMasterID,_binSequence,_rack,_row,_slot,_overrideName,_searchName,_maxQuantity,_InventoryOnHand,_InventoryAllocated,_InventoryOnOrder,_AverageCost,_changedByID;
          

          
			insert into bin (prWarehouseID,prWarehouseInventoryID,prMasterID,binSequence,rack,row,slot,overrideName,searchName,maxQuantity,InventoryOnHand,InventoryAllocated,InventoryOnOrder,AverageCost,changedByID,LastUpdatedTime) 
            values (_prWarehouseID,_prWarehouseInventoryID,_prMasterID,_binSequence,_rack,_row,_slot,_overrideName,_searchName,_maxQuantity,_InventoryOnHand,_InventoryAllocated,_InventoryOnOrder,_AverageCost,_changedByID,now());

			SELECT LAST_INSERT_ID() INTO _binId;
 
 			-- need to update prWHInventory tables and prMaster
			SELECT * from bin where binId =  _binId;
			call INV_updateBinSequence('RESYNC',_binId);
		
        ELSE

/*
			select prMasterID,prWarehouseID,prWarehouseInventoryID into _lastPrMasterID,_lastPrWarehouseID,_prWarehouseInventoryID from bin  where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID limit 1;
            IF (_prMasterID=_lastPrMasterID and _prWarehouseID=_lastPrWarehouseID) THEN
				set _prMasterID = NULL;
        		set _prWarehouseID = NULL;
            END IF;
*/

			if (_prMasterID is not null) THEN 
			 	select max(binSequence)+1 into _binSequence from bin where prMasterID = _prMasterID and prWarehouseID = _prWarehouseID ;
				select prWarehouseInventoryID into _prWarehouseInventoryID from  prWarehouseInventory where prMasterID = _prMasterID and prWarehouseID = _prWarehouseID ;
			END IF;
			set  @l_sql ='update bin set ';
		   
			 if (_rack is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'rack =\'',_rack,'\''); 
				set commaNeeded =1;
			END IF;
			 if (_row is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'row =\'',_row,'\''); 
				set commaNeeded =1;
			END IF;
			 if (_slot is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'slot =\'',_slot,'\''); 
				set commaNeeded =1;
                set _searchName=concat(_row,'-',_rack,'-',_slot);
			END IF;
            
			 if (_slot is not null or _row is not null or _rack is not null ) THEN 
                set _searchName=concat(_row,'-',_rack,'-',_slot);
			END IF;
            
            
			 if (_overrideName is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'overrideName =\'',_overrideName,'\''); 
				set commaNeeded =1;
                set _searchName=_overrideName;
			Elseif (_overrideName is null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'overrideName = null'); 
				set commaNeeded =1;
                -- set _searchName=_overrideName;
			END IF;
            
			 if (_searchName is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'searchName =\'',_searchName,'\''); 
				set commaNeeded =1;
			END IF; 

/*            
           if (_prMasterID is not null and _prWarehouseID is not null) THEN 
				
                IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'prMasterID =', _prMasterID); 
				set @l_sql = CONCAT(@l_sql,',prWarehouseID =', _prWarehouseID); 
				set commaNeeded =1;

				select prWarehouseInventoryID into _prWarehouseInventoryID from prWarehouseInventory  where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID;
				if (_prWarehouseInventoryID is null) THEN
					
					insert into prWarehouseInventory (prMasterID,prWarehouseID) values (_prMasterID,_prWarehouseID);
					SELECT LAST_INSERT_ID() INTO _prWarehouseInventoryID;
					
				END IF;
                
				set @l_sql = CONCAT(@l_sql,',prWarehouseInventoryID =', _prWarehouseInventoryID); 
				set @l_sql = CONCAT(@l_sql,',binSequence =', _binSequence); 


			END IF;
*/
			-- TODO, maybe check if pr is attached, else zero out everything.	
             -- do changes here need to roll up to prWarehouse.. and can calculations be done here?   
			if (_maxQuantity is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'maxQuantity =', _maxQuantity); 
				set commaNeeded =1;
			END IF;

			/* note: inventory should be updated via 	

			-- call INV_updateOH('REPLACE',_binId,_InventoryOnHand,_InventoryAllocated,null,_changedByID);

			 if (_InventoryOnHand is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'InventoryOnHand =', _InventoryOnHand); 
				set commaNeeded =1;
			END IF;
			 if (_InventoryAllocated is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'InventoryAllocated =', _InventoryAllocated); 
				set commaNeeded =1;
			END IF;
			 if (_InventoryOnOrder is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'InventoryOnOrder =', _InventoryOnOrder); 
				set commaNeeded =1;
			END IF;
			*/

			 if (_AverageCost is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'AverageCost =', _AverageCost); 
				set commaNeeded =1;
			END IF;
			 if (_prMasterID is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'prMasterID =', _prMasterID); 
				set commaNeeded =1;
			END IF;
              if (_prWarehouseInventoryID is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'prWarehouseInventoryID =', _prWarehouseInventoryID); 
				set commaNeeded =1;
			END IF;

			
			IF (commaNeeded>0) THEN
			
				set @l_sql = CONCAT(@l_sql,',changedByID =', _changedByID); 
				set @l_sql = CONCAT(@l_sql,',LastUpdatedTime =\'', now(),'\''); 
				set @l_sql = CONCAT(@l_sql,' where binId=', _binId); 

				-- select @l_sql;
					
					
				PREPARE stmt FROM @l_sql;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
                SELECT * from bin where binId =  _binId;
				if(_binSequence is not null) THEN 
					call INV_updateSequence("UPDATESEQ",_binId,_prMasterID,_binSequence);
                END IF ;
				
			END IF;


		END IF;

		if (_changedByID > 0) THEN select * from v_INV_bin where binId=_binId; END IF;

	ELSEIF (_action='UPDATEPRODUCT') THEN

		if ( _binId is null or _prWarehouseID is null) THEN 
		    SIGNAL SQLSTATE '45002' SET MESSAGE_TEXT = 'call updateBin:_binId or _prWarehouseID missing';
			LEAVE INV_updateBin; 
		END IF;
			
			set  @l_sql ='update bin set ';

           	-- check if there is inventory
			select prMasterID into _hasInventory from bin  where (InventoryOnHand>0 or InventoryAllocated>0 or InventoryOnOrder>0) and binId = _binId;
 

           if (_prMasterID is null and _hasInventory is null) THEN 


                IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'prMasterID = NULL'); 
				set @l_sql = CONCAT(@l_sql,',prWarehouseInventoryID = NULL'); 
				set @l_sql = CONCAT(@l_sql,',binSequence = 0');
				set commaNeeded =1;
 
           ELSEif (_prMasterID is not null and _hasInventory is null) THEN 

				select prMasterID into _lastPrMasterID from bin  where binId = _binId;

-- select 'ELSEif (_prMasterID is not null and _hasInventory is null)', _prMasterID,_hasInventory, _binId,_lastPrMasterID,@l_sql;


	            IF (_prMasterID=_lastPrMasterID ) THEN
					
                    set _prMasterID = NULL;
	        		set _prWarehouseID = NULL;
	            
	            ELSE

			
	                IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'prMasterID =', _prMasterID); 
					-- set @l_sql = CONCAT(@l_sql,',prWarehouseID =', _prWarehouseID); 
					set commaNeeded =1;

					select prWarehouseInventoryID, InventoryOnHand, InventoryAllocated, InventoryOnOrder, AverageCost 
                    into _prWarehouseInventoryID, _InventoryOnHand, _InventoryAllocated, _InventoryOnOrder, _AverageCost 
                    from prWarehouseInventory  where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID;
					
                    if (_InventoryOnHand is null) THEN set _InventoryOnHand=0; END IF;
                    if (_InventoryAllocated is null) THEN set _InventoryAllocated=0; END IF;
                    if (_InventoryOnOrder is null) THEN set _InventoryOnOrder=0; END IF;
                    if (_AverageCost is null) THEN set _AverageCost=0; END IF;
                    
                    if (_prWarehouseInventoryID is null) THEN
						
						insert into prWarehouseInventory (prMasterID,prWarehouseID) values (_prMasterID,_prWarehouseID);
						SELECT LAST_INSERT_ID() INTO _prWarehouseInventoryID;
						
					END IF;
                    
-- select 'ELSE',_prMasterID,_prWarehouseID,_prWarehouseInventoryID,@l_sql;

	                
	                -- get max bin seq
            		select count(*), max(binId) into _bins,_maxBin from bin where prWarehouseInventoryID=_prWarehouseInventoryID;
		            if (_bins>0) THEN
						set _binSequence = _bins+1;
		            ELSE
						set _binSequence = 0;
		            END IF;

					set @l_sql = CONCAT(@l_sql,',prWarehouseInventoryID =', _prWarehouseInventoryID); 
					set @l_sql = CONCAT(@l_sql,',binSequence =', _binSequence);

-- select 'if (_bins>0) THEN',_binSequence,_InventoryOnHand,_InventoryAllocated,_InventoryOnOrder,_AverageCost,@l_sql;
                    
                    -- only update oh's if this is the first bin for this product at this wh
                    if (_binSequence=0) THEN
						set @l_sql = CONCAT(@l_sql,',InventoryOnHand =', _InventoryOnHand);
						set @l_sql = CONCAT(@l_sql,',InventoryAllocated =', _InventoryAllocated);
						set @l_sql = CONCAT(@l_sql,',InventoryOnOrder =', _InventoryOnOrder);
						set @l_sql = CONCAT(@l_sql,',AverageCost =', _AverageCost);
					END IF;
                   	set commaNeeded =1;
 
-- select 'if (_binSequence=0)',_binSequence,@l_sql;

				END IF;


			END IF;

			IF (commaNeeded>0) THEN
			
				set @l_sql = CONCAT(@l_sql,',changedByID =', _changedByID); 
				set @l_sql = CONCAT(@l_sql,',LastUpdatedTime =\'', now(),'\''); 
				set @l_sql = CONCAT(@l_sql,' where binId=', _binId); 

				-- select @l_sql;
					
				PREPARE stmt FROM @l_sql;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
			
				
			END IF;


		-- when do we have to call this function?
		-- call INV_updateOH('REPLACE',_binId,_InventoryOnHand,_changedByID);

		call INV_updateBinSequence('RESYNC',_binId);

		select * from v_INV_bin where binId=_binId;

	ELSEIF (_action='DELETE') THEN

	-- select prMasterID into _prMasterID from bin  where InventoryOnHand=0 and InventoryAllocated=0 and InventoryOnOrder=0 and binId = _binId;
		
        -- if (_prMasterID is null) THEN
			select binSequence into _binSequence from bin where InventoryOnHand=0 and InventoryAllocated=0 and InventoryOnOrder=0 and binId = _binId;
			DELETE from bin where InventoryOnHand=0 and InventoryAllocated=0 and InventoryOnOrder=0 and binId = _binId;
            
            if(_prMasterID is not null) THEN
				if(_binSequence is not null) THEN
					call INV_updateSequence("DELETESEQ",_binId,_prMasterID,_binSequence);
				END IF;
			END IF;

	ELSEIF(_action = "DELETEITEM")   then
			
			select binSequence into _binSequence from bin where InventoryOnHand=0 and InventoryAllocated=0 and InventoryOnOrder=0 and binId = _binId;
					if(_prMasterID is not null) THEN
						if(_binSequence is not null) THEN
							call INV_updateSequence("DELETESEQ",_binId,_prMasterID,_binSequence);
							END IF;
					END IF;
			update bin  set prMasterID = null, prWarehouseInventoryID = null, binSequence = 0 where InventoryOnHand=0 and InventoryAllocated=0 and InventoryOnOrder=0 and binId = _binId;
			END IF;
        -- END IF;
        
END$$

DELIMITER ;

-- ==================================

-- call updateBinSequence('RESYNC',3);
-- call updateBinSequence('MOVEUP',3);
-- call updateBinSequence('MOVEDOWN',3);



DROP procedure IF EXISTS `INV_updateBinSequence`;

DELIMITER $$
CREATE PROCEDURE `INV_updateBinSequence` ( 
   IN _action  varchar(25),
   IN _binId INT
)
INV_updateBinSequence: BEGIN
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _bins varchar(500);
DECLARE _aBinId INT;
DECLARE _prWarehouseInventoryID INT;
DECLARE _binSequence INT DEFAULT 1;
DECLARE _toBeMovedBinID INT;
DECLARE _toBeMovedSeq INT;
DECLARE _toBeReplacedBinID INT;
DECLARE _toBeReplacedSeq INT;

select prWarehouseInventoryID into _prWarehouseInventoryID from bin where binId = _binId;
select binId, binSequence into _toBeMovedBinID,_toBeMovedSeq from bin where binId = _binId;

IF (_action='MOVEUP') THEN

select binId, binSequence into _toBeReplacedBinID, _toBeReplacedSeq from bin where prWarehouseInventoryID=_prWarehouseInventoryID and binSequence <_toBeMovedSeq order by binSequence desc limit 1;
IF (_toBeReplacedBinID is not NULL) THEN 
	update bin set binSequence=_toBeMovedSeq   where binId= _toBeReplacedBinID; 
	update bin set binSequence=_toBeReplacedSeq   where binId= _toBeMovedBinID; 
END IF;

ELSEIF (_action='MOVEDOWN') THEN

select binId, binSequence into _toBeReplacedBinID, _toBeReplacedSeq from bin where prWarehouseInventoryID=_prWarehouseInventoryID and binSequence > _toBeMovedSeq order by binSequence asc limit 1;
IF (_toBeReplacedBinID is not NULL) THEN 
	update bin set binSequence=_toBeMovedSeq   where binId= _toBeReplacedBinID;     
	update bin set binSequence=_toBeReplacedSeq   where binId= _toBeMovedBinID;
END IF;

END IF;


IF (_action='RESYNC' and _prWarehouseInventoryID is not null) THEN

	select GROUP_CONCAT(binId) into _bins from bin where prWarehouseInventoryID=_prWarehouseInventoryID;

		-- select _bins;
        
		IF (_bins is not null) THEN
        
			 do_this:
			   LOOP
			 SET strLen = CHAR_LENGTH(_bins);
									
			 set _aBinId=SUBSTRING_INDEX(_bins, ',', 1);

				-- select _aBinId,_binSequence;
				update bin set binSequence = _binSequence where binId=_aBinId;
                set _binSequence = _binSequence+1;
                
                
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_bins, ',', 1))+2;
			 SET _bins = MID(_bins, SubStrLen, strLen);

			 IF _bins = '' or _bins is null THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
											
		END IF; -- if not null

END IF;    

-- select * from bin where prWarehouseInventoryID=_prWarehouseInventoryID;
 
END$$

DELIMITER ;




-- ==================================


-- call INV_getBin(null,null,2,3,NULL);
-- call INV_getBin('QSEARCH',null,null,null,'3');
-- call INV_getBin('DETAILED-SEARCH',null,null,null,'3');
-- call INV_getBin('UNALLOCATED',null,null,null,null);
-- call INV_getBin('WAREHOUSEROLLUP',null , null, 339, null);
-- call INV_getBin('PRODUCTROLLUP',null , null, 339, null);

DROP procedure IF EXISTS `INV_getBin`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_getBin`( 
   IN _action  varchar(25),
   IN _binId INT,
   IN _prWarehouseID INT,
   IN _prMasterID INT,
   IN _search VARCHAR(200)
)
INV_getBin: BEGIN
DECLARE _prWarehouseInventoryID INT;
DECLARE commaNeeded INT DEFAULT 0;
	IF (_action='QSEARCH'  and _search is not null and _binId is null) THEN

		-- select *,CONCAT('\'%',_search,'%\'') from bin where searchName like CONCAT('%',_search,'%');
        
        
		IF (_prWarehouseID is not null) THEN
			select * from bin where searchName like CONCAT('%',_search,'%') and prWarehouseID=_prWarehouseID and inTransfer is null  order by searchName;
        else
			select * from bin where searchName like CONCAT('%',_search,'%') and  inTransfer is null order by searchName;
        END IF;

	ELSEIF (_action='UNALLOCATED') THEN

		-- select *,CONCAT('\'%',_search,'%\'') from bin where searchName like CONCAT('%',_search,'%');
        
        
		IF (_prWarehouseID is not null) THEN
			select * from bin where prMasterID is null and prWarehouseID=_prWarehouseID and  inTransfer is null order by searchName;
        else
			select * from bin where prMasterID is null and  inTransfer is null order by searchName;
        END IF;

	ELSEIF (_action='DETAILED-SEARCH' and _search is not null and _binId is null) THEN
       
		IF (_prWarehouseID is not null) THEN
			select * from v_INV_bin  where  detailed_search like CONCAT('%',_search,'%') and prWarehouseID=_prWarehouseID  order by searchName;
        else
			select * from v_INV_bin  where  detailed_search like CONCAT('%',_search,'%')  order by searchName;
        END IF;
        
        ELSEIF (_action='ALLBINS' and _search is not null and _binId is null) THEN
       
		IF (_prWarehouseID is not null) THEN
			select * from v_INV_ALLBINS  where  detailed_search like CONCAT('%',_search,'%') and prWarehouseID=_prWarehouseID  order by searchName;
        else
			select * from v_INV_ALLBINS  where  detailed_search like CONCAT('%',_search,'%')  order by searchName;
        END IF;

	ELSEIF (_action='DETAILED-SEARCH-OPTIONS' and _search is not null and _binId is null) THEN
       
		IF (_prWarehouseID is not null) THEN
			select * from v_INV_bin where concat(detailed_search,PrimaryVendor) like CONCAT('%',_search,'%') and prWarehouseID=_prWarehouseID  order by searchName;
        else
			select * from v_INV_bin where concat(detailed_search,PrimaryVendor) like CONCAT('%',_search,'%')  order by searchName;
        END IF;

	ELSEIF (_action='WITHPRODUCTS') THEN

        
		if ( _binId is not null) THEN
			
	        select * from v_INV_bin where binId=_binId and ItemCode is not null;
	        
		ELSEif ( _prWarehouseID is not null and _prMasterID is null) THEN

	        select * from v_INV_bin where prWarehouseID=_prWarehouseID  and ItemCode is not null order by searchName ASC;

		ELSEif ( _prWarehouseID is null and _prMasterID is NOT null) THEN

	        select * from v_INV_bin where prMasterID=_prMasterID  and ItemCode is not null order by searchName ASC;

		ELSEif ( _prWarehouseID is NOT null and _prMasterID is NOT null) THEN

	        select * from v_INV_bin where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID  and ItemCode is not null ORDER BY binSequence;

		END IF;
    
	ELSEIF (_action='FACILITY') THEN

        
		if ( _binId is not null) THEN
			
	        select * from v_INV_bin where binId=_binId;
	        
		ELSEif ( _prWarehouseID is not null and _prMasterID is null) THEN

	        select * from v_INV_bin where prWarehouseID=_prWarehouseID;

		ELSEif ( _prWarehouseID is null and _prMasterID is NOT null) THEN

	        select * from v_INV_bin where prMasterID=_prMasterID order by binSequence ASC;

		ELSEif ( _prWarehouseID is NOT null and _prMasterID is NOT null) THEN

	        select * from v_INV_bin where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID ORDER BY binSequence;

		END IF;


	ELSEIF (_action='WAREHOUSEROLLUP') THEN

       set  @l_sql = "SELECT 
        -(1) AS `binId`,
        `b`.`prWarehouseID` AS `prWarehouseID`,
        `b`.`prWarehouseInventoryID` AS `prWarehouseInventoryID`,
        `b`.`prMasterID` AS `prMasterID`,
        (SELECT 
                `bin`.`searchName`
            FROM
                `bin`
            WHERE
                ((`bin`.`prWarehouseID` = `b`.`prWarehouseID`)
                    AND (`bin`.`prWarehouseInventoryID` = `b`.`prWarehouseInventoryID`)
                    AND (`bin`.`prMasterID` = `b`.`prMasterID`)
                    AND (`bin`.`binSequence` = 1))) AS `primaryBin`,
        MIN(`b`.`binSequence`) AS `binSequence`,
        SUM(`b`.`InventoryOnHand`) AS `InventoryOnHand`,
        SUM(`b`.`InventoryAllocated`) AS `InventoryAllocated`,
        (CASE
            WHEN ((SUM(`b`.`InventoryAllocated`) - SUM(`b`.`InventoryOnHand`)) > 0) THEN (SUM(`b`.`InventoryAllocated`) - SUM(`b`.`InventoryOnHand`))
            ELSE 0
        END) AS `InventoryOnOrder`,
        (SUM(`b`.`InventoryOnHand`) - SUM(`b`.`InventoryAllocated`)) AS `InventoryAvailable`,
        AVG(`b`.`AverageCost`) AS `AverageCost`,
        `pm`.`ItemCode` AS `ItemCode`,
        `pm`.`Description` AS `Description`,
        `dept`.`Description` AS `Department`,
        `dept`.`prDepartmentID` AS `prDepartmentId`,
        `cat`.`Description` AS `Category`,
        `cat`.`prCategoryID` AS `prCategoryId`,
        `vend`.`Name` AS `PrimaryVendor`,
        `pm`.`InventoryOnHand` AS `prInventoryOnHand`,
        `pm`.`InventoryAllocated` AS `prInventoryAllocated`,
        `pm`.`InventoryOnOrder` AS `prInventoryOnOrder`,
        `pm`.`AverageCost` AS `prAverageCost`,
        `w`.`Description` AS `whDescription`,
        `w`.`Address1` AS `whAddress1`,
        `wi`.`InventoryOnHand` AS `whInventoryOnHand`,
        `wi`.`InventoryAllocated` AS `whInventoryAllocated`,
        `wi`.`InventoryOnOrder` AS `whInventoryOnOrder`,
        `ic`.`CountedOnHand` AS `inventoryCounted`,
        INV_GETYEARTODATESOLD(`b`.`prMasterID`, `b`.`prWarehouseID`) AS `YTDSold`,
        CONCAT(CONVERT( `b`.`searchName` USING UTF8),
                IFNULL(`pm`.`ItemCode`, ''),
                IFNULL(`w`.`Description`, '')) AS `detailed_search`
    FROM
        (((((((`bin` `b`
        LEFT JOIN `prMaster` `pm` ON ((`pm`.`prMasterID` = `b`.`prMasterID`)))
        LEFT JOIN `prDepartment` `dept` ON ((`dept`.`prDepartmentID` = `pm`.`prDepartmentID`)))
        LEFT JOIN `prCategory` `cat` ON ((`cat`.`prCategoryID` = `pm`.`prCategoryID`)))
        LEFT JOIN `rxMaster` `vend` ON ((`vend`.`rxMasterID` = `pm`.`rxMasterIDPrimaryVendor`)))
        LEFT JOIN `prWarehouse` `w` ON ((`w`.`prWarehouseID` = `b`.`prWarehouseID`)))
        LEFT JOIN `prWarehouseInventory` `wi` ON ((`wi`.`prWarehouseInventoryID` = `b`.`prWarehouseInventoryID`)))
        LEFT JOIN `prInventoryCount` `ic` ON ((`pm`.`prMasterID` = `ic`.`prMasterID`)))
    WHERE
        (`w`.`InActive` = 0)";
        
        
		if ( _prMasterID is NOT null and _prWarehouseID is null) THEN
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,'   '); END IF; 
				set @l_sql = CONCAT(@l_sql,' and `b`.`prMasterID` =', _prMasterID); 
				set commaNeeded =1;
			-- select * from v_INV_bin_warehouseRollup
			-- having prMasterID=_prMasterID;
	        
		ELSEif ( _prMasterID is null and _prWarehouseID is not null) THEN
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,'   '); END IF; 
				set @l_sql = CONCAT(@l_sql,' and  `b`.`prWarehouseID` =', _prWarehouseID); 
				set commaNeeded =1;
			-- select * from v_INV_bin_warehouseRollup
			-- having prWarehouseID=_prWarehouseID;

		ELSEif ( _prWarehouseID is NOT null and _prMasterID is NOT null) THEN
			IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,'   '); END IF; 
				set @l_sql = CONCAT(@l_sql,' and  `b`.`prWarehouseID` =', _prWarehouseID,'  and `b`.`prMasterID` =',_prMasterID); 
				set commaNeeded =1;
			-- select * from v_INV_bin_warehouseRollup
			-- having prMasterID=_prMasterID and prWarehouseID=_prWarehouseID;
            
		END IF;
        
        set @l_sql = CONCAT(@l_sql,'  GROUP BY `b`.`prWarehouseID` , `b`.`prMasterID`'); 
        PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
    
	ELSEIF (_action='PRODUCTROLLUP') THEN

        
		if ( _prMasterID is NOT null and _prWarehouseID is null) THEN

			select * from v_INV_bin_productRollup
			having prMasterID=_prMasterID;
	        
		ELSEif ( _prMasterID is null and _prWarehouseID is not null) THEN

			select * from v_INV_bin_productRollup
			having prWarehouseID=_prWarehouseID;

		ELSEif ( _prWarehouseID is NOT null and _prMasterID is NOT null) THEN

			select * from v_INV_bin_productRollup
			having prMasterID=_prMasterID and prWarehouseID=_prWarehouseID;
            
		END IF;
    
    END IF;
 
END$$

DELIMITER ;


-- ==================================
-- call getProduct('QSEARCH',null,null,'32.2');

DROP procedure IF EXISTS `INV_getProduct`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_getProduct`( 
   IN _action  varchar(25),
   IN _prMasterID INT,
   IN _prWarehouseID INT,
   IN _search VARCHAR(200)
)
INV_getProduct: BEGIN
DECLARE _prWarehouseInventoryID INT;
    IF (_action='QSEARCH-OPTIONS'  and _search is not null and _prMasterID is null) THEN
        IF (_prWarehouseID is not null) THEN
			select * from v_INV_product where concat(detailed_search,PrimaryVendor) like CONCAT('%',_search,'%') and prWarehouseID=_prWarehouseID  order by detailed_search;
        else
			select * from v_INV_product where concat(detailed_search,PrimaryVendor) like CONCAT('%',_search,'%')  order by detailed_search;
        END IF;
    END IF;
	IF (_action='QSEARCH'  and _search is not null and _prMasterID is null) THEN

		-- select *,CONCAT('\'%',_search,'%\'') from bin where searchName like CONCAT('%',_search,'%');
        
		IF (_prWarehouseID is not null) THEN
			select * from v_INV_product where detailed_search like CONCAT('%',_search,'%') and prWarehouseID=_prWarehouseID  order by detailed_search;
        else
			select * from v_INV_product where detailed_search like CONCAT('%',_search,'%') group by prMasterID order by detailed_search;
        END IF;

    ELSEIF(_action='TRANSFERQSEARCH' and _search is not null) THEN
        SELECT prWH.prTransferID, prWH.TransferDate, prWH.TransNumber,rm.City, CASE WHEN CONCAT(TransferDate,TransNumber, rm.City) LIKE CONCAT('%',_search,'%') THEN 
        'and' ELSE '' END AS result FROM prWHtransfer prWH , prWarehouse rm WHERE ReceivedDate IS NULL HAVING result != '' ORDER BY prWH.prTransferID DESC;
    END IF;
 
END$$

DELIMITER ;





-- ==================================
-- TODO  open curs will not work below, need to fix

DROP procedure IF EXISTS `INV_updateSequence`;

DELIMITER $$
CREATE PROCEDURE `INV_updateSequence`( 
	IN _action varchar(25),
    IN _binId INT,
   IN _prMasterID INT,
   IN _binSequence INT
)
INV_updateSequence: BEGIN
    DECLARE v_finished INT default 0;
    DECLARE iBinId INT ;
	DECLARE task_cursor CURSOR FOR select binId from bin where prMasterID = _prMasterID and binSequence > _binSequence ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    if(_action='DELETESEQ') THEN
		OPEN task_cursor;
			
		getTaskId : LOOP
		FETCH task_cursor INTO iBinId;
			IF(v_finished = 1) THEN
			CLOSE task_cursor;
			LEAVE getTaskId;
			END IF;
			update bin set binSequence = binSequence - 1 where binId = iBinId;
		END LOOP;
   
    ELSEIF(_action='UPDATESEQ') THEN 
		
        update bin set binSequence = _binSequence where binID = _binId;
        
    END IF;
END$$

DELIMITER ; 






/* Thsi procedure is no longer valid - it is located in the new place tp_auditinventory
-- =================================================

-- call INV_getBin('DETAILED-SEARCH',null,null,null,'DMSR0909');
-- call INV_updateInventoryOH('ADJUSTMENT',now(),null,1639,null, concat('DavidIA-',Date(now())) ,'Reason2',4,null,null,1);
-- call INV_updateInventoryOH('ADJUSTMENT',now(),null,1639,null, concat('DavidIA-',Date(now())) ,'Reason2',5,null,null,1);
-- call INV_updateInventoryOH('COUNT',now(),null,1639,null, concat('DavidIC-',Date(now())) ,'Cycle Count',10,null,null,1);
-- call INV_updateInventoryOH('TRANSFER',now(),now(),1639,550, concat('DavidIT-',Date(now())) ,'Reason2',1,null,null,5);
-- call INV_updateInventoryOH('TRANSFER-RECEIVE',null,null,null,null,null,null,null,_prTransferDetailID,null,1);
-- call INV_updateInventoryOH('TRANSFER-RECEIVE-UNDO',null,null,null,null,null,null,null,_prTransferDetailID,null,1);
-- call INV_updateInventoryOH('TRANSFER-CANCEL',null,null,null,null,null,null,null,_prTransferDetailID,null,1);
-- call INV_updateInventoryOH('RECEIVE-ITEM',null,null,binId,null,null,null,23,null,_vePODetailID,1);
-- call INV_updateInventoryOH('SALESORDER',null,null,null,null,null,null,null,null,_cuSODetailID,1);
-- call INV_updateInventoryOH('INVOICE',null,null,binId,null,null,null,23,null,_cuInvoiceID,1);

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
-- DECLARE _prTransferDetailID INT;
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
-- DECLARE _newVePODetailBinID INT;
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
     if ( _changedByID is null) THEN 
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updateInventoryOH:_changedByID missing';
		LEAVE INV_updateInventoryOH; 
	 END IF;

if (_action='SALESORDER') THEN

	set _journalID='SO';

	-- TODO check to see if this is a valid SO to adjust inventory.  
	-- if in the cuSODetail table then it should pull from inventory.

	-- TODO, need to write a script that creates records in the cuSODetailBin table.


	

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
   

 		set _whOH = 0;  -- this will hold total amount needed to reverse
		-- get list of cuSODetailID's to try and undo any allocations.
        select group_concat(cuSODetailBinID) into _binIds from cuSODetailBin where cuSODetailID=_lineItemDetailID; 
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
				
                delete from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;
				-- call FIX_tool("BIN_ALLOCATION",null,null,null,_aBinId);

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;        
 
 			call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,_whOH,0,'Sales Order Reverse Allocation',_changedByID,_VendorNumber,_refRelatedNo);

        
        -- get list of bins to loop and try to fill allocations
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
     
	-- before going on, make sure there is enough inventory
    select sum(allocated) into _lastAllocated from cuSODetailBin  where cuSODetailID = _cuSODetailID;
    select sum(InventoryOnHand), sum(InventoryAllocated) into _prOH,_prIA from bin where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID;
    if (_quantityChanged>(_prOH-_prIA)+ IFNULL(_lastAllocated,0)) THEN
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient Inventory to Invoice';
		LEAVE INV_updateInventoryOH; 
    END IF;
    
    -- select _prMasterID, _prFromWarehouseID, _InActive,_IsInventory, _quantityChanged, _quantityBilled, _cuSODetailID, _inventoryCost;
    
    
	if (_cuSODetailID is not null) THEN
		
        -- remove allocations
 		set _whOH = 0;  -- this will hold total amount needed to reverse
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
                    -- delete from cuSODetailBin where cuSODetailBinID = _acuSODetailBinId;
                END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_binIds, ',', 1))+2;
				SET _binIds = MID(_binIds, SubStrLen, strLen);
				IF (_binIds = '' or _binIds is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  
            

 			call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,0,_whOH,'Sales Order Reverse Allocation',_changedByID,null,null);
            
    END IF;
 
         -- add back in OH consumptions in case it has changed.
		set _glAmount = 0;
		set _whOH = 0;  -- this will hold total amount needed to reverse

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
				-- FYI no GL activity if the amount is zero.
				set _glAmount = -1*_glAmount*_inventoryCost;
				call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,null,null,null,_lineItemDetailID,_changedByID,null,null);
                
				call INV_updateInventoryLog('INSERT',_aBinId,_journalID,null,null,null,_whOH,0,'Customer Invoice Remove',_changedByID,null,null);
            END IF;
            
    
		-- Now put new OH in.
            
            
		set _prOH = _quantityBilled;
        set _lastOH = 0;
        set _lastAllocated = 0;
        set _lastAvailable = 0;
        
        -- get list of bins to loop and try to debit on hands
        set _binIds = null;
        
		select group_concat(binId) into _binIds from bin where prMasterID=_prMasterID and prWarehouseID=_prFromWarehouseID order by binSequence; 
        
        do_this:
		   LOOP
				SET strLen = CHAR_LENGTH(_binIds);
				set _aBinId=SUBSTRING_INDEX(_binIds, ',', 1);
				
                if(_prOH=_quantityBilled) THEN set _fromBinID = _aBinId; END IF;
               
				select InventoryOnHand,InventoryAllocated,(InventoryOnHand-InventoryAllocated) into _lastOH,_lastAllocated,_lastAvailable from bin where binId = _aBinId;
				if (_lastAvailable >= _prOH) THEN
					-- assign everything
					call INV_updateOH('ADJUST',_aBinId,(-1*_prOH),null,null,_changedByID);
                    insert into cuInvoiceDetailBin (cuInvoiceDetailID,binId,QuantityBilled) values (_lineItemDetailID,_aBinId,_prOH);
                    set _prOH = 0;
                ELSE
					-- assign partial
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
			call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,null,null,null,_lineItemDetailID,_changedByID,null,null);
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

-- select _fromBinID,_prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_quantityChanged,_lastOH,(_quantityChanged-_lastOH),_prOH,_prIA,_prIOO, _whOH,_whIA,_whIOO,_lastOH;
	
 	-- update the prWHtransfer, determine if this is a new batch.
    select prTransferID into _prTransferId from prWHtransfer where 
    -- TransferDate= _transferDate and 
	Description=_reference and reasonCode =_resonCode and Date(CreatedOn) = Date(now()) and prFromWareHouseID = _prFromWarehouseID;
    
    if(_prTransferId is null) THEN
		
        insert into prWHtransfer (TransferDate,prFromWareHouseID,Description,reasonCode,screenno,CreatedOn,CreatedById) values 
		(now(),_prFromWarehouseID,_reference,_resonCode,2,Date(now()),_changedByID);
		SELECT LAST_INSERT_ID() INTO _prTransferId;
    
    END IF;
    
    if(_prTransferId is not null) THEN
		UPDATE prWHtransfer SET TransferDate = now()  WHERE prTransferID = _prTransferId;
	end if;
   
	-- select Description, ItemCode, AverageCost into _description,_itemcode,_inventoryCost from prMaster where prMasterID=_prMasterID;

	-- this could be a positive or negative number.  The gl will handle
	--  set _reference = _prTransferId;
    set _glAmount = ((_quantityChanged-_lastOH)*_inventoryCost);
	call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,_reference,_prTransferId,null,null,_changedByID,null,null);

 
	
    -- select prTransferDetailID into _prTransferDetailID from prWHtransferDetail where  prTransferId=_prTransferId  and fromBinId =_fromBinID limit 1;
    
    -- if (_prTransferDetailID is null) THEN
		insert into prWHtransferDetail (prTransferID,prMasterID,Description,QuantityTransfered,InventoryCost,QuantityAvailable,ItemCode,difference,fromBinId) values 
		(_prTransferId,_prMasterID,_description,_quantityChanged,_inventoryCost,_lastOH,_itemcode,(_quantityChanged-_lastOH),_fromBinID);
		SELECT LAST_INSERT_ID() INTO _prTransferDetailID;
	-- ELSE
	-- 	update prWHtransferDetail set QuantityTransfered= _quantityChanged, difference=(_quantityChanged-_lastOH) where prTransferDetailID = _prTransferDetailID;
    -- END IF;

	
    

	call INV_updateOH('REPLACE',_fromBinID,_quantityChanged,_lastAllocated,null,_changedByID);

    call INV_updateInventoryLog('INSERT',_fromBinID,_journalID,_prTransferId,_prTransferDetailID,_prTransferId,_quantityChanged,0,'IA Created',_changedByID,null,null);

-- 	select *,_prTransferDetailID as prTransferDetailID, _prTransferId as prTransferId from v_INV_bin where binId=_fromBinID;


	 select * from v_INV_WHtransferDetail where prTransferID = _prTransferId;

ELSEIF (_action='TRANSFER-RECEIVE-UNDO') THEN 

	set _journalID='TR';

	-- check to see if product is actually recived
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

	 -- need to revers OH in the fromBin and insert revers gl.
	-- set _reference = _prTransferId;
    set _glAmount = -1*_quantityChanged*_inventoryCost;
	call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,_prToWarehouseID,_reference,_reference,null,null,_changedByID,null,null);

    
	

    
	


	
	call INV_updateOH('ADJUST',_fromBinID,_quantityChanged,_quantityChanged,null,_changedByID);
   
    
    call INV_updateOH('ADJUST',_toBinID,(-1*_quantityChanged),null,null,_changedByID);
    
    select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
        
	update bin set inTransfer = inTransfer+_quantityChanged where binId = _virtualbinId;

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

	-- update prWHtransferDetail set QuantityTransfered=0, Description='Canceled' where prTransferDetailID=_prTransferDetailID;
    
	

	 
	
   --  set _glAmount = _quantityChanged*_inventoryCost;
	-- call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,null,_prFromWarehouseID,_reference,_reference,null,null,_changedByID,null,null);

	call INV_updateOH('ADJUST',_fromBinID,null,(-1*_quantityChanged),null,_changedByID);
    
	
	-- call INV_updateOH('ADJUST',_toBinID,null,(-1*_quantityChanged),null,_changedByID);

    call INV_updateInventoryLog('INSERT',_fromBinID,_journalID,_prTransferId,_prTransferDetailID,_reference,0,_quantityChanged,'TR Cancel',_changedByID,null,null);
	select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
        
        update bin set inTransfer = inTransfer-_quantityChanged where binId = _virtualbinId;
   --  update prWHtransferDetail set ReceivedDate=null where prTransferDetailID=_prTransferDetailID;
	
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
    
    select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
        
        update bin set inTransfer = inTransfer-_quantityChanged where binId = _virtualbinId;
    
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

	-- select prWarehouseID,prWarehouseInventoryID into _prToWarehouseID,_prToWarehouseInventoryID from bin where binId=_toBinID;

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
    
    select prTransferDetailID into _prTransferDetailID from prWHtransferDetail where prTransferId=_prTransferId and fromBinId =_fromBinID ; -- and toBinId =_toBinID

		set _reference = _transNumber;
	-- 	 set _glAmount = _quantityChanged*_inventoryCost;
	-- 	call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,_reference,_reference,null,null,_changedByID,null,null);


		insert into prWHtransferDetail (prTransferID,prMasterID,Description,QuantityTransfered,InventoryCost,QuantityAvailable,ItemCode,difference,fromBinId,toBinId) values 
		(_prTransferId,_prMasterID,_description,_quantityChanged,_inventoryCost,(_lastOH-_lastAllocated),_itemcode,(_quantityChanged-_lastOH),_fromBinID,null);
		SELECT LAST_INSERT_ID() INTO _prTransferDetailID;

		

		
		

		call INV_updateOH('ADJUST',_fromBinID,null,_quantityChanged,null,_changedByID);
        
        select binId into _virtualbinId from bin where prWarehouseID = _prFromWarehouseID and prMasterID is null and inTransfer is not null;
        
        update bin set inTransfer = inTransfer+_quantityChanged where binId = _virtualbinId;

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
		call GL_updateGLTransaction('INSERT',null,_journalID,_glAmount,_prFromWarehouseID,null,_glDescription,_reference,_veReceiveDetailBinID,_lineItemDetailID,_changedByID,null,null);
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

-- ==============================================  END updateInventoryOH
*/


-- ==============================================
-- CREATE DEFINER=`root`@`%` PROCEDURE `GL_updateGLTransaction`(
-- ==============================================
-- MOVED TO TP_AVG_COST script


-- ==============================================
-- call GL_reverseGLTransaction(null,'142943',5);

DROP procedure IF EXISTS `GL_reverseGLTransaction`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `GL_reverseGLTransaction`(
	IN _action varchar(25),
    IN _reference varchar(255),
    IN _changedByID INT,
    IN _veBillID INT,
    IN _journalId VARCHAR(25),
    IN _isInvoiceDatechanged INT,
    IN _LastinvoiceDate date
   
)
GL_reverseGLTransaction : BEGIN    

DECLARE _changedByName varchar(255);
-- DECLARE _veBillID INT;
DECLARE _coLedgerSourceID INT;
DECLARE _coFiscalYearId INT;
DECLARE _coFiscalPeriodId INT;
DECLARE _glTransactionId INT;
DECLARE _glTransactionReversedId INT;
DECLARE _period INT;
DECLARE _fyear varchar(25);
DECLARE _pStartDate DATETIME;
DECLARE _pEndDate DATETIME;
DECLARE _yStartDate DATETIME;
DECLARE _yEndDate DATETIME;
DECLARE _journalDesc varchar(50);    
DECLARE _debit_coAccountId  int;
DECLARE _debit_coAccountNumber varchar(255);
DECLARE _debit_transDesc varchar(255);
DECLARE _debit_reference varchar(255);
DECLARE _glTransactions longtext;
-- DECLARE _journalId varchar(25);
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _debit decimal(19,4);
DECLARE _credit decimal(19,4);
DECLARE _alreadyReversed  int;
DECLARE _transactionDate DATE;    
DECLARE _createdOn date;

DECLARE _UsePostDate INT;
DECLARE _permissiontoPreviousPeriod INT;
DECLARE _isAdmin INT;
DECLARE _isPeriodOpenStatus INT;
SET SESSION group_concat_max_len = 1000000; 
	-- select glTransactionID into _alreadyReversed from glTransaction t where reference = _reference and locate('REVERSED',transactionDesc)=0 limit 1;

	-- if (_alreadyReversed is not null) THEN
	-- 	leave GL_reverseGLTransaction;
    -- END IF;
    
	
select ifnull(FullName,_changedByID) into _changedByName from tsUserLogin where UserLoginID = _changedByID;

 select UsePostDate into _UsePostDate from veBill where veBillID = _veBillID;
IF (_journalId='CI') THEN
	select CreatedOn into _createdOn from cuInvoice WHERE cuInvoiceID=_veBillID ;
	IF(_isInvoiceDatechanged = 1) then 
		-- SELECT InvoiceDate INTO _transactionDate  FROM cuInvoice WHERE cuInvoiceID=_veBillID;
        set _transactionDate =  _LastinvoiceDate;
	-- elseif(date(_createdOn) = date(now())) then
    -- SELECT InvoiceDate INTO _transactionDate  FROM cuInvoice WHERE cuInvoiceID=_veBillID;
     ELSE
		 SET _transactionDate=NOW();
	 END IF;
ELSEIF(_journalId='VB' and _UsePostDate=1) then
		SELECT PostDate INTO _transactionDate  FROM veBill WHERE veBillID=_veBillID;
ELSE
	SET _transactionDate=NOW();
END IF;

	SELECT p.coFiscalPeriodID, p.coFiscalYearID, p.period, p.StartDate AS pStartDate,p.EndDate AS pEndDate,y.StartDate AS yStartDate,y.EndDate AS yEndDate,y.fiscalYear
	INTO
	_coFiscalPeriodId,_coFiscalYearId,_period,_pStartDate,_pEndDate,_yStartDate,_yEndDate,_fyear
	FROM coFiscalPeriod p
	LEFT JOIN coFiscalYear `y` ON (y.coFiscalYearID = p.coFiscalYearID)
	WHERE DATE(_transactionDate) >= DATE(p.StartDate) AND DATE(_transactionDate) <= DATE(p.EndDate) AND p.openStatus=1
	ORDER BY p.StartDate DESC LIMIT 1;

	-- HANDLE REVERSAL IF NEEDED
	-- if (_reference is not null and LENGTH(_reference) > 1) THEN
	
		-- select group_concat(glTransactionID) into _glTransactions from glTransaction t where reference = _reference and locate('REVERSED',transactionDesc)=0;
		
		-- SELECT GROUP_CONCAT(DISTINCT t.glTransactionId) INTO _glTransactions 
		-- FROM glTransaction t 
		-- LEFT JOIN glLinkage l ON(t.glTransactionId=l.glTransactionId)
		-- WHERE t.reference =_reference AND l.status=0 ;

		SELECT GROUP_CONCAT(DISTINCT t.glTransactionId) INTO _glTransactions 
		FROM glLinkage l
		LEFT JOIN glTransaction t ON(l.glTransactionId=t.glTransactionId)
		WHERE l.veBillId=_veBillID AND t.journalId=_journalId AND l.status=0 ;

		 do_this:
		   LOOP
				set _glTransactionId = null;
				SET strLen = CHAR_LENGTH(_glTransactions);
				set _glTransactionId=SUBSTRING_INDEX(_glTransactions, ',', 1);
               
				select 
                l.veBillID,l.coLedgerSourceId,
				-- g.coFiscalPeriodId,g.period,g.pStartDate,g.pEndDate,g.coFiscalYearId,g.fyear,g.yStartDate,g.yEndDate,
                g.journalId,g.journalDesc,g.coAccountId,g.coAccountNumber,g.reference,g.transactionDesc,
                IFNULL(g.debit,0),IFNULL(g.credit,0)
                into
                _veBillID,_coLedgerSourceId,
				-- _coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,
                _journalId,_journalDesc,_debit_coAccountId,_debit_coAccountNumber,_debit_reference,_debit_transDesc,
                -- REVERSED                
                _credit,_debit                
                from glTransaction g left join glLinkage l on (l.glTransactionID = g.glTransactionID)
                where g.glTransactionID = _glTransactionId;
		
		set _glTransactionReversedId = _glTransactionId;

		if (_credit>0 or _debit>0) THEN
			UPDATE glLinkage SET STATUS=1 WHERE glTransactionID = _glTransactionId;

			insert into glTransaction (coFiscalPeriodId,period,pStartDate,pEndDate,coFiscalYearId,fyear,yStartDate,yEndDate,entrydate,enteredBy,coAccountId,coAccountNumber,transactionDesc,transactionDate,debit,credit,reference,journalId,journalDesc)
			values (_coFiscalPeriodId,_period,_pStartDate,_pEndDate,_coFiscalYearId,_fyear,_yStartDate,_yEndDate,now(),_changedByName,_debit_coAccountId,_debit_coAccountNumber,_debit_transDesc,_transactionDate,_debit,_credit,_debit_reference,_journalId,_journalDesc);

			SELECT LAST_INSERT_ID() INTO _glTransactionId;

			insert into glLinkage (entrydate,glTransactionid,status,coLedgerSourceId,veBillID) values (now(),_glTransactionId,1,_coLedgerSourceID,_veBillID);

			-- reversal helps to make sure a reversal does not happen again for a glTransaction
			insert into glTransactionReversal (glTransactionId,glTransactionReversedId,transactionDesc,enteredBy)
			values (_glTransactionId,_glTransactionReversedId,_debit_transDesc,_changedByID);

		END IF;
        
				
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_glTransactions, ',', 1))+2;
				SET _glTransactions = MID(_glTransactions, SubStrLen, strLen);
				IF (_glTransactions = '' or _glTransactions is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;  
            
            
	-- END IF;
	
    -- END REVERSAL
    
    
END$$

DELIMITER ;




-- ==============================================
-- call INV_getTransferHistory('ADJUSTMENT-DETAILS',7681,null);
-- call INV_getTransferHistory('TRANSFER-DETAILS',7681,null);
-- call INV_getTransferHistory('ADJUSTMENT-HISTORY',null,null);
-- call INV_getTransferHistory('TRANSFER-HISTORY',null,null);
-- call INV_getTransferHistory('TRANSFER-HISTORY',null,null);
-- call INV_getTransferHistory('TRANSFER-DETAILS',null,null);
-- call INV_getTransferHistory('TRANSFER-QSEARCH',null,'test');
-- call INV_getTransferHistory('TRANSFER-SEARCH',null,'12x1');

DROP procedure IF EXISTS `INV_getTransferHistory`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_getTransferHistory`(
	IN _action varchar(25),
    IN _prTransferID INT,
	IN _search varchar(25),
	IN _vePODetailID INT ,
    IN _status varchar(25)
)
INV_getTransferHistory : BEGIN
	
    if (_action='ADJUSTMENT-HISTORY') THEN
		select * from v_INV_WHtransfer where screenno = 2 OR screenno = -2 order by transferDate DESC limit 300;        
	ElSEIF (_action='ADJUSTMENT-DETAILS' or _action='TRANSFER-DETAILS' and _prTransferID is not null) THEN
		select * from v_INV_WHtransferDetail where prTransferID = _prTransferID;
	ElSEIF (_action='TRANSFER-HISTORY' and _prTransferID is  null) THEN
			if(_status = "RECEIVED") then 
				select * from v_INV_WHtransfer where screenno = 1 and (sessionStatus = "Received" or sessionStatus = "No Transfers") order by transferDate DESC, descr ASC limit 300;  
			elseif(_status = "NON-RECEIVED") then
				select * from v_INV_WHtransfer where screenno = 1 and (sessionStatus = "Partial" or sessionStatus = "") order by transferDate DESC, descr ASC limit 300; 
			end if;
    ElSEIF (_action='TRANSFER-HISTORY' and _prTransferID is not null) THEN
		select * from v_INV_WHtransfer where screenno = 1 and prTransferId=_prTransferID; 
    ElSEIF (_action='TRANSFER-HISTORY-SEARCH' and _prTransferID is null) THEN
		select * from v_INV_WHtransfer where screenno = 1 and concat(descr,TransNumber,prTransferId) like CONCAT('%',_search,'%')   order by transferDate DESC, descr ASC;    
	ElSEIF (_action='TRANSFER-DETAILS') THEN
		select * from v_INV_WHtransferDetail where prTransferID = _prTransferID;    
	ElSEIF (_action='TRANSFER-QSEARCH' and _search is not null ) THEN
		
        select * from v_INV_WHtransfer where screenno = 1 and concat(descr,TransNumber) like CONCAT('%',_search,'%')   order by transferDate DESC, descr ASC; 
        
	ElSEIF (_action='TRANSFER-SEARCH' ) THEN

		select distinct (prTransferId) as tid,d.* from v_INV_WHtransferDetail d where concat(descr,TransNumber,description,itemCode) like CONCAT('%',_search,'%');
    ElSEIF (_action='QTY-BILLED' ) THEN
        select QuantityBilled from veBillDetail where vePODetailID=_vePODetailID;
	END IF;
   
END$$

DELIMITER ;


-- ==============================================

DROP procedure IF EXISTS `INV_updatePrMaster`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_updatePrMaster`(
	IN _action varchar(25),
    IN _prMasterID INT,
    IN _itemCode varchar(100),
    IN _description varchar(1000),
    IN _departmentName INT,
    IN _categoryName INT,
    IN _boxName decimal(19,4),
    In _weightName INT,
    In _ounces INT,
    In _sellingPriceName decimal(19,4),
    In _multiplierName decimal(19,4),
    In _factoryCostName decimal(19,4),
    In _productSiteName varchar(10000),
    In _primaryVendorName varchar(1000),
    In _vendorItemCodeName varchar(1000),
    In _vendorName Int,
	In _salesOrderSelectedName varchar(10000),
	In _invoiceSelectedName varchar(10000),
	In _purchaseOrderSelectedName varchar(10000),
    In _inactive INT,
    In _inventory INT,
    In _taxable INT,
    In _singleItem INT,
    in _RetailName decimal(19,4),
	IN _special1Name decimal(19,4),
	In _wholeSaleName decimal(19,4),
	In _distributorName decimal(19,4),
	In _dealerName decimal(19,4),
	In _special2Name decimal(19,4),
    In _overName decimal(19,4),
    In _QuantityName decimal(19,4),
    In _secVendorName1 Int,
    In _secVendorItemCodeName1 varchar(1000),
    In _secVendorName2 Int,
    In _secVendorItemCodeName2 varchar(1000),
    In _secVendorName3 Int,
    In _secVendorItemCodeName3 varchar(1000),
    In _secVendorName4 Int,
    In _secVendorItemCodeName4 varchar(1000),
    IN _changedByID INT
)
INV_updatePrMaster:BEGIN

declare _weight decimal(19,4);
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE strLen2    INT DEFAULT 0;
DECLARE SubStrLen2 INT DEFAULT 0;
DECLARE _inventories text;
DECLARE _prWarehouseID INT DEFAULT 0;
DECLARE _counter INT default 0;
DECLARE _count INT default 0;
 DECLARE _max int;
 
DECLARE _trasactionStatus INT;
declare _newTransactionStatus int;
declare _existingTranStauts int;
DECLARE _cusoPrmasterIDs TEXT;
DECLARE _cusoPrmasterID INT;
DECLARE _cuSODetailIDs TEXT;
DECLARE _cuSODetailID INT;
DECLARE _cusoQuantityOrdereds TEXT;
declare _cusoQuantityOrdered decimal(19,4);
DECLARE _QuantityOrdered DECIMAL(19,4);
DECLARE _prMstID INT;

set _newTransactionStatus = _departmentName;
set _existingTranStauts = _categoryName;
		 if ( _changedByID is null) THEN 
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_updatePrMaster:_changedByID missing';
				LEAVE INV_updatePrMaster; 
		END IF;
		if (_max is null or _max=0) THEN set _max=1000000; END IF;
		if(_ounces is null) then
					set _ounces = 00;
				elseif(length(_ounces) = 1) then
					set _ounces = concat(0,_ounces);
				else
					set _ounces= _ounces;
				end if;
                
                set _weight = concat(_weightName,".",_ounces);
                SELECT CAST(_weight AS DECIMAL(19,4)) into _weight;
        
        if(_action = 'UPDATE') THEN
			if(_prMasterID is null) then
            
				
                
                insert into prMaster (prDepartmentID,prCategoryID,ItemCode,Description,InActive,IsInventory,BoxQty,Weight,Website,POMult,SalesPrice00,LastCost,
                SOPopup,POPopup,CUPopup,QuantityBreak0,QuantityBreak1,SalesPrice01,SalesPrice10,SalesPrice20,SalesPrice30,SalesPrice40,SalesPrice50,IsTaxable,
                SingleItemTax,VendorItemNumber,rxMasterIDPrimaryVendor,VendorItemNumber01,VendorItemNumber02,VendorItemNumber03,VendorItemNumber04,
                rxMasterIDSecondaryVendor01,rxMasterIDSecondaryVendor02,rxMasterIDSecondaryVendor03,rxMasterIDSecondaryVendor04,CreatedOn,CreatedByID,LastUpdatedTime) 
                values (_departmentName,_categoryName,_itemCode,_description,_inactive,_inventory,_boxName,_weight,_productSiteName,_multiplierName,_sellingPriceName,_factoryCostName,
                _salesOrderSelectedName,_purchaseOrderSelectedName,_invoiceSelectedName,_QuantityName,_overName,
                _RetailName,_dealerName,_distributorName,_wholeSaleName,_special1Name,_special2Name,_taxable,_singleItem,_vendorItemCodeName,
                _vendorName,_secVendorItemCodeName1,_secVendorItemCodeName2,_secVendorItemCodeName3,_secVendorItemCodeName4,_secVendorName1,_secVendorName2,
                _secVendorName3,_secVendorName4,now(),_changedByID,now());
                
                SELECT LAST_INSERT_ID() INTO _prMasterID;
                
                if(_prMasterID is not null) then
					select group_concat(i.prWarehouseID) into _inventories from prWarehouse i;
                    if (_inventories is not null )  THEN
						 do_this:
							LOOP
								 SET strLen = CHAR_LENGTH(_inventories);
                                 set _prWarehouseID=SUBSTRING_INDEX(_inventories, ',', 1);
                                 
                                 insert into prWarehouseInventory (prMasterID,prWarehouseID,LastUpdatedTime) values (_prMasterID,_prWarehouseID,now());
                                 
                                 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_inventories, ',', 1))+2;
								SET _inventories = MID(_inventories, SubStrLen, strLen);
                                set _counter = _counter+1;
                                IF _inventories = '' or _inventories is null or _counter > _max THEN
									LEAVE do_this;
								END IF;
                                END LOOP do_this;
					end if;
					select * from prMaster where prMasterID = _prMasterID;
                    call INV_createBinsFromWarehouseInventory('PRODUCT',_prMasterID,null);
				end if;
				 
			end if;
            if(_prMasterID is not null) then
				
                update prMaster set prDepartmentID=_departmentName,prCategoryID=_categoryName,ItemCode=_itemCode,Description=_description,InActive=_inactive,IsInventory=_inventory,
					BoxQty=_boxName,Weight=_weight,Website=_productSiteName,POMult=_multiplierName,SalesPrice00=_sellingPriceName,LastCost=_factoryCostName,
					SOPopup=_salesOrderSelectedName,POPopup=_purchaseOrderSelectedName,CUPopup=_invoiceSelectedName,QuantityBreak0=_QuantityName,
					QuantityBreak1=_overName,SalesPrice01=_RetailName,SalesPrice10=_dealerName,SalesPrice20=_distributorName,SalesPrice30=_wholeSaleName,
					SalesPrice40=_special1Name,SalesPrice50=_special2Name,IsTaxable=_taxable,SingleItemTax=_singleItem,VendorItemNumber=_vendorItemCodeName,rxMasterIDPrimaryVendor=_vendorName,
					VendorItemNumber01=_secVendorItemCodeName1,VendorItemNumber02=_secVendorItemCodeName2,VendorItemNumber03=_secVendorItemCodeName3,VendorItemNumber04=_secVendorItemCodeName4,
					rxMasterIDSecondaryVendor01=_secVendorName1,rxMasterIDSecondaryVendor02=_secVendorName2,rxMasterIDSecondaryVendor03=_secVendorName3,rxMasterIDSecondaryVendor04=_secVendorName4,LastUpdatedTime=now()
                where prMasterID = _prMasterID;

				 select * from prMaster where prMasterID = _prMasterID;
				  if(_inventory = 1) then
					 call INV_createBinsFromWarehouseInventory('PRODUCT',_prMasterID,null);
				end if;
            end if;
		elseif(_action = 'UPDATE_ALLOCATION') then

			select transactionStatus into _trasactionStatus from cuSO where cuSOID = _prMasterID;
            if(_newTransactionStatus != _existingTranStauts && _newTransactionStatus != _trasactionStatus) then
				update cuSO set transactionStatus = _newTransactionStatus where cuSOID = _prMasterID;
			end if;
			if(_newTransactionStatus != 1) then
				select group_concat(prMasterID), group_concat(QuantityOrdered) into _cusoPrmasterIDs,_cusoQuantityOrdereds  from cuSODetail where cuSOID = _prMasterID;
				do_this:LOOP
					SET strLen = CHAR_LENGTH(_cusoPrmasterIDs);
					set _cusoPrmasterID=SUBSTRING_INDEX(_cusoPrmasterIDs, ',', 1);
                    
					SET strLen2 = CHAR_LENGTH(_cusoQuantityOrdereds);
					set _cusoQuantityOrdered=SUBSTRING_INDEX(_cusoQuantityOrdereds, ',', 1);
                    
                    
					-- get previous InventoryAllocated from prMaster
					
						if(_newTransactionStatus != _existingTranStauts and _newTransactionStatus is not null && _trasactionStatus != _newTransactionStatus) then
							update prMaster set InventoryAllocated = InventoryAllocated - _cusoQuantityOrdered where prMasterID = _cusoPrmasterID;
                        end if;
						SET SubStrLen2 = CHAR_LENGTH(SUBSTRING_INDEX(_cusoQuantityOrdereds, ',', 1))+2;
						SET _cusoQuantityOrdereds = MID(_cusoQuantityOrdereds, SubStrLen2, strLen2);
							
						SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_cusoPrmasterIDs, ',', 1))+2;
						SET _cusoPrmasterIDs = MID(_cusoPrmasterIDs, SubStrLen, strLen);
						IF (_cusoPrmasterIDs = '' or _cusoPrmasterIDs is null) THEN
							LEAVE do_this;
						END IF;
				END LOOP do_this;
			else
            
            
				select group_concat(cuSODetailID) into _cuSODetailIDs  from cuSODetail where cuSOID = _prMasterID;
				-- select _cuSODetailIDs;
				do_that:LOOP
					SET strLen = CHAR_LENGTH(_cuSODetailIDs);
					set _cuSODetailID=SUBSTRING_INDEX(_cuSODetailIDs, ',', 1);
					-- select _cuSODetailID;
					select QuantityOrdered,prMasterID into _QuantityOrdered,_prMstID from cuSODetail where cuSODetailID = _cuSODetailID;
					-- select _QuantityOrdered,_prMstID;
                    
				-- get previous InventoryAllocated from prMaster
				
				
					update prMaster set InventoryAllocated = InventoryAllocated + _QuantityOrdered where prMasterID = _prMstID;
					-- select InventoryAllocated from prMaster where prMasterID = _prMstID;
							
						SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_cuSODetailIDs, ',', 1))+2;
						SET _cuSODetailIDs = MID(_cuSODetailIDs, SubStrLen, strLen);
						IF (_cuSODetailIDs = '' or _cuSODetailIDs is null) THEN
							LEAVE do_that;
						END IF;
				END LOOP do_that;
			END IF;
      
        end if;
END$$

DELIMITER ;


/* procidure no longer valid - latest version is in tp_auditinventory
-- ==============================================
-- call INV_updateOH('ADJUST',48,5,5,null,1);
-- call INV_updateOH('REPLACE',48,10,10,10,1);
-- call INV_updateOH('ADJUST',48,2,2,2,1);

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

	-- if (_adjustAllocated is null) THEN set _adjustAllocated=0; END IF;
	-- if (_adjust is null) THEN set _adjust=0; END IF;
	-- if (_adjustOnOrder is null) THEN set _adjustOnOrder=0; END IF;
	
	select prMasterID,prWarehouseID,prWarehouseInventoryID,InventoryOnHand,InventoryAllocated,InventoryOnOrder 
    into _prMasterID,_prFromWarehouseID,_prFromWarehouseInventoryID,_lastOH,_lastAllocated,_lastOnOrder 
    from bin where binId=_binID;



	if ( _action = 'ADJUST' ) THEN
		set _quantityChanged = _lastOH + ifnull(_adjust,0);
		set _quantityChangedAllocated = _lastAllocated + ifnull(_adjustAllocated,0);
		
		-- NOTE: OnOrder field is DEPRECATED
		-- if (_adjustOnOrder>0) THEN set _adjustOnOrder=0; END IF;
		-- set _quantityChangedOnOrder = _lastOnOrder + _adjustOnOrder;
		set _quantityChangedOnOrder=0;
    ELSEIF( _action = 'REPLACE' ) THEN
		set _quantityChanged = _adjust;
 		set _quantityChangedAllocated = _adjustAllocated;
 		set _quantityChangedOnOrder = _adjustOnOrder;
    END IF;
	
	if (_quantityChanged<0) THEN set _quantityChanged = 0; END IF;
	-- if (_quantityChangedAllocated<0) THEN set _quantityChangedAllocated = 0; END IF;
	-- NOTE: we are deprecating OnOrder, so modify code to reduce over time, but not add.
	-- if (_quantityChangedOnOrder<0) THEN set _quantityChangedOnOrder = 0; END IF;

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

				-- select @l_sql;
					
				PREPARE stmt FROM @l_sql;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
				
			END IF;
            
    -- dangerous, need to build a script that creates bins for each product.
    select sum(InventoryOnHand),sum(InventoryAllocated),sum(InventoryOnOrder) into _prOH,_prIA,_prIOO from bin where prMasterID = _prMasterID;
    
    update prMaster set InventoryOnHand = _prOH,InventoryAllocated=_prIA,InventoryOnOrder=_prIOO, LastUpdatedTime=now() where prMasterID=_prMasterID;
	
    select sum(InventoryOnHand),sum(InventoryAllocated),sum(InventoryOnOrder) into _whOH,_whIA,_whIOO from bin where prMasterID = _prMasterID and prWarehouseID=_prFromWarehouseID;

   
    
	update prWarehouseInventory set InventoryOnHand = _whOH,InventoryAllocated=_whIA,InventoryOnOrder=_whIOO, LastUpdatedTime=now() where prWarehouseInventoryID=_prFromWarehouseInventoryID;
   

		-- need to update tpInventoryLogMaster
		-- need to update tpInventoryLog

END$$

DELIMITER ;
*/



-- ==============================================
DROP procedure IF EXISTS `INV_updateInventoryLog`;

DELIMITER $$



-- =====================================================
-- call INV_updateInventoryLog('INSERT',48,'IA',123,123456,'Cycle Count Kinetics 11/27/19 Dallas',10,5,'IA Created',1);
-- call INV_updateInventoryLog('INSERT',48,'IT',123,123456,'prodout',10,0,'IA Created',1);
-- call INV_updateInventoryLog('INSERT',48,'IT',123,123456,'prodin',0,10,'IA Created',1);
-- call INV_updateInventoryLog('INSERT',48,'IT',123,123456,'prodin',0,10,'IA ReceiveItems',1);


CREATE DEFINER=`root`@`%` PROCEDURE `INV_updateInventoryLog`(
	IN _action varchar(25),
    IN _binID INT,
    IN _transType varchar(25),
    IN _transferID INT,
    IN _transferDetailID INT,
    IN _referenceNo varchar(100),
    IN _qtyOut decimal(19,4),
    IN _qtyIn decimal(19,4),
    IN _transDescription varchar(100),
    IN _changedByID INT,
	IN _VendorNumber varchar(25),
    IN _refRelatedNo varchar(25)
)
INV_updateInventoryLog : BEGIN
DECLARE _prMasterID INT;
DECLARE _prWarehouseID INT;
DECLARE _ItemCode varchar(255);
DECLARE _whDescription varchar(255);
DECLARE _prWarehouseName varchar(255);
DECLARE _InventoryOnHand  decimal(19,4);
DECLARE _whInventoryOnHand  decimal(19,4);
DECLARE _InventoryAllocated  decimal(19,4);
DECLARE _InventoryOnOrder  decimal(19,4);
DECLARE _receiveDate datetime;

if ((_transType = 'TR' or _transType = 'IR') and _qtyIn>0) THEN set _receiveDate = Date(now()); end if;
if( _transType = 'RI' ) THEN set _receiveDate = Date(now()); end if; 

if (_qtyOut =0 and _qtyIn=0) THEN
		leave INV_updateInventoryLog;
END IF;

select 
prMasterID, ItemCode,prWarehouseID, whDescription, prInventoryOnHand ,whInventoryAllocated,whInventoryOnOrder,whInventoryOnHand 
into
_prMasterID, _ItemCode,_prWarehouseID, _whDescription, _InventoryOnHand ,_InventoryAllocated,_InventoryOnOrder, _whInventoryOnHand
from v_INV_bin where binID = _binID;

SELECT IFNULL(SUM(QuantityOrdered - QuantityReceived),0) INTO _InventoryOnOrder  FROM vePODetail d
LEFT JOIN vePO p ON (p.vePOID = d.vePOID)
 WHERE QuantityOrdered > QuantityReceived
 AND joReleaseID IS NULL
 AND p.vePOID IS NOT NULL
 AND p.prWarehouseID=_prWarehouseID
 AND prMasterID=_prMasterID;

insert into  tpInventoryLogMaster
(prMasterID,productCode,warehouseID,warehouseName,onHand,wrOnHand,allocated,onOrder,
transType,transID,transDetailID,referenceNo,productOut,productIn,transDecription,userId,createdOn,receiveDate,vendorNumber,refRelatedNo)
 values
( _prMasterID,_itemCode,_prWarehouseID,_whDescription,_InventoryOnHand,_whInventoryOnHand, _InventoryAllocated,_InventoryOnOrder,
 _transType,_transferID,_transferDetailID,_referenceNo,_qtyOut,_qtyIn,_transDescription,_changedByID, now(), _receiveDate,_VendorNumber,_refRelatedNo);
 

insert into tpInventoryLog
(prMasterID,productCode,warehouseID,transType,transID,transDetailID,productOut,productIn,transDecription,userId,createdOn)
values
(_prMasterID,_itemCode,_prWarehouseID,_transType,_transferID,_transferDetailID,_qtyOut,_qtyIn,_transDescription,_changedByID, now()
); 
 

END$$

DELIMITER ;




-- =========================================================
-- call INV_getPO('RECEIVE', null,null,null,null);

DROP procedure IF EXISTS `INV_getPO`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_getPO`(
IN _action  varchar(25),
IN _searchData varchar(25), 
IN _dateFrom  varchar(25),
IN _dateTo varchar(25),
IN _poNumber int

)
INV_getPO : BEGIN

	if ( _action is null) THEN 
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_getPO:_action missing';
		LEAVE INV_getPO; 
	END IF; 
    
	
IF(_poNumber is not null) then           
           if(_action='RECEIVE') then
           select * from v_INV_getPO where ponumber=_poNumber and difference = 0 and TransactionStatus <> -1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
           else
           select * from v_INV_getPO where ponumber=_poNumber and difference <> 0  and TransactionStatus = 1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
           end if;
ELSE 
     
	IF(_searchData is not null) then
       
        select * from v_INV_getPO where detailSearch like CONCAT('%',_searchData,'%')  and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
	END iF;
    IF( _searchData is null and _dateFrom is null and _dateTo is null) then
        
        if(_action='RECEIVE') then
            select * from v_INV_getPO where    difference = 0 and TransactionStatus <> -1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
		else
            select * from v_INV_getPO where    difference <> 0 and TransactionStatus = 1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
		end if;
	END iF;
    
	IF(_dateFrom is not null and _dateTo is not null) then
        if(_action='RECEIVE') then
         select * from v_INV_getPO where CreatedOn BETWEEN concat(_dateFrom,' 00:00:00') AND concat(_dateTo,' 23:59:59') and TransactionStatus <> -1 AND   difference = 0 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
        else 
        select * from v_INV_getPO where CreatedOn BETWEEN concat(_dateFrom,' 00:00:00') AND concat(_dateTo,' 23:59:59') and TransactionStatus = 1 AND   difference <> 0 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
        end if;
	ELSEIF( _dateFrom is not null and _dateTo is null) then
          if(_action='RECEIVE') then
          select * from v_INV_getPO where CreatedOn >=concat(_dateFrom,' 00:00:00')  AND difference = 0 and TransactionStatus <> -1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
         else
         select * from v_INV_getPO where CreatedOn >=concat(_dateFrom,' 00:00:00') AND difference <> 0 and TransactionStatus = 1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
         end if;
	ELSEIF( _dateFrom is null and _dateTo is not null) then
         if(_action='RECEIVE') then
          select * from v_INV_getPO where   CreatedOn <= concat(_dateTo,' 23:59:59') AND difference = 0 and TransactionStatus <> -1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
          else
          select * from v_INV_getPO where   CreatedOn <= concat(_dateTo,' 23:59:59') AND difference <> 0 and TransactionStatus = 1 and joReleaseID is null and ponumber is not null order by CreatedOn desc limit 300;
          end if;
	END IF;  
    
END IF; 
   
END$$
DELIMITER ;

-- ==============================================
-- call PO_getReceivedBinsWithUpdate(null,643799);


DROP procedure IF EXISTS `PO_getReceivedBinsWithUpdate`;
/*
DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `PO_getReceivedBinsWithUpdate`(
	IN _action varchar(25),
    IN _vePODetailID INT   
)
PO_getReceivedBinsWithUpdate : BEGIN

DECLARE _vePODetailBinID INT;

	call PO_initPODetailBin(null,_vePODetailID,null,null,null,_vePODetailBinID);
    
    if (_vePODetailID is not null) THEN
		select * from v_PO_vePODetailBin where vePODetailID=_vePODetailID;
    END IF;
    
    -- select _vePODetailBinID;

END$$

DELIMITER ;
*/




-- ==============================================
-- call PO_initReceiveDetail('INIT',643945,20005,5,1,@val);


DROP procedure IF EXISTS `PO_initReceiveDetail`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `PO_initReceiveDetail`(
	IN _action varchar(25),
    IN _vePODetailID INT,
   	IN _binId INT,
   	IN _inventoryPutAway INT,
    IN _changedById INT,
    IN _reference varchar(100),
    OUT _outBinID INT(11)
)
PO_initReceiveDetail : BEGIN
-- DECLARE _veReceiveDetailID INT;
DECLARE _veReceiveDetailBinID INT;
DECLARE _veReceiveDetailID INT;
DECLARE _veReceiveID INT;
DECLARE _vePOID INT;
DECLARE _prMasterID INT;
DECLARE _prWarehouseID INT;
DECLARE _Description varchar(255);
DECLARE _QuantityReceived INT;
DECLARE _rxMasterID INT;
DECLARE _poNumber varchar(25);
DECLARE _vendorOrderNO INT;
if (_binId is null) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call PO_initReceiveDetail:_binId required';
	LEAVE PO_initReceiveDetail; 
END IF;


-- DETERMINE IF THESE ITEMS EXIST ON RECEIVE TABLES
/* select d.veReceiveDetailID, d.veReceiveID 
into _veReceiveDetailID,_veReceiveID 
from veReceiveDetail d
left join veReceive r on (r.veReceiveID = d.veReceiveID)
where d.vePODetailID = _vePODetailID and r.ReceiveDate = Date(now());
*/



if (_action = 'INIT') THEN

	if (_inventoryPutAway is null )  THEN 
		set _veReceiveDetailBinID = null;
        LEAVE PO_initReceiveDetail;
    END IF;

	-- may need to do something with the existing QuantitityReceived!?
	select d.prMasterID,d.Description,d.QuantityReceived,d.vePOID, p.prWarehouseID, p.rxVendorID, p.PONumber,p.VendorOrderNumber
    into _prMasterID,_Description,_QuantityReceived,_vePOID,_prWarehouseID,_rxMasterID,_poNumber,_vendorOrderNO
	from vePODetail d
    left join vePO p on (p.vePOID = d.vePOID)
    where vePODetailID=_vePODetailID;
    
    select veReceiveID into _veReceiveID from veReceive where  vePOID = _vePOID and ReceiveDate = Date(now()) and rxMasterID = _rxMasterID;
    
    -- RECEIVE
    if (_veReceiveID is null) THEN
		insert  IGNORE into veReceive (rxMasterID,vePOID,ReceiveDate) values (_rxMasterID,_vePOID,now()) ; -- Date(now())
    
		SELECT LAST_INSERT_ID() INTO _veReceiveID;
	
    END IF;

	-- RECEIVE DETAIL
	-- if (_veReceiveDetailID is NULL) THEN
		
        insert into veReceiveDetail (veReceiveID,vePODetailID,prMasterID,Description,QuantityReceived,vePOID) 
        values (_veReceiveID,_vePODetailID,_prMasterID,_description,_inventoryPutAway,_vePOID);
        
        SELECT LAST_INSERT_ID() INTO _veReceiveDetailID;    
   --  ELSE
		-- update  veReceiveDetail set QuantityReceived = _inventoryPutAway where veReceiveDetailID = _veReceiveDetailID;
   --  END IF;
    
    
    select veReceiveDetailBinID into _veReceiveDetailBinID from veReceiveDetailBin where  veReceiveDetailID= _veReceiveDetailID and binId = _binId limit 1;
    
    -- RECEIVE BIN
   -- if (_veReceiveDetailBinID is null) THEN
    
		insert into veReceiveDetailBin (vePODetailID,veReceiveDetailID,prWarehouseID,prMasterID,binId,InventoryPutAway,reversed,LastUpdatedTime,changedByID) values 
			(_vePODetailID,_veReceiveDetailID,_prWarehouseID,_prMasterID,_binId,_inventoryPutAway,0,now(),_changedById);
			
		SELECT LAST_INSERT_ID() INTO _veReceiveDetailBinID;   
	-- ELSE
		-- update veReceiveDetailBin set InventoryPutAway=_inventoryPutAway where veReceiveDetailBinID=_veReceiveDetailBinID;
	-- END IF;

	-- after each put away, recalculate totals on the received.
	update vePO SET receiveddate = now() where vePOID = _vePOID;
	update veReceive SET ReceiveDate=now() where veReceiveID=_veReceiveID;
	update  vePODetail set QuantityReceived = _QuantityReceived + _inventoryPutAway where vePODetailID = _vePODetailID;
    call INV_updateInventoryLog('INSERT',_binId,'RI',_veReceiveID,_veReceiveDetailID,_vePOID,0,_inventoryPutAway,'Received',_changedByID,_reference,_poNumber);
	select sum(b.InventoryPutAway) into _inventoryPutAway
    from veReceiveDetailBin b
    where b.reversed=0 and b.vePODetailID = _vePODetailID;
    
	
	
    set _outBinID = _veReceiveDetailBinID;

 ELSEIF (_action='RECALCULATE') THEN
 
	select sum(b.InventoryPutAway) into _inventoryPutAway
    from veReceiveDetailBin b
    -- left join veReceiveDetail d on (d.veReceiveDetailID =  b.veReceiveDetail)  
    where b.reversed=0 and b.vePODetailID = _vePODetailID;
    
	update  vePODetail set QuantityReceived = _inventoryPutAway where vePODetailID = _vePODetailID;
 
 
	if (_veReceiveDetailID is not null) THEN
		
        select sum(b.InventoryPutAway) into _inventoryPutAway
		from veReceiveDetailBin b
		-- left join veReceiveDetail d on (d.veReceiveDetailID =  b.veReceiveDetail)  
		where b.reversed=0 and b.veReceiveDetailID = _veReceiveDetailID;

		update  veReceiveDetail set QuantityReceived = _inventoryPutAway where veReceiveDetailID = _veReceiveDetailID;
        
	END IF;
    
    set _veReceiveDetailBinID = null;
 
 END IF;
    
set _outBinID = _veReceiveDetailBinID;
    

END$$

DELIMITER ;








-- =========================================================


-- call PO_getPurchaseItems('RECOMMENDED',141239);

DROP procedure IF EXISTS `PO_getPurchaseItems`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `PO_getPurchaseItems`(
	IN _action  varchar(25),
    IN _vePOID INT
)
PO_getPurchaseItems:BEGIN

IF (_action ='RECOMMENDED') THEN 

		select 
        -- rd.veReceiveDetailBinID as veReceiveDetailBinID,
        d.vePODetailID, d.vePOID, d.prMasterID, p.prWarehouseID, d.Description, d.QuantityOrdered, d.QuantityReceived,prod.ItemCode,
        (ifnull(d.UnitCost * d.QuantityReceived,0) ) AS quantityBilledAmount,(d.QuantityOrdered - d.QuantityReceived) AS difference,d.QuantityBilled AS quantityBilled, 
		 (CASE 
           when ((select count(*) from bin where prMasterID = d.prMasterID and prWarehouseID = p.prWarehouseID) = 1)  then 
           (d.QuantityOrdered - d.QuantityReceived)
		   else
            (
			  (CASE
				WHEN  (b.InventoryAllocated -  b.InventoryOnHand) >0  THEN 
					(CASE
						WHEN (b.InventoryAllocated -  b.InventoryOnHand)<(d.QuantityOrdered - d.QuantityReceived) THEN (b.InventoryAllocated -  b.InventoryOnHand)
						ELSE (d.QuantityOrdered - d.QuantityReceived)
					END)
				WHEN (b.InventoryAllocated -  b.InventoryOnHand) <= 0 AND b.binSequence=1 THEN (RECEIVE_getBinRecommendedPutAway(d.prMasterID,p.prWarehouseID,d.QuantityOrdered- d.QuantityReceived))
				ELSE 0 
			  END)
            )
	     end)
       as recommendedPutAway,
		-- ifnull(rd.InventoryPutAway,0) as InventoryPutAway,
        null as InventoryPutAway,
		b.binId, b.searchName as binName, b.binSequence, b.InventoryOnHand, b.InventoryAllocated,  
		d.QuantityBilled,d.QuantityInvoiced,d.UnitCost, 
		p.PONumber, p.tag 
		from vePODetail d
		left join vePO p on (p.vePOID = d.vePOID)
		left join prMaster prod on (prod.prMasterID = d.prMasterID)
		left join bin b on (b.prMasterID = d.prMasterID and b.prWarehouseID = p.prWarehouseID)
		-- left join veReceiveDetailBin rd on (rd.binId = b.binId and rd.vePODetailID =d.vePODetailID)
		where d.QuantityOrdered >= d.QuantityReceived and d.QuantityOrdered >0 and p.prWarehouseID>0 and prod.IsInventory=1 
		and d.vePOID=_vePOID
		order by  d.posistion;
        
        LEAVE PO_getPurchaseItems;
        
ELSEIF (_action='PODETAILS'  and _vePOID is not null) THEN
		SELECT 
		`d`.`vePODetailID` AS `vePodetailId`,
        `d`.`vePOID` AS `vePOID`,
        `d`.`prMasterID` AS `prMasterId`,
        `d`.`Description` AS `description`,
        (SELECT 
                `prMaster`.`ItemCode`
            FROM
                `prMaster`
            WHERE
                (`prMaster`.`prMasterID` = `d`.`prMasterID`)) AS `note`,
        `d`.`QuantityOrdered` AS `quantityOrdered`,
        `d`.`QuantityReceived` AS `quantityReceived`,
        (ifnull( `d`.`UnitCost` * `d`.`QuantityReceived`,0) ) AS `quantityBilled`,
        `p`.`prWarehouseID` AS `prWarehouseID`,
        (`d`.`QuantityOrdered` - `d`.`QuantityReceived`) AS `difference`,
        (SELECT 
                `bin`.`searchName`
            FROM
                `bin`
            WHERE
                ((`bin`.`prWarehouseID` = `p`.`prWarehouseID`)
                    AND (`bin`.`prMasterID` = `d`.`prMasterID`)
                    AND (`bin`.`binSequence` = 1))
            LIMIT 1) AS `binLocation`,
			 (SELECT 
                `bin`.`binId`
            FROM
                `bin`
            WHERE
                ((`bin`.`prWarehouseID` = `p`.`prWarehouseID`)
                    AND (`bin`.`prMasterID` = `d`.`prMasterID`)
                    AND (`bin`.`binSequence` = 1))
            LIMIT 1) AS `binId`
    FROM
        (`vePODetail` `d`
        LEFT JOIN `vePO` `p` ON ((`p`.`vePOID` = `d`.`vePOID`)))
    WHERE
        ((`p`.`prWarehouseID` IS NOT NULL)
            AND (`p`.`prWarehouseID` > 0)) AND `d`.`vePOID` = _vePOID;
	END IF;
END$$
DELIMITER ;



-- ==============================================

DROP procedure IF EXISTS `INV_getWarehouse`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_getWarehouse`(
IN _vePOID INT
)
INV_getWarehouse:BEGIN
  select prWarehouseID,SearchName from prWarehouse where prWarehouseID=(select prWarehouseID  from vePO where vePOID=_vePOID);
  
END$$
DELIMITER ;


-- ==============================================

DROP procedure IF EXISTS `PO_PriorReceipts`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `PO_PriorReceipts`(
 IN _vePOID INT
)
PO_PriorReceipts: BEGIN
	SELECT * FROM v_PriorReceipts where vePOID =  _vePOID order by receiveDate desc;
END$$

DELIMITER ;


-- ==============================================
-- call INV_Productdetails('MA75006061212',null,null);

DROP procedure IF EXISTS `INV_Productdetails`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_Productdetails`(
IN _search varchar(1000),
IN _inactive INT,
IN _prWarehouseId int
)
INV_Productdetails:BEGIN
DECLARE itemcodeCondn text(100000);
DECLARE inactiveCondn text(100);
DECLARE warehouseCondn text(1000);
DECLARE aStr text(1000000);

	if(_search is not null ) Then 
		set itemcodeCondn = concat("AND ( pr.Description LIKE '%",_search,"%' OR  pr.ItemCode LIKE '%",_search,"%' 
        OR  pc.Description LIKE '%",_search,"%' OR 
				 pd.Description LIKE '%",_search,"%' OR  rx.Name LIKE '%",_search,"%')");
	ELSE
		set itemcodeCondn = " AND ( pr.Description LIKE '%%' OR  pr.ItemCode LIKE '%%' OR  pc.Description LIKE '%%' OR 
				 pd.Description LIKE '%%' OR   rx.Name LIKE '%%') ";
	END IF;
    
    if (_inactive = 1 ) then
		set inactiveCondn = "pr.InActive=1 ";
	else
		set inactiveCondn = "pr.InActive=0 ";
	End if ;
		
    if (_prWarehouseId is  null ) then
		set warehouseCondn = "";
	else 
		set warehouseCondn = concat(" pw.prWarehouseID = " , _prWarehouseId , " AND ") ;
	end if;
	
	-- TODO lets sum up bin's since prMaster is a rollup table.	
    if (_prWarehouseId is null) then
			set @aStr = concat("SELECT pr.prMasterID as prMasterId,pr.ItemCode as itemCode,REPLACE (pr.Description,'``','\"') as description, SUM(pw.InventoryOnHand) AS inventoryOnHand, "
					, "SUM( pw.InventoryAllocated) AS inventoryAllocated, "
					-- , "SUM(pw.InventoryOnOrder) AS inventoryOnOrder, " 
                    , "PO_getOnOrder(pr.prMasterID) as inventoryOnOrder, "
                    , "SUM(pr.Submitted) AS submitted, "
					, "pd.Description as prDepartment,pc.Description as prCategory,"
					, "rx.Name as vendorName, pr.LastCost, ROUND_TO_EVEN(IFNULL(pr.AverageCost*pw.InventoryOnHand ,0), 4) AS TotalCost, ROUND_TO_EVEN(pr.AverageCost, 4)"
					, " FROM prMaster pr" , " LEFT JOIN prWarehouseInventory pw ON pr.prMasterID = pw.prMasterID "
					, " LEFT JOIN prDepartment pd ON pd.prDepartmentID=pr.prDepartmentID"
					, " LEFT JOIN prCategory pc ON pc.prCategoryID = pr.prCategoryID"
					, " LEFT JOIN rxMaster rx ON rx.rxMasterID = pr.rxMasterIDPrimaryVendor WHERE " , warehouseCondn
					, " " , inactiveCondn , itemcodeCondn , " GROUP BY prMasterID order by pr.ItemCode  ");
	else 
			set  @aStr = concat("SELECT pr.prMasterID as prMasterId,pr.ItemCode as itemCode,REPLACE (pr.Description,'``','\"') as description,pw.InventoryOnHand as inventoryOnHand,pw.InventoryAllocated as inventoryAllocated,"
					-- , "pw.InventoryOnOrder as inventoryOnOrder,"
                    , "PO_getOnOrder(pr.prMasterID) as inventoryOnOrder, "
                    , "pr.Submitted as submitted,pd.Description as prDepartment,pc.Description as prCategory,"
					, "rx.Name as vendorName, pr.LastCost, ROUND_TO_EVEN(IFNULL(pr.AverageCost*pw.InventoryOnHand ,0), 4) AS TotalCost, ROUND_TO_EVEN(pr.AverageCost, 4)"
					, " FROM prMaster pr" , " LEFT JOIN prWarehouseInventory pw ON pr.prMasterID = pw.prMasterID "
					, " LEFT JOIN prDepartment pd ON pd.prDepartmentID=pr.prDepartmentID"
					, " LEFT JOIN prCategory pc ON pc.prCategoryID = pr.prCategoryID"
					, " LEFT JOIN rxMaster rx ON rx.rxMasterID = pr.rxMasterIDPrimaryVendor WHERE " , warehouseCondn
					, " " , inactiveCondn , itemcodeCondn , "order by pr.ItemCode ");
	END if;
    
	-- select @astr;
	prepare stmt from @aStr;
	execute stmt;
	deallocate prepare stmt;
END$$

DELIMITER ;



-- ==================================
-- call PR_getProductDetail(null,29,null);

DROP procedure IF EXISTS `PR_getProductDetail`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `PR_getProductDetail`( 
   IN _action  varchar(25),
   IN _prMasterID INT,
   IN _search VARCHAR(200)
)
PR_getProduct: BEGIN

	if (_prMasterID is not null) THEN
		select * from v_PR_product where prMasterID = _prMasterID;
		select IFNULL((SELECT 
                        SUM(`cud`.`QuantityBilled`)
                    FROM
                        (((`cuInvoiceDetail` `cud`
                        LEFT JOIN `cuInvoice` `cu` ON ((`cud`.`cuInvoiceID` = `cu`.`cuInvoiceID`)))
                        LEFT JOIN `joReleaseDetail` `jrd` ON ((`jrd`.`joReleaseDetailID` = `cu`.`joReleaseDetailID`)))
                        LEFT JOIN `joRelease` `jo` ON ((`jo`.`joReleaseID` = `jrd`.`joReleaseID`)))
                    WHERE
                        ((`cud`.`prMasterID` = _prMasterID)
                            AND (`cu`.`InvoiceDate` BETWEEN (SELECT 
                                `coFiscalYear`.`StartDate`
                            FROM
                                `coFiscalYear`
                            WHERE
                                `coFiscalYear`.`coFiscalYearID` IN (SELECT 
                                        `c`.`coFiscalYearID`
                                    FROM
                                        `coFiscalPeriod` `c`
                                    WHERE
                                        ((`c`.`StartDate` <= CURDATE())
                                            AND (`c`.`EndDate` >= CURDATE())
                                            AND (`c`.`openStatus` = 1)))) AND CURDATE())
                            AND ((`jo`.`ReleaseType` <> 1)
                            OR ISNULL(`cu`.`joReleaseDetailID`)
                            OR (`cu`.`joReleaseDetailID` = 0)))),
                0) AS `YTDSold`;
    elseif (_search is not null) THEN
		select * from v_PR_product where detailed_search like CONCAT('%',_search,'%') order by Description;
    END IF;

END$$
DELIMITER ;



-- ==================================
-- new product
-- call PR_updateProductDetail('UPDATE',1,null,0,1,'DaveTest','test product',1,1,0,'website',1,2,3,4,1,1,6,7,8,1,1,'abc',2,'xyz2');

-- updating any/all values nulls ignored
-- call PR_updateProductDetail('UPDATE',1,2048,0,1,'DaveTest','test product',1,1,0,'website',1,2,3,4,1,1,6,7,8,1,1,'abc',2,'xyz2');

-- turning inventory off
-- call PR_updateProductDetail('UPDATE',1,2048,0,0,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

-- forcing vendors to change, null is considered.
-- call PR_updateProductDetail('VENDOR',1,2048,0,1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,3,'their code',null,null);

DROP procedure IF EXISTS `PR_updateProductDetail`;

DELIMITER $$
CREATE PROCEDURE `PR_updateProductDetail`( 
IN _action varchar(50),
IN _createdByID INT,
IN _prMasterID INT,
IN _InActive INT,
IN _IsInventory INT,
IN _ItemCode varchar(100), 
IN _Description varchar(100),
IN _prCategoryID INT, 
IN _prDepartmentID INT, 
IN _AverageCost INT,
IN _Website varchar(500),
IN _BoxQty INT,
IN _Weight decimal(19,4),
IN _WeightOz  decimal(19,4),
IN _NewPrice   decimal(19,4),
IN _IsTaxable INT,
IN _SingleItemTax INT,
IN _AverageCost_New   decimal(19,4), -- SV_AvgCost
IN _Consignment   decimal(19,4), -- SV_WhseCost
IN _POCost_New  decimal(19,4), -- SV_FactoryCost
IN _POMult INT,  -- as SV_Multiplier
IN _rxMasterIDPrimaryVendor INT,
IN _VendorItemNumber  varchar(100),
IN _rxMasterIDSecondaryVendor01 INT,
IN _VendorItemNumber01  varchar(100)
)
PR_updateProductDetail: BEGIN
	DECLARE commaNeeded INT DEFAULT 0;
    DECLARE v_finished INT default 0;
    DECLARE iBinId INT ;
	DECLARE task_cursor CURSOR FOR select binId from bin where prMasterID = _prMasterID and binSequence > _binSequence ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    
    
    if(_action='UPDATE') THEN

		if (_prMasterID is null) THEN

            insert into prMaster(prDepartmentID,prCategoryID,ItemCode,Description,InActive,IsInventory,IsTaxable,SingleItemTax,Website
            ,BoxQty,Weight,NewPrice,Consignment,POCost_New,AverageCost_New
            ,CreatedOn,CreatedByID,lastUpdatedTime
            ,rxMasterIDPrimaryVendor,VendorItemNumber,rxMasterIDSecondaryVendor01,VendorItemNumber01) 
            values
            (_prDepartmentID,_prCategoryID,_ItemCode,_Description,_InActive,_IsInventory,_IsTaxable,_SingleItemTax,_Website
            ,_BoxQty,_Weight,_NewPrice,_Consignment,_POCost_New,_AverageCost_New
            ,now(),_createdByID,now()
            ,_rxMasterIDPrimaryVendor,_VendorItemNumber,_rxMasterIDSecondaryVendor01,_VendorItemNumber01);
            
			SELECT LAST_INSERT_ID() INTO _prMasterID;
            
        ELSEif (_prMasterID is not null) THEN
    
				set  @l_sql ='update prMaster set ';
		 
				if (_prDepartmentID is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'prDepartmentID =', _prDepartmentID); 
					set commaNeeded =1;
				END IF;
				if (_prCategoryID is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'prCategoryID =', _prCategoryID); 
					set commaNeeded =1;
				END IF;
                if (_ItemCode is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'ItemCode =\'', TRIM(_ItemCode),'\''); 
					set commaNeeded =1;
				END IF;
                if (_Description is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'Description =\'', TRIM(_Description),'\''); 
					set commaNeeded =1;
				END IF;
				if (_InActive is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'InActive =', _InActive); 
					set commaNeeded =1;
				END IF;
				if (_IsInventory is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'IsInventory =', _IsInventory); 
					set commaNeeded =1;
				END IF;
				if (_IsTaxable is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'IsTaxable =', _IsTaxable); 
					set commaNeeded =1;
				END IF;				
				if (_SingleItemTax is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'SingleItemTax =', _SingleItemTax); 
					set commaNeeded =1;
				END IF;	                
                if (_Website is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'Website =\'', TRIM(_Website),'\''); 
					set commaNeeded =1;
				END IF;                
				if (_BoxQty is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'BoxQty =', _BoxQty); 
					set commaNeeded =1;
				END IF;	   
				if (_Weight is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'Weight =', _Weight); 
					set commaNeeded =1;
				END IF;                
				if (_NewPrice is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'OldPrice = NewPrice'); 
					set @l_sql = CONCAT(@l_sql,',NewPrice =', _NewPrice); 
					set commaNeeded =1;
				END IF;                 
				if (_Consignment is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'Consignment =', _Consignment); 
					set commaNeeded =1;
				END IF;                
				if (_NewPrice is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'POCost_Old = POCost_New'); 
					set @l_sql = CONCAT(@l_sql,',POCost_Changed = POCost_Old-',_POCost_New); 
					set @l_sql = CONCAT(@l_sql,',POCost_New =', _POCost_New); 
					set commaNeeded =1;
				END IF;                 
				if (_AverageCost_New is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'AverageCost_Old = AverageCost_New'); 
					set @l_sql = CONCAT(@l_sql,',AverageCost_Changed = AverageCost_Old-',_AverageCost_New); 
					set @l_sql = CONCAT(@l_sql,',AverageCost_New =', _AverageCost_New); 
					set commaNeeded =1;
				END IF;                 



				if (_rxMasterIDPrimaryVendor is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'rxMasterIDPrimaryVendor =', _rxMasterIDPrimaryVendor); 
					set commaNeeded =1;
				END IF;                
                if (_VendorItemNumber is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'VendorItemNumber =\'', _VendorItemNumber,'\''); 
					set commaNeeded =1;
				END IF; 
				if (_rxMasterIDSecondaryVendor01 is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'rxMasterIDSecondaryVendor01 =', _rxMasterIDSecondaryVendor01); 
					set commaNeeded =1;
				END IF;                
                if (_VendorItemNumber01 is not null) THEN 
					IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
					set @l_sql = CONCAT(@l_sql,'VendorItemNumber01 =\'', _VendorItemNumber01,'\''); 
					set commaNeeded =1;
				END IF;                 
                
                
				IF (commaNeeded>0) THEN
				
					set @l_sql = CONCAT(@l_sql,',LastUpdatedTime =\'', now(),'\''); 
					set @l_sql = CONCAT(@l_sql,' where prMasterID=', _prMasterID); 

					-- select @l_sql;
						
					PREPARE stmt FROM @l_sql;
					EXECUTE stmt;
					DEALLOCATE PREPARE stmt;
				
					
				END IF;
		        
        END IF;

		IF (_IsInventory=1 and _prMasterID is not null) THEN
        
			call INV_createBinsFromWarehouseInventory('PRODUCT',_prMasterID,null);
                
		END IF;

	
        
    ELSEIF(_action='VENDOR') THEN 

        update prMaster set rxMasterIDPrimaryVendor=_rxMasterIDPrimaryVendor,VendorItemNumber=_VendorItemNumber,rxMasterIDSecondaryVendor01=_rxMasterIDSecondaryVendor01,VendorItemNumber01=_VendorItemNumber01 where prMasterID = _prMasterID;

    ELSEIF(_action='DELETE') THEN 
		
        update prMaster set InActive = 1, IsInventory=0,LastUpdatedTime=now() where prMasterID = _prMasterID;
        
    END IF;
    
END$$

DELIMITER ; 



-- =========================================================
DROP procedure IF EXISTS `INV_createBinsFromWarehouseInventory`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_createBinsFromWarehouseInventory`(
	IN _action varchar(25),
	IN _prMasterID INT,
    IN _max int
)
INV_createBinsFromWarehouseInventory : BEGIN
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _inventories text;

DECLARE _binId INT;
DECLARE _prWarehouseID INT;
DECLARE _prWarehouseInventoryID INT;
DECLARE _itemCode varchar(255);
DECLARE _warehouseName varchar(255);
DECLARE _overrideName varchar(255);
DECLARE _counter INT default 0;
DECLARE _count INT default 0;
DECLARE _binName varchar(255);


if (_max is null or _max=0) THEN set _max=1000000; END IF;


IF (_action = 'PRODUCT' and _prMasterID is NOT NULL) THEN

	select group_concat(w.prWarehouseID)  into _inventories
	from prWarehouse w 
	left join bin b on (b.prWarehouseID = w.prWarehouseID and b.prMasterID=_prMasterID)
	left join prMaster p on (p.prMasterID=_prMasterID and p.IsInventory=1)
	where b.binID is null ;

-- select _action, _inventories;

		 do_this:
		   LOOP
		 
		 SET strLen = CHAR_LENGTH(_inventories);
								
		 set _prWarehouseInventoryID=SUBSTRING_INDEX(_inventories, ',', 1);

		set _prWarehouseID=_prWarehouseInventoryID;
		set _itemCode=null;
		set _warehouseName=null;

		select itemCode into _itemCode from prMaster where prMasterID=_prMasterID;
		select searchName into _warehouseName from prWarehouse where prWarehouseID=_prWarehouseID;
        
		set _overrideName = concat( ifnull(_itemCode,''),'(',_prMasterID,')@',_warehouseName);

	-- if (_overrideName is null) THEN 
		-- select _prWarehouseInventoryID,_prMasterID,_prWarehouseID,_itemCode,_warehouseName; 
	-- END IF;

-- select _action, _prMasterID, _inventories,_prWarehouseID,_overrideName;
		
        if (_prWarehouseID is not null) THEN
			call INV_updateBin('UPDATE',null,_prWarehouseID,_prMasterID,null,null,null,_overrideName,null,null,null,null,null,null,0);
		END IF;
			
		 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_inventories, ',', 1))+2;
		 SET _inventories = MID(_inventories, SubStrLen, strLen);

		set _counter = _counter+1;
		
		 IF _inventories = '' or _inventories is null or _counter > _max THEN
		   LEAVE do_this;
		 END IF;
		END LOOP do_this;

ELSEIF (_action = 'INIT') THEN

	SET SESSION group_concat_max_len = 1000000;

	SELECT "UPGRADE bin's from legacy";

-- pickup all the records not already associated to a bin.
set _inventories = null;
select group_concat(i.prWarehouseInventoryID) into _inventories
from prWarehouseInventory i
left join prWarehouse w on (w.prWarehouseID = i.prWarehouseID)
left join prMaster p on (p.prMasterID = i.prMasterID)
left join bin b on (b.prWarehouseInventoryID = i.prWarehouseInventoryID)
where 
b.binID is null and p.ItemCode is not null and w.searchName is not null and 
p.IsInventory=1;

-- select 'RUNNING bin creation';

	if (_inventories is not null )  THEN
			 do_this:
			   LOOP
			 
		     SET strLen = CHAR_LENGTH(_inventories);
									
			 set _prWarehouseInventoryID=SUBSTRING_INDEX(_inventories, ',', 1);

			set _prMasterID=null;
			set _prWarehouseID=null;
			set _itemCode=null;
			set _warehouseName=null;

			select i.prMasterID,p.ItemCode,i.prWarehouseID, w.searchName, i.Bin into _prMasterID, _itemCode, _prWarehouseID,_warehouseName,_binName
			from prWarehouseInventory i
            left join bin b on (i.prMasterID = b.prMasterID and i.prWarehouseID = b.prWarehouseID)
			left join prWarehouse w on (w.prWarehouseID = i.prWarehouseID)
			left join prMaster p on (p.prMasterID = i.prMasterID)
			where i.prWarehouseInventoryID=_prWarehouseInventoryID;

			if(_binName is not null and _binName <> '') then 
				set _count = 0;
				select count(*) into _count from bin where overrideName = _binName;
				if(_count > 0) then
					set _overrideName = concat(_itemCode,'(',_prMasterID,')@',_warehouseName);
				else
					set _overrideName = _binName;
				end if;
			else
				set _overrideName = concat(_itemCode,'(',_prMasterID,')@',_warehouseName);
			end if;

			-- if (_overrideName is null) THEN 
				-- select _prWarehouseInventoryID,_prMasterID,_prWarehouseID,_itemCode,_warehouseName; 
			-- END IF;

		        if (_prWarehouseID is not null) THEN
					call INV_updateBin('UPDATE',null,_prWarehouseID,_prMasterID,null,null,null,_overrideName,null,null,null,null,null,null,0);
				END IF;
		        
		        
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_inventories, ',', 1))+2;
			 SET _inventories = MID(_inventories, SubStrLen, strLen);

			set _counter = _counter+1;
			
			 IF _inventories = ''  or _inventories is null  or _counter > _max THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
	END IF;

/*
set _inventories = null;

select group_concat(d.prWarehouseInventoryID) 
into _inventories
from
(select i.prWarehouseInventoryID
FROM prWarehouseInventory i 
where Bin is not null and Bin <> ''
group by Bin, prWarehouseID, prMasterID) d;

-- select _inventories;

-- select 'RUNNING bin update';

	if (_inventories is not null )  THEN

			 do_this:
			   LOOP
			 
		     SET strLen = CHAR_LENGTH(_inventories);
									
			 set _prWarehouseInventoryID=SUBSTRING_INDEX(_inventories, ',', 1);

			set _prMasterID=null;
			set _prWarehouseID=null;
			set _itemCode=null;
			set _warehouseName=null;
			set _binId=null;
			
			select b.binId, i.Bin 
            into _binId,_warehouseName
			from prWarehouseInventory i
            left join bin b on (i.prMasterID = b.prMasterID and i.prWarehouseID = b.prWarehouseID)
			where i.prWarehouseInventoryID=_prWarehouseInventoryID limit 1;
            
            -- select _binId,_warehouseName;
           
            
            -- check to see if override name is already used
            set _count = 0;
            select count(*) into _count from bin where overrideName = _warehouseName or searchName =_warehouseName limit 1;
            
			set _overrideName = _warehouseName;

            -- select _binId,_warehouseName,_count;

		        if (_binId is not null and _count=0) THEN
					-- select _prWarehouseInventoryID,_binId,_warehouseName,_count;
					
					call INV_updateBin('UPDATE',_binId,null,null,null,null,null,_overrideName,null,null,null,null,null,null,0);
				END IF;
		        
		        
			 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_inventories, ',', 1))+2;
			 SET _inventories = MID(_inventories, SubStrLen, strLen);

			set _counter = _counter+1;
			
			 IF _inventories = ''  or _inventories is null  or _counter > _max THEN
			   LEAVE do_this;
			 END IF;
			END LOOP do_this;
	END IF;

*/


END IF;

-- select 'FINISHED';

-- select GROUP_CONCAT(prWarehouseInventoryID) from v_INV_bin into _inventories where InventoryOnHand != whInventoryOnHand;

END$$

DELIMITER ;



-- =========================================================
-- call INV_createCuSODetailBins('CHECK');
-- call INV_createCuSODetailBins('INIT');

DROP procedure IF EXISTS `INV_createCuSODetailBins`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_createCuSODetailBins`(
	IN _action varchar(25)
)
INV_createCuSODetailBins : BEGIN
DECLARE _allocated decimal(19,4);
DECLARE _QuantityBilled decimal(19,4);
DECLARE _binId INT;
DECLARE _cuSODetailID INT;
DECLARE _lastUpdated datetime;

DECLARE _ids    text;
DECLARE _id    INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;

SET SESSION group_concat_max_len = 1000000;

if (_action = 'CHECK') THEN

	select s.CreatedOn, d.cuSODetailID, theBin.binId, d.QuantityOrdered, d.QuantityBilled, s.TransactionStatus
	from cuSODetail d 
	left join cuSO s on (s.cuSOID = d.cuSOID)
	left join cuSODetailBin b on (b.cuSODetailID = d.cuSODetailID)
	left join prMaster p on (p.prMasterID = d.prMasterID)
	left join bin theBin on (theBin.prMasterID = d.prMasterId and s.prFromWarehouseID = theBin.prWarehouseId)
	where d.QuantityOrdered > d.QuantityBilled and s.TransactionStatus=1 and p.IsInventory=1 
	and cuSODetailBinID is null
	order by s.CreatedOn desc;
    
elseif (_action = 'INIT') THEN

	SELECT "UPGRADE cuSODetailBin from legacy";

	select group_concat(d.cuSODetailID) 
    into _ids
	from cuSODetail d 
	left join cuSO s on (s.cuSOID = d.cuSOID)
	left join cuSODetailBin b on (b.cuSODetailID = d.cuSODetailID)
	left join prMaster p on (p.prMasterID = d.prMasterID)
	-- left join bin theBin on (theBin.prMasterID = d.prMasterId and s.prFromWarehouseID = theBin.prWarehouseId)
	where d.QuantityOrdered > d.QuantityBilled and s.TransactionStatus=1 and p.IsInventory=1 
	and cuSODetailBinID is null
	order by s.CreatedOn desc;
    
    select _ids, CHAR_LENGTH(_ids);
    
		 do_this:
		   LOOP
				set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);

	select s.CreatedOn,d.cuSODetailID,theBin.binId ,d.QuantityOrdered,d.QuantityBilled
    into _lastUpdated,_cuSODetailID,_binId,_allocated,_QuantityBilled
    from cuSODetail d
    left join cuSO s on (s.cuSOID = d.cuSOID)
	left join bin theBin on (theBin.prMasterID = d.prMasterId and s.prFromWarehouseID = theBin.prWarehouseId)
    where d.cuSODetailID =_id;
    
    if (_binId is not null) THEN
		insert into cuSODetailBin (cuSODetailID,binId,allocated,lastUpdated) values (_cuSODetailID,_binId,_allocated,_lastUpdated);
	END IF;
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 


END IF;

END$$

DELIMITER ;

-- =======================================================
DROP procedure IF EXISTS `INV_createTransferBins`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_createTransferBins`(
IN _action varchar(25)
)
BEGIN
DECLARE _lastUpdated datetime;
DECLARE _frombinId INT;
DECLARE _tobinId INT;

DECLARE _ids    text;
DECLARE _id    INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
SET SESSION group_concat_max_len = 1000000;
        if(_action = 'UPDATEDATE') THEN
			select group_concat(prTransferID) into _ids
            from prWHtransfer where screenno = 1 and ReceivedDate is not null;
            
            select _ids, CHAR_LENGTH(_ids);

			do_this:
		   LOOP
				set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);

	
    select ReceivedDate into _lastUpdated from prWHtransfer where screenno = 1 And prTransferID = _id;
    
    if (_lastUpdated is not null) THEN
		update prWHtransferDetail set ReceivedDate = _lastUpdated where prTransferID = _id and ReceivedDate is null;
	END IF;
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
            
            
         elseif(_action = 'INIT')   THEN
			 
             
             select group_concat(d.prTransferDetailID)  into _ids
             from prWHtransferDetail d 
			left join  prWHtransfer t on t.prTransferID = d.prTransferID 
			left join prMaster p on p.prMasterID = d.prMasterID
			where t.screenno = 1 and p.IsInventory = 1 and d.fromBinId is null;
            
            select _ids, CHAR_LENGTH(_ids);
            
            do_this:
		   LOOP
				set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);

				select b.binId into _frombinId
                from prWHtransferDetail d
                left join  prWHtransfer t on t.prTransferID = d.prTransferID 
                left join prMaster p on p.prMasterID = d.prMasterID
                left join bin b on (b.prMasterID = d.prMasterID and b.prWarehouseID = t.prFromWareHouseID and b.binSequence = 1)
                where d.prTransferDetailID = _id;
                
              /*  select b.binId into _tobinId
                from prWHtransferDetail d
                left join  prWHtransfer t on t.prTransferID = d.prTransferID 
                left join prMaster p on p.prMasterID = d.prMasterID
                left join bin b on (b.prMasterID = d.prMasterID and b.prWarehouseID = t.prToWareHouseID and b.binSequence = 1)
                where d.prTransferDetailID = _id; */
                
    
    
    if (_frombinId is not null) THEN
		update prWHtransferDetail set fromBinId = _frombinId where prTransferDetailID = _id;
	END IF;
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this;
            
             elseif(_action = 'REMOVETOBIN')   THEN 
				select group_concat(pwd.prTransferDetailID) into _ids  from prWHtransferDetail  pwd 
				left join prWHtransfer pw on  pwd.prTransferID = pw.prTransferID 
				where pw.screenno = 1 and pwd.ReceivedDate is null 
				order by pwd.prTransferDetailID desc;
					
                    select _ids, CHAR_LENGTH(_ids);
				
                do_this:
		   LOOP
				set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);

	
  
				update prWHtransferDetail set toBinId = null where prTransferDetailID = _id;
	
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
                
				
		end if;


END$$

DELIMITER ;



-- ============================================================
-- call SO_getSODetail('SODetail',91663,null);
-- call SO_getSODetail('SODetailBin',91663,null);

DROP procedure IF EXISTS `SO_getSODetail`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `SO_getSODetail`(
IN _action varchar(20),
IN _cuSOID INT,
IN _cuSODetailID INT
)
SO_getSODetail: BEGIN
DECLARE _count INT;


if (_action = 'SODetail') THEN

	select count(*) into _count from cuSODetailTicket where cuSOID = _cuSOID and ticketStatus=1;
    
     if(_count = 0) then 
		call INV_createPickTicket_v2('CREATE',_cuSOID,null);
	end if;
    
    
	/*
	SELECT NULL AS cuInvoiceId,d.cuSOID, d.cuSODetailID, Description AS description,ItemCode AS itemCode, toPick,bo,
    (case when toPick>0 THEN toPick ELSE IFNULL(SUM(d.availableToInvoice),QuantityOrdered) END) AS availableToInvoice, 
    (case when toPick>0 THEN bo     ELSE SUM(IFNULL(d.backOrdered,0)) END) AS backOrdered, 
    NULL AS vePODetailID,
	CASE WHEN ItemCode='QP' THEN IFNULL(QuantityOrdered,1) ELSE IFNULL((QuantityBilled - SUM(IFNULL(d.backOrdered,0))),d.SOQuantityBilled) END AS quantityBilled, prMasterID AS prMasterId,prFromWarehouseID, QuantityOrdered, 
	-- UnitCost AS unitCost,
	-- CASE WHEN ItemCode='QP' THEN IF(totalInvoiceSubTotal<>0,IF((soTotal-totalInvoiceSubTotal)<>0,(soTotal-totalInvoiceSubTotal),0),soTotal) ELSE UnitCost END AS unitCost,
	CASE WHEN ItemCode='QP' THEN IF(totalInvoiceSubTotal<>0,IF((soTotal-totalInvoiceSubTotal)<>0,IF(QuantityOrdered<0 AND (soTotal-totalInvoiceSubTotal)<0,(soTotal-totalInvoiceSubTotal)*-1,(soTotal-totalInvoiceSubTotal)),0),IF(QuantityOrdered<0 AND soTotal<0,soTotal*-1,soTotal)) ELSE UnitCost END AS unitCost,
	PriceMultiplier AS priceMultiplier,Taxable AS taxable,IsInventory AS isInventory,0 AS whseCost,d.note,d.whseCost as whseCost
	FROM (
	SELECT 
    detail.Description ,p.ItemCode, tix.toPick, tix.backOrdered as bo,
    detail.cuSOID, detail.QuantityOrdered,  detail.UnitCost, detail.PriceMultiplier, detail.Taxable,
	sodb.cuSODetailBinID, detail.cuSODetailID, sodb.binId, sodb.allocated, (detail.QuantityOrdered-IFNULL(detail.QuantityBilled,0)) AS QuantityBilled, detail.QuantityBilled AS SOQuantityBilled,
	(CASE WHEN ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) <= b.InventoryOnHand THEN  ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) ELSE  b.InventoryOnHand END) AS availableToInvoice,
	(CASE WHEN ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) - b.InventoryOnHand < 0 THEN 0 ELSE ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) - b.InventoryOnHand END) AS backOrdered,	
	-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
	b.InventoryOnHand,  b.searchName AS binName, p.prMasterID, so.prFromWarehouseID, p.IsInventory,so.SubTotal AS soTotal,ci.totalInvoiceAmount,ci.totalInvoiceSubTotal,detail.position,detail.Note AS note,
    ROUND_TO_EVEN((syv.ValueCurrency*p.AverageCost),2) as whseCost
	FROM cuSODetail detail  
    LEFT JOIN cuSO so ON (so.cuSOID = detail.cuSOID)
	LEFT JOIN cuSODetailBin sodb ON (detail.cuSODetailID = sodb.cuSODetailID) 
	LEFT JOIN cuSODetailTicket tix ON (tix.cuSODetailID = detail.cuSODetailID and tix.ticketStatus=1) 
	LEFT JOIN `bin` b ON (b.binId = sodb.binId)
    LEFT JOIN prMaster p ON (p.prMasterID = detail.prMasterID)
	LEFT JOIN SalesOrderInvoicesView ci ON(so.cuSOID=ci.cuSOID) 
    LEFT JOIN sysVariable syv on (syv.sysVariableID = 1020000)
		WHERE detail.cuSOID = _cuSOID
	
	) d
     -- where (quantityBilled+backOrdered) = 0
	GROUP BY d.cuSODetailID
	HAVING (quantityBilled<>0 OR backOrdered>0)
	ORDER BY position; */
    
    SELECT NULL AS cuInvoiceId,d.cuSOID, d.cuSODetailID, Description AS description,ItemCode AS itemCode, toPick,bo,
    (case when toPick>0 THEN toPick ELSE IFNULL(SUM(d.availableToInvoice),QuantityOrdered) END) AS availableToInvoice, 
    (case when toPick>0 THEN bo     ELSE SUM(IFNULL(d.backOrdered,0)) END) AS backOrdered, 
    NULL AS vePODetailID,
	CASE WHEN ItemCode='QP' THEN IFNULL(QuantityOrdered,1) ELSE IFNULL((QuantityBilled - SUM(IFNULL(d.backOrdered,0))),d.SOQuantityBilled) END AS quantityBilled, prMasterID AS prMasterId,prFromWarehouseID, QuantityOrdered, 
	-- UnitCost AS unitCost,
	-- CASE WHEN ItemCode='QP' THEN IF(totalInvoiceSubTotal<>0,IF((soTotal-totalInvoiceSubTotal)<>0,(soTotal-totalInvoiceSubTotal),0),soTotal) ELSE UnitCost END AS unitCost,
	CASE WHEN ItemCode='QP' THEN IF(totalInvoiceSubTotal<>0,IF((soTotal-totalInvoiceSubTotal)<>0,IF(QuantityOrdered<0 AND (soTotal-totalInvoiceSubTotal)<0,(soTotal-totalInvoiceSubTotal)*-1,(soTotal-totalInvoiceSubTotal)),0),IF(QuantityOrdered<0 AND soTotal<0,soTotal*-1,soTotal)) ELSE UnitCost END AS unitCost,
	PriceMultiplier AS priceMultiplier,Taxable AS taxable,IsInventory AS isInventory,0 AS whseCost,d.note,d.whseCost as whseCost
	FROM (




SELECT 
    detail.Description,
    p.ItemCode,
    tix.toPick,
    tix.backOrdered AS bo,
    detail.cuSOID,
    detail.QuantityOrdered,
    detail.UnitCost,
    detail.PriceMultiplier,
    detail.Taxable,
    -- sodb.cuSODetailBinID,
    detail.cuSODetailID,
    b.binId,
    (tix.toPick+tix.backOrdered) as allocated,
    (detail.QuantityOrdered - IFNULL(detail.QuantityBilled, 0)) AS QuantityBilled,
    detail.QuantityBilled AS SOQuantityBilled,
   tix.toPick AS availableToInvoice,
    tix.backOrdered AS backOrdered,
    b.InventoryOnHand,
    b.searchName AS binName,
    p.prMasterID,
    so.prFromWarehouseID,
    p.IsInventory,
    so.SubTotal AS soTotal,
    ci.totalInvoiceAmount,
    ci.totalInvoiceSubTotal,
    detail.position,
    detail.Note AS note,
    ROUND_TO_EVEN(p.AverageCost, 2) AS whseCost
FROM
    cuSODetail detail
        LEFT JOIN
    cuSO so ON (so.cuSOID = detail.cuSOID)
        LEFT JOIN
    cuSODetailTicket tix ON (tix.cuSODetailID = detail.cuSODetailID
        AND tix.ticketStatus = 1)
        LEFT JOIN
    `bin` b ON (b.binId = tix.binId)
        LEFT JOIN
    prMaster p ON (p.prMasterID = detail.prMasterID)
        LEFT JOIN
    SalesOrderInvoicesView ci ON (so.cuSOID = ci.cuSOID)
        LEFT JOIN
    sysVariable syv ON (syv.sysVariableID = 1020000)
WHERE
    detail.cuSOID = _cuSOID 
    )
    
    d
     -- where (quantityBilled+backOrdered) = 0
	GROUP BY d.cuSODetailID
	HAVING (quantityBilled<>0 OR backOrdered>0)
	ORDER BY position;
    

ELSEif (_action = 'SODetailBin') THEN

	select 
    p.Description,p.ItemCode,
    null as cuInvoiceID, detail.cuSOID, detail.QuantityOrdered, detail.UnitCost, detail.PriceMultiplier, detail.Taxable,
	sodb.cuSODetailBinID, detail.cuSODetailID, sodb.binId, sodb.allocated, IFNULL(sodb.QuantityBilled, detail.QuantityBilled) as QuantityBilled  ,detail.QuantityBilled as SOQuantityBilled,
	IFNULL((CASE WHEN (sodb.allocated-sodb.QuantityBilled) <= b.InventoryOnHand THEN  (sodb.allocated-sodb.QuantityBilled) ELSE  b.InventoryOnHand END),detail.QuantityOrdered) as availableToInvoice,
	IFNULL((CASE WHEN (sodb.allocated-sodb.QuantityBilled) - b.InventoryOnHand < 0 THEN 0 ELSE (sodb.allocated-sodb.QuantityBilled) - b.InventoryOnHand END),0) as backOrdered,
	-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
	b.InventoryOnHand, b.searchName as binName, p.prMasterID, so.prFromWarehouseID, p.IsInventory,detail.Note AS note  
	from cuSODetail detail  
    left join cuSO so on (so.cuSOID = detail.cuSOID)
	left join cuSODetailBin sodb on (detail.cuSODetailID = sodb.cuSODetailID) 
	left join `bin` b on (b.binId = sodb.binId)
    left join prMaster p on (p.prMasterID = detail.prMasterID)
	where detail.cuSOID = _cuSOID;
    
END IF;

END$$

DELIMITER ;



-- ============================================================
-- call PO_getVeBillDetail('veBilToInvoice',194477,null);

DROP procedure IF EXISTS `PO_getVeBillDetail`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `PO_getVeBillDetail`(
IN _action VARCHAR(40),
IN _veBillID INT,
IN _veBillDetailID INT
)
PO_getVeBillDetail: BEGIN
DECLARE _estimatedBilling decimal(19,4);
DECLARE _QP_prMasterID INT;
DECLARE _QP_Description varchar(255);
DECLARE _joReleaseDetailID INT;
DECLARE _joReleaseID INT;
DECLARE _vePOID INT;

if (_action = 'veBilToInvoice') THEN

	select IFNULL(EstimatedBilling,0),d.joReleaseDetailID,d.joReleaseID into _estimatedBilling,_joReleaseDetailID,_joReleaseID from joRelease r
    left join joReleaseDetail d on (d.joReleaseID = r.joReleaseID)
    left join veBill b on (b.joReleaseDetailID = d.joReleaseDetailID) 
    where b.veBillID = _veBillID; 
	
	select prMasterID,Description into _QP_prMasterID,_QP_Description from prMaster where ItemCode='QP' limit 1;

	-- select _joReleaseDetailID, _veBillID;
   -- select SUM(CustomerInvoiceAmount)  from joReleaseDetail where joReleaseID = _joReleaseID;
	-- need to figure out the SUM of veBill QP's and subtract from EstimatedBilling to get amount remaining.
	select ifnull((_estimatedBilling-sum(Subtotal)),_estimatedBilling) into _estimatedBilling
	from cuInvoice ci
	left join joReleaseDetail jrd on (jrd.joReleaseDetailID = ci.joReleaseDetailID)
	left join joRelease jr on (jr.joReleaseID = jrd.joReleaseID)
	where jr.joReleaseID = _joReleaseID;
	
	if (_estimatedBilling < 0) THEN set _estimatedBilling=0; END IF;
	
	select null as cuInvoiceId,d.veBillID, d.veBillDetailID, d.veBillID, d.vePODetailID, Description as description,ItemCode as itemCode,
    QuantityOrdered,d.QuantityReceived,
    IFNULL(sum(d.availableToInvoice),QuantityOrdered) as availableToInvoice, (QuantityOrdered - d.QuantityBilled)  as backOrdered, 
	d.QuantityBilled as quantityBilled, prMasterID as prMasterId,prFromWarehouseID, UnitCost as unitCost,PriceMultiplier as priceMultiplier,Taxable as taxable,IsInventory as isInventory,d.note
	from (
	select 
    detail.Description as description,p.ItemCode as itemCode,
    null as cuSOID,  detail.veBillID, ved.QuantityOrdered as QuantityOrdered,  0 as unitCost, 0 as priceMultiplier, detail.Taxable as taxable,
	null as cuSODetailBinID, detail.veBillDetailID, detail.vePODetailID, null as cuSODetailID, null as binId, 0 as allocated, 
    0 as QuantityReceived,
    detail.QuantityBilled as QuantityBilled, 
    0 as vePOQuantityBilled,
	0 as availableToInvoice,
	0 as backOrdered,
	0 as InventoryOnHand,  null as binName, p.prMasterID, null as prFromWarehouseID, p.IsInventory ,0 as whseCost,detail.Note AS note
	from veBillDetail detail  
    left join veBill so on (so.veBillID = detail.veBillID)
    -- left join vePO ve on (ve.vePOID = so.vePOID)
    left join vePODetail ved on (ved.vePODetailID = detail.vePODetailID)
	-- left join cuSODetailBin sodb on (detail.cuSODetailID = sodb.cuSODetailID) 
	-- left join bin b on (b.binId = sodb.binId)
    left join prMaster p on (p.prMasterID = detail.prMasterID)
	where detail.veBillID = _veBillID) d
	group by d.veBillDetailID
    UNION
	select null as cuInvoiceId, _veBillID as veBillID, null as veBillDetailID, _veBillID as veBillID, null as vePODetailID, _QP_Description as description,'QP' as itemCode,
    1 as QuantityOrdered,_estimatedBilling as QuantityReceived,
    IFNULL(_estimatedBilling,0) as availableToInvoice, 0 as backOrdered, 
	1 as quantityBilled, _QP_prMasterID as prMasterId, null prFromWarehouseID, _estimatedBilling as  unitCost, 1 as priceMultiplier, 1 as taxable, 0 as isInventory,NULL AS note;

ELSEIF(_action='veBilToCommissionInvoice') THEN
    SELECT IFNULL (b.CommAmount,0),d.joReleaseDetailID,d.joReleaseID,p.vePOID INTO _estimatedBilling,_joReleaseDetailID,_joReleaseID,_vePOID FROM 
    veCommDetail b LEFT JOIN joReleaseDetail d ON (b.joReleaseDetailID = d.joReleaseDetailID) 
    LEFT JOIN joRelease r ON (d.joReleaseID = r.joReleaseID)
    LEFT JOIN vePO p ON(r.joReleaseID=p.joReleaseID)
    WHERE b.veCommDetailID = _veBillID; 

	SELECT prMasterID,Description INTO _QP_prMasterID,_QP_Description FROM prMaster WHERE ItemCode='QP' LIMIT 1;    
        
    SELECT NULL AS cuInvoiceId,d.cuSOID, d.cuSODetailID,d.vePOID, d.vePODetailID, Description AS description,ItemCode AS itemCode,
    QuantityOrdered,d.QuantityReceived,
    IFNULL(SUM(d.availableToInvoice),QuantityOrdered) AS availableToInvoice, IFNULL(SUM(d.backOrdered),0) AS backOrdered, 
	d.QuantityBilled AS quantityBilled, prMasterID AS prMasterId,prFromWarehouseID, 0 AS unitCost,0 AS priceMultiplier,Taxable AS taxable,IsInventory AS isInventory,d.note 
	FROM (
	SELECT 
    detail.Description AS description,p.ItemCode AS itemCode,
    NULL AS cuSOID,  detail.vePOID, detail.QuantityOrdered,  detail.UnitCost AS unitCost, detail.PriceMultiplier AS priceMultiplier, detail.Taxable AS taxable,
	NULL AS cuSODetailBinID, detail.vePODetailID, NULL AS cuSODetailID, NULL AS binId, 0 AS allocated, 
    detail.QuantityReceived,
    detail.QuantityBilled AS QuantityBilled, detail.QuantityBilled AS vePOQuantityBilled,
	(detail.QuantityOrdered - detail.QuantityBilled) AS availableToInvoice,
	0 AS backOrdered,
	0 AS InventoryOnHand,  NULL AS binName, p.prMasterID, so.prWarehouseID AS prFromWarehouseID, p.IsInventory ,0 AS whseCost,detail.Note AS note 
	FROM vePODetail detail  
    LEFT JOIN vePO so ON (so.vePOID = detail.vePOID)
	-- left join cuSODetailBin sodb on (detail.cuSODetailID = sodb.cuSODetailID) 
	-- left join bin b on (b.binId = sodb.binId)
    LEFT JOIN prMaster p ON (p.prMasterID = detail.prMasterID)
	WHERE detail.vePOID = _vePOID) d
	GROUP BY d.vePODetailID
    UNION
    SELECT NULL AS cuInvoiceId,NULL AS cuSOID, NULL AS cuSODetailID,NULL AS vePOID, NULL AS vePODetailID,
    _QP_Description AS description,'QP' AS itemCode,
    1 AS QuantityOrdered,1 AS QuantityReceived,
   1 AS availableToInvoice, 0 AS backOrdered, 
	1 AS quantityBilled, _QP_prMasterID AS prMasterId,NULL AS prFromWarehouseID, _estimatedBilling AS unitCost,1 AS priceMultiplier,1 AS taxable,0 AS isInventory,NULL AS note
	;
    
ELSE
	select null as cuInvoiceId,d.veBillID, d.veBillDetailID, d.veBillID, d.vePODetailID, Description as description, ItemCode as itemCode,
    QuantityOrdered,d.QuantityReceived,
    IFNULL(sum(d.availableToInvoice),QuantityOrdered) as availableToInvoice, IFNULL(sum(d.backOrdered),0) as backOrdered, 
	d.QuantityBilled as quantityBilled, prMasterID as prMasterId,prFromWarehouseID, UnitCost as unitCost,PriceMultiplier as priceMultiplier,Taxable as taxable,IsInventory as isInventory,d.note
	from (
	select 
    detail.Description as description,p.ItemCode as itemCode,
    null as cuSOID,  detail.veBillID, detail.QuantityBilled as QuantityOrdered,  detail.UnitCost as unitCost, detail.PriceMultiplier as priceMultiplier, detail.Taxable as taxable,
	null as cuSODetailBinID, detail.veBillDetailID, detail.vePODetailID, null as cuSODetailID, null as binId, 0 as allocated, 
    0  as QuantityReceived,
    detail.QuantityBilled as QuantityBilled, detail.QuantityBilled as vePOQuantityBilled,
	detail.QuantityBilled as availableToInvoice,
	0 as backOrdered,
	0 as InventoryOnHand,  null as binName, p.prMasterID, null as prFromWarehouseID, p.IsInventory ,0 as whseCost,detail.Note AS note
	from veBillDetail detail  
    left join veBill so on (so.veBillID = detail.veBillID)
	-- left join cuSODetailBin sodb on (detail.cuSODetailID = sodb.cuSODetailID) 
	-- left join bin b on (b.binId = sodb.binId)
    left join prMaster p on (p.prMasterID = detail.prMasterID)
	where detail.veBillID = _veBillID) d
	group by d.veBillDetailID;
    
    
END IF;

END$$

DELIMITER ;

-- ============================================================


DROP procedure IF EXISTS `BO_getBillOnly`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `BO_getBillOnly`(
IN _joReleaseId INT
)
BO_getBillOnly:BEGIN
DECLARE _estimatedBilling decimal(19,4);
DECLARE _QP_prMasterID INT;
DECLARE _QP_Description varchar(255);

			select IFNULL(EstimatedBilling,0) into _estimatedBilling from joRelease  where joReleaseID = _joReleaseId ;
            
            select prMasterID,Description into _QP_prMasterID,_QP_Description from prMaster where ItemCode='QP' limit 1;
            
            select ifnull((_estimatedBilling-sum(Subtotal)),_estimatedBilling) into _estimatedBilling
			from cuInvoice ci
			left join joReleaseDetail jrd on (jrd.joReleaseDetailID = ci.joReleaseDetailID)
			left join joRelease jr on (jr.joReleaseID = jrd.joReleaseID)
			where jr.joReleaseID = _joReleaseID;
            
            if (_estimatedBilling < 0) THEN set _estimatedBilling=0; END IF;
            
            select null as cuInvoiceId,null as cuSOID, null as cuSODetailID,null as vePOID, null as vePODetailID,
			_QP_Description as description,'QP' as itemCode,
			1 as QuantityOrdered,1 as QuantityReceived,
			1 as availableToInvoice, 0 as backOrdered, 
			1 as quantityBilled, _QP_prMasterID as prMasterId,null as prFromWarehouseID, _estimatedBilling as unitCost,
            1 as priceMultiplier,1 as taxable,0 as isInventory,NULL AS note ;
END$$

DELIMITER ;



-- ============================================================
-- call PO_getVePODetail(null,142583,null);

DROP procedure IF EXISTS `PO_getVePODetail`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `PO_getVePODetail`(
IN _action varchar(20),
IN _vePOID INT,
IN _vePODetailID INT
)
PO_getVePODetail: BEGIN
DECLARE _estimatedBilling decimal(19,4);
DECLARE _QP_prMasterID INT;
DECLARE _QP_Description varchar(255);
DECLARE _joReleaseDetailID INT;
DECLARE _joReleaseID INT;

	select IFNULL(EstimatedBilling,0),b.joReleaseID into _estimatedBilling,_joReleaseID from joRelease r
    
    left join vePO b on (b.joReleaseID = r.joReleaseID) 
    where b.vePOID = _vePOID; 
	
	select prMasterID,Description into _QP_prMasterID,_QP_Description from prMaster where ItemCode='QP' limit 1;
	
    select ifnull((_estimatedBilling-sum(Subtotal)),_estimatedBilling) into _estimatedBilling
	from cuInvoice ci
	left join joReleaseDetail jrd on (jrd.joReleaseDetailID = ci.joReleaseDetailID)
	left join joRelease jr on (jr.joReleaseID = jrd.joReleaseID)
	where jr.joReleaseID = _joReleaseID;
	
	if (_estimatedBilling < 0) THEN set _estimatedBilling=0; END IF;
    
	select null as cuInvoiceId,d.cuSOID, d.cuSODetailID,d.vePOID, d.vePODetailID, Description as description,ItemCode as itemCode,
    QuantityOrdered,d.QuantityReceived,
    IFNULL(sum(d.availableToInvoice),QuantityOrdered) as availableToInvoice, IFNULL(sum(d.backOrdered),0) as backOrdered, 
	d.QuantityBilled as quantityBilled, prMasterID as prMasterId,prFromWarehouseID, 0 as unitCost,0 as priceMultiplier,Taxable as taxable,IsInventory as isInventory,d.note 
	from (
	select 
    detail.Description as description,p.ItemCode as itemCode,
    null as cuSOID,  detail.vePOID, detail.QuantityOrdered,  detail.UnitCost as unitCost, detail.PriceMultiplier as priceMultiplier, detail.Taxable as taxable,
	null as cuSODetailBinID, detail.vePODetailID, null as cuSODetailID, null as binId, 0 as allocated, 
    detail.QuantityReceived,
    detail.QuantityBilled as QuantityBilled, detail.QuantityBilled as vePOQuantityBilled,
	(detail.QuantityOrdered - detail.QuantityBilled) as availableToInvoice,
	0 as backOrdered,
	0 as InventoryOnHand,  null as binName, p.prMasterID, so.prWarehouseID as prFromWarehouseID, p.IsInventory ,0 as whseCost,detail.Note AS note 
	from vePODetail detail  
    left join vePO so on (so.vePOID = detail.vePOID)
	-- left join cuSODetailBin sodb on (detail.cuSODetailID = sodb.cuSODetailID) 
	-- left join bin b on (b.binId = sodb.binId)
    left join prMaster p on (p.prMasterID = detail.prMasterID)
	where detail.vePOID = _vePOID) d
	group by d.vePODetailID
    UNION
    select null as cuInvoiceId,null as cuSOID, null as cuSODetailID,null as vePOID, null as vePODetailID,
    _QP_Description as description,'QP' as itemCode,
    1 as QuantityOrdered,1 as QuantityReceived,
   1 as availableToInvoice, 0 as backOrdered, 
	1 as quantityBilled, _QP_prMasterID as prMasterId,null as prFromWarehouseID, _estimatedBilling as unitCost,1 as priceMultiplier,1 as taxable,0 as isInventory,NULL AS note
	;


END$$

DELIMITER ;


-- ============================================================
-- call INVOICE_getInvoiceDetail(_action,_billOrInvoiceID,_cuSOID,_vePOID,_veBillID); - action=CustomerInvoice or CustomerInvoiceBin or VendorInvoice
-- call INVOICE_getInvoiceDetail('CustomerInvoice',290515,null,null,null);
-- call INVOICE_getInvoiceDetail('CustomerInvoice',null,91677,null,null);
-- call INVOICE_getInvoiceDetail('CustomerInvoice',null,null,null,194477); -- vebill
-- call INVOICE_getInvoiceDetail('CustomerInvoiceBin',290515,null,null,null);
-- call INVOICE_getInvoiceDetail('CustomerInvoice',null,null,142583,null);
-- call INVOICE_getInvoiceDetail('VendorInvoice',190043,null,null,null);
-- call INVOICE_getInvoiceDetail('VendorInvoice',null,null,142583,null);

DROP procedure IF EXISTS `INVOICE_getInvoiceDetail`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_getInvoiceDetail`(
IN _action varchar(20),
IN _cuInvoiceID INT,  -- should be only cuInvoiceId
IN _cuSOID INT,
IN _vePOID INT,
IN _veBillID INT,
IN _joReleaseId INT
)
INVOICE_getInvoiceDetail: BEGIN
DECLARE _joReleaseType INT;
if (_action = 'CustomerInvoice') THEN
	if (_cuInvoiceID is not null) THEN
		if(_vePOID is not null) then
			if(_veBillID is not null) then
				select 
			detail.Description as description ,p.ItemCode as itemCode,
			detail.cuInvoiceID, detail.cuSODetailID, sd.vePOID, ifnull(sd.QuantityOrdered,detail.QuantityBilled) as QuantityOrdered , detail.UnitCost as unitCost, detail.PriceMultiplier as priceMultiplier, detail.Taxable as taxable,
			sodb.cuInvoiceDetailBinID, detail.cuInvoiceDetailId, sodb.binId, sd.QuantityOrdered as allocated, detail.QuantityBilled as quantityBilled ,
			detail.QuantityBilled as availableToInvoice,
			(case when 
            ((sd.QuantityOrdered-ifNull(sd.QuantityBilled,0))) > 0 then
            (sd.QuantityOrdered-ifNull(sd.QuantityBilled,0))
            else 0 end)
             AS backOrdered,null as vePODetailID,veb.QuantityBilled as vebillbill,
			-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
			b.InventoryOnHand, b.searchName as binName, p.prMasterID as prMasterId , so.prFromWarehouseID, p.IsInventory as isInventory,detail.whseCost,detail.position ,detail.Note AS note
			from cuInvoiceDetail detail  
			left join cuInvoice so on (so.cuInvoiceID = detail.cuInvoiceID)
			left join cuInvoiceDetailBin sodb on (detail.cuInvoiceDetailID = sodb.cuInvoiceDetailID)
			left join vePODetail sd on (sd.vePODetailID = detail.cuSODetailID)
            left join veBillDetail veb on (sd.vePODetailID = veb.vePODetailID and veb.veBillID=_veBillID)
			left join `bin` b on (b.binId = sodb.binId)
			left join prMaster p on (p.prMasterID = detail.prMasterID)
			where detail.cuInvoiceID = _cuInvoiceID
			order by position;
			else
				select 
			detail.Description as description ,p.ItemCode as itemCode,
			detail.cuInvoiceID, detail.cuSODetailID, sd.vePOID, ifnull(sd.QuantityOrdered,detail.QuantityBilled) as QuantityOrdered , detail.UnitCost as unitCost, detail.PriceMultiplier as priceMultiplier, detail.Taxable as taxable,
			sodb.cuInvoiceDetailBinID, detail.cuInvoiceDetailId, sodb.binId, sd.QuantityOrdered as allocated, detail.QuantityBilled as quantityBilled ,
			detail.QuantityBilled as availableToInvoice,
			-- (sd.QuantityOrdered-ifNull(sd.QuantityBilled,0))  
            0 AS backOrdered,null as vePODetailID,
			-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
			b.InventoryOnHand, b.searchName as binName, p.prMasterID as prMasterId , so.prFromWarehouseID, p.IsInventory as isInventory,detail.whseCost,detail.position,detail.Note AS note 
			from cuInvoiceDetail detail  
			left join cuInvoice so on (so.cuInvoiceID = detail.cuInvoiceID)
			left join cuInvoiceDetailBin sodb on (detail.cuInvoiceDetailID = sodb.cuInvoiceDetailID)
			left join vePODetail sd on (sd.vePODetailID = detail.cuSODetailID)
			left join `bin` b on (b.binId = sodb.binId)
			left join prMaster p on (p.prMasterID = detail.prMasterID)
			where detail.cuInvoiceID = _cuInvoiceID
			order by position;
            end if;
		else
			select 
			detail.Description as description ,p.ItemCode as itemCode,
			detail.cuInvoiceID, detail.cuSODetailID, sd.cuSOID, ifnull(sd.QuantityOrdered,detail.QuantityBilled) as QuantityOrdered , detail.UnitCost as unitCost, detail.PriceMultiplier as priceMultiplier, detail.Taxable as taxable,
			sodb.cuInvoiceDetailBinID, detail.cuInvoiceDetailId, sodb.binId, sd.QuantityOrdered as allocated, detail.QuantityBilled as quantityBilled ,
			detail.QuantityBilled as availableToInvoice,
			(sd.QuantityOrdered-ifNull(sd.QuantityBilled,0))  AS backOrdered,null as vePODetailID,
			-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
			b.InventoryOnHand, b.searchName as binName, p.prMasterID as prMasterId , so.prFromWarehouseID, p.IsInventory as isInventory,detail.whseCost,detail.position ,detail.Note AS note,
            ROUND_TO_EVEN((syv.ValueCurrency*p.AverageCost),2) as whseCost
			from cuInvoiceDetail detail  
			left join cuInvoice so on (so.cuInvoiceID = detail.cuInvoiceID)
			left join cuInvoiceDetailBin sodb on (detail.cuInvoiceDetailID = sodb.cuInvoiceDetailID)
			left join cuSODetail sd on (sd.cuSODetailID = detail.cuSODetailID)
			left join `bin` b on (b.binId = sodb.binId)
			left join prMaster p on (p.prMasterID = detail.prMasterID)
            LEFT JOIN sysVariable syv on (syv.sysVariableID = 1020000)
			where detail.cuInvoiceID = _cuInvoiceID
			group by detail.cuInvoiceDetailId
			order by position;
			
			
		end if;
	elseif (_cuSOID is not null) THEN
		call SO_getSODetail('SODetail',_cuSOID,null);
	elseif (_veBillID is not null) THEN
		SELECT jr.ReleaseType INTO _joReleaseType FROM vePO v LEFT JOIN joRelease jr ON(v.joReleaseId=jr.joReleaseId) WHERE vePOId=_vePOID;
		IF (_joReleaseType=4)THEN
		  CALL PO_getVeBillDetail('veBilToCommissionInvoice',_veBillID,NULL);
		ELSE
		  CALL PO_getVeBillDetail('veBilToInvoice',_veBillID,NULL); -- invoice ready, not rall veBillDetail items.
		END IF;
		-- call PO_getVeBillDetail('veBill',_veBillID,null); -- invoice ready, not rall veBillDetail items.
    elseif (_vePOID is not null) THEN
		call PO_getVePODetail(null,_vePOID,null);
    elseif(_joReleaseId is not null) then
		call BO_getBillOnly(_joReleaseId);
    
    
    END IF;
    
ELSEif (_action = 'CustomerInvoiceBin') THEN
	if (_cuInvoiceID is not null) THEN
		select 
		p.Description,p.ItemCode,
		detail.cuInvoiceID, detail.cuSODetailID, sd.cuSOID, sd.QuantityOrdered, detail.UnitCost, detail.PriceMultiplier, detail.Taxable,
		sodb.cuInvoiceDetailBinID, detail.cuInvoiceDetailId, sodb.binId, sd.QuantityOrdered as allocated, detail.QuantityBilled as QuantityBilled ,
		detail.QuantityBilled as availableToInvoice,
		detail.onOrder as backOrdered,
		-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
		b.InventoryOnHand, b.searchName as binName, p.prMasterID as prMasterId, so.prFromWarehouseID, p.IsInventory
		from cuInvoiceDetail detail  
		left join cuInvoice so on (so.cuInvoiceID = detail.cuInvoiceID)
		left join cuInvoiceDetailBin sodb on (detail.cuInvoiceDetailID = sodb.cuInvoiceDetailID)
		left join cuSODetail sd on (sd.cuSODetailID = detail.cuSODetailID)
		left join `bin` b on (b.binId = sodb.binId)
		left join prMaster p on (p.prMasterID = detail.prMasterID)
		where detail.cuInvoiceID = _cuInvoiceID;
	elseif (_cuSOID is not null) THEN
		call SO_getSODetail('SODetailBin',_cuSOID,null);
    elseif (_vePOID is not null) THEN
		call PO_getVePODetail(null,_vePOID,null);
    elseif (_veBillID is not null) THEN
		call PO_getVeBillDetail('cuInvoice',_veBillID,null); -- invoice ready, not rall veBillDetail items.
        
    END IF;
/* 
ELSEif (_action = 'VendorInvoice') THEN
	if (_cuInvoiceID is not null) THEN
		select 
		detail.Description as description ,p.ItemCode as itemCode,
		detail.veBillID, detail.veBillDetailID, 
		null as cuInvoiceID, null as cuInvoiceDetailID, null as cuInvoiceDetailBinID,
        detail.vePODetailID, so.vePOID, 
        null as QuantityOrdered , detail.UnitCost as unitCost, detail.PriceMultiplier as priceMultiplier, detail.Taxable as taxable,
		null binId, detail.QuantityBilled as quantityBilled ,
		detail.QuantityBilled as availableToInvoice,
		null as backOrdered,
		-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
		null as InventoryOnHand, null as binName, p.prMasterID, null prFromWarehouseID, p.IsInventory as isInventory,null as whseCost
		from veBillDetail detail  
		left join veBill so on (so.veBillID = detail.veBillID)
		left join prMaster p on (p.prMasterID = detail.prMasterID)
		-- where so.vePOID = _vePOID;
		where detail.veBillID = _billOrInvoiceID;
	
    elseif (_vePOID is not null) THEN
		call PO_getVePODetail(null,_vePOID,null);
    
    END IF;
*/
END IF;
END$$

DELIMITER ;

-- ============================================================
-- call INVOICE_updateInvoice('UPDATE',cuInvoiceId,cuSOID, vePOID, rxCustomerID, rxBillToID, rxBillToAddressID, rxContactID
-- _rxShipToID,rxShipToAddressID, _ShipToMode,_veShipViaID,isCareOfRequired, _Tag, empSalesRepID, empAEID, empCostID, empSubmitID, empOrderID
-- coDivisionID, _CustomerPONumber, _DoNotMail, _coTaxTerritoryID, cuTermsID, dueDate,changedByID,freight,joReleaseDetailID,shipDate,_prToWareHouseID ,
-- _shipToName,_shipToAddress1,_shipToAddress2,_shipToCity,_shipToState,_shipToZip,_joReleaseID,_joMasterID,_joReleaseSeq);

-- CREATE NEW INVOICE FROM SO
-- call INVOICE_updateInvoice('UPDATE',null,91677, null, null, null, null, null,null,null, null,null,null, null, null, null, null, null, null,null, null, null, null, null, null,1,null,null,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL );
-- UPDATE INVOICE
-- call INVOICE_updateInvoice('UPDATE',290552,null, null, null, null, null, null,null,null, null,null,null, null, null, null, null, null, 44,null, 'ponumber', 1, 286, null, null,10,10,,null,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL );
-- CREATE NEW INVOICE FROM PO
-- call INVOICE_updateInvoice('UPDATE',null,null, 142583, null, null, null, null,null,null, null,null,null, null, null, null, null, null, null,null, null, null, null, null, null,1,null,null,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL );


DROP procedure IF EXISTS `INVOICE_updateInvoice`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_updateInvoice`(
IN _action varchar(20),
IN _cuInvoiceID INT,
IN _cuSOID INT,
IN _vePOID INT,
IN _rxCustomerID INT,
IN _rxBillToID INT,
IN _rxBillToAddressID INT,
IN _rxContactID INT,
IN _rxShipToID INT,
IN _rxShipToAddressID INT,
IN _ShipToMode INT,
IN _veShipViaID INT,
IN _isCareOfRequired INT,
IN _Tag VARCHAR(255),
IN _empSalesRepID INT,
IN _empAEID INT,
IN _empCostID INT,
IN _empSubmitID INT,
IN _empOrderID INT,
IN _coDivisionID INT,
IN _CustomerPONumber varchar(255),
IN _DoNotMail INT,
IN _coTaxTerritoryID INT,
IN _cuTermsID INT,
IN _dueDate DATE,
IN _changedByID INT,
IN _Freight decimal(19,4),  -- note remove from declare
IN _subTotal1 decimal(19,4),
IN _taxTotal1  decimal(19,4),
IN _joReleaseDetailID INT,   -- note remove from declare
IN _ShipDate DATE,
IN _prToWareHouseID INT,
IN _shipToName VARCHAR(80),
IN _shipToAddress1 VARCHAR(40),
IN _shipToAddress2 VARCHAR(40),
IN _shipToCity VARCHAR(30),
IN _shipToState VARCHAR(10),
IN _shipToZip VARCHAR(10),
IN _joReleaseID INT,
IN _joMasterID INT,
IN _joReleaseSeq VARCHAR(50),
IN _TrackingNumber VARCHAR(50),
IN _invoiceDate DATE
)
INVOICE_updateInvoice: BEGIN
DECLARE _count INT DEFAULT 0;
DECLARE _prFromWarehouseID INT;
-- DECLARE _joReleaseID INT;
-- DECLARE _joMasterID INT;
-- DECLARE _ShipDate DATETIME;
DECLARE _DatePromised DATETIME;
DECLARE _SONumber varchar(255);
DECLARE _InvoiceNumber varchar(255);
DECLARE _cuTermsDescription varchar(255);
DECLARE _InvoiceAmount decimal(19,4);
DECLARE _AppliedAmount decimal(19,4);
DECLARE _TaxAmount decimal(19,4);
-- DECLARE _Freight decimal(19,4);
DECLARE _FreightCost decimal(19,4);
DECLARE _CostTotal decimal(19,4);
DECLARE _Subtotal decimal(19,4);
DECLARE _TaxTotal decimal(19,4);
DECLARE _TaxRate decimal(19,6);
-- DECLARE _TrackingNumber varchar(255);
DECLARE _IsCredit INT;
DECLARE _cIopenStatus INT DEFAULT 1;
DECLARE _whseCostTotal decimal(19,4);
DECLARE _taxfreight decimal(19,4);
DECLARE _TaxableSales decimal(19,4);
DECLARE _NonTaxableSales decimal(19,4);
DECLARE _LastcoTaxTerritoryID INT;
DECLARE _LastFreight decimal(19,4);
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _ids varchar(255);
DECLARE _ID INT;
DECLARE commaNeeded INT DEFAULT 0;
DECLARE _sysVariable INT;
DECLARE _joReleaseType INT;
DECLARE _jobNumber VARCHAR(255);
DECLARE _transType varchar(50);
DECLARE _lastSubTotal decimal(19,4);

DECLARE _lastTaxAmount decimal(19,4);
DECLARE _LastInvoiceDate DATE;

DECLARE _inside_joReleaseDetailID INT;

IF (_ShipToMode=3 AND _rxShipToAddressID IS NULL)THEN
CALL sp_rolodex_address_update('Update',NULL,NULL,0,_shipToName,_shipToAddress1,_shipToAddress2,
_shipToCity,_shipToState,_shipToZip,0,0,0,1,NULL,NULL,3,NULL,NULL,NULL,0,0,_rxShipToAddressID);
END IF;
-- CONSIDER A QUICK CHECK ON OPEN PERIOD
if (_action = 'UPDATE') THEN
	if (_cuInvoiceID is null) THEN
	   
		if (_cuSOID is not null) THEN
            -- get the SO information
			select s.joReleaseID,r.joMasterID,IFNULL(_ShipDate,CURRENT_TIMESTAMP()) as shipDate,_rxCustomerID AS rxCustomerID,rxBillToID,rxBillToAddressID,_rxShipToID AS rxShipToID,_rxShipToAddressID AS rxShipToAddressID,_veShipViaID AS veShipViaID,prFromWarehouseID,
            s.cuTermsID,_ShipToMode,_coTaxTerritoryID AS coTaxTerritoryID,s.SONumber,
			-- s.CustomerPONumber
			_CustomerPONumber AS CustomerPONumber
			,STR_TO_DATE(s.DatePromised, '%c/%e/%Y'),
            s.CostTotal,s.SubTotal,s.TaxTotal,_Freight AS Freight,s.TaxRate,
            s.cuAssignmentID0,s.cuAssignmentID1,s.cuAssignmentID2,s.cuAssignmentID3,s.cuAssignmentID4,
            _TrackingNumber AS TrackingNumber,_Tag AS Tag,FreightCost,_coDivisionID AS coDivisionID,_cuTermsID AS cuTermsID,term.Description,
            s.rxContactID,s.whseCostTotal,s.taxfreight,s.TaxableSales,s.NonTaxableSales,s.isCareOfRequired
            into _joReleaseID,_joMasterID,_ShipDate,_rxCustomerID,_rxBillToID,_rxBillToAddressID,_rxShipToID,_rxShipToAddressID,_veShipViaID,_prFromWarehouseID,
			_cuTermsID,_ShipToMode,_coTaxTerritoryID,_SONumber,_CustomerPONumber,_DatePromised,
            _CostTotal,_SubTotal,_TaxTotal,_Freight,_TaxRate,
            _empSalesRepID,_empAEID,_empCostID,_empSubmitID, _empOrderID,
            _TrackingNumber,_Tag,_FreightCost,_coDivisionID,_cuTermsID,_cuTermsDescription,
            _rxContactID,_whseCostTotal,_taxfreight,_TaxableSales,_NonTaxableSales,_isCareOfRequired         
            from cuSO s
            left join joRelease r on (r.joReleaseID = s.joReleaseID)
            left join cuTerms term on (term.cuTermsID = _cuTermsID)
            where s.cuSOID = _cuSOID;
 
            
            if(_joMasterID is not null) THEN 
			--	select count(cuSOID)+1 into _count from cuInvoice where cuSOID=_cuSOID;
				SELECT totalCount INTO _count FROM (
					SELECT ci.cuSOID,COUNT(IFNULL(ci.cuSOID,0)) AS totalCount,CASE jr.ReleaseType WHEN 1 THEN "DropShip" WHEN 2 THEN "StockOrder" WHEN 3 THEN "BillOnly" WHEN 4 THEN "CommissionOrder" WHEN 5 THEN "ServiceOrder" ELSE "SalesOrder" END AS releaseType
					FROM cuInvoice ci 
					LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID) 
					LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
					WHERE ci.cuSOID=_cuSOID
					GROUP BY cuSOID,releaseType
				) test WHERE releaseType IN('StockOrder','ServiceOrder');
				SET _count=IFNULL(_count,0)+1;
				set _InvoiceNumber = concat(_SONumber,_count);
            else
				SELECT COUNT(cuSOID) INTO _count FROM cuInvoice WHERE cuSOID=_cuSOID AND (joReleaseDetailID IS NULL or joReleaseDetailID = 0);
				SET _count=IFNULL(_count,0)+1;
				SET _InvoiceNumber = CONCAT(_SONumber,'-',_count);
            end if;
            set _TaxAmount = _TaxTotal;
            SET _DoNotMail =IFNULL(_DoNotMail,0);
			set _InvoiceAmount = _SubTotal;
			set _AppliedAmount = 0;
            set _IsCredit = 0;
            
 -- select _InvoiceNumber;
 
-- select _joReleaseID,_joMasterID,_ShipDate, _joReleaseDetailID;
      
 
		elseif (_vePOID is not null) THEN
		
            -- get the SO information
			select s.joReleaseID,r.joMasterID,IFNULL(_ShipDate,CURRENT_TIMESTAMP()) as shipDate,_rxCustomerID AS rxCustomerID,IFNULL(_rxBillToID,rxBillToID) AS rxBillToID,rxBillToAddressID,_rxShipToID AS rxShipToID,_rxShipToAddressID AS rxShipToAddressID,_veShipViaID AS veShipViaID,prWarehouseID,
            _ShipToMode,_coTaxTerritoryID as coTaxTerritoryID,s.PONumber,_CustomerPONumber AS CustomerPONumber,STR_TO_DATE(s.DateWanted, '%c/%e/%Y'),
            0 as CostTotal,0 AS SubTotal,0 AS TaxTotal,_Freight AS Freight,s.TaxRate,
            -- s.cuAssignmentID0,s.cuAssignmentID1,s.cuAssignmentID2,s.cuAssignmentID3,s.cuAssignmentID4,
            _TrackingNumber AS  TrackingNumber,_Tag AS Tag,0 as _FreightCost,null as Description,
            s.rxVendorContactID,0 as whseCostTotal,0 as taxfreight,0 as TaxableSales,0 as NonTaxableSales,s.isCareOfRequired
            into
            _joReleaseID,_joMasterID,_ShipDate,_rxCustomerID,_rxBillToID,_rxBillToAddressID,_rxShipToID,_rxShipToAddressID,_veShipViaID,_prFromWarehouseID,
		    _ShipToMode,_coTaxTerritoryID,_SONumber,_CustomerPONumber,_DatePromised,
            _CostTotal,_SubTotal,_TaxTotal,_Freight,_TaxRate,
            -- _empSalesRepID,_empAEID,_empCostID,_empSubmitID, _empOrderID,
            _TrackingNumber,_Tag,_FreightCost,_cuTermsDescription,
            _rxContactID,_whseCostTotal,_taxfreight,_TaxableSales,_NonTaxableSales,_isCareOfRequired                  
            from vePO s
            left join joRelease r on (r.joReleaseID = s.joReleaseID)
            -- left join cuTerms term on (term.cuTermsID = s.cuTermsID)
            where s.vePOID = _vePOID;
 
			-- hack to overload cuSOID in the invoice table.  Probably should change this one day.
			set _cuSOID = _vePOID;
			
            -- select count(cuSOID)+1 into _count from cuInvoice where cuSOID=_vePOID;
			if(_joReleaseDetailID is not null) then
					select test.num into _count
				from (SELECT 
					(@row_number:=@row_number + 1) AS num, 
					joReleaseDetailID
				FROM
					joReleaseDetail,
					(SELECT @row_number:=0) AS t
					where joReleaseID= _joReleaseID 
					)test
					where test.joReleaseDetailID = _joReleaseDetailID;
				end if;
			/* SELECT totalCount INTO _count FROM (
				SELECT ci.cuSOID,COUNT(IFNULL(ci.cuSOID,0)) AS totalCount,CASE jr.ReleaseType WHEN 1 THEN "DropShip" WHEN 2 THEN "StockOrder" WHEN 3 THEN "BillOnly" WHEN 4 THEN "CommissionOrder" WHEN 5 THEN "ServiceOrder" ELSE "SalesOrder" END AS releaseType
				FROM cuInvoice ci 
				LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID) 
				LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
				WHERE ci.cuSOID=_vePOID
				GROUP BY cuSOID,releaseType
			) test WHERE releaseType IN('DropShip','CommissionOrder'); */
            if(_joReleaseDetailID is null) then 
            select count(*) into _count from joReleaseDetail where joReleaseID= _joReleaseID ;
			SET _count=IFNULL(_count,0)+1;
            end if;
            set _InvoiceNumber = concat(_SONumber,_count);
            set _TaxAmount = _TaxTotal;
            SET _DoNotMail =IFNULL(_DoNotMail,0);
			set _InvoiceAmount = _SubTotal;
			set _AppliedAmount = 0;
            set _IsCredit = 0;
  		ELSE
			-- For BillOnly CustomerInvoice
			IF (_joReleaseID IS NOT NULL) THEN
				SELECT jr.ReleaseType,jm.JobNumber INTO _joReleaseType,_jobNumber FROM joRelease jr LEFT JOIN joMaster jm ON(jr.joMasterID=jm.joMasterID) WHERE joReleaseID=_joReleaseID;
				IF (_joReleaseType=3 AND _joReleaseSeq IS NOT NULL) THEN
				SELECT COUNT(joReleaseDetailID) INTO _count FROM joReleaseDetail WHERE joReleaseID=_joReleaseID;
				SET _count=IFNULL(_count,0)+1;
				SET _InvoiceNumber = CONCAT(_jobNumber,_joReleaseSeq,_count);
				END IF;
			END IF;
        END IF;
		
		if (_coDivisionID is null or _cuTermsID is null) THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call INVOICE_updateInvoice:Required: _coDivisionID,_cuTermsID';
			leave INVOICE_updateInvoice; 
        END IF;
		if (_joReleaseID >0 and _joMasterID>0) THEN
			if(_joReleaseDetailID is not null) then 
            
				update joReleaseDetail set CustomerInvoiceDate = Date(now()), CustomerInvoiceAmount = _InvoiceAmount where joReleaseDetailID = _joReleaseDetailID;
			else
            -- create the releaseDetail
            insert into joReleaseDetail (joReleaseID,joMasterID,ShipDate,VendorInvoiceDate,VendorInvoiceAmount,
            CustomerInvoiceDate,CustomerInvoiceAmount)
			values
            (_joReleaseID,_joMasterID,_ShipDate,null,null,Date(now()),_InvoiceAmount);
            
            SELECT LAST_INSERT_ID() INTO _joReleaseDetailID;
            end if;
		end if;
		
		-- should be able to create if was from a vePO or a cuSO or just a straight invoice.
		if ( _rxCustomerID > 0 ) THEN
			if(_InvoiceNumber is null) THEN
				SELECT ValueString into _InvoiceNumber  FROM sysVariable where sysVariableID = 2014002015;
                 select REPLACE(_InvoiceNumber, '"', '' ) into _sysVariable ;
                update sysVariable set ValueString = (_sysVariable+1) where sysVariableID = 2014002015;
			end if;
            if(_joReleaseDetailID is null) then
				set _joReleaseDetailID = 0;
			end if;
            set _InvoiceAmount = ifnull(_subTotal1,0.0000)+ifnull(_freight,0.0000)+ifnull(_taxTotal1,0.0000);                       
			insert into cuInvoice 
            (CreatedByID,CreatedOn,ChangedByID,ChangedOn,TransactionStatus,Applied,
			joReleaseDetailID,cuSOID,rxCustomerID,rxBillToID,rxBillToAddressID,rxShipToID,rxShipToAddressID,veShipViaID,prFromWarehouseID,prToWarehouseID,
            cuTermsID,ShipToMode,coTaxTerritoryID,InvoiceNumber,CustomerPONumber,InvoiceDate,ShipDate,DueDate,
            InvoiceAmount,AppliedAmount,TaxAmount,Freight,CostTotal,Subtotal,TaxTotal,TaxRate,
            cuAssignmentID0,cuAssignmentID1,cuAssignmentID2,cuAssignmentID3,cuAssignmentID4,
            TrackingNumber,jobnodescription,FreightCost,coDivisionID,DoNotMail,Description,IsCredit,
            rxContactID,cIopenStatus,
            whseCostTotal,taxfreight,TaxableSales,NonTaxableSales,isCareOfRequired)
			values
			(_changedByID,now(),null,null,1,0,
			_joReleaseDetailID,_cuSOID,_rxCustomerID,_rxBillToID,_rxBillToAddressID,_rxShipToID,_rxShipToAddressID,_veShipViaID,_prFromWarehouseID,_prToWarehouseID,
            _cuTermsID,ifnull(_ShipToMode,0),_coTaxTerritoryID,_InvoiceNumber,_CustomerPONumber,ifnull(_invoiceDate,now()),_ShipDate,Date(_dueDate),
            ifnull(_InvoiceAmount,0.0000),ifnull(_AppliedAmount,0.0000),ifnull(_TaxAmount,0.0000),_Freight,_CostTotal,_subTotal,_taxTotal,_TaxRate,
            _empSalesRepID,_empAEID,_empCostID,_empSubmitID, _empOrderID,
            _TrackingNumber,_Tag,_FreightCost,_coDivisionID,_DoNotMail,_cuTermsDescription,ifnull(_IsCredit,0),
            _rxContactID,_cIopenStatus,
            _whseCostTotal,ifnull(_taxfreight,0),_TaxableSales,_NonTaxableSales,_isCareOfRequired);
			
             SELECT LAST_INSERT_ID() INTO _cuInvoiceID;
				-- select _cuInvoiceID;
                set _transType = 'CI-Created';
                set _lastSubTotal = 0;
				set _LastFreight = 0;
				set _lastTaxAmount = 0;
				set _LastcoTaxTerritoryID = 0;
				set _LastInvoiceDate = Null;
                select _cuInvoiceID,_transType,_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID;
             -- call INVOICE_tpCuInvoiceLogMaster('CI-Created',_cuInvoiceID,1);
		end if;
		
		
        
    else 
			select Subtotal,TaxAmount,InvoiceDate into _lastSubTotal,_lastTaxAmount,_LastInvoiceDate from cuInvoice where cuInvoiceID = _cuInvoiceID; 
			SET  @l_sql ='update cuInvoice set ';
		   
		
			IF (_rxCustomerID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' rxCustomerID =', _rxCustomerID); 
				SET commaNeeded =1;
			END IF;
			IF (_rxBillToID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' rxBillToID =', _rxBillToID); 
				SET commaNeeded =1;
			END IF;
			IF (_rxBillToAddressID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' rxBillToAddressID =', _rxBillToAddressID); 
				SET commaNeeded =1;
			END IF;
			IF (_rxContactID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' rxContactID =', _rxContactID); 
				SET commaNeeded =1;
			END IF;
			-- IF (_rxShipToID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' rxShipToID =', IFNULL(_rxShipToID,'null'));  
				SET commaNeeded =1;
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' prToWarehouseID =',IFNULL(_prToWarehouseID,'null')); 
				SET commaNeeded =1;
			-- END IF;
			IF (_rxShipToAddressID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' rxShipToAddressID =', _rxShipToAddressID); 
				SET commaNeeded =1;
			END IF;
			IF (_ShipToMode IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' ShipToMode =', _ShipToMode); 
				SET commaNeeded =1;
			END IF;
			IF (_veShipViaID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' veShipViaID =', _veShipViaID); 
				SET commaNeeded =1;
			END IF;
			IF (_isCareOfRequired IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' isCareOfRequired =', _isCareOfRequired); 
				SET commaNeeded =1;
			END IF;
			IF (_empSalesRepID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' cuAssignmentID0 =', _empSalesRepID); 
				SET commaNeeded =1;
			END IF;
			IF (_empAEID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' cuAssignmentID1 =', _empAEID); 
				SET commaNeeded =1;
			END IF;
			IF (_empCostID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' cuAssignmentID2 =', _empCostID); 
				SET commaNeeded =1;
			END IF;
			IF (_empSubmitID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' cuAssignmentID3 =', _empSubmitID); 
				SET commaNeeded =1;
			END IF;
			IF (_empOrderID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' cuAssignmentID4 =', _empOrderID); 
				SET commaNeeded =1;
			END IF;
			IF (_coDivisionID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' coDivisionID =', _coDivisionID); 
				SET commaNeeded =1;
			END IF;
			IF (_DoNotMail IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' DoNotMail =', _DoNotMail); 
				SET commaNeeded =1;
			END IF;
			IF (_Freight IS NOT NULL) THEN 
				select Freight into _LastFreight from cuInvoice where cuInvoiceID = _cuInvoiceID;
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' Freight =', _Freight); 
				SET commaNeeded =1;
			END IF;
            
			
			IF (_coTaxTerritoryID IS NOT NULL) THEN 
				select coTaxTerritoryID into _LastcoTaxTerritoryID from cuInvoice where cuInvoiceID = _cuInvoiceID;
				if (_LastcoTaxTerritoryID <> _coTaxTerritoryID) THEN
					IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
					SET @l_sql = CONCAT(@l_sql,' coTaxTerritoryID =', _coTaxTerritoryID); 
					SET commaNeeded =1;
                    -- SET _LastcoTaxTerritoryID = 1;
                END IF;
                
			END IF;
			IF (_cuTermsID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' cuTermsID =', _cuTermsID); 
				SET commaNeeded =1;
			END IF;
			if (_dueDate is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'  dueDate =\'', Date(_dueDate),'\''); 
				set commaNeeded =1;
			END IF;
			IF (_ShipDate IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,'  ShipDate =\'', DATE(_ShipDate),'\''); 
				SET commaNeeded =1;
			END IF;
            /*
			IF (_prWarehouseID IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,' prFromWarehouseID =', _prWarehouseID); 
				SET commaNeeded =1;
			END IF;
            */
			if (_CustomerPONumber is not null) THEN 
				IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,','); END IF; 
				set @l_sql = CONCAT(@l_sql,'CustomerPONumber =\'', _CustomerPONumber,'\''); 
				set commaNeeded =1;
			END IF;
			IF (_TrackingNumber IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,'TrackingNumber =\'', _TrackingNumber,'\''); 
				SET commaNeeded =1;
			END IF;
			IF (_Tag IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,'jobnodescription =\'', REPLACE(_Tag,'\'','\\\''),'\''); 
				SET commaNeeded =1;
			END IF;
			IF (_invoiceDate IS NOT NULL) THEN 
				IF (commaNeeded>0) THEN SET @l_sql = CONCAT(@l_sql,','); END IF; 
				SET @l_sql = CONCAT(@l_sql,'  InvoiceDate =\'', DATE(_invoiceDate),'\''); 
				SET commaNeeded =1;
			END IF;
		
			IF (commaNeeded>0) THEN
			
				SET @l_sql = CONCAT(@l_sql,',ChangedOn =\'', NOW(),'\''); 
				SET @l_sql = CONCAT(@l_sql,',ChangedByID =', _changedByID);
				SET @l_sql = CONCAT(@l_sql,' where cuInvoiceID=', _cuInvoiceID); 
				-- select @l_sql;
					
				PREPARE stmt FROM @l_sql;
				EXECUTE stmt;
				DEALLOCATE PREPARE stmt;
			
				
			END IF;
			-- select _cuInvoiceID;
            set _transType = 'CI-Edited';
            select _cuInvoiceID,_transType,_lastSubTotal,_LastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastInvoiceDate;
           /* IF (_LastcoTaxTerritoryID<>_coTaxTerritoryID or _Freight <> _LastFreight) THEN
				-- call INVOICE_recalculate(null,_cuInvoiceID,1,_changedByID); force gl
				call INVOICE_recalculate(null,_cuInvoiceID,0,_changedByID,null);
                -- select _transType;
				-- call INVOICE_tpCuInvoiceLogMaster('CI-Edited',_cuInvoiceID,1);
			else 
				 select _transType;
				-- call INVOICE_tpCuInvoiceLogMaster('CI-Edited',_cuInvoiceID,0);
			END IF; */
            
		
		END IF;
elseif(_action = "INSIDE_JOB") then
	select jor.joReleaseDetailID into _inside_joReleaseDetailID from joReleaseDetail jor left join joRelease jo on jo.joReleaseID = jor.joReleaseID
	left join cuSO cs on cs.joReleaseID = jo.joReleaseID where cs.cuSOID  = _cuSOID ;
		
	select TransactionStatus from cuInvoice where joReleaseDetailID = _inside_joReleaseDetailID;
END IF;
END$$

DELIMITER ;




/*  This procedure is no longer valied - it has been replaced in tp_auditinventory
-- ============================================================
-- call INVOICE_updateInvoiceDetail('UPDATE',_cuInvoiceID,_cuInvoiceDetailID,_cuSODetailID,_vePODetailID,_prMasterID,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,_Note,_changedByID);


-- call INVOICE_updateInvoiceDetail('UPDATE',290560,null,367205,null,null,5,10,1,1,null,1); -- create from cuSODetail
-- call INVOICE_updateInvoiceDetail('UPDATE',291960,null,null,646790,null,5,10,1,1,null,1); -- create from vePODetail
-- call INVOICE_updateInvoiceDetail('UPDATE',290560,1151527,null,null,null,2,5,null,1,null,1); -- update existing item.
-- call INVOICE_updateInvoiceDetail('UPDATE',290560,null,null,null,31,5,10,1,1,'This is a note',1); -- non inventory


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
DECLARE _count INT DEFAULT 0;
DECLARE _HasSingleItemTaxAmount INT DEFAULT 1;
DECLARE _whseCost decimal(19,4);
DECLARE _onOrder decimal(19,4);
DECLARE _LastQuantityBilled decimal(19,4);
DECLARE _position INT DEFAULT 1;

DECLARE _prWarehouseID INT;
-- DECLARE _Description varchar(255);
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
-- select _action,_cuInvoiceID,_cuInvoiceDetailID,_cuSODetailID,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable;
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
    
		if (  _cuInvoiceDetailID is null ) THEN 
        
					if (_cuSODetailID is not null) THEN
						
                        
                        set _count=0;
			-- -select (QuantityOrdered-QuantityBilled) into _count from cuSODetail where cuSODetailID = _cuSODetailID;
			SELECT IF(pm.ItemCode='QP',1,(QuantityOrdered-QuantityBilled)),IF(pm.ItemCode='QP',1,0) INTO _count,_isQPItemCode  FROM cuSODetail sod LEFT JOIN prMaster pm ON(sod.prMasterID=pm.prMasterID) WHERE cuSODetailID = _cuSODetailID;
			if (_count =0) THEN 
                            leave INVOICE_updateInvoiceDetail; 
                        END IF;
						
                        -- if item is already on invoice.
						set _count=0;
                        select cuInvoiceDetailID into _count from cuInvoiceDetail where cuSODetailID=_cuSODetailID and cuInvoiceID = _cuInvoiceID;
                        if (_count >0) THEN leave INVOICE_updateInvoiceDetail; END IF;
                        
						select
						so.cuSOID, p.prMasterID, so.prFromWarehouseID,
                       -- detail.Description,
                        p.IsInventory,detail.HasSingleItemTaxAmount,detail.whseCost,0
                        into
						_cuSOID, _prMasterID, _prWarehouseID,
                       --  _Description,
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
						-- REQUIRED FROM INPUT: _Note,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable	

						-- select _cuSOID, _cuSODetailID, _prMasterID, _Description,_Note,_QuantityBilled,_onOrder,_UnitCost,_PriceMultiplier,_Taxable,_HasSingleItemTaxAmount,_IsInventory,_whseCost,_position;           
				
						-- insert into cuInvoiceDetail
						select count(*) into _position from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
						-- if (_QuantityBilled>=0) THEN
                        
							insert into cuInvoiceDetail 
							(cuInvoiceID,cuSODetailID,prMasterID,Description,Note,QuantityBilled,UnitCost,PriceMultiplier,Taxable,HasSingleItemTaxAmount,whseCost,position,onOrder) 
							values 
							(_cuInvoiceID,_cuSODetailID,_prMasterID,_Description,_Note,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,_HasSingleItemTaxAmount,_whseCost,_position,_onOrder);
				 
							SELECT LAST_INSERT_ID() INTO _cuInvoiceDetailID;
						   -- update cuSODetail.QuantityBilled.
                           if(_isQPItemCode=1) then 
								if(_QuantityBilled >= 0) then
									set _isQPItemCodeQty = 1;
								else
									set _isQPItemCodeQty = -1;
								end if;
							end if;
						 	update cuSODetail set QuantityBilled=IF(_isQPItemCode=1,_isQPItemCodeQty,QuantityBilled+_QuantityBilled) where cuSODetailID=_cuSODetailID;
						-- END IF;
						-- select _cuInvoiceDetailID;
						
						if (_IsInventory=1 and _QuantityBilled<>0) THEN
						
							set _TotalLeftTobeBilled = _QuantityBilled;
                        
							-- insert into cuSODetailBIN
							set _ids = null;
							set _ID = null;
							select GROUP_CONCAT(cuSODetailBinID) into _ids from cuSODetailBin where cuSODetailID=_cuSODetailID;
							do_this:
							LOOP
								 SET strLen = CHAR_LENGTH(_ids);										
								 set _ID=SUBSTRING_INDEX(_ids, ',', 1);
								
								set _AvailableToBillInThisBin = 0;
								set _onOrder = 0;
								
								select
								sodb.binId,
								(CASE WHEN (sodb.allocated-sodb.QuantityBilled) <= b.InventoryOnHand THEN  (sodb.allocated-sodb.QuantityBilled) ELSE  b.InventoryOnHand END) as availableToInvoice,
								(CASE WHEN (sodb.allocated-sodb.QuantityBilled) - b.InventoryOnHand < 0 THEN 0 ELSE (sodb.allocated-sodb.QuantityBilled) - b.InventoryOnHand END) as backOrdered
								into
								_binId,_AvailableToBillInThisBin,_onOrder
								from cuSODetailBin sodb
								left join bin b on (b.binId = sodb.binId)
								where sodb.cuSODetailBinID = _ID;                           
								
                                -- need to figure out when _QuantityBilled is all used, then stop iterating.
                                
                                if (_AvailableToBillInThisBin<_TotalLeftTobeBilled and _TotalLeftTobeBilled<>0) THEN
									set _AmountTobeBilledThisTime = _AvailableToBillInThisBin;
                                    set _TotalLeftTobeBilled = _TotalLeftTobeBilled -_AvailableToBillInThisBin;
                                ELSE
                                    set _AmountTobeBilledThisTime = _TotalLeftTobeBilled;
                                    set _TotalLeftTobeBilled = 0;
                                END IF;
                                
                                if (_AmountTobeBilledThisTime<>0) THEN
                                
									insert into cuInvoiceDetailBin (cuInvoiceDetailID,cuSODetailBinID,binId,QuantityBilled,txState,lastUpdated)
									values (_cuInvoiceDetailID,_ID,_binId,_AmountTobeBilledThisTime,'I',now());
										
									update cuSODetailBin set QuantityBilled = QuantityBilled + _AmountTobeBilledThisTime where  cuSODetailBinID=_ID;   
										
									-- select _ID as _cuSODetailBinID,_QuantityBilled,_onOrder;
									call INV_updateOH('ADJUST',_binId,(-1*_AmountTobeBilledThisTime),(-1*_AmountTobeBilledThisTime),null,_changedByID);
									
									call INV_updateInventoryLog('INSERT',_binId,'CI',_cuInvoiceID,_cuInvoiceDetailID,_referenceNo,_AmountTobeBilledThisTime,0,'Customer Invoice',_changedByID,null,_refRelatedNo);
									-- call FIX_tool("BIN_ALLOCATION",null,null,null,_binId);
                                END IF;
                             
								 SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
								 SET _ids = MID(_ids, SubStrLen, strLen);
								 IF _ids = '' or _ids is null THEN
								   LEAVE do_this;
								 END IF;
								 
							END LOOP do_this;
						END IF; -- IsInventory
					-- create a invoice detail from a PO "Drop Ship" - no inventory adjusted
					elseif (_vePODetailID is not null) THEN
						
						-- select (QuantityOrdered-QuantityBilled) into _count from vePODetail where vePODetailID = _vePODetailID;
						-- if (_count <=0) THEN leave INVOICE_updateInvoiceDetail; END IF;
						
                        -- if item is already on invoice.
						-- select cuInvoiceDetailID into _count from cuInvoiceDetail d where d.cuSODetailID=_vePODetailID and d.cuInvoiceID = _cuInvoiceID;
                       --  if (_count >0) THEN leave INVOICE_updateInvoiceDetail; END IF;
						
						select
						so.vePOID, p.prMasterID, so.prWarehouseID,
                        -- detail.Description, 
                        p.IsInventory,0 as HasSingleItemTaxAmount,p.POCost as whseCost,0
                        into
						_cuSOID, _prMasterID, _prWarehouseID, 
                       -- _Description,
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
						

						-- select _cuSOID, _cuSODetailID, _prMasterID, _Description,_Note,_QuantityBilled,_onOrder,_UnitCost,_PriceMultiplier,_Taxable,_HasSingleItemTaxAmount,_IsInventory,_whseCost,_position;           
				
						select count(*) into _position from cuInvoiceDetail where cuInvoiceID=_cuInvoiceID;
						
						-- if (_quantityBilled>=0) THEN
							
							insert into cuInvoiceDetail 
							(cuInvoiceID,cuSODetailID,prMasterID,Description,Note,QuantityBilled,UnitCost,PriceMultiplier,Taxable,HasSingleItemTaxAmount,whseCost,position,onOrder) 
							values 
							(_cuInvoiceID,_vePODetailID,_prMasterID,_Description,_Note,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,_HasSingleItemTaxAmount,_whseCost,_position,_onOrder);
				 
							SELECT LAST_INSERT_ID() INTO _cuInvoiceDetailID;
                            
						   -- update cuSODetail.QuantityBilled.
							-- update vePODetail set QuantityBilled=QuantityBilled+_QuantityBilled where vePODetailID=_vePODetailID;
						-- END IF;
					-- A new product is being added that is not related to a cuSO or cuPO
					ELSEIF (_cuSODetailID is null and  _vePODetailID is null and _prMasterID is not null) THEN
					
							-- check to make sure it is non-inventory
						select 
						-- p.Description,
                        p.IsInventory 
                        into 
                        -- _Description,
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
                    
		ELSE -- cuInvoiceDetailID is NOT NULL, update needed.                
	
				-- need to get the difference.
				select d.QuantityBilled,d.prMasterID, i.prFromWarehouseID, s.cuSOID, d.cuSODetailID, p.IsInventory, s.QuantityOrdered 
				into _LastQuantityBilled,_prMasterID, _prWarehouseID, _cuSOID, _cuSODetailID ,  _IsInventory, _soDetailOrdered
				from cuInvoiceDetail d 
				left join cuInvoice i on (i.cuInvoiceID = d.cuInvoiceID)
                left join cuSODetail s on (s.cuSODetailID = d.cuSODetailID)
				left join prMaster p on (p.prMasterID = d.prMasterID)
				where cuInvoiceDetailID = _cuInvoiceDetailID;
				
				if (_IsInventory =1 and _LastQuantityBilled <> _QuantityBilled) THEN
 
					-- RULE, user can not change beyond what was ordered from cuSO
					if (_soDetailOrdered is not null and _QuantityBilled > _soDetailOrdered) THEN
 							leave INVOICE_updateInvoiceDetail;                    
                    END IF;
                    
                    
					-- set _quantityChanged = _QuantityBilled-_LastQuantityBilled;
					set _quantityChanged = _LastQuantityBilled-_QuantityBilled;
                    
					IF( _QuantityBilled < _LastQuantityBilled) THEN 
						-- get the primary binId  to PUT BACK
						select binId into _binId from bin where prMasterID=_prMasterID and prWarehouseID =  _prWarehouseID order by binSequence limit 1;
						call INV_updateOH('ADJUST',_binId,_quantityChanged,null,null,_changedByID);
					ELSE 
						-- FIND A BIN THAT HAS MORE PRODUCT.
						select binId into _binId from bin where prMasterID=_prMasterID and prWarehouseID =  _prWarehouseID  
                        and InventoryOnHand > (-1*_quantityChanged)  order by binSequence limit 1;
                        
						call INV_updateOH('ADJUST',_binId,_quantityChanged,null,null,_changedByID);
                    END IF;
                    
                    -- This is problematic if there are multiple bins with product.
					select cuInvoiceDetailBinID,cuSODetailBinID into _cuInvoiceDetailBinID,_cuSODetailBinID  from cuInvoiceDetailBin where cuInvoiceDetailID = _cuInvoiceDetailID limit 1;
					
                    if (_cuSODetailID is not null) Then			
						update cuSODetailBin set QuantityBilled = (QuantityBilled - _quantityChanged), lastUpdated=now() where cuSODetailBinID = _cuSODetailBinID;
					END IF;
					
					update cuInvoiceDetailBin set QuantityBilled = (QuantityBilled - _quantityChanged), lastUpdated=now() where cuInvoiceDetailBinID = _cuInvoiceDetailBinID;
					-- call FIX_tool("BIN_ALLOCATION",null,null,null,_binId);
                    call INV_updateInventoryLog('INSERT',_binId,'CI',_cuInvoiceID,_cuInvoiceDetailID,_referenceNo,0,_quantityChanged,'Customer Invoice Change',_changedByID,null,_refRelatedNo);
                
                END IF;
				
                -- check values
                update cuInvoiceDetail set QuantityBilled = _QuantityBilled,UnitCost=_UnitCost,Taxable=_Taxable,PriceMultiplier=_PriceMultiplier,Note=_Note,Description=_Description where cuInvoiceDetailID = _cuInvoiceDetailID;
    
    
				-- This is to make sure the cuSODetail is properly added up.
				if (_cuSODetailID is not null) Then			
					select Sum(QuantityBilled) into  _QuantityBilled from cuInvoiceDetail where cuSODetailID = _cuSODetailID;
						-- select 'UPDATE cuSODetail',_QuantityBilled, _cuSODetailID;
					update cuSODetail set QuantityBilled = _QuantityBilled where cuSODetailID = _cuSODetailID; 
				END IF;
    
        
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
    
		-- is inventory not allowed to be deleted.
		LEAVE INVOICE_updateInvoiceDetail;
        
        
		delete from cuInvoiceDetailBin where cuInvoiceDetailBinID = _cuInvoiceDetailBinID;
		-- just stick all the inventory back into the bin.
		select binId into _binId from bin where prMasterID=_prMasterID and prWarehouseID =  _prWarehouseID order by binSequence limit 1;
            
        -- add inventory
		call INV_updateOH('ADJUST',_binId,(_LastQuantityBilled),null,null,_changedByID);
								
		call INV_updateInventoryLog('INSERT',_binId,'CI',_cuInvoiceID,_cuInvoiceDetailID,_referenceNo,_LastQuantityBilled,0,'Customer Invoice Delete',_changedByID,null,_refRelatedNo);
		-- call FIX_tool("BIN_ALLOCATION",null,null,null,_binId);
    
    END IF; -- end if isInventory
	delete from cuInvoiceDetail where cuInvoiceDetailID = _cuInvoiceDetailID;
	
     IF (_vePODetailID is not null) THEN
 
            select Sum(QuantityBilled) into  _QuantityBilled from cuInvoiceDetail where cuSODetailID = _vePODetailID;
			-- select 'UPDATE cuSODetail',_QuantityBilled, _cuSODetailID;
			update vePODetail set QuantityBilled =  _QuantityBilled where vePODetailID = _vePODetailID;
     ELSEIF (_cuSODetailID is not null) THEN
             select Sum(QuantityBilled) into  _QuantityBilled from cuInvoiceDetail where cuSODetailID = _cuSODetailID;
			-- select 'UPDATE cuSODetail',_QuantityBilled, _cuSODetailID;
			update cuSODetail set QuantityBilled = _QuantityBilled where cuSODetailID = _cuSODetailID;
 
	END IF;
	select Subtotal,Freight,TaxAmount,coTaxTerritoryID,InvoiceDate 
    into _lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastinvoiceDate  from cuInvoice where cuInvoiceID = _cuInvoiceID;
	call INVOICE_recalculate('CUSTOMERINVOICE',_cuInvoiceID,0,_changedByID,'CI-Line Item(s) Deleted',_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastinvoiceDate);
    -- call INVOICE_tpCuInvoiceLogMaster('CI-Line Item(s) Deleted',_cuInvoiceID,0);
END IF; -- ELSE action DELETE
select _cuInvoiceDetailID;
END$$

DELIMITER ;
-- =============END updateInvoiceDetail ===========================
*/




/* procedure is no longer valid - new procedure moved to TP_AVG_COST
-- ============================================================
-- call INVOICE_recalculate('CUSTOMERINVOICE',290560,0,1);


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
DECLARE _newAverageCost decimal(19,4);
DECLARE _tpInventoryLogID INT;
DECLARE _newOnHand decimal(19,4);
DECLARE _oldonHand decimal(19,4);
DECLARE _oldaverageCost decimal(19,4);
DECLARE _oldTotalValue decimal(19,4);
DECLARE _newTotalValue decimal(19,4);
    SET SESSION group_concat_max_len = 1000000; 
	if (_action='CUSTOMERINVOICE') THEN
	
        select CostTotal,TaxableSales,NonTaxableSales,InvoiceAmount,TaxRate,InvoiceDate,Subtotal,TaxAmount
        into 
        _lastCostTotal,_lastTaxableSales,_lastNonTaxableSales,_lastInvoiceAmount,_lastTaxRate,_InvoiceDate,_lastSubTotal,_lastTaxAmount
        from cuInvoice where cuInvoiceID=_cuInvoiceID;
        
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
		END IF ; 
		
		if (_ignoreGL=0) THEN 
			
			call GL_updateGLTransaction('INSERT',null,'CI',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,_isInvoiceDatechanged,_LastinvoiceDate); 
		
		END IF;
        
	ELSEif (_action='VENDORINVOICE_OLD') THEN
 
 		-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INVOICE_recalculate:VENDORINVOICE not yet supported - need to update veBill';
		-- LEAVE INVOICE_recalculate; 
		select GROUP_CONCAT(veBillDetailID) into _ids from  veBillDetail  where veBillID = _cuInvoiceID;
        set _totalcost = 0;
		set _Subtotal =0;
        do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);
                select ROUND_TO_EVEN(IFNULL(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier),0),2) into _totalcost from veBillDetail where veBillDetailID = _id;
				set _Subtotal = _Subtotal+_totalcost;
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
         --   select _Subtotal;
		-- if (_ignoreGL=0) THEN call VENDOR_GL(_cuInvoiceID,_changedByID); END IF;
        select FreightAmount,joReleaseDetailID into _Freight,_joReleaseDetailID  from veBill where veBillID =  _cuInvoiceID;
        -- select IFNULL(Sum(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier)),0) into _TaxableSales  from veBillDetail where veBillID =_cuInvoiceID and Taxable=1;  
		-- select IFNULL(Sum(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier)),0) into _NonTaxableSales  from veBillDetail where veBillID =_cuInvoiceID and Taxable=0;
	-- 	set _Subtotal = ROUND_TO_EVEN((ifnull(_TaxableSales,0)+ ifnull(_NonTaxableSales,0)),2); 
        set _InvoiceAmount = _Subtotal + _Freight;
     --   select _InvoiceAmount;
        update veBill 
        set 
        BillAmount = _InvoiceAmount  
        where veBillID =  _cuInvoiceID;
      --   select BillAmount into _InvoiceAmount  from veBill where veBillID =  _cuInvoiceID;
        
        if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VB',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;
		
         if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 
			
            select sum(QuantityBilled),GROUP_CONCAT(vb.veBillDetailID),ve.PONumber into _count,_ids,_PONumber  from veBillDetail vb
            left join prMaster pr on  pr.prMasterID = vb.prMasterID
            left join veBill vl on vb.veBillID = vl.veBillID
            left join vePO ve on ve.vePOID = vl.vePOID
            where vb.veBillID = _cuInvoiceID and pr.IsInventory = 1 ;
            
            
            set _freightDistributionAll = _Freight/_count;
			
            do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);
                select ROUND_TO_EVEN(IFNULL(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier),0),2),
                prMasterID, QuantityBilled
                into _totalcost,_prMasterID,_QuantityBilled from veBillDetail where veBillDetailID = _id;
                
                -- call update_prMasterAvgCost("latestAvgCostCal", _cuInvoiceID, _prMasterID, 0);
                
				set   _freightDistribution = _freightDistributionAll*_QuantityBilled;
                set _newAverageCost = (_totalcost+_freightDistribution)/_QuantityBilled;
                Select MAX(tpInventoryLogID) into _tpInventoryLogID from tpInventoryLogMaster where prMasterID=_prMasterID AND refRelatedNo=_PONumber AND transType ='RI';
                select onHand into _newOnHand from tpInventoryLogMaster where tpInventoryLogID = _tpInventoryLogID;
                set _oldonHand = _newOnHand - _QuantityBilled;
                select AverageCost into _oldaverageCost from prMaster where prMasterID = _prMasterID;
                set _oldTotalValue = _oldonHand*_oldaverageCost;
                set _newTotalValue = _QuantityBilled*_newAverageCost;
                set _averageCost = (_oldTotalValue+_newTotalValue)/_newOnHand;
                update prMaster set AverageCost = _averageCost where prMasterID = _prMasterID;
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
            
           -- if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VB',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;
            
            
		end if;
        ELSEif (_action='VENDORINVOICE') THEN
 
 		-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INVOICE_recalculate:VENDORINVOICE not yet supported - need to update veBill';
		-- LEAVE INVOICE_recalculate; 
		select GROUP_CONCAT(veBillDetailID) into _ids from  veBillDetail  where veBillID = _cuInvoiceID;
        select _ids;
        set _totalcost = 0;
		set _Subtotal =0;
        do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);
                select ROUND_TO_EVEN(IFNULL(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier),0),2) into _totalcost from veBillDetail where veBillDetailID = _id;
				set _Subtotal = _Subtotal+_totalcost;
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 

        select FreightAmount,joReleaseDetailID into _Freight,_joReleaseDetailID  from veBill where veBillID =  _cuInvoiceID;

        set _InvoiceAmount = _Subtotal + _Freight;

        update veBill set BillAmount = _InvoiceAmount where veBillID =  _cuInvoiceID;
        
         if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VB',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;
		
         if(_joReleaseDetailID is null or _joReleaseDetailID =0) then 
			
--             select sum(QuantityBilled),GROUP_CONCAT(vb.veBillDetailID),ve.PONumber into _count,_ids,_PONumber  from veBillDetail vb
--             left join prMaster pr on  pr.prMasterID = vb.prMasterID
--             left join veBill vl on vb.veBillID = vl.veBillID
--             left join vePO ve on ve.vePOID = vl.vePOID
--             where vb.veBillID = _cuInvoiceID and pr.IsInventory = 1 ;
--             
--             
--             set _freightDistributionAll = _Freight/_count;
			select GROUP_CONCAT(veBillDetailID) into _ids from  veBillDetail  where veBillID = _cuInvoiceID;
            do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);
                select ROUND_TO_EVEN(IFNULL(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier),0),2),
                prMasterID, QuantityBilled
                into _totalcost,_prMasterID,_QuantityBilled from veBillDetail where veBillDetailID = _id;
                
                select _totalcost,_prMasterID,_QuantityBilled,_id;
                
                -- call update_prMasterAvgCost("latestAvgCostCal", _cuInvoiceID, _prMasterID, 0);
			SELECT  d.* FROM veBillDetail d LEFT JOIN veBill v ON (v.veBillID = d.veBillID) WHERE
			prMasterID = _prMasterID AND v.BillDate > (SELECT date_format(MAKEDATE(year(now()),1),"%y-%m-%d 00:00:00")) ORDER BY veBillDetailID ASC; -- '2022-01-00 00:00:00'

			SELECT  v.BillDate, d.QuantityBilled, d.PriceMultiplier,  d.UnitCost, IFNULL(d.FreightCost, 0),
			((d.PriceMultiplier * d.UnitCost) + IFNULL(d.FreightCost, 0)) AS avgCost, d.* FROM
			veBillDetail d LEFT JOIN veBill v ON (v.veBillID = d.veBillID) WHERE prMasterID = _prMasterID -- 264
			AND v.BillDate > (SELECT date_format(MAKEDATE(year(now()),1),"%y-%m-%d 00:00:00")) ORDER BY veBillDetailID ASC;
            
            
			SELECT d.UnitCost,((d.PriceMultiplier * d.UnitCost) + IFNULL(d.FreightCost, 0)) into @_oldAvgcost,@_newAvgCost FROM
			veBillDetail d LEFT JOIN veBill v ON (v.veBillID = d.veBillID) WHERE prMasterID = _prMasterID -- 264
			AND v.BillDate > (SELECT date_format(MAKEDATE(year(now()),1),"%y-%m-%d 00:00:00")) ORDER BY veBillDetailID ASC limit 1;
            
		 
			SELECT d.prMasterID,
			SUM(((d.PriceMultiplier * d.UnitCost) + IFNULL(d.FreightCost, 0))) ,
            COUNT(*),
			-- SUM(((d.PriceMultiplier * d.UnitCost) + IFNULL(d.FreightCost, 0))) / COUNT(*)
             ifnull(@_oldAvgcost,0) + ifnull(@_newAvgCost,0)/ COUNT(*)
			-- d.*
            into @_prmasterid, @_totalSum, @_count, @_avgCost -- , @_totalVebillDetail 
            FROM veBillDetail d LEFT JOIN veBill v ON (v.veBillID = d.veBillID) WHERE
			prMasterID = _prMasterID AND v.BillDate > (SELECT date_format(MAKEDATE(year(now()),1),"%y-%m-%d 00:00:00")) GROUP BY prMasterID;

			select @_avgCost;
			update prMaster set averageCost = @_avgCost where prMasterID = _prMasterID;
            -- select averageCost from prMaster where prMasterID = _prMasterID;
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
           -- if (_ignoreGL=0) THEN call GL_updateGLTransaction('INSERT',null,'VB',_InvoiceAmount,null,null,null,null,null,_cuInvoiceID,_changedByID,null,null);  END IF;
            
            
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
*/


DROP procedure IF EXISTS `TP_jobRelease_customer`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `TP_jobRelease_customer`(
IN _action varchar(50),
IN _joMasterID INT
)
TP_jobRelease_customer:BEGIN
DECLARE _rxMasterID INT;
DECLARE _rxAddressID INT;
				
                
                if ( _joMasterID is null) THEN 
					SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call TP_jobRelease_customer:_joMasterID missing';
					LEAVE TP_jobRelease_customer; 
				END IF;
                select rxCustomerID into _rxMasterID from joMaster where joMasterID = _joMasterID;
                
                select rxAddressID into _rxAddressID from rxAddress where rxMasterID =  _rxMasterID AND IsMailing = 1;
                
                if (_rxAddressID is null) then
					select rxAddressID into _rxAddressID from rxAddress where rxMasterID = _rxMasterID AND IsDefault = 1;
                end if;
                
                update cuSO SET rxCustomerID =_rxMasterID, rxBillToID = _rxMasterID,
				rxShipToID = CASE WHEN ShipToMode = 0 OR ShipToMode = 1  THEN  _rxAddressID 
								  WHEN  ShipToMode = 2 or ShipToMode = 3  THEN  _joMasterID END
				where joReleaseID IN (select joReleaseID from joRelease where joMasterID =_joMasterID);
                
                update vePO SET rxBillToID =_rxMasterID,
					rxShipToID = CASE WHEN ShipToMode = 0 OR ShipToMode = 3  THEN null  
									  WHEN  ShipToMode = 1  THEN  _rxAddressID  
                                      WHEN ShipToMode = 2 THEN _joMasterID END
					  where joReleaseID IN (select joReleaseID from joRelease where joMasterID =_joMasterID);
                
END$$

DELIMITER ;



-- ==============================================

DROP procedure IF EXISTS `CO_updateCustomerFinancial`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `CO_updateCustomerFinancial`(
IN _action varchar(25),
IN _cuMasterID INT,
IN _invoiceYesNoMethod INT,
IN _statementYesNoMethod INT,
IN _invoiceYesDate DATE,
IN _statementYesDate DATE,
IN  _changedbyID INT
)
CO_updateCustomerFinancial:BEGIN
		if(_changedbyID is null and _cuMasterID is null) THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call CO_updateCustomerFinancial:missing changedbyID and _cuMasterID';
			LEAVE CO_updateCustomerFinancial;
		END IF;
        
        if(_invoiceYesNoMethod = 1) THEN 
			if(_invoiceYesDate is null) THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call CO_updateCustomerFinancial:missing invoiceYesDate';
				LEAVE CO_updateCustomerFinancial;
			end if;
		end if;
        
        if(_statementYesNoMethod = 1) THEN 
			if(_statementYesDate is null) THEN
				SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call CO_updateCustomerFinancial:missing statementYesDate';
				LEAVE CO_updateCustomerFinancial;
			end if;
		end if;
					
        
        update cuMaster set invoiceYesNOmethod = _invoiceYesNoMethod,statementYesNOmethod = _statementYesNoMethod,invoiceYesDate = Date(_invoiceYesDate),
							statementYesDate = Date(_statementYesDate) where cuMasterID = _cuMasterID;
        
        
END$$

DELIMITER ;

-- ==============================================


DROP procedure IF EXISTS `CO_getCustomerFinancial`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `CO_getCustomerFinancial`(
IN _action VARCHAR(100),
IN _cuMasterID INT,
in _customerName varchar(255),
IN _date date
)
CO_getCustomerFinancial:BEGIN
		
        DECLARE _rxMasterID INT;
        
        if(_cuMasterID is null) THEN
			SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call CO_getCustomerFinancial:missing _cuMasterID';
			LEAVE CO_getCustomerFinancial;
		END IF;
        if(_action = "getCustomerFinancial")then
        select * from cuMaster where cuMasterID = _cuMasterID;
        end if;
        
        if(_action = "getSingleCustomerFinancial")then
        
        select rxMasterID into _rxMasterID from rxMaster where Name = _customerName;
        
        SELECT InvoiceDate,InvoiceNumber,CustomerPONumber,totalamount,Days,CASE WHEN Days>=0 AND Days<=30 THEN InvoiceAmount ELSE 0 END AS AmtCur,  CASE WHEN Days>30 
		AND Days<=60 THEN InvoiceAmount ELSE 0 END AS Amt30, CASE WHEN Days>60 AND Days<=90 THEN InvoiceAmount ELSE 0 END AS Amt60, CASE WHEN Days>90 
		THEN InvoiceAmount ELSE 0 END AS Amt90,cuInvoiceID  FROM ( SELECT cuInvoice.cuInvoiceID,InvoiceDate, InvoiceNumber,CustomerPONumber,ar.InvoiceAmount 
		AS totalamount,DATEDIFF(_date,InvoiceDate) AS Days, ar.InvoiceAmount-(ar.AppliedAmount+IFNULL(ar.DiscountAmt,0)) AS 
		Balance,ar.InvoiceAmount-(ar.AppliedAmount+IFNULL(ar.DiscountAmt,0)) AS InvoiceAmount From
		(SELECT MAX(arhistoryID) AS arhistoryID,cuInvoiceID FROM arhistory WHERE DATE(createdOn)<=_date AND `inv_rec`=0 GROUP BY cuInvoiceID) sub  
		JOIN `arhistory` ar ON(sub.arhistoryID=ar.arhistoryID) JOIN cuInvoice ON(ar.cuInvoiceID=cuInvoice.cuInvoiceID)  
		LEFT JOIN cuMaster  ON cuMaster.cuMasterID = IFNULL(cuInvoice.rxBillToID,cuInvoice.rxCustomerID) 
		WHERE IF(CreditMemo = 0,CreditMemo=0,memoStatus=1) AND (TransactionStatus>0) AND 
		`inv_rec`=0 AND (ABS(ar.InvoiceAmount - (ar.AppliedAmount + IFNULL(ar.DiscountAmt, 0))) >= .01)AND IFNULL(cuInvoice.rxBillToID,cuInvoice.rxCustomerID)=_rxMasterID
		AND DATE(ar.createdOn)<=_date GROUP BY cuInvoiceID  Union All  SELECT 0 AS cuInvoiceID, ReceiptDate  AS InvoiceDate,'Unapplied' AS InvoiceNumber,
		(CASE cuReceiptTypeID WHEN 1 THEN CONCAT('CH-',IFNULL(Reference,'')) WHEN 2 THEN CONCAT('CK-',IFNULL(Reference,''))
		WHEN 3 THEN CONCAT('CC-',IFNULL(Reference,'')) WHEN 4 THEN CONCAT('OR-',IFNULL(Reference,'')) END) AS CustomerPONumber, 
		(SUM(IFNULL(Appliedamount,0))-receiptamount) AS totalamount ,  DATEDIFF(_date,ReceiptDate) AS Days, (SUM(IFNULL(Appliedamount,0))-receiptamount) AS Balance, 
		(SUM(IFNULL(AppAmount,0))-receiptamount) AS InvoiceAmount FROM (  SELECT sub.AppAmount,ar.arhistoryID,Reference,cuReceiptTypeID,cuReceipt.rxCustomerID,
		cuReceipt.cuReceiptID,IF(revornot=1,0,Amount) AS receiptamount,DiscountAmt,Appliedamount,revornot,`createdOn`,`ReceiptDate` FROM   (SELECT MAX(arhistoryID)
		AS arhistoryID,cuInvoiceID,SUM(AppliedAmount) AS AppAmount FROM arhistory  WHERE  DATE(createdOn)<=_date AND `inv_rec`=1  GROUP BY cuReceiptID,cuInvoiceID) sub 
		JOIN `arhistory` ar ON(sub.arhistoryID=ar.arhistoryID)  LEFT JOIN cuReceipt ON(ar.cuReceiptID=cuReceipt.cuReceiptID)  WHERE `inv_rec`=1 )AS
		sub LEFT JOIN rxMaster ON(sub.rxCustomerID=rxMaster.rxMasterID) WHERE rxCustomerID=_rxMasterID GROUP BY cuReceiptID  Union All   SELECT 0 AS
		cuInvoiceID,ar.createdOn AS InvoiceDate,'Unapplied' AS InvoiceNumber, (CASE cuReceiptTypeID WHEN 1 THEN CONCAT('CH-',IFNULL(Reference,'')) WHEN 2
		THEN CONCAT('CK-',IFNULL(Reference,'')) WHEN 3 THEN CONCAT('CC-',IFNULL(Reference,'')) WHEN 4 THEN CONCAT('OR-',IFNULL(Reference,'')) END) AS
		CustomerPONumber,ar.Appliedamount AS totalamount,DATEDIFF(_date ,ar.`createdOn`) AS Days,(ar.Appliedamount*-1) AS Balance,(ar.Appliedamount*-1) AS
		InvoiceAmount  FROM  (   SELECT MAX(arhistoryID) AS arhistoryID,inv_rec FROM arhistory WHERE (inv_rec=1 OR inv_rec=2) AND  DATE(createdOn)<=_date 
		GROUP BY cuReceiptID  ) sub JOIN `arhistory` ar ON(sub.arhistoryID=ar.arhistoryID)  LEFT JOIN cuReceipt ON(ar.cuReceiptID=cuReceipt.cuReceiptID) 
		LEFT JOIN rxMaster ON(cuReceipt.rxCustomerID=rxMaster.rxMasterID)   LEFT JOIN cuMaster ON cuMaster.cuMasterID = rxMaster.rxMasterID 
		WHERE ar.inv_rec=2 AND rxCustomerID=_rxMasterID AND DATE(ar.createdOn)<=_date ) AS SubQuery WHERE Days>=0 and ABS(Balance) >= .01 AND ABS(InvoiceAmount)>= .01;
        
        SELECT SUM(IFNULL(TO_DAYS(DATE(l.datePaid)),0) -IFNULL(TO_DAYS(DATE(c.InvoiceDate)),0))/count((IFNULL(l.refInvoiceID,0))) as avgdays FROM cuReceipt r
		LEFT JOIN cuLinkageDetail l ON ((r.cuReceiptID = l.cuReceiptID))
		LEFT JOIN cuInvoice c ON ((l.cuInvoiceID = c.cuInvoiceID))
		LEFT JOIN coDivision d ON ((d.coDivisionID = c.coDivisionID))
		LEFT JOIN rxMaster rx ON ((rx.rxMasterID = r.rxCustomerID)) WHERE l.refInvoiceID <> 0 AND  r.rxCustomerID= _rxMasterID;
        end if;

END$$

DELIMITER ;

-- ==============================================

-- call getBinBackOrder(null,null);
-- call getBinBackOrder(null,142579);
-- call getBinBackOrder(null,142579,null,null,null,null);

-- need to return cuSODetailID and cuSOID
DROP procedure IF EXISTS `getBinBackOrder`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `getBinBackOrder`( 
	IN _action  varchar(25),
	IN _vePOID INT,
	IN _warehouseID INT,
	IN _coDivisionID INT,
	IN _fromDate datetime,
	IN _toDate datetime)
BEGIN
DECLARE commaNeeded INT DEFAULT 0;
IF (_vePOID>0) THEN

	select 
	bo.*
	-- ,p.vePOID, p.prWarehouseID, d.prMasterID 
	from vePO p
	left join vePODetail d on (d.vePOID = p.vePOID)
	left join prMaster prod on (prod.prMasterID = d.prMasterID)
	left join (
	select w.EMAIL as toWHEmail, prMasterID, b.prWarehouseID, ItemCode, b.Description, whDescription, sum( InventoryAllocated - InventoryOnHand) as backOrder
	from v_INV_bin b
	left join prWarehouse w on (w.prWarehouseID = b.prWarehouseID)
	where b.InventoryOnHand < b.InventoryAllocated
	group by b.prMasterID, b.prWarehouseID
	) bo on (bo.prMasterID = d.prMasterID and bo.prWarehouseID=p.prWarehouseID)
	where d.QuantityOrdered > d.QuantityReceived and p.prWarehouseID>0 and prod.IsInventory=1 and bo.prMasterID is not null and p.vePOID = _vePOID;

ELSE

/*
	select w.EMAIL as toWHEmail, prMasterID, b.prWarehouseID, ItemCode, b.Description as ItemDescription, whDescription, sum( InventoryAllocated - InventoryOnHand) as backOrder
	from v_INV_bin b
	left join prWarehouse w on (w.prWarehouseID = b.prWarehouseID)
	where InventoryOnHand < InventoryAllocated
	group by prMasterID, prWarehouseID;
*/
	set  @l_sql =  'select w.EMAIL as toWHEmail, s.cuSOID, d.cuSODetailID, s.SONumber, s.createdDate, b.prMasterID, b.prWarehouseID, b.ItemCode, b.Description as ItemDescription, b.whDescription, 
    sum( InventoryAllocated - InventoryOnHand) as backOrder,d.QuantityOrdered,d.QuantityBilled,rx.Name as customeName,s.Tag as jobName,
    (d.QuantityOrdered * d.whseCost) as amount
	from v_INV_bin b
    left join cuSO s on (s.prFromWarehouseID = b.prWarehouseID)
	left join cuSODetail d on (d.cuSOID = s.cuSOID and d.prMasterID = b.prMasterID)
	left join prWarehouse w on (w.prWarehouseID = b.prWarehouseID)
    left join rxMaster rx on (rx.rxMasterID = s.rxCustomerID)
    left join joRelease joR on (joR.joReleaseID = s.joReleaseID)
    left join joMaster joM on (joM.joMasterID = joR.joMasterID)
	where b.InventoryOnHand < b.InventoryAllocated and (s.cuSOID is  null or s.TransactionStatus = 1) and d.QuantityOrdered <> d.QuantityBilled ';
	
    if(_warehouseID is not null) THEN 
		IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,'   '); END IF; 
		set @l_sql = CONCAT(@l_sql,' and b.prWarehouseID =', _warehouseID); 
		set commaNeeded =1;
	END if;
    
    if(_coDivisionID is not null) THEN 
		IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,'   '); END IF; 
		set @l_sql = CONCAT(@l_sql,' and s.coDivisionID =', _coDivisionID); 
		set commaNeeded =1;
	END if;
    
    if(_fromDate is not null and _toDate is not null) THEN 
		IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,'   '); END IF; 
		set @l_sql = CONCAT(@l_sql,' and DATE(s.createdDate) BETWEEN  ','\"', date(_fromDate) ,'\"', '  AND  ','\"', date(_toDate),'\"'); 
		set commaNeeded =1;
	END if;
    if(_fromDate is not null and _toDate is null) THEN 
		IF (commaNeeded>0) THEN set @l_sql = CONCAT(@l_sql,'   '); END IF; 
		set @l_sql = CONCAT(@l_sql,' and Date(s.createdDate) =  ','\"', date(_fromDate),'\"' ); 
		set commaNeeded =1;
	END if;
    
        
        	set @l_sql = CONCAT(@l_sql,'  group by b.prMasterID, b.prWarehouseID, d.cuSODetailID'); 
			set @l_sql = CONCAT(@l_sql,'  order by createdDate,cuSOID asc'); 

			 -- select @l_sql;
        	
			PREPARE stmt FROM @l_sql;
			EXECUTE stmt;
			DEALLOCATE PREPARE stmt;
END IF;

-- call create bins
-- select count() from bins
-- selec count(wh inventories)
-- if bins = inventories SUCCESS


-- SODetailBin -- create data based open sales orders, partials
-- cuInvoiceDetailBin -- check for partial.

END$$

DELIMITER ;



-- =======
DROP procedure IF EXISTS `INV_PR_Allocated`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_PR_Allocated`(
IN _action varchar(25),
IN _prMasterID INT
)
INV_PR_Allocated:BEGIN
	if(_prMasterID is null) THEN
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_PR_Allocated:_prMasterID missing';
         LEAVE INV_PR_Allocated;
	END if;
    if(_action = 'ALLOCATED') THEN 
		select * from (
        SELECT so.cuSOID,sodetail.cuSODetailID,so.CreatedOn,so.DatePromised,rxmaster.Name,
        so.SONumber,(SUM(sodetail.QuantityOrdered) - SUM(sodetail.QuantityBilled)) AS quantityordered,
		warehouse.SearchName,so.rxCustomerID FROM cuSO so LEFT JOIN cuSODetail sodetail ON (so.cuSOID = sodetail.cuSOID) 
		LEFT JOIN rxMaster rxmaster ON(rxmaster.rxMasterID = so.rxCustomerID ) 
		LEFT JOIN prWarehouse warehouse ON(warehouse.prWarehouseID = so.prFromWarehouseID) 
		LEFT JOIN prMaster pr ON(sodetail.prMasterID=pr.prMasterID) WHERE  so.TransactionStatus = 1 AND 
		sodetail.prMasterID= _prMasterID AND sodetail.QuantityBilled IS NOT NULL 
        and warehouse.InActive = 0
        AND pr.IsInventory=1 and pr.InventoryAllocated != 0
        GROUP BY sodetail.cuSOID
		UNION ALL SELECT -1 AS cuSOID,-1 AS cuSODetailID, H.TransferDate AS OrderDate, H.EstreceiveDate AS DatePromised,
		 'Warehouse Transfer Out' AS NAME,H.TransNumber AS SONumber,D.QuantityTransfered AS quantityordered,prWarehouse.SearchName,
		 0 AS rxCustomerID FROM prWarehouse INNER JOIN prWHtransfer H ON 
		prWarehouse.prWarehouseID = H.prFromWareHouseID RIGHT OUTER JOIN prWHtransferDetail D ON H.prTransferID = D.prTransferID 
		LEFT JOIN prMaster pr ON(D.prMasterID=pr.prMasterID)  WHERE (H.ReceivedDate IS NULL) AND (D.ReceivedDate IS NULL)  AND  `prToWareHouseID` IS NOT NULL AND pr.IsInventory=1 and prWarehouse.InActive=0 AND (D.prMasterID = _prMasterID)
        ) allocated where quantityordered  <>0;
        
	END IF;
     if(_action = 'ORDERED') then
		 SELECT vepo.vePOID,CAST(vepo.PONumber  AS CHAR) AS ponumber,vepo.OrderDate,vedetail.EstimatedShipDate,rxmaster.Name,vepo.rxVendorID,
			vepo.prWarehouseID, CASE WHEN vepo.`joReleaseID` IS NULL THEN SUM(IFNULL(vedetail.QuantityOrdered,0)-IFNULL(vedetail.QuantityReceived ,0) ) ELSE 
			0 END AS QuantityOrdered, warehouse.City 
			FROM vePO vepo 
			LEFT JOIN vePODetail vedetail ON vepo.vePOID = vedetail.vePOID 
			LEFT JOIN rxMaster rxmaster ON rxmaster.rxMasterID = vepo.rxVendorID 
			LEFT JOIN prWarehouse warehouse ON warehouse.prWarehouseID = vepo.prWarehouseID 
			LEFT JOIN joRelease ON vepo.joReleaseID=joRelease.joReleaseID 
			LEFT JOIN prMaster pr ON(vedetail.prMasterID=pr.prMasterID) WHERE  vedetail.prMasterID= _prMasterID
			 AND  vedetail.QuantityOrdered IS NOT NULL 
			 -- AND pr.IsInventory=1 
			 And vepo.TransactionStatus!=-1 And (joRelease.releaseType IS NULL || joRelease.releaseType<>4) 
			GROUP BY vepo.vePOID HAVING QuantityOrdered>0 
			UNION All 
			SELECT D.prTransferDetailID AS vePOID,CAST(H.TransNumber  AS CHAR) AS ponumber, H.TransferDate AS OrderDate,H.EstreceiveDate AS EstimatedShipDate,'Warehouse Transfer In' AS NAME,0 AS rxVendorID,
			prWarehouse.prWarehouseID,D.QuantityTransfered AS QuantityOrdered,prWarehouse.SearchName 
			FROM prWarehouse 
			INNER JOIN prWHtransfer H ON prWarehouse.prWarehouseID = H.prToWareHouseID JOIN prWHtransferDetail D ON H.prTransferID = D.prTransferID 
			LEFT JOIN prMaster pr ON(D.prMasterID=pr.prMasterID) WHERE (H.ReceivedDate IS NULL) AND  (D.ReceivedDate IS NULL) 
			-- AND pr.IsInventory=1 
			AND (D.prMasterID = _prMasterID)
			 ORDER BY vePOID DESC;
	END IF;
END$$

DELIMITER ;



-- ==================================

-- call TAX_calculateTax(160,10000,100.00,@_StateTax,@_CityTax,@_CountyTax,@_MTATax,@_CCDTax,@_educationTax,@_HSTax,@_OtherTax1,@_OtherTax2);

DROP procedure IF EXISTS `TAX_calculateTax`;

DELIMITER $$
-- CREATE DEFINER=`root`@`%` PROCEDURE `TAX_calculateTax`( IN _coTaxTerritoryID  INT, IN _totalTax decimal(19,4),
-- OUT _StateTax decimal(19,4) )
CREATE DEFINER=`root`@`%` PROCEDURE `TAX_calculateTax`( IN _coTaxTerritoryID  INT, IN _taxableSales decimal(19,4), IN _totalTax decimal(19,4),
  OUT _StateTax decimal(19,4),OUT _CityTax decimal(19,4),OUT _CountyTax decimal(19,4),OUT _MTATax decimal(19,4),OUT _CCDTax decimal(19,4),
  OUT _educationTax decimal(19,4),OUT _HSTax decimal(19,4),OUT _OtherTax1 decimal(19,4),OUT _OtherTax2 decimal(19,4) )
BEGIN
/*
DECLARE _StateTax decimal(19,4);
DECLARE _CityTax decimal(19,4);
DECLARE _CountyTax decimal(19,4);
DECLARE _MTATax decimal(19,4);
DECLARE _CCDTax decimal(19,4);
DECLARE _educationTax decimal(19,4);
DECLARE _HSTax decimal(19,4);
DECLARE _OtherTax1 decimal(19,4);
DECLARE _OtherTax2 decimal(19,4);
*/

DECLARE _TaxDistribution1 decimal(19,4);
DECLARE _TaxDistribution2 decimal(19,4);
DECLARE _TaxDistribution3 decimal(19,4);
DECLARE _TaxDistribution4 decimal(19,4);
DECLARE _TaxDistribution5 decimal(19,4);
DECLARE _TaxDistribution6 decimal(19,4);
DECLARE _TaxDistribution7 decimal(19,4);
DECLARE _TaxDistribution8 decimal(19,4);

DECLARE _taxAdj decimal(19,4) DEFAULT 0.01;

select 
-- tax.State,tax.County,tax.CountyCode,tax.TaxShipping,
IFNULL(tax.Distribution1,0),IFNULL(tax.Distribution2,0),IFNULL(tax.Distribution3,0),IFNULL(tax.Distribution4,0),
IFNULL(tax.Distribution5,0),
IFNULL(tax.Distribution6,0),IFNULL(tax.Distribution7,0),IFNULL(tax.Distribution8,0)
into
-- _State,_County,_CountyCode,_IsTaxShipping,
_TaxDistribution1,_TaxDistribution2,_TaxDistribution3,_TaxDistribution4,_TaxDistribution5,_TaxDistribution6,_TaxDistribution7,_TaxDistribution8
from coTaxTerritory tax where coTaxTerritoryID=_coTaxTerritoryID;

-- select _TaxDistribution1,_TaxDistribution2,_TaxDistribution3,_TaxDistribution4,_TaxDistribution5,_TaxDistribution6,_TaxDistribution7,_TaxDistribution8;

				set _CityTax = ifnull(Round(_taxAdj*_TaxDistribution1 * _taxableSales,2),0);
				set _CountyTax = ifnull(Round(_taxAdj*_TaxDistribution2 * _taxableSales,2),0);
				set _MTATax = ifnull(Round(_taxAdj*_TaxDistribution3 * _taxableSales,2),0);
				set _CCDTax = ifnull(Round(_taxAdj*_TaxDistribution4 * _taxableSales,2),0);
				set _educationTax = ifnull(Round(_taxAdj*_TaxDistribution5 * _taxableSales,2),0);
				set _HSTax = ifnull(Round(_taxAdj*_TaxDistribution6 * _taxableSales,2),0);
				set _OtherTax1 = ifnull(Round(_taxAdj*_TaxDistribution7 * _taxableSales,2),0);
				set _OtherTax2 = ifnull(Round(_taxAdj*_TaxDistribution8 * _taxableSales,2),0);
				set _StateTax = Round(_totalTax,2) - _CityTax - _CountyTax - _MTATax - _CCDTax - _educationTax - _HSTax - _OtherTax1 -_OtherTax2;
                -- set _StateTax = 1;


/*

	private BigDecimal calculateTaxByDistribution(BigDecimal taxDistribution, BigDecimal taxableSales) {
		return JobUtil.floorFigureoverall((new BigDecimal("0.01")).multiply(taxableSales)
				.multiply(taxDistribution == null ? new BigDecimal("0.0000") : taxDistribution), 2);
	}
    

			if (hasGrandFatherTaxRate == 1) {
				cityTax = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution1(), taxableSales);
				countyTax = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution2(), taxableSales);
				mtaTax = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution3(), taxableSales);
				ccdTax = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution4(), taxableSales);
				educationTax = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution5(), taxableSales);
				hSTax = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution6(), taxableSales);
				otherTax1 = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution7(), taxableSales);
				otherTax2 = calculateTaxByDistribution(aCoTaxTerritory.getgRDistribution8(), taxableSales);
				stateTax = JobUtil
						.floorFigureoverall(
								taxAmount.subtract(cityTax).subtract(countyTax).subtract(mtaTax).subtract(ccdTax)
										.subtract(educationTax).subtract(hSTax).subtract(otherTax1).subtract(otherTax2),
								2);
			} else {
				cityTax = calculateTaxByDistribution(aCoTaxTerritory.getDistribution1(), taxableSales);
				countyTax = calculateTaxByDistribution(aCoTaxTerritory.getDistribution2(), taxableSales);
				mtaTax = calculateTaxByDistribution(aCoTaxTerritory.getDistribution3(), taxableSales);
				ccdTax = calculateTaxByDistribution(aCoTaxTerritory.getDistribution4(), taxableSales);
				educationTax = calculateTaxByDistribution(aCoTaxTerritory.getDistribution5(), taxableSales);
				hSTax = calculateTaxByDistribution(aCoTaxTerritory.getDistribution6(), taxableSales);
				otherTax1 = calculateTaxByDistribution(aCoTaxTerritory.getDistribution7(), taxableSales);
				otherTax2 = calculateTaxByDistribution(aCoTaxTerritory.getDistribution8(), taxableSales);
				stateTax = JobUtil
						.floorFigureoverall(
								taxAmount.subtract(cityTax).subtract(countyTax).subtract(mtaTax).subtract(ccdTax)
										.subtract(educationTax).subtract(hSTax).subtract(otherTax1).subtract(otherTax2),
								2);
			}
            
*/   


END$$

DELIMITER ;

-- ============================================
DROP procedure IF EXISTS `Invoice_billedQuantity`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `Invoice_billedQuantity`(
IN _action varchar(20),
IN _cuSOID INT
)
Invoice_billedQuantity:BEGIN

declare _SONumber varchar(100);
declare  _count int;
declare  _InvoiceNumber varchar(100);


  
  if(_action='QUANTITY' and _cuSOID is not null) then
  select sum(QuantityOrdered)-sum(QuantityBilled) as difference from cuSODetail d left join prMaster p on  p.prMasterID=d.prMasterID where 
  p.IsInventory=1 and cuSOID=_cuSOID;
  end if;
  
  if(_action='SOSTATUS' and _cuSOID is not null) then
  select TransactionStatus as tstatus from cuSO where cuSOID=_cuSOID ;
  end if;
  
  if(_action='INVOICENUMBER') then
		if(_cuSOID is not null) then 
		select SONumber into _SONumber from  cuSO where cuSOID=_cuSOID ;
        select count(cuSOID)+1 into _count from cuInvoice where cuSOID=_cuSOID and InvoiceNumber like CONCAT('%',_SONumber,'%') and joReleaseDetailID is null;
		set _InvoiceNumber = concat(_SONumber,'-',_count);
        select _InvoiceNumber;
        
        else
        SELECT ValueString into _InvoiceNumber  FROM sysVariable where sysVariableID = 2014002015;
        select _InvoiceNumber;
        end if;
	end if;
END$$

DELIMITER ;

-- ========================================

DROP procedure IF EXISTS `update_SoStatus`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `update_SoStatus`(
IN _cuSOID INT
)
update_SoStatus:BEGIN
  if(_cuSOID is null) then
  SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call update_SoStatus:Required: _cuSOID';
  leave update_SoStatus; 
   end if;
  if(_cuSOID is not null)  then
  update cuSO set TransactionStatus=2 where cuSOID=_cuSOID;
 end if;
END$$

DELIMITER ;


-- ==============================================
-- CI-Created and CI-Edited supported right now

-- call INVOICE_tpCuInvoiceLogMaster('CI-Created',291906,1); 

DROP procedure IF EXISTS `INVOICE_tpCuInvoiceLogMaster`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_tpCuInvoiceLogMaster`(
IN _transType varchar(50),
IN _cuInvoiceID INT,
IN _TransactionStatus INT,
IN _LastInvoiceAmount decimal(19,4),
IN _LastSubtotal decimal(19,4),
IN _LastFreight decimal(19,4),
IN _LastTaxAmount decimal(19,4),
IN _LastCostTotal decimal(19,4),
IN _LastTaxRate decimal(19,4),
IN _LastcoTaxTerritoryID INT,
IN _isInvoiceDatechanged INT
-- _LastInvoiceAmount_LastAppliedAmount_LastDiscountAmt_LastSubtotal_LastFreight_LastAddCost_LastCostTotal_LastTaxAmount_LastTaxRate_LastcoTaxTerritoryID
)
INVOICE_tpCuInvoiceLogMaster:BEGIN
-- DECLARE _cuInvoiceID INT;
DECLARE _CreatedOn datetime default now();
DECLARE _CreatedByID INT;
DECLARE _CreatedByName varchar(50);
DECLARE _ChangedOn datetime default now();
DECLARE _ChangedByID INT;
DECLARE _ChangedByName varchar(50);
-- DECLARE _transType varchar(50) default 'CI-Created';
DECLARE _joReleaseDetailID INT;
DECLARE _cuSOID INT;
DECLARE _rxCustomerID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _prToWarehouseID INT;
DECLARE _rxShipToID INT;
DECLARE _rxShipToAddressID INT;
DECLARE _ShipToMode INT(5);
DECLARE _cuTermsID INT;
DECLARE _coTaxTerritoryID INT;
DECLARE _InvoiceNumber varchar(50);
DECLARE _CustomerPONumber varchar(50);
DECLARE _InvoiceDate datetime;
DECLARE _effectiveDate datetime;
DECLARE _ShipDate datetime;
DECLARE _DueDate datetime;
DECLARE _PrintDate datetime;
DECLARE _cuAssignmentID0 INT;
DECLARE _cuAssignmentID1 INT;
DECLARE _cuAssignmentID2 INT;
DECLARE _cuAssignmentID3 INT;
DECLARE _cuAssignmentID4 INT;
DECLARE _CreditMemo INT(5);
DECLARE _memoStatus INT(5);
DECLARE _IsCredit INT(5);
DECLARE _reason text;
DECLARE _State varchar(50);
DECLARE _County varchar(50);
DECLARE _CountyCode varchar(50);
DECLARE _SONumber varchar(50);
 DECLARE _InvoiceAmount decimal(19,4);
-- DECLARE _LastInvoiceAmount decimal(19,4);
DECLARE _AppliedAmount decimal(19,4);
DECLARE _LastAppliedAmount decimal(19,4);
DECLARE _DiscountAmt decimal(19,4);
DECLARE _LastDiscountAmt decimal(19,4);
DECLARE _Subtotal decimal(19,4);
-- DECLARE _LastSubtotal decimal(19,4);
DECLARE _Freight decimal(19,4);
-- DECLARE _LastFreight decimal(19,4);
DECLARE _AddCost decimal(19,4);
DECLARE _LastAddCost decimal(19,4);
DECLARE _CostTotal decimal(19,4);
-- DECLARE _LastCostTotal decimal(19,4);
DECLARE _TaxAmount decimal(19,4);
-- DECLARE _LastTaxAmount decimal(19,4);
DECLARE _TaxableSales decimal(19,4);
DECLARE _NonTaxableSales decimal(19,4);
DECLARE _TaxRate decimal(19,4);
DECLARE _IsTaxShipping INT(4);
DECLARE _StateTax decimal(19,4);
DECLARE _CityTax decimal(19,4);
DECLARE _CountyTax decimal(19,4);
DECLARE _MTATax decimal(19,4); 
DECLARE _CCDTax decimal(19,4);
DECLARE _educationTax decimal(19,4);
DECLARE _HSTax decimal(19,4);
DECLARE _OtherTax1 decimal(19,4);
DECLARE _OtherTax2 decimal(19,4);
DECLARE _TaxDistribution1 decimal(19,4);
DECLARE _TaxDistribution2 decimal(19,4);
DECLARE _TaxDistribution3 decimal(19,4);
DECLARE _TaxDistribution4 decimal(19,4);
DECLARE _TaxDistribution5 decimal(19,4);
DECLARE _TaxDistribution6 decimal(19,4);
DECLARE _TaxDistribution7 decimal(19,4);
DECLARE _TaxDistribution8 decimal(19,4);
DECLARE _Description varchar(250);
DECLARE _Note text;
DECLARE _PONumber varchar(50);
DECLARE _SalesPerson varchar(50);
-- DECLARE _SalesPersionId INT; _cuAssignmentID0
DECLARE _CustomerName varchar(50);
DECLARE _joReleaseID INT;
DECLARE _JobNumber varchar(50);
DECLARE _JobName varchar(250);
-- DECLARE _LastTaxRate decimal(19,4);
-- DECLARE _transStatus INT(3);
-- DECLARE _LastcoTaxTerritoryID INT;
DECLARE _Fperiod INT(5);
DECLARE _Fyear varchar(25);
-- DECLARE _TransactionStatus int;
DECLARE _Applied decimal(19,4);
DECLARE _TaxTotal decimal(19,4);
DECLARE _TrackingNumber varchar(50);
DECLARE _coDivisionID INT;
DECLARE _FreightCost decimal(19,4);
DECLARE _rxContactID INT;
DECLARE _jobnodescription varchar(50);
DECLARE _taxfreight INT;
DECLARE _tpCuInvoiceLogMasterID INT;

SELECT 
tax.State,tax.County,tax.CountyCode,tax.TaxShipping,
tax.Distribution1,tax.Distribution2,tax.Distribution3,tax.Distribution4,tax.Distribution5,tax.Distribution6,tax.Distribution7,tax.Distribution8,
i.`cuInvoiceID`,i.`CreatedByID`,i.`CreatedOn`,i.`ChangedByID`,i.`ChangedOn`,i.`TransactionStatus`,i.`Applied`,i.`joReleaseDetailID`,
i.`cuSOID`,
-- so.SONumber,
i.`rxCustomerID`,rx.Name,
-- i.`rxBillToID`,i.`rxBillToAddressID`,
i.`rxShipToID`,i.`rxShipToAddressID`,
-- i.`veShipViaID`,
i.`prFromWarehouseID`,i.`prToWarehouseID`,i.`cuTermsID`,i.`ShipToMode`,i.`coTaxTerritoryID`,i.`InvoiceNumber`,i.`CustomerPONumber`,
-- i.`QuickJobName`,
i.`InvoiceDate`,i.`ShipDate`,i.`DueDate`,i.`PrintDate`,i.`InvoiceAmount`,i.`AppliedAmount`,i.`TaxAmount`,i.`Freight`,i.`CostTotal`,i.`Subtotal`,i.`TaxTotal`,
i.`TaxRate`,i.`cuAssignmentID0`,i.`cuAssignmentID1`,i.`cuAssignmentID2`,i.`cuAssignmentID3`,i.`cuAssignmentID4`,i.`TrackingNumber`,i.`coDivisionID`,i.`FreightCost`,
-- i.`TaxExempt1`,i.`TaxExempt2`,i.`TaxExempt3`,i.`TaxExempt4`,i.`TaxExempt5`,i.`TaxExempt6`,i.`TaxExempt7`,i.`TaxExempt8`,i.`TaxExempt0`,
i.`CreditMemo`,i.`IsCredit`,i.`Description`,i.`Note`,i.`DiscountAmt`,i.`memoStatus`,
i.`rxContactID`,i.`jobnodescription`,i.`reason`,i.`taxfreight`,i.`TaxableSales`,
i.`NonTaxableSales`,
r.joReleaseID, m.JobNumber, m.Description
into
_State,_County,_CountyCode,_IsTaxShipping,
_TaxDistribution1,_TaxDistribution2,_TaxDistribution3,_TaxDistribution4,_TaxDistribution5,_TaxDistribution6,_TaxDistribution7,_TaxDistribution8,

_cuInvoiceID,_CreatedByID,_CreatedOn,_ChangedByID,_ChangedOn,_TransactionStatus,_Applied,_joReleaseDetailID,
_cuSOID,
-- _SONumber,
_rxCustomerID,_CustomerName,
-- _rxBillToID,_rxBillToAddressID,
_rxShipToID,_rxShipToAddressID,
-- _veShipViaID,
_prFromWarehouseID,_prToWarehouseID,_cuTermsID,_ShipToMode,_coTaxTerritoryID,_InvoiceNumber,_CustomerPONumber,
-- _QuickJobName,
_InvoiceDate,_ShipDate,_DueDate,_PrintDate,_InvoiceAmount,_AppliedAmount,_TaxAmount,_Freight,_CostTotal,_Subtotal,_TaxTotal,
_TaxRate,_cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3,_cuAssignmentID4,_TrackingNumber,_coDivisionID,_FreightCost,
-- _TaxExempt1,_TaxExempt2,_TaxExempt3,_TaxExempt4,_TaxExempt5,_TaxExempt6,_TaxExempt7,_TaxExempt8,_TaxExempt0,
_CreditMemo,_IsCredit,_Description,_Note,_DiscountAmt,_memoStatus,
_rxContactID,_jobnodescription,_reason,_taxfreight,_TaxableSales,
_NonTaxableSales,
_joReleaseID,_jobNumber,_JobName
FROM `cuInvoice` i
left join coTaxTerritory tax on (tax.coTaxTerritoryID = i.coTaxTerritoryID)
left join joReleaseDetail rd on (i.joReleaseDetailID = rd.joReleaseDetailID)
left join joRelease r on (r.joReleaseID = rd.joReleaseID)
left join joMaster m on (m.joMasterID = r.joMasterID)
left join rxMaster rx on (rx.rxMasterID = i.rxCustomerID)
-- left join cuSO so on (so.cuSOID = i.cuSOID)
 where cuInvoiceID=_cuInvoiceID;

if (_ChangedByID is null) THEN set _ChangedByID =_CreatedByID; END IF;

select FullName into _SalesPerson from tsUserLogin where UserLoginID = _cuAssignmentID0;
select FullName,FullName into _CreatedByName,_ChangedByName from tsUserLogin where UserLoginID = _ChangedByID;

-- select Name into _CustomerName from rxMaster where rxCustomerID = _rxCustomerID;

-- how do i know if it is cuSO or vePO
if (_cuSOID is not null and _prFromWarehouseID is not null) THEN 
	select SONumber into _SONumber from cuSO where cuSOID = _cuSOID; 
END IF;
if (_cuSOID is not null and _prFromWarehouseID is null) THEN 
	select PONumber into _PONumber from vePO where vePOID = _cuSOID; 
END IF;
-- select sum(cost) into _AddCost  from joInvoiceCost where cuInvoiceID=_cuInvoiceID;
if((_isInvoiceDatechanged = 1) or (_transType ="CI-Created")) then 
set _effectiveDate = _InvoiceDate ;
else 
set _effectiveDate = now();
end if;

set _TaxAmount = _TaxTotal;
set _ChangedOn = now();

-- call INVOICE_tpCuInvoiceLogMaster('CI-Created',291906,1); 
-- call TAX_calculateTax(_coTaxTerritoryID,_TaxAmount,@_StateTax);
-- select _TaxAmount,@_StateTax;


call TAX_calculateTax(_coTaxTerritoryID,_TaxableSales,_TaxAmount,_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_educationTax,_HSTax,_OtherTax1,_OtherTax2);
-- call TAX_calculateTax(_coTaxTerritoryID,_TaxAmount,_StateTax);
-- select _TaxableSales,_TaxAmount,_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_educationTax,_HSTax,_OtherTax1,_OtherTax2;
-- leave INVOICE_tpCuInvoiceLogMaster;

-- get the fyear and period
if(date(_CreatedOn) = date(_ChangedOn)) then
SELECT p.period, y.fiscalYear 
into _Fperiod,_Fyear
FROM coFiscalPeriod p 
left join coFiscalYear `y` on (p.coFiscalYearID = y.coFiscalYearID)
where date(_InvoiceDate) between p.StartDate and p.EndDate limit 1;
else
SELECT p.period, y.fiscalYear 
into _Fperiod,_Fyear
FROM coFiscalPeriod p 
left join coFiscalYear `y` on (p.coFiscalYearID = y.coFiscalYearID)
where date(now()) between p.StartDate and p.EndDate limit 1;
end if;

/*
_AddCost,
_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_OtherTax,
_HSTax,_OtherTax1,_OtherTax2,
,_Fperiod,_Fyear

*/
if(_TaxRate = 0) then
set _NonTaxableSales = _TaxableSales+_NonTaxableSales;
set _TaxableSales = 0;
end if;
/*
if (_transType = 'CI-Created') THEN
	-- select  _transType;
ELSEIF (_transType = 'CI-Edited') THEN
	-- select  _transType;
    -- call INVOICE_tpCuInvoiceLogMaster_rollback('CI-ROLLBACK',_cuInvoiceID,0);
END IF;
*/

INSERT INTO `tpCuInvoiceLogMaster`
(`cuInvoiceID`,`CreatedOn`,`CreatedByID`,`CreatedByName`,`ChangedOn`,`ChangedByID`,`ChangedByName`,
`transType`,`joReleaseDetailID`,`cuSOID`,`rxCustomerID`,`prFromWarehouseID`,`prToWarehouseID`,`rxShipToID`,`rxShipToAddressID`,
`ShipToMode`,`cuTermsID`,`coTaxTerritoryID`,`InvoiceNumber`,`CustomerPONumber`,`InvoiceDate`,`ShipDate`,`DueDate`,`PrintDate`,
`cuAssignmentID0`,`cuAssignmentID1`,`CreditMemo`,`memoStatus`,`IsCredit`,`reason`,`State`,`County`,`CountyCode`,`SONumber`,
`InvoiceAmount`,`LastInvoiceAmount`,`AppliedAmount`,`LastAppliedAmount`,`DiscountAmt`,`LastDiscountAmt`,`Subtotal`,
`LastSubtotal`,`Freight`,`LastFreight`,`AddCost`,`LastAddCost`,`CostTotal`,`LastCostTotal`,`TaxAmount`,`LastTaxAmount`,
`TaxableSales`,`NonTaxableSales`,`TaxRate`,`IsTaxShipping`,`StateTax`,`CityTax`,`CountyTax`,`MTATax`,`CCDTax`,`OtherTax`,
`HSTax`,`OtherTax1`,`OtherTax2`,
`TaxDistribution1`,`TaxDistribution2`,`TaxDistribution3`,`TaxDistribution4`,`TaxDistribution5`,`TaxDistribution6`,`TaxDistribution7`,`TaxDistribution8`,
`Description`,`Note`,`PONumber`,`SalesPerson`,`SalesPersionId`,`CustomerName`,`joReleaseID`,`JobNumber`,`JobName`,
`LastTaxRate`,`transStatus`,`LastcoTaxTerritoryID`,`LogDate`,`Fperiod`,`Fyear`,`effectiveDate`)
VALUES
(_cuInvoiceID,_CreatedOn,_CreatedByID,_CreatedByName,_ChangedOn,_ChangedByID,_ChangedByName,
_transType,_joReleaseDetailID,_cuSOID,_rxCustomerID,_prFromWarehouseID,_prToWarehouseID,_rxShipToID,_rxShipToAddressID,
_ShipToMode,_cuTermsID,_coTaxTerritoryID,_InvoiceNumber,_CustomerPONumber,_InvoiceDate,_ShipDate,_DueDate,_PrintDate,
_cuAssignmentID0,_cuAssignmentID1,_CreditMemo,_memoStatus,_IsCredit,_reason,_State,_County,_CountyCode,_SONumber,
_InvoiceAmount,_LastInvoiceAmount,_AppliedAmount,_LastAppliedAmount,_DiscountAmt,_LastDiscountAmt,_Subtotal,
_LastSubtotal,_Freight,_LastFreight,IFNULL(_FreightCost,0),_LastAddCost,_CostTotal,_LastCostTotal,_TaxAmount,_LastTaxAmount,
_TaxableSales,_NonTaxableSales,_TaxRate,_IsTaxShipping,_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_educationTax,
_HSTax,_OtherTax1,_OtherTax2,
_TaxDistribution1,_TaxDistribution2,_TaxDistribution3,_TaxDistribution4,_TaxDistribution5,_TaxDistribution6,_TaxDistribution7,_TaxDistribution8,
_Description,_Note,_PONumber,_SalesPerson,_cuAssignmentID0,_CustomerName,_joReleaseID,_JobNumber,_JobName,
_LastTaxRate,_TransactionStatus,_LastcoTaxTerritoryID,now(),_Fperiod,_Fyear,_effectiveDate);

select last_insert_id() into _tpCuInvoiceLogMasterID;
select _tpCuInvoiceLogMasterID;
END$$

DELIMITER ;    

-- ==================================================


DROP procedure IF EXISTS `INVOICE_tpCuInvoiceLogMaster_rollback`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_tpCuInvoiceLogMaster_rollback`(
IN _transType varchar(50),
IN _cuInvoiceID INT,
IN _TransactionStatus INT,
IN _lastSubTotal decimal(19,4),
IN _lastFreight decimal(19,4),
IN _lastTaxAmount decimal(19,4),
IN _LastcoTaxTerritoryID INT,
IN _lastCostTotal decimal(19,4),
IN _lastTaxableSales decimal(19,4),
IN _lastNonTaxableSales decimal(19,4),
IN _lastInvoiceAmount decimal(19,4),
IN _lastTaxRate decimal(19,4)
)
INVOICE_tpCuInvoiceLogMaster_rollback:BEGIN


DECLARE _CreatedOn datetime default now();
DECLARE _CreatedByID INT;
DECLARE _CreatedByName varchar(50);
DECLARE _ChangedOn datetime default now();
DECLARE _ChangedByID INT;
DECLARE _ChangedByName varchar(50);
-- DECLARE _transType varchar(50) default 'CI-Created';
DECLARE _joReleaseDetailID INT;
DECLARE _cuSOID INT;
DECLARE _rxCustomerID INT;
DECLARE _prFromWarehouseID INT;
DECLARE _prToWarehouseID INT;
DECLARE _rxShipToID INT;
DECLARE _rxShipToAddressID INT;
DECLARE _ShipToMode INT(5);
DECLARE _cuTermsID INT;
DECLARE _coTaxTerritoryID INT;
DECLARE _InvoiceNumber varchar(50);
DECLARE _CustomerPONumber varchar(50);
DECLARE _InvoiceDate datetime;
declare _effectiveDate datetime;
DECLARE _ShipDate datetime;
DECLARE _DueDate datetime;
DECLARE _PrintDate datetime;
DECLARE _cuAssignmentID0 INT;
DECLARE _cuAssignmentID1 INT;
DECLARE _cuAssignmentID2 INT;
DECLARE _cuAssignmentID3 INT;
DECLARE _cuAssignmentID4 INT;
DECLARE _CreditMemo INT(5);
DECLARE _memoStatus INT(5);
DECLARE _IsCredit INT(5);
DECLARE _reason text;
DECLARE _State varchar(50);
DECLARE _County varchar(50);
DECLARE _CountyCode varchar(50);
DECLARE _SONumber varchar(50);
DECLARE _InvoiceAmount decimal(19,4);
-- DECLARE _LastInvoiceAmount decimal(19,4);
DECLARE _AppliedAmount decimal(19,4);
DECLARE _LastAppliedAmount decimal(19,4);
DECLARE _DiscountAmt decimal(19,4);
DECLARE _LastDiscountAmt decimal(19,4);
DECLARE _Subtotal decimal(19,4);
-- DECLARE _LastSubtotal decimal(19,4);
DECLARE _Freight decimal(19,4);
-- DECLARE _LastFreight decimal(19,4);
DECLARE _AddCost decimal(19,4);
DECLARE _LastAddCost decimal(19,4);
DECLARE _CostTotal decimal(19,4);
-- DECLARE _LastCostTotal decimal(19,4);
DECLARE _TaxAmount decimal(19,4);
-- DECLARE _LastTaxAmount decimal(19,4);
DECLARE _TaxableSales decimal(19,4);
DECLARE _NonTaxableSales decimal(19,4);
DECLARE _TaxRate decimal(19,4);
DECLARE _IsTaxShipping INT(4);
DECLARE _StateTax decimal(19,4);
DECLARE _CityTax decimal(19,4);
DECLARE _CountyTax decimal(19,4);
DECLARE _MTATax decimal(19,4); 
DECLARE _CCDTax decimal(19,4);
DECLARE _educationTax decimal(19,4);
DECLARE _HSTax decimal(19,4);
DECLARE _OtherTax1 decimal(19,4);
DECLARE _OtherTax2 decimal(19,4);
DECLARE _TaxDistribution1 decimal(19,4);
DECLARE _TaxDistribution2 decimal(19,4);
DECLARE _TaxDistribution3 decimal(19,4);
DECLARE _TaxDistribution4 decimal(19,4);
DECLARE _TaxDistribution5 decimal(19,4);
DECLARE _TaxDistribution6 decimal(19,4);
DECLARE _TaxDistribution7 decimal(19,4);
DECLARE _TaxDistribution8 decimal(19,4);
DECLARE _Description varchar(250);
DECLARE _Note text;
DECLARE _PONumber varchar(50);
DECLARE _SalesPerson varchar(50);
-- DECLARE _SalesPersionId INT; _cuAssignmentID0
DECLARE _CustomerName varchar(50);
DECLARE _joReleaseID INT;
DECLARE _JobNumber varchar(50);
DECLARE _JobName varchar(250);
-- DECLARE _LastTaxRate decimal(19,4);
-- DECLARE _transStatus INT(3);
-- DECLARE _LastcoTaxTerritoryID INT;
DECLARE _Fperiod INT(5);
DECLARE _Fyear varchar(25);
-- DECLARE _TransactionStatus int;
DECLARE _Applied decimal(19,4);
DECLARE _TaxTotal decimal(19,4);
DECLARE _TrackingNumber varchar(50);
DECLARE _coDivisionID INT;
DECLARE _FreightCost decimal(19,4);
DECLARE _rxContactID INT;
DECLARE _jobnodescription varchar(50);
DECLARE _taxfreight INT;
DECLARE _tpCuInvoiceLogMasterID INT;
Declare _lastinvoicedate datetime;

SELECT 
tax.State,tax.County,tax.CountyCode,tax.TaxShipping,
tax.Distribution1,tax.Distribution2,tax.Distribution3,tax.Distribution4,tax.Distribution5,tax.Distribution6,tax.Distribution7,tax.Distribution8,
i.`cuInvoiceID`,i.`CreatedByID`,i.`CreatedOn`,i.`ChangedByID`,i.`ChangedOn`,i.`TransactionStatus`,i.`Applied`,i.`joReleaseDetailID`,
i.`cuSOID`,
-- so.SONumber,
i.`rxCustomerID`,rx.Name,
-- i.`rxBillToID`,i.`rxBillToAddressID`,
i.`rxShipToID`,i.`rxShipToAddressID`,
-- i.`veShipViaID`,
i.`prFromWarehouseID`,i.`prToWarehouseID`,i.`cuTermsID`,i.`ShipToMode`,i.`coTaxTerritoryID`,i.`InvoiceNumber`,i.`CustomerPONumber`,
-- i.`QuickJobName`,
i.`InvoiceDate`,i.`ShipDate`,i.`DueDate`,i.`PrintDate`,i.`InvoiceAmount`,i.`AppliedAmount`,i.`TaxAmount`,i.`Freight`,i.`CostTotal`,i.`Subtotal`,i.`TaxTotal`,
i.`TaxRate`,i.`cuAssignmentID0`,i.`cuAssignmentID1`,i.`cuAssignmentID2`,i.`cuAssignmentID3`,i.`cuAssignmentID4`,i.`TrackingNumber`,i.`coDivisionID`,i.`FreightCost`,
-- i.`TaxExempt1`,i.`TaxExempt2`,i.`TaxExempt3`,i.`TaxExempt4`,i.`TaxExempt5`,i.`TaxExempt6`,i.`TaxExempt7`,i.`TaxExempt8`,i.`TaxExempt0`,
i.`CreditMemo`,i.`IsCredit`,i.`Description`,i.`Note`,i.`DiscountAmt`,i.`memoStatus`,
i.`rxContactID`,i.`jobnodescription`,i.`reason`,i.`taxfreight`,i.`TaxableSales`,
i.`NonTaxableSales`,
r.joReleaseID, m.JobNumber, m.Description
into
_State,_County,_CountyCode,_IsTaxShipping,
_TaxDistribution1,_TaxDistribution2,_TaxDistribution3,_TaxDistribution4,_TaxDistribution5,_TaxDistribution6,_TaxDistribution7,_TaxDistribution8,

_cuInvoiceID,_CreatedByID,_CreatedOn,_ChangedByID,_ChangedOn,_TransactionStatus,_Applied,_joReleaseDetailID,
_cuSOID,
-- _SONumber,
_rxCustomerID,_CustomerName,
-- _rxBillToID,_rxBillToAddressID,
_rxShipToID,_rxShipToAddressID,
-- _veShipViaID,
_prFromWarehouseID,_prToWarehouseID,_cuTermsID,_ShipToMode,_coTaxTerritoryID,_InvoiceNumber,_CustomerPONumber,
-- _QuickJobName,
_InvoiceDate,_ShipDate,_DueDate,_PrintDate,_InvoiceAmount,_AppliedAmount,_TaxAmount,_Freight,_CostTotal,_Subtotal,_TaxTotal,
_TaxRate,_cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3,_cuAssignmentID4,_TrackingNumber,_coDivisionID,_FreightCost,
-- _TaxExempt1,_TaxExempt2,_TaxExempt3,_TaxExempt4,_TaxExempt5,_TaxExempt6,_TaxExempt7,_TaxExempt8,_TaxExempt0,
_CreditMemo,_IsCredit,_Description,_Note,_DiscountAmt,_memoStatus,
_rxContactID,_jobnodescription,_reason,_taxfreight,_TaxableSales,
_NonTaxableSales,
_joReleaseID,_jobNumber,_JobName
FROM `cuInvoice` i
left join coTaxTerritory tax on (tax.coTaxTerritoryID = _LastcoTaxTerritoryID)
left join joReleaseDetail rd on (i.joReleaseDetailID = rd.joReleaseDetailID)
left join joRelease r on (r.joReleaseID = rd.joReleaseID)
left join joMaster m on (m.joMasterID = r.joMasterID)
left join rxMaster rx on (rx.rxMasterID = i.rxCustomerID)
-- left join cuSO so on (so.cuSOID = i.cuSOID)
 where cuInvoiceID=_cuInvoiceID;

 SELECT AddCost,TaxableSales,NonTaxableSales,StateTax,CityTax,CountyTax,MTATax,CCDTax,OtherTax,HSTax,OtherTax1,OtherTax2,InvoiceDate
 INTO 
 _AddCost,_lastTaxableSales,_lastNonTaxableSales,_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_educationTax,_HSTax,_OtherTax1,_OtherTax2,_lastinvoicedate
 FROM tpCuInvoiceLogMaster WHERE cuInvoiceID=_cuInvoiceID and transStatus=1 ORDER BY tpCuInvoiceLogMasterID DESC LIMIT 1; 

if (_ChangedByID is null) THEN set _ChangedByID =_CreatedByID; END IF;

select FullName into _SalesPerson from tsUserLogin where UserLoginID = _cuAssignmentID0;
select FullName,FullName into _CreatedByName,_ChangedByName from tsUserLogin where UserLoginID = _ChangedByID;

-- select Name into _CustomerName from rxMaster where rxCustomerID = _rxCustomerID;
if(date(_lastinvoicedate) <> date(_InvoiceDate)) then 
set _effectiveDate = _lastinvoicedate;

else 
set _effectiveDate = now();
end if;
-- how do i know if it is cuSO or vePO
if (_cuSOID is not null and _prFromWarehouseID is not null) THEN 
	select SONumber into _SONumber from cuSO where cuSOID = _cuSOID; 
END IF;
if (_cuSOID is not null and _prFromWarehouseID is null) THEN 
	select PONumber into _PONumber from vePO where vePOID = _cuSOID; 
END IF;
-- select (sum(cost))*-1 into _AddCost  from joInvoiceCost where cuInvoiceID=_cuInvoiceID;



set _ChangedOn = now();

-- call INVOICE_tpCuInvoiceLogMaster('CI-Created',291906,1); 
-- call TAX_calculateTax(_coTaxTerritoryID,_TaxAmount,@_StateTax);
-- select _TaxAmount,@_StateTax;

-- set _TaxableSales = _lastTaxableSales;
-- call TAX_calculateTax(_LastcoTaxTerritoryID,_TaxableSales,_TaxAmount,_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_educationTax,_HSTax,_OtherTax1,_OtherTax2);
-- call TAX_calculateTax(_coTaxTerritoryID,_TaxAmount,_StateTax);
-- select _TaxableSales,_TaxAmount,_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_educationTax,_HSTax,_OtherTax1,_OtherTax2;
-- leave INVOICE_tpCuInvoiceLogMaster;
set _Subtotal = -1*_lastSubTotal;
set _Freight = -1*_lastFreight ;
set _TaxAmount = -1*_lastTaxAmount;
set _CostTotal =  -1*_lastCostTotal;
set _TaxableSales = -1*_lastTaxableSales;
set  _NonTaxableSales=-1*_lastNonTaxableSales;
set _InvoiceAmount =  -1*_lastInvoiceAmount;
/*
_AddCost,
_StateTax,_CityTax,_CountyTax,_MTATax,_CCDTax,_OtherTax,
_HSTax,_OtherTax1,_OtherTax2,
,_Fperiod,_Fyear

*/

INSERT INTO `tpCuInvoiceLogMaster`
(`cuInvoiceID`,`CreatedOn`,`CreatedByID`,`CreatedByName`,`ChangedOn`,`ChangedByID`,`ChangedByName`,
`transType`,`joReleaseDetailID`,`cuSOID`,`rxCustomerID`,`prFromWarehouseID`,`prToWarehouseID`,`rxShipToID`,`rxShipToAddressID`,
`ShipToMode`,`cuTermsID`,`coTaxTerritoryID`,`InvoiceNumber`,`CustomerPONumber`,`InvoiceDate`,`ShipDate`,`DueDate`,`PrintDate`,
`cuAssignmentID0`,`cuAssignmentID1`,`CreditMemo`,`memoStatus`,`IsCredit`,`reason`,`State`,`County`,`CountyCode`,`SONumber`,
`InvoiceAmount`,`LastInvoiceAmount`,`AppliedAmount`,`LastAppliedAmount`,`DiscountAmt`,`LastDiscountAmt`,`Subtotal`,
`LastSubtotal`,`Freight`,`LastFreight`,`AddCost`,`LastAddCost`,`CostTotal`,`LastCostTotal`,`TaxAmount`,`LastTaxAmount`,
`TaxableSales`,`NonTaxableSales`,`TaxRate`,`IsTaxShipping`,`StateTax`,`CityTax`,`CountyTax`,`MTATax`,`CCDTax`,`OtherTax`,
`HSTax`,`OtherTax1`,`OtherTax2`,
`TaxDistribution1`,`TaxDistribution2`,`TaxDistribution3`,`TaxDistribution4`,`TaxDistribution5`,`TaxDistribution6`,`TaxDistribution7`,`TaxDistribution8`,
`Description`,`Note`,`PONumber`,`SalesPerson`,`SalesPersionId`,`CustomerName`,`joReleaseID`,`JobNumber`,`JobName`,
`LastTaxRate`,`transStatus`,`LastcoTaxTerritoryID`,`LogDate`,`Fperiod`,`Fyear`,`effectiveDate`)
VALUES
(_cuInvoiceID,_CreatedOn,_CreatedByID,_CreatedByName,_ChangedOn,_ChangedByID,_ChangedByName,
_transType,_joReleaseDetailID,_cuSOID,_rxCustomerID,_prFromWarehouseID,_prToWarehouseID,_rxShipToID,_rxShipToAddressID,
_ShipToMode,_cuTermsID,_LastcoTaxTerritoryID,_InvoiceNumber,_CustomerPONumber,_InvoiceDate,_ShipDate,_DueDate,_PrintDate,
_cuAssignmentID0,_cuAssignmentID1,_CreditMemo,_memoStatus,_IsCredit,_reason,_State,_County,_CountyCode,_SONumber,
_InvoiceAmount,0.0000,_AppliedAmount,0.0000,_DiscountAmt,0.0000,_Subtotal,
0.0000,_Freight,0.0000,IFNULL(_AddCost,0)*-1,0.0000,_CostTotal,0.0000,_TaxAmount,0.0000,
_TaxableSales,_NonTaxableSales,_lastTaxRate,_IsTaxShipping,-1*_StateTax,-1*_CityTax,-1*_CountyTax,-1*_MTATax,-1*_CCDTax,-1*_educationTax,
-1*_HSTax,-1*_OtherTax1,-1*_OtherTax2,
_TaxDistribution1,_TaxDistribution2,_TaxDistribution3,_TaxDistribution4,_TaxDistribution5,_TaxDistribution6,_TaxDistribution7,_TaxDistribution8,
_Description,_Note,_PONumber,_SalesPerson,_cuAssignmentID0,_CustomerName,_joReleaseID,_JobNumber,_JobName,
_lastTaxRate,_TransactionStatus,_LastcoTaxTerritoryID,now(),_Fperiod,_Fyear,_effectiveDate);

select last_insert_id() into _tpCuInvoiceLogMasterID;
select _tpCuInvoiceLogMasterID;


END$$

DELIMITER ;





-- ============================================ 

DROP procedure IF EXISTS `INVOICE_fromSoDetail`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_fromSoDetail`(
IN _cuSOID INT
)
BEGIN
  SELECT SUM(quantityBilled) AS quantityBilled,SUM(backOrdered) AS backOrdered FROM ( 
		SELECT  d.cuSODetailID,
		CASE WHEN ItemCode='QP' THEN 0 ELSE IFNULL((QuantityBilled - SUM(d.backOrdered)),d.SOQuantityBilled) END AS quantityBilled ,
		IFNULL(SUM(d.backOrdered),0) AS backOrdered
		FROM (
			SELECT 
			detail.Description ,p.ItemCode,
			detail.cuSOID, detail.QuantityOrdered,  detail.UnitCost, detail.PriceMultiplier, detail.Taxable,
			sodb.cuSODetailBinID, detail.cuSODetailID, sodb.binId, sodb.allocated, (detail.QuantityOrdered-IFNULL(detail.QuantityBilled,0)) AS QuantityBilled, detail.QuantityBilled AS SOQuantityBilled,
			(CASE WHEN ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) <= b.InventoryOnHand THEN  ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) ELSE  b.InventoryOnHand END) AS availableToInvoice,
			(CASE WHEN ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) - b.InventoryOnHand < 0 THEN 0 ELSE ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) - b.InventoryOnHand END) AS backOrdered,	
			b.InventoryOnHand,  b.searchName AS binName, p.prMasterID, so.prFromWarehouseID, p.IsInventory 
			FROM cuSODetail detail  
			LEFT JOIN cuSO so ON (so.cuSOID = detail.cuSOID)
			LEFT JOIN cuSODetailBin sodb ON (detail.cuSODetailID = sodb.cuSODetailID) 
			LEFT JOIN `bin` b ON (b.binId = sodb.binId)
			LEFT JOIN prMaster p ON (p.prMasterID = detail.prMasterID)
			WHERE detail.cuSOID = _cuSOID
		) d
		GROUP BY d.cuSODetailID
		) AS test;
END$$

DELIMITER ;

-- =============================================

DROP procedure IF EXISTS `INVOICE_CheckSoBillStatus`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INVOICE_CheckSoBillStatus`(
IN _cuSOID INT
)
BEGIN
  DECLARE isQuotedPriceLineItems INT;
	SELECT cuSODetailID INTO isQuotedPriceLineItems FROM cuSODetail sod LEFT JOIN prMaster pm ON(sod.prMasterID=pm.prMasterID)  WHERE cuSOID=_cuSOID AND pm.ItemCode='QP';
	IF (isQuotedPriceLineItems IS NOT NULL) THEN
		SELECT 
			CASE WHEN TransactionStatus=-1 THEN "Void" 
			WHEN TransactionStatus=0 THEN "OnHold" 
			WHEN TransactionStatus=2 THEN "Closed"
			ELSE
			IF(SubTotal-totalInvoiceAmount<=0,"BilledFully","") END AS STATUS 
			FROM (
				SELECT so.cuSOID,so.TransactionStatus,so.SubTotal,SUM(ci.InvoiceAmount) AS totalInvoiceAmount FROM cuSO so 
				LEFT JOIN cuInvoice ci ON(so.cuSOID=ci.cuSOID AND joreleaseID IS NULL AND joreleaseDetailID IS NULL)
				WHERE so.cuSOID=_cuSOID
			)AS statusTable;
	ELSE
			SELECT CASE WHEN TransactionStatus=-1 THEN "Void" 
			WHEN TransactionStatus=0 THEN "OnHold" 
			WHEN TransactionStatus=2 THEN "Closed"
			ELSE
			IF(SUM(IFNULL(sod.QuantityOrdered,0)-IFNULL(sod.QuantityBilled,0))=0,"BilledFully","") END AS STATUS 
			 FROM cuSO so 
			LEFT JOIN cuSODetail sod ON(so.cuSOID=sod.cuSOID) WHERE so.cuSOID=_cuSOID
			GROUP BY so.cuSOID;
	
	
	END IF;
END$$

DELIMITER ;

-- =============================================
DROP procedure IF EXISTS `sp_rolodex_address_update`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `sp_rolodex_address_update`(
IN _action VARCHAR(100),
IN _rxAddressID INT(11),
IN _rxMasterID INT(10),
IN _InActive TINYINT(4),
IN _Name VARCHAR(80),
IN _Address1 VARCHAR(40),
IN _Address2 VARCHAR(40),
IN _City VARCHAR(30),
IN _State VARCHAR(2),
IN _Zip VARCHAR(10),
IN _IsStreet TINYINT(4),
IN _IsMailing TINYINT(4),
IN _IsBillTo TINYINT(4),
IN _IsShipTo TINYINT(4),
IN _coTaxTerritoryID INT(10),
IN _otherBillTo INT(10),
IN _otherShipTo INT(10),
IN _Phone1 VARCHAR(30),
IN _Phone2 VARCHAR(30),
IN _Fax VARCHAR(30),
IN _IsDefault TINYINT(4),
IN _IsRemitTo TINYINT(4),
OUT _returnval INT(11)
)
BEGIN
IF (_action='Update')THEN
	-- if (rxMasterID is not null) then 
	--	SELECT coTaxTerritoryID into _coTaxTerritoryID FROM rxAddress WHERE rxMasterID =_rxMasterID AND IsDefault = 1;
	-- End if;	
    INSERT INTO rxAddress(rxAddressID,rxMasterID,InActive,NAME,Address1,Address2,City,State,Zip,IsStreet,IsMailing,IsBillTo,IsShipTo,coTaxTerritoryID,otherBillTo,otherShipTo,Phone1,Phone2,Fax,IsDefault,IsRemitTo)
    VALUES(_rxAddressID,_rxMasterID,_InActive,_Name,_Address1,_Address2,_City,_State,_Zip,_IsStreet,_IsMailing,_IsBillTo,_IsShipTo,_coTaxTerritoryID,_otherBillTo,_otherShipTo,_Phone1,_Phone2,_Fax,_IsDefault,_IsRemitTo);
    SELECT LAST_INSERT_ID() INTO _returnval;
END IF; 
END$$
DELIMITER ;

-- =============================================

DROP procedure IF EXISTS `INV_createVirtualbin`;

DELIMITER $$

CREATE PROCEDURE `INV_createVirtualbin` (
IN _action varchar(25)
)
INV_createVirtualbin:BEGIN
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _warehouses text;
DECLARE _prWarehouseID INT;
DECLARE _warehouseName varchar(255);
DECLARE _overrideName varchar(255);
DECLARE _binID INT;
DECLARE _count INT;
DECLARE _inTransfer decimal(19,4);
		
        select count(*) into _count from bin where prMasterID is null and InTransfer is not null;
        if(_count >0) then 
			select "already inserted";
			leave INV_createVirtualbin;
		end if;
        select group_concat(prWarehouseID)  into _warehouses from prWarehouse;
        
        do_this:
			LOOP
				SET strLen = CHAR_LENGTH(_warehouses);
								
				set _prWarehouseID=SUBSTRING_INDEX(_warehouses, ',', 1);
                
                select searchName into _warehouseName from prWarehouse where prWarehouseID=_prWarehouseID;
                
                set _overrideName = concat( _warehouseName," Transfer Bin");
                
				select
				  ifnull(sum(pwd.QuantityTransfered),0)
				 into _inTransfer
				 from prWHtransferDetail  pwd 
				left join prWHtransfer pw on  pwd.prTransferID = pw.prTransferID 
				where pw.screenno = 1 
				and pwd.ReceivedDate is null and pwd.toBinId is null and pw.prFromWareHouseID =  _prWarehouseID
				order by pwd.prTransferDetailID desc;
                
                insert into bin 
                (prWarehouseID,overrideName,searchName,LastUpdatedTime,changedByID,inTransfer)
                values 
                (_prWarehouseID,_overrideName,_overrideName,now(),0,_inTransfer);
                select LAST_INSERT_ID() INTO _binID;
                select _binID;
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_warehouses, ',', 1))+2;
				SET _warehouses = MID(_warehouses, SubStrLen, strLen);

				
		
				IF _warehouses = '' or _warehouses is null  THEN
					LEAVE do_this;
				END IF;
				END LOOP do_this;
            

END$$

DELIMITER ;

-- =============================================

DROP procedure IF EXISTS `INV_warehouseVirtualBin`;


DELIMITER $$

CREATE PROCEDURE `INV_warehouseVirtualBin` (
IN _action varchar(25),
IN _prWarehouseID INT
)
INV_warehouseVirtualBin:BEGIN



DECLARE _warehouseName varchar(255);
DECLARE _overrideName varchar(255);
DECLARE _binID INT;

		
        
        if ( _prWarehouseID is null) THEN 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call INV_warehouseVirtualBin:_prWarehouseID missing';
			LEAVE INV_warehouseVirtualBin; 
		END IF;
        
        if(_action = "INSERT") then 
			
            select searchName into _warehouseName from prWarehouse where prWarehouseID=_prWarehouseID;
            set _overrideName = concat( _warehouseName," Transfer Bin");
            
            insert into bin 
			(prWarehouseID,overrideName,searchName,LastUpdatedTime,changedByID,inTransfer)
			values 
			(_prWarehouseID,_overrideName,_overrideName,now(),0,0);
            
            select LAST_INSERT_ID() INTO _binID;
            select * from bin where binId = _binID;
            
		end if;
        
        if(_action = "UPDATE") then 
			
            select searchName into _warehouseName from prWarehouse where prWarehouseID=_prWarehouseID;
            set _overrideName = concat( _warehouseName," Transfer Bin");
            select binId into _binID from bin where prWarehouseID=_prWarehouseID and inTransfer is not null;
            UPDATE bin set overrideName=_overrideName,searchName=_overrideName,LastUpdatedTime=now() where  binId = _binID;
            select * from bin where binId = _binID;
            
		end if;
        
        if(_action = "GETBIN") then 
			
            
            select binId into _binID from bin where prWarehouseID=_prWarehouseID and inTransfer is not null;
            select * from bin where binId = _binID;
            
		end if;
        
         if(_action = "GETPRODUCT") then 
			
            
           select
			  sum(pwd.QuantityTransfered) as quantity,
			 pwd.prMasterID,pr.ItemCode,pw.prFromWareHouseID
			 from prWHtransferDetail  pwd 
			left join prWHtransfer pw on  pwd.prTransferID = pw.prTransferID 
			left join prMaster pr on pwd.prMasterID = pr.prMasterID
			where pw.screenno = 1 
			and pwd.ReceivedDate is null and pwd.toBinId is null and pw.prFromWareHouseID = _prWarehouseID
			group by pwd.prMasterID
			order by pwd.prTransferDetailID desc  ;
            
		end if;
            

END$$

DELIMITER ;



-- =============================================
-- call INV_createPickTicket('CREATE',95534);
-- call INV_createPickTicket('INVOICE',94992);
-- call INV_createPickTicket('VOID',94992);

DROP procedure IF EXISTS `INV_createPickTicket`;

DELIMITER $$
CREATE DEFINER=`root`@`%` PROCEDURE `INV_createPickTicket`(
IN _action varchar(25),
IN _cuSOID INT
)
INV_createPickTicket: BEGIN

DECLARE _ids    text;
DECLARE _id    INT;
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
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
-- DECLARE _prePickBackorderd decimal(19,4);
DECLARE _promised decimal(19,4);
DECLARE _binAllocated decimal(19,4);
DECLARE _availableToPick decimal(19,4);
DECLARE _backOrdered decimal(19,4);
DECLARE _InventoryOnHand decimal(19,4);
DECLARE _quantityDesired decimal(19,4);
DECLARE _amountAvailableToPickFrom decimal(19,4);


	if(_action = 'CREATE') THEN
		
        select cuSOID into _foundID from cuSO where cuSOID=_cuSOID;
        
        if (_foundID is null) THEN
			leave INV_createPickTicket;
        END IF;
        
        update cuSODetailTicket set ticketStatus=0, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;

			-- get printTicketNumber
			select count(*)  INTO _printID from cuSODetailTicket where cuSOID=_cuSOID;

			-- get list of inventory items

			select GROUP_CONCAT(cb.cuSODetailBinID) 
            into _ids
            from cuSODetail d
            left join cuSODetailBin cb on (cb.cuSODetailID = d.cuSODetailID)
            left join prMaster p on (p.prMasterID = d.prMasterID)
            where d.cuSOID=_cuSOID and p.isInventory=1;

-- select _ids;

		 do_this:
		   LOOP
				set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);



set _QuantityOrdered=0;
set _QuantityBilled=0;
-- set _prePickBackorderd=0;
set _promised=0;
set _binAllocated=0;
set _availableToPick=0;
set _backOrdered=0;
set _InventoryOnHand=0;
set _quantityDesired =0;
set _amountAvailableToPickFrom =0;


select cuSOID,cuSODetailID,cuSODetailBinID,binId,prMasterID,prFromWarehouseID,binName,
ItemCode,Description,QuantityOrdered,QuantityBilled,
-- prePickBackorderd,
IFNULL(promised,0),binAllocated,
-- (CASE WHEN (binAllocated-QuantityBilled) <= (InventoryOnHand - promised) THEN  (binAllocated-QuantityBilled) ELSE (InventoryOnHand - IFNULL(promised,0)) END) AS availableToPick,
-- (CASE WHEN (binAllocated-QuantityBilled) <= (InventoryOnHand - promised) THEN  0 ELSE (QuantityOrdered - (InventoryOnHand - IFNULL(promised,0))) END) AS backOrdered,
InventoryOnHand
INTO
_cuSOID,_cuSODetailID,_cuSODetailBinID,_binId,_prMasterID,_prFromWarehouseID,_binName,
_ItemCode,_Description,_QuantityOrdered,_QuantityBilled,
-- _prePickBackorderd,
_promised,_binAllocated,
-- _availableToPick,_backOrdered,
_InventoryOnHand
from 
(	
SELECT 
    detail.cuSOID, sodb.cuSODetailBinID, detail.cuSODetailID, sodb.binId, sodb.allocated, 
    detail.Description ,p.ItemCode, detail.QuantityOrdered,
    IFNULL(detail.QuantityBilled,0) AS QuantityBilled,
-- 	(CASE WHEN ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) <= b.InventoryOnHand THEN  ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) ELSE  b.InventoryOnHand END) AS availableToInvoice,
-- 	(CASE WHEN ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) - b.InventoryOnHand < 0 THEN 0 ELSE ((sodb.allocated-detail.QuantityBilled)-(sodb.QuantityBilled-detail.QuantityBilled)) - b.InventoryOnHand END) AS prePickBackorderd,	
	(select sum(t.toPick) from cuSODetailTicket t where t.binId = b.binId and t.ticketStatus=1) as promised,
	-- (sodb.allocated - b.InventoryOnHand) as backOrdered,
	sodb.allocated as binAllocated, b.InventoryOnHand,  b.searchName AS binName, p.prMasterID, so.prFromWarehouseID, p.IsInventory
    FROM cuSODetailBin sodb  
     LEFT JOIN cuSODetail detail on (detail.cuSODetailID = sodb.cuSODetailID) 
    LEFT JOIN cuSO so ON (so.cuSOID = detail.cuSOID)
   
	 -- LEFT JOIN cuSODetailBin sodb ON (detail.cuSODetailID = sodb.cuSODetailID) 
	LEFT JOIN `bin` b ON (b.binId = sodb.binId)
    LEFT JOIN prMaster p ON (p.prMasterID = detail.prMasterID)
    -- left join cuSODetailTicket t on (t.cuSODetailID = sodb.cuSODetailID)

	WHERE sodb.cuSODetailBinID = _id) rawData;

	-- o=10  b=4 (6)   I=3  p=2  get=1
	
	set _quantityDesired = (_QuantityOrdered -  _QuantityBilled);
    set _amountAvailableToPickFrom = (case when _InventoryOnHand - _promised <0 THEN 0 ELSE _InventoryOnHand - _promised END);
    
    set _availableToPick = (case when _quantityDesired <= _amountAvailableToPickFrom THEN _quantityDesired ELSE _amountAvailableToPickFrom END);
    set _backOrdered = _quantityDesired - _availableToPick;
   

-- select * from cuSODetailTicket t where t.binId = _binId and t.ticketStatus=1;  
/*    
     select _cuSOID,_cuSODetailID,_cuSODetailBinID,_binId,_prMasterID,_prFromWarehouseID,_binName,
 _ItemCode,_Description,_QuantityOrdered,_QuantityBilled,
 -- _prePickBackorderd,
 _promised,_binAllocated,
 _availableToPick,_backOrdered,_InventoryOnHand;
*/	
    if (_binId is not null) THEN 

		insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
		values (_printID,_cuSOID,_cuSODetailID,1,_availableToPick,_QuantityOrdered,_backOrdered,_promised,_InventoryOnHand,_ItemCode,_Description,_binName,_binId);
			-- write record
		-- insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
        -- values (_printID, _cuSOID,_cuSODetailID,1,_availableToPick,_QuantityOrdered,_backOrdered,_promised,_InventoryOnHand,_ItemCode,_Description,_binName,_binId);
 
	END IF;
    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
            
	ELSEif(_action = 'INVOICE') THEN
		update cuSODetailTicket set ticketStatus=2, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;
	
	ELSEif(_action = 'VOID') THEN
		update cuSODetailTicket set ticketStatus=0, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;

	ELSEif(_action = 'DELETE') THEN
		select count(*) as count from  cuSODetailTicket  where cuSOID=_cuSOID and ticketStatus=1;
	
	END IF;

END$$

DELIMITER ;

-- ===================================================================

/* this procedure no longer valid - latest procedure is in tp_auditinventory

DROP procedure IF EXISTS `INV_createPickTicket_v2`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_createPickTicket_v2`(
IN _action varchar(25),
IN _cuSOID INT,
IN _DEBUG INT
)
INV_createPickTicket_v2 : BEGIN

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
DECLARE _availableToPick decimal(19,4);
DECLARE _backOrdered decimal(19,4);
DECLARE _InventoryOnHand decimal(19,4);
DECLARE _InventoryAllocated decimal(19,4);
DECLARE _quantityDesired decimal(19,4);
DECLARE _amountAvailableToPickFrom decimal(19,4);
DECLARE _binCount INT;


DECLARE _cuSODetailIDs varchar(2000);
DECLARE _notEnoughInventory TINYINT;
DECLARE _multiBinAllocationIssue TINYINT;
DECLARE _sumSODetailBinAllocated decimal(19,4);

if(_action = 'CREATE') THEN
	
        select cuSOID into _foundID from cuSO where cuSOID=_cuSOID;
        
        if (_foundID is null) THEN
			leave INV_createPickTicket_v2;
        END IF;

		-- clean up any tickets that should not be considered
		update  cuSODetailTicket t
		left join cuSODetail d on (d.cuSODetailID = t.cuSODetailId )
		 set t.ticketStatus=2  
		where t.ticketStatus=1 and d.QuantityOrdered = d.QuantityBilled;


		-- catch any open tickets that should be closed
		update  cuSODetailTicket t
		left join cuSODetail d on (d.cuSODetailID = t.cuSODetailId )
		set t.ticketStatus=2  
		where t.ticketStatus=1 and (d.QuantityOrdered = d.QuantityBilled );

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

		 if (_DEBUG=1) THEN select _cuSOID, _cuSODetailIDs as cuSODetailIDs; END IF;
         
		 do_cusodetailids:
		   LOOP
				set _cuSODetailID = null;
				SET strLen = CHAR_LENGTH(_cuSODetailIDs);
				set _cuSODetailID=SUBSTRING_INDEX(_cuSODetailIDs, ',', 1);

			
			-- test if bin recomendation matches quantity ordered
			select sum(sob.allocated), d.QuantityOrdered, d.prMasterID 
            into _sumSODetailBinAllocated, _QuantityOrdered, _prMasterID
            from cuSODetailBin sob
			left join cuSODetail d on (d.cuSODetailID = sob.cuSODetailID)
			where d.cuSODetailID = _cuSODetailID;

			-- test if allocated >= oh for bin seq>1
			-- check if any issues with soDetailBin.allocated to oh recomendation
            -- an issue could be that there is not enough inventory as previous thought.
			select count(*) 
            into _multiBinAllocationIssue 
            from cuSODetailBin sob
			left join bin b on (sob.binId = b.binId)
			where sob.allocated > b.InventoryOnHand and sob.cuSODetailID = _cuSODetailID
            and b.binSequence>1;
			
			-- if mis match on allocations and ordered, then fix - some issue has caused this?
			if (_sumSODetailBinAllocated <> _QuantityOrdered or _multiBinAllocationIssue=1) then 
				if (_DEBUG=1) THEN select 'RUNNING PRFIX',_prMasterID as prMasterIDFixed,_sumSODetailBinAllocated,_QuantityOrdered,_multiBinAllocationIssue; END IF;
				call AUDIT_inventory('PRFIX',1,_prMasterID,null,null,null,null,null,null);
			end if;

			-- determine how much is already promosed from earlier tickets.

			select count(*) 
            into _notEnoughInventory 
            from cuSODetailBin sob
			left join bin b on (sob.binId = b.binId)
			where sob.allocated > b.InventoryOnHand and sob.cuSODetailID = _cuSODetailID;

			-- if no issue, then do a straight ticket insert - easiest case
			if (_notEnoughInventory = 0) then 

				if (_DEBUG=1) THEN select 'Allocations less bin inventory - simple insert',_cuSODetailID,_prMasterID; END IF;
							
				set _promised =0; -- since inventory available to allocated
                
				insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,
                ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
                select _printID,_cuSOID,_cuSODetailID,1,(sob.allocated-sob.QuantityBilled),
                cd.QuantityOrdered,0,_promised, b.InventoryOnHand,pr.ItemCode,cd.Description,b.searchName,b.binId
                from cuSODetailBin sob
                left join cuSODetail cd on (cd.cuSODetailID = sob.cuSODetailID)
                left join bin b on (b.binId = sob.binId)
                left join prMaster pr on (pr.prMasterID = cd.prMasterID)
                where cd.cuSODetailID = _cuSODetailID 
                and cd.QuantityOrdered <> cd.QuantityBilled;
    
			ELSE 

				set _promised =0; -- since inventory available to allocated
            
				if (_DEBUG=1) THEN select 'Allocation greater than oh',_cuSODetailID,_prMasterID; END IF;
				
                -- 1. assumption is not enough inventory on bin #1
                -- insert for all sodetailbins
				insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,
                toPick,
                ordered,
                backOrdered,
                alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
                select _printID,_cuSOID,_cuSODetailID,1,
                IF ( ((sob.allocated-sob.QuantityBilled)-b.InventoryOnHand)<0, (sob.allocated-sob.QuantityBilled),b.InventoryOnHand),
                cd.QuantityOrdered, 
                IF ( ((sob.allocated-sob.QuantityBilled)-b.InventoryOnHand)>0, ((sob.allocated-sob.QuantityBilled)-b.InventoryOnHand),0),
                0, b.InventoryOnHand,pr.ItemCode,cd.Description,b.searchName,b.binId
                from cuSODetailBin sob
                left join cuSODetail cd on (cd.cuSODetailID = sob.cuSODetailID)
                left join bin b on (b.binId = sob.binId)
                left join prMaster pr on (pr.prMasterID = cd.prMasterID)
                where cd.cuSODetailID = _cuSODetailID
                and cd.QuantityOrdered <> cd.QuantityBilled;
                
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

		if (_DEBUG=1) THEN select 'before adjustment', _tickets, t.* from cuSODetailTicket t where cuSOID = _cuSOID and ticketStatus=1; END IF;

		 do_tickets:
		   LOOP
				set _pickTicketId = null;
				SET strLen = CHAR_LENGTH(_tickets);
				set _pickTicketId=SUBSTRING_INDEX(_tickets, ',', 1);

				set _promised=0;
                set _backOrdered=0;
                set _availableToPick=0;
                
				select binId into _binId from cuSODetailTicket where pickTicketId=_pickTicketId;

				select ifnull(sum(toPick),0) into _promised from cuSODetailTicket where binId =_binId and ticketStatus=1 and pickTicketId<_pickTicketId;

				select toPick, inventoryOHAtTime into _availableToPick,_InventoryOnHand from cuSODetailTicket where pickTicketId=_pickTicketId;
                
				if ( (_promised + _availableToPick) > _InventoryOnHand) then 
					set _backOrdered = (_promised + _availableToPick) - _InventoryOnHand;
					set _availableToPick = _availableToPick - _backOrdered;
                    if (_availableToPick<0) THEN set _availableToPick=0; END IF;
				else
                select toPick,ordered into @toPick,@ordered from cuSODetailTicket where pickTicketId=_pickTicketId;
					set _backOrdered = @toPick - @ordered;
				end if;
                
				update cuSODetailTicket set toPick=_availableToPick,
                -- backOrdered = _backOrdered,
                alreadyPromised=_promised where pickTicketId=_pickTicketId;

				if (_DEBUG=1) THEN select 'after adjustment', _promised,_availableToPick,_backOrdered,_InventoryOnHand,_binId ; END IF;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_tickets, ',', 1))+2;
				SET _tickets = MID(_tickets, SubStrLen, strLen);
				IF (_tickets = '' or _tickets is null) THEN
				   LEAVE do_tickets;
				END IF;
                    
			END LOOP do_tickets; 
	
	if (_DEBUG=1) THEN select t.* from cuSODetailTicket t where ticketStatus=1; END IF;


ELSEif(_action = 'CREATE_OLD') THEN

        select cuSOID into _foundID from cuSO where cuSOID=_cuSOID;
        
        if (_foundID is null) THEN
			leave INV_createPickTicket_v2;
        END IF;
        
        update cuSODetailTicket set ticketStatus=0, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;

			
			select count(*)  INTO _printID from cuSODetailTicket where cuSOID=_cuSOID;

			

			select GROUP_CONCAT(d.cuSODetailID) 
            into _ids
            from cuSODetail d
            left join cuSO cu   on (d.cuSOID = cu.cuSOID)
            left join prMaster p on (p.prMasterID = d.prMasterID)
            where d.cuSOID=_cuSOID and p.isInventory=1;



		 do_this:
		   LOOP
				set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);



set _QuantityOrdered=0;
set _QuantityBilled=0;

set _promised=0;
set _binAllocated=0;
set _availableToPick=0;
set _backOrdered=0;
set _InventoryOnHand=0;
set _InventoryAllocated = 0;
set _quantityDesired =0;
set _amountAvailableToPickFrom =0;
set _binCount = 0;
				
                select cu.prFromWarehouseID,cd.prMasterID,cd.QuantityOrdered,cd.QuantityBilled,cu.cuSOID,pr.ItemCode,cd.Description
                into _prFromWarehouseID,_prMasterID,_QuantityOrdered,_QuantityBilled,_cuSOID,_ItemCode,_Description
                from cuSO cu 
                left join cuSODetail cd on (cd.cuSOID = cu.cuSOID)
                left join prMaster pr on (pr.prMasterID = cd.prMasterID)
                where cd.cuSODetailID = _id ;
                
                select count(*) into _binCount  from bin where prWarehouseID = _prFromWarehouseID and prMasterID = _prMasterID;
                
                if (_binCount = 1) then 
					
						select binId,InventoryOnHand,InventoryAllocated,searchName
						into _binId,_InventoryOnHand,_InventoryAllocated,_binName
						from bin where prWarehouseID = _prFromWarehouseID and prMasterID = _prMasterID;
						
						
						select ifnull(sum(toPick),0) into _promised from cuSODetailTicket  where binId = _binId and ticketStatus=1;
						
						set _quantityDesired = _QuantityOrdered - _QuantityBilled;
						set _amountAvailableToPickFrom = (case when _InventoryOnHand - _promised <0 THEN 0 ELSE _InventoryOnHand - _promised END);
						
						set _availableToPick = (case when _quantityDesired <= _amountAvailableToPickFrom THEN _quantityDesired ELSE _amountAvailableToPickFrom END);
						set _backOrdered = _quantityDesired - _availableToPick;
						
							if (_binId is not null) THEN 

								insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
								values (_printID,_cuSOID,_id,1,_availableToPick,_QuantityOrdered,_backOrdered,_promised,_InventoryOnHand,_ItemCode,_Description,_binName,_binId);
								
							END IF;
					else
                
							select binId,InventoryOnHand,InventoryAllocated,searchName
						    into _binId,_InventoryOnHand,_InventoryAllocated,_binName 
                            from bin where prWarehouseID = _prFromWarehouseID and prMasterID = _prMasterID and binSequence = 1;
                            
                            select ifnull(sum(toPick),0) into _promised from cuSODetailTicket  where binId = _binId and ticketStatus=1;
                            
                            set _quantityDesired = _QuantityOrdered - _QuantityBilled;
                            
                            set _amountAvailableToPickFrom =  _InventoryOnHand - _promised;
                            
                            if(_amountAvailableToPickFrom >= _quantityDesired) then 
                           
									set _availableToPick = _quantityDesired;
									set _backOrdered = 0;
									
									if (_binId is not null) THEN 

										insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
										values (_printID,_cuSOID,_id,1,_availableToPick,_QuantityOrdered,_backOrdered,_promised,_InventoryOnHand,_ItemCode,_Description,_binName,_binId);
										
									END IF;
                            
                            else
									
									set _quantityDesired = _QuantityOrdered - _QuantityBilled;
									select GROUP_CONCAT(binId)  into _bids
                                    from bin where prWarehouseID = _prFromWarehouseID and prMasterID = _prMasterID;
                                    
                                    
									do_that:
										LOOP
											set _bid = null;
                                            
											SET bstrLen = CHAR_LENGTH(_bids);
											set _bid=SUBSTRING_INDEX(_bids, ',', 1);
                                           
                                           
												if(_quantityDesired > 0) then 
											
												select binId,InventoryOnHand,InventoryAllocated,searchName
												into _binId,_InventoryOnHand,_InventoryAllocated,_binName 
												from bin where binId = _bid;
												
												select ifnull(sum(toPick),0) into _promised from cuSODetailTicket  where binId = _bid and ticketStatus=1;
                                               
                                                set _amountAvailableToPickFrom = (case when _InventoryOnHand - _promised <0 THEN 0 ELSE _InventoryOnHand - _promised END);
                                                
                                                set _availableToPick = (case when _quantityDesired <= _amountAvailableToPickFrom THEN _quantityDesired ELSE _amountAvailableToPickFrom END);
                                               
                                                
                                                if(_availableToPick > 0) then 
                                                
													if (_bid is not null) THEN 
                                                    
											
														insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
														values (_printID,_cuSOID,_id,1,_availableToPick,_QuantityOrdered,0,_promised,_InventoryOnHand,_ItemCode,_Description,_binName,_bid);
										
													END IF;
												
												end if;
                                                
                                                set _quantityDesired =  _quantityDesired - _availableToPick;
                                                end if;
                                                

                            
										SET bSubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_bids, ',', 1))+2;
										SET _bids = MID(_bids, bSubStrLen, bstrLen);
										IF (_bids = '' or _bids is null) THEN
											LEAVE do_that;
										END IF;
											
									END LOOP do_that;
                                    
                                   if(_quantityDesired > 0) then 
                                                
													select binId,InventoryOnHand,InventoryAllocated,searchName
													into _binId,_InventoryOnHand,_InventoryAllocated,_binName 
													from bin where prWarehouseID = _prFromWarehouseID and prMasterID = _prMasterID 
                                                    and binSequence = 1;
                                                    
                                                    select count(*) into _foundID from cuSODetailTicket  where binId = _binId and cuSOID = _cuSOID
                                                    and cuSODetailId = _id and ticketStatus=1;
                                                    select ifnull(sum(toPick),0) into _promised from cuSODetailTicket  where binId = _binId and ticketStatus=1;
                                                    if(_foundID = 0) then 
                                                    
														if (_binId is not null) THEN 

															insert into cuSODetailTicket (printNumber,cuSOID,cuSODetailId,ticketStatus,toPick,ordered,backOrdered,alreadyPromised,inventoryOHAtTime,ItemCode,Description,binName,binId)
															values (_printID,_cuSOID,_id,1,0,_QuantityOrdered,_quantityDesired,_promised,_InventoryOnHand,_ItemCode,_Description,_binName,_binId);
											
														END IF;
													else 
															update cuSODetailTicket set backOrdered = _quantityDesired where binId = _binId and cuSOID = _cuSOID
                                                    and cuSODetailId = _id and ticketStatus=1;
													end if;
                                                
                                                end if;
                            
                            end if;
                    
					end if;



    
				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
            
	ELSEif(_action = 'INVOICE') THEN
		update cuSODetailTicket set ticketStatus=2, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;
	
	ELSEif(_action = 'VOID') THEN
		update cuSODetailTicket set ticketStatus=0, lastUpdated=now() where cuSOID=_cuSOID and ticketStatus=1;

	ELSEif(_action = 'DELETE') THEN
		UPDATE cuSODetailTicket  SET ticketStatus = 2 where cuSODetailId = _cuSOID and ticketStatus=1;
	
	END IF;

END$$

DELIMITER ;
*/



-- ==================================================================
-- call GL_findIssues('veBill-AmountToGLMismatch','2020-05-31',null,200);
-- call GL_findIssues('cuInvoice-RecordsToInvestigate','2020-08-01',null,null);
-- call GL_findIssues('cuInvoice-NullArHistory records','2020-08-01',null,null);
-- call GL_findIssues('openSalesOrders',null,null,null);
-- call GL_findIssues('VendorBillsNotMatchingGL',null,null,null);


DROP procedure IF EXISTS `GL_findIssues`;

DELIMITER $$
CREATE  PROCEDURE GL_findIssues(
IN _action VARCHAR(100),
IN _veBillDateStart varchar(100),
IN _veBillDateEnd varchar(100),
IN _coAccountID int
)
GL_findIssues: BEGIN

if (_action ='veBill-AmountToGLMismatch') then

	-- needs more work
    
	select (raw.BillAmount - ifnull(raw.GL,0)) as totalIssueAmount, ifnull(raw.raw.GL,'No GL') as GlMissing,  raw.* from
	( 
	select b.veBillID, b.createdOn, b.BillDate, b.BillAmount, l.Amount as appliedAmount, l.Discount, t.TransactionDate, t.Amount as bankAmount, 
	(
	SELECT sum(credit)-sum(debit) FROM 
	glTransaction LEFT JOIN glLinkage ON(glTransaction.glTransactionId=glLinkage.glTransactionId)
	WHERE 
	coAccountId=_coAccountID 
	-- AND journalId IN('VB') 
	and veBillId=b.veBillID
	AND transactionDate>STR_TO_DATE(_veBillDateStart,'%Y-%m-%d')
	) as 'GL',
	t.uniquechkRef,t.status,t.memo,t.void, b.Void as veBillVoid
	from veBill b
	left join moLinkageDetail l on (l.veBillID = b.veBillID)
	left join moTransaction t on (l.moTransactionID = t.moTransactionID)
	 where  b.createdOn >STR_TO_DATE(_veBillDateStart,'%Y-%m-%d') or b.BillDate>STR_TO_DATE(_veBillDateStart,'%Y-%m-%d')
	 -- order by b.veBillID,l.moTransactionID;
	 ) raw
	where (raw.BillAmount - ifnull(raw.GL,0))<>0;

ELSEIF (_action ='cuInvoice-RecordsToInvestigate') THEN

	select cuInvoiceID,InvoiceNumber,InvoiceAmount,glSum,glDebit,glCredit,glRecordsFound
	from
	(select i.cuInvoiceID, i.InvoiceNumber, i.InvoiceAmount,
	( 
	select count( * ) from glTransaction t 
	left join glLinkage l on (l.glTransactionID= t.glTransactionID)
	where t.journalId='CI' and l.veBillID = cuInvoiceID
	) as glRecordsFound,
	( 
	select sum(credit)-sum(debit) from glTransaction t 
	left join glLinkage l on (l.glTransactionID= t.glTransactionID)
	where t.journalId='CI' and l.veBillID = cuInvoiceID
	) as glSum,
	ifnull(( 
	select t.debit from glTransaction t 
	left join glLinkage l on (l.glTransactionID= t.glTransactionID)
	where t.journalId='CI' and l.veBillID = cuInvoiceID and t.debit=abs(InvoiceAmount) limit 1
	),0) as glDebit,
	ifnull(( 
	select t.credit from glTransaction t 
	left join glLinkage l on (l.glTransactionID= t.glTransactionID)
	where t.journalId='CI' and l.veBillID = cuInvoiceID and t.credit=abs(InvoiceAmount) limit 1
	),0) as glCredit
	from cuInvoice i 
	where i.InvoiceDate>STR_TO_DATE(_veBillDateStart,'%Y-%m-%d') 
	) raw
	where glRecordsFound=0 and InvoiceAmount <>0 or ( abs(InvoiceAmount) <> glDebit and abs(InvoiceAmount) <> glCredit)
	-- where raw.cuInvoiceID =302720
	order by raw.cuInvoiceID;

	-- 	302661	CJU200612A2	-225.0000	0.0000			2
	-- 	302720	EJS200708A1	900.0000	0.0000			7

ELSEIF (_action ='cuInvoice-NullArHistory records') THEN

    
    select a.*,c.* 
    from arhistory a 
	left join cuInvoice c on (c.cuInvoiceID = a.cuInvoiceID) 
	where a.createdOn is null 
    order by a.cuInvoiceID desc;


ELSEIF (_action ='openSalesOrders') THEN

	select p.ItemCode, p.IsInventory, p.prMasterID, so.prFromWarehouseID, so.cuSOID, s.cuSODetailID, so.SONumber, 
	so.OrderDate, so.CreatedOn,  
	s.QuantityOrdered as SO_QuantityOrdered, s.QuantityBilled as SO_QuantityBilled,
	sob.allocated as SODETAILBIN_QuantityOrdered, sob.QuantityBilled SODETAILBIN_QuantityBilled,
	sob.binId, b.InventoryAllocated as BIN_Allocated,
	id.QuantityBilled as InvoiceDetailQuantityBilled, id.cuInvoiceDetailID
	-- ,inv.cuInvoiceID
	from cuSODetail s
	left join cuSO so on (so.cuSOID = s.cuSOID)
	left join prMaster p on (p.prMasterID = s.prMasterID)
	left join cuSODetailBin sob on (sob.cuSODetailID = s.cuSODetailID)
	left join bin b on (b.binId = sob.binId)
	left join cuInvoiceDetail id on (id.cuSODetailID = s.cuSODetailID)
	-- left join cuInvoice inv on (inv.cuSOID = s.cuSOID)
	where s.QuantityOrdered<> s.QuantityBilled
	and p.prMasterID not in (19,2) and p.IsInventory=1 and so.TransactionStatus=1 
	-- and p.prMasterID=280 and so.prFromWarehouseID=2
	-- order by so.CreatedOn desc;
	order by p.ItemCode desc;

ELSEIF (_action ='VendorBillsNotMatchingGL') THEN

	select b.veBillID, b.InvoiceNumber, b.BillDate, b.TransactionStatus, Max(BillAmount) as BillAmount, Max(AppliedAmount) as AppliedAmount, sum(t.debit)-sum(t.credit) as GLNotZero
	from veBill b
	left join glLinkage l on (l.veBillID = b.veBillID)
	left join glTransaction t on (l.glTransactionID = t.glTransactionID)
	where
	t.journalId='VB'
	-- and b.veBillID=119087
	group by b.veBillID
	having sum(t.debit)-sum(t.credit) <> 0
	order by b.veBillID desc;

END IF;

END$$


DELIMITER ;


/*  MOVED TO tp_fix_tool.sql script

-- ==================================================================
-- openSalesOrders will add up all cuSODetailID's for a prMasterID and prWarehouseID
--    and update the bin with the correct allocated amount
--
-- call FIX_tool('openSalesOrders',280,2, 'REVIEW_FIRST'); -- 'REVIEW_FIRST or COMMIT'
-- ==================================================================

DROP procedure IF EXISTS `FIX_tool`;

DELIMITER $$
CREATE  PROCEDURE FIX_tool(
IN _action VARCHAR(100),
IN _prMasterId INT,
IN _prWarehouseId INT,
IN _reviewChange varchar(100),
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
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;
DECLARE _inventories text;
DECLARE _salesOrderBinAlloc decimal(19,4);
DECLARE _transferAllocated decimal(19,4);
	

if (_action ='openSalesOrders') then

	select count(*) into _binNumber from bin where prMasterID= _prMasterId and prWarehouseID = _prWarehouseId;
    
    if (_binNumber>1) THEN
		select 'MULTIPLE BINS FOUND', _binNumber,_prMasterId,_prWarehouseId, 'RESEARCH BEFOR CONTINUING';
        select group_concat(binId) into  _inventories from bin where prMasterID= _prMasterId and prWarehouseID = _prWarehouseId;
        do_this:
		   LOOP
		 
		 SET strLen = CHAR_LENGTH(_inventories);
								
		 set _binId=SUBSTRING_INDEX(_inventories, ',', 1);

		
		
       /*  select  (sum(csb.allocated) - sum(csb.QuantityBilled)) into _salesOrderBinAlloc
        from cuSODetailBin csb
        left join cuSODetail cs on (cs.cuSODetailID = csb.cuSODetailID)
		left join cuSO c on (c.cuSOID = cs.cuSOID)
        where 
        c.TransactionStatus = 1 and csb.allocated <> csb.QuantityBilled and
        csb.binId = _binId 
        ; */
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

	elseif (_action = 'AVERAGECOST') THEN
		
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
		
        /* select  (sum(csb.allocated) - sum(csb.QuantityBilled)) into _salesOrderBinAlloc
        from cuSODetailBin csb
        left join cuSODetail cs on (cs.cuSODetailID = csb.cuSODetailID)
		left join cuSO c on (c.cuSOID = cs.cuSOID)
        where 
        c.TransactionStatus = 1 and csb.allocated <> csb.QuantityBilled and
        csb.binId = _binId 
        ; */
        
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

*/


-- =============================================
DROP PROCEDURE IF EXISTS `sp_updateQuotesStatus`;
DELIMITER $$

CREATE  PROCEDURE `sp_updateQuotesStatus`(IN _action VARCHAR(50),IN _id INT,IN _description VARCHAR(50))
sp_updateQuotesStatus:BEGIN
IF (_action='UPDATE') THEN
	IF (_id IS NOT NULL AND _id >0) THEN
	  UPDATE joQuoteStatus SET description=_description WHERE id=_id;
	ELSE
	  INSERT INTO joQuoteStatus(id,description) VALUES(NULL,_description);
	END IF;
	SELECT "Success";
ELSEIF(_action='DELETE') THEN
	DELETE FROM joQuoteStatus WHERE id=_id;
	SELECT "Success";
ELSEIF(_action='AllLIST') THEN
	SELECT * FROM joQuoteStatus;
ELSEIF(_action='FINDBYID') THEN
	SELECT * FROM joQuoteStatus WHERE id=_id;
END IF;
END$$

DELIMITER ;

-- =============================================
-- =============================================
DROP PROCEDURE IF EXISTS `sp_updateQuotesSellingType`;
DELIMITER $$
CREATE  PROCEDURE `sp_updateQuotesSellingType`(IN _action VARCHAR(50),IN _id INT,IN _description VARCHAR(50))
sp_updateQuotesSellingType:BEGIN
IF (_action='UPDATE') THEN
	IF (_id IS NOT NULL AND _id >0) THEN
	  UPDATE joQuoteSellingType SET description=_description WHERE id=_id;
	ELSE
	  INSERT INTO joQuoteSellingType(id,description) VALUES(NULL,_description);
	END IF;
	SELECT "Success";
ELSEIF(_action='DELETE') THEN
	DELETE FROM joQuoteSellingType WHERE id=_id;
	SELECT "Success";
ELSEIF(_action='AllLIST') THEN
	SELECT * FROM joQuoteSellingType;
ELSEIF(_action='FINDBYID') THEN
	SELECT * FROM joQuoteSellingType WHERE id=_id;
END IF;
END$$

DELIMITER ;

-- =============================================
DROP PROCEDURE IF EXISTS `getCustomerAddress`;
DELIMITER $$

CREATE PROCEDURE `getCustomerAddress`(rxCustomerID INT(11))
BEGIN
DECLARE Mailing INT;
DECLARE isShipToAddress TINYINT;
DECLARE isBillToAddress TINYINT;
DECLARE DefaultAddress INT;
DROP TEMPORARY TABLE IF EXISTS tmpar;
SET isBillToAddress  = 1;
SET Mailing = (SELECT COUNT(*) FROM rxAddress WHERE IsMailing = 1 AND rxMasterID = rxCustomerID);

CREATE TEMPORARY TABLE tmpar(NAME VARCHAR(80),Address1 VARCHAR(40),Address2 VARCHAR(40),
city VARCHAR(50),State VARCHAR(50),Zip VARCHAR(50),rxAddressId INT(11),coTaxTerritoryID INT(11),
IsBillTo TINYINT,IsShipTo TINYINT,IsMailing TINYINT);
IF(Mailing = 1)
THEN
INSERT INTO tmpar 
(SELECT rxmaster.Name,address.Address1,address.Address2,address.city,address.State,address.Zip,
				address.rxAddressId,cotax.coTaxTerritoryID, isBillToAddress AS IsBillTo ,address.IsShipTo
                ,address.IsMailing FROM rxMaster rxmaster 
				LEFT JOIN rxAddress address ON address.rxMasterID = rxmaster.rxMasterID 
				LEFT JOIN cuMaster cumaster ON cumaster.cuMasterID = rxmaster.rxMasterID 
				LEFT JOIN coTaxTerritory cotax ON address.coTaxTerritoryID = cotax.coTaxTerritoryID 
				WHERE rxmaster.Name IS NOT NULL AND address.IsMailing = 1 AND rxmaster.rxMasterID = rxCustomerID);
ELSE 
SET DefaultAddress = (SELECT COUNT(*) FROM rxAddress WHERE IsDefault = 1 AND rxMasterID = rxCustomerID);
IF(DefaultAddress = 1)
THEN
SELECT rxmaster.Name,address.Address1,address.Address2,address.city,address.State,address.Zip,
				address.rxAddressId,cotax.coTaxTerritoryID,isBillToAddress AS IsBillTo,address.IsShipTo,address.IsMailing FROM rxMaster rxmaster 
				LEFT JOIN rxAddress address ON rxmaster.rxMasterID = address.rxMasterID
				LEFT JOIN cuMaster cumaster ON rxmaster.rxMasterID = cumaster.cuMasterID 
				LEFT JOIN coTaxTerritory cotax ON address.coTaxTerritoryID = cotax.coTaxTerritoryID 
				WHERE rxmaster.Name IS NOT NULL AND address.IsDefault = 1 AND rxmaster.rxMasterID = rxCustomerID;
ELSE
SELECT rxmaster.Name,address.Address1,address.Address2,address.city,address.State,address.Zip,
				address.rxAddressId,cotax.coTaxTerritoryID, isBillToAddress AS IsBillTo,address.IsShipTo,isBillToAddress AS IsDefault FROM rxMaster rxmaster 
				LEFT JOIN rxAddress address ON rxmaster.rxMasterID = address.rxMasterID 
				LEFT JOIN cuMaster cumaster ON rxmaster.rxMasterID = cumaster.cuMasterID 
				LEFT JOIN coTaxTerritory cotax ON address.coTaxTerritoryID = cotax.coTaxTerritoryID 
				WHERE rxmaster.Name IS NOT NULL AND rxmaster.rxMasterID = rxCustomerID;
END IF;                
END IF;
SET isShipToAddress = (SELECT IsShipTo FROM tmpar);
IF(isShipToAddress = 0)
THEN
SELECT * FROM tmpar
UNION ALL
SELECT rxmaster.Name,address.Address1,address.Address2,address.city,address.State,address.Zip,
				address.rxAddressId,cotax.coTaxTerritoryID, isBillToAddress AS IsBillTo ,address.IsShipTo
                ,address.IsMailing FROM rxMaster rxmaster 
				LEFT JOIN rxAddress address ON rxmaster.rxMasterID = address.rxMasterID 
				LEFT JOIN cuMaster cumaster ON rxmaster.rxMasterID = cumaster.cuMasterID 
				LEFT JOIN coTaxTerritory cotax ON address.coTaxTerritoryID = cotax.coTaxTerritoryID 
				WHERE rxmaster.Name IS NOT NULL AND address.IsShipTo = 1 AND rxmaster.rxMasterID = rxCustomerID;
ELSE 
SELECT * FROM tmpar;
END IF;
END$$

DELIMITER ;

-- =============================================

DROP PROCEDURE IF EXISTS `Project_InvoiceCostDetail`;
DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `Project_InvoiceCostDetail`(IN rxCustomerId INT,IN salesRepId INT,IN fromDate VARCHAR(50),IN toDate VARCHAR(50),IN `sortBy` VARCHAR(100))
BEGIN
/*SET @l_sql = 'SELECT  DISTINCT
info_userLoginID AS salesRepId,tsu.FullName AS salesRepName,ci.cuInvoiceId,DATE_FORMAT(ci.InvoiceDate, "%m/%d/%Y") as InvoiceDate,JobNumber,
CAST(ReleaseTypes AS SIGNED) AS joReleaseType,ReleaseTypeDescription,ci.InvoiceNumber,ci.InvoiceAmount,
info_rxCustomerID,rxm.Name AS customerName,InvoiceCostStock AS stockCost,InvoiceCostDrop AS poCost,
(InvoiceSubTotal+InvoiceFreight) AS InvoiceAmountWOTax,
(InvoiceSubTotal+InvoiceFreight)-(InvoiceCostStock+InvoiceCostDrop) AS profit,
ifnull(ROUND(ROUND_TO_EVEN((((InvoiceSubTotal+InvoiceFreight)-(InvoiceCostStock+InvoiceCostDrop))/(InvoiceSubTotal+InvoiceFreight)*100),2),2),0) AS margin
 FROM SalesCommissionView scv 
       LEFT JOIN tsUserLogin tsu ON(scv.info_userLoginID=tsu.UserLoginID)
       LEFT JOIN cuInvoice ci ON(scv.info_cuInvoiceID=ci.cuInvoiceId)
       LEFT JOIN rxMaster rxm ON(scv.info_rxCustomerID=rxm.rxMasterID)
WHERE RecordType=\'Invoice\' ';*/
SET @l_sql = 'SELECT ci.cuAssignmentID0 AS salesRepId,tsu.FullName AS salesRepName,ci.cuInvoiceId,DATE_FORMAT(ci.InvoiceDate, "%m/%d/%Y") AS InvoiceDate,
		jm.JobNumber,IF(ReleaseType IS NOT NULL,CAST(ReleaseType AS SIGNED),NULL) AS joReleaseType,jrt.Description AS ReleaseTypeDescription,
		ci.InvoiceNumber,ci.InvoiceAmount,ci.rxCustomerID AS info_rxCustomerID,
		rxm.Name AS customerName,IFNULL(ci.`CostTotal`, 0) AS `stockCost`,
		IFNULL(vb.BillAmount,0) AS poCost,(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0)) AS InvoiceAmountWOTax,
		(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)) AS profit,
		IFNULL(ROUND(ROUND_TO_EVEN((((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)))/(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))*100),2),2),0) AS margin
		 FROM cuInvoice ci
		LEFT JOIN tsUserLogin tsu ON(ci.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(ci.rxCustomerID=rxm.rxMasterID)
		LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
		LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
		LEFT JOIN joMaster jm ON(jr.joMasterID=jm.joMasterID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
		 WHERE ci.cuAssignmentID0 IS NOT NULL and ci.cuAssignmentID0>0 ';
IF (rxCustomerId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.rxCustomerID=',rxCustomerId);
END IF;
IF (salesRepId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.cuAssignmentID0=',salesRepId);
END IF;
IF (fromDate IS NOT NULL AND fromDate<>'' AND (toDate IS NULL OR toDate='')) THEN
    SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
    SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate=\'',fromDate,'\'');
ELSE
	IF (fromDate IS NOT NULL AND fromDate<>'') THEN
		SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate>=\'',fromDate,' 00:00:00\'');
	END IF;
	IF (toDate IS NOT NULL AND toDate<>'') THEN
		SET toDate=DATE_FORMAT(toDate, "%Y-%m-%d");    
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate<=\'',toDate,' 23:59:59\'');
	END IF;
	
END IF;
		
        SET @l_sql=CONCAT(@l_sql,'union all   ');
        SET @l_sql=CONCAT(@l_sql,'SELECT jm.cuAssignmentID0 AS salesRepId,tsu.FullName AS salesRepName,vec.veCommDetailID,DATE_FORMAT(vec.CommDate, "%m/%d/%Y") AS InvoiceDate,
		jm.JobNumber,IF(ReleaseType IS NOT NULL,CAST(ReleaseType AS SIGNED),NULL) AS joReleaseType,jrt.Description AS ReleaseTypeDescription,
		vec.InvoiceNumber,vec.CommAmount as InvoiceAmount,jm.rxCustomerID AS info_rxCustomerID,
		rxm.Name AS customerName,0 AS `stockCost`,
		0 AS poCost,vec.CommAmount AS InvoiceAmountWOTax,
		vec.CommAmount -0-0 AS profit,
		 IFNULL(ROUND(ROUND_TO_EVEN((vec.CommAmount/vec.CommAmount)*100,2),2),0) AS margin
		 FROM joMaster jm
         LEFT JOIN joRelease jr ON(jm.joMasterID=jr.joMasterID)
         LEFT JOIN joReleaseDetail jrd ON(jr.joReleaseID=jrd.joReleaseID)
         LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
         left join veCommDetail vec on (vec.joReleaseDetailID = jrd.joReleaseDetailID)
		LEFT JOIN tsUserLogin tsu ON(jm.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(jm.rxCustomerID=rxm.rxMasterID)
		left join cuInvoice ci ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
		WHERE jm.cuAssignmentID0 IS NOT NULL and jm.cuAssignmentID0>0');
  IF (rxCustomerId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and jm.rxCustomerID=',rxCustomerId);
END IF;
IF (salesRepId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and jm.cuAssignmentID0=',salesRepId);
END IF;
IF (fromDate IS NOT NULL AND fromDate<>'' AND (toDate IS NULL OR toDate='')) THEN
    SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
    SET @l_sql=CONCAT(@l_sql,' and vec.CommDate=\'',fromDate,'\'');
ELSE
	IF (fromDate IS NOT NULL AND fromDate<>'') THEN
		SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
		SET @l_sql=CONCAT(@l_sql,' and vec.CommDate>=\'',fromDate,' 00:00:00\'');
	END IF;
	IF (toDate IS NOT NULL AND toDate<>'') THEN
		SET toDate=DATE_FORMAT(toDate, "%Y-%m-%d");    
		SET @l_sql=CONCAT(@l_sql,' and vec.CommDate<=\'',toDate,' 23:59:59\'');
	END IF;
	
END IF;
  
IF (sortBy='SalesRep') THEN
	SET @l_sql=CONCAT(@l_sql,' order by salesRepName asc,InvoiceDate'); -- salesRepId
ELSE
	SET @l_sql=CONCAT(@l_sql,' order by salesRepName asc,InvoiceDate'); -- info_rxCustomerID
END IF;
-- select @l_sql ;
PREPARE stmt FROM @l_sql;

EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;

-- =============================================
DROP PROCEDURE IF EXISTS `COMMISSION_SavePaidInvoicesFromSCV`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `COMMISSION_SavePaidInvoicesFromSCV`(IN _action  VARCHAR(50), IN _ecPeriodID  INT)
COMMISSION_SavePaidInvoicesFromSCV: BEGIN
	DECLARE v_done INT DEFAULT FALSE;
	DECLARE _RecordType VARCHAR(25);
	DECLARE _CustomerStatus VARCHAR(25);
	DECLARE _IsCommPaid VARCHAR(25);
	DECLARE _cuInvoiceId INT;
	DECLARE _CommAvailableDate DATETIME;
	DECLARE _InvoiceNumber VARCHAR (100);
	DECLARE _joReleaseType INT;
	DECLARE _info_rxCustomerID INT;
	DECLARE _InvoiceAmount DOUBLE;
	DECLARE _appliedAmount DOUBLE;
	DECLARE _CommPercent DOUBLE;
	DECLARE _AmountDue DOUBLE;
	DECLARE _info_userLoginID INT;
	DECLARE _PayType INT;
	DECLARE _StatementID INT;
	DECLARE _Info_ReleasedetailID INT;
	DECLARE _CalcRevShare DOUBLE;
	DECLARE _info_joReleaseID INT;
	DECLARE _joMasterID INT;
	DECLARE _info_veCommDetailID INT;
	DECLARE _veBillID INT;
	DECLARE _ecType VARCHAR(10);
	DECLARE _periodStartDate DATETIME;
	DECLARE _periodEndDate DATETIME;
	DECLARE _ecInvoicePeriodID INT;
	DECLARE _allowToCalculateCommission INT DEFAULT FALSE;
	DECLARE _isJobPaidInFull INT DEFAULT FALSE;
	DECLARE _isFollowingPeriod INT DEFAULT FALSE;
	DECLARE _customerPaidDate DATETIME;
	DECLARE _isCommAfterPayment INT DEFAULT FALSE;
	DECLARE _dayAfter INT;
	DECLARE _billingReminder DECIMAL(19,4);
	DECLARE _accountsReceivable DECIMAL(19,4);
	DECLARE _vendorCommBalance DECIMAL(19,4);
	DECLARE _lastcuinvoicePaiddate DATETIME ;
	DECLARE _maxInvoiceDate DATETIME ;
	DECLARE _revisedContract DECIMAL(19,4);
	DECLARE _invoiced DECIMAL(19,4);	
	DECLARE _info_joInvoiceCostID INT;
	DECLARE _invoiceDate DATETIME ;
	
	#cursors
	DECLARE cursorForCommission CURSOR FOR 
	SELECT DISTINCT RecordType,CustomerStatus,IsCommPaid,info_cuInvoiceID,CommAvailableDate,InvoiceNumber,
					CAST(ReleaseTypes AS SIGNED) AS joReleaseType,info_rxCustomerID,InvoiceAmount,CAST(CalcRawInvoiceProfit AS DECIMAL(19,4)) AS appliedAmount,CommPercent,
					CAST(CalcSplitRev AS DECIMAL(19,4)) AS AmountDue,
					info_userLoginID, (SELECT CommAfterPayment FROM emMaster WHERE UserLoginID = info_userLoginID LIMIT 1) AS PayType,
					login.StatementID,Info_ReleasedetailID,CAST(CalcRevShare AS DECIMAL(19,4)),info_joReleaseID, joMasterID, 
					 info_veCommDetailID, veBillID,isJobPaidInFull,isFollowingPeriod,CustomerPaidDate,CommAfterPayment,dayAfter,info_joInvoiceCostID,InvoiceDate  
			 FROM SalesCommissionView scv 
			 LEFT JOIN (SELECT ecstm.repLoginID AS repid,ecstm.ecStatementID 
					AS StatementID FROM  ecStatement ecstm WHERE ecstm.ecPeriodID =  _ecPeriodID ) AS login ON 
					login.repid = scv.info_userLoginID 
			 WHERE isCommPaid='no' AND CommAvailableDate <= _periodEndDate;
	#handlers
	  DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
	  /*DECLARE EXIT HANDLER FOR SQLEXCEPTION
	  BEGIN
	    ROLLBACK;
	    RESIGNAL;
	    SELECT 'ROLLBACK';
	  END;*/  
	  
	  IF ( _ecPeriodID IS NULL ) THEN 
	    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'call COMMISSION_SavePaidInvoicesFromSCV:_ecPeriodID not found';
		LEAVE COMMISSION_SavePaidInvoicesFromSCV; 
	  END IF;
	-- bringing period startdate and enddate
	SELECT DATE_ADD(PeriodEndingDate,INTERVAL 1 DAY) INTO _periodStartDate  FROM ecPeriod WHERE ecPeriodID<_ecPeriodID ORDER BY PeriodEndingDate DESC LIMIT 1;
	SELECT DATE_FORMAT(PeriodEndingDate,'%Y-%m-%d 23:59:59') INTO _periodEndDate FROM ecPeriod WHERE ecPeriodID=_ecPeriodID LIMIT 1;
	
	-- For  testing log
	SELECT _ecPeriodID,_periodStartDate, _periodEndDate;
	OPEN cursorForCommission;
  
  -- START TRANSACTION;
  read_loop: LOOP
  
    FETCH cursorForCommission INTO _RecordType,_CustomerStatus,_IsCommPaid,_cuInvoiceId,_CommAvailableDate,_InvoiceNumber,
                 _joReleaseType,_info_rxCustomerID,_InvoiceAmount, _appliedAmount,  _CommPercent,
                 _AmountDue,_info_userLoginID, _PayType, _StatementID, _Info_ReleasedetailID, _CalcRevShare, _info_joReleaseID, _joMasterID,
                 _info_veCommDetailID, _veBillID,_isJobPaidInFull,_isFollowingPeriod,_customerPaidDate,_isCommAfterPayment,_dayAfter,_info_joInvoiceCostID,_invoiceDate;
    -- SELECT 'step1', _isJobPaidInFull,_isCommAfterPayment,_invoiceDate,_dayAfter ;   
	  
--  Start Logic
IF (_RecordType IS NOT NULL) THEN
	IF (_RecordType<>'AddCost' && _RecordType<>'VendorExpense') THEN
		   IF (_isJobPaidInFull=1) THEN
			 IF (_joMasterID IS NOT NULL AND _joMasterID>0)THEN
				-- Inside job commission should calculate after all invoices paid in job 
				SELECT IFNULL(ContractAmount,0) +SUM(IFNULL(jC.ChangeAmount,0)) INTO _revisedContract FROM joMaster 
				LEFT JOIN joChange jC ON joMaster.joMasterid=jC.joMasterid 
				LEFT JOIN joChangeType jCT ON (jC.SellingType = jCT.Description AND jCT.joChangeTypeID = 1)
				WHERE joMaster.joMasterID=_joMasterID;
				
				SELECT SUM(IFNULL(I.Subtotal,0))+SUM(IFNULL(I.Freight,0)) AS Invoiced INTO _invoiced
				  FROM joRelease AS R 
				 RIGHT JOIN (joReleaseDetail AS D RIGHT JOIN cuInvoice AS I ON D.joReleaseDetailID = I.joReleaseDetailID)
				 ON R.joReleaseID = D.joReleaseID WHERE (R.joMasterID=_joMasterID
				) AND (I.TransactionStatus<>-1) 
				AND (R.ReleaseType = 1 OR R.ReleaseType = 4 OR R.ReleaseType = 3 OR R.ReleaseType = 2);
				
				SET _billingReminder=_revisedContract-_invoiced;
				
				SELECT IFNULL(SUM(appliedAmt),0) AS accountsReceivable,MAX(paidDate) AS maxInvoicePaidDate,MAX(invoiceDate) AS maxInvoiceDate  INTO _accountsReceivable,_lastcuinvoicePaiddate,_maxInvoiceDate FROM
				(
				SELECT cuInvoice.invoicenumber, MAX(cuInvoice.invoicedate) AS invoiceDate, MAX(cul.datePaid) AS paidDate, cuInvoice.InvoiceAmount, cuInvoice.donotmail, cuInvoice.surtaxtotal,  cuInvoice.surtaxrate, cuInvoice.surtaxamount, cuInvoice.Subtotal,  IFNULL((IFNULL(cuInvoice.InvoiceAmount,0) - (SUM(IFNULL(cul.`PaymentApplied`,0))+IFNULL(cuInvoice.DiscountAmt,0))),0) AS appliedAmt,
				cuInvoice.Freight,cuInvoice.TaxAmount,DATEDIFF(NOW(),InvoiceDate) AS days,  (SUM(IFNULL(cul.`PaymentApplied`,0))+IFNULL(cuInvoice.DiscountAmt,0)) AS paidamt  FROM joMaster JOIN joReleaseDetail ON joMaster.joMasterid=joReleaseDetail.joMasterid  JOIN cuInvoice ON joReleaseDetail.joReleaseDetailid=cuInvoice.joReleaseDetailid  LEFT JOIN cuLinkageDetail cul ON(cuInvoice.cuInvoiceID=cul.cuInvoiceID) 
				WHERE cuInvoice.TransactionStatus <> -1 AND joMaster.joMasterID = _joMasterID 
				GROUP BY cuInvoice.cuInvoiceID 
				) AS financialQuery;
				
				-- select 'step1',_billingReminder,_accountsReceivable;
				IF (_billingReminder=0 AND _accountsReceivable=0) THEN
					-- SELECT 'step2',_billingReminder,_lastcuinvoicePaiddate,_maxInvoiceDate,_isFollowingPeriod,_periodEndDate;
					IF (_lastcuinvoicePaiddate IS NOT NULL AND _lastcuinvoicePaiddate<=_periodEndDate ) THEN
						IF (_isFollowingPeriod=1) THEN
							IF (DATE_ADD(_lastcuinvoicePaiddate,INTERVAL 30 DAY)<=_periodEndDate ) THEN
								SET _allowToCalculateCommission = TRUE;
							ELSE
								SET _allowToCalculateCommission = FALSE;
							END IF;
						ELSE
							SET _allowToCalculateCommission = TRUE;
						END IF;
					ELSE
					   SET _allowToCalculateCommission = FALSE;
					END IF;
				ELSE
					SET _allowToCalculateCommission = FALSE;
				END IF;
				
				IF (_allowToCalculateCommission=1 AND _RecordType='VendorComm') THEN
					SELECT IFNULL(po.SubTotal,0)-SUM(IFNULL(vec.CommAmount,0)) AS commBalance INTO _vendorCommBalance FROM joRelease jr 
					LEFT JOIN joReleaseDetail jrd ON(jr.joReleaseId=jrd.joReleaseId) 
					LEFT JOIN vePO po ON(jr.joReleaseId=po.joReleaseId) 
					LEFT JOIN veCommDetail vec ON(jrd.joReleaseDetailID=vec.joReleaseDetailID)
					WHERE jr.joReleaseId=_info_joReleaseID;
					
					IF (_vendorCommBalance=0 AND _CommAvailableDate<=_periodEndDate) THEN
					     SET _allowToCalculateCommission = TRUE;
					ELSE
					     SET _allowToCalculateCommission = FALSE;
					END IF;
				END IF;
								
				
			 ELSE 
				-- Outside job , commission should calculate after invoice paid
				IF (_CustomerStatus="Paid" AND _customerPaidDate <=_periodEndDate) THEN
					SET _allowToCalculateCommission = TRUE;
				ELSE
					SET _allowToCalculateCommission = FALSE;
				END IF;
			 END IF;
		   ELSEIF (_isCommAfterPayment=1) THEN 
			-- commission should calculate after customer payment
			IF (_RecordType='VendorComm') THEN
				SELECT IFNULL(po.SubTotal,0)-SUM(IFNULL(vec.CommAmount,0)) AS commBalance INTO _vendorCommBalance FROM joRelease jr 
				LEFT JOIN joReleaseDetail jrd ON(jr.joReleaseId=jrd.joReleaseId) 
				LEFT JOIN vePO po ON(jr.joReleaseId=po.joReleaseId) 
				LEFT JOIN veCommDetail vec ON(jrd.joReleaseDetailID=vec.joReleaseDetailID)
				WHERE jr.joReleaseId=_info_joReleaseID;
				
				IF (_vendorCommBalance=0 AND _CommAvailableDate<=_periodEndDate) THEN
				     SET _allowToCalculateCommission = TRUE;
				ELSE
				     SET _allowToCalculateCommission = FALSE;
				END IF;
			ELSE
				IF (_CustomerStatus="Paid" AND _customerPaidDate <=_periodEndDate) THEN
					SET _allowToCalculateCommission = TRUE;
				ELSE
					SET _allowToCalculateCommission = FALSE;
				END IF;	
			END IF;
		   ELSE
                        IF (_RecordType='VendorComm') THEN
				IF (_CommAvailableDate<=_periodEndDate) THEN
				     SET _allowToCalculateCommission = TRUE;
				ELSE
				     SET _allowToCalculateCommission = FALSE;
				END IF;
                        ELSE
                   
				-- commission should calculate after customer invoice creation
				IF (_dayAfter IS NOT NULL AND _dayAfter>0) THEN
					IF (DATE_ADD(_CommAvailableDate,INTERVAL _dayAfter DAY)<=_periodEndDate) THEN
						SET _allowToCalculateCommission = TRUE;
					ELSE 
						SET _allowToCalculateCommission = FALSE;
					END IF;
				ELSE
					IF (_CommAvailableDate<=_periodEndDate) THEN
					     SET _allowToCalculateCommission = TRUE;
					ELSE
					     SET _allowToCalculateCommission = FALSE;
					END IF;
				END IF;
                        
                        END IF;					
			
			
			
		   END IF; 
	ELSEIF (_RecordType='AddCost') THEN
		IF (_CommAvailableDate<=_periodEndDate) THEN
		    SET _allowToCalculateCommission = TRUE;	
		ELSE
		    SET _allowToCalculateCommission = FALSE;	
		END IF;
	ELSEIF (_RecordType='VendorExpense') THEN
		IF (_CommAvailableDate<=_periodEndDate) THEN
		    SET _allowToCalculateCommission = TRUE;	
		ELSE
		    SET _allowToCalculateCommission = FALSE;	
		END IF;
		
	END IF;   
END IF;
--  End Logic	  
	    IF v_done THEN
		LEAVE read_loop;
	    END IF;
	    IF (_RecordType IS NOT NULL AND _allowToCalculateCommission=1) THEN
	     CALL COMMISSION_UpdateCommissionTables(
			_RecordType,_CustomerStatus,_IsCommPaid,_cuInvoiceId,_CommAvailableDate,_InvoiceNumber,
			_joReleaseType,_info_rxCustomerID,_InvoiceAmount, _appliedAmount,  _CommPercent,
			_AmountDue,_info_userLoginID, _PayType, _StatementID, _Info_ReleasedetailID, _CalcRevShare, _info_joReleaseID, _joMasterID,
			_info_veCommDetailID, _veBillID,_isJobPaidInFull,_isFollowingPeriod,_customerPaidDate,_isCommAfterPayment,_dayAfter,
			_periodStartDate,_periodEndDate,_ecPeriodID,_info_joInvoiceCostID,_invoiceDate		
		);	
	    END IF;
	  END LOOP;
	  
	  -- COMMIT; 
	  CLOSE cursorForCommission;
	
    END$$

DELIMITER ;
-- =============================================
DROP PROCEDURE IF EXISTS `COMMISSION_UpdateCommissionTables`;
DELIMITER $$

CREATE PROCEDURE `COMMISSION_UpdateCommissionTables`(
IN _RecordType VARCHAR(25),IN _CustomerStatus VARCHAR(25),IN _IsCommPaid VARCHAR(25),IN _cuInvoiceId INT,IN _CommAvailableDate DATETIME,IN _InvoiceNumber VARCHAR (100),
IN _joReleaseType INT,IN _info_rxCustomerID INT,IN _InvoiceAmount DOUBLE,IN _appliedAmount DOUBLE,IN _CommPercent DOUBLE,
IN _AmountDue DOUBLE,IN _info_userLoginID INT,IN _PayType INT,IN _StatementID INT,IN _Info_ReleasedetailID INT,IN _CalcRevShare DOUBLE,IN _info_joReleaseID INT,IN _joMasterID INT,
IN _info_veCommDetailID INT,IN _veBillID INT,IN _isJobPaidInFull INT,IN _isFollowingPeriod INT,IN _customerPaidDate DATETIME,IN _isCommAfterPayment INT,IN _dayAfter INT,
IN _periodStartDate DATETIME,IN _periodEndDate DATETIME,IN _ecPeriodID INT,IN _info_joInvoiceCostID INT,IN _invoiceDate DATETIME 
)
BEGIN
DECLARE _ecType VARCHAR(10);
DECLARE _ecInvoicePeriodID INT;
					IF (_RecordType='Invoice') THEN
						SET _ecType='I';
  						SET _joMasterID=NULL;
 						SET _veBillID=NULL;
					ELSEIF (_RecordType='AddCost') THEN
						SET _ecType='A';
 						SET _joMasterID=NULL;
 						SET _veBillID=NULL;
					ELSEIF (_RecordType='VendorComm') THEN
						SET _ecType='V';
 						SET _joMasterID=NULL;
 						SET _veBillID=NULL;
					ELSEIF (_RecordType='VendorExpense') THEN
						SET _ecType='VE';
                    END IF;
    
                 
	INSERT IGNORE ecInvoicePeriod (cuInvoiceID,ecPeriodID,Modified,rxCustomerID,ReleaseType,Reference,DatePaid,Sales,Profit,
    joReleaseID,cuTrueInvoiceID,ExpjoMasterID,ExprxMasterID,enteredDate,ecType)
    VALUES (_cuInvoiceId,_ecPeriodID,TRUE,_info_rxCustomerID,_joReleaseType,_InvoiceNumber,DATE(_periodEndDate),_InvoiceAmount,_appliedAmount,
    _info_joReleaseID,NULL,_joMasterID,_joMasterID,NOW(),_ecType);
    
	SELECT LAST_INSERT_ID() INTO _ecInvoicePeriodID;
    INSERT IGNORE ecInvoiceRepSplit (ecInvoicePeriodID,ecStatementID,Profit,CommissionRate,AmountDue) 
    VALUES (_ecInvoicePeriodID,_StatementID,_appliedAmount,_CommPercent,_AmountDue);
    
					IF (_RecordType='AddCost') THEN
                    
                    UPDATE joInvoiceCost SET ecInvoicePeriodID =_ecInvoicePeriodID WHERE joInvoiceCostID=_info_joInvoiceCostID
                    -- joReleaseDetailID=_Info_ReleasedetailID
                    AND enteredDate <= _periodEndDate AND ecInvoicePeriodID IS NULL;
                    -- AND joInvoiceCostID>0;
                    
					ELSEIF (_RecordType='VendorComm') THEN
                    
                    UPDATE veCommDetail SET ecInvoicePeriodID =_ecInvoicePeriodID WHERE veCommDetailID=_info_veCommDetailID
                    -- joReleaseDetailID=_Info_ReleasedetailID 
                    AND ShipDate <= _periodEndDate AND ecInvoicePeriodID IS NULL;
                    -- AND veCommDetailID>0;
                
					ELSEIF (_RecordType='VendorExpense') THEN
                    
                    UPDATE veBillDistribution vBD LEFT JOIN 
                    (SELECT ecInvoicePeriodID, vBD.veBillDistributionID,vB.BillDate FROM veBillDistribution vBD
		    LEFT JOIN veBill vB ON vB.veBillId = vBD.veBillId WHERE vBD.veBillDistributionID = _info_veCommDetailID 
                    -- AND vB.BillDate >= _periodStartDate 
                    AND vB.BillDate <= _periodEndDate 
                    AND vBD.ecInvoicePeriodID IS NULL) d  ON d.veBillDistributionID = vBD.veBillDistributionID 
                    SET vBD.ecInvoicePeriodID = _ecInvoicePeriodID WHERE vBD.veBillDistributionID = _info_veCommDetailID 
		    -- AND d.BillDate >= _periodStartDate 
                    AND d.BillDate <= _periodEndDate AND vBD.ecInvoicePeriodID IS NULL;
                    -- AND veBillDistributionID>0;
                
                    END IF;
END$$

DELIMITER ;

-- =============================================
DROP PROCEDURE IF EXISTS `COMMISSION_report`;
DELIMITER $$

CREATE  PROCEDURE `COMMISSION_report`(
in _action varchar(250),
in _EcStatementId integer
)
BEGIN


if (_action = "JOBPAIDINFULL") then 
 set @commissionQuery = "SELECT  ecInvoicePeriod.ExpjoMasterID, (SELECT  SUM(IFNULL(Subtotal, 0)) AS amount  FROM cuInvoice
        WHERE joReleaseDetailID IN (SELECT   joReleaseDetailID FROM  joReleaseDetail WHERE joMasterID IN (joMaster.joMasterID))) AS test1,
    (SELECT IFNULL(joMM.ContractAmount, 0) + IFNULL(SUM(jC.ChangeAmount), 0) AS amount
    FROM joMaster joMM
	JOIN joChange jC ON jC.joMasterid = joMM.joMasterid
    LEFT JOIN joChangeType jCT ON jC.SellingType = jCT.Description
	WHERE  jCT.joChangeTypeID = 1 AND joMM.joMasterID = joMaster.joMasterID) AS test22,
    ecInvoicePeriod.ExprxMasterID,
    ecInvoicePeriod.joReleaseID AS joReleaseID2,
    joReleaseDetail.joReleaseID,
    rxMaster.rxMasterID,
    TRIM(BOTH ' ' FROM rxMaster.Name) AS NAME,
    TRIM(BOTH ' ' FROM rxMaster.FirstName) AS FirstName,
    (CASE
        WHEN (joMaster.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM joMaster.JobNumber)
        WHEN (joM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM joM.JobNumber)
        WHEN (jM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM jM.JobNumber)
        ELSE '-'
    END) AS JobNumber,
    (CASE
        WHEN (joMaster.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM joMaster.Description)
        WHEN (joM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM joM.Description)
        WHEN (jM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM jM.Description)
        ELSE (TRIM(BOTH ' ' FROM rxMaster.Name))
    END) AS JobName,
    cuInvoice.QuickJobName,
    cuInvoice.InvoiceDate AS InvoiceDate,
    IFNULL(joReleaseType.Description,
            IF(ecInvoicePeriod.ExpjoMasterID IS NULL,
                'Sales',
                'Expense')) AS releaseType,
    IFNULL(ecInvoicePeriod.Sales, 0.0000) AS Sales,
    IFNULL(ecInvoicePeriod.Sales, 0.0000) AS TotalSales,
    IFNULL(ecInvoicePeriod.Profit, 0.0000) AS TotalProfit,
    ecInvoicePeriod.Reference,
    IFNULL(ecInvoiceRepSplit.Profit, 0.0000) AS Profit,
    IFNULL(ecInvoiceRepSplit.CommissionRate, 0.0000) AS CommissionRate,
    IFNULL(ecInvoiceRepSplit.AmountDue, 0.0000) AS AmountDue,
    IFNULL(cuInvoice.SubTotal, 0.0000) + IFNULL(cuInvoice.Freight, 0.0000) AS Gross,
    (((IFNULL(cuInvoice.SubTotal, 0.0000) + IFNULL(cuInvoice.Freight, 0.0000) - (IFNULL(cuInvoice.SubTotal, 0.0000) + IFNULL(cuInvoice.Freight, 0.0000) - IFNULL(ecInvoicePeriod.Profit, 0.0000))) / (IFNULL(cuInvoice.SubTotal, 0.0000) + IFNULL(cuInvoice.Freight, 0.0000))) * 100) AS Margin,
    (SELECT headertext FROM tsUserSetting) AS header,
    (SELECT companylogo FROM tsUserSetting) AS logo
FROM
    (joReleaseDetail
    RIGHT JOIN (((ecInvoiceRepSplit
    LEFT JOIN ecInvoicePeriod ON ecInvoiceRepSplit.ecInvoicePeriodID = ecInvoicePeriod.ecInvoicePeriodID)
    LEFT JOIN rxMaster ON ecInvoicePeriod.rxCustomerID = rxMaster.rxMasterID)
    LEFT JOIN cuInvoice ON ecInvoicePeriod.cuInvoiceID = cuInvoice.cuInvoiceID) ON joReleaseDetail.joReleaseDetailID = cuInvoice.joReleaseDetailID)
        LEFT JOIN veCommDetail veC ON ecInvoicePeriod.ecInvoicePeriodID = veC.ecInvoicePeriodID
        LEFT JOIN joReleaseDetail joRD ON joRD.joReleaseDetailID = veC.joReleaseDetailID
        LEFT JOIN joRelease joR ON (joR.joReleaseID = joRD.joReleaseID OR joR.joReleaseID = ecInvoicePeriod.joReleaseID)
        LEFT JOIN joMaster joM ON joM.joMasterID = joR.joMasterID
        LEFT JOIN joMaster jM ON ecInvoicePeriod.ExpjoMasterID = jM.joMasterID
        LEFT JOIN joMaster ON joReleaseDetail.joMasterID = joMaster.joMasterID
        LEFT JOIN joReleaseType ON ecInvoicePeriod.ReleaseType = joReleaseType.joReleaseTypeID
WHERE
    (joMaster.ContractAmount IS NULL OR joMaster.ContractAmount <= (SELECT SUM((IFNULL(C.Subtotal, 0) + IFNULL(C.Freight, 0)))
        FROM joReleaseDetail D
		RIGHT JOIN joRelease AS R ON R.joReleaseID = D.joReleaseID
		LEFT JOIN veBill AS V ON V.joReleaseDetailID = D.joReleaseDetailID
		LEFT JOIN cuInvoice AS C ON C.joReleaseDetailID = D.joReleaseDetailID
        WHERE R.ReleaseType != 4 AND R.joMasterID = joMaster.joMasterID)) AND 
        (joMaster.ContractAmount IS NULL OR (SELECT SUM(aa.test) FROM (SELECT IFNULL(jC.ChangeAmount, 0) AS test, joMaster.joMasterID
            FROM joChange jC
            LEFT JOIN joMaster ON jC.joMasterid = joMaster.joMasterid
            LEFT JOIN joChangeType jCT ON jC.SellingType = jCT.Description
            WHERE jCT.joChangeTypeID = 1 UNION SELECT IFNULL(C.Subtotal, 0) + IFNULL(C.Freight, 0) AS test, R.joMasterID
            FROM joReleaseDetail D
            RIGHT JOIN joRelease AS R ON R.joReleaseID = D.joReleaseID
            LEFT JOIN veBill AS V ON V.joReleaseDetailID = D.joReleaseDetailID
            LEFT JOIN cuInvoice AS C ON C.joReleaseDetailID = D.joReleaseDetailID
            WHERE R.ReleaseType != 4) AS aa
        WHERE aa.joMasterID = joMaster.joMasterID) <= (SELECT SUM(ab.Subtotal + ab.Freight)
        FROM
            (SELECT IFNULL(cuInvoice.Subtotal, 0) AS Subtotal, IFNULL(cuInvoice.Freight, 0) AS Freight, jjm.joMasterID
            FROM joMaster jjm
            JOIN joReleaseDetail ON jjm.joMasterID = joReleaseDetail.joMasterID
            JOIN cuInvoice ON joReleaseDetail.joReleaseDetailID = cuInvoice.joReleaseDetailID
            LEFT JOIN cuLinkageDetail cul ON (cuInvoice.cuInvoiceID = cul.cuInvoiceID)
            WHERE cuInvoice.TransactionStatus <> - 1
            GROUP BY cuInvoice.cuInvoiceID
            ORDER BY LENGTH(cuInvoice.invoicenumber) ASC , cuInvoice.invoiceNumber ASC) AS ab
        WHERE ab.joMasterID = joMaster.joMasterID)) AND (joMaster.ContractAmount IS NULL
        OR (SELECT SUM(IFNULL(appliedAmt, 0)) 
        FROM
            (SELECT IFNULL((IFNULL(cuInvoice.InvoiceAmount, 0) - (SUM(IFNULL(cul.`PaymentApplied`, 0)) + IFNULL(cuInvoice.DiscountAmt, 0))), 0) AS appliedAmt, joMaster.joMasterID
            FROM joMaster
            JOIN joReleaseDetail ON joMaster.joMasterID = joReleaseDetail.joMasterID
            JOIN cuInvoice ON joReleaseDetail.joReleaseDetailID = cuInvoice.joReleaseDetailID
            LEFT JOIN cuLinkageDetail cul ON (cuInvoice.cuInvoiceID = cul.cuInvoiceID)
            WHERE
                cuInvoice.TransactionStatus <> - 1
            GROUP BY cuInvoice.cuInvoiceID
            ORDER BY LENGTH(cuInvoice.invoicenumber) ASC , cuInvoice.invoiceNumber ASC) AS a
        WHERE a.joMasterID = joMaster.joMasterID) = 0) AND ((SELECT SUM(IFNULL(Subtotal, 0)) AS amount
        FROM cuInvoice
        WHERE joReleaseDetailID IN (SELECT joReleaseDetailID FROM joReleaseDetail WHERE joMasterID IN (joMaster.joMasterID))) = (SELECT IFNULL(joMM.ContractAmount, 0) + IFNULL(SUM(jC.ChangeAmount), 0) AS amount
        FROM joMaster joMM JOIN joChange jC ON jC.joMasterid = joMM.joMasterid 
        LEFT JOIN joChangeType jCT ON jC.SellingType = jCT.Description
        WHERE jCT.joChangeTypeID = 1 AND joMM.joMasterID = joMaster.joMasterID) OR (SELECT IFNULL(joMM.ContractAmount, 0) + IFNULL(SUM(jC.ChangeAmount), 0) AS amount
        FROM joMaster joMM
		JOIN joChange jC ON jC.joMasterid = joMM.joMasterid
		LEFT JOIN joChangeType jCT ON jC.SellingType = jCT.Description
        WHERE jCT.joChangeTypeID = 1 AND joMM.joMasterID = joMaster.joMasterID) = 0)
        AND ecInvoiceRepSplit.ecStatementID = ";
        set @commissionQuery = CONCAT(@commissionQuery, _EcStatementId ," ORDER BY joMaster.JobNumber , cuInvoice.InvoiceNumber;"); 
        
        
        
		prepare stmt1 from @commissionQuery;
	     execute stmt1;
	     deallocate prepare stmt1;
ELSEIF (_action = "CUSTOMERPAYMENT" or _action = "CUSTOMERINVOICE") then 
        set @commissionQuery = "SELECT ecInvoicePeriod.ExpjoMasterID, ecInvoicePeriod.ExprxMasterID, ecInvoicePeriod.joReleaseID AS joReleaseID2, 
						joReleaseDetail.joReleaseID, rxMaster.rxMasterID,  TRIM(BOTH ' ' FROM rxMaster.Name) AS NAME,  TRIM(BOTH ' ' FROM rxMaster.FirstName) 
						AS FirstName,          (CASE             WHEN (joMaster.JobNumber IS NOT NULL)THEN TRIM(BOTH ' ' FROM joMaster.JobNumber)        
						    WHEN (joM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM joM.JobNumber)                      
						 WHEN (jM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM jM.JobNumber)  ELSE '-'             END)AS JobNumber, 
						(CASE             WHEN (joMaster.JobNumber IS NOT NULL)THEN TRIM(BOTH ' ' FROM joMaster.Description)            
						WHEN (joM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM joM.Description)                    
						 WHEN (jM.JobNumber IS NOT NULL) THEN TRIM(BOTH ' ' FROM jM.Description) 
						   ELSE (TRIM(BOTH ' ' FROM rxMaster.Name))             END)AS JobName,  cuInvoice.QuickJobName, 
						 IFNULL(joReleaseType.Description,IF(ecInvoicePeriod.ExpjoMasterID IS NULL,'Sales','Expense')) AS releaseType,
						 IFNULL(ecInvoicePeriod.Sales,0.0000) as Sales,  IFNULL(ecInvoicePeriod.Sales,0.0000) AS TotalSales, IFNULL(ecInvoicePeriod.Profit,0.0000) AS TotalProfit, ecInvoicePeriod.Reference,  
						 cuInvoice.InvoiceDate as InvoiceDate, IFNULL(ecInvoiceRepSplit.Profit,0.0000) as Profit, IFNULL(ecInvoiceRepSplit.CommissionRate,0.0000) as CommissionRate,  IFNULL(ecInvoiceRepSplit.AmountDue,0.0000) as AmountDue,
						IFNULL(cuInvoice.SubTotal,0.0000) + IFNULL(cuInvoice.Freight,0.0000) AS Gross,
						 (((IFNULL(cuInvoice.SubTotal, 0.0000) + IFNULL(cuInvoice.Freight, 0.0000) - (IFNULL(cuInvoice.SubTotal, 0.0000) + IFNULL(cuInvoice.Freight, 0.0000) -  IFNULL(ecInvoicePeriod.Profit, 0.0000)))/ (IFNULL(cuInvoice.SubTotal, 0.0000) + IFNULL(cuInvoice.Freight, 0.0000)))*100) as Margin,
						(SELECT headertext FROM tsUserSetting) AS header, (SELECT companylogo FROM tsUserSetting) AS logo
						  FROM (joReleaseDetail RIGHT JOIN (((ecInvoiceRepSplit LEFT JOIN ecInvoicePeriod
						 ON  ecInvoiceRepSplit.ecInvoicePeriodID = ecInvoicePeriod.ecInvoicePeriodID) 
						 LEFT JOIN rxMaster ON ecInvoicePeriod.rxCustomerID = rxMaster.rxMasterID)
						 LEFT JOIN cuInvoice ON ecInvoicePeriod.cuInvoiceID = cuInvoice.cuInvoiceID) 
						ON joReleaseDetail.joReleaseDetailID = cuInvoice.joReleaseDetailID     )    
						 LEFT JOIN veCommDetail veC ON ecInvoicePeriod.ecInvoicePeriodID = veC.ecInvoicePeriodID  
						 LEFT JOIN joReleaseDetail joRD ON joRD.joReleaseDetailID = veC.joReleaseDetailID  
						 LEFT JOIN joRelease joR  ON (joR.joReleaseID = joRD.joReleaseID OR joR.joReleaseID=ecInvoicePeriod.joReleaseID)  
						 LEFT JOIN joMaster joM ON joM.joMasterID = joR.joMasterID 
						 LEFT JOIN joMaster jM ON ecInvoicePeriod.ExpjoMasterID = jM.joMasterID 
						LEFT JOIN joMaster ON joReleaseDetail.joMasterID = joMaster.joMasterID
						LEFT JOIN joReleaseType ON ecInvoicePeriod.ReleaseType = joReleaseType.joReleaseTypeID 
						WHERE ecInvoiceRepSplit.ecStatementID = ";
                        
		set @commissionQuery = concat(@commissionQuery, _EcStatementId," ORDER BY joMaster.JobNumber, cuInvoice.InvoiceNumber"); 
        		 prepare stmt1 from @commissionQuery;
	     execute stmt1;
	     deallocate prepare stmt1;
end if; 

END$$

DELIMITER ;
-- =============================================
DROP PROCEDURE IF EXISTS `updateTimeStamp`;


DELIMITER $$

CREATE PROCEDURE `updateTimeStamp`(IN _action varchar(100),IN _id int)
BEGIN
	if(_action = "SALES_ORDER") then 
		update cuSO set emailTimeStamp = now()  where cuSOID = _id;
		select emailTimeStamp from cuSO where cuSOID = _id;
	elseif(_action = "PURCHASE_ORDER") then
		update vePO set emailTimeStamp = now()  where vePOID = _id;
		select emailTimeStamp from vePO where vePOID = _id;
	elseif(_action = "CUSTOMER_INVOICE") then
		update cuInvoice set PrintDate = now() where cuInvoiceID = _id;
        select PrintDate as emailTimeStamp from cuInvoice where cuInvoiceID = _id;
	elseif(_action = "GET_CUSTOMER_INVOICE") then
        select PrintDate as emailTimeStamp from cuInvoice where cuInvoiceID = _id;
	end if;
END$$

DELIMITER ;

-- ===================================================================
DROP PROCEDURE IF EXISTS `updateRxMasterCatagory_Check`;


DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `updateRxMasterCatagory_Check`(
IN _rxMasterID INT
)
updateRxMasterCatagory_Check:BEGIN
	declare isArchitect int default 0;
	declare isEngineer int default 0; 
	declare isOwner int default 0; 
    declare _rxMasterCategory1ID int;
    declare _rxMasterCategory2ID int;
    declare _rxMasterCategory4ID int;
    
	select IsCategory1 ,IsCategory2,IsCategory4 into isArchitect,isEngineer,isOwner from rxMaster where rxMasterID=_rxMasterID;
    select rxMasterCategory1ID into _rxMasterCategory1ID from rxMasterCategory1 where rxMasterCategory1ID  =  _rxMasterID;
	select rxMasterCategory2ID  into _rxMasterCategory2ID from rxMasterCategory2 where rxMasterCategory2ID  =  _rxMasterID;
    select rxMasterCategory4ID into _rxMasterCategory4ID from rxMasterCategory4 where rxMasterCategory4ID  =  _rxMasterID;

    if (isArchitect= 0) then
		if(_rxMasterCategory1ID is not null && _rxMasterCategory1ID != '') then
			delete from rxMasterCategory1 where rxMasterCategory1ID=_rxMasterID;
        end if;
    end if;    
    if (isEngineer = 0) then 
		if(_rxMasterCategory2ID is not null && _rxMasterCategory2ID != '') then
			delete from rxMasterCategory2 where rxMasterCategory2ID=_rxMasterID; 
		end if;
    end if;
    if (isOwner = 0 )then
		if(_rxMasterCategory4ID is not null && _rxMasterCategory4ID != '') then
			delete from rxMasterCategory4 where rxMasterCategory4ID=_rxMasterID;
		end if;
    end if;
END$$

DELIMITER ;

-- ================================================================================

DROP PROCEDURE IF EXISTS `updaterxMasterCategory`;


DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `updaterxMasterCategory`(
IN _rxMasterID INT,
IN _action_type varchar(255),
IN _cuAssignmentID0 int,
IN _cuAssignmentID1 int,
IN _cuAssignmentID2 int,
IN _cuAssignmentID3 int,
IN _cuAssignmentID4 int,
IN _userID INT

)
updaterxMasterCategory :BEGIN
		declare isFound tinyint default 0;
        If(_action_type='ARCHITECT') then
            if(_cuAssignmentID0 is null and _cuAssignmentID1 is null and _cuAssignmentID2 is null
				   and _cuAssignmentID3 is null and _cuAssignmentID4 is null )then
					delete from rxMasterCategory1 where rxMasterCategory1ID=_rxMasterId;
            else
				select count(*) into isFound from rxMasterCategory1 where rxMasterCategory1ID = _rxMasterId;
				if(isFound>0) then
					update rxMasterCategory1 
					set cuAssignmentID0=_cuAssignmentID0, cuAssignmentID1=_cuAssignmentID1,cuAssignmentID2=_cuAssignmentID2,
					cuAssignmentID3=_cuAssignmentID3,cuAssignmentID4=_cuAssignmentID4 where rxMasterCategory1ID=_rxMasterId;
				else
					insert into rxMasterCategory1(rxMasterCategory1ID,cuAssignmentID0,cuAssignmentID1,cuAssignmentID2,cuAssignmentID3,cuAssignmentID4)
					value (_rxMasterID, _cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3,_cuAssignmentID4);
				end if;
           end if;     
		elseif(_action_type='ENGINEER') then
			if(_cuAssignmentID0 is null and _cuAssignmentID1 is null and _cuAssignmentID2 is null
				   and _cuAssignmentID3 is null and _cuAssignmentID4 is null )then
					delete from rxMasterCategory2 where rxMasterCategory2ID=_rxMasterId;
            else
            select _rxMasterID;
				select count(*) into isFound from rxMasterCategory2 where rxMasterCategory2ID = _rxMasterID;
				if(isFound>0) then
					update rxMasterCategory2 
					set cuAssignmentID0=_cuAssignmentID0, cuAssignmentID1=_cuAssignmentID1,cuAssignmentID2=_cuAssignmentID2,
					cuAssignmentID3=_cuAssignmentID3,cuAssignmentID4=_cuAssignmentID4 where rxMasterCategory2ID=_rxMasterId;
				else
					insert into rxMasterCategory2(rxMasterCategory2ID,cuAssignmentID0,cuAssignmentID1,cuAssignmentID2,cuAssignmentID3,cuAssignmentID4)
					value (_rxMasterID, _cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3,_cuAssignmentID4);
				end if;
            end if;    
        elseif(_action_type='OWNER') then
			if(_cuAssignmentID0 is null and _cuAssignmentID1 is null and _cuAssignmentID2 is null
				   and _cuAssignmentID3 is null and _cuAssignmentID4 is null )then
					delete from rxMasterCategory4 where rxMasterCategory4ID=_rxMasterId;
            else
				select count(*) into isFound from rxMasterCategory4 where rxMasterCategory4ID = _rxMasterID;
				if(isFound>0) then
					update rxMasterCategory4 
					set cuAssignmentID0=_cuAssignmentID0, cuAssignmentID1=_cuAssignmentID1,cuAssignmentID2=_cuAssignmentID2,
					cuAssignmentID3=_cuAssignmentID3,cuAssignmentID4=_cuAssignmentID4 where rxMasterCategory4ID=_rxMasterId;
				else
					insert into rxMasterCategory4(rxMasterCategory4ID,cuAssignmentID0,cuAssignmentID1,cuAssignmentID2,cuAssignmentID3,cuAssignmentID4)
					value (_rxMasterID, _cuAssignmentID0,_cuAssignmentID1,_cuAssignmentID2,_cuAssignmentID3,_cuAssignmentID4);
				end if;
             end if;   
		end if;     
		UPDATE rxMaster SET ChangedOn = NOW(),ChangedByID = _userID WHERE rxMasterID = _rxMasterId;
END$$

DELIMITER ;
-- ==========================================================================================

DROP PROCEDURE IF EXISTS `get_WH_JobActivity`;


DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `get_WH_JobActivity`(
IN _joMasterId INT, 
IN _startBidDate DATETIME, 
IN _endBidDate DATETIME,
IN _salesPersonId INT, 
IN _jobStatus varchar(40), 
IN _quoteType INT,
IN _rxMasterId INT,
IN _startBookedDate DATETIME, 
IN _endBookedDate DATETIME,
IN _groupBy varchar(250))
get_WH_JobActivity: BEGIN

DECLARE andNeeded INT DEFAULT 0;
set  @l_sql= 'SELECT 
        jo.JobNumber AS JobNumber,
        jo.Description AS JobName,
        joS.JobStatus AS JobStatus,
        bs.Description AS BidStatus,
        rm.Name AS Customer, 
        (SELECT 
                ts.Initials
            FROM
                tsUserLogin ts
            WHERE
                (ts.UserLoginID = jo.cuAssignmentID0)) AS EmployeeAssignedInitial0,
        (SELECT 
                ts.FullName
            FROM
                tsUserLogin ts
            WHERE
                (ts.UserLoginID = jo.cuAssignmentID0)) AS EmployeeAssigned0,
        (SELECT 
                ts.FullName
            FROM
                tsUserLogin ts
            WHERE
                (ts.UserLoginID = jo.cuAssignmentID1)) AS EmployeeAssigned1,
        (SELECT 
                ts.FullName
            FROM
                tsUserLogin ts
            WHERE
                (ts.UserLoginID = jo.cuAssignmentID2)) AS EmployeeAssigned2,
        (SELECT 
                ts.FullName
            FROM
                tsUserLogin ts
            WHERE
                (ts.UserLoginID = jo.cuAssignmentID3)) AS EmployeeAssigned3,
        (SELECT 
                ts.FullName
            FROM
                tsUserLogin ts
            WHERE
                (ts.UserLoginID = jo.cuAssignmentID4)) AS EmployeeAssigned4,
        (SELECT 
                ts.FullName
            FROM
                tsUserLogin ts
            WHERE
                (ts.UserLoginID = jo.cuAssignmentID5)) AS EmployeeAssigned5,
        rxb.Name AS BidderName,
        CONCAT(c.FirstName, \' \', c.LastName) AS BidderContactName,
        cmt.Code AS QuoteType,
        joQCat.description AS QuoteItemCategory,
        (SELECT 
                rxMaster.Name
            FROM
                rxMaster
            WHERE
                (rxMaster.rxMasterID = joQDM.manufacturer)) AS QuoteItemVendor,
        q.QuoteRev AS QuoteRevision,
        u.FullName AS QuoteCreatedBy,
        joQDM.cost AS QuoteItemCost,
        IF((joQDM.percentage > 1),((joQDM.percentage *5)-5),0) AS QuoteItemPercentage,
                (CASE 
            WHEN (joQDM.sellingType = 1 ) THEN (SELECT ValueString FROM sysVariable WHERE sysVariableID=2016010032)
            WHEN (joQDM.sellingType = 2) THEN \'Commission\'
        END) AS QuoteItemSellingType, 
        (CASE joQDM.isLostOrSold
            WHEN (joQDM.isLostOrSold = 1) THEN \'Pending\'
            WHEN (joQDM.isLostOrSold = 2) THEN \'Lost\'
            WHEN (joQDM.isLostOrSold = 3) THEN \'Sold\'
        END) AS QuoteItemLostSold,
        q.QuoteAmount AS QuoteHeaderAmount,
        joQDM.sellprice AS QuoteItemSellPrice,
        joQDM.type AS QuoteLineItemType,
        q.DiscountedPrice AS QuoteDiscountPrice,
        b.LowBid AS BidderLowBid,
        ci.CustomerPONumber AS CustomerPONumber,
        (IFNULL(jo.ContractAmount, 0) + IFNULL(joChg.ChangeAmount, 0)) AS JobTotalAmount_Calc,
        (IFNULL(jo.ContractAmount, 0) - IFNULL(jo.EstimatedCost, 0)) AS JobProfitAmount_Calc,
        (IFNULL(joChg.ChangeAmount, 0) - IFNULL(joChg.ChangeCost, 0)) AS ChangeOrderProfitAmount_Calc,
        ((IFNULL(jo.ContractAmount, 0) - IFNULL(jo.EstimatedCost, 0)) + (IFNULL(joChg.ChangeAmount, 0) - IFNULL(joChg.ChangeCost, 0))) AS JobTotalProfitAmount_Calc,
        (((IFNULL(jo.ContractAmount, 0) - IFNULL(jo.EstimatedCost, 0)) + (IFNULL(joChg.ChangeAmount, 0) - IFNULL(joChg.ChangeCost, 0))) / IFNULL((jo.ContractAmount + joChg.ChangeAmount),
                1)) AS JobProfitMargin_Calc,
        ((((IFNULL(jo.ContractAmount, 0) - IFNULL(jo.EstimatedCost, 0)) + (IFNULL(joChg.ChangeAmount, 0) - IFNULL(joChg.ChangeCost, 0))) / IFNULL((jo.ContractAmount + joChg.ChangeAmount),
                1)) / IFNULL(em.Quota, 1)) AS PercentOfQuota_Calc,
        jo.EstimatedCost AS JobEstimatedCost,
        jo.ContractAmount AS JobContractAmount,
        joChg.ChangeCost AS ChangeOrderCost,
        joChg.ChangeAmount AS ChangeOrderAmount,
        joChg.CustomerPONumber AS ChangeOrderCustomerPO,
        IFNULL(rt.Description, \'NA\') AS ReleaseType,
        IF((joR.ReleaseType = 3),
            CONCAT(jo.JobNumber,
                    CONVERT( UCASE(INTTOLETTER(joR.seq_Number)) USING UTF8)),
            so.SONumber) AS SOReleaseNumber,
        so.SubTotal AS SOReleaseSubTotal,
        so.Freight AS SOReleaseFreight,
        so.CostTotal AS SOReleaseCostTotal,
        po.PONumber AS VenPOReleaseNumber,
        (SELECT 
                rxMaster.Name
            FROM
                rxMaster
            WHERE
                (rxMaster.rxMasterID = po.rxVendorID)) AS VenPOReleaseVendor,
        po.Subtotal AS VenPOReleaseSubTotal,
        po.Freight AS VenPOReleaseFreight,
        pod.prMasterID AS POprMasterID,
        (SELECT 
                prMaster.ItemCode
            FROM
                prMaster
            WHERE
                (prMaster.prMasterID = pod.prMasterID)) AS POProductName,
        pod.EstimatedShipDate AS POEstimatedShipDate,
        pod.QuantityOrdered AS POQuantityOrdered,
        pod.QuantityReceived AS POQuantityReceived,
        pod.QuantityBilled AS POQuantityBilled,
        joR.EstimatedBilling AS Allocated,
        joR.CommissionAmount AS CommissionReleaseAmount,
        joR.CommissionReceived AS CommissionReleaseReceived,
        ci.InvoiceNumber AS CuInvoiceNumber,
        ci.Subtotal AS cuInvoiceSubTotal,
        ci.Freight AS CuInvoiceFreight,
        ci.InvoiceAmount AS CuInvoiceAmount,
        ci.AppliedAmount AS CuInvoiceAppliedAmount,
        jo.ChangedOn AS LastActivityDate,
        jo.BidDate AS BidDate,
		(jo.BidDate + INTERVAL 90 DAY) AS ProjectOrderDate,
        jo.BookedDate AS BookedDate,
        jo.ClosedDate AS ClosedDate,
        joChg.ChangeDate AS ChangeOrderDate,
        joR.ReleaseDate AS ReleaseDate,
        so.createdDate AS SOReleaseDate,
        po.OrderDate AS VenPOReleaseDate,
        joR.CommissionDate AS CommissionReleaseDate,
        ci.InvoiceDate AS CuInvoiceDate,
        ci.DiscountAmt AS DiscountAmt,
        ci.Subtotal AS SubTotal,
        ci.Freight AS Freight,
        d.Code AS DivisionCode,
        d.Description AS Division,
        em.Quota AS MonthlyQuota,
        (SELECT 
                ts.Name
            FROM
                rxMaster ts
            WHERE
                (ts.rxMasterID = jo.rxCategory1)) AS Architect,
        (SELECT 
                ts.Name
            FROM
                rxMaster ts
            WHERE
                (ts.rxMasterID = jo.rxCategory2)) AS Engineer,
        (SELECT 
                ts.Name
            FROM
                rxMaster ts
            WHERE
                (ts.rxMasterID = jo.rxCategory3)) AS GeneralContractor,
        (SELECT 
                ts.Name
            FROM
                rxMaster ts
            WHERE
                (ts.rxMasterID = jo.rxCategory4)) AS JoOwner,
        (SELECT 
                ts.Name
            FROM
                rxMaster ts
            WHERE
                (ts.rxMasterID = jo.rxCategory5)) AS BondAgent,
                (SELECT 
                ts.Name
            FROM
                rxMaster ts
            WHERE
                (ts.rxMasterID = jo.rxCategory6)) AS InstallingContractor,
        (CASE jo.ClaimFiled
            WHEN (jo.ClaimFiled = 0) THEN \'None\'
            WHEN (jo.ClaimFiled = 1) THEN \'Bond\'
            WHEN (jo.ClaimFiled = 2) THEN \'Lean\'
        END) AS ClaimFiled,
        jo.ClaimFiledDate AS ClaimFiledDate,
        (SELECT 
                CONCAT(ts.FirstName, \' \', ts.LastName)
            FROM
                rxContact ts
            WHERE
                (ts.rxContactID = jo.CreditContact0)) AS GCContact,
        (SELECT 
                CONCAT(ts.FirstName, \' \', ts.LastName)
            FROM
                rxContact ts
            WHERE
                (ts.rxContactID = jo.CreditContact1)) AS OwnerContact,
        (SELECT 
                CONCAT(ts.FirstName, \' \', ts.LastName)
            FROM
                rxContact ts
            WHERE
                (ts.rxContactID = jo.CreditContact2)) AS BondAgentContact,
        jo.CreditNotes AS CreditNotes,
        jo.CreditReferenceNumber AS CreditReferenceNumber,
        (CASE jo.CreditStatus
            WHEN (jo.CreditStatus = 0) THEN \'Pending\'
            WHEN (jo.CreditStatus = 1) THEN \'Approved\'
            WHEN (jo.CreditStatus = 2) THEN \'Hold\'
        END) AS CreditStatus,
        jo.CreditStatusDate AS CreditStatusDate,
        (CASE jo.CreditType
            WHEN (jo.CreditType = 0) THEN \'Pending\'
            WHEN (jo.CreditType = 1) THEN \'Check Received\'
            WHEN (jo.CreditType = 2) THEN \'Credit Card\'
            WHEN (jo.CreditType = 3) THEN \'Joint Check\'
            WHEN (jo.CreditType = 4) THEN \'Open Account\'
            WHEN (jo.CreditType = 5) THEN \'Customer Terms\'
        END) AS CreditType,
        jo.CreditTypeDate AS CreditTypeDate,
        (CASE
            WHEN (jo.LienWaverSigned = 0) THEN \'No\'
            ELSE \'Yes\'
        END) AS LienWaverSigned,
        jo.LienWaverSignedDate AS LienWaverSignedDate,
        (CASE
            WHEN (jo.LienWaverThrough = 0) THEN \'No\'
            ELSE \'Yes\'
        END) AS LienWaverThrough,
        jo.LienWaverThroughAmount AS LienWaverThroughAmount,
        jo.LienWaverThroughDate AS LienWaverThroughDate,
        (CASE
            WHEN (jo.LienWaverThroughFinal = 0) THEN \'No\'
            ELSE \'Yes\'
        END) AS LienWaverThroughFinal,
        (CASE
            WHEN (jo.ReceivedNOC = 0) THEN \'No\'
            ELSE \'Yes\'
        END) AS ReceivedNOC,
        jo.ReceivedNOCDate AS ReceivedNOCDate,
        (CASE
            WHEN (jo.RequestedNOC = 0) THEN \'No\'
            ELSE \'Yes\'
        END) AS RequestedNOC,
        jo.RequestedNOCDate AS RequestedNOCDate,
        (CASE
            WHEN (jo.SentNTC = 0) THEN \'No\'
            ELSE \'Yes\'
        END) AS SentNTC,
        jo.SentNTCDate AS SentNTCDate,
        joR.BillNote AS ReleaseBillNote,
        joR.ReleaseNote AS ReleaseNote,
        jo.ReleaseNotes AS JobReleaseNotes,
        IFNULL(pod.EstimatedShipDate,
                IF(((po.DateWanted = NULL)
                        OR (po.DateWanted = \'\')),
                    NULL,
                    STR_TO_DATE(po.DateWanted, \'%m/%d/%Y\'))) AS RequestedShipDate,
        jo.coDivisionID AS coDivisionID,
        jo.cuAssignmentID0 AS cuAssignmentID0,
        jo.cuAssignmentID1 AS cuAssignmentID1,
        jo.cuAssignmentID2 AS cuAssignmentID2,
        jo.cuAssignmentID3 AS cuAssignmentID3,
        jo.cuAssignmentID4 AS cuAssignmentID4,
        jo.cuAssignmentID5 AS cuAssignmentID5,
        jo.cuAssignmentID6 AS cuAssignmentID6,
        ci.cuInvoiceID AS cuInvoiceID,
        rm.rxMasterID AS CustomerID,
        em.emMasterID AS emMasterID,
        jo.joMasterID AS joMasterID,
        joR.joReleaseID AS joReleaseID,
        po.vePOID AS vePOID,
        q.joQuoteHeaderID AS joQuoteHeaderID,
        q.InternalNote AS QuoteItemInternalNote,
        (CASE
            WHEN
                ((ci.memoStatus = 0)
                    AND (ci.CreditMemo = 1))
            THEN
                0
            ELSE 1
        END) AS IsRollbackFlag,
        pod.Description AS PODescription,
        pod.vePODetailID AS vePODetailID,
        ((pod.QuantityOrdered * pod.UnitCost) * IF((pod.PriceMultiplier = 0),
            1,
            pod.PriceMultiplier)) AS POQuantityOrderedCost,
        rt.joReleaseTypeID AS ReleaseTypeID,
        joRD.CustomerInvoiceAmount AS CustomerInvoiceAmount,
        (ci.InvoiceAmount - ci.AppliedAmount) AS BalanceDue,
        IF(ISNULL(ci.PaymentMadeOn),
            (TO_DAYS(CAST(NOW() AS DATE)) - TO_DAYS(joRD.CustomerInvoiceDate)),
            IF((ci.InvoiceAmount = ci.AppliedAmount),
                0,
                (TO_DAYS(CAST(NOW() AS DATE)) - TO_DAYS(joRD.CustomerInvoiceDate)))) AS DaysAged,
        joRD.joReleaseDetailID AS joReleaseDetailID,
        vb.InvoiceNumber AS vendorInvoiceNumber,
        CONCAT(rC.FirstName, \' \', rC.LastName) AS ProjectManagerName,
        jo.LocationAddress1 AS LocationAddress1,
        jo.LocationAddress2 AS LocationAddress2,
        jo.LocationCity AS LocationCity,
        jo.LocationState AS LocationState,
        jo.LocationZip AS LocationZip,
        rA.Address1 AS Address1,
        rA.Address2 AS Address2,
        rA.City AS City,
        rA.State AS State,
        rA.Zip AS Zip,
        rA.Phone1 AS Phone1,
        rA.Phone2 AS Phone2,
        rA.Fax AS Fax,
        cTT.County AS County,
        cTT.TaxRate AS TaxRate,
        jo.isDrawInfo AS isDrawInfo,
        jo.DrawInfo AS DrawInfo,
        jo.SellPrice AS SellPrice,
        vBD.ExpenseAmount AS ExpenseAmount,
        vb.BillDate AS BillDate,
        ci.CostTotal AS CostTotal,
        vb.BillAmount AS VeBillBillAmount,
        vb.AppliedAmount AS VeBillAppliedAmount,
        vb.FreightAmount AS VeBillFreightAmount,
        vCD.CommAmount AS CommAmount,
        IF(ISNULL(pod.EstimatedShipDate),
            \'NO\',
            \'YES\') AS ShipDateAcknowledgement,
        vb.TaxAmount AS VeBillTaxAmount,
        (vb.BillAmount - (vb.FreightAmount + vb.TaxAmount)) AS VeBillSubTotal,
        ci.DiscountAmt AS CuInvoiceDiscountAmount,
        vCD.BillAmount AS VeCommInvoiceAmount,
        vCD.CommDate AS VeCommDate,
        vCD.InvoiceNumber AS VeCommInvoiceNumber,
        vCD.veCommDetailID AS VeCommDetailID,
        sod.Description AS SODescription,
        ((sod.QuantityOrdered * IFNULL(sod.whseCost, 0)) * IF((sod.PriceMultiplier = 0),
            1,
            sod.PriceMultiplier)) AS SOQuantityOrderedCost,
        sod.cuSODetailID AS cuSODetailID,
        po.CustomerPONumber AS POCustomerPONumber,
        IF((joR.ReleaseType = 3),
            jo.CustomerPONumber,
            so.CustomerPONumber) AS SOCustomerPONumber
    FROM
        (((((((((((((((((((((((((((((((joMaster jo
        LEFT JOIN rxMaster rm ON ((rm.rxMasterID = jo.rxCustomerID)))
        LEFT JOIN rxAddress rA ON (((rA.rxMasterID = jo.rxCustomerID)
            AND (rA.IsMailing = 1))))
        LEFT JOIN coTaxTerritory cTT ON ((cTT.coTaxTerritoryID = jo.coTaxTerritoryID)))
        LEFT JOIN coDivision d ON ((d.coDivisionID = jo.coDivisionID)))        
        LEFT JOIN tsUserLogin ts ON ((ts.UserLoginID = jo.cuAssignmentID0)))
        LEFT JOIN emMaster em ON ((ts.UserLoginID = em.UserLoginID)))
        LEFT JOIN joRelease joR ON ((joR.joMasterID = jo.joMasterID)))
        LEFT JOIN joReleaseDetail joRD ON ((joRD.joReleaseID = joR.joReleaseID)))
        LEFT JOIN joReleaseType rt ON ((joR.ReleaseType = rt.joReleaseTypeID)))
        LEFT JOIN joChange joChg ON ((joChg.joMasterID = jo.joMasterID)))
        LEFT JOIN cuInvoice ci ON ((ci.joReleaseDetailID = joRD.joReleaseDetailID)))
        LEFT JOIN veBill vb ON ((vb.joReleaseDetailID = joRD.joReleaseDetailID)))
        LEFT JOIN veBill vbDetail ON ((vb.veBillID = vbDetail.veBillID)))
        LEFT JOIN veBillDistribution vBD ON ((vBD.joMasterID = jo.joMasterID)))
        LEFT JOIN veCommDetail vCD ON ((vCD.joReleaseDetailID = joRD.joReleaseDetailID)))
        LEFT JOIN cuSO so ON ((so.joReleaseID = joR.joReleaseID)))
        LEFT JOIN cuSODetail sod ON ((so.cuSOID = sod.cuSOID)))
        LEFT JOIN vePO po ON ((po.joReleaseID = joR.joReleaseID)))
        LEFT JOIN vePODetail pod ON ((po.vePOID = pod.vePOID)))
        LEFT JOIN rxMaster vn ON ((vn.rxMasterID = po.rxVendorID)))
        LEFT JOIN joStatus joS ON ((joS.joStatusID = jo.JobStatus)))
        LEFT JOIN joQuoteHeader q ON ((q.joMasterID = jo.joMasterID)))        
        LEFT JOIN cuMasterType cmt ON ((cmt.cuMasterTypeID = q.cuMasterTypeID)))
		LEFT  JOIN (SELECT MAX(QuoteRev) AS MaxQuoteRev, MAX(joQuoteHeaderID) AS MaxjoQuoteHeaderID, quoteTypeID FROM joQuoteHistory GROUP BY joMasterID,quoteTypeID) gL        
        ON((q.joQuoteHeaderID = gL.MaxjoQuoteHeaderID) AND(gL.quoteTypeID=cmt.cuMasterTypeID))
        LEFT JOIN joQuoteDetailMstr joQDM ON ((joQDM.joQuoteHeaderID = gL.MaxjoQuoteHeaderID)))
        LEFT JOIN joQuoteCategory joQCat ON ((joQCat.id = joQDM.category)))
        LEFT JOIN tsUserLogin u ON ((u.UserLoginID = q.CreatedByID)))
        LEFT JOIN joBidder b ON (((b.joMasterID = jo.joMasterID)
            AND (b.cuMasterTypeID = q.cuMasterTypeID))))
        LEFT JOIN rxContact c ON ((b.rxContactID = c.rxContactID)))
        LEFT JOIN rxContact rC ON ((jo.cuAssignmentID7 = rC.rxContactID)))
        LEFT JOIN joBidStatus bs ON ((bs.joBidStatusID = jo.joBidStatusID)))
        LEFT JOIN rxMaster rxb ON ((b.rxMasterID = rxb.rxMasterID)))
        
    WHERE ';
    
      if (_joMasterId is not null) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql,'jo.joMasterID =', _joMasterId); 
      set andNeeded =1;
       END IF;
     
      if (_startBidDate is not null) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql,'jo.BidDate >= \'', _startBidDate,'\''); 
      set andNeeded =1;
       END IF;
 
      if (_endBidDate is not null) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql,'jo.BidDate <=\'', _endBidDate,'\''); 
      set andNeeded =1;
       END IF;
    
      if (_jobStatus is not null) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql, 'find_in_set(jo.JobStatus,\'',_jobStatus,'\')'); 
      set andNeeded =1;
       END IF;

      if (_quoteType is not null AND _quoteType > 0) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql,'cmt.cuMasterTypeID =', _quoteType); 
      set andNeeded =1;
       END IF;

      if (_salesPersonId is not null AND _salesPersonId > 0) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql,'jo.cuAssignmentID0 =', _salesPersonId); 
      set andNeeded =1;
       END IF;
       
   if (_rxMasterId is not null AND _rxMasterId > 0) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      if (_startBookedDate is not null) THEN
	  set @l_sql = CONCAT(@l_sql,'vn.rxMasterID =', _rxMasterId); 
      else 
      set @l_sql = CONCAT(@l_sql,'joQDM.manufacturer =', _rxMasterId); 
      set andNeeded =1;
      END IF;
       END IF;
       
       if (_startBookedDate is not null) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql,'jo.BookedDate >= \'', _startBookedDate,'\''); 
      set andNeeded =1;
       END IF;
 
      if (_endBookedDate is not null) THEN
      IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql,' AND '); END IF; 
      set @l_sql = CONCAT(@l_sql,'jo.BookedDate <=\'', _endBookedDate,'\''); 
      set andNeeded =1;
       END IF;
       
		if (_groupBy is not null) THEN
        IF (andNeeded>0) THEN set @l_sql = CONCAT(@l_sql, If(LEFT(TRIM(LEADING FROM _groupBy) , 5) = 'GROUP','',' AND ')); END IF; 
        set @l_sql = CONCAT(@l_sql,_groupBy);
		set andNeeded =1;
       END IF;
       
    

    PREPARE stmt FROM @l_sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    
END$$

DELIMITER ;
-- ===========================================================================================
/* DROP PROCEDURE IF EXISTS `Project_InvoiceCostDetail`;
DELIMITER $$

CREATE PROCEDURE `Project_InvoiceCostDetail`(IN rxCustomerId INT,IN salesRepId INT,IN fromDate VARCHAR(50),IN toDate VARCHAR(50),IN `sortBy` VARCHAR(100))
BEGIN
/*SET @l_sql = 'SELECT  DISTINCT
info_userLoginID AS salesRepId,tsu.FullName AS salesRepName,ci.cuInvoiceId,DATE_FORMAT(ci.InvoiceDate, "%m/%d/%Y") as InvoiceDate,JobNumber,
CAST(ReleaseTypes AS SIGNED) AS joReleaseType,ReleaseTypeDescription,ci.InvoiceNumber,ci.InvoiceAmount,
info_rxCustomerID,rxm.Name AS customerName,InvoiceCostStock AS stockCost,InvoiceCostDrop AS poCost,
(InvoiceSubTotal+InvoiceFreight) AS InvoiceAmountWOTax,
(InvoiceSubTotal+InvoiceFreight)-(InvoiceCostStock+InvoiceCostDrop) AS profit,
ifnull(ROUND(ROUND_TO_EVEN((((InvoiceSubTotal+InvoiceFreight)-(InvoiceCostStock+InvoiceCostDrop))/(InvoiceSubTotal+InvoiceFreight)*100),2),2),0) AS margin
 FROM SalesCommissionView scv 
       LEFT JOIN tsUserLogin tsu ON(scv.info_userLoginID=tsu.UserLoginID)
       LEFT JOIN cuInvoice ci ON(scv.info_cuInvoiceID=ci.cuInvoiceId)
       LEFT JOIN rxMaster rxm ON(scv.info_rxCustomerID=rxm.rxMasterID)
WHERE RecordType=\'Invoice\' ';
SET @l_sql = 'SELECT ci.cuAssignmentID0 AS salesRepId,tsu.FullName AS salesRepName,ci.cuInvoiceId,DATE_FORMAT(ci.InvoiceDate, "%m/%d/%Y") AS InvoiceDate,
		jm.JobNumber,IF(ReleaseType IS NOT NULL,CAST(ReleaseType AS SIGNED),NULL) AS joReleaseType,jrt.Description AS ReleaseTypeDescription,
		ci.InvoiceNumber,ci.InvoiceAmount,ci.rxCustomerID AS info_rxCustomerID,
		rxm.Name AS customerName,IFNULL(ci.`CostTotal`, 0) AS `stockCost`,
		IFNULL(vb.BillAmount,0) AS poCost,(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0)) AS InvoiceAmountWOTax,
		(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)) AS profit,
		IFNULL(ROUND(ROUND_TO_EVEN((((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)))/(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))*100),2),2),0) AS margin
		 FROM cuInvoice ci
		LEFT JOIN tsUserLogin tsu ON(ci.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(ci.rxCustomerID=rxm.rxMasterID)
		LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
		LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
		LEFT JOIN joMaster jm ON(jr.joMasterID=jm.joMasterID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID)
		WHERE ci.cuAssignmentID0 IS NOT NULL and ci.cuAssignmentID0>0 ';
IF (rxCustomerId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.rxCustomerID=',rxCustomerId);
END IF;
IF (salesRepId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.cuAssignmentID0=',salesRepId);
END IF;
IF (fromDate IS NOT NULL AND fromDate<>'' AND (toDate IS NULL OR toDate='')) THEN
    SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
    SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate=\'',fromDate,'\'');
ELSE
	IF (fromDate IS NOT NULL AND fromDate<>'') THEN
		SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate>=\'',fromDate,' 00:00:00\'');
	END IF;
	IF (toDate IS NOT NULL AND toDate<>'') THEN
		SET toDate=DATE_FORMAT(toDate, "%Y-%m-%d");    
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate<=\'',toDate,' 23:59:59\'');
	END IF;
	
END IF;
IF (sortBy='SalesRep') THEN
	SET @l_sql=CONCAT(@l_sql,' order by salesRepId,InvoiceDate');
ELSE
	SET @l_sql=CONCAT(@l_sql,' order by info_rxCustomerID,InvoiceDate');
END IF;
-- select @l_sql ;
PREPARE stmt FROM @l_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$

DELIMITER ; */
-- =============================================
DROP PROCEDURE IF EXISTS `Project_InvoiceCostDetailSummary`;
DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `Project_InvoiceCostDetailSummary`(IN rxCustomerId INT,IN salesRepId INT,IN fromDate VARCHAR(50),IN toDate VARCHAR(50),IN `sortBy` VARCHAR(100))
BEGIN
SET @l_sql = 'SELECT ci.cuAssignmentID0 AS salesRepId,tsu.FullName AS salesRepName,
		ci.rxCustomerID AS info_rxCustomerID,
		rxm.Name AS customerName,SUM(IFNULL(ci.`CostTotal`, 0)) AS `stockCost`,
		SUM(IFNULL(vb.BillAmount,0)) AS poCost,SUM((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))) AS InvoiceAmountWOTax,
		SUM((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0))) AS profit,
		IFNULL(ROUND(ROUND_TO_EVEN((SUM((IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))-(IFNULL(ci.`CostTotal`, 0)+IFNULL(vb.BillAmount,0)))/SUM(IFNULL(ci.SubTotal,0)+IFNULL(ci.Freight,0))*100),2),2),0) AS margin
		 FROM cuInvoice ci
		LEFT JOIN tsUserLogin tsu ON(ci.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(ci.rxCustomerID=rxm.rxMasterID)
		LEFT JOIN joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN joRelease jr ON(jrd.joReleaseID=jr.joReleaseID)
		LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
		LEFT JOIN joMaster jm ON(jr.joMasterID=jm.joMasterID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
	 	WHERE ci.cuAssignmentID0 IS NOT NULL and ci.cuAssignmentID0>0 ';
IF (rxCustomerId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.rxCustomerID=',rxCustomerId);
END IF;
IF (salesRepId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and ci.cuAssignmentID0=',salesRepId);
END IF;
IF (fromDate IS NOT NULL AND fromDate<>'' AND (toDate IS NULL OR toDate='')) THEN
    SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
    SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate=\'',fromDate,'\'');
ELSE
	IF (fromDate IS NOT NULL AND fromDate<>'') THEN
		SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate>=\'',fromDate,' 00:00:00\'');
	END IF;
	IF (toDate IS NOT NULL AND toDate<>'') THEN
		SET toDate=DATE_FORMAT(toDate, "%Y-%m-%d");    
		SET @l_sql=CONCAT(@l_sql,' and ci.InvoiceDate<=\'',toDate,' 23:59:59\'');
	END IF;
	
END IF;

	SET @l_sql=CONCAT(@l_sql,' group by salesRepId ');

 SET @l_sql=CONCAT(@l_sql,'union all   ');
  SET @l_sql=CONCAT(@l_sql,'SELECT jm.cuAssignmentID0 AS salesRepId,tsu.FullName AS salesRepName,
		jm.rxCustomerID AS info_rxCustomerID,
		rxm.Name AS customerName,SUM(IFNULL(ci.`CostTotal`, 0)) AS `stockCost`,
		0 AS poCost,SUM((IFNULL(vec.CommAmount,0))) AS InvoiceAmountWOTax,
		SUM(IFNULL(vec.CommAmount,0)) AS profit,
		IFNULL(ROUND(ROUND_TO_EVEN(SUM(IFNULL(vec.CommAmount,0))*100,2),2),0) AS margin
		 FROM joMaster jm
         LEFT JOIN joRelease jr ON(jm.joMasterID=jr.joMasterID)
         LEFT JOIN joReleaseDetail jrd ON(jr.joReleaseID=jrd.joReleaseID)
         LEFT JOIN joReleaseType jrt ON(jr.ReleaseType=jrt.joReleaseTypeID)
         left join veCommDetail vec on (vec.joReleaseDetailID = jrd.joReleaseDetailID)
		LEFT JOIN tsUserLogin tsu ON(jm.cuAssignmentID0=tsu.UserLoginID)
		LEFT JOIN rxMaster rxm ON(jm.rxCustomerID=rxm.rxMasterID)
		left join cuInvoice ci ON(ci.joReleaseDetailID=jrd.joReleaseDetailID)
		LEFT JOIN veBill vb ON(ci.joReleaseDetailID=vb.joReleaseDetailID and vb.joReleaseDetailID > 0)
		WHERE jm.cuAssignmentID0 IS NOT NULL and jm.cuAssignmentID0>0');
        
        
        IF (rxCustomerId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and jm.rxCustomerID=',rxCustomerId);
END IF;
IF (salesRepId>0) THEN
	SET @l_sql=CONCAT(@l_sql,' and jm.cuAssignmentID0=',salesRepId);
END IF;
IF (fromDate IS NOT NULL AND fromDate<>'' AND (toDate IS NULL OR toDate='')) THEN
    SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
    SET @l_sql=CONCAT(@l_sql,' and vec.CommDate=\'',fromDate,'\'');
ELSE
	IF (fromDate IS NOT NULL AND fromDate<>'') THEN
		SET fromDate=DATE_FORMAT(fromDate, "%Y-%m-%d");
		SET @l_sql=CONCAT(@l_sql,' and vec.CommDate>=\'',fromDate,' 00:00:00\'');
	END IF;
	IF (toDate IS NOT NULL AND toDate<>'') THEN
		SET toDate=DATE_FORMAT(toDate, "%Y-%m-%d");    
		SET @l_sql=CONCAT(@l_sql,' and vec.CommDate<=\'',toDate,' 23:59:59\'');
	END IF;
	
END IF;

IF (sortBy='SalesRep') THEN
	SET @l_sql=CONCAT(@l_sql,' group by salesRepId order by salesRepName');
ELSE
	SET @l_sql=CONCAT(@l_sql,' group by salesRepId order by customerName');
END IF;
set @l_sql = CONCAT("select salesRepId,salesRepName,info_rxCustomerID,
customerName,sum(stockCost) as stockCost ,sum(poCost) as poCost,sum(InvoiceAmountWOTax) as InvoiceAmountWOTax,sum(profit) as profit,sum(margin) as margin
 from (",@l_sql,") as test group by salesRepId order by salesRepName asc");
-- select @l_sql ;
 PREPARE stmt FROM @l_sql;
 EXECUTE stmt;
 DEALLOCATE PREPARE stmt;
END$$

DELIMITER ;


-- ================================================================


DROP procedure IF EXISTS `back_averagecost`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `back_averagecost`(
IN veBillID INT(10)
)
back_averagecost:BEGIN

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
DECLARE _newAverageCost decimal(19,4);
DECLARE _tpInventoryLogID INT;
DECLARE _newOnHand decimal(19,4);
DECLARE _oldonHand decimal(19,4);
DECLARE _oldaverageCost decimal(19,4);
DECLARE _oldTotalValue decimal(19,4);
DECLARE _newTotalValue decimal(19,4);

SET SESSION group_concat_max_len = 1000000; 


select sum(QuantityBilled),GROUP_CONCAT(vb.veBillDetailID),ve.PONumber into _count,_ids,_PONumber  from veBillDetail vb
            left join prMaster pr on  pr.prMasterID = vb.prMasterID
            left join veBill vl on vb.veBillID = vl.veBillID
            left join vePO ve on ve.vePOID = vl.vePOID
            where vb.veBillID = veBillID and pr.IsInventory = 1 ;
            
            
            set _freightDistributionAll = _Freight/_count;
			
            do_this:
			loop	
                set _id = null;
				SET strLen = CHAR_LENGTH(_ids);
				set _id=SUBSTRING_INDEX(_ids, ',', 1);
                select ROUND_TO_EVEN(IFNULL(UnitCost*QuantityBilled*IF((PriceMultiplier IS NULL || PriceMultiplier=0),1,PriceMultiplier),0),2),
                prMasterID, QuantityBilled
                into _totalcost,_prMasterID,_QuantityBilled from veBillDetail where veBillDetailID = _id;
				set   _freightDistribution = _freightDistributionAll*_QuantityBilled;
                set _newAverageCost = (_totalcost+_freightDistribution)/_QuantityBilled;
                Select MAX(tpInventoryLogID) into _tpInventoryLogID from tpInventoryLogMaster where prMasterID=_prMasterID AND refRelatedNo=_PONumber AND transType ='RI';
                select onHand into _newOnHand from tpInventoryLogMaster where tpInventoryLogID = _tpInventoryLogID;
                set _oldonHand = _newOnHand - _QuantityBilled;
                select AverageCost into _oldaverageCost from prMaster where prMasterID = _prMasterID;
                set _oldTotalValue = _oldonHand*_oldaverageCost;
                set _newTotalValue = _QuantityBilled*_newAverageCost;
                set _averageCost = (_oldTotalValue+_newTotalValue)/_newOnHand;
                update prMaster set AverageCost = _averageCost where prMasterID = _prMasterID;
                SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_ids, ',', 1))+2;
				SET _ids = MID(_ids, SubStrLen, strLen);
				IF (_ids = '' or _ids is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
            
            
	
END$$

DELIMITER ;

-- =============================================

DROP procedure IF EXISTS `INV_maintenance`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `INV_maintenance`(
IN _action varchar(25),
IN _prMasterID INT,
IN _prDepartmentID INT,
IN _prCategoryID INT,
IN _rxMasterIDPrimaryVendor INT,
IN _sellingPrice decimal(19,4),
IN _multiplier decimal(19,4),
IN _factoryCost decimal(19,4)
)
INV_maintenance:BEGIN	
 
DECLARE _updatePrMasterIDS longtext;
DECLARE _updateID INT;
DECLARE _salesprice1 decimal(19,4);
DECLARE _POMult decimal(19,4);
DECLARE _lastCost decimal(19,4);
DECLARE strLen    INT DEFAULT 0;
DECLARE SubStrLen INT DEFAULT 0;

SET SESSION group_concat_max_len = 1000000; 

        if(_action = "UPDATE") then

			set @l_sql = "select group_concat(prMasterID) into @_updatePrMasterIDS   from prMaster where IsInventory = 1 and InActive= 0 ";
    
    
			if (_prMasterID is not null and _prMasterID != '-1' ) then 
				set @l_sql = concat(@l_sql," and prMasterID = ", _prMasterID) ;
            end if;
            
            if (_prDepartmentID is not null and _prDepartmentID != '-1') then 
				set @l_sql = concat(@l_sql," and prDepartmentID  = ", _prDepartmentID) ;
            end if;
            
            if (_prCategoryID is not null and _prCategoryID != '-1') then 
				set @l_sql = concat(@l_sql," and prCategoryID = ", _prCategoryID) ;
            end if ;
            
            if (_rxMasterIDPrimaryVendor is not null and _rxMasterIDPrimaryVendor != '-1') then 
				set @l_sql = concat(@l_sql," and rxMasterIDPrimaryVendor  = ", _rxMasterIDPrimaryVendor) ;
            end if ;
            
		end if;
			
            prepare stmt from @l_sql;
            execute stmt ;
            deallocate prepare stmt;
            
            
   
            do_this:
			LOOP
				SET strLen = CHAR_LENGTH(@_updatePrMasterIDS);
				set _updateID=SUBSTRING_INDEX(@_updatePrMasterIDS, ',', 1);

                update prMaster set 
                SalesPrice00 = if(_sellingPrice is not null AND _sellingPrice > 0 AND SalesPrice00 is not null AND SalesPrice00 > 0 , (SalesPrice00*_sellingPrice)/100 , SalesPrice00),
                POMult = if(_multiplier is not null AND _multiplier > 0 AND POMult is not null AND POMult > 0 , (POMult*_multiplier)/100 , POMult),
                LastCost = if(_factoryCost is not null AND _factoryCost > 0 AND LastCost is not null AND LastCost > 0 , (LastCost*_factoryCost)/100 , LastCost)
                where prMasterID = _updateID ;

				SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(@_updatePrMasterIDS, ',', 1))+2;
				SET @_updatePrMasterIDS = MID(@_updatePrMasterIDS, SubStrLen, strLen);
				IF (@_updatePrMasterIDS = '' or @_updatePrMasterIDS is null) THEN
				   LEAVE do_this;
				END IF;
                    
			END LOOP do_this; 
   
END$$

DELIMITER ;




-- =============================================
-- call NOTIFICATION_notification('INSERT',5,3250,'baggarisiva@gmail.com','baggarisiva@gmail.com','Pick Ticket #111127 [test4]','test','javax.net.ssl.SSLSocketFactory','','',111127,'PickTicket_111127_[test4].pdf','','SalesOrder_111127.pdf',NULL,'SO');
-- call NOTIFICATION_notification('MAILSEND',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
-- call NOTIFICATION_notification('GETMAIL',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
-- call NOTIFICATION_notification('FAILEDUPDATE',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
-- call NOTIFICATION_notification('UPDATE',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
-- call NOTIFICATION_notification('CREATE',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
-- call NOTIFICATION_notification('RESEND',null,null,null,'baggarisiva@gmail.com',','Pick Ticket #111127 [test4]','test',null,null,null,null,null,null,378,null);

DROP procedure IF EXISTS `NOTIFICATION_notification`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `NOTIFICATION_notification`(
IN _action VARCHAR(30),
IN _userLoginId INT,
IN _contactID INT,
IN _fromEmailId VARCHAR(100), 
IN _toEmailId VARCHAR(100), 
IN _subject LONGTEXT,
IN _content LONGTEXT,
IN _SSL_FACTORY VARCHAR(100),
IN _JobNumber VARCHAR(100),
IN _BCCAddr VARCHAR(100),
IN _PONumber VARCHAR(100),
IN _file VARCHAR(100),
IN _ccaddress VARCHAR(100),
IN _writepdfname VARCHAR(100),
IN _id INT,
IN _pdfType VARCHAR(40),
IN _fileAttachment1 VARCHAR(300),
IN _fileAttachment2 VARCHAR(300),
IN _fileAttachment3 VARCHAR(300),
IN _readyOn VARCHAR(300)
)
NOTIFICATION_notification: BEGIN

	declare _valueInt INT;
    declare _mailService varchar(45);
    declare corr_Id INT;
    declare _found INT;
    declare _tryes INT;
	 declare _ackOfOtp INT;
     declare _isAdmin INT;
    declare _resetpassword varchar(225);
    declare _mailAddress varchar(255);
    
    
	IF(_action IS NULL ) THEN
		SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call NOTIFICATION_notification: _action can not be empty';
		LEAVE NOTIFICATION_notification;
	END IF;
    
	IF(_action ='INSERT') THEN
		INSERT into tsUser_global_notification (userLoginId,contactId,fromEmailId,toEmailId,
        `subject`,content,SSL_FACTORY,JobNumber,BCCAddr,
        PONumber,filename,ccaddress,writepdfname,pdfType, fileAttachment1, fileAttachment2, fileAttachment3, readyOn,createdOn)
		values
		(_userLoginId,_contactID,_fromEmailId,_toEmailId,
        _subject, _content, _SSL_FACTORY, _JobNumber, _BCCAddr,
        _PONumber, _file, _ccaddress, _writepdfname,_pdfType, _fileAttachment1, _fileAttachment2, _fileAttachment3, _readyOn,now());
	
		
	ELSEIF(_action ='MAILSEND') THEN
		select valueInt from att_configuration
		where configKey = 'NOTIFICATION_ENABLED';

	ELSEIF(_action = 'ATTACHMENTCORUPTTED') THEN
		UPDATE tsUser_global_notification set statusId = 2 where id = _id;
		
		SELECT tsUser_notification_Id INTO _found FROM ts_Correspondance
            WHERE tsUser_notification_Id = _id;
			if(_found > 0) then
				UPDATE ts_Correspondance SET  createdOn = now(), errMessage = _file,errCode = _ccaddress, message = _writepdfname WHERE tsUser_notification_Id = _found ;
			else
				INSERT into ts_Correspondance(tsUser_notification_Id,tsUserLoginId,contactId,fromEmail,toEmail,PONumber,createdOn,message,pdfType, errMessage, errCode)
				values (id,_userLoginId,_contactID,_fromEmailId,_toEmailId,_PONumber,now(),_writepdfname,_pdfType, _file, _ccaddress);
			end if;
		

	ELSEIF(_action ='GETMAIL') THEN
		select service into _mailService from att_configuration
		where configKey = 'NOTIFICATION_ENABLED';
			
		SELECT _mailService, ts.*, login.* 	FROM tsUserLogin AS login
		RIGHT JOIN tsUser_global_notification ts ON ts.userLoginId = login.UserLoginID
		WHERE ts.statusId = 0 AND ts.tryes < 3 LIMIT 100;

	ELSEIF(_action = 'FAILEDUPDATE') THEN
		UPDATE  tsUser_global_notification SET tryes = tryes + 1, changedOn = now() where id = _id and statusId = 0;
		SELECT tryes INTO _tryes FROM tsUser_global_notification
        WHERE statusId = 0 AND tryes = 3 AND id = _id;
		IF(_tryes = 3) THEN
			UPDATE tsUser_global_notification set statusId = 1 where tryes =3 and id = _id;
			SELECT tsUser_notification_Id INTO _found FROM ts_Correspondance
            WHERE tsUser_notification_Id = _id;
			if(_found > 0) then
				UPDATE ts_Correspondance SET  createdOn = now(), errMessage = _file,errCode = _ccaddress WHERE tsUser_notification_Id = _found ;
			else
				INSERT into ts_Correspondance(tsUser_notification_Id,tsUserLoginId,contactId,fromEmail,toEmail,PONumber,createdOn,message,pdfType, errMessage, errCode)
				values (_id,_userLoginId,_contactID,_fromEmailId,_toEmailId,_PONumber,now(),_writepdfname,_pdfType, _file, _ccaddress);
			end if;
		END IF;
        
	ELSEIF(_action ='UPDATE') THEN
		UPDATE tsUser_global_notification SET statusId = 1, changedOn = now() where statusId = 0 and id = _id;
		SELECT tsUser_notification_Id INTO _found FROM ts_Correspondance
        WHERE tsUser_notification_Id = _id;
		if(_found > 0) then
			UPDATE ts_Correspondance SET createdOn = now(), message = _writepdfname,pdfType = _pdfType,errMessage = null,errCode = null WHERE tsUser_notification_Id = _found;        
		else          
			INSERT into ts_Correspondance(tsUser_notification_Id,tsUserLoginId,contactId,fromEmail,toEmail,PONumber,createdOn,message,pdfType)
			values (_id,_userLoginId,_contactID,_fromEmailId,_toEmailId,_PONumber,now(),_writepdfname,_pdfType);
		end if;

	ELSEIF(_action = 'CREATE') THEN 
		SELECT ADMIN INTO _isAdmin FROM tsUserLogin WHERE UserLoginID = _userLoginId;
		SET @l_sql = concat('SELECT results.*,
        DATE_FORMAT(results.changedOnDate, "%m/%d/%Y") as `date`,
		DATE_FORMAT(results.changedOnDate, "%h:%i %p") as time
        FROM (
		select if(ts.changedOn is null, ts.createdOn, ts.changedOn)  as changedOnDate,
        ts.tryes as `Tryes`, ts.toEmailId as toEmail, ts.`subject`, if(corr.message = "SUCCESS", "SENT", "FAILED") as report, ts.id, corr.errMessage, corr.errCode
        FROM tsUser_global_notification  ts
        LEFT JOIN  ts_Correspondance corr ON (corr.tsUser_notification_Id = ts.Id) WHERE (ts.statusId = 1 or ts.statusId = 2) ');
        
        IF(_isAdmin = 0) THEN
			SET @l_sql = concat(@l_sql, ' and ts.userLoginId = ', _userLoginId );
			 SET @l_sql = concat(@l_sql, ' and ts.createdOn > ',"'",now() - interval 1 month ,"'");
		ELSE
			 SET @l_sql = concat(@l_sql, ' and ts.createdOn > ',"'",now() - interval 1 month ,"'" );
        END IF;
								
		SET @l_sql = concat(@l_sql, ' group by ts.id order by changedOnDate desc) as results;');
        
          

		 PREPARE stmt FROM @l_sql;
		 EXECUTE stmt;
		 DEALLOCATE PREPARE stmt;
 
    
    ELSEIF(_action = 'RESEND' AND _id IS NOT NULL) THEN
		SET @l_sql = concat('UPDATE tsUser_global_notification SET statusId = 0, tryes = 0 ');
        
        IF(_toEmailId IS NOT NULL) THEN
			SET @l_sql = concat(@l_sql, ', toEmailId = \'', _toEmailId, '\'');
		END IF;
        
        IF(_subject IS NOT NULL) THEN
			SET @l_sql = concat(@l_sql, ', `subject` = \'', _subject, '\'');
		END IF;
        
        IF(_content IS NOT NULL) THEN
			SET @l_sql = concat(@l_sql, ', content = \'', _content, '\'');
		END IF;
        
		SET @l_sql = concat(@l_sql, ', changedOn = \'', now(), '\' where id = ', _id, ';');
        
        PREPARE stmt FROM @l_sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
        
        SELECT toEmailID AS EMAIL, `subject`, content FROM tsUser_global_notification 
        WHERE id = _id;

	ELSEIF(_action = 'GETCOUNT') THEN 
    
		SELECT ADMIN INTO _isAdmin FROM tsUserLogin WHERE UserLoginID = _userLoginId;
		SET @l_sql = "SELECT COUNT(*) AS FAILED_COUNT FROM 
        (SELECT report FROM (SELECT IF(corr.message = 'SUCCESS', 'SENT', 'FAILED') as report
        FROM tsUser_global_notification  ts
        LEFT JOIN  ts_Correspondance corr ON (corr.tsUser_notification_Id = ts.Id) 
		WHERE ((ts.statusId = 1 and ts.tryes = 3) or (ts.statusId = 2))";
       
        IF(_isAdmin = 1) THEN
        SET @l_sql = concat(@l_sql, ' and ts.createdOn > ',"'",now() - interval 1 month ,"'" );
			SET @l_sql = concat(@l_sql, " group by ts.id) as STATUS WHERE report = 'FAILED') AS TEMP");
		ELSE 
			SET @l_sql = concat(@l_sql, ' and ts.createdOn > ',"'",now() - interval 1 month ,"'" );
			SET @l_sql = concat(@l_sql, 'and ts.userLoginId = ', _userLoginId, " group by ts.id) as STATUS WHERE report = 'FAILED') AS TEMP");
        END IF;
       
        PREPARE stmt FROM @l_sql;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;

	ELSEIF(_action  = 'SENDOTP') THEN
		select entity_loginFailedAttempts,ack_forOtp into _tryes,_ackOfOtp from tsUserLogin where BINARY LoginName = _fromEmailId and BINARY LoginPassword = _toEmailId;
		if(_tryes < 3) then
			UPDATE tsUserLogin SET entity_loginFailedAttempts =entity_loginFailedAttempts+ 1, entity_loginEmailValidationCode=LPAD(FLOOR(RAND() * 999999.99), 4, '0') where LoginName = _fromEmailId and LoginPassword = _toEmailId;
			select *, _tryes from tsUserLogin where LoginName = _fromEmailId and LoginPassword = _toEmailId;
			else select _tryes;
		end if;

	ELSEIF(_action = 'RESET_TRIES') THEN
		UPDATE tsUserLogin SET entity_loginFailedAttempts = 0 where UserLoginID = _userLoginId;
		select entity_loginFailedAttempts from tsUserLogin where UserLoginID = _userLoginId;
    ELSEIF(_action = 'RESETPASSWORD') THEN
        select LoginPassword,EmailAddr into _resetpassword,_mailAddress from tsUserLogin where LoginName = _fromEmailId and EmailAddr = _toEmailId;
        select _resetpassword,_mailAddress;
    END IF;
END$$

DELIMITER ;




-- =============================================
-- =============================================
call INV_createBinsFromWarehouseInventory('INIT',null,null); 



call INV_createCuSODetailBins('INIT');

call INV_createTransferBins('UPDATEDATE');
call INV_createTransferBins('INIT');
call INV_createTransferBins('REMOVETOBIN');
call INV_createVirtualbin(null);
select 'SUCCESS PROCEDURE CREATION!!';
select * from tp_version;