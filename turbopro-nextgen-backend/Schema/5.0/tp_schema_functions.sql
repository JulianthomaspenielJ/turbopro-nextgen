
update tp_version set functionVersion=3,functionVersionDesc='Created new Function calculateSingleTaxAmount' where versionId >0;



-- ==============================================  
-- select GL_buildAccountName('3000-01-000-100','02');
-- select GL_buildAccountName('3000-01-000','02');
-- select GL_buildAccountName('3000-01','02');
-- select GL_buildAccountName('3000','02');

DROP FUNCTION IF EXISTS `GL_buildAccountName`;

DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GL_buildAccountName`(_acctNumber varchar(100), _subAccountNumber varchar(10)) RETURNS varchar(100) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
DECLARE _nextStart INT DEFAULT 0;
DECLARE _partLength INT DEFAULT 0;
DECLARE _partName VARCHAR(45) default '';
DECLARE _divName VARCHAR(45) default '';
DECLARE _accountName VARCHAR(45) default '';
DECLARE _departmentName VARCHAR(45) default '';
DECLARE _otherName VARCHAR(45) default '';
DECLARE _formatted VARCHAR(45) default '';

set _partName = _acctNumber;

-- account
set _partLength = CHAR_LENGTH(_partName);
set _accountName = SUBSTRING_INDEX(_partName, '-', 1);

-- division
set _nextStart = CHAR_LENGTH(SUBSTRING_INDEX(_partName, '-', 1))+2;
set _partName = MID(_partName, _nextStart, _partLength);
set _divName = SUBSTRING_INDEX(_partName, '-', 1);

if (_subAccountNumber is not null and CHAR_LENGTH(_subAccountNumber)>1) THEN
	set _divName = _subAccountNumber;
END IF;

-- department
set _partLength = CHAR_LENGTH(_partName);
set _nextStart = CHAR_LENGTH(SUBSTRING_INDEX(_partName, '-', 1))+2;
set _partName = MID(_partName, _nextStart, _partLength);
set _departmentName = SUBSTRING_INDEX(_partName, '-', 1);

-- other
set _partLength = CHAR_LENGTH(_partName);
set _nextStart = CHAR_LENGTH(SUBSTRING_INDEX(_partName, '-', 1))+2;
set _partName = MID(_partName, _nextStart, _partLength);
set _otherName = SUBSTRING_INDEX(_partName, '-', 1);


if (CHAR_LENGTH(_otherName)>1) THEN
	set _formatted = concat(_accountName,'-',_divName,'-',_departmentName,'-',_otherName);
elseif (CHAR_LENGTH(_departmentName)>1) THEN
	set _formatted = concat(_accountName,'-',_divName,'-',_departmentName);
elseif (CHAR_LENGTH(_divName)>1) THEN
	set _formatted = concat(_accountName,'-',_divName);
else
	set _formatted = concat(_accountName);     
end if;

RETURN _formatted;
END //
DELIMITER ;


-- ==============================================  

-- select GL_determineAccountNumber('3000-02-000',181);

DROP FUNCTION IF EXISTS `GL_determineAccountNumber`;

DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `GL_determineAccountNumber`(_acctNumber varchar(100), _originalAccountID INT) RETURNS INT 
    DETERMINISTIC
BEGIN
DECLARE _accountId INT DEFAULT 0;
DECLARE _coAccountID INT DEFAULT 0;

select coAccountID into _coAccountID from coAccount where Number =_acctNumber limit 1;

if (_coAccountID is not null) then 
	set _accountId=_coAccountID;
else
	set _accountId=_originalAccountID;
end if;

RETURN _accountId;
END //
DELIMITER ;


-- ==============================================




DROP FUNCTION IF EXISTS RECEIVE_getBinRecommendedPutAway;

DELIMITER //
CREATE FUNCTION `RECEIVE_getBinRecommendedPutAway`(_prMasterID INT, _prWarehouseID INT, _quantityOrdered INT) RETURNS int
    DETERMINISTIC
BEGIN
DECLARE _return INT default 0;
DECLARE _allocated INT default 0;

select sum(InventoryAllocated) -  sum(InventoryOnHand) into _allocated from bin 
where prMasterID=_prMasterID and prWarehouseID=_prWarehouseID and binSequence !=1;

set _return = _quantityOrdered - ifnull(_allocated,0);

if (_return <=0 ) then set _return=0; END IF;

RETURN _return;
END //
DELIMITER ;

-- ==============================================  
-- select INV_getYearToDateSold(879,1);

DROP FUNCTION IF EXISTS `INV_getYearToDateSold`;

DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `INV_getYearToDateSold`(_prMasterID INT, _prWarehouseID INT) RETURNS decimal(19,4)
    DETERMINISTIC
BEGIN
DECLARE _formatted decimal(19,4) default 0;

 SELECT 
                        SUM(`cud`.`QuantityBilled`)
                        into _formatted
                    FROM
                        (((`cuInvoiceDetail` `cud`
                        LEFT JOIN `cuInvoice` `cu` ON ((`cud`.`cuInvoiceID` = `cu`.`cuInvoiceID`)))
                        LEFT JOIN `joReleaseDetail` `jrd` ON ((`jrd`.`joReleaseDetailID` = `cu`.`joReleaseDetailID`)))
                        LEFT JOIN `joRelease` `jo` ON ((`jo`.`joReleaseID` = `jrd`.`joReleaseID`)))
                    WHERE
                        ((`cud`.`prMasterID` = _prMasterID)
                            AND (`cu`.`prFromWarehouseID` = _prWarehouseID)
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
                            OR (`cu`.`joReleaseDetailID` = 0)));

RETURN IFNULL(_formatted,0);
END //
DELIMITER ;

 -- ==============================================  

-- select PO_getOnOrder(770);

DROP FUNCTION IF EXISTS `PO_getOnOrder`;

DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `PO_getOnOrder`(_prMasterID INT) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE _formatted int default 0;

select sum(d.QuantityOrdered) into _formatted from 
(
SELECT ifnull(sum(QuantityOrdered - QuantityReceived),0) AS QuantityOrdered FROM vePODetail d
left join vePO p on (p.vePOID = d.vePOID)
 where QuantityOrdered > QuantityReceived
 and joReleaseID is null
 and p.vePOID is not null
 and p.TransactionStatus = 1
	and prMasterID=_prMasterID 
    union all 
    SELECT D.QuantityTransfered AS QuantityOrdered 
			FROM prWarehouse 
			INNER JOIN prWHtransfer H ON prWarehouse.prWarehouseID = H.prToWareHouseID JOIN prWHtransferDetail D ON H.prTransferID = D.prTransferID 
			LEFT JOIN prMaster pr ON(D.prMasterID=pr.prMasterID) WHERE (H.ReceivedDate IS NULL) AND  (D.ReceivedDate IS NULL) 
			AND D.prMasterID = _prMasterID
            ) as d
    ;

RETURN _formatted;
END //

 -- ==============================================
DROP function IF EXISTS `PO_getOnOrder_warehouse`;

DELIMITER $$

CREATE DEFINER=`root`@`%` FUNCTION `PO_getOnOrder_warehouse`(_prMasterID int,_warehouseID int) RETURNS decimal(19,4)
BEGIN
DECLARE _formatted int default 0;


SELECT ifnull(sum(QuantityOrdered - QuantityReceived),0) into _formatted FROM vePODetail d
left join vePO p on (p.vePOID = d.vePOID)
 where QuantityOrdered > QuantityReceived
 and joReleaseID is null
 and p.vePOID is not null
 and p.TransactionStatus = 1 and p.prWarehouseID = _warehouseID
	and prMasterID=_prMasterID;

RETURN _formatted;
END$$

DELIMITER ;

 -- ==============================================

DELIMITER $$

DROP FUNCTION IF EXISTS `calculateSingleTaxAmount`$$

CREATE FUNCTION `calculateSingleTaxAmount`(_cuInvoiceId INT) RETURNS DECIMAL(19,4)
BEGIN

DECLARE _taxID INT;DECLARE _totalAmount DECIMAL(19,4);DECLARE _frieght DECIMAL(19,4);DECLARE _taxRate DECIMAL(19,4);
DECLARE _taxrate2 DECIMAL(19,4);DECLARE _taxrate3 DECIMAL(19,4);DECLARE _taxrate4 DECIMAL(19,4);DECLARE _taxrate5 DECIMAL(19,4);DECLARE _taxrate6 DECIMAL(19,4);
DECLARE _from2 DECIMAL(19,4);DECLARE _from3 DECIMAL(19,4);DECLARE _from4 DECIMAL(19,4);DECLARE _from5 DECIMAL(19,4);DECLARE _from6 DECIMAL(19,4);
DECLARE _to2 DECIMAL(19,4);DECLARE _to3 DECIMAL(19,4);DECLARE _to4 DECIMAL(19,4);DECLARE _to5 DECIMAL(19,4);DECLARE _to6 DECIMAL(19,4);
DECLARE _taxRate2Total DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate3Total DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate4Total DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate5Total DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate6Total DECIMAL(19,4) DEFAULT 0.00;
DECLARE _taxRate2Diff DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate3Diff DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate4Diff DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate5Diff DECIMAL(19,4) DEFAULT 0.00;DECLARE _taxRate6Diff DECIMAL(19,4) DEFAULT 0.00;
DECLARE _singleTaxAmount DECIMAL(19,4) DEFAULT 10.00;
SELECT coTaxTerritoryId,SubTotal,Freight INTO _taxID,_totalAmount,_frieght FROM cuInvoice WHERE cuInvoiceId=_cuInvoiceId;

IF (_taxID IS NOT NULL AND _taxID>0) THEN
	SELECT TaxRate,IFNULL(Rate2,0),IFNULL(Rate3,0),IFNULL(Rate4,0),IFNULL(Rate5,0),IFNULL(Rate6,0),IFNULL(From2,0),IFNULL(From3,0),IFNULL(From4,0),IFNULL(From5,0),IFNULL(From6,0) INTO _taxRate,_taxrate2,_taxrate3,_taxrate4,_taxrate5,_taxrate6,_from2,_from3,_from4,_from5,_from6 FROM coTaxTerritory WHERE coTaxTerritoryID=_taxID;
	IF (_from3 IS NOT NULL && _from3 <> 0) THEN 
		SET _to2 = _from3 - 0.01;
	END IF;
	IF (_from4 IS NOT NULL && _from4 <> 0) THEN 
		SET _to3 = _from4 - 0.01;
	END IF;
	IF (_from5 IS NOT NULL && _from5 <> 0) THEN 
		SET _to4 = _from5 - 0.01;
	END IF;
	IF (_from6 IS NOT NULL && _from6 <> 0) THEN 
		SET _to5 = _from6 - 0.01;
	END IF;
	SET _totalAmount=ABS(_totalAmount);
ELSE
	SET _totalAmount=ABS(_totalAmount);
END IF;

IF (_totalAmount<>0) THEN
	IF (_taxRate2 IS NOT NULL && _taxRate2 <> "" && _taxRate2<>0)THEN
		IF (_from2 IS NOT NULL &&_from2 >= 0 && _to2 <= _totalAmount)THEN
			SET _taxRate2Diff = _to2 - _from2;
		ELSE
			SET _taxRate2Diff = (_totalAmount - _from2);  
		END IF;
		SET _taxRate2Total = (_taxRate2Diff * _taxRate2) / 100;
	END IF;
	IF (_taxRate3 IS NOT NULL && _taxRate3 <> "" && _taxRate3<>0)THEN
		IF (_to3 <= _totalAmount)THEN
			SET _taxRate3Diff = _to3 - _from3;
		ELSEIF(_from3<_totalAmount) THEN
			SET _taxRate3Diff = (_totalAmount - _from3);  
		END IF;
		SET _taxRate3Total = (_taxRate3Diff * _taxRate3) / 100;
	END IF;
	IF (_taxRate4 IS NOT NULL && _taxRate4 <> "" && _taxRate4<>0)THEN
		IF (_to4 <= _totalAmount)THEN
			SET _taxRate4Diff = _to4 - _from4;
		ELSEIF(_from4<_totalAmount) THEN
			SET _taxRate4Diff = (_totalAmount - _from4);  
		END IF;
		SET _taxRate4Total = (_taxRate4Diff * _taxRate4) / 100;
	END IF;
	IF (_taxRate5 IS NOT NULL && _taxRate5 <> "" && _taxRate5<>0)THEN
		IF (_to5 <= _totalAmount)THEN
			SET _taxRate5Diff = _to5 - _from5;
		ELSEIF(_from5<_totalAmount) THEN
			SET _taxRate5Diff = (_totalAmount - _from5);  
		END IF;
		SET _taxRate5Total = (_taxRate5Diff * _taxRate5) / 100;
	END IF;
	IF (_taxRate6 IS NOT NULL && _taxRate6 <> "" && _taxRate6<>0)THEN
		IF (_to6 <= _totalAmount)THEN
			SET _taxRate6Diff = _to6 - _from6;
		ELSEIF(_from6<_totalAmount) THEN
			SET _taxRate6Diff = (_totalAmount - _from6);  
		END IF;
		SET _taxRate6Total = (_taxRate6Diff * _taxRate6) / 100;
	END IF;
	
END IF;
IF (_totalAmount<0) THEN
            	SET _taxRate2Total = _taxRate2Total * -1;
            	SET _taxRate3Total = _taxRate3Total * -1;
            	SET _taxRate4Total = _taxRate4Total * -1;
            	SET _taxRate5Total = _taxRate5Total * -1;
            	SET _taxRate6Total = _taxRate6Total * -1;
            	SET _totalAmount = _totalAmount * -1;
END IF;

SET _singleTaxAmount=_taxRate2Total+_taxRate3Total+_taxRate4Total+_taxRate5Total+_taxRate6Total;
RETURN ROUND_TO_EVEN(_singleTaxAmount,2);
 END$$

DELIMITER ;


-- ====================================



DROP FUNCTION IF EXISTS F_InvoiceCostDrop;

DELIMITER //
CREATE FUNCTION `F_InvoiceCostDrop`(_joReleaseDetailID INT, _cuInvoiceID INT) RETURNS decimal(19,4)
    DETERMINISTIC
BEGIN

DECLARE _result1 decimal(19,4) DEFAULT 0.0000;
DECLARE _result2 decimal(19,4) DEFAULT 0.0000;
DECLARE _result decimal(19,4) DEFAULT 0.0000;

if (_joReleaseDetailID>0) THEN
select IFNULL((SELECT 
					-- count(*)

                         `veBill`.`BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = _joReleaseDetailID)),
                0) into _result1;
END IF;
                
select IFNULL((SELECT 
                        SUM(`veBill`.`BillAmount`)
                    FROM
                       `veBill`
                    WHERE
                        (`veBill`.`cuInvoiceID_ApplyCost` = _cuInvoiceID)
                    GROUP BY `veBill`.`cuInvoiceID_ApplyCost`),
                0) into _result2;
    

RETURN _result1+_result2;
-- RETURN _result1;
END //
DELIMITER ;