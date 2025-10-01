
use TP_struct;

-- ==============================================

-- call ETL_TURBOREP_121('ETL',0);
-- call ETL_TURBOREP_12M('ETL',0);
-- call ETL_TURBOREP_121Delta('ETL',0);

DROP procedure IF EXISTS `ETL_TURBOREP_BASIC`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_TURBOREP_BASIC`(
	IN _action varchar(25),
	IN _truncate int
    )
ETL_TURBOREP_BASIC : BEGIN

if (_truncate=1) THEN truncate table `coAccount`; END IF;


INSERT IGNORE INTO `coAccount`
(`coAccountID`,
`InActive`,
`Number`,
`Description`,
`BalanceSheetColumn`,
`IncludeWhenZero`,
`DebitBalance`,
`ContraAccount`,
`LineAboveAmount`,
`LineBelowAmount`,
`TotalingLevel`,
`VerticalSpacing`,
`HorizontalSpacing`,
`FontLarge`,
`FontBold`,
`FontItalic`,
`FontUnderline`,
`Tax1099`,
`SubAccount`,
`IsSubAccount`,
`IsMasterAccount`,
`DollarSign`
-- `accountType`,
-- `openingBalance`,
-- `FinancialStatus`
)
SELECT `coAccount`.`coAccountID`,
    `coAccount`.`InActive`,
    `coAccount`.`Number`,
    `coAccount`.`Description`,
    `coAccount`.`BalanceSheetColumn`,
    `coAccount`.`IncludeWhenZero`,
    `coAccount`.`DebitBalance`,
    `coAccount`.`ContraAccount`,
    `coAccount`.`LineAboveAmount`,
    `coAccount`.`LineBelowAmount`,
    `coAccount`.`TotalingLevel`,
    `coAccount`.`VerticalSpacing`,
    `coAccount`.`HorizontalSpacing`,
    `coAccount`.`FontLarge`,
    `coAccount`.`FontBold`,
    `coAccount`.`FontItalic`,
    `coAccount`.`FontUnderline`,
    `coAccount`.`Tax1099`,
    `coAccount`.`SubAccount`,
    `coAccount`.`IsSubAccount`,
    `coAccount`.`IsMasterAccount`,
    `coAccount`.`DollarSign`
FROM `Hvac_company`.`coAccount`;

select 'coAccount',count(*) from coAccount;

if (_truncate=1) THEN truncate table `coBalance`; END IF;

INSERT INTO `coBalance`
(`coBalanceID`,
`coAccountID`,
`coFiscalPeriodID`,
`YearOpening`,
`YearDebits`,
`YearCredits`,
`QuarterOpening`,
`QuarterDebits`,
`QuarterCredits`,
`PeriodOpening`,
`PeriodDebits`,
`PeriodCredits`)
SELECT `coBalance`.`coBalanceID`,
    `coBalance`.`coAccountID`,
    `coBalance`.`coFiscalPeriodID`,
    `coBalance`.`YearOpening`,
    `coBalance`.`YearDebits`,
    `coBalance`.`YearCredits`,
    `coBalance`.`QuarterOpening`,
    `coBalance`.`QuarterDebits`,
    `coBalance`.`QuarterCredits`,
    `coBalance`.`PeriodOpening`,
    `coBalance`.`PeriodDebits`,
    `coBalance`.`PeriodCredits`
FROM `Hvac_company`.`coBalance`;

select 'coBalance',count(*) from coBalance;


if (_truncate=1) THEN truncate table `coDivision`; END IF;

INSERT IGNORE INTO `coDivision`
(`coDivisionID`,
`Description`,
`Code`,
`InActive`,
`UseInvoiceSeqNo`,
`InvoiceSeqNo`,
`AddressQuote`,
`Address1`,
`Address2`,
`Address3`,
`SubAccount`,
`AccountDistribution`,
`Address4`,
`Additional1`,
`Additional2`,
`Additional3`)
SELECT `coDivision`.`coDivisionID`,
    `coDivision`.`Description`,
    `coDivision`.`Code`,
    `coDivision`.`InActive`,
    `coDivision`.`UseInvoiceSeqNo`,
    `coDivision`.`InvoiceSeqNo`,
    `coDivision`.`AddressQuote`,
    `coDivision`.`Address1`,
    `coDivision`.`Address2`,
    `coDivision`.`Address3`,
    `coDivision`.`SubAccount`,
    `coDivision`.`AccountDistribution`,
    `coDivision`.`Address4`,
    `coDivision`.`Additional1`,
    `coDivision`.`Additional2`,
    `coDivision`.`Additional3`
FROM `Hvac_company`.`coDivision`;

select 'coDivision',count(*) from coDivision;


if (_truncate=1) THEN truncate table `coFiscalPeriod`; END IF;

INSERT INTO `coFiscalPeriod`
(`coFiscalPeriodID`,
`coFiscalYearID`,
`StartDate`,
`EndDate`,
`StartNewQuarter`,
`FinalPeriod`
-- `period`,
-- `openStatus`
)
SELECT `coFiscalPeriod`.`coFiscalPeriodID`,
    `coFiscalPeriod`.`coFiscalYearID`,
    `coFiscalPeriod`.`StartDate`,
    `coFiscalPeriod`.`EndDate`,
    `coFiscalPeriod`.`StartNewQuarter`,
    `coFiscalPeriod`.`FinalPeriod`
FROM `Hvac_company`.`coFiscalPeriod`;

select 'coFiscalPeriod',count(*) from coFiscalPeriod;



if (_truncate=1) THEN truncate table `coFiscalYear`; END IF;

INSERT INTO `coFiscalYear`
(`coFiscalYearID`,
`StartDate`,
`EndDate`
-- `fiscalYear`
-- `Description`,
-- `closedStatus`
)
SELECT `coFiscalYear`.`coFiscalYearID`,
    `coFiscalYear`.`StartDate`,
    `coFiscalYear`.`EndDate`
FROM `Hvac_company`.`coFiscalYear`;


select 'coFiscalYear',count(*) from coFiscalYear;




if (_truncate=1) THEN truncate table `coBalance`; END IF;

select 'coAccount',count(*) from coAccount;

if (_truncate=1) THEN truncate table `coBalance`; END IF;

select 'coAccount',count(*) from coAccount;

if (_truncate=1) THEN truncate table `coBalance`; END IF;

select 'coAccount',count(*) from coAccount;

if (_truncate=1) THEN truncate table `coBalance`; END IF;

select 'coAccount',count(*) from coAccount;

if (_truncate=1) THEN truncate table `coBalance`; END IF;

select 'coAccount',count(*) from coAccount;

if (_truncate=1) THEN truncate table `coBalance`; END IF;


END$$

DELIMITER ;

-- ===============================================

DROP procedure IF EXISTS `ETL_TURBOREP_121`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_TURBOREP_121`()
BEGIN
    DECLARE restables INTEGER DEFAULT 0;
	DECLARE finished INTEGER DEFAULT 0;
	DECLARE tablename1 varchar(100) DEFAULT "";
    DECLARE newtable varchar(50);
    
    DEClARE testcursor1 
		CURSOR FOR 
			SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES  WHERE TABLE_SCHEMA = 'Hvac_company' and TABLE_TYPE = 'BASE TABLE' ;
    
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN testcursor1;

    
	getTableNames: LOOP
		FETCH testcursor1 INTO tablename1;
		IF finished = 1 THEN 
			LEAVE getTableNames;
		END IF;
           set @newtable=(select TABLE_NAME  from INFORMATION_SCHEMA.TABLES  WHERE TABLE_SCHEMA = 'TP_struct' and TABLE_TYPE = 'BASE TABLE' and upper(TABLE_NAME)=upper(tablename1));
       
	if(@newtable=tablename1) then
         
				 set @decide=( SELECT IF(COUNT(1)>0,'Differences','No Differences')  FROM
		(
			SELECT
				column_name,ordinal_position,
				data_type,column_type,COUNT(1) rowcount
			FROM information_schema.columns
			WHERE
			(
				(table_schema='TP_struct' AND table_name=@newtable) OR
				(table_schema='Hvac_company' AND table_name=tablename1)
			)
			AND table_name IN (@newtable,tablename1)
			GROUP BY
				column_name,data_type
			HAVING COUNT(1)=1
		) A);

    if(@decide='No Differences') then
      
     -- SET restables = CONCAT(tablename1,",",restables);
	    SET restables = restables + 1;
     
         set @l_sql1=concat("truncate TP_struct.",@newtable);
		 prepare stmt1 from @l_sql1;
	     execute stmt1;
	     deallocate prepare stmt1;
      
        set @l_sql = concat("INSERT INTO TP_struct.",@newtable," SELECT * from Hvac_company.",tablename1,";");
        prepare stmt from @l_sql;
	    execute stmt;
	    deallocate prepare stmt;

	end if;
	 
  
end if;
	
       
	END LOOP getTableNames;
    
    select restables;
	CLOSE testcursor1;
END$$

DELIMITER ;

-- ================================================================
DROP procedure IF EXISTS `ETL_TURBOREP_121Delta`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_TURBOREP_121Delta` (
	IN _truncate int
)
ETL_TURBOREP_121Delta : BEGIN

 DECLARE countcheck INTEGER DEFAULT 0;
SET FOREIGN_KEY_CHECKS = 0;


if (_truncate=1) THEN truncate table `coAccount`; END IF;

INSERT IGNORE INTO `coAccount`
(`coAccountID`,
`InActive`,
`Number`,
`Description`,
`BalanceSheetColumn`,
`IncludeWhenZero`,
`DebitBalance`,
`ContraAccount`,
`LineAboveAmount`,
`LineBelowAmount`,
`TotalingLevel`,
`VerticalSpacing`,
`HorizontalSpacing`,
`FontLarge`,
`FontBold`,
`FontItalic`,
`FontUnderline`,
`Tax1099`,
`SubAccount`,
`IsSubAccount`,
`IsMasterAccount`,
`DollarSign`
-- `accountType`,
-- `openingBalance`,
-- `FinancialStatus`
)
SELECT `coAccount`.`coAccountID`,
    `coAccount`.`InActive`,
    `coAccount`.`Number`,
    `coAccount`.`Description`,
    `coAccount`.`BalanceSheetColumn`,
    `coAccount`.`IncludeWhenZero`,
    `coAccount`.`DebitBalance`,
    `coAccount`.`ContraAccount`,
    `coAccount`.`LineAboveAmount`,
    `coAccount`.`LineBelowAmount`,
    `coAccount`.`TotalingLevel`,
    `coAccount`.`VerticalSpacing`,
    `coAccount`.`HorizontalSpacing`,
    `coAccount`.`FontLarge`,
    `coAccount`.`FontBold`,
    `coAccount`.`FontItalic`,
    `coAccount`.`FontUnderline`,
    `coAccount`.`Tax1099`,
    `coAccount`.`SubAccount`,
    `coAccount`.`IsSubAccount`,
    `coAccount`.`IsMasterAccount`,
    `coAccount`.`DollarSign`
FROM `Hvac_company`.`coAccount`;

 set countcheck=countcheck+1;
-- select 'coAccount',count(*) from coAccount;


if (_truncate=1) THEN truncate table `moAccount`; END IF;

INSERT IGNORE INTO `moAccount`
(`moAccountID`,
`InActive`,
`AccountType`,
`Description`,
`coAccountIDAsset`,
`coAccountIDDeposits`,
`coAccountIDInterest`,
`coAccountIDFees`,
`OpenBalance`,
`Additions`,
`Subtractions`,
`UndepositedReceipts`,
`UnprintedPayables`,
`UnprintedPayroll`,
`NextCheckNumber`,
`EndingBalance`,
`Company1`,
`Company2`,
`Company3`,
`Company4`,
`Company5`,
`Bank1`,
`Bank2`,
`Bank3`,
`Bank4`,
`Bank5`,
`CheckCode`,
`RoutingNumber`,
`AccountNumber`
-- `LogoYN`,
-- `LineNo`
)
SELECT `moAccount`.`moAccountID`,
    `moAccount`.`InActive`,
    `moAccount`.`AccountType`,
    `moAccount`.`Description`,
    `moAccount`.`coAccountIDAsset`,
    `moAccount`.`coAccountIDDeposits`,
    `moAccount`.`coAccountIDInterest`,
    `moAccount`.`coAccountIDFees`,
    `moAccount`.`OpenBalance`,
    `moAccount`.`Additions`,
    `moAccount`.`Subtractions`,
    `moAccount`.`UndepositedReceipts`,
    `moAccount`.`UnprintedPayables`,
    `moAccount`.`UnprintedPayroll`,
    `moAccount`.`NextCheckNumber`,
    `moAccount`.`EndingBalance`,
    `moAccount`.`Company1`,
    `moAccount`.`Company2`,
    `moAccount`.`Company3`,
    `moAccount`.`Company4`,
    `moAccount`.`Company5`,
    `moAccount`.`Bank1`,
    `moAccount`.`Bank2`,
    `moAccount`.`Bank3`,
    `moAccount`.`Bank4`,
    `moAccount`.`Bank5`,
    `moAccount`.`CheckCode`,
    `moAccount`.`RoutingNumber`,
    `moAccount`.`AccountNumber`
FROM `Hvac_company`.`moAccount`;
 set countcheck=countcheck+1;
-- select 'moAccount',count(*) from moAccount;


if (_truncate=1) THEN truncate table `coFiscalPeriod`; END IF;

INSERT INTO `coFiscalPeriod`
(`coFiscalPeriodID`,
`coFiscalYearID`,
`StartDate`,
`EndDate`,
`StartNewQuarter`,
`FinalPeriod`,
 `period`
-- `openStatus`
)
SELECT `coFiscalPeriod`.`coFiscalPeriodID`,
    `coFiscalPeriod`.`coFiscalYearID`,
    `coFiscalPeriod`.`StartDate`,
    `coFiscalPeriod`.`EndDate`,
    `coFiscalPeriod`.`StartNewQuarter`,
    `coFiscalPeriod`.`FinalPeriod`,
    CASE 
WHEN MONTH(coFiscalPeriod.StartDate)=8 THEN 1 
WHEN MONTH(coFiscalPeriod.StartDate)=9 THEN 2
WHEN MONTH(coFiscalPeriod.StartDate)=10 THEN 3
WHEN MONTH(coFiscalPeriod.StartDate)=11 THEN 4 
WHEN MONTH(coFiscalPeriod.StartDate)=12 THEN 5
WHEN MONTH(coFiscalPeriod.StartDate)=1 THEN 6
WHEN MONTH(coFiscalPeriod.StartDate)=2 THEN 7
WHEN MONTH(coFiscalPeriod.StartDate)=3 THEN 8
WHEN MONTH(coFiscalPeriod.StartDate)=4 THEN 9
WHEN MONTH(coFiscalPeriod.StartDate)=5 THEN 10
WHEN MONTH(coFiscalPeriod.StartDate)=6 THEN 11
WHEN MONTH(coFiscalPeriod.StartDate)=7 THEN 12
END
FROM `Hvac_company`.`coFiscalPeriod`;
 set countcheck=countcheck+1;
-- select 'coFiscalPeriod',count(*) from coFiscalPeriod;


if (_truncate=1) THEN truncate table `coFiscalYear`; END IF;

INSERT INTO `coFiscalYear`
(`coFiscalYearID`,
`StartDate`,
`EndDate`,
 `fiscalYear`
-- `Description`,
-- `closedStatus`
)
SELECT `coFiscalYear`.`coFiscalYearID`,
    `coFiscalYear`.`StartDate`,
    `coFiscalYear`.`EndDate`,
    CONCAT(YEAR(`coFiscalYear`.`StartDate`),'-',YEAR(`coFiscalYear`.`EndDate`))    
FROM `Hvac_company`.`coFiscalYear`;
 set countcheck=countcheck+1;
-- select 'coFiscalYear',count(*) from coFiscalYear;


if (_truncate=1) THEN truncate table `coLedgerSource`; END IF;

INSERT IGNORE INTO `coLedgerSource`
(`coLedgerSourceID`,
`Description`
-- `JournalID`
)
SELECT `coLedgerSource`.`coLedgerSourceID`,
`coLedgerSource`.`Description`
FROM `Hvac_company`.`coLedgerSource`;
 set countcheck=countcheck+1;
-- select 'coLedgerSource',count(*) from coLedgerSource;


if (_truncate=1) THEN truncate table `coTaxTerritory`; END IF;

INSERT IGNORE INTO `coTaxTerritory`
(`coTaxTerritoryID`,
`County`,
`State`,
`CountyCode`,
`TaxRate`,
`Distribution1`,
`Distribution2`,
`Distribution3`,
`Distribution4`,
`Distribution5`,
`Distribution6`,
`Distribution7`,
`Distribution8`,
`HasSurtax`,
`SurtaxCap`,
`SurtaxRate`,
`MultiRate`,
`Rate2`,
`From2`,
`Rate3`,
`From3`,
`Rate4`,
`From4`,
`Rate5`,
`From5`,
`Rate6`,
`From6`,
`TaxShipping`,
`DistDesc1`,
`DistDesc2`,
`DistDesc3`,
`DistDesc4`,
`DistDesc5`,
`DistDesc6`,
`DistDesc7`,
`DistDesc8`,
`GRDate`,
`GRTaxRate`,
`GRDistribution1`,
`GRDistribution2`,
`GRDistribution3`,
`GRDistribution4`,
`GRDistribution5`,
`GRDistribution6`,
`GRDistribution7`,
`GRDistribution8`,
`GRSurtaxCap`,
`GRSurtaxRate`,
`GRRate1`,
`GRRate2`,
`GRRate3`,
`GRRate4`,
`GRRate5`,
`GRRate6`
-- `inActive`,
-- `taxfreight`
)
SELECT 
`coTaxTerritory`.`coTaxTerritoryID`,
`coTaxTerritory`.`County`,
`coTaxTerritory`.`State`,
`coTaxTerritory`.`CountyCode`,
`coTaxTerritory`.`TaxRate`,
`coTaxTerritory`.`Distribution1`,
`coTaxTerritory`.`Distribution2`,
`coTaxTerritory`.`Distribution3`,
`coTaxTerritory`.`Distribution4`,
`coTaxTerritory`.`Distribution5`,
`coTaxTerritory`.`Distribution6`,
`coTaxTerritory`.`Distribution7`,
`coTaxTerritory`.`Distribution8`,
`coTaxTerritory`.`HasSurtax`,
`coTaxTerritory`.`SurtaxCap`,
`coTaxTerritory`.`SurtaxRate`,
`coTaxTerritory`.`MultiRate`,
`coTaxTerritory`.`Rate2`,
`coTaxTerritory`.`From2`,
`coTaxTerritory`.`Rate3`,
`coTaxTerritory`.`From3`,
`coTaxTerritory`.`Rate4`,
`coTaxTerritory`.`From4`,
`coTaxTerritory`.`Rate5`,
`coTaxTerritory`.`From5`,
`coTaxTerritory`.`Rate6`,
`coTaxTerritory`.`From6`,
`coTaxTerritory`.`TaxShipping`,
`coTaxTerritory`.`DistDesc1`,
`coTaxTerritory`.`DistDesc2`,
`coTaxTerritory`.`DistDesc3`,
`coTaxTerritory`.`DistDesc4`,
`coTaxTerritory`.`DistDesc5`,
`coTaxTerritory`.`DistDesc6`,
`coTaxTerritory`.`DistDesc7`,
`coTaxTerritory`.`DistDesc8`,
`coTaxTerritory`.`GRDate`,
`coTaxTerritory`.`GRTaxRate`,
`coTaxTerritory`.`GRDistribution1`,
`coTaxTerritory`.`GRDistribution2`,
`coTaxTerritory`.`GRDistribution3`,
`coTaxTerritory`.`GRDistribution4`,
`coTaxTerritory`.`GRDistribution5`,
`coTaxTerritory`.`GRDistribution6`,
`coTaxTerritory`.`GRDistribution7`,
`coTaxTerritory`.`GRDistribution8`,
`coTaxTerritory`.`GRSurtaxCap`,
`coTaxTerritory`.`GRSurtaxRate`,
`coTaxTerritory`.`GRRate1`,
`coTaxTerritory`.`GRRate2`,
`coTaxTerritory`.`GRRate3`,
`coTaxTerritory`.`GRRate4`,
`coTaxTerritory`.`GRRate5`,
`coTaxTerritory`.`GRRate6`
FROM  `Hvac_company`.`coTaxTerritory`;
 set countcheck=countcheck+1;
-- select 'coTaxTerritory',count(*) from coTaxTerritory;

if (_truncate=1) THEN truncate table `cuInvoice`; END IF;

INSERT IGNORE INTO `cuInvoice`
(`cuInvoiceID`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`TransactionStatus`,
`Applied`,
`joReleaseDetailID`,
`cuSOID`,
`rxCustomerID`,
`rxBillToID`,
`rxBillToAddressID`,
`rxShipToID`,
`rxShipToAddressID`,
`veShipViaID`,
`prFromWarehouseID`,
`prToWarehouseID`,
`cuTermsID`,
`ShipToMode`,
`coTaxTerritoryID`,
`InvoiceNumber`,
`CustomerPONumber`,
`QuickJobName`,
`InvoiceDate`,
`ShipDate`,
`DueDate`,
`PrintDate`,
`InvoiceAmount`,
`AppliedAmount`,
`TaxAmount`,
`Freight`,
`CostTotal`,
`Subtotal`,
`TaxTotal`,
`TaxRate`,
`cuAssignmentID0`,
`cuAssignmentID1`,
`cuAssignmentID2`,
`cuAssignmentID3`,
`cuAssignmentID4`,
`TrackingNumber`,
`SurtaxOverrideCap`,
`SurtaxTotal`,
`SurtaxRate`,
`SurtaxAmount`,
`SingleItemTaxAmount`,
`coDivisionID`,
`FreightCost`,
`DoNotMail`,
`TaxExempt1`,
`TaxExempt2`,
`TaxExempt3`,
`TaxExempt4`,
`TaxExempt5`,
`TaxExempt6`,
`TaxExempt7`,
`TaxExempt8`,
`TaxExempt0`,
`CreditMemo`,
`IsCredit`,
`Description`,
`Note`,
`HasGrandfatherRate`,
`QuickEntry`,
`MethodSent`
-- `DiscountAmt`,
-- ``memoStatus`,
-- ``rxContactID`,
-- ``jobnodescription`,
-- ``cIopenStatus`,
-- ``reason`,
-- ``whseCostTotal`,
-- ``taxAdjustmentStatus`,
-- ``taxfreight`,
-- ``TaxableSales`,
-- `NonTaxableSales`,
-- `EmailDate`,
-- `StatementEmailDate`,
-- `EmailStatus`,
-- `PaymentMadeOn`,
-- `isCareOfRequired`
)
SELECT `cuInvoice`.`cuInvoiceID`,
    `cuInvoice`.`CreatedByID`,
    `cuInvoice`.`CreatedOn`,
    `cuInvoice`.`ChangedByID`,
    `cuInvoice`.`ChangedOn`,
    `cuInvoice`.`TransactionStatus`,
    `cuInvoice`.`Applied`,
    `cuInvoice`.`joReleaseDetailID`,
    `cuInvoice`.`cuSOID`,
    `cuInvoice`.`rxCustomerID`,
    `cuInvoice`.`rxBillToID`,
    `cuInvoice`.`rxBillToAddressID`,
    `cuInvoice`.`rxShipToID`,
    `cuInvoice`.`rxShipToAddressID`,
    `cuInvoice`.`veShipViaID`,
    `cuInvoice`.`prFromWarehouseID`,
    `cuInvoice`.`prToWarehouseID`,
    `cuInvoice`.`cuTermsID`,
    `cuInvoice`.`ShipToMode`,
    `cuInvoice`.`coTaxTerritoryID`,
    `cuInvoice`.`InvoiceNumber`,
    `cuInvoice`.`CustomerPONumber`,
    `cuInvoice`.`QuickJobName`,
    `cuInvoice`.`InvoiceDate`,
    `cuInvoice`.`ShipDate`,
    `cuInvoice`.`DueDate`,
    `cuInvoice`.`PrintDate`,
    `cuInvoice`.`InvoiceAmount`,
    `cuInvoice`.`AppliedAmount`,
    `cuInvoice`.`TaxAmount`,
    `cuInvoice`.`Freight`,
    `cuInvoice`.`CostTotal`,
    `cuInvoice`.`Subtotal`,
    `cuInvoice`.`TaxTotal`,
    `cuInvoice`.`TaxRate`,
    `cuInvoice`.`cuAssignmentID0`,
    `cuInvoice`.`cuAssignmentID1`,
    `cuInvoice`.`cuAssignmentID2`,
    `cuInvoice`.`cuAssignmentID3`,
    `cuInvoice`.`cuAssignmentID4`,
    `cuInvoice`.`TrackingNumber`,
    `cuInvoice`.`SurtaxOverrideCap`,
    `cuInvoice`.`SurtaxTotal`,
    `cuInvoice`.`SurtaxRate`,
    `cuInvoice`.`SurtaxAmount`,
    `cuInvoice`.`SingleItemTaxAmount`,
    `cuInvoice`.`coDivisionID`,
    `cuInvoice`.`FreightCost`,
    `cuInvoice`.`DoNotMail`,
    `cuInvoice`.`TaxExempt1`,
    `cuInvoice`.`TaxExempt2`,
    `cuInvoice`.`TaxExempt3`,
    `cuInvoice`.`TaxExempt4`,
    `cuInvoice`.`TaxExempt5`,
    `cuInvoice`.`TaxExempt6`,
    `cuInvoice`.`TaxExempt7`,
    `cuInvoice`.`TaxExempt8`,
    `cuInvoice`.`TaxExempt0`,
    `cuInvoice`.`CreditMemo`,
    `cuInvoice`.`IsCredit`,
    `cuInvoice`.`Description`,
    `cuInvoice`.`Note`,
    `cuInvoice`.`HasGrandfatherRate`,
    `cuInvoice`.`QuickEntry`,
    `cuInvoice`.`MethodSent`
FROM `Hvac_company`.`cuInvoice`;
 set countcheck=countcheck+1;
-- select 'cuInvoice',count(*) from cuInvoice;


if (_truncate=1) THEN truncate table `cuInvoiceDetail`; END IF;

INSERT IGNORE INTO `cuInvoiceDetail`
(`cuInvoiceDetailID`,
`cuInvoiceID`,
`cuSODetailID`,
`prMasterID`,
`Description`,
`Note`,
`QuantityBilled`,
`UnitCost`,
`UnitPrice`,
`PriceMultiplier`,
`Taxable`,
`HasSingleItemTaxAmount`,
`coAccountID`
-- `whseCost`,
-- `position`,
-- `onOrder`
)
SELECT `cuInvoiceDetail`.`cuInvoiceDetailID`,
    `cuInvoiceDetail`.`cuInvoiceID`,
    `cuInvoiceDetail`.`cuSODetailID`,
    `cuInvoiceDetail`.`prMasterID`,
    `cuInvoiceDetail`.`Description`,
    `cuInvoiceDetail`.`Note`,
    `cuInvoiceDetail`.`QuantityBilled`,
    `cuInvoiceDetail`.`UnitCost`,
    `cuInvoiceDetail`.`UnitPrice`,
    `cuInvoiceDetail`.`PriceMultiplier`,
    `cuInvoiceDetail`.`Taxable`,
    `cuInvoiceDetail`.`HasSingleItemTaxAmount`,
    `cuInvoiceDetail`.`coAccountID`
FROM `Hvac_company`.`cuInvoiceDetail`;
 set countcheck=countcheck+1;
-- select 'cuInvoiceDetail',count(*) from cuInvoice;


if (_truncate=1) THEN truncate table `cuLinkageDetail`; END IF;

INSERT IGNORE INTO `cuLinkageDetail`
(`cuLinkageDetailID`,
`cuInvoiceID`,
`cuReceiptID`,
`rxCustomerID`,
`PaymentApplied`,
`DiscountUsed`
-- `creditAmount`,
-- `refInvoiceID`,
-- `amtApplied`,
-- `statusCheck`,
-- `datePaid`,
-- `deletedStatus`
)
SELECT `cuLinkageDetail`.`cuLinkageDetailID`,
    `cuLinkageDetail`.`cuInvoiceID`,
    `cuLinkageDetail`.`cuReceiptID`,
    `cuLinkageDetail`.`rxCustomerID`,
    `cuLinkageDetail`.`PaymentApplied`,
    `cuLinkageDetail`.`DiscountUsed`
FROM `Hvac_company`.`cuLinkageDetail`;
 set countcheck=countcheck+1;
-- select 'cuLinkageDetail',count(*) from cuLinkageDetail;


if (_truncate=1) THEN truncate table `cuMaster`; END IF;

INSERT IGNORE INTO `cuMaster`
(`cuMasterID`,
`cuTermsID`,
`cuAssignmentID0`,
`cuAssignmentID1`,
`cuAssignmentID2`,
`cuAssignmentID3`,
`cuAssignmentID4`,
`PORequired`,
`cuMasterTypeID`,
`PriceLevel`,
`CreditHold`,
`CreditLimit`,
`CreditHoldOverride`,
`TaxExemptNumber`,
`AccountNumber`,
`coDivisionID`,
`FinCharge`,
`CreditAppDate`,
`Statements`,
`QuoteMethod`,
`InvoiceMethod`,
`StatementMethod`,
`DefaultMult`,
`QM_Text`,
`IM_Text`,
`SM_Text`,
`prWarehouseID`,
`AvgDaysAsOf`,
`UseAvgDaysAsOf`
-- `tier`,
-- `TermDiscountDays`,
-- `TermDiscountPercent`,
-- `TermDiscountOnDay`,
-- `TermDiscountEnabled`,
-- `financialStatus`,
-- `salesOrderPopup`,
-- `addConvenienceFee`,
-- `isacceptsACHForm`,
-- `invoiceYesNOmethod`,
-- `statementYesNOmethod`,
-- `invoiceYesDate`,
-- `statementYesDate`
)
SELECT `cuMaster`.`cuMasterID`,
    `cuMaster`.`cuTermsID`,
    `cuMaster`.`cuAssignmentID0`,
    `cuMaster`.`cuAssignmentID1`,
    `cuMaster`.`cuAssignmentID2`,
    `cuMaster`.`cuAssignmentID3`,
    `cuMaster`.`cuAssignmentID4`,
    `cuMaster`.`PORequired`,
    `cuMaster`.`cuMasterTypeID`,
    `cuMaster`.`PriceLevel`,
    `cuMaster`.`CreditHold`,
    `cuMaster`.`CreditLimit`,
    `cuMaster`.`CreditHoldOverride`,
    `cuMaster`.`TaxExemptNumber`,
    `cuMaster`.`AccountNumber`,
    `cuMaster`.`coDivisionID`,
    `cuMaster`.`FinCharge`,
    `cuMaster`.`CreditAppDate`,
    `cuMaster`.`Statements`,
    `cuMaster`.`QuoteMethod`,
    `cuMaster`.`InvoiceMethod`,
    `cuMaster`.`StatementMethod`,
    `cuMaster`.`DefaultMult`,
    `cuMaster`.`QM_Text`,
    `cuMaster`.`IM_Text`,
    `cuMaster`.`SM_Text`,
    `cuMaster`.`prWarehouseID`,
    `cuMaster`.`AvgDaysAsOf`,
    `cuMaster`.`UseAvgDaysAsOf`
FROM `Hvac_company`.`cuMaster`;
 set countcheck=countcheck+1;
-- select 'cuMaster',count(*) from cuMaster;


if (_truncate=1) THEN truncate table `cuReceipt`; END IF;

INSERT IGNORE INTO `cuReceipt`
(`cuReceiptID`,
`rxCustomerID`,
`cuReceiptTypeID`,
`ReceiptDate`,
`Reference`,
`Memo`,
`Amount`,
`cuSODepositID`,
`CreditCardApproved`
-- `reversePaymentStatus`
)
SELECT `cuReceipt`.`cuReceiptID`,
    `cuReceipt`.`rxCustomerID`,
    `cuReceipt`.`cuReceiptTypeID`,
    `cuReceipt`.`ReceiptDate`,
    `cuReceipt`.`Reference`,
    `cuReceipt`.`Memo`,
    `cuReceipt`.`Amount`,
    `cuReceipt`.`cuSODepositID`,
    `cuReceipt`.`CreditCardApproved`
FROM `Hvac_company`.`cuReceipt`;
 set countcheck=countcheck+1;
-- select 'cuReceipt',count(*) from cuReceipt;


if (_truncate=1) THEN truncate table `cuSO`; END IF;

INSERT IGNORE INTO `cuSO`
(`cuSOID`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`TransactionStatus`,
`joReleaseID`,
`rxCustomerID`,
`rxBillToID`,
`rxBillToAddressID`,
`rxShipToID`,
`rxShipToAddressID`,
`veShipViaID`,
`prFromWarehouseID`,
`prToWarehouseID`,
`cuTermsID`,
`ShipToMode`,
`coTaxTerritoryID`,
`SONumber`,
`CustomerPONumber`,
`DatePromised`,
`QuickJobName`,
`OrderDate`,
`ShipDate`,
`CostTotal`,
`SubTotal`,
`TaxTotal`,
`Freight`,
`TaxRate`,
`cuAssignmentID0`,
`cuAssignmentID1`,
`cuAssignmentID2`,
`cuAssignmentID3`,
`cuAssignmentID4`,
`TrackingNumber`,
`SurtaxOverrideCap`,
`SurtaxTotal`,
`SurtaxRate`,
`SurtaxAmount`,
`SingleItemTaxAmount`,
`joSchedDetailID`,
`Tag`,
`FreightCost`,
`coDivisionID`,
`TaxExempt1`,
`TaxExempt2`,
`TaxExempt3`,
`TaxExempt4`,
`TaxExempt5`,
`TaxExempt6`,
`TaxExempt7`,
`TaxExempt8`,
`TaxExempt0`
-- `emailTimeStamp`,
-- `rxContactID`,
-- `whseCostTotal`,
-- `ShiptoIndex`,
-- `createdDate`,
-- `withpriceStatus`,
-- `taxfreight`,
-- `TaxableSales`,
-- `NonTaxableSales`,
-- `isCareOfRequired`
)
SELECT `cuSO`.`cuSOID`,
    `cuSO`.`CreatedByID`,
    `cuSO`.`CreatedOn`,
    `cuSO`.`ChangedByID`,
    `cuSO`.`ChangedOn`,
    `cuSO`.`TransactionStatus`,
    `cuSO`.`joReleaseID`,
    `cuSO`.`rxCustomerID`,
    `cuSO`.`rxBillToID`,
    `cuSO`.`rxBillToAddressID`,
    `cuSO`.`rxShipToID`,
    `cuSO`.`rxShipToAddressID`,
    `cuSO`.`veShipViaID`,
    `cuSO`.`prFromWarehouseID`,
    `cuSO`.`prToWarehouseID`,
    `cuSO`.`cuTermsID`,
    `cuSO`.`ShipToMode`,
    `cuSO`.`coTaxTerritoryID`,
    `cuSO`.`SONumber`,
    `cuSO`.`CustomerPONumber`,
    `cuSO`.`DatePromised`,
    `cuSO`.`QuickJobName`,
    `cuSO`.`OrderDate`,
    `cuSO`.`ShipDate`,
    `cuSO`.`Freight`,
    `cuSO`.`CostTotal`,
    `cuSO`.`SubTotal`,
    `cuSO`.`TaxTotal`,
    `cuSO`.`TaxRate`,
    `cuSO`.`cuAssignmentID0`,
    `cuSO`.`cuAssignmentID1`,
    `cuSO`.`cuAssignmentID2`,
    `cuSO`.`cuAssignmentID3`,
    `cuSO`.`cuAssignmentID4`,
    `cuSO`.`TrackingNumber`,
    `cuSO`.`SurtaxOverrideCap`,
    `cuSO`.`SurtaxTotal`,
    `cuSO`.`SurtaxRate`,
    `cuSO`.`SurtaxAmount`,
    `cuSO`.`SingleItemTaxAmount`,
    `cuSO`.`joSchedDetailID`,
    `cuSO`.`Tag`,
    `cuSO`.`FreightCost`,
    `cuSO`.`coDivisionID`,
    `cuSO`.`TaxExempt1`,
    `cuSO`.`TaxExempt2`,
    `cuSO`.`TaxExempt3`,
    `cuSO`.`TaxExempt4`,
    `cuSO`.`TaxExempt5`,
    `cuSO`.`TaxExempt6`,
    `cuSO`.`TaxExempt7`,
    `cuSO`.`TaxExempt8`,
    `cuSO`.`TaxExempt0`
FROM `Hvac_company`.`cuSO`;
 set countcheck=countcheck+1;
-- select 'cuSO',count(*) from cuSO;


if (_truncate=1) THEN truncate table `cuSODetail`; END IF;

INSERT IGNORE INTO `cuSODetail`
(`cuSODetailID`,
`cuSOID`,
`prMasterID`,
`Description`,
`Note`,
`QuantityOrdered`,
`QuantityReceived`,
`QuantityBilled`,
`UnitCost`,
`UnitPrice`,
`PriceMultiplier`,
`Taxable`,
`HasSingleItemTaxAmount`,
`joSchedDetailID`
-- `whseCost`,
-- `position`
)
SELECT `cuSODetail`.`cuSODetailID`,
    `cuSODetail`.`cuSOID`,
    `cuSODetail`.`prMasterID`,
    `cuSODetail`.`Description`,
    `cuSODetail`.`Note`,
    `cuSODetail`.`QuantityOrdered`,
    `cuSODetail`.`QuantityReceived`,
    `cuSODetail`.`QuantityBilled`,
    `cuSODetail`.`UnitCost`,
    `cuSODetail`.`UnitPrice`,
    `cuSODetail`.`PriceMultiplier`,
    `cuSODetail`.`Taxable`,
    `cuSODetail`.`HasSingleItemTaxAmount`,
    `cuSODetail`.`joSchedDetailID`
FROM `Hvac_company`.`cuSODetail`;
set countcheck=countcheck+1;
-- select 'cuSODetail',count(*) from cuSODetail;


if (_truncate=1) THEN truncate table `cuSODetailTemplate`; END IF;

INSERT IGNORE INTO `cuSODetailTemplate`
(`cuSODetailID`,
`cuSOID`,
`prMasterID`,
`Description`,
`Note`,
`QuantityOrdered`,
`QuantityReceived`,
`QuantityBilled`,
`UnitCost`,
`UnitPrice`,
`PriceMultiplier`,
`Taxable`,
`HasSingleItemTaxAmount`,
`joSchedDetailID`
-- `position`
)
SELECT `cuSODetailTemplate`.`cuSODetailID`,
    `cuSODetailTemplate`.`cuSOID`,
    `cuSODetailTemplate`.`prMasterID`,
    `cuSODetailTemplate`.`Description`,
    `cuSODetailTemplate`.`Note`,
    `cuSODetailTemplate`.`QuantityOrdered`,
    `cuSODetailTemplate`.`QuantityReceived`,
    `cuSODetailTemplate`.`QuantityBilled`,
    `cuSODetailTemplate`.`UnitCost`,
    `cuSODetailTemplate`.`UnitPrice`,
    `cuSODetailTemplate`.`PriceMultiplier`,
    `cuSODetailTemplate`.`Taxable`,
    `cuSODetailTemplate`.`HasSingleItemTaxAmount`,
    `cuSODetailTemplate`.`joSchedDetailID`
FROM `Hvac_company`.`cuSODetailTemplate`;
set countcheck=countcheck+1;
-- select 'cuSODetailTemplate',count(*) from cuSODetailTemplate;


if (_truncate=1) THEN truncate table `cuTerms`; END IF;

INSERT IGNORE INTO `cuTerms`
(`cuTermsID`,
`Description`,
`InActive`,
`DueDays`,
`DiscountDays`,
`DiscountPercent`,
`DueOnDay`,
`DiscOnDay`,
`OrderNote`,
-- `PickTicketNote`,
`PickTicketNote1`,
`PickTicketNote2`,
`PickTicketNote3`,
`PickTicketNote4`,
`PickTicketNote5`,
`IsGlobal`
)
SELECT `cuTerms`.`cuTermsID`,
    `cuTerms`.`Description`,
    `cuTerms`.`InActive`,
    `cuTerms`.`DueDays`,
    `cuTerms`.`DiscountDays`,
    `cuTerms`.`DiscountPercent`,
    `cuTerms`.`DueOnDay`,
    `cuTerms`.`DiscOnDay`,
    `cuTerms`.`OrderNote`,
    `cuTerms`.`PickTicketNote1`,
    `cuTerms`.`PickTicketNote2`,
    `cuTerms`.`PickTicketNote3`,
    `cuTerms`.`PickTicketNote4`,
    `cuTerms`.`PickTicketNote5`,
    `cuTerms`.`IsGlobal`
FROM `Hvac_company`.`cuTerms`;
set countcheck=countcheck+1;
-- select 'cuTerms',count(*) from cuTerms;


if (_truncate=1) THEN truncate table `ecInvoicePeriod`; END IF;

INSERT IGNORE INTO `ecInvoicePeriod`
(`ecInvoicePeriodID`,
`cuInvoiceID`,
`ecPeriodID`,
`Modified`,
`rxCustomerID`,
`ReleaseType`,
`Reference`,
`DatePaid`,
`Sales`,
`Profit`,
`joReleaseID`,
`cuTrueInvoiceID`,
`ExpjoMasterID`,
`ExprxMasterID`
-- `enteredDate`,
-- `ecType`
)
SELECT `ecInvoicePeriod`.`ecInvoicePeriodID`,
    `ecInvoicePeriod`.`cuInvoiceID`,
    `ecInvoicePeriod`.`ecPeriodID`,
    `ecInvoicePeriod`.`Modified`,
    `ecInvoicePeriod`.`rxCustomerID`,
    `ecInvoicePeriod`.`ReleaseType`,
    `ecInvoicePeriod`.`Reference`,
    `ecInvoicePeriod`.`DatePaid`,
    `ecInvoicePeriod`.`Sales`,
    `ecInvoicePeriod`.`Profit`,
    `ecInvoicePeriod`.`joReleaseID`,
    `ecInvoicePeriod`.`cuTrueInvoiceID`,
    `ecInvoicePeriod`.`ExpjoMasterID`,
    `ecInvoicePeriod`.`ExprxMasterID`
FROM `Hvac_company`.`ecInvoicePeriod`;
set countcheck=countcheck+1;
-- select 'ecInvoicePeriod',count(*) from ecInvoicePeriod;


if (_truncate=1) THEN truncate table `ecSplitJob`; END IF;

INSERT IGNORE INTO `ecSplitJob`
(`ecSplitJobID`,
`joMasterID`,
`rxMasterID`,
`Allocated`,
`ecSplitCodeID`,
`joReleaseID`
-- `splitType`,
-- `CreatedByID`,
-- `CreatedOn`,
-- `ChangedByID`,
-- `ChangedOn`,
-- `IsRelease`
)
SELECT `ecSplitJob`.`ecSplitJobID`,
    `ecSplitJob`.`joMasterID`,
    `ecSplitJob`.`rxMasterID`,
    `ecSplitJob`.`Allocated`,
    `ecSplitJob`.`ecSplitCodeID`,
    `ecSplitJob`.`joReleaseID`
FROM `Hvac_company`.`ecSplitJob`;
set countcheck=countcheck+1;
-- select 'ecSplitJob',count(*) from ecSplitJob;


if (_truncate=1) THEN truncate table `ecStatement`; END IF;

INSERT INTO `ecStatement`
(`ecStatementID`,
`ecPeriodID`,
`RepLoginID`,
`OpeningBalance`,
`JobCommissions`,
`OtherCommissions`,
`Overrides`,
`Adjustments`,
`Payment`,
`RepDeduct1`,
`RepDeduct2`,
`RepDeduct3`,
`RepDeduct4`,
`Comment`,
`Custom1`,
`Custom2`,
`Custom3`,
`Custom4`,
`Custom5`,
`Custom6`,
`Custom7`,
`Custom8`,
`Custom9`,
`Custom10`,
`Flags`,
`Profit`,
-- `BonusComPaidxxx`,
`BonusComPaid`
-- `CalculatedDate`,
-- `ecStatementEnteredDate`
)
SELECT `ecStatement`.`ecStatementID`,
    `ecStatement`.`ecPeriodID`,
    `ecStatement`.`RepLoginID`,
    `ecStatement`.`OpeningBalance`,
    `ecStatement`.`JobCommissions`,
    `ecStatement`.`OtherCommissions`,
    `ecStatement`.`Overrides`,
    `ecStatement`.`Adjustments`,
    `ecStatement`.`Payment`,
    `ecStatement`.`RepDeduct1`,
    `ecStatement`.`RepDeduct2`,
    `ecStatement`.`RepDeduct3`,
    `ecStatement`.`RepDeduct4`,
    `ecStatement`.`Comment`,
    `ecStatement`.`Custom1`,
    `ecStatement`.`Custom2`,
    `ecStatement`.`Custom3`,
    `ecStatement`.`Custom4`,
    `ecStatement`.`Custom5`,
    `ecStatement`.`Custom6`,
    `ecStatement`.`Custom7`,
    `ecStatement`.`Custom8`,
    `ecStatement`.`Custom9`,
    `ecStatement`.`Custom10`,
    `ecStatement`.`Flags`,
    `ecStatement`.`Profit`,
    `ecStatement`.`BonusComPaid`
FROM `Hvac_company`.`ecStatement`;
set countcheck=countcheck+1;
-- select 'ecStatement',count(*) from ecStatement;


if (_truncate=1) THEN truncate table `emMaster`; END IF;

INSERT IGNORE INTO `emMaster`
(`emMasterID`,
`CommissionJobProfit`,
`CommissionInvoiceProfit`,
`UserLoginID`,
`GetsCommission`,
`Quota`,
`RepDeduct1`,
`RepDeduct2`,
`RepDeduct3`,
`RepDeduct4`,
`ShowDirectory`,
`Location`,
`Position`,
`PhotoName`,
`Phone`,
`Email`,
`Comment`,
`WebName`,
`EmploymentStatus`,
`EmploymentType`,
`MaritalStatus`,
`Sex`,
`SSN`,
`BirthDate`,
`HireDate`,
`NextReviewDate`,
`LastRaiseDate`,
`TerminationDate`,
`VacaType`,
`VacaStartDate`,
`VacaHoursPerYear`,
`VacaHoursMaximum`,
`VacaHoursAvailable`,
`VacaCarryOverYear`,
`SickType`,
`SickStartDate`,
`SickHoursPerYear`,
`SickHoursMaximum`,
`SickHoursAvailable`,
`SickCarryOverYear`,
`PayFrequency`,
`RetirementPlan`,
`StatutoryEmployee`,
`coStateID`,
`epCoDepartmentID`,
`FT_MaritalStatus`,
`FT_Exemptions`,
`FT_SupWH`,
`FT_SpecialCode`,
`ST_MaritalStatus`,
`ST_Exemptions`,
`ST_SupWH`,
`ST_SpecialCode`,
`LT_MaritalStatus`,
`LT_Exemptions`,
`LT_SupWH`,
`LT_SpecialCode`,
`JobNumberPrefix`,
`JobNumberSequence`,
`JobNumberGenerate`,
`DirectDeposit`,
`coDivisionID`,
`CommissionBuySellProfit`,
`CommissionFactory`,
`ProfitBonus`,
`PaymentPeriod`,
`BranchManager`,
`EnginComm`,
`GetsBonus`,
`BonusLevel1`,
`BonusComm1`,
`BonusLevel2`,
`BonusComm2`,
`BonusLevel3`,
`BonusComm3`,
`BonusLevel4`,
`BonusComm4`,
`BonusLevel5`,
`BonusComm5`,
`BonusLevel6`,
`BonusComm6`,
`BonusLevel7`,
`BonusComm7`,
`BonusLevel8`,
`BonusComm8`
-- `dayAfter`,
-- `CommAfterPayment`,
-- `CommPayOn`,
-- `isJobPaidInFull`,
-- `isFollowingPeriod`
)
SELECT `emMaster`.`emMasterID`,
    `emMaster`.`CommissionJobProfit`,
    `emMaster`.`CommissionInvoiceProfit`,
    `emMaster`.`UserLoginID`,
    `emMaster`.`GetsCommission`,
    `emMaster`.`Quota`,
    `emMaster`.`RepDeduct1`,
    `emMaster`.`RepDeduct2`,
    `emMaster`.`RepDeduct3`,
    `emMaster`.`RepDeduct4`,
    `emMaster`.`ShowDirectory`,
    `emMaster`.`Location`,
    `emMaster`.`Position`,
    `emMaster`.`PhotoName`,
    `emMaster`.`Phone`,
    `emMaster`.`Email`,
    `emMaster`.`Comment`,
    `emMaster`.`WebName`,
    `emMaster`.`EmploymentStatus`,
    `emMaster`.`EmploymentType`,
    `emMaster`.`MaritalStatus`,
    `emMaster`.`Sex`,
    `emMaster`.`SSN`,
    `emMaster`.`BirthDate`,
    `emMaster`.`HireDate`,
    `emMaster`.`NextReviewDate`,
    `emMaster`.`LastRaiseDate`,
    `emMaster`.`TerminationDate`,
    `emMaster`.`VacaType`,
    `emMaster`.`VacaStartDate`,
    `emMaster`.`VacaHoursPerYear`,
    `emMaster`.`VacaHoursMaximum`,
    `emMaster`.`VacaHoursAvailable`,
    `emMaster`.`VacaCarryOverYear`,
    `emMaster`.`SickType`,
    `emMaster`.`SickStartDate`,
    `emMaster`.`SickHoursPerYear`,
    `emMaster`.`SickHoursMaximum`,
    `emMaster`.`SickHoursAvailable`,
    `emMaster`.`SickCarryOverYear`,
    `emMaster`.`PayFrequency`,
    `emMaster`.`RetirementPlan`,
    `emMaster`.`StatutoryEmployee`,
    `emMaster`.`coStateID`,
    `emMaster`.`epCoDepartmentID`,
    `emMaster`.`FT_MaritalStatus`,
    `emMaster`.`FT_Exemptions`,
    `emMaster`.`FT_SupWH`,
    `emMaster`.`FT_SpecialCode`,
    `emMaster`.`ST_MaritalStatus`,
    `emMaster`.`ST_Exemptions`,
    `emMaster`.`ST_SupWH`,
    `emMaster`.`ST_SpecialCode`,
    `emMaster`.`LT_MaritalStatus`,
    `emMaster`.`LT_Exemptions`,
    `emMaster`.`LT_SupWH`,
    `emMaster`.`LT_SpecialCode`,
    `emMaster`.`JobNumberPrefix`,
    `emMaster`.`JobNumberSequence`,
    `emMaster`.`JobNumberGenerate`,
    `emMaster`.`DirectDeposit`,
    `emMaster`.`coDivisionID`,
    `emMaster`.`CommissionBuySellProfit`,
    `emMaster`.`CommissionFactory`,
    `emMaster`.`ProfitBonus`,
    `emMaster`.`PaymentPeriod`,
    `emMaster`.`BranchManager`,
    `emMaster`.`EnginComm`,
    `emMaster`.`GetsBonus`,
    `emMaster`.`BonusLevel1`,
    `emMaster`.`BonusComm1`,
    `emMaster`.`BonusLevel2`,
    `emMaster`.`BonusComm2`,
    `emMaster`.`BonusLevel3`,
    `emMaster`.`BonusComm3`,
    `emMaster`.`BonusLevel4`,
    `emMaster`.`BonusComm4`,
    `emMaster`.`BonusLevel5`,
    `emMaster`.`BonusComm5`,
    `emMaster`.`BonusLevel6`,
    `emMaster`.`BonusComm6`,
    `emMaster`.`BonusLevel7`,
    `emMaster`.`BonusComm7`,
    `emMaster`.`BonusLevel8`,
    `emMaster`.`BonusComm8`
FROM `Hvac_company`.`emMaster`;
set countcheck=countcheck+1;
-- select 'emMaster',count(*) from emMaster;


if (_truncate=1) THEN truncate table `epCoDeduction`; END IF;

INSERT IGNORE INTO `epCoDeduction`
(`epCoDeductionID`,
`InActive`,
`Description`,
`BuiltIn`,
`CalculationType`,
`Amount`,
`Maximum`,
`FederalIncomeTaxExempt`,
`SocialSecurityExempt`,
`MedicareExempt`,
`StateIncomeTaxExempt`,
`LocalIncomeTaxExempt`,
`SortOrder`)
SELECT `epCoDeduction`.`epCoDeductionID`,
    `epCoDeduction`.`InActive`,
    `epCoDeduction`.`Description`,
   -- `epCoDeduction`.`W2Code`,
    `epCoDeduction`.`BuiltIn`,
    `epCoDeduction`.`CalculationType`,
    `epCoDeduction`.`Amount`,
    `epCoDeduction`.`Maximum`,
    `epCoDeduction`.`FederalIncomeTaxExempt`,
    `epCoDeduction`.`SocialSecurityExempt`,
    `epCoDeduction`.`MedicareExempt`,
    `epCoDeduction`.`StateIncomeTaxExempt`,
    `epCoDeduction`.`LocalIncomeTaxExempt`,
   -- `epCoDeduction`.`OtherExempt`,
    `epCoDeduction`.`SortOrder`
FROM `Hvac_company`.`epCoDeduction`;

set countcheck=countcheck+1;
-- select 'epCoDeduction',count(*) from epCoDeduction;


if (_truncate=1) THEN truncate table `epTransaction`; END IF;

INSERT INTO `epTransaction`
(`epTransactionID`,
`rxMasterID`,
`moTransactionID`,
`PostDate`,
-- `PayPeriodBeginning`,
`PayPeriodEnding`,
`PeriodFrequency`,
`GrossWages`,
`NetWages`,
`OpenBalance`
)
SELECT `epTransaction`.`epTransactionID`,
    `epTransaction`.`rxMasterID`,
    `epTransaction`.`moTransactionID`,
   --  `epTransaction`.`coStateID`,
    `epTransaction`.`PostDate`,
    `epTransaction`.`PayPeriodEnding`,
    `epTransaction`.`PeriodFrequency`,
    `epTransaction`.`GrossWages`,
   --  `epTransaction`.`FITWages`,
   -- `epTransaction`.`SocialSecurityWages`,
   --  `epTransaction`.`MedicareWages`,
   -- `epTransaction`.`OtherWages`,
    `epTransaction`.`NetWages`,
    `epTransaction`.`OpenBalance`
FROM `Hvac_company`.`epTransaction`;
set countcheck=countcheck+1;
-- select 'epTransaction',count(*) from epTransaction;


if (_truncate=1) THEN truncate table `FormLabel`; END IF;

INSERT IGNORE INTO `FormLabel`
(`FormHeaderID`,
`tEMPsORT`,
`FormNo`,
`Section`,
`Name`,
`Caption`,
`Hide`,
`Show`,
`UseTopOffset`,
`locTop`,
`locLeft`,
`sizeHeight`,
`sizeWidth`,
`BorderStyle`,
`Style`,
`Tag`,
`WordWrap`
)
SELECT `FormLabel`.`FormHeaderID`,
    `FormLabel`.`TempSort`,
    `FormLabel`.`FormNo`,
    `FormLabel`.`Section`,
    `FormLabel`.`Name`,
    `FormLabel`.`Caption`,
    `FormLabel`.`Hide`,
    `FormLabel`.`Show`,
    `FormLabel`.`UseTopOffset`,
    `FormLabel`.`locTop`,
    `FormLabel`.`locLeft`,
    `FormLabel`.`sizeHeight`,
    `FormLabel`.`sizeWidth`,
    `FormLabel`.`BorderStyle`,
    `FormLabel`.`Style`,
    `FormLabel`.`Tag`,
    `FormLabel`.`WordWrap`
FROM `Hvac_company`.`FormLabel`;
set countcheck=countcheck+1;
-- select 'FormLabel',count(*) from FormLabel;


if (_truncate=1) THEN truncate table `FormScratch`; END IF;

INSERT IGNORE INTO `FormScratch`
(`FormHeaderID`,
-- `tEMPsORT`,
`FormNo`,
`Section`,
`Name`,
`Caption`,
`Hide`,
`Show`,
`UseTopOffset`,
`locTop`,
`locLeft`,
`sizeHeight`,
`sizeWidth`,
`BorderStyle`,
`Style`
-- `Tag`
)
SELECT `FormScratch`.`FormHeaderID`,
    `FormScratch`.`FormNo`,
    `FormScratch`.`Section`,
    `FormScratch`.`Name`,
    `FormScratch`.`Caption`,
    `FormScratch`.`Hide`,
    `FormScratch`.`Show`,
    `FormScratch`.`UseTopOffset`,
    `FormScratch`.`locTop`,
    `FormScratch`.`locLeft`,
    `FormScratch`.`sizeHeight`,
    `FormScratch`.`sizeWidth`,
    `FormScratch`.`BorderStyle`,
    `FormScratch`.`Style`
FROM `Hvac_company`.`FormScratch`;
set countcheck=countcheck+1;
-- select 'FormScratch',count(*) from FormScratch;


if (_truncate=1) THEN truncate table `JobChanges`; END IF;

INSERT IGNORE INTO `JobChanges`
(`joMasterID`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`JobNumber`,
`rxCustomerID`,
`Description`,
`LocationName`,
`LocationAddress1`,
`LocationAddress2`,
`LocationCity`,
`LocationState`,
`LocationZip`,
`rxCategory1`,
`rxCategory2`,
`rxCategory3`,
`rxCategory4`,
`rxCategory5`,
`cuAssignmentID0`,
`cuAssignmentID1`,
`cuAssignmentID2`,
`cuAssignmentID3`,
`cuAssignmentID4`,
`PlanAndSpecJob`,
`PriorApprovalRequired`,
`PriorApprovalDone`,
`PriorApprovalDoneDate`,
`PriorApprovalGranted`,
`PriorApprovalGrantedDate`,
`Source1`,
`Source2`,
`Source3`,
`Source4`,
`SubmittalSent`,
`SubmittalApproved`,
`SubmittalResent`,
`SubmittalSentDate`,
`SubmittalApprovedDate`,
`SubmittalResentDate`,
`AddendumReceived`,
`AddendumQuotedThru`,
`BidDate`,
`BidTime`,
`CustomerPONumber`,
`BookedDate`,
`ClosedDate`,
`EntireJobContractAmount`,
`ContractAmount`,
`EstimatedCost`,
`EstimatedProfit`,
`CloseOutActualProfit`,
`JobStatus`,
`CreditStatus`,
`CreditType`,
`JobBonded`,
`RequestedNOC`,
`RequestedNOCDate`,
`ReceivedNOC`,
`ReceivedNOCDate`,
`SentNTC`,
`SentNTCDate`,
`LienWaverSigned`,
`LienWaverSignedDate`,
`LienWaverThrough`,
`LienWaverThroughDate`,
`LienWaverThroughAmount`,
`LienWaverThroughFinal`,
`coTaxTerritoryID`,
`Notice24`,
`Notice48`,
`NoticeCall`,
`who0`,
`who1`,
`who2`,
`who3`,
`who4`,
`who5`,
`who6`,
`who7`,
`CreditStatusDate`,
`CreditTypeDate`,
`ClaimFiledDate`,
`CreditContact0`,
`CreditContact1`,
`CreditContact2`,
`ClaimFiled`,
`CreditNotes`
-- `upsize_ts`
)
SELECT `JobChanges`.`joMasterID`,
    `JobChanges`.`CreatedByID`,
    `JobChanges`.`CreatedOn`,
    `JobChanges`.`ChangedByID`,
    `JobChanges`.`ChangedOn`,
    `JobChanges`.`JobNumber`,
    `JobChanges`.`rxCustomerID`,
    `JobChanges`.`Description`,
    `JobChanges`.`LocationName`,
    `JobChanges`.`LocationAddress1`,
    `JobChanges`.`LocationAddress2`,
    `JobChanges`.`LocationCity`,
    `JobChanges`.`LocationState`,
    `JobChanges`.`LocationZip`,
    `JobChanges`.`rxCategory1`,
    `JobChanges`.`rxCategory2`,
    `JobChanges`.`rxCategory3`,
    `JobChanges`.`rxCategory4`,
    `JobChanges`.`rxCategory5`,
    `JobChanges`.`cuAssignmentID0`,
    `JobChanges`.`cuAssignmentID1`,
    `JobChanges`.`cuAssignmentID2`,
    `JobChanges`.`cuAssignmentID3`,
    `JobChanges`.`cuAssignmentID4`,
    `JobChanges`.`PlanAndSpecJob`,
    `JobChanges`.`PriorApprovalRequired`,
    `JobChanges`.`PriorApprovalDone`,
    `JobChanges`.`PriorApprovalDoneDate`,
    `JobChanges`.`PriorApprovalGranted`,
    `JobChanges`.`PriorApprovalGrantedDate`,
    `JobChanges`.`Source1`,
    `JobChanges`.`Source2`,
    `JobChanges`.`Source3`,
    `JobChanges`.`Source4`,
    `JobChanges`.`SubmittalSent`,
    `JobChanges`.`SubmittalApproved`,
    `JobChanges`.`SubmittalResent`,
    `JobChanges`.`SubmittalSentDate`,
    `JobChanges`.`SubmittalApprovedDate`,
    `JobChanges`.`SubmittalResentDate`,
    `JobChanges`.`AddendumReceived`,
    `JobChanges`.`AddendumQuotedThru`,
    `JobChanges`.`BidDate`,
    `JobChanges`.`BidTime`,
    `JobChanges`.`CustomerPONumber`,
    `JobChanges`.`BookedDate`,
    `JobChanges`.`ClosedDate`,
    `JobChanges`.`EntireJobContractAmount`,
    `JobChanges`.`ContractAmount`,
    `JobChanges`.`EstimatedCost`,
    `JobChanges`.`EstimatedProfit`,
    `JobChanges`.`CloseOutActualProfit`,
    `JobChanges`.`JobStatus`,
    `JobChanges`.`CreditStatus`,
    `JobChanges`.`CreditType`,
    `JobChanges`.`JobBonded`,
    `JobChanges`.`RequestedNOC`,
    `JobChanges`.`RequestedNOCDate`,
    `JobChanges`.`ReceivedNOC`,
    `JobChanges`.`ReceivedNOCDate`,
    `JobChanges`.`SentNTC`,
    `JobChanges`.`SentNTCDate`,
    `JobChanges`.`LienWaverSigned`,
    `JobChanges`.`LienWaverSignedDate`,
    `JobChanges`.`LienWaverThrough`,
    `JobChanges`.`LienWaverThroughDate`,
    `JobChanges`.`LienWaverThroughAmount`,
    `JobChanges`.`LienWaverThroughFinal`,
    `JobChanges`.`coTaxTerritoryID`,
    `JobChanges`.`Notice24`,
    `JobChanges`.`Notice48`,
    `JobChanges`.`NoticeCall`,
    `JobChanges`.`who0`,
    `JobChanges`.`who1`,
    `JobChanges`.`who2`,
    `JobChanges`.`who3`,
    `JobChanges`.`who4`,
    `JobChanges`.`who5`,
    `JobChanges`.`who6`,
    `JobChanges`.`who7`,
    `JobChanges`.`CreditStatusDate`,
    `JobChanges`.`CreditTypeDate`,
    `JobChanges`.`ClaimFiledDate`,
    `JobChanges`.`CreditContact0`,
    `JobChanges`.`CreditContact1`,
    `JobChanges`.`CreditContact2`,
    `JobChanges`.`ClaimFiled`,
    `JobChanges`.`CreditNotes`
FROM `Hvac_company`.`JobChanges`;
set countcheck=countcheck+1;
-- select 'JobChanges',count(*) from JobChanges;


if (_truncate=1) THEN truncate table `joBidder`; END IF;

INSERT IGNORE INTO `joBidder`
(`joBidderID`,
`joMasterID`,
`rxMasterID`,
`rxContactID`,
`cuMasterTypeID`,
`LowBid`,
`NoChance`,
`QuoteRev`,
`QuoteDate`,
`QuoteStatus`,
`UserLoginID`
-- `quoteemailstatus`,
-- `Locked`,
-- `LastLockedBy`,
-- `UpdatedByID`,
-- `UpdatedOn`,
-- `CreatedByID`,
-- `CreatedOn`
)
SELECT `joBidder`.`joBidderID`,
    `joBidder`.`joMasterID`,
    `joBidder`.`rxMasterID`,
    `joBidder`.`rxContactID`,
    `joBidder`.`cuMasterTypeID`,
    `joBidder`.`LowBid`,
    `joBidder`.`NoChance`,
    `joBidder`.`QuoteRev`,
    `joBidder`.`QuoteDate`,
    `joBidder`.`QuoteStatus`,
    `joBidder`.`UserLoginID`
FROM `Hvac_company`.`joBidder`;
set countcheck=countcheck+1;
-- select 'joBidder',count(*) from joBidder;


if (_truncate=1) THEN truncate table `cuMasterType`; END IF;

INSERT IGNORE INTo `cuMasterType`
(
   ` cuMasterTypeID`, 
    `Code`, 
    `Description`, 
    `InActive`
)
select `cuMasterType`.`cuMasterTypeID`, 
`cuMasterType`.`Code`, 
`cuMasterType`.`Description`, 
`cuMasterType`.`InActive`
from `Hvac_company`.`cuMasterType`;


set countcheck=countcheck+1;


if (_truncate=1) THEN truncate table `prDepartment`; END IF;

INSERT IGNORE INTo `prDepartment`
(
   `prDepartmentID`, 
   `Description`, 
   `InActive`, 
   `coAccountIDSales`,
    `coAccountIDCOGS`
)
select `prDepartment`.`prDepartmentID`, 
`prDepartment`.`Description`, 
`prDepartment`.`InActive`, 
`prDepartment`.`coAccountIDSales`,
`prDepartment`.`coAccountIDCOGS`
from `Hvac_company`.`prDepartment`;


set countcheck=countcheck+1;

if (_truncate=1) THEN truncate table `prCategory`; END IF;

INSERT IGNORE INTo `prCategory`
(
   `prCategoryID`, 
   `Description`,
    `InActive`,
    `MarkupCost`,
    `MarkupAmount`
)
select `prCategory`.`prCategoryID`, 
`prCategory`.`Description`, 
`prCategory`.`InActive`, 
`prCategory`.`MarkupCost`,
`prCategory`.`MarkupAmount`
from `Hvac_company`.`prCategory`;


set countcheck=countcheck+1;


if (_truncate=1) THEN truncate table `joChange`; END IF;

INSERT IGNORE INTO `joChange`
(`joChangeID`,
`joMasterID`,
`ChangeDate`,
`CustomerPONumber`,
`ChangeByID`,
`ChangeByName`,
`ChangeReason`,
`ChangeAmount`,
`ChangeCost`
-- `SellingType`
)
SELECT `joChange`.`joChangeID`,
    `joChange`.`joMasterID`,
    `joChange`.`ChangeDate`,
    `joChange`.`CustomerPONumber`,
    `joChange`.`ChangeByID`,
    `joChange`.`ChangeByName`,
    `joChange`.`ChangeReason`,
    `joChange`.`ChangeAmount`,
    `joChange`.`ChangeCost`
FROM `Hvac_company`.`joChange`;
set countcheck=countcheck+1;
-- select 'joChange',count(*) from joChange;


if (_truncate=1) THEN truncate table `joMaster`; END IF;

INSERT IGNORE INTO `joMaster`
(`joMasterID`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`JobNumber`,
`rxCustomerID`,
`coDivisionID`,
`joBidStatusID`,
`Description`,
`LocationName`,
`LocationAddress1`,
`LocationAddress2`,
`LocationCity`,
`LocationState`,
`LocationZip`,
`rxCategory1`,
`rxCategory2`,
`rxCategory3`,
`rxCategory4`,
`rxCategory5`,
`rxCategory6`,
`cuAssignmentID0`,
`cuAssignmentID1`,
`cuAssignmentID2`,
`cuAssignmentID3`,
`cuAssignmentID4`,
`cuAssignmentID5`,
`cuAssignmentID6`,
-- `cuAssignmentID7`,
`PlanAndSpecJob`,
`PriorApprovalRequired`,
`PriorApprovalDone`,
`PriorApprovalDoneDate`,
`PriorApprovalGranted`,
`PriorApprovalGrantedDate`,
`Source1`,
`Source2`,
`Source3`,
`Source4`,
`SourceReport1`,
`SubmittalSent`,
`SubmittalApproved`,
`SubmittalResent`,
`SubmittalSentDate`,
`SubmittalApprovedDate`,
`SubmittalResentDate`,
`BinNumber`,
`PlanDate`,
`BidDate`,
`BidTime`,
`CustomerPONumber`,
`BookedDate`,
`ClosedDate`,
`EntireJobContractAmount`,
`ContractAmount`,
`EstimatedCost`,
`EstimatedProfit`,
`CloseOutActualProfit`,
`JobStatus`,
`CreditStatus`,
`CreditType`,
`LostComment`,
`JobBonded`,
`RequestedNOC`,
`RequestedNOCDate`,
`ReceivedNOC`,
`ReceivedNOCDate`,
`SentNTC`,
`SentNTCDate`,
`LienWaverSigned`,
`LienWaverSignedDate`,
`LienWaverThrough`,
`LienWaverThroughDate`,
`LienWaverThroughAmount`,
`LienWaverThroughFinal`,
`coTaxTerritoryID`,
`Notice24`,
`Notice48`,
`NoticeCall`,
`who0`,
`who1`,
`who2`,
`who3`,
`who4`,
`who5`,
`who6`,
`who7`,
`CreditStatusDate`,
`CreditTypeDate`,
`ClaimFiledDate`,
`CreditContact0`,
`CreditContact1`,
`CreditContact2`,
`ClaimFiled`,
`CreditNotes`,
`ReleaseNotes`,
`CreditReferenceNumber`,
`QuoteYesNo1`,
`PlanNumbers`,
`PriorCost`,
`PriorRevenue`,
`OriginalBidDate`,
`OriginalBidTime`,
`BidPostponed`,
`OtherSource`,
`AddendumReceived`,
`AddendumQuotedThru`,
`TaxExempt1`,
`TaxExempt2`,
`TaxExempt3`,
`TaxExempt4`,
`TaxExempt5`,
`TaxExempt6`,
`TaxExempt7`,
`TaxExempt8`,
`TaxExempt0`,
`ManualQty`,
`ManualRequested`,
`ManualSent`,
`ManualDate`,
`RequestManual`,
`RequestDate`,
`coBranchID`,
`ActualProfitToDate`,
`Website`,
`QuoteNumber`
-- `noticeId`,
-- `contactId`,
-- `notice`,
-- `contactName`,
-- `otherContact`,
-- `seqnum`,
-- `isDrawInfo`,
-- `DrawInfo`,
-- `who8`,
-- `SellPrice`,
-- `Commission`,
-- `isAllSalesRep`
)
SELECT `joMaster`.`joMasterID`,
    `joMaster`.`CreatedByID`,
    `joMaster`.`CreatedOn`,
    `joMaster`.`ChangedByID`,
    `joMaster`.`ChangedOn`,
    `joMaster`.`JobNumber`,
    `joMaster`.`rxCustomerID`,
    `joMaster`.`coDivisionID`,
    `joMaster`.`joBidStatusID`,
    `joMaster`.`Description`,
    `joMaster`.`LocationName`,
    `joMaster`.`LocationAddress1`,
    `joMaster`.`LocationAddress2`,
    `joMaster`.`LocationCity`,
    `joMaster`.`LocationState`,
    `joMaster`.`LocationZip`,
    `joMaster`.`rxCategory1`,
    `joMaster`.`rxCategory2`,
    `joMaster`.`rxCategory3`,
    `joMaster`.`rxCategory4`,
    `joMaster`.`rxCategory5`,
    `joMaster`.`rxCategory6`,
    `joMaster`.`cuAssignmentID0`,
    `joMaster`.`cuAssignmentID1`,
    `joMaster`.`cuAssignmentID2`,
    `joMaster`.`cuAssignmentID3`,
    `joMaster`.`cuAssignmentID4`,
    `joMaster`.`cuAssignmentID5`,
    `joMaster`.`cuAssignmentID6`,
    `joMaster`.`PlanAndSpecJob`,
    `joMaster`.`PriorApprovalRequired`,
    `joMaster`.`PriorApprovalDone`,
    `joMaster`.`PriorApprovalDoneDate`,
    `joMaster`.`PriorApprovalGranted`,
    `joMaster`.`PriorApprovalGrantedDate`,
    `joMaster`.`Source1`,
    `joMaster`.`Source2`,
    `joMaster`.`Source3`,
    `joMaster`.`Source4`,
    `joMaster`.`SourceReport1`,
    `joMaster`.`SubmittalSent`,
    `joMaster`.`SubmittalApproved`,
    `joMaster`.`SubmittalResent`,
    `joMaster`.`SubmittalSentDate`,
    `joMaster`.`SubmittalApprovedDate`,
    `joMaster`.`SubmittalResentDate`,
    `joMaster`.`BinNumber`,
    `joMaster`.`PlanDate`,
    `joMaster`.`BidDate`,
    `joMaster`.`BidTime`,
    `joMaster`.`CustomerPONumber`,
    `joMaster`.`BookedDate`,
    `joMaster`.`ClosedDate`,
    `joMaster`.`EntireJobContractAmount`,
    `joMaster`.`ContractAmount`,
    `joMaster`.`EstimatedCost`,
    `joMaster`.`EstimatedProfit`,
    `joMaster`.`CloseOutActualProfit`,
    `joMaster`.`JobStatus`,
    `joMaster`.`CreditStatus`,
    `joMaster`.`CreditType`,
    `joMaster`.`LostComment`,
    `joMaster`.`JobBonded`,
    `joMaster`.`RequestedNOC`,
    `joMaster`.`RequestedNOCDate`,
    `joMaster`.`ReceivedNOC`,
    `joMaster`.`ReceivedNOCDate`,
    `joMaster`.`SentNTC`,
    `joMaster`.`SentNTCDate`,
    `joMaster`.`LienWaverSigned`,
    `joMaster`.`LienWaverSignedDate`,
    `joMaster`.`LienWaverThrough`,
    `joMaster`.`LienWaverThroughDate`,
    `joMaster`.`LienWaverThroughAmount`,
    `joMaster`.`LienWaverThroughFinal`,
    `joMaster`.`coTaxTerritoryID`,
    `joMaster`.`Notice24`,
    `joMaster`.`Notice48`,
    `joMaster`.`NoticeCall`,
    `joMaster`.`who0`,
    `joMaster`.`who1`,
    `joMaster`.`who2`,
    `joMaster`.`who3`,
    `joMaster`.`who4`,
    `joMaster`.`who5`,
    `joMaster`.`who6`,
    `joMaster`.`who7`,
    `joMaster`.`CreditStatusDate`,
    `joMaster`.`CreditTypeDate`,
    `joMaster`.`ClaimFiledDate`,
    `joMaster`.`CreditContact0`,
    `joMaster`.`CreditContact1`,
    `joMaster`.`CreditContact2`,
    `joMaster`.`ClaimFiled`,
    `joMaster`.`CreditNotes`,
    `joMaster`.`ReleaseNotes`,
    `joMaster`.`CreditReferenceNumber`,
    `joMaster`.`QuoteYesNo1`,
    `joMaster`.`PlanNumbers`,
    `joMaster`.`PriorCost`,
    `joMaster`.`PriorRevenue`,
    `joMaster`.`OriginalBidDate`,
    `joMaster`.`OriginalBidTime`,
    `joMaster`.`BidPostponed`,
    `joMaster`.`OtherSource`,
    `joMaster`.`AddendumReceived`,
    `joMaster`.`AddendumQuotedThru`,
    `joMaster`.`TaxExempt1`,
    `joMaster`.`TaxExempt2`,
    `joMaster`.`TaxExempt3`,
    `joMaster`.`TaxExempt4`,
    `joMaster`.`TaxExempt5`,
    `joMaster`.`TaxExempt6`,
    `joMaster`.`TaxExempt7`,
    `joMaster`.`TaxExempt8`,
    `joMaster`.`TaxExempt0`,
    `joMaster`.`ManualQty`,
    `joMaster`.`ManualRequested`,
    `joMaster`.`ManualSent`,
    `joMaster`.`ManualDate`,
    `joMaster`.`RequestManual`,
    `joMaster`.`RequestDate`,
    `joMaster`.`coBranchID`,
    `joMaster`.`ActualProfitToDate`,
    `joMaster`.`Website`,
    `joMaster`.`QuoteNumber`
FROM `Hvac_company`.`joMaster`;
set countcheck=countcheck+1;
-- select 'joMaster',count(*) from joMaster;


if (_truncate=1) THEN truncate table `joQuoteDetail`; END IF;

INSERT IGNORE INTO `joQuoteDetail`
(`joQuoteDetailID`,
`joQuoteHeaderID`,
`Product`,
`ProductNote`,
`ItemQuantity`,
`Paragraph`,
`rxManufacturerID`,
`Price`,
`InlineNote`,
`Cost`,
`Subtotal`,
`veFactoryID`,
`Mult`,
`Spec`,
`FmtBold`,
`FmtUnderline`,
`FmtItalic`,
`FmtLarge`,
`DetailSequenceID`,
`PricingNote`
-- `position`,
-- `Percentage`
)
SELECT `joQuoteDetail`.`joQuoteDetailID`,
    `joQuoteDetail`.`joQuoteHeaderID`,
    `joQuoteDetail`.`Product`,
    `joQuoteDetail`.`ProductNote`,
    `joQuoteDetail`.`ItemQuantity`,
    `joQuoteDetail`.`Paragraph`,
    `joQuoteDetail`.`rxManufacturerID`,
    `joQuoteDetail`.`Price`,
    `joQuoteDetail`.`InlineNote`,
    `joQuoteDetail`.`Cost`,
    `joQuoteDetail`.`Subtotal`,
    `joQuoteDetail`.`veFactoryID`,
    `joQuoteDetail`.`Mult`,
    `joQuoteDetail`.`Spec`,
    `joQuoteDetail`.`FmtBold`,
    `joQuoteDetail`.`FmtUnderline`,
    `joQuoteDetail`.`FmtItalic`,
    `joQuoteDetail`.`FmtLarge`,
    `joQuoteDetail`.`DetailSequenceID`,
    `joQuoteDetail`.`PricingNote`
FROM `Hvac_company`.`joQuoteDetail`;
set countcheck=countcheck+1;
-- select 'joQuoteDetail',count(*) from joQuoteDetail;


if (_truncate=1) THEN truncate table `joQuoteDetailWorkFile`; END IF;

INSERT IGNORE INTO `joQuoteDetailWorkFile`
(`joQuoteDetailWorkFileID`,
`Product`,
`ProductNote`,
`ItemQuantity`,
`Paragraph`,
`rxManufacturerID`,
`Price`,
`InlineNote`,
`Cost`,
`Subtotal`,
`veFactoryID`,
`Mult`,
`Spec`,
`FmtBold`,
`FmtUnderline`,
`FmtItalic`,
`FmtLarge`,
`FmtDisp`,
`DetailSequenceID`,
`PricingNote`)
SELECT `joQuoteDetailWorkFile`.`joQuoteDetailWorkFileID`,
    `joQuoteDetailWorkFile`.`Product`,
    `joQuoteDetailWorkFile`.`ProductNote`,
    `joQuoteDetailWorkFile`.`ItemQuantity`,
    `joQuoteDetailWorkFile`.`Paragraph`,
    `joQuoteDetailWorkFile`.`rxManufacturerID`,
    `joQuoteDetailWorkFile`.`Price`,
    `joQuoteDetailWorkFile`.`InlineNote`,
    `joQuoteDetailWorkFile`.`Cost`,
    `joQuoteDetailWorkFile`.`Subtotal`,
    `joQuoteDetailWorkFile`.`veFactoryID`,
    `joQuoteDetailWorkFile`.`Mult`,
    `joQuoteDetailWorkFile`.`Spec`,
    `joQuoteDetailWorkFile`.`FmtBold`,
    `joQuoteDetailWorkFile`.`FmtUnderline`,
    `joQuoteDetailWorkFile`.`FmtItalic`,
    `joQuoteDetailWorkFile`.`FmtLarge`,
    `joQuoteDetailWorkFile`.`FmtDisp`,
    `joQuoteDetailWorkFile`.`DetailSequenceID`,
    `joQuoteDetailWorkFile`.`PricingNote`
FROM `Hvac_company`.`joQuoteDetailWorkFile`;
set countcheck=countcheck+1;
-- select 'joQuoteDetailWorkFile',count(*) from joQuoteDetailWorkFile;


if (_truncate=1) THEN truncate table `joQuoteHeader`; END IF;

INSERT IGNORE INTO `joQuoteHeader`
(`joQuoteHeaderID`,
`joMasterID`,
`cuMasterTypeID`,
`QuoteRev`,
`QuoteAmount`,
`DiscountedPrice`,
`CreatedByID`,
`CreatedByName`,
`Remarks`,
`QuoteYesNo1`,
`Locked`,
`DateCreated`,
`DisplayQuantity`,
`DisplayParagraph`,
`DisplayManufacturer`,
`DisplayCost`,
`DisplayPrice`,
`PrintQuantity`,
`PrintParagraph`,
`PrintManufacturer`,
`PrintCost`,
`PrintPrice`,
`NotesFullWidth`,
`LineNumbers`,
`PrintTotal`,
`CostAmount`,
`DisplayMult`,
`DisplaySpec`,
`PrintMult`,
`PrintSpec`,
`HidePrice`,
`InternalNote`,
`PrimaryQuote`,
`BookedQuote`
-- `neworoldquote`,
-- `LSDStatus`,
-- `LSDValue`,
-- `DonotQty`,
-- `ShowTotOnly`,
-- `lastLockedBy`,
-- `updatedByID`,
-- `updatedOn`
)
SELECT `joQuoteHeader`.`joQuoteHeaderID`,
    `joQuoteHeader`.`joMasterID`,
    `joQuoteHeader`.`cuMasterTypeID`,
    `joQuoteHeader`.`QuoteRev`,
    `joQuoteHeader`.`QuoteAmount`,
    `joQuoteHeader`.`DiscountedPrice`,
    `joQuoteHeader`.`CreatedByID`,
    `joQuoteHeader`.`CreatedByName`,
    `joQuoteHeader`.`Remarks`,
    `joQuoteHeader`.`QuoteYesNo1`,
    `joQuoteHeader`.`Locked`,
    `joQuoteHeader`.`DateCreated`,
    `joQuoteHeader`.`DisplayQuantity`,
    `joQuoteHeader`.`DisplayParagraph`,
    `joQuoteHeader`.`DisplayManufacturer`,
    `joQuoteHeader`.`DisplayCost`,
    `joQuoteHeader`.`DisplayPrice`,
    `joQuoteHeader`.`PrintQuantity`,
    `joQuoteHeader`.`PrintParagraph`,
    `joQuoteHeader`.`PrintManufacturer`,
    `joQuoteHeader`.`PrintCost`,
    `joQuoteHeader`.`PrintPrice`,
    `joQuoteHeader`.`NotesFullWidth`,
    `joQuoteHeader`.`LineNumbers`,
    `joQuoteHeader`.`PrintTotal`,
    `joQuoteHeader`.`CostAmount`,
    `joQuoteHeader`.`DisplayMult`,
    `joQuoteHeader`.`DisplaySpec`,
    `joQuoteHeader`.`PrintMult`,
    `joQuoteHeader`.`PrintSpec`,
    `joQuoteHeader`.`HidePrice`,
    `joQuoteHeader`.`InternalNote`,
    `joQuoteHeader`.`PrimaryQuote`,
    `joQuoteHeader`.`BookedQuote`
FROM `Hvac_company`.`joQuoteHeader`;
set countcheck=countcheck+1;
-- select 'joQuoteHeader',count(*) from joQuoteHeader;


if (_truncate=1) THEN truncate table `joQuoteHistory`; END IF;

INSERT IGNORE INTO `joQuoteHistory`
(`joQuoteHistoryID`,
`joQuoteHeaderID`,
`joMasterID`,
`rxMasterID`,
`rxContactID`,
`QuoteRev`,
`QuoteDate`,
`QuoteStatus`,
`employeeId`,
-- `quoteTypeID`,
`quoteAmount`
-- `joBidderID`
)
SELECT `joQuoteHistory`.`joQuoteHistoryID`,
    `joQuoteHistory`.`joQuoteHeaderID`,
    `joQuoteHistory`.`joMasterID`,
    `joQuoteHistory`.`rxMasterID`,
    `joQuoteHistory`.`rxContactID`,
    `joQuoteHistory`.`QuoteRev`,
    `joQuoteHistory`.`QuoteDate`,
    `joQuoteHistory`.`QuoteStatus`,
    `joQuoteHistory`.`EmployeeID`,
    -- `joQuoteHistory`.`QuoteType`,
    `joQuoteHistory`.`QuoteAmount`
    -- `joQuoteHistory`.`Note`
FROM `Hvac_company`.`joQuoteHistory`;
set countcheck=countcheck+1;
-- select 'joQuoteHistory',count(*) from joQuoteHistory;


if (_truncate=1) THEN truncate table `joQuoteTemplateDetail`; END IF;

INSERT IGNORE INTO `joQuoteTemplateDetail`
(`joQuoteTemplateDetailID`,
`joQuoteTemplateHeaderID`,
`Product`,
`ProductNote`,
`ItemQuantity`,
`Paragraph`,
`rxManufacturerID`,
`Price`,
`InlineNote`,
`Cost`,
`Subtotal`,
`veFactoryID`,
`Mult`,
`Spec`,
`FmtBold`,
`FmtUnderline`,
`FmtItalic`,
`FmtLarge`,
`DetailSequenceID`,
`PricingNote`
-- `POSITION`,
-- `Percentage`
)
SELECT `joQuoteTemplateDetail`.`joQuoteTemplateDetailID`,
    `joQuoteTemplateDetail`.`joQuoteTemplateHeaderID`,
    `joQuoteTemplateDetail`.`Product`,
    `joQuoteTemplateDetail`.`ProductNote`,
    `joQuoteTemplateDetail`.`ItemQuantity`,
    `joQuoteTemplateDetail`.`Paragraph`,
    `joQuoteTemplateDetail`.`rxManufacturerID`,
    `joQuoteTemplateDetail`.`Price`,
    `joQuoteTemplateDetail`.`InlineNote`,
    `joQuoteTemplateDetail`.`Cost`,
    `joQuoteTemplateDetail`.`Subtotal`,
    `joQuoteTemplateDetail`.`veFactoryID`,
    `joQuoteTemplateDetail`.`Mult`,
    `joQuoteTemplateDetail`.`Spec`,
    `joQuoteTemplateDetail`.`FmtBold`,
    `joQuoteTemplateDetail`.`FmtUnderline`,
    `joQuoteTemplateDetail`.`FmtItalic`,
    `joQuoteTemplateDetail`.`FmtLarge`,
    `joQuoteTemplateDetail`.`DetailSequenceID`,
    `joQuoteTemplateDetail`.`PricingNote`
FROM `Hvac_company`.`joQuoteTemplateDetail`;
set countcheck=countcheck+1;
-- select 'joQuoteTemplateDetail',count(*) from joQuoteTemplateDetail;


if (_truncate=1) THEN truncate table `joQuoteTemplateHeader`; END IF;

INSERT IGNORE INTO `joQuoteTemplateHeader`
(`joQuoteTemplateHeaderID`,
`OwnerID`,
`TemplateName`,
`cuMasterTypeID`,
`QuoteRev`,
`Remarks`,
-- `DateCreated`,
-- `CreatedByID`,
`QuoteAmount`,
-- `DiscountedPrice`,
`QuoteYesNo1`,
`DisplayQuantity`,
`DisplayParagraph`,
`DisplayManufacturer`,
`DisplayCost`,
`DisplayPrice`,
`PrintQuantity`,
`PrintParagraph`,
`PrintManufacturer`,
`PrintCost`,
`PrintPrice`,
`NotesFullWidth`,
`LineNumbers`,
`GlobalTemplate`,
`PrintTotal`,
`CostAmount`,
`DisplayMult`,
`DisplaySpec`,
`PrintMult`,
`PrintSpec`,
`HidePrice`
-- `neworoldquote`
)
SELECT `joQuoteTemplateHeader`.`joQuoteTemplateHeaderID`,
    `joQuoteTemplateHeader`.`OwnerID`,
    `joQuoteTemplateHeader`.`TemplateName`,
    `joQuoteTemplateHeader`.`cuMasterTypeID`,
    `joQuoteTemplateHeader`.`QuoteRev`,
    `joQuoteTemplateHeader`.`Remarks`,
    `joQuoteTemplateHeader`.`QuoteAmount`,
    `joQuoteTemplateHeader`.`QuoteYesNo1`,
    `joQuoteTemplateHeader`.`DisplayQuantity`,
    `joQuoteTemplateHeader`.`DisplayParagraph`,
    `joQuoteTemplateHeader`.`DisplayManufacturer`,
    `joQuoteTemplateHeader`.`DisplayCost`,
    `joQuoteTemplateHeader`.`DisplayPrice`,
    `joQuoteTemplateHeader`.`PrintQuantity`,
    `joQuoteTemplateHeader`.`PrintParagraph`,
    `joQuoteTemplateHeader`.`PrintManufacturer`,
    `joQuoteTemplateHeader`.`PrintCost`,
    `joQuoteTemplateHeader`.`PrintPrice`,
    `joQuoteTemplateHeader`.`NotesFullWidth`,
    `joQuoteTemplateHeader`.`LineNumbers`,
    `joQuoteTemplateHeader`.`GlobalTemplate`,
    `joQuoteTemplateHeader`.`PrintTotal`,
    `joQuoteTemplateHeader`.`CostAmount`,
    `joQuoteTemplateHeader`.`DisplayMult`,
    `joQuoteTemplateHeader`.`DisplaySpec`,
    `joQuoteTemplateHeader`.`PrintMult`,
    `joQuoteTemplateHeader`.`PrintSpec`,
    `joQuoteTemplateHeader`.`HidePrice`
FROM `Hvac_company`.`joQuoteTemplateHeader`;
set countcheck=countcheck+1;
-- select 'joQuoteTemplateHeader',count(*) from joQuoteTemplateHeader;


if (_truncate=1) THEN truncate table `joRelease`; END IF;

INSERT IGNORE INTO `joRelease`
(`joReleaseID`,
`joMasterID`,
`ReleaseType`,
`ReleaseDate`,
`EstimatedBilling`,
`ReleaseNote`,
`CommissionReceived`,
`CommissionDate`,
`CommissionAmount`,
`Cancelled`,
`POID`,
`BillNote`
-- `seq_Number`,
-- `release_status`,
-- `coDivisionID`,
-- `GRTaxRate`
)
SELECT `joRelease`.`joReleaseID`,
    `joRelease`.`joMasterID`,
    `joRelease`.`ReleaseType`,
    `joRelease`.`ReleaseDate`,
    `joRelease`.`EstimatedBilling`,
    `joRelease`.`ReleaseNote`,
    `joRelease`.`CommissionReceived`,
    `joRelease`.`CommissionDate`,
    `joRelease`.`CommissionAmount`,
    `joRelease`.`Cancelled`,
    `joRelease`.`POID`,
    `joRelease`.`BillNote`
FROM `Hvac_company`.`joRelease`;
set countcheck=countcheck+1;
-- select 'joRelease',count(*) from joRelease;


if (_truncate=1) THEN truncate table `joScheduleDetail`; END IF;

INSERT IGNORE INTO `joScheduleDetail`
(`joScheduleDetailID`,
`joSubmittalDetailID`,
`joLineNumber`,
`joScheduleModelID`,
`Quantity`,
`UnitCost`,
`PriceMultiplier`,
`Col01`,
`Col02`,
`Col03`,
`Col04`,
`Col05`,
`Col06`,
`Col07`,
`Col08`,
`Col09`,
`Col10`,
`Col11`,
`Col12`,
`Col13`,
`Col14`,
`Col15`,
`Col16`,
`Col17`,
`Col18`,
`Col19`,
`Col20`,
`FN_Factory`,
`FN_Engineer`,
`FN_Advise`,
`QtyOrdered`,
`Status`,
`Dimension`,
`TAG`
-- `VisibleLineNumber`,
-- `ImportToPo`
)
SELECT `joScheduleDetail`.`joScheduleDetailID`,
    `joScheduleDetail`.`joSubmittalDetailID`,
    `joScheduleDetail`.`joLineNumber`,
    `joScheduleDetail`.`joScheduleModelID`,
    `joScheduleDetail`.`Quantity`,
    `joScheduleDetail`.`UnitCost`,
    `joScheduleDetail`.`PriceMultiplier`,
    `joScheduleDetail`.`Col01`,
    `joScheduleDetail`.`Col02`,
    `joScheduleDetail`.`Col03`,
    `joScheduleDetail`.`Col04`,
    `joScheduleDetail`.`Col05`,
    `joScheduleDetail`.`Col06`,
    `joScheduleDetail`.`Col07`,
    `joScheduleDetail`.`Col08`,
    `joScheduleDetail`.`Col09`,
    `joScheduleDetail`.`Col10`,
    `joScheduleDetail`.`Col11`,
    `joScheduleDetail`.`Col12`,
    `joScheduleDetail`.`Col13`,
    `joScheduleDetail`.`Col14`,
    `joScheduleDetail`.`Col15`,
    `joScheduleDetail`.`Col16`,
    `joScheduleDetail`.`Col17`,
    `joScheduleDetail`.`Col18`,
    `joScheduleDetail`.`Col19`,
    `joScheduleDetail`.`Col20`,
    `joScheduleDetail`.`FN_Factory`,
    `joScheduleDetail`.`FN_Engineer`,
    `joScheduleDetail`.`FN_Advise`,
    `joScheduleDetail`.`QtyOrdered`,
    `joScheduleDetail`.`Status`,
    `joScheduleDetail`.`Dimension`,
    `joScheduleDetail`.`TAG`
FROM `Hvac_company`.`joScheduleDetail`;
set countcheck=countcheck+1;
-- select 'joScheduleDetail',count(*) from joScheduleDetail;


if (_truncate=1) THEN truncate table `joSubmittalHeader`; END IF;

INSERT IGNORE INTO `joSubmittalHeader`
(`joSubmittalHeaderID`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`joMasterID`,
`Revision`,
`SubmittalByID`,
`SubmittalDate`,
`Copies`,
`RevisionNote`,
`RemarkNote`,
`PlanDate`,
`Addendum`,
`SignedByID`,
`ForRecordOnly`
)
SELECT `joSubmittalHeader`.`joSubmittalHeaderID`,
    `joSubmittalHeader`.`CreatedByID`,
    `joSubmittalHeader`.`CreatedOn`,
    `joSubmittalHeader`.`ChangedByID`,
    `joSubmittalHeader`.`ChangedOn`,
    `joSubmittalHeader`.`joMasterID`,
    `joSubmittalHeader`.`Revision`,
    `joSubmittalHeader`.`SubmittalByID`,
    `joSubmittalHeader`.`SubmittalDate`,
    `joSubmittalHeader`.`Copies`,
    `joSubmittalHeader`.`RevisionNote`,
    `joSubmittalHeader`.`RemarkNote`,
    `joSubmittalHeader`.`PlanDate`,
    `joSubmittalHeader`.`Addendum`,
    `joSubmittalHeader`.`SignedByID`,
    `joSubmittalHeader`.`ForRecordOnly`
FROM `Hvac_company`.`joSubmittalHeader`;
set countcheck=countcheck+1;
-- select 'joSubmittalHeader',count(*) from joSubmittalHeader;





if (_truncate=1) THEN truncate table `moTransaction`; END IF;

INSERT IGNORE INTO `moTransaction`
(`moTransactionID`,
`rxMasterID`,
`rxAddressID`,
`coAccountID`,
`moAccountID`,
`TransactionDate`,
`moTransactionTypeID`,
`CheckType`,
`Reference`,
`Description`,
`Void`,
`Reconciled`,
`TempRec`,
`Printed`,
`Amount`,
`DirectDeposit`
-- `balance`,
-- `status`,
-- `memo`,
-- `pageflagVoid`,
-- `uniquechkRef`
)
SELECT `moTransaction`.`moTransactionID`,
    `moTransaction`.`rxMasterID`,
    `moTransaction`.`rxAddressID`,
    `moTransaction`.`coAccountID`,
    `moTransaction`.`moAccountID`,
    `moTransaction`.`TransactionDate`,
    `moTransaction`.`moTransactionTypeID`,
    `moTransaction`.`CheckType`,
    `moTransaction`.`Reference`,
    `moTransaction`.`Description`,
    `moTransaction`.`Void`,
    `moTransaction`.`Reconciled`,
    `moTransaction`.`TempRec`,
    `moTransaction`.`Printed`,
    `moTransaction`.`Amount`,
    `moTransaction`.`DirectDeposit`
FROM `Hvac_company`.`moTransaction`;
set countcheck=countcheck+1;
-- select 'moTransaction',count(*) from moTransaction;


if (_truncate=1) THEN truncate table `prMaster`; END IF;

INSERT IGNORE INTO `prMaster`
(`prMasterID`,
`prDepartmentID`,
`prCategoryID`,
`ItemCode`,
`Description`,
`InActive`,
`IsInventory`,
`IsTaxable`,
`PrintOnPOs`,
`PrintOnSOs`,
`PurchasingUnitMultiplier`,
`PurchasingUnitOfMeasure`,
`SalesUnitMultiplier`,
`SalesUnitOfMeasure`,
`rxMasterIDPrimaryVendor`,
`VendorItemNumber`,
-- `NewPrice`,
-- `OldPrice`,
-- `LastCost`,
`SalesPrice00`,
`SalesPrice01`,
`SalesPrice02`,
`SalesPrice03`,
`SalesPrice04`,
`SalesPrice05`,
`SalesPrice10`,
`SalesPrice11`,
`SalesPrice12`,
`SalesPrice13`,
`SalesPrice14`,
`SalesPrice15`,
`SalesPrice20`,
`SalesPrice21`,
`SalesPrice22`,
`SalesPrice23`,
`SalesPrice24`,
`SalesPrice25`,
`SalesPrice30`,
`SalesPrice31`,
`SalesPrice32`,
`SalesPrice33`,
`SalesPrice34`,
`SalesPrice35`,
`SalesPrice40`,
`SalesPrice41`,
`SalesPrice42`,
`SalesPrice43`,
`SalesPrice44`,
`SalesPrice45`,
`SalesPrice50`,
`SalesPrice51`,
`SalesPrice52`,
`SalesPrice53`,
`SalesPrice54`,
`SalesPrice55`,
`InitialCost`,
`AverageCost`,
-- `oldAverageCost`,
`InventoryOnHand`,
`InventoryAllocated`,
`InventoryOnOrder`,
`InventoryOrderPoint`,
`InventoryOrderQuantity`,
`QuantityBreak0`,
`QuantityBreak1`,
`QuantityBreak2`,
`QuantityBreak3`,
`QuantityBreak4`,
`QuantityBreak5`,
`SingleItemTax`,
`HasInitialCost`,
`CostAsOf`,
`InitialOnHand`,
`Weight`,
`POCost`,
`BoxQty`,
`CreatedOn`,
`CreatedByID`,
`Website`,
`SalesPrice00_Old`,
`SalesPrice00_New`,
`SalesPrice00_Changed`,
`SalesPrice10_Old`,
`SalesPrice10_New`,
`SalesPrice10_Changed`,
`SalesPrice20_Old`,
`SalesPrice20_New`,
`SalesPrice20_Changed`,
`SalesPrice30_Old`,
`SalesPrice30_New`,
`SalesPrice30_Changed`,
`SalesPrice40_Old`,
`SalesPrice40_New`,
`SalesPrice40_Changed`,
`SalesPrice50_Old`,
`SalesPrice50_New`,
`SalesPrice50_Changed`,
`AverageCost_Old`,
`AverageCost_New`,
`AverageCost_Changed`,
`POCost_Old`,
`POCost_New`,
`POCost_Changed`,
`POMult`,
`SOPopup`,
`Consignment`,
`POPopup`,
`CUPopup`,
`PrintOnCUs`,
`PrintOnPTs`,
`Labor`,
`AutoAssemble`,
`rxMasterIDSecondaryVendor01`,
`rxMasterIDSecondaryVendor02`,
`rxMasterIDSecondaryVendor03`,
`rxMasterIDSecondaryVendor04`,
`rxMasterIDSecondaryVendor05`,
`VendorItemNumber01`,
`VendorItemNumber02`,
`VendorItemNumber03`,
`VendorItemNumber04`,
`VendorItemNumber05`,
`Serialized`,
`Submitted`
-- `LastUpdatedTime`
)
SELECT `prMaster`.`prMasterID`,
    `prMaster`.`prDepartmentID`,
    `prMaster`.`prCategoryID`,
    `prMaster`.`ItemCode`,
    `prMaster`.`Description`,
    `prMaster`.`InActive`,
    `prMaster`.`IsInventory`,
    `prMaster`.`IsTaxable`,
    `prMaster`.`PrintOnPOs`,
    `prMaster`.`PrintOnSOs`,
    `prMaster`.`PurchasingUnitMultiplier`,
    `prMaster`.`PurchasingUnitOfMeasure`,
    `prMaster`.`SalesUnitMultiplier`,
    `prMaster`.`SalesUnitOfMeasure`,
    `prMaster`.`rxMasterIDPrimaryVendor`,
    `prMaster`.`VendorItemNumber`,
    `prMaster`.`SalesPrice00`,
    `prMaster`.`SalesPrice01`,
    `prMaster`.`SalesPrice02`,
    `prMaster`.`SalesPrice03`,
    `prMaster`.`SalesPrice04`,
    `prMaster`.`SalesPrice05`,
    `prMaster`.`SalesPrice10`,
    `prMaster`.`SalesPrice11`,
    `prMaster`.`SalesPrice12`,
    `prMaster`.`SalesPrice13`,
    `prMaster`.`SalesPrice14`,
    `prMaster`.`SalesPrice15`,
    `prMaster`.`SalesPrice20`,
    `prMaster`.`SalesPrice21`,
    `prMaster`.`SalesPrice22`,
    `prMaster`.`SalesPrice23`,
    `prMaster`.`SalesPrice24`,
    `prMaster`.`SalesPrice25`,
    `prMaster`.`SalesPrice30`,
    `prMaster`.`SalesPrice31`,
    `prMaster`.`SalesPrice32`,
    `prMaster`.`SalesPrice33`,
    `prMaster`.`SalesPrice34`,
    `prMaster`.`SalesPrice35`,
    `prMaster`.`SalesPrice40`,
    `prMaster`.`SalesPrice41`,
    `prMaster`.`SalesPrice42`,
    `prMaster`.`SalesPrice43`,
    `prMaster`.`SalesPrice44`,
    `prMaster`.`SalesPrice45`,
    `prMaster`.`SalesPrice50`,
    `prMaster`.`SalesPrice51`,
    `prMaster`.`SalesPrice52`,
    `prMaster`.`SalesPrice53`,
    `prMaster`.`SalesPrice54`,
    `prMaster`.`SalesPrice55`,
    `prMaster`.`InitialCost`,
    `prMaster`.`AverageCost`,
    `prMaster`.`InventoryOnHand`,
    `prMaster`.`InventoryAllocated`,
    `prMaster`.`InventoryOnOrder`,
    `prMaster`.`InventoryOrderPoint`,
    `prMaster`.`InventoryOrderQuantity`,
    `prMaster`.`QuantityBreak0`,
    `prMaster`.`QuantityBreak1`,
    `prMaster`.`QuantityBreak2`,
    `prMaster`.`QuantityBreak3`,
    `prMaster`.`QuantityBreak4`,
    `prMaster`.`QuantityBreak5`,
    `prMaster`.`SingleItemTax`,
    `prMaster`.`HasInitialCost`,
    `prMaster`.`CostAsOf`,
    `prMaster`.`InitialOnHand`,
    `prMaster`.`Weight`,
    `prMaster`.`POCost`,
    `prMaster`.`BoxQty`,
    `prMaster`.`CreatedOn`,
    `prMaster`.`CreatedByID`,
    `prMaster`.`Website`,
    `prMaster`.`SalesPrice00_Old`,
    `prMaster`.`SalesPrice00_New`,
    `prMaster`.`SalesPrice00_Changed`,
    `prMaster`.`SalesPrice10_Old`,
    `prMaster`.`SalesPrice10_New`,
    `prMaster`.`SalesPrice10_Changed`,
    `prMaster`.`SalesPrice20_Old`,
    `prMaster`.`SalesPrice20_New`,
    `prMaster`.`SalesPrice20_Changed`,
    `prMaster`.`SalesPrice30_Old`,
    `prMaster`.`SalesPrice30_New`,
    `prMaster`.`SalesPrice30_Changed`,
    `prMaster`.`SalesPrice40_Old`,
    `prMaster`.`SalesPrice40_New`,
    `prMaster`.`SalesPrice40_Changed`,
    `prMaster`.`SalesPrice50_Old`,
    `prMaster`.`SalesPrice50_New`,
    `prMaster`.`SalesPrice50_Changed`,
    `prMaster`.`AverageCost_Old`,
    `prMaster`.`AverageCost_New`,
    `prMaster`.`AverageCost_Changed`,
    `prMaster`.`POCost_Old`,
    `prMaster`.`POCost_New`,
    `prMaster`.`POCost_Changed`,
    `prMaster`.`POMult`,
    `prMaster`.`SOPopup`,
    `prMaster`.`Consignment`,
    `prMaster`.`POPopup`,
    `prMaster`.`CUPopup`,
    `prMaster`.`PrintOnCUs`,
    `prMaster`.`PrintOnPTs`,
    `prMaster`.`Labor`,
    `prMaster`.`AutoAssemble`,
    `prMaster`.`rxMasterIDSecondaryVendor01`,
    `prMaster`.`rxMasterIDSecondaryVendor02`,
    `prMaster`.`rxMasterIDSecondaryVendor03`,
    `prMaster`.`rxMasterIDSecondaryVendor04`,
    `prMaster`.`rxMasterIDSecondaryVendor05`,
    `prMaster`.`VendorItemNumber01`,
    `prMaster`.`VendorItemNumber02`,
    `prMaster`.`VendorItemNumber03`,
    `prMaster`.`VendorItemNumber04`,
    `prMaster`.`VendorItemNumber05`,
    `prMaster`.`Serialized`,
    `prMaster`.`Submitted`
FROM `Hvac_company`.`prMaster`;
set countcheck=countcheck+1;
-- select 'prMaster',count(*) from prMaster;


if (_truncate=1) THEN truncate table `prTransfer`; END IF;

INSERT IGNORE INTO `prTransfer`
(`prTransferID`,
`TransferDate`,
`prFromWarehouseID`,
`prToWarehouseID`,
`Description`,
`coAccountID`,
`cuSOID`,
`Assemble_prMasterID`
-- `screenno`
)
SELECT `prTransfer`.`prTransferID`,
    `prTransfer`.`TransferDate`,
    `prTransfer`.`prFromWarehouseID`,
    `prTransfer`.`prToWarehouseID`,
    `prTransfer`.`Description`,
    `prTransfer`.`coAccountID`,
    `prTransfer`.`cuSOID`,
    `prTransfer`.`Assemble_prMasterID`
FROM `Hvac_company`.`prTransfer`;
set countcheck=countcheck+1;
-- select 'prTransfer',count(*) from prTransfer;


if (_truncate=1) THEN truncate table `prWarehouse`; END IF;

INSERT INTO `TP_struct`.`prWarehouse`
(`prWarehouseID`,
`SearchName`,
`Description`,
`InActive`,
`Address1`,
`Address2`,
`City`,
`State`,
`Zip`,
`coAccountIDAsset`,
`coTaxTerritoryID`,
`PrinterName`,
`EMail`,
`PickTicketInfo`,
`IsLaserPrinter`,
`PrinterCopies`
-- `adjustCogAccountID`
)
SELECT `prWarehouse`.`prWarehouseID`,
    `prWarehouse`.`SearchName`,
    `prWarehouse`.`Description`,
    `prWarehouse`.`InActive`,
    `prWarehouse`.`Address1`,
    `prWarehouse`.`Address2`,
    `prWarehouse`.`City`,
    `prWarehouse`.`State`,
    `prWarehouse`.`Zip`,
    `prWarehouse`.`coAccountIDAsset`,
    `prWarehouse`.`coTaxTerritoryID`,
    `prWarehouse`.`PrinterName`,
    `prWarehouse`.`EMail`,
    `prWarehouse`.`PickTicketInfo`,
    `prWarehouse`.`IsLaserPrinter`,
    `prWarehouse`.`PrinterCopies`
FROM `Hvac_company`.`prWarehouse`;
set countcheck=countcheck+1;
-- select 'prWarehouse',count(*) from prWarehouse;


if (_truncate=1) THEN truncate table `prWarehouseInventory`; END IF;

INSERT IGNORE INTO `prWarehouseInventory`
(`prWarehouseInventoryID`,
`prMasterID`,
`prWarehouseID`,
`InventoryOnHand`,
`InventoryAllocated`,
`InventoryOnOrder`,
`Bin`,
`HasInitialCost`,
`InitialCost`,
`CostAsof`,
`AverageCost`,
`SalePrice00`,
`SalePrice01`,
`SalePrice02`,
`SalePrice03`,
`SalePrice04`,
`SalePrice05`,
`InitialOnHand`
-- `LastUpdatedTime`
)
SELECT `prWarehouseInventory`.`prWarehouseInventoryID`,
    `prWarehouseInventory`.`prMasterID`,
    `prWarehouseInventory`.`prWarehouseID`,
    `prWarehouseInventory`.`InventoryOnHand`,
    `prWarehouseInventory`.`InventoryAllocated`,
    `prWarehouseInventory`.`InventoryOnOrder`,
    `prWarehouseInventory`.`Bin`,
    `prWarehouseInventory`.`HasInitialCost`,
    `prWarehouseInventory`.`InitialCost`,
    `prWarehouseInventory`.`CostAsof`,
    `prWarehouseInventory`.`AverageCost`,
    `prWarehouseInventory`.`SalePrice00`,
    `prWarehouseInventory`.`SalePrice01`,
    `prWarehouseInventory`.`SalePrice02`,
    `prWarehouseInventory`.`SalePrice03`,
    `prWarehouseInventory`.`SalePrice04`,
    `prWarehouseInventory`.`SalePrice05`,
    `prWarehouseInventory`.`InitialOnHand`
FROM `Hvac_company`.`prWarehouseInventory`;
set countcheck=countcheck+1;
-- select 'prWarehouseInventory',count(*) from prWarehouseInventory;


if (_truncate=1) THEN truncate table `prWHtransfer`; END IF;

INSERT IGNORE INTO `prWHtransfer`
(`prTransferID`,
`TransferDate`,
`prFromWareHouseID`,
`prToWareHouseID`,
`TransNumber`,
`Description`,
`ReceivedDate`
-- `EstreceiveDate`,
-- `coAccountID`,
-- `reasonCode`,
-- `adjustCogAccountID`,
-- `CreatedById`,
-- `CreatedOn`,
-- `screenno`,
-- `prtansferID_dummy`
)
SELECT `prWHtransfer`.`prTransferID`,
    `prWHtransfer`.`TransferDate`,
    `prWHtransfer`.`prFromWareHouseID`,
    `prWHtransfer`.`prToWareHouseID`,
    `prWHtransfer`.`TransNumber`,
    `prWHtransfer`.`Description`,
    `prWHtransfer`.`ReceivedDate`
FROM `Hvac_company`.`prWHtransfer`;
set countcheck=countcheck+1;
-- select 'prWHtransfer',count(*) from prWHtransfer;


if (_truncate=1) THEN truncate table `prWHtransferDetail`; END IF;

INSERT IGNORE INTO `prWHtransferDetail`
(`prTransferDetailID`,
`prTransferID`,
`prMasterID`,
`Description`,
`QuantityTransfered`,
`InventoryCost`
-- `QuantityAvailable`,
-- `ItemCode`,
-- `difference`,
-- `fromBinId`,
-- `toBinId`,
-- `ReceivedDate`
)
SELECT `prWHtransferDetail`.`prTransferDetailID`,
    `prWHtransferDetail`.`prTransferID`,
    `prWHtransferDetail`.`prMasterID`,
    `prWHtransferDetail`.`Description`,
    `prWHtransferDetail`.`QuantityTransfered`,
    `prWHtransferDetail`.`InventoryCost`
FROM `Hvac_company`.`prWHtransferDetail`;
set countcheck=countcheck+1;
-- select 'prWHtransferDetail',count(*) from prWHtransferDetail;


if (_truncate=1) THEN truncate table `rxAddress`; END IF;

INSERT IGNORE INTO `rxAddress`
(`rxAddressID`,
`rxMasterID`,
`InActive`,
`Name`,
`Address1`,
`Address2`,
`City`,
`State`,
`Zip`,
`IsStreet`,
`IsMailing`,
`IsBillTo`,
`IsShipTo`,
`coTaxTerritoryID`
-- `otherBillTo`,
-- `otherShipTo`,
-- `Phone1`,
-- `Phone2`,
-- `Fax`,
-- `IsDefault`,
-- `IsRemitTo`
)
SELECT `rxAddress`.`rxAddressID`,
    `rxAddress`.`rxMasterID`,
    `rxAddress`.`InActive`,
    `rxAddress`.`Name`,
    `rxAddress`.`Address1`,
    `rxAddress`.`Address2`,
    `rxAddress`.`City`,
    `rxAddress`.`State`,
    `rxAddress`.`Zip`,
    `rxAddress`.`IsStreet`,
    `rxAddress`.`IsMailing`,
    `rxAddress`.`IsBillTo`,
    `rxAddress`.`IsShipTo`,
    `rxAddress`.`coTaxTerritoryID`
FROM `Hvac_company`.`rxAddress`;
set countcheck=countcheck+1;
-- select 'rxAddress',count(*) from rxAddress;


if (_truncate=1) THEN truncate table `rxContact`; END IF;

INSERT IGNORE INTO `rxContact`
(`rxContactID`,
`rxMasterID`,
`InActive`,
`Title`,
`FirstName`,
`MiddleInitial`,
`LastName`,
`JobPosition`,
`Phone`,
`Cell`,
`Pager`,
`Fax`,
`EMail`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`JobClass0`,
`JobClass1`,
`JobClass2`,
`JobClass3`,
`JobClass4`,
`JobClass5`,
`JobClass6`,
`JobClass7`,
`JobClass8`,
`JobClass9`,
`cuAssignmentID0`,
`Division`
-- `extension`,
-- `DirectLine`
)
SELECT `rxContact`.`rxContactID`,
    `rxContact`.`rxMasterID`,
    `rxContact`.`InActive`,
    `rxContact`.`Title`,
    `rxContact`.`FirstName`,
    `rxContact`.`MiddleInitial`,
    `rxContact`.`LastName`,
    `rxContact`.`JobPosition`,
    `rxContact`.`Phone`,
    `rxContact`.`Cell`,
    `rxContact`.`Pager`,
    `rxContact`.`Fax`,
    `rxContact`.`EMail`,
    `rxContact`.`CreatedByID`,
    `rxContact`.`CreatedOn`,
    `rxContact`.`ChangedByID`,
    `rxContact`.`ChangedOn`,
    `rxContact`.`JobClass0`,
    `rxContact`.`JobClass1`,
    `rxContact`.`JobClass2`,
    `rxContact`.`JobClass3`,
    `rxContact`.`JobClass4`,
    `rxContact`.`JobClass5`,
    `rxContact`.`JobClass6`,
    `rxContact`.`JobClass7`,
    `rxContact`.`JobClass8`,
    `rxContact`.`JobClass9`,
    `rxContact`.`cuAssignmentID0`,
    `rxContact`.`Division`
FROM `Hvac_company`.`rxContact`;
set countcheck=countcheck+1;
-- select 'rxContact',count(*) from rxContact;


if (_truncate=1) THEN truncate table `rxMaster`; END IF;

INSERT IGNORE INTO `rxMaster`
(`rxMasterID`,
-- `TempList`,
-- `OldCode_JMFIRMID`,
-- `OldCode_CUSTNO`,
-- `OldCode_VENDOR`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`InActive`,
`Name`,
`SearchName`,
`FirstName`,
`MiddleInitial`,
`Phone1`,
`Phone2`,
`Phone3`,
`Fax`,
`IsCustomer`,
`IsVendor`,
`IsEmployee`,
`IsCategory1`,
`IsCategory2`,
`IsCategory3`,
`IsCategory4`,
`IsCategory5`,
`IsCategory6`,
`Note`,
`IsProspect`,
`Websight`,
`AltManufacturer`,
`isCategory7`,
`isCategory8`
-- `iscategory7Duplicate`
)
SELECT `rxMaster`.`rxMasterID`,
    `rxMaster`.`CreatedByID`,
    `rxMaster`.`CreatedOn`,
    `rxMaster`.`ChangedByID`,
    `rxMaster`.`ChangedOn`,
    `rxMaster`.`InActive`,
    `rxMaster`.`Name`,
    `rxMaster`.`SearchName`,
    `rxMaster`.`FirstName`,
    `rxMaster`.`MiddleInitial`,
    `rxMaster`.`Phone1`,
    `rxMaster`.`Phone2`,
    `rxMaster`.`Phone3`,
    `rxMaster`.`Fax`,
    `rxMaster`.`IsCustomer`,
    `rxMaster`.`IsVendor`,
    `rxMaster`.`IsEmployee`,
    `rxMaster`.`IsCategory1`,
    `rxMaster`.`IsCategory2`,
    `rxMaster`.`IsCategory3`,
    `rxMaster`.`IsCategory4`,
    `rxMaster`.`IsCategory5`,
    `rxMaster`.`IsCategory6`,
    `rxMaster`.`Note`,
    `rxMaster`.`IsProspect`,
    `rxMaster`.`Websight`,
    `rxMaster`.`AltManufacturer`,
    `rxMaster`.`isCategory7`,
    `rxMaster`.`isCategory8`
FROM `Hvac_company`.`rxMaster`;
set countcheck=countcheck+1;
-- select 'rxMaster',count(*) from rxMaster;


if (_truncate=1) THEN truncate table `sysAccountLinkage`; END IF;

INSERT IGNORE INTO `sysAccountLinkage`
(`sysAccountLinkageID`,
`coAccountIDNetSales`,
`coAccountIDPL`,
`coAccountIDCurEarnings`,
`coAccountIDRetainedEarnings`,
`coAccountIDAR`,
`coAccountIDDiscounts`,
`coAccountIDSalesTaxInv`,
`coAccountIDShipping`,
`coAccountIDOtherCharges`,
`coAccountIDPayments`,
`coAccountIDAP`,
`coAccountIDFreight`,
`coAccountIDSalesTaxPaid`,
`coAccountIDDiscountsTaken`,
`coAccountIDMisc`,
`coRangeAsset1`,
`coRangeAsset2`,
`coRangeLiability1`,
`coRangeLiability2`,
`coRangeEquity1`,
`coRangeEquity2`,
`coRangeIncome1`,
`coRangeIncome2`,
`coRangeExpense1`,
`coRangeExpense2`,
`coAccountIDShipInventory`,
`coAccountIDInventoryAdjustment`
-- `coAccountIDAccrual`
)
SELECT `sysAccountLinkage`.`sysAccountLinkageID`,
    `sysAccountLinkage`.`coAccountIDNetSales`,
    `sysAccountLinkage`.`coAccountIDPL`,
    `sysAccountLinkage`.`coAccountIDCurEarnings`,
    `sysAccountLinkage`.`coAccountIDRetainedEarnings`,
    `sysAccountLinkage`.`coAccountIDAR`,
    `sysAccountLinkage`.`coAccountIDDiscounts`,
    `sysAccountLinkage`.`coAccountIDSalesTaxInv`,
    `sysAccountLinkage`.`coAccountIDShipping`,
    `sysAccountLinkage`.`coAccountIDOtherCharges`,
    `sysAccountLinkage`.`coAccountIDPayments`,
    `sysAccountLinkage`.`coAccountIDAP`,
    `sysAccountLinkage`.`coAccountIDFreight`,
    `sysAccountLinkage`.`coAccountIDSalesTaxPaid`,
    `sysAccountLinkage`.`coAccountIDDiscountsTaken`,
    `sysAccountLinkage`.`coAccountIDMisc`,
    `sysAccountLinkage`.`coRangeAsset1`,
    `sysAccountLinkage`.`coRangeAsset2`,
    `sysAccountLinkage`.`coRangeLiability1`,
    `sysAccountLinkage`.`coRangeLiability2`,
    `sysAccountLinkage`.`coRangeEquity1`,
    `sysAccountLinkage`.`coRangeEquity2`,
    `sysAccountLinkage`.`coRangeIncome1`,
    `sysAccountLinkage`.`coRangeIncome2`,
    `sysAccountLinkage`.`coRangeExpense1`,
    `sysAccountLinkage`.`coRangeExpense2`,
    `sysAccountLinkage`.`coAccountIDShipInventory`,
    `sysAccountLinkage`.`coAccountIDInventoryAdjustment`
FROM `Hvac_company`.`sysAccountLinkage`;
set countcheck=countcheck+1;
-- select 'sysAccountLinkage',count(*) from sysAccountLinkage;

if (_truncate=1) THEN truncate table `sysInfo`; END IF;

INSERT IGNORE INTO `sysInfo`
(`sysInfoID`,
`DataMark`,
`DBRequiresMajor`,
`DBRequiresMinor`,
`DBRequiresRevision`,
`LatestMajor`,
`LatestMinor`,
`LatestRevision`,
`Locked`,
`LockedReason`,
`CashBasisAccounting`,
`CurrentFiscalYearID`,
`CurrentPeriodID`,
`CashBasis`,
`rxMasterCategory1Desc`,
`rxMasterCategory2Desc`,
`rxMasterCategory3Desc`,
`rxMasterCategory4Desc`,
`rxMasterCategory5Desc`,
`rxMasterCategory6Desc`,
`coCompanyNameAddress0`,
`coCompanyNameAddress1`,
`coCompanyNameAddress2`,
`coCompanyNameAddress3`,
`coCompanyNameAddress4`,
`prPriceLevel0`,
`prPriceLevel1`,
`prPriceLevel2`,
`prPriceLevel3`,
`prPriceLevel4`,
`prPriceLevel5`,
`prPriceLevel6`,
`BillPayAccountID`,
`POBillTo_Name`,
`POBillTo_Address1`,
`POBillTo_Address2`,
`POBillTo_City`,
`POBillTo_State`,
`POBillTo_Zip`,
`POShipTo_Name`,
`POShipTo_Address1`,
`POShipTo_Address2`,
`POShipTo_City`,
`POShipTo_State`,
`POShipTo_Zip`,
`joSource1Desc`,
`joSource2Desc`,
`joSource3Desc`,
`joSource4Desc`,
`QuotedPriceID`,
`RepDeduct1Desc`,
`RepDeduct2Desc`,
`RepDeduct3Desc`,
`RepDeduct4Desc`,
`SalesMgrID`,
`CommissionOverride`,
`SalesTaxDist1`,
`SalesTaxDist2`,
`SalesTaxDist3`,
`SalesTaxDist4`,
`SalesTaxDist5`,
`SalesTaxDist6`,
`SalesTaxDist7`,
`SalesTaxDist8`,
`rxMasterCategory7Desc`,
`rxMasterCategory8Desc`,
`AlternatePOAddress`,
`POName`,
`POStreet1`,
`POStreet2`,
`POCity`,
`POState`,
`POZip`,
`DetailSequenceID`,
`CreditCardServer`
--  `prPriceLevelval0`,
-- `prPriceLevelval1`,
-- `prPriceLevelval2`,
-- `prPriceLevelval3`,
-- `prPriceLevelval4`,
-- `prPriceLevelval5`
)
SELECT `sysInfo`.`sysInfoID`,
    `sysInfo`.`DataMark`,
    `sysInfo`.`DBRequiresMajor`,
    `sysInfo`.`DBRequiresMinor`,
    `sysInfo`.`DBRequiresRevision`,
    `sysInfo`.`LatestMajor`,
    `sysInfo`.`LatestMinor`,
    `sysInfo`.`LatestRevision`,
    `sysInfo`.`Locked`,
    `sysInfo`.`LockedReason`,
    `sysInfo`.`CashBasisAccounting`,
    `sysInfo`.`CurrentFiscalYearID`,
    `sysInfo`.`CurrentPeriodID`,
    `sysInfo`.`CashBasis`,
    `sysInfo`.`rxMasterCategory1Desc`,
    `sysInfo`.`rxMasterCategory2Desc`,
    `sysInfo`.`rxMasterCategory3Desc`,
    `sysInfo`.`rxMasterCategory4Desc`,
    `sysInfo`.`rxMasterCategory5Desc`,
    `sysInfo`.`rxMasterCategory6Desc`,
    `sysInfo`.`coCompanyNameAddress0`,
    `sysInfo`.`coCompanyNameAddress1`,
    `sysInfo`.`coCompanyNameAddress2`,
    `sysInfo`.`coCompanyNameAddress3`,
    `sysInfo`.`coCompanyNameAddress4`,
    `sysInfo`.`prPriceLevel0`,
    `sysInfo`.`prPriceLevel1`,
    `sysInfo`.`prPriceLevel2`,
    `sysInfo`.`prPriceLevel3`,
    `sysInfo`.`prPriceLevel4`,
    `sysInfo`.`prPriceLevel5`,
    `sysInfo`.`prPriceLevel6`,
    `sysInfo`.`BillPayAccountID`,
    `sysInfo`.`POBillTo_Name`,
    `sysInfo`.`POBillTo_Address1`,
    `sysInfo`.`POBillTo_Address2`,
    `sysInfo`.`POBillTo_City`,
    `sysInfo`.`POBillTo_State`,
    `sysInfo`.`POBillTo_Zip`,
    `sysInfo`.`POShipTo_Name`,
    `sysInfo`.`POShipTo_Address1`,
    `sysInfo`.`POShipTo_Address2`,
    `sysInfo`.`POShipTo_City`,
    `sysInfo`.`POShipTo_State`,
    `sysInfo`.`POShipTo_Zip`,
    `sysInfo`.`joSource1Desc`,
    `sysInfo`.`joSource2Desc`,
    `sysInfo`.`joSource3Desc`,
    `sysInfo`.`joSource4Desc`,
    `sysInfo`.`QuotedPriceID`,
    `sysInfo`.`RepDeduct1Desc`,
    `sysInfo`.`RepDeduct2Desc`,
    `sysInfo`.`RepDeduct3Desc`,
    `sysInfo`.`RepDeduct4Desc`,
    `sysInfo`.`SalesMgrID`,
    `sysInfo`.`CommissionOverride`,
    `sysInfo`.`SalesTaxDist1`,
    `sysInfo`.`SalesTaxDist2`,
    `sysInfo`.`SalesTaxDist3`,
    `sysInfo`.`SalesTaxDist4`,
    `sysInfo`.`SalesTaxDist5`,
    `sysInfo`.`SalesTaxDist6`,
    `sysInfo`.`SalesTaxDist7`,
    `sysInfo`.`SalesTaxDist8`,
    `sysInfo`.`rxMasterCategory7Desc`,
    `sysInfo`.`rxMasterCategory8Desc`,
    `sysInfo`.`AlternatePOAddress`,
    `sysInfo`.`POName`,
    `sysInfo`.`POStreet1`,
    `sysInfo`.`POStreet2`,
    `sysInfo`.`POCity`,
    `sysInfo`.`POState`,
    `sysInfo`.`POZip`,
    `sysInfo`.`DetailSequenceID`,
    `sysInfo`.`CreditCardServer`
FROM `Hvac_company`.`sysInfo`;
set countcheck=countcheck+1;
-- select 'sysInfo',count(*) from sysInfo;


if (_truncate=1) THEN truncate table `UserLoginClone`; END IF;

INSERT INTO `TP_struct`.`UserLoginClone`
(`UserLoginID`,
`LoginName`,
`LoginPassword`,
`FullName`,
`Initials`
-- `SystemAdministrator`,
-- `SalesRep`,
-- `Employee0`,
-- `Employee1`,
-- `Employee2`,
-- `Employee3`,
-- `Employee4`,
-- `Inactive`,
-- `EmailName`,
-- `EmailAddr`,
-- `LogOnName`,
-- `LogOnPswd`,
-- `UseAuthentication`,
-- `CCAddr1`,
-- `CCName1`,
-- `CCAddr2`,
-- `CCName2`,
-- `CCAddr3`,
-- `CCName3`,
-- `CCAddr4`,
-- `CCName4`,
-- `BCCaddr`,
-- `SMTPSvr`,
-- `SMTPEmailActive`,
-- `SMTPPort`,
-- `temppwd`
)
SELECT `UserLoginClone`.`UserLoginID`,
    `UserLoginClone`.`LoginName`,
    `UserLoginClone`.`LoginPassword`,
    `UserLoginClone`.`FullName`,
    `UserLoginClone`.`Initials`
FROM `Hvac_company`.`UserLoginClone`;
set countcheck=countcheck+1;
-- select 'UserLoginClone',count(*) from UserLoginClone;


if (_truncate=1) THEN truncate table `veBill`; END IF;

INSERT IGNORE INTO `TP_struct`.`veBill`
(`veBillID`,
`TransactionStatus`,
`rxMasterID`,
`vePOID`,
`joReleaseDetailID`,
`cuInvoiceID_ApplyCost`,
`BillDate`,
`UsePostDate`,
`ReceiveDate`,
`PostDate`,
`DueDate`,
`ShipDate`,
`BillAmount`,
`AppliedAmount`,
`TaxAmount`,
`FreightAmount`,
`InvoiceNumber`,
`APAccountID`,
`Void`,
`Applied`,
`veShipViaID`,
`TrackingNumber`,
-- `OldPONum`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`AdditionalFreight`,
`Note`
-- `Reason`,
-- `creditUsed`,
-- `assignCuinvoiceId`
)
SELECT `veBill`.`veBillID`,
    `veBill`.`TransactionStatus`,
    `veBill`.`rxMasterID`,
    `veBill`.`vePOID`,
    `veBill`.`joReleaseDetailID`,
    `veBill`.`cuInvoiceID_ApplyCost`,
    `veBill`.`BillDate`,
    `veBill`.`UsePostDate`,
    `veBill`.`ReceiveDate`,
    `veBill`.`PostDate`,
    `veBill`.`DueDate`,
    `veBill`.`ShipDate`,
    `veBill`.`BillAmount`,
    `veBill`.`AppliedAmount`,
    `veBill`.`TaxAmount`,
    `veBill`.`FreightAmount`,
    `veBill`.`InvoiceNumber`,
    `veBill`.`APAccountID`,
    `veBill`.`Void`,
    `veBill`.`Applied`,
    `veBill`.`veShipViaID`,
    `veBill`.`TrackingNumber`,
    `veBill`.`CreatedByID`,
    `veBill`.`CreatedOn`,
    `veBill`.`ChangedByID`,
    `veBill`.`ChangedOn`,
    `veBill`.`AdditionalFreight`,
    `veBill`.`Note`
FROM `Hvac_company`.`veBill`;
set countcheck=countcheck+1;
-- select 'veBill',count(*) from veBill;


if (_truncate=1) THEN truncate table `veBillDetail`; END IF;

INSERT IGNORE INTO `veBillDetail`
(`veBillDetailID`,
`veBillID`,
`vePODetailID`,
`prMasterID`,
`Description`,
`Note`,
`QuantityBilled`,
`UnitCost`,
`PriceMultiplier`,
`FreightCost`
-- `vePOID`,
-- `Taxable`
)
SELECT `veBillDetail`.`veBillDetailID`,
    `veBillDetail`.`veBillID`,
    `veBillDetail`.`vePODetailID`,
    `veBillDetail`.`prMasterID`,
    `veBillDetail`.`Description`,
    `veBillDetail`.`Note`,
    `veBillDetail`.`QuantityBilled`,
    `veBillDetail`.`UnitCost`,
    `veBillDetail`.`PriceMultiplier`,
    `veBillDetail`.`FreightCost`
FROM `Hvac_company`.`veBillDetail`;
set countcheck=countcheck+1;
-- select 'veBillDetail',count(*) from veBillDetail;


if (_truncate=1) THEN truncate table `veBillDistribution`; END IF;

INSERT IGNORE INTO `veBillDistribution`
(`veBillDistributionID`,
`veBillID`,
`coExpenseAccountID`,
`ExpenseAmount`,
`joMasterID`
-- `ecInvoicePeriodID`
)
SELECT `veBillDistribution`.`veBillDistributionID`,
    `veBillDistribution`.`veBillID`,
    `veBillDistribution`.`coExpenseAccountID`,
    `veBillDistribution`.`ExpenseAmount`,
    `veBillDistribution`.`joMasterID`
FROM `Hvac_company`.`veBillDistribution`;
set countcheck=countcheck+1;
-- select 'veBillDistribution',count(*) from veBillDistribution;


if (_truncate=1) THEN truncate table `veBillPay`; END IF;

INSERT IGNORE INTO `veBillPay`
(`veBillPayID`,
`veBillID`,
`ApplyingAmount`,
`DiscountAmount`
-- `moAccountId`,
-- `userID`
)
SELECT `veBillPay`.`veBillPayID`,
    `veBillPay`.`veBillID`,
    `veBillPay`.`ApplyingAmount`,
    `veBillPay`.`DiscountAmount`
FROM `Hvac_company`.`veBillPay`;
set countcheck=countcheck+1;
-- select 'veBillPay',count(*) from veBillPay;


if (_truncate=1) THEN truncate table `veCommDetail`; END IF;

INSERT IGNORE INTO `veCommDetail`
(`veCommDetailID`,
`rxMasterID`,
`joReleaseDetailID`,
`ShipDate`,
`veShipViaID`,
`TrackingNumber`,
`InvoiceNumber`,
`BillAmount`,
`CommDate`,
`CommAmount`
-- `ecInvoicePeriodID`,
-- `hasCustomerInvoice`
)
SELECT `veCommDetail`.`veCommDetailID`,
    `veCommDetail`.`rxMasterID`,
    `veCommDetail`.`joReleaseDetailID`,
    `veCommDetail`.`ShipDate`,
    `veCommDetail`.`veShipViaID`,
    `veCommDetail`.`TrackingNumber`,
    `veCommDetail`.`InvoiceNumber`,
    `veCommDetail`.`BillAmount`,
    `veCommDetail`.`CommDate`,
    `veCommDetail`.`CommAmount`
FROM `Hvac_company`.`veCommDetail`;
set countcheck=countcheck+1;
-- select 'veCommDetail',count(*) from veCommDetail;


if (_truncate=1) THEN truncate table `veMaster`; END IF;

INSERT IGNORE INTO `veMaster`
(`veMasterID`,
`DueDays`,
`DiscountDays`,
`DiscountPercent`,
`DueOnDay`,
`DiscOnDay`,
`DiscountIncludesFreight`,
`Manufacturer`,
`coExpenseAccountID`,
`Tax1099`,
`SSN`,
`ImportType`,
`AccountNumber`,
`DirectDeposit`,
`POName`,
`VendorTerms`
-- `expense1099Flag`,
-- `expense1099Id`,
-- `generalLiabilityDate`,
-- `workersCompensationDate`
)
SELECT `veMaster`.`veMasterID`,
    `veMaster`.`DueDays`,
    `veMaster`.`DiscountDays`,
    `veMaster`.`DiscountPercent`,
    `veMaster`.`DueOnDay`,
    `veMaster`.`DiscOnDay`,
    `veMaster`.`DiscountIncludesFreight`,
    `veMaster`.`Manufacturer`,
    `veMaster`.`coExpenseAccountID`,
    `veMaster`.`Tax1099`,
    `veMaster`.`SSN`,
    `veMaster`.`ImportType`,
    `veMaster`.`AccountNumber`,
    `veMaster`.`DirectDeposit`,
    `veMaster`.`POName`,
    `veMaster`.`VendorTerms`
FROM `Hvac_company`.`veMaster`;
set countcheck=countcheck+1;
-- select 'veMaster',count(*) from veMaster;


if (_truncate=1) THEN truncate table `vePO`; END IF;

INSERT IGNORE INTO `vePO`
(`vePOID`,
`CreatedByID`,
`CreatedOn`,
`ChangedByID`,
`ChangedOn`,
`TransactionStatus`,
`joReleaseID`,
`rxVendorID`,
`rxBillToID`,
`rxBillToAddressID`,
`rxShipToID`,
`rxShipToAddressID`,
`veShipViaID`,
`prWarehouseID`,
`veFreightChargesID`,
`OrderedByID`,
`BillToMode`,
`ShipToMode`,
`Acknowledged`,
`PONumber`,
`VendorOrderNumber`,
`CustomerPONumber`,
`OrderDate`,
`AcknowledgementDate`,
`EstimatedShipDate`,
`DateWanted`,
`Tag`,
`SpecialInstructions`,
`Subtotal`,
`TaxTotal`,
`Freight`,
`TaxRate`,
`rxVendorAddressID`,
`rxVendorContactID`,
`joSchedDetailID`,
`veFactoryID`,
`MultipleAcks`,
`FreightChargeNote`,
`Consignment`,
`cuSOID`,
`joStockReleaseID`
-- `billToIndex`,
-- `shipToIndex`,
-- `emailTimeStamp`,
-- `wantedOnOrBefore`,
-- `qbPO`,
-- `receiveddate`,
-- `rxShipToOtherAddressID`,
-- `isCareOfRequired`,
-- `isFrieghtNotRequired`
)
SELECT `vePO`.`vePOID`,
    `vePO`.`CreatedByID`,
    `vePO`.`CreatedOn`,
    `vePO`.`ChangedByID`,
    `vePO`.`ChangedOn`,
    `vePO`.`TransactionStatus`,
    `vePO`.`joReleaseID`,
    `vePO`.`rxVendorID`,
    `vePO`.`rxBillToID`,
    `vePO`.`rxBillToAddressID`,
    `vePO`.`rxShipToID`,
    `vePO`.`rxShipToAddressID`,
    `vePO`.`veShipViaID`,
    `vePO`.`prWarehouseID`,
    `vePO`.`veFreightChargesID`,
    `vePO`.`OrderedByID`,
    `vePO`.`BillToMode`,
    `vePO`.`ShipToMode`,
    `vePO`.`Acknowledged`,
    `vePO`.`PONumber`,
    `vePO`.`VendorOrderNumber`,
    `vePO`.`CustomerPONumber`,
    `vePO`.`OrderDate`,
    `vePO`.`AcknowledgementDate`,
    `vePO`.`EstimatedShipDate`,
    `vePO`.`DateWanted`,
    `vePO`.`Tag`,
    `vePO`.`SpecialInstructions`,
    `vePO`.`Subtotal`,
    `vePO`.`TaxTotal`,
    `vePO`.`Freight`,
    `vePO`.`TaxRate`,
    `vePO`.`rxVendorAddressID`,
    `vePO`.`rxVendorContactID`,
    `vePO`.`joSchedDetailID`,
    `vePO`.`veFactoryID`,
    `vePO`.`MultipleAcks`,
    `vePO`.`FreightChargeNote`,
    `vePO`.`Consignment`,
    `vePO`.`cuSOID`,
    `vePO`.`joStockReleaseID`
FROM `Hvac_company`.`vePO`;
set countcheck=countcheck+1;
-- select 'vePO',count(*) from vePO;


if (_truncate=1) THEN truncate table `vePODetail`; END IF;

INSERT IGNORE INTO `vePODetail`
(`vePODetailID`,
`vePOID`,
`prMasterID`,
`Description`,
`Note`,
`QuantityOrdered`,
`QuantityReceived`,
`QuantityBilled`,
`UnitCost`,
`PriceMultiplier`,
`Taxable`,
`EstimatedShipDate`,
`joSchedDetailID`,
`Acknowledged`,
`AcknowledgementDate`,
`VendorOrderNumber`,
`cuSODetailID`
-- `posistion`,
-- `QuantityInvoiced`
)
SELECT `vePODetail`.`vePODetailID`,
    `vePODetail`.`vePOID`,
    `vePODetail`.`prMasterID`,
    `vePODetail`.`Description`,
    `vePODetail`.`Note`,
    `vePODetail`.`QuantityOrdered`,
    `vePODetail`.`QuantityReceived`,
    `vePODetail`.`QuantityBilled`,
    `vePODetail`.`UnitCost`,
    `vePODetail`.`PriceMultiplier`,
    `vePODetail`.`Taxable`,
    `vePODetail`.`EstimatedShipDate`,
    `vePODetail`.`joSchedDetailID`,
    `vePODetail`.`Acknowledged`,
    `vePODetail`.`AcknowledgementDate`,
    `vePODetail`.`VendorOrderNumber`,
    `vePODetail`.`cuSODetailID`
FROM `Hvac_company`.`vePODetail`;
set countcheck=countcheck+1;
-- select 'vePODetail',count(*) from vePODetail;


if (_truncate=1) THEN truncate table `veReceiveDetail`; END IF;

INSERT IGNORE INTO `veReceiveDetail`
(`veReceiveDetailID`,
`veReceiveID`,
`vePODetailID`,
`prMasterID`,
`Description`,
`Note`,
`QuantityReceived`
-- `vePOID`
)
SELECT `veReceiveDetail`.`veReceiveDetailID`,
    `veReceiveDetail`.`veReceiveID`,
    `veReceiveDetail`.`vePODetailID`,
    `veReceiveDetail`.`prMasterID`,
    `veReceiveDetail`.`Description`,
    `veReceiveDetail`.`Note`,
    `veReceiveDetail`.`QuantityReceived`
FROM `Hvac_company`.`veReceiveDetail`;
set countcheck=countcheck+1;
 select countcheck;
-- select 'veReceiveDetail',count(*) from veReceiveDetail;




END$$

DELIMITER ;

-- ============================================================


DROP procedure IF EXISTS `ETL_TURBOREP_DEFAULT`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_TURBOREP_DEFAULT` (
	IN _truncate int
)
ETL_TURBOREP_DEFAULT :BEGIN

SET FOREIGN_KEY_CHECKS = 0;

if (_truncate=1) THEN truncate table `jocategory`; END IF;

INSERT INTO `jocategory` VALUES (8,'Salesrep'),(9,'AE'),(10,'Costing'),(11,'Submitting'),(12,'Ordering'),(13,'Take-Off'),(14,'Quote By');

if (_truncate=1) THEN truncate table `joChangeType`; END IF;

INSERT INTO `joChangeType` VALUES (1,'Buy/Resale'),(2,'Commission');

if (_truncate=1) THEN truncate table `tsAccessModule`; END IF;

INSERT INTO `tsAccessModule` VALUES (20001,'Home'),(20002,'Job'),(20003,'Sales'),(20004,'Project'),(20005,'Company'),(20006,'Inventory'),(20007,'Banking'),(20008,'Financial');

if (_truncate=1) THEN truncate table `tsAccessProcedure`; END IF;

INSERT INTO `tsAccessProcedure` VALUES (22001,20001,'New Job',NULL),(22002,20001,'Quick book',NULL),(23001,20002,'Main',NULL),(23002,20002,'Quotes',NULL),(23003,20002,'Submittal',NULL),(23004,20002,'Credit',NULL),(23005,20002,'Release',NULL),(23006,20002,'Financial',NULL),(23007,20002,'Journal',NULL),(24001,20003,'Sales',NULL),(24002,20003,'Sales Filter',NULL),(25001,20004,'Project',NULL),(25002,20004,'Project Filter',NULL),(26001,20005,'Customers',NULL),(26002,20005,'Payments',NULL),(26003,20005,'Statements',NULL),(26004,20005,'Sales Order',NULL),(26005,20005,'Invoice',NULL),(26006,20005,'Finance Changes',NULL),(26007,20005,'Tax Adjustments',NULL),(26008,20005,'Credit/Debit Memos',NULL),(26009,20005,'Sales Order Template',NULL),(26010,20005,'Purchase Orders',NULL),(26011,20005,'Vendors',NULL),(26012,20005,'Pay Bills',NULL),(26013,20005,'Invoice & Bills',NULL),(26014,20005,'Employees',NULL),(26015,20005,'Commissions',NULL),(26016,20005,'Rolodex',NULL),(26017,20005,'Users',NULL),(26018,20005,'Settings',NULL),(26019,20005,'Check Uncheck Categories',NULL),(26020,20005,'AddCostImport',NULL),(26021,20005,'Add New Customer',NULL),(26022,20005,'Add New Vendor',NULL),(27001,20006,'Inventory',NULL),(27002,20006,'Categories',NULL),(27003,20006,'Warehouses',NULL),(27004,20006,'Receive Inventory',NULL),(27005,20006,'Transfer',NULL),(27006,20006,'Order Points',NULL),(27007,20006,'Inventory Value',NULL),(27008,20006,'Count',NULL),(27009,20006,'Adjustments',NULL),(27010,20006,'Transactions',NULL),(27011,20006,'Bin Master',NULL),(28001,20007,'Banking',NULL),(28002,20007,'Write Checks',NULL),(28003,20007,'Reissue Checks',NULL),(28004,20007,'Recouncile Accounts',NULL),(29001,20008,'Chart Accounts',NULL),(29002,20008,'Divisions',NULL),(29003,20008,'Tax Territories',NULL),(29004,20008,'General Ledger',NULL),(29005,20008,'Journal Entries',NULL),(29006,20008,'Accounting Cycles',NULL),(29007,20008,'GL Transactions',NULL),(29008,20008,'Open Period Posting Only',NULL),(29009,20002,'Delete Jobs',NULL),(29010,20002,'Unlock Quotes',NULL),(29011,20008,'Sales_Tax',NULL),(29012,20002,'Change Contract Amount',NULL),(29013,20002,'LimitJobsToDivision',NULL);



END$$

DELIMITER ;

-- ==========================================================


DROP procedure IF EXISTS `ETL_TURBOREP_gl`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_TURBOREP_gl` (
 IN _truncate int
)
BEGIN
SET FOREIGN_KEY_CHECKS = 0;

if (_truncate=1) THEN truncate table `glTransaction`; END IF;

INSERT IGNORE INTO `glTransaction`
(
`coFiscalPeriodId`,
`period`,
`pStartDate`,
`pEndDate`,
`coFiscalYearId`,
`fyear`,
`yStartDate`,
`yEndDate`,
`journalId`,
`journalDesc`,
`entrydate`,
`enteredBy`,
`coAccountId`,
`coAccountNumber`,
`reference`,
`transactionDesc`,
`transactionDate`,
`debit`,
`credit`
)

select 
-- lh.TransactionReferenceID as transactionID,lh.coLedgerHeaderID, ld.coLedgerDetailID, lh.sourceNo, 
lh.coFiscalPeriodID, 
CASE 
WHEN MONTH(fp.StartDate)=8 THEN 8
WHEN MONTH(fp.StartDate)=9 THEN 9
WHEN MONTH(fp.StartDate)=10 THEN 10
WHEN MONTH(fp.StartDate)=11 THEN 11
WHEN MONTH(fp.StartDate)=12 THEN 12
WHEN MONTH(fp.StartDate)=1 THEN 1
WHEN MONTH(fp.StartDate)=2 THEN 2
WHEN MONTH(fp.StartDate)=3 THEN 3
WHEN MONTH(fp.StartDate)=4 THEN 4
WHEN MONTH(fp.StartDate)=5 THEN 5
WHEN MONTH(fp.StartDate)=6 THEN 6
WHEN MONTH(fp.StartDate)=7 THEN 7
END
as period,date(fp.StartDate) as pStartDate , date(fp.EndDate) as pEndDate,
fp.coFiscalYearID, YEAR(fy.StartDate) as fyear, date(fy.StartDate) as yStartDate, date(fy.EndDate) as yEndDate,
CASE
WHEN ls.Description='Bank Transaction' THEN 'BT'
WHEN ls.Description='Inventory Transfer' THEN 'IT'
WHEN ls.Description='Customer Invoices' THEN 'CI'
WHEN ls.Description='Customer Payments' THEN 'CP'
WHEN ls.Description='Vendor Bills' THEN 'VB'
WHEN ls.Description='JE' THEN 'JE'
ELSE null
END
as journalId,
ls.Description as journalDesc,
lh.PostDate as entryDate,
'ETL' as enteredBy,
ld.coAccountID as coAccountId,
a.Number as coAccountNumber,
ifnull(lh.Reference,lh.Description) as reference,
CASE
WHEN ls.Description='Bank Transaction' THEN lh.Description
WHEN ls.Description='Inventory Transfer' THEN lh.Description
WHEN ls.Description='Customer Invoices' THEN (select rx.Name from Hvac_company.cuInvoice ci 
left join Hvac_company.rxMaster rx on ci.rxCustomerID = rx.rxMasterID
where ci.InvoiceNumber=lh.Reference)
WHEN ls.Description='Customer Payments' THEN (select rx.Name from Hvac_company.cuReceipt cu
left join Hvac_company.rxMaster rx on rx.rxMasterID = cu.rxCustomerID
where cu.Reference = )
WHEN ls.Description='Vendor Bills' THEN (select rx.Name from Hvac_company.veBill vb
left join Hvac_company.rxMaster rx on rx.rxMasterID = vb.rxMasterID 
where vb.InvoiceNumber = lh.Reference)
WHEN ls.Description='JE' THEN lh.Description
ELSE null
END
as transactionDesc,
lh.PostDate as transactionDate,
CASE
WHEN a.DebitBalance=1 THEN abs(ld.Amount)
ELSE 0
END as debit,
CASE
WHEN a.DebitBalance=0 THEN abs(ld.Amount)
ELSE 0
END as credit

-- ld.Amount,
-- a.DebitBalance,
-- a.Description
from
Hvac_company.coLedgerDetail ld
left join Hvac_company.coLedgerHeader lh on (lh.coLedgerHeaderID = ld.coLedgerHeaderID)
left join Hvac_company.coFiscalPeriod fp on (fp.coFiscalPeriodID = lh.coFiscalPeriodID)
left join Hvac_company.coFiscalYear fy on (fy.coFiscalYearID = fp.coFiscalYearID)
left join Hvac_company.coLedgerSource ls on (lh.coLedgerSourceID = ls.coLedgerSourceID)
left join Hvac_company.coAccount a on (ld.coAccountID = a.coAccountID)
where lh.coLedgerHeaderID is not null
order by lh.TransactionReferenceID desc, ld.coLedgerDetailID;


if (_truncate=1) THEN truncate table `glLinkage`; END IF;

INSERT INTO `TP_struct`.`glLinkage`
(`entrydate`,
`coLedgerSourceId`,
`glTransactionId`,
`veBillID`,
`status`)
select g.entrydate,c.coLedgerSourceID,g.glTransactionId,
CASE
WHEN c.coLedgerSourceID=4230 THEN (select cuReceiptID from Hvac_company.cuReceipt where Reference = g.reference)
WHEN c.coLedgerSourceID=6220 THEN (select veBillID from Hvac_company.veBill where InvoiceNumber = g.reference)
WHEN c.coLedgerSourceID=4220 THEN (select cuInvoiceID from Hvac_company.cuInvoice where InvoiceNumber = g.reference)
ELSE g.reference
END
as veBillID,
0 from glTransaction g left join coLedgerSource c on g.journalId=c.JournalID;

END$$

DELIMITER ;

-- =============================================

DROP procedure IF EXISTS `ETL_upgradeDatabase`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_upgradeDatabase` (
IN _version INT,
IN _versionDesc varchar(255),
IN _schema  varchar(255)
)
ETL_upgradeDatabase:BEGIN
DECLARE colName varchar(25) default null;
-- DECLARE _schema varchar(50);

 -- set _schema = 'Bartos';
 -- select _schema;

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'prWHtransferDetail' AND column_name = 'fromBinId' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  prWHtransferDetail  ADD  fromBinId INT;
       -- select '..column binId added to prWHtransferDetail' ;
    END IF;
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'prWHtransferDetail' AND column_name = 'toBinId' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  prWHtransferDetail  ADD  toBinId INT;
       -- select '..column binId added to prWHtransferDetail' ;
    END IF;
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'prWHtransferDetail' AND column_name = 'ReceivedDate' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  prWHtransferDetail  ADD  ReceivedDate datetime;
       -- select '..column binId added to prWHtransferDetail' ;
    END IF;
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuMaster' AND column_name = 'invoiceYesNOmethod' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  cuMaster  ADD  invoiceYesNOmethod INT;
    END IF;
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuMaster' AND column_name = 'statementYesNOmethod' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  cuMaster  ADD  statementYesNOmethod INT;
    END IF;
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuMaster' AND column_name = 'invoiceYesDate' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  cuMaster  ADD  invoiceYesDate datetime;
    END IF;
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuMaster' AND column_name = 'statementYesDate' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  cuMaster  ADD  statementYesDate datetime;
    END IF;

  insert ignore into coLedgerSource (coLedgerSourceID,Description,JournalID) values (3230, 'Transfer Received','TR');  
  insert ignore into tsAccessProcedure (AccessProcedureID,AccessModuleID,ProcedureName) values (27011,20006,'Bin Master');

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tp_version' AND column_name = 'versionId' and TABLE_SCHEMA = _schema;

    IF colName is null THEN

      CREATE TABLE `tp_version` (
         versionId INT(11) NOT NULL AUTO_INCREMENT,
         description varchar(100) NULL DEFAULT '[TableMajor].[view].[procedure].[BaseData]',
         tableVersion INT  NULL,
         viewVersion INT  NULL,
         procedureVersion INT  NULL,
         functionVersion INT  NULL,
         baseDataVersion INT  NULL,
         tableVersionDesc varchar(100)  NULL,
         viewVersionDesc varchar(100)  NULL,
         procedureVersionDesc varchar(255)  NULL,
         functionVersionDesc varchar(255)  NULL,
         baseDataVersionDesc varchar(255)  NULL,
          PRIMARY KEY (`versionId`))
      ENGINE = InnoDB;

      insert tp_version (tableVersion,tableVersionDesc) values ('1', 'Initial Rollout');
    
    END IF;


 set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'veReceiveDetailBin' AND column_name = 'veReceiveDetailBinID'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

        CREATE TABLE `veReceiveDetailBin` (
           veReceiveDetailBinID INT(11) NOT NULL AUTO_INCREMENT,
           vePODetailID INT(11)  NOT NULL,
           veReceiveDetailID INT(11)  NOT NULL,
           prWarehouseID INT(11)  NOT NULL,
           prMasterID INT(11)  NOT NULL,
           binId INT(11) NOT NULL,
           InventoryPutAway decimal(19,4) NULL Default 0,  -- 400
           reversed INT(2) NOT NULL DEFAULT 0,  -- if = 1 then reversed
           GlRecordedTime datetime NULL,
           LastUpdatedTime datetime NOT NULL Default now(),
           changedByID INT(11)  NULL,
            PRIMARY KEY (`veReceiveDetailBinID`),
          INDEX IDX_veReceiveDetailID(veReceiveDetailID)
          )
        ENGINE = InnoDB;

      -- select '..bin created';

    END IF;

    -- TODO REMOVE THIS TABLE AND SWITCH EVERYTING OVER TO veReceiveDetailID
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'vePODetailBin' AND column_name = 'vePODetailBinID'  and TABLE_SCHEMA = _schema;
    
    DROP table IF EXISTS `vePODetailBin`;
    /*
    IF colName is null THEN

        CREATE TABLE `vePODetailBin` (
           vePODetailBinID INT(11) NOT NULL AUTO_INCREMENT,
           vePODetailID INT(11)  NOT NULL,
           prWarehouseID INT(11)  NOT NULL,
           prMasterID INT(11)  NOT NULL,
           binId INT(11) NOT NULL,
           InventoryPutAway decimal(19,4) NULL Default 0,  -- 400
           reversed INT(2) NOT NULL DEFAULT 0,  -- if = 1 then reversed
           GlRecordedTime datetime NULL,
           LastUpdatedTime datetime NOT NULL Default now(),
           changedByID INT(11)  NULL,
            PRIMARY KEY (`vePODetailBinID`),
          INDEX IDX_vePODetailID(vePODetailID)
          )
        ENGINE = InnoDB;
    
      -- select '..bin created';

    END IF;
    */
    
  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'bin' AND column_name = 'binId'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

        CREATE TABLE `bin` (
           binId INT(11) NOT NULL AUTO_INCREMENT,
           prWarehouseID INT(11)  NULL,
           prWarehouseInventoryID INT(11)  NULL,
           prMasterID INT(11)  NULL,
           binSequence INT(5) NOT NULL DEFAULT 1,
           rack varchar(100) NULL,
           row varchar(100) NULL,
           slot varchar(100) NULL,
           overrideName varchar(200) NULL,
           searchName varchar(200) NOT NULL,
           maxQuantity decimal(19,4) NULL Default 0,
           InventoryOnHand decimal(19,4) NULL Default 0,
           InventoryAllocated decimal(19,4) NULL Default 0,
           InventoryOnOrder decimal(19,4) NULL Default 0,
           AverageCost decimal(19,4) NULL Default 0,
           LastUpdatedTime datetime NOT NULL Default now(),
           changedByID INT(11)  NULL,
            PRIMARY KEY (`binId`),
          INDEX IDX_WHSEQ(prWarehouseInventoryID,binSequence),
          INDEX IDX_SEARCHNAME(searchName),
          UNIQUE UNIQUE_WHSEARCH(prWarehouseID,searchName)
          )
        ENGINE = InnoDB;

      -- select '..bin created';

    END IF;

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tempTierCommissions' AND column_name = 'commissionID'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

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

    END IF;


  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuSODetailBin' AND column_name = 'QuantityBilled'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

              DROP TABLE IF EXISTS cuSODetailBin;

              CREATE TABLE cuSODetailBin (
              cuSODetailBinID int auto_increment,
              `cuSODetailID` int(11) NULL,
              `binId` int(11) NOT NULL,
              `allocated` decimal(19,4)  NOT NULL default 0.000,
              `QuantityBilled` decimal(19,4)  NOT NULL default 0.000,
              `txState` varchar(5) NOT NULL DEFAULT 'A', -- A=allocated, UA=reversed
              `lastUpdated` datetime not NULL default CURRENT_TIMESTAMP(),
              PRIMARY KEY (`cuSODetailBinID`),
              INDEX `cuSODetailBin_IDX` (cuSODetailID,binId)
            ) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=latin1;

    END IF;

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuInvoiceDetailBin' AND column_name = 'QuantityBilled'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

              DROP TABLE IF EXISTS cuInvoiceDetailBin;

              CREATE TABLE cuInvoiceDetailBin (
              cuInvoiceDetailBinID int auto_increment,
              `cuInvoiceDetailID` int(11) NOT NULL,
              `cuSODetailBinID` int(11) NULL,
              `binId` int(11) NOT NULL,
              `QuantityBilled` decimal(19,4)  NOT NULL default 0.000,
              `txState` varchar(5) NOT NULL DEFAULT 'OH', -- OH-onHand
              `lastUpdated` datetime not NULL default CURRENT_TIMESTAMP(),
              PRIMARY KEY (`cuInvoiceDetailBinID`),
              INDEX `cuInvoiceDetailBin_IDX` (cuInvoiceDetailID,binId)
            ) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=latin1;

    END IF; 

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuInvoiceDetail' AND column_name = 'onOrder'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

      ALTER TABLE  cuInvoiceDetail  ADD  onOrder decimal(19,4) DEFAULT 0;

    END IF;


    -- Table to hold reversals.
    set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'glTransactionReversal' AND column_name = 'glTransactionId'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

        CREATE TABLE `glTransactionReversal` (
           glTransactionId INT(11) NOT NULL,
           glTransactionReversedId INT(11) NULL,
           transactionDesc varchar(255) NULL,
           transactionDate datetime NOT NULL Default now(),
           enteredBy INT(11)  NULL,
            PRIMARY KEY (`glTransactionID`)
          )
        ENGINE = InnoDB;

    END IF;


update tp_version set tableVersion=_version,tableVersionDesc=_versionDesc where versionId >0;
END$$

DELIMITER ;

-- ===========================================

DROP procedure IF EXISTS `ETL`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL` ()
BEGIN

call ETL_TURBOREP_DEFAULT(1);

call ETL_TURBOREP_121();

call ETL_TURBOREP_121Delta(1);

call ETL_TURBOREP_gl(1);

call ETL_upgradeTableData();

call ETL_upgradeDatabase(8,'add glTransactionReversal', 'TP_struct');

call INV_createBinsFromWarehouseInventory('INIT',null,null); 

call INV_createCuSODetailBins('INIT');

call INV_createTransferBins('UPDATEDATE');

call INV_createTransferBins('INIT');

END$$

DELIMITER ;

-- =========================================


DROP procedure IF EXISTS `ETL_upgradeTableData`;

DELIMITER $$

CREATE PROCEDURE `ETL_upgradeTableData` ()
BEGIN

SET FOREIGN_KEY_CHECKS = 0;

truncate versionMaintainance;
INSERT INTO `versionMaintainance` VALUES (1,'4.0.0','3.0');

truncate tsUserLogin;
INSERT INTO `tsUserLogin` VALUES (1,'Admin','D3m0','Administrator','Admin',1,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,150,1000,1000,1000,1000,1,1,500,1000,50,NULL,NULL,NULL,NULL,1,1),(723,'MichaelB','î‚†rò*','Brownstein, Michael A.','MAB',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(724,'DorothyC','î‚†rò*','Cade, Dorothy E.','DEC',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(725,'SoniaG',']Q\r’‘','Cunningham, Sonia','SC',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(726,'SteveF','ætj×Ú5','Fulton, Stephen B.','SBF',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(727,'AliceaH','î‚†rò*','Hannin, Alice A.','AAH',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(728,'MarybethK','!Ô!','Kinsley, Marybeth','MK',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(729,'AbeK','~XW£','Kooby, Abraham','AK',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(730,'ChuckL','ú½9…','Lafferty, C. J.','CJL',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(731,'Steven','î‚†rò*','Madden, Steven','SM',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(732,'SteveP','~Ž“','Peal, Steven D','SDP',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(733,'NickP','î‚†rò*','Pergamalis, Jr., Nick','NP',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(734,'YvonneP','î‚†rò*','Phillips, Yvonne K.','YKP',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(735,'ChrisR','«Fô\r','Russo, Christopher J','CJR',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(736,'NikkiR','óI{ý','Russo, Nikki P.','NPR',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(737,'RichardR','´ŸË\"','Russo, Richard R.','RRR',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(738,'JohnS','î‚†rò*','Sagers, John M.','JMS',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(739,'IgnacioS','î‚†rò*','Sanchez, Ignacio','IS',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(740,'SuzanneS','œÍSú','Sojack, Suzanne','SS',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(741,'MarkV','	kò|Ž–','Vigarino, Mark A.','MAV',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(742,'BobZ','î‚†rò*','Zumstein, Robert K.','RKZ',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(743,'TQ',NULL,'TQ','TQ',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(744,' ',NULL,' ','ALL',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(745,'HVAC',' F¦','HVAC Associates, Inc','HVAC',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(746,'AmandaZ','Q‰©î','Zumstein, Amanda','AZ',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(747,'KeriR','î‚†rò*','Rodriguez, Keri','KR',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(748,'DanH','î‚†rò*','Howe, Daniel J.','DH',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(750,'MikeG','¯®a','Gallagher, Mike','MAG',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(751,'ALINAB','<¤éŸ','BECK, ALINA','AB',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(752,'RoyG','î‚†rò*','Griffin, Wayne R.','WRG',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(753,'GORDONC','7Œ','Cade, Gordon L.','GLC',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(754,'WILLIAMH','î‚†rò*','Hagerty, William D.','WDH',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(755,'CORRIER','T,êÄ','Russo, Cora Lee','CLR',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(756,'JOHNC','î‚†rò*','Childs, John E','JEC',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(757,'WRWGOLF','öÈÒÈ•D','WALLS, BILL','WRW',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(758,'GregB','¢ãÃF','Bachmann, Greg','GB',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(759,'efax',NULL,'efax',NULL,0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(760,'JOSHUAR','ætj×Ú5','Roccanti, Joshua M.','JMR',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(761,'JASONA','\rÇÐ£','Ayala, Jason ','JA',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(762,'McK','ætj×Ú5','Kinsley, Mckenna','McK',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(763,'BILLYM','ÆÌmy','MILLER, WILLIAM J','WJM',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(764,'JENN','MÌ¼U','Russo, Jennifer','JNR',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0),(765,'seane','Ö…Õ','Edwards, Sean W','SWE',0,0,0,0,0,0,0,0,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0);

truncate tsUserGroupLink;
INSERT INTO `tsUserGroupLink` VALUES (3,7,1),(4,133,2),(5,170,5),(6,179,2),(7,8,1),(9,181,6),(11,181,6),(13,147,6),(14,158,1),(15,10,1),(16,160,6),(17,12,1),(18,12,4),(19,12,6),(20,145,1),(21,136,2),(22,180,3),(23,56,1),(24,44,7),(25,132,1),(26,148,6),(28,126,6),(29,142,5),(30,165,1),(31,117,6),(32,117,1),(33,117,6),(34,15,1),(35,173,1),(36,55,7),(37,164,6),(38,164,1),(39,71,1),(41,157,1),(42,41,1),(43,41,4),(44,41,4),(45,174,2),(46,39,1),(47,37,1),(48,169,2),(49,36,3),(50,36,4),(51,183,2),(53,155,1),(54,176,1),(56,35,1),(57,121,1),(58,143,1),(59,86,2),(60,33,4),(61,33,2),(62,110,5),(63,31,1),(64,53,1),(65,149,1),(67,107,1),(68,58,1),(69,29,1),(70,130,6),(71,128,5),(72,113,2),(75,59,1),(76,153,1),(77,140,6),(78,163,2),(79,182,3),(80,167,7),(81,19,1),(82,132,6),(83,41,3),(84,41,5),(85,41,6),(86,41,7),(87,10,6),(88,125,2),(89,127,3),(91,127,5),(92,182,5),(93,182,7),(94,125,7),(113,49,5),(114,49,5),(117,186,4),(118,186,3),(119,185,2),(120,184,7),(121,187,1),(122,118,3),(123,137,6),(124,191,7),(125,22,3),(126,62,2),(127,192,2),(129,194,6),(130,195,5),(131,196,1),(132,196,2),(133,198,1),(134,198,6),(135,200,1),(136,201,6),(137,202,2),(138,202,6),(139,203,5),(140,204,3),(141,205,1),(142,206,6),(143,207,6),(144,208,4),(145,196,7),(146,210,6),(147,210,1),(148,211,1),(150,212,6),(151,213,7),(152,214,7),(153,140,1),(154,215,3),(155,216,2),(156,217,1),(157,217,4),(158,217,7),(159,218,2),(160,219,1),(161,220,5),(162,221,3),(163,222,6),(164,223,7),(165,224,7),(166,225,7),(167,212,1),(168,206,1),(169,226,2),(170,227,2),(171,126,1),(172,228,3),(173,33,6),(174,33,7),(175,230,5),(177,225,6),(178,231,5),(179,232,5),(180,232,3),(181,233,2),(182,234,1),(183,235,3),(184,238,7),(185,234,6),(186,239,2),(187,240,6),(188,241,7),(189,242,7),(190,243,5),(191,244,7),(192,245,7),(193,33,3),(194,33,1),(195,246,5),(196,247,6),(197,248,3),(198,249,4),(199,250,5);

truncate tsUserGroup;
INSERT INTO `tsUserGroup` VALUES (1,'Salesman'),(2,'A/E'),(3,'Accounting'),(4,'Admins'),(5,'Credit'),(6,'Estimating'),(7,'Whse'),(8,'');

truncate sysVariable ;
INSERT INTO `sysVariable` VALUES (1,0,0.0000,NULL,NULL,NULL),(2,0,0.0000,NULL,NULL,NULL),(3,0,0.0000,NULL,NULL,NULL),(4,-1,0.0000,NULL,NULL,NULL),(5,-1,0.0000,NULL,NULL,NULL),(6,-1,0.0000,NULL,NULL,NULL),(23,150,0.0000,NULL,NULL,NULL),(24,0,0.0000,NULL,NULL,NULL),(25,1,0.0000,NULL,NULL,NULL),(26,1,0.0000,NULL,NULL,NULL),(27,1,0.0000,NULL,NULL,NULL),(28,0,0.0000,NULL,'2014-10-31 00:00:00',NULL),(29,0,0.0000,NULL,NULL,'This invoice has been issued under a joint check agreement.'),(30,0,0.0000,NULL,NULL,NULL),(31,0,0.0000,NULL,NULL,NULL),(32,-1,0.0000,NULL,NULL,NULL),(33,0,0.0000,'0',NULL,NULL),(34,0,0.0000,NULL,NULL,NULL),(35,-1,0.0000,NULL,NULL,NULL),(36,0,0.0000,'\\\\vdc01\\documents\\TurboDocMan\\',NULL,NULL),(37,0,0.0000,'\\\\vdc01\\documents\\TurboDocMan\\',NULL,NULL),(38,0,0.0000,'',NULL,NULL),(39,0,0.0000,'',NULL,NULL),(40,0,0.0000,'\\\\vdc01\\documents\\TurboDocMan\\',NULL,NULL),(41,0,0.0000,NULL,NULL,''),(42,0,0.0000,NULL,NULL,''),(8014,1,0.0000,NULL,NULL,NULL),(1000000,0,0.0000,NULL,NULL,NULL),(1000007,3,0.0000,NULL,NULL,NULL),(1000100,0,0.0000,'C:\\Program Files\\A & E Specialties\\TurboRep\\PDF',NULL,NULL),(1000101,0,0.0000,'Bartos Industries, LTD.',NULL,NULL),(1000103,0,0.0000,'10350 Olympic Drive',NULL,NULL),(1000105,0,0.0000,'Dallas, TX  75220',NULL,NULL),(1000106,0,0.0000,'75-2799456',NULL,NULL),(1000117,1,0.0000,NULL,NULL,NULL),(1010000,0,0.0000,NULL,NULL,NULL),(1010001,0,0.0000,NULL,NULL,NULL),(1010004,0,0.0000,NULL,NULL,NULL),(1010005,1,0.0000,NULL,NULL,NULL),(1020000,0,1.1000,NULL,NULL,NULL),(1020001,1,0.0000,NULL,NULL,NULL),(1030000,1,0.0000,NULL,NULL,NULL),(1030002,1,0.0000,NULL,NULL,NULL),(1030006,1,0.0000,NULL,NULL,NULL),(1030007,1,0.0000,NULL,NULL,NULL),(1030008,1,0.0000,NULL,NULL,NULL),(1030009,1,0.0000,NULL,NULL,NULL),(1030014,1,0.0000,NULL,NULL,NULL),(1030100,0,0.0000,'TEST',NULL,NULL),(1040001,0,0.0000,NULL,NULL,NULL),(1040002,0,0.0000,NULL,NULL,NULL),(1040003,0,0.0000,'',NULL,NULL),(1040004,0,0.0000,'',NULL,NULL),(1040005,0,0.0000,'',NULL,NULL),(1040006,0,0.0000,'',NULL,NULL),(1040007,0,0.0000,'',NULL,NULL),(1040008,0,0.0000,'Job Commissions',NULL,NULL),(1040009,0,0.0000,'Warehouse Commissions',NULL,NULL),(1040010,0,0.0000,'Override Commiss',NULL,NULL),(1050000,0,0.0000,NULL,NULL,NULL),(1050001,0,0.0000,NULL,NULL,NULL),(1050002,1,0.0000,NULL,NULL,NULL),(1050003,1,0.0000,NULL,NULL,NULL),(1050004,1,0.0000,NULL,NULL,NULL),(1050005,0,0.0000,NULL,NULL,NULL),(1060001,0,0.0000,'',NULL,NULL),(1060002,0,0.0000,'',NULL,NULL),(1060003,0,0.0000,'1st Notice?',NULL,NULL),(1060004,1,0.0000,NULL,NULL,NULL),(1060005,0,0.0000,'Final Notice?',NULL,NULL),(1060006,1,0.0000,NULL,NULL,NULL),(1060007,0,0.0000,'Proj Data Sheet',NULL,NULL),(1060008,1,0.0000,NULL,NULL,NULL),(1060009,1,0.0000,NULL,NULL,NULL),(1060011,1,0.0000,NULL,NULL,NULL),(1060014,1,0.0000,NULL,NULL,NULL),(1060020,1,0.0000,NULL,NULL,NULL),(1060023,1,0.0000,NULL,NULL,NULL),(1060030,0,0.0000,NULL,NULL,NULL),(1070000,0,0.0000,'secure.emailsrvr.com',NULL,NULL),(1070001,1,0.0000,NULL,NULL,NULL),(1070002,1,0.0000,NULL,NULL,NULL),(1070003,1,0.0000,NULL,NULL,NULL),(1002000014,0,0.0000,NULL,NULL,'â€œÂ²\0\0Ã¼!\0\0\0\0%Y0Â£$\0\0\0v\0e\0r\0s\0i\0o\0n\0\0\0\02\0.\00\0\0\r\0Ã²â€¢Ã¹Â¯(\0\0\0a\0u\0t\0o\0m\0a\0t\0i\0c\0s\0o\0r\0t\0Ã¿Ã¿\0\0ql?,\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0(\0\0\0s\0h\0o\0w\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0<Sâ€¢Ãˆ0\0\0\0b\0o\0u\0n\0d\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0Â¢Ã»0X4\0\0\0r\0e\0p\0l\0a\0c\0e\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0et%Â¬8\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0c\0o\0l\0u\0m\0n\0\0\0\0\0\0\0\0\r\00(Â²,\0\0\0h\0i\0d\0e\0s\0e\0l\0e\0c\0t\0i\0o\0n\0\0\0\0\0\0\0\0Ã¦ÃžÃ¶Â,\0\0\0u\0s\0e\0e\0v\0e\0n\0o\0d\0d\0c\0o\0l\0o\0r\0Ã¿Ã¿\0\0YÃ\nâ€œÃ¦,\0\0\0a\0l\0l\0o\0w\0c\0a\0r\0d\0s\0i\0z\0i\0n\0g\0\0\0\0\r\0&	â‚¬Ã®,\0\0\0r\0e\0c\0o\0r\0d\0s\0e\0t\0t\0y\0p\0e\0\0\0\0\0\0\0\0â€¢4Â¼RD\0\0r\0e\0c\0o\0r\0d\0s\0o\0u\0r\0c\0e\0\0\0S\0E\0L\0E\0C\0T\0 \0Q\0.\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0,\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0,\0 \0R\0X\0.\0N\0a\0m\0e\0,\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0A\0S\0 \0Q\0u\0o\0t\0e\0N\0o\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0,\0 \0J\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0 \0A\0S\0 \0P\0r\0o\0j\0e\0c\0t\0,\0 \0Q\0.\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0,\0 \0J\0.\0B\0i\0d\0D\0a\0t\0e\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0,\0 \0T\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0 \0A\0S\0 \0Q\0u\0o\0t\0e\0T\0y\0p\0e\0 \0 \0F\0R\0O\0M\0 \0j\0o\0M\0a\0s\0t\0e\0r\0 \0J\0 \0L\0E\0F\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0r\0x\0M\0a\0s\0t\0e\0r\0 \0R\0X\0 \0O\0N\0 \0J\0.\0r\0x\0C\0u\0s\0t\0o\0m\0e\0r\0I\0D\0 \0=\0 \0R\0X\0.\0r\0x\0M\0a\0s\0t\0e\0r\0I\0D\0 \0R\0I\0G\0H\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0 \0Q\0 \0O\0N\0 \0J\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0=\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0L\0E\0F\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0 \0T\0 \0O\0N\0 \0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0 \0=\0 \0T\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0 \0 \0W\0H\0E\0R\0E\0 \0(\0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0+\0 \0\'\0-\0\'\0 \0+\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0 \0+\0 \0\'\0*\0\'\0 \0+\0 \0S\0T\0R\0(\0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0 \0I\0N\0 \0(\0S\0E\0L\0E\0C\0T\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0+\0 \0\'\0-\0\'\0 \0+\0 \0M\0A\0X\0(\0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0)\0 \0+\0 \0\'\0*\0\'\0 \0+\0 \0S\0T\0R\0(\0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0 \0A\0S\0 \0S\0e\0a\0r\0c\0h\0K\0e\0y\0 \0F\0R\0O\0M\0 \0j\0o\0M\0a\0s\0t\0e\0r\0 \0J\0 \0R\0I\0G\0H\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0 \0Q\0 \0O\0N\0 \0J\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0=\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0W\0h\0e\0r\0e\0 \0(\0j\0.\0J\0o\0b\0S\0t\0a\0t\0u\0s\0 \0=\0 \01\0)\0 \0A\0n\0d\0 \0(\0Q\0.\0C\0r\0e\0a\0t\0e\0d\0B\0y\0I\0D\0 \0=\0 \01\04\0)\0 \0G\0R\0O\0U\0P\0 \0B\0Y\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0,\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0,\0 \0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0)\0 \0O\0R\0D\0E\0R\0 \0B\0Y\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0,\0 \0T\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0Â·Ã·Å“,\0\0d\0a\0t\0a\0b\0a\0s\0e\0n\0a\0m\0e\0\0\0P\0r\0o\0v\0i\0d\0e\0r\0=\0S\0Q\0L\0O\0L\0E\0D\0B\0.\01\0;\0I\0n\0t\0e\0g\0r\0a\0t\0e\0d\0 \0S\0e\0c\0u\0r\0i\0t\0y\0=\0S\0S\0P\0I\0;\0I\0n\0i\0t\0i\0a\0l\0 \0C\0a\0t\0a\0l\0o\0g\0=\0B\0a\0r\0t\0o\0s\0_\0C\0o\0m\0p\0a\0n\0y\0;\0D\0a\0t\0a\0 \0S\0o\0u\0r\0c\0e\0=\0V\0S\0Q\0L\00\01\0;\0U\0s\0e\0 \0P\0r\0o\0c\0e\0d\0u\0r\0e\0 \0f\0o\0r\0 \0P\0r\0e\0p\0a\0r\0e\0=\01\0;\0A\0u\0t\0o\0 \0T\0r\0a\0n\0s\0l\0a\0t\0e\0=\0T\0r\0u\0e\0;\0P\0a\0c\0k\0e\0t\0 \0S\0i\0z\0e\0=\04\00\09\06\0;\0W\0o\0r\0k\0s\0t\0a\0t\0i\0o\0n\0 \0I\0D\0=\0V\0B\0A\0R\0T\0S\01\0;\0U\0s\0e\0 \0E\0n\0c\0r\0y\0p\0t\0i\0o\0n\0 \0f\0o\0r\0 \0D\0a\0t\0a\0=\0F\0a\0l\0s\0e\0;\0T\0a\0g\0 \0w\0i\0t\0h\0 \0c\0o\0l\0u\0m\0n\0 \0c\0o\0l\0l\0a\0t\0i\0o\0n\0 \0w\0h\0e\0n\0 \0p\0o\0s\0s\0i\0b\0l\0e\0=\0F\0a\0l\0s\0e\0\0	\0(sfÃ· \0\0\0a\0l\0l\0o\0w\0e\0d\0i\0t\0\0\0\0\0FÂ³Ã¶X0\0\0\0g\0r\0o\0u\0p\0b\0y\0b\0o\0x\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Âª?Ã‹0\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0h\0e\0a\0d\0e\0r\0Ã¿Â Â \0\0\0\0\0Ã¶Å¡ \0\0\0d\0a\0t\0a\0m\0o\0d\0e\0\0\0\0\0\09Ã³Â·Å¡(\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0b\0k\0g\0Ã¿Ã€Ã€\0\0\0Ã˜z#4\0\0\0c\0o\0l\0u\0m\0n\0h\0e\0a\0d\0e\0r\0h\0e\0i\0g\0h\0t\0\0â‚¬Å½C\0\0Ã›Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\01\0\0\0\0\0\0\0Ã˜Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\02\0\0\0\0\0\0\0ÃÂ¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\07\0\0\0\0\0\0\0Â¬Æ’â€”Â·(\0\0\0c\0o\0l\0u\0m\0n\0s\0c\0o\0u\0n\0t\0\n\0\0\0 	\0Ã€tÃÃžÃ€\0\0c\0o\0l\0u\0m\0n\0(\01\0)\0\0Ëœ\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0Â­\ZÂ£<\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡@\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬4\0\0\0k\0e\0y\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Å’Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\02\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€4ÃÃž(\0\0c\0o\0l\0u\0m\0n\0(\03\0)\0\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0u\0s\0t\0o\0m\0e\0r\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡,\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0N\0a\0m\0e\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬ \0\0\0k\0e\0y\0\0\0\0N\0a\0m\0e\0\0\0\0\0Ã©Â´~â€”$Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€Ã”ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\04\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0Q\0u\0o\0t\0e\0 \0#\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0N\0o\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0N\0o\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0C\0\0\0\0\0 	\0Ã€Ã´ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\05\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£$\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0R\0e\0v\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0!\0\0\0\0\0 	\0Ã€â€ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\06\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€Â´ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\07\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0r\0e\0a\0t\0e\0d\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€TÃŒÃžËœ\0\0c\0o\0l\0u\0m\0n\0(\08\0)\0\0p\0\0\0\0\0\0â€œÂ²\0\0p\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0B\0i\0d\0/\0D\0u\0e\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0B\0i\0d\0D\0a\0t\0e\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0B\0i\0d\0D\0a\0t\0e\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â´Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€tÃŒÃžÂ´\0\0c\0o\0l\0u\0m\0n\0(\09\0)\0\0Å’\0\0\0\0\0\0â€œÂ²\0\0Å’\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0A\0m\0o\0u\0n\0t\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0	\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0\0\0Â¹Ã¼Â²0\0\0\0f\0o\0r\0m\0a\0t\0	\0\0\0#\0#\0,\0#\0#\00\0.\00\00\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0	\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\0Ã©Â´~â€”ËœÃ¾Ã¿Ã¿w\0i\0d\0t\0h\0<\0\0\0\0\0 \n\0Ã°;â€ºÂ®@\0\0c\0o\0l\0u\0m\0n\0(\01\00\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\n\0\0\0Q\0u\0o\0t\0e\0 \0T\0y\0p\0e\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\n\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0	\0\0\0Q\0u\0o\0t\0e\0T\0y\0p\0e\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\n\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0	\0\0\0Q\0u\0o\0t\0e\0T\0y\0p\0e\0\0\0Ã©Â´~â€”Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0K\0\0\0\0\0\0\0\0\0Â¢xÂ°4\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0s\0c\0o\0u\0n\0t\0\0\0\0\0\0 \0ÃªÂ«Ã‚Ã‚L\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\01\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0D\0e\0f\0a\0u\0l\0t\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã€Ã€\0\0\0\0\0;Â¹Tâ€œ$\0\0\0f\0o\0n\0t\0s\0i\0z\0e\0DB\0\0\0\0\0\0\0Â»WVÂ³<\0\0\0f\0o\0n\0t\0n\0a\0m\0e\0\r\0\0\0M\0S\0 \0S\0a\0n\0s\0 \0S\0e\0r\0i\0f\0\0\0\0\0rÃ–lâ€šÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0Ã¿\0\0\0\0\0\0 \0ÃªÃ‹Ã‚Ã‚Ã„\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\02\0)\0\0Â\0\0\0\0\0\0\0â€œÂ²\0\0Â\0\0\0\0\0dâ€”\râ€ž$\0\0\0n\0a\0m\0e\0\0\0\0O\0d\0d\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã Ã \0\0\0\0\0rÃ–lâ€šâ€Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ«Ã‚Ã‚Ãˆ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\03\0)\0\0â€\0\0\0\0\0\0\0â€œÂ²\0\0â€\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0E\0v\0e\0n\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã°Ã°\0\0\0\0\0rÃ–lâ€šÂÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ‚Ã‚Ã¬\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\04\0)\0\0Â¸\0\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0R\0o\0w\0G\0r\0o\0u\0p\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿ÃÃ\0\0\0\0\0rÃ–lâ€šlÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0Ãª+Ã‚Ã‚ÃŒ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\05\0)\0\0Ëœ\0\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0\0dâ€”\râ€ž,\0\0\0n\0a\0m\0e\0\n\0\0\0P\0r\0e\0v\0i\0e\0w\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0Ã¿\0\0\0\0\0rÃ–lâ€šÅ’Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªKÃ‚Ã‚Ã´\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\06\0)\0\0Ã€\0\0\0\0\0\0\0â€œÂ²\0\0Ã€\0\0\0\0\0dâ€”\râ€ž0\0\0\0n\0a\0m\0e\0\0\0\0S\0e\0l\0e\0c\0t\0e\0d\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0\r\0\0â‚¬\0\0\0\0rÃ–lâ€šdÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0\0\n\0<ZÃ—$\0\0\0i\0m\0a\0g\0e\0c\0o\0u\0n\0t\0\0\0\0\0 \0Ã¤Â¶2ÂÃ¼ÃŸÃ¿Ã¿p\0r\0i\0n\0t\0e\0r\0p\0r\0o\0p\0e\0r\0t\0i\0e\0s\0\0Â¸\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0	\0\0.Ã·Â®P\0\0\0p\0a\0g\0e\0h\0e\0a\0d\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif	\0\0.Ã½ÃƒÃŸP\0\0\0p\0a\0g\0e\0f\0o\0o\0t\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif\0\082Fâ€ž$\0\0\0o\0r\0i\0e\0n\0t\0a\0t\0i\0o\0n\0\0\0\0Å’YE \0\0\0p\0a\0p\0e\0r\0b\0i\0n\0\0\0\0\0	\0-	3Â« \0\0\0p\0a\0p\0e\0r\0s\0i\0z\0e\0\0\0\0\0Yâ„¢\Z(\0\0\0p\0r\0i\0n\0t\0q\0u\0a\0l\0i\0t\0y\0Ã½Ã¿\0\0\0\0}!Câ€¡0\0\0\0r\0e\0p\0e\0a\0t\0f\0r\0o\0z\0e\0n\0c\0o\0l\0s\0\0\0\0\0\0\r\0|â€™â€“(\0\0\0r\0e\0p\0e\0a\0t\0h\0e\0a\0d\0e\0r\0s\0Ã¿Ã¿\0\0}Â²P\Z|Ã¾Ã¿Ã¿t\0r\0a\0n\0s\0l\0a\0t\0e\0c\0o\0l\0o\0r\0s\0\0\0'),(1002000037,0,0.0000,NULL,NULL,'â€œÂ²\0\0Â \"\0\0\0\0%Y0Â£$\0\0\0v\0e\0r\0s\0i\0o\0n\0\0\0\02\0.\00\0\0\r\0Ã²â€¢Ã¹Â¯(\0\0\0a\0u\0t\0o\0m\0a\0t\0i\0c\0s\0o\0r\0t\0Ã¿Ã¿\0\0ql?,\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0(\0\0\0s\0h\0o\0w\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0<Sâ€¢Ãˆ0\0\0\0b\0o\0u\0n\0d\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0Â¢Ã»0X4\0\0\0r\0e\0p\0l\0a\0c\0e\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0et%Â¬8\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0c\0o\0l\0u\0m\0n\0\0\0\0\0\0\0\0\r\00(Â²,\0\0\0h\0i\0d\0e\0s\0e\0l\0e\0c\0t\0i\0o\0n\0\0\0\0\0\0\0\0Ã¦ÃžÃ¶Â,\0\0\0u\0s\0e\0e\0v\0e\0n\0o\0d\0d\0c\0o\0l\0o\0r\0Ã¿Ã¿\0\0YÃ\nâ€œÃ¦,\0\0\0a\0l\0l\0o\0w\0c\0a\0r\0d\0s\0i\0z\0i\0n\0g\0\0\0\0\r\0&	â‚¬Ã®,\0\0\0r\0e\0c\0o\0r\0d\0s\0e\0t\0t\0y\0p\0e\0\0\0\0\0\0\0\0â€¢4Â¼R(\0\0r\0e\0c\0o\0r\0d\0s\0o\0u\0r\0c\0e\0Ã¿\0\0S\0E\0L\0E\0C\0T\0 \0Q\0.\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0,\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0,\0 \0R\0X\0.\0N\0a\0m\0e\0,\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0A\0S\0 \0Q\0u\0o\0t\0e\0N\0o\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0,\0 \0J\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0 \0A\0S\0 \0P\0r\0o\0j\0e\0c\0t\0,\0 \0Q\0.\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0,\0 \0J\0.\0B\0i\0d\0D\0a\0t\0e\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0,\0 \0T\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0 \0A\0S\0 \0Q\0u\0o\0t\0e\0T\0y\0p\0e\0 \0 \0F\0R\0O\0M\0 \0j\0o\0M\0a\0s\0t\0e\0r\0 \0J\0 \0L\0E\0F\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0r\0x\0M\0a\0s\0t\0e\0r\0 \0R\0X\0 \0O\0N\0 \0J\0.\0r\0x\0C\0u\0s\0t\0o\0m\0e\0r\0I\0D\0 \0=\0 \0R\0X\0.\0r\0x\0M\0a\0s\0t\0e\0r\0I\0D\0 \0R\0I\0G\0H\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0 \0Q\0 \0O\0N\0 \0J\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0=\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0L\0E\0F\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0 \0T\0 \0O\0N\0 \0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0 \0=\0 \0T\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0 \0 \0W\0H\0E\0R\0E\0 \0(\0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0+\0 \0\'\0-\0\'\0 \0+\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0 \0+\0 \0\'\0*\0\'\0 \0+\0 \0S\0T\0R\0(\0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0 \0I\0N\0 \0(\0S\0E\0L\0E\0C\0T\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0+\0 \0\'\0-\0\'\0 \0+\0 \0M\0A\0X\0(\0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0)\0 \0+\0 \0\'\0*\0\'\0 \0+\0 \0S\0T\0R\0(\0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0 \0A\0S\0 \0S\0e\0a\0r\0c\0h\0K\0e\0y\0 \0F\0R\0O\0M\0 \0j\0o\0M\0a\0s\0t\0e\0r\0 \0J\0 \0R\0I\0G\0H\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0 \0Q\0 \0O\0N\0 \0J\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0=\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0W\0h\0e\0r\0e\0 \0(\0j\0.\0J\0o\0b\0S\0t\0a\0t\0u\0s\0 \0=\0 \01\0)\0 \0A\0n\0d\0 \0(\01\0=\01\0)\0 \0G\0R\0O\0U\0P\0 \0B\0Y\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0,\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0,\0 \0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0)\0 \0O\0R\0D\0E\0R\0 \0B\0Y\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0,\0 \0T\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0\0\0Â·Ã·Å“L\0\0d\0a\0t\0a\0b\0a\0s\0e\0n\0a\0m\0e\0\0\0P\0r\0o\0v\0i\0d\0e\0r\0=\0S\0Q\0L\0O\0L\0E\0D\0B\0.\01\0;\0P\0a\0s\0s\0w\0o\0r\0d\0=\04\0b\0@\0r\0t\00\0s\02\0@\0d\0m\0i\0n\0;\0U\0s\0e\0r\0 \0I\0D\0=\0s\0a\0;\0I\0n\0i\0t\0i\0a\0l\0 \0C\0a\0t\0a\0l\0o\0g\0=\0B\0a\0r\0t\0o\0s\0_\0C\0o\0m\0p\0a\0n\0y\0;\0D\0a\0t\0a\0 \0S\0o\0u\0r\0c\0e\0=\0b\0a\0r\0d\0l\0t\0r\0m\00\01\0;\0U\0s\0e\0 \0P\0r\0o\0c\0e\0d\0u\0r\0e\0 \0f\0o\0r\0 \0P\0r\0e\0p\0a\0r\0e\0=\01\0;\0A\0u\0t\0o\0 \0T\0r\0a\0n\0s\0l\0a\0t\0e\0=\0T\0r\0u\0e\0;\0P\0a\0c\0k\0e\0t\0 \0S\0i\0z\0e\0=\04\00\09\06\0;\0W\0o\0r\0k\0s\0t\0a\0t\0i\0o\0n\0 \0I\0D\0=\0B\0A\0R\0D\0L\0T\0R\0M\00\01\0;\0U\0s\0e\0 \0E\0n\0c\0r\0y\0p\0t\0i\0o\0n\0 \0f\0o\0r\0 \0D\0a\0t\0a\0=\0F\0a\0l\0s\0e\0;\0T\0a\0g\0 \0w\0i\0t\0h\0 \0c\0o\0l\0u\0m\0n\0 \0c\0o\0l\0l\0a\0t\0i\0o\0n\0 \0w\0h\0e\0n\0 \0p\0o\0s\0s\0i\0b\0l\0e\0=\0F\0a\0l\0s\0e\0\0	\0(sfÃ· \0\0\0a\0l\0l\0o\0w\0e\0d\0i\0t\0\0\0\0\0FÂ³Ã¶X0\0\0\0g\0r\0o\0u\0p\0b\0y\0b\0o\0x\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Âª?Ã‹0\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0h\0e\0a\0d\0e\0r\0Ã¿Â Â \0\0\0\0\0Ã¶Å¡ \0\0\0d\0a\0t\0a\0m\0o\0d\0e\0\0\0\0\0\09Ã³Â·Å¡(\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0b\0k\0g\0Ã¿Ã€Ã€\0\0\0Ã˜z#4\0\0\0c\0o\0l\0u\0m\0n\0h\0e\0a\0d\0e\0r\0h\0e\0i\0g\0h\0t\0\0â‚¬Å½C\0\0Ã›Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\01\0\0\0\0\0\0\0Ã˜Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\02\0\0\0\0\0\0\0ÃÂ¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\07\0\0\0\0\0\0\0Â¬Æ’â€”Â·(\0\0\0c\0o\0l\0u\0m\0n\0s\0c\0o\0u\0n\0t\0\n\0\0\0 	\0Ã€tÃÃžÃ€\0\0c\0o\0l\0u\0m\0n\0(\01\0)\0\0Ëœ\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0Â­\ZÂ£<\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡@\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬4\0\0\0k\0e\0y\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Å’Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\02\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€4ÃÃž(\0\0c\0o\0l\0u\0m\0n\0(\03\0)\0\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0u\0s\0t\0o\0m\0e\0r\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡,\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0N\0a\0m\0e\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬ \0\0\0k\0e\0y\0\0\0\0N\0a\0m\0e\0\0\0\0\0Ã©Â´~â€”$Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€Ã”ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\04\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0Q\0u\0o\0t\0e\0 \0#\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0N\0o\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0N\0o\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0C\0\0\0\0\0 	\0Ã€Ã´ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\05\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£$\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0R\0e\0v\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0!\0\0\0\0\0 	\0Ã€â€ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\06\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€Â´ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\07\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0r\0e\0a\0t\0e\0d\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€TÃŒÃžËœ\0\0c\0o\0l\0u\0m\0n\0(\08\0)\0\0p\0\0\0\0\0\0â€œÂ²\0\0p\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0B\0i\0d\0/\0D\0u\0e\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0B\0i\0d\0D\0a\0t\0e\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0B\0i\0d\0D\0a\0t\0e\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â´Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€tÃŒÃžÂ´\0\0c\0o\0l\0u\0m\0n\0(\09\0)\0\0Å’\0\0\0\0\0\0â€œÂ²\0\0Å’\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0A\0m\0o\0u\0n\0t\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0	\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0\0\0Â¹Ã¼Â²0\0\0\0f\0o\0r\0m\0a\0t\0	\0\0\0#\0#\0,\0#\0#\00\0.\00\00\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0	\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\0Ã©Â´~â€”ËœÃ¾Ã¿Ã¿w\0i\0d\0t\0h\0<\0\0\0\0\0 \n\0Ã°;â€ºÂ®@\0\0c\0o\0l\0u\0m\0n\0(\01\00\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\n\0\0\0Q\0u\0o\0t\0e\0 \0T\0y\0p\0e\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\n\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0	\0\0\0Q\0u\0o\0t\0e\0T\0y\0p\0e\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\n\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0	\0\0\0Q\0u\0o\0t\0e\0T\0y\0p\0e\0\0\0Ã©Â´~â€”Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0K\0\0\0\0\0\0\0\0\r\0ÃŸ]â€Ã„,\0\0\0s\0o\0r\0t\0k\0e\0y\0s\0c\0o\0u\0n\0t\0\0\0\0\0\0 \n\0|s+8t\0\0\0s\0o\0r\0t\0k\0e\0y\0(\01\0)\0\0H\0\0\0\0\0\0\0â€œÂ²\0\0H\0\0\0\0\0Â¢Wâ€¡Å½ \0\0\0c\0o\0l\0i\0n\0d\0e\0x\0\0\0\0\0	\0ËœjÃ Ã®Ã Ã¿Ã¿Ã¿s\0o\0r\0t\0o\0r\0d\0e\0r\0\0\0\0\0\0Â¢xÂ°4\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0s\0c\0o\0u\0n\0t\0\0\0\0\0\0 \0ÃªÂ«Ã‚Ã‚L\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\01\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0D\0e\0f\0a\0u\0l\0t\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã€Ã€\0\0\0\0\0;Â¹Tâ€œ$\0\0\0f\0o\0n\0t\0s\0i\0z\0e\0DB\0\0\0\0\0\0\0Â»WVÂ³<\0\0\0f\0o\0n\0t\0n\0a\0m\0e\0\r\0\0\0M\0S\0 \0S\0a\0n\0s\0 \0S\0e\0r\0i\0f\0\0\0\0\0rÃ–lâ€šÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0Ã¿\0\0\0\0\0\0 \0ÃªÃ‹Ã‚Ã‚Ã„\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\02\0)\0\0Â\0\0\0\0\0\0\0â€œÂ²\0\0Â\0\0\0\0\0dâ€”\râ€ž$\0\0\0n\0a\0m\0e\0\0\0\0O\0d\0d\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã Ã \0\0\0\0\0rÃ–lâ€šâ€Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ«Ã‚Ã‚Ãˆ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\03\0)\0\0â€\0\0\0\0\0\0\0â€œÂ²\0\0â€\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0E\0v\0e\0n\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã°Ã°\0\0\0\0\0rÃ–lâ€šÂÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ‚Ã‚Ã¬\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\04\0)\0\0Â¸\0\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0R\0o\0w\0G\0r\0o\0u\0p\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿ÃÃ\0\0\0\0\0rÃ–lâ€šlÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0Ãª+Ã‚Ã‚ÃŒ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\05\0)\0\0Ëœ\0\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0\0dâ€”\râ€ž,\0\0\0n\0a\0m\0e\0\n\0\0\0P\0r\0e\0v\0i\0e\0w\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0Ã¿\0\0\0\0\0rÃ–lâ€šÅ’Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªKÃ‚Ã‚Ã´\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\06\0)\0\0Ã€\0\0\0\0\0\0\0â€œÂ²\0\0Ã€\0\0\0\0\0dâ€”\râ€ž0\0\0\0n\0a\0m\0e\0\0\0\0S\0e\0l\0e\0c\0t\0e\0d\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0\r\0\0â‚¬\0\0\0\0rÃ–lâ€šdÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0\0\n\0<ZÃ—$\0\0\0i\0m\0a\0g\0e\0c\0o\0u\0n\0t\0\0\0\0\0 \0Ã¤Â¶2ÂXÃŸÃ¿Ã¿p\0r\0i\0n\0t\0e\0r\0p\0r\0o\0p\0e\0r\0t\0i\0e\0s\0\0Â¸\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0	\0\0.Ã·Â®P\0\0\0p\0a\0g\0e\0h\0e\0a\0d\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif	\0\0.Ã½ÃƒÃŸP\0\0\0p\0a\0g\0e\0f\0o\0o\0t\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif\0\082Fâ€ž$\0\0\0o\0r\0i\0e\0n\0t\0a\0t\0i\0o\0n\0\0\0\0Å’YE \0\0\0p\0a\0p\0e\0r\0b\0i\0n\0\0\0\0\0	\0-	3Â« \0\0\0p\0a\0p\0e\0r\0s\0i\0z\0e\0\0\0\0\0Yâ„¢\Z(\0\0\0p\0r\0i\0n\0t\0q\0u\0a\0l\0i\0t\0y\0Ã½Ã¿\0\0\0\0}!Câ€¡0\0\0\0r\0e\0p\0e\0a\0t\0f\0r\0o\0z\0e\0n\0c\0o\0l\0s\0\0\0\0\0\0\r\0|â€™â€“(\0\0\0r\0e\0p\0e\0a\0t\0h\0e\0a\0d\0e\0r\0s\0Ã¿Ã¿\0\0}Â²P\Z|Ã¾Ã¿Ã¿t\0r\0a\0n\0s\0l\0a\0t\0e\0c\0o\0l\0o\0r\0s\0\0\0'),(1002000067,0,0.0000,NULL,NULL,'â€œÂ²\0\0â‚¬\"\0\0\0\0%Y0Â£$\0\0\0v\0e\0r\0s\0i\0o\0n\0\0\0\02\0.\00\0\0\r\0Ã²â€¢Ã¹Â¯(\0\0\0a\0u\0t\0o\0m\0a\0t\0i\0c\0s\0o\0r\0t\0Ã¿Ã¿\0\0ql?,\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0(\0\0\0s\0h\0o\0w\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0<Sâ€¢Ãˆ0\0\0\0b\0o\0u\0n\0d\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0Â¢Ã»0X4\0\0\0r\0e\0p\0l\0a\0c\0e\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0et%Â¬8\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0c\0o\0l\0u\0m\0n\0\0\0\0\0\0\0\0\r\00(Â²,\0\0\0h\0i\0d\0e\0s\0e\0l\0e\0c\0t\0i\0o\0n\0\0\0\0\0\0\0\0Ã¦ÃžÃ¶Â,\0\0\0u\0s\0e\0e\0v\0e\0n\0o\0d\0d\0c\0o\0l\0o\0r\0Ã¿Ã¿\0\0YÃ\nâ€œÃ¦,\0\0\0a\0l\0l\0o\0w\0c\0a\0r\0d\0s\0i\0z\0i\0n\0g\0\0\0\0\r\0&	â‚¬Ã®,\0\0\0r\0e\0c\0o\0r\0d\0s\0e\0t\0t\0y\0p\0e\0\0\0\0\0\0\0\0â€¢4Â¼RD\0\0r\0e\0c\0o\0r\0d\0s\0o\0u\0r\0c\0e\0\0\0S\0E\0L\0E\0C\0T\0 \0Q\0.\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0,\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0,\0 \0R\0X\0.\0N\0a\0m\0e\0,\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0A\0S\0 \0Q\0u\0o\0t\0e\0N\0o\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0,\0 \0J\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0 \0A\0S\0 \0P\0r\0o\0j\0e\0c\0t\0,\0 \0Q\0.\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0,\0 \0J\0.\0B\0i\0d\0D\0a\0t\0e\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0,\0 \0T\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0 \0A\0S\0 \0Q\0u\0o\0t\0e\0T\0y\0p\0e\0 \0 \0F\0R\0O\0M\0 \0j\0o\0M\0a\0s\0t\0e\0r\0 \0J\0 \0L\0E\0F\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0r\0x\0M\0a\0s\0t\0e\0r\0 \0R\0X\0 \0O\0N\0 \0J\0.\0r\0x\0C\0u\0s\0t\0o\0m\0e\0r\0I\0D\0 \0=\0 \0R\0X\0.\0r\0x\0M\0a\0s\0t\0e\0r\0I\0D\0 \0R\0I\0G\0H\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0 \0Q\0 \0O\0N\0 \0J\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0=\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0L\0E\0F\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0 \0T\0 \0O\0N\0 \0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0 \0=\0 \0T\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0 \0 \0W\0H\0E\0R\0E\0 \0(\0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0+\0 \0\'\0-\0\'\0 \0+\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0 \0+\0 \0\'\0*\0\'\0 \0+\0 \0S\0T\0R\0(\0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0 \0I\0N\0 \0(\0S\0E\0L\0E\0C\0T\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0 \0+\0 \0\'\0-\0\'\0 \0+\0 \0M\0A\0X\0(\0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0)\0 \0+\0 \0\'\0*\0\'\0 \0+\0 \0S\0T\0R\0(\0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0 \0A\0S\0 \0S\0e\0a\0r\0c\0h\0K\0e\0y\0 \0F\0R\0O\0M\0 \0j\0o\0M\0a\0s\0t\0e\0r\0 \0J\0 \0R\0I\0G\0H\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0 \0Q\0 \0O\0N\0 \0J\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0=\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0 \0W\0h\0e\0r\0e\0 \0(\0j\0.\0J\0o\0b\0S\0t\0a\0t\0u\0s\0 \0=\0 \01\0)\0 \0A\0n\0d\0 \0(\0Q\0.\0C\0r\0e\0a\0t\0e\0d\0B\0y\0I\0D\0 \0=\0 \01\01\0)\0 \0G\0R\0O\0U\0P\0 \0B\0Y\0 \0Q\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0,\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0,\0 \0Q\0.\0c\0u\0M\0a\0s\0t\0e\0r\0T\0y\0p\0e\0I\0D\0)\0)\0 \0O\0R\0D\0E\0R\0 \0B\0Y\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0,\0 \0T\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0,\0 \0Q\0.\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0Â·Ã·Å“L\0\0d\0a\0t\0a\0b\0a\0s\0e\0n\0a\0m\0e\0\0\0P\0r\0o\0v\0i\0d\0e\0r\0=\0S\0Q\0L\0O\0L\0E\0D\0B\0.\01\0;\0P\0a\0s\0s\0w\0o\0r\0d\0=\04\0b\0@\0r\0t\00\0s\02\0@\0d\0m\0i\0n\0;\0U\0s\0e\0r\0 \0I\0D\0=\0s\0a\0;\0I\0n\0i\0t\0i\0a\0l\0 \0C\0a\0t\0a\0l\0o\0g\0=\0B\0a\0r\0t\0o\0s\0_\0C\0o\0m\0p\0a\0n\0y\0;\0D\0a\0t\0a\0 \0S\0o\0u\0r\0c\0e\0=\0b\0a\0r\0d\0l\0t\0r\0m\00\01\0;\0U\0s\0e\0 \0P\0r\0o\0c\0e\0d\0u\0r\0e\0 \0f\0o\0r\0 \0P\0r\0e\0p\0a\0r\0e\0=\01\0;\0A\0u\0t\0o\0 \0T\0r\0a\0n\0s\0l\0a\0t\0e\0=\0T\0r\0u\0e\0;\0P\0a\0c\0k\0e\0t\0 \0S\0i\0z\0e\0=\04\00\09\06\0;\0W\0o\0r\0k\0s\0t\0a\0t\0i\0o\0n\0 \0I\0D\0=\0B\0A\0R\0D\0L\0T\0R\0M\00\01\0;\0U\0s\0e\0 \0E\0n\0c\0r\0y\0p\0t\0i\0o\0n\0 \0f\0o\0r\0 \0D\0a\0t\0a\0=\0F\0a\0l\0s\0e\0;\0T\0a\0g\0 \0w\0i\0t\0h\0 \0c\0o\0l\0u\0m\0n\0 \0c\0o\0l\0l\0a\0t\0i\0o\0n\0 \0w\0h\0e\0n\0 \0p\0o\0s\0s\0i\0b\0l\0e\0=\0F\0a\0l\0s\0e\0\0	\0(sfÃ· \0\0\0a\0l\0l\0o\0w\0e\0d\0i\0t\0\0\0\0\0Âª?Ã‹0\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0h\0e\0a\0d\0e\0r\0Ã¿Â Â \0\0\0\0\0Ã¶Å¡ \0\0\0d\0a\0t\0a\0m\0o\0d\0e\0\0\0\0\0\09Ã³Â·Å¡(\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0b\0k\0g\0Ã¿Ã€Ã€\0\0\0Ã˜z#4\0\0\0c\0o\0l\0u\0m\0n\0h\0e\0a\0d\0e\0r\0h\0e\0i\0g\0h\0t\0\0â‚¬Å½C\0\0Ã›Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\01\0\0\0\0\0\0\0Ã˜Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\02\0\0\0\0\0\0\0ÃÂ¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\07\0\0\0\0\0\0\0Â¬Æ’â€”Â·(\0\0\0c\0o\0l\0u\0m\0n\0s\0c\0o\0u\0n\0t\0\n\0\0\0 	\0Ã€tÃÃžÃ€\0\0c\0o\0l\0u\0m\0n\0(\01\0)\0\0Ëœ\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0Â­\ZÂ£<\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡@\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬4\0\0\0k\0e\0y\0\0\0\0j\0o\0Q\0u\0o\0t\0e\0H\0e\0a\0d\0e\0r\0I\0D\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Å’Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\02\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€4ÃÃž(\0\0c\0o\0l\0u\0m\0n\0(\03\0)\0\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0u\0s\0t\0o\0m\0e\0r\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡,\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0N\0a\0m\0e\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬ \0\0\0k\0e\0y\0\0\0\0N\0a\0m\0e\0\0\0\0\0Ã©Â´~â€”$Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€Ã”ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\04\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0Q\0u\0o\0t\0e\0 \0#\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0N\0o\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0N\0o\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0C\0\0\0\0\0 	\0Ã€Ã´ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\05\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£$\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0R\0e\0v\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0R\0e\0v\0\0\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0!\0\0\0\0\0 	\0Ã€â€ÃÃž,\0\0c\0o\0l\0u\0m\0n\0(\06\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0\0Ã©Â´~â€” Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€Â´ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\07\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0r\0e\0a\0t\0e\0d\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0D\0a\0t\0e\0C\0r\0e\0a\0t\0e\0d\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€TÃŒÃžËœ\0\0c\0o\0l\0u\0m\0n\0(\08\0)\0\0p\0\0\0\0\0\0â€œÂ²\0\0p\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0B\0i\0d\0/\0D\0u\0e\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0B\0i\0d\0D\0a\0t\0e\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0B\0i\0d\0D\0a\0t\0e\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â´Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€tÃŒÃžÂ´\0\0c\0o\0l\0u\0m\0n\0(\09\0)\0\0Å’\0\0\0\0\0\0â€œÂ²\0\0Å’\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0A\0m\0o\0u\0n\0t\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0	\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0\0\0Â¹Ã¼Â²0\0\0\0f\0o\0r\0m\0a\0t\0	\0\0\0#\0#\0,\0#\0#\00\0.\00\00\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0	\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0Q\0u\0o\0t\0e\0A\0m\0o\0u\0n\0t\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\0Ã©Â´~â€”ËœÃ¾Ã¿Ã¿w\0i\0d\0t\0h\0<\0\0\0\0\0 \n\0Ã°;â€ºÂ®@\0\0c\0o\0l\0u\0m\0n\0(\01\00\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\n\0\0\0Q\0u\0o\0t\0e\0 \0T\0y\0p\0e\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\n\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0	\0\0\0Q\0u\0o\0t\0e\0T\0y\0p\0e\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\n\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0	\0\0\0Q\0u\0o\0t\0e\0T\0y\0p\0e\0\0\0Ã©Â´~â€”Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0K\0\0\0\0\0\0\0\0\n\0Ã\nÃ€Â¦$\0\0\0g\0r\0o\0u\0p\0c\0o\0u\0n\0t\0\0\0\0 \0Ã´ËœJÅ¸p\0\0\0g\0r\0o\0u\0p\0(\01\0)\0\0H\0\0\0\0\0\0\0â€œÂ²\0\0H\0\0\0\0\0Â¢Wâ€¡Å½ \0\0\0c\0o\0l\0i\0n\0d\0e\0x\0	\0\0\0\0	\0ËœjÃ Ã®Ã Ã¿Ã¿Ã¿s\0o\0r\0t\0o\0r\0d\0e\0r\0\0\0\0\0\0Â¢xÂ°4\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0s\0c\0o\0u\0n\0t\0\0\0\0\0\0 \0ÃªÂ«Ã‚Ã‚L\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\01\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0D\0e\0f\0a\0u\0l\0t\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã€Ã€\0\0\0\0\0;Â¹Tâ€œ$\0\0\0f\0o\0n\0t\0s\0i\0z\0e\0DB\0\0\0\0\0\0\0Â»WVÂ³<\0\0\0f\0o\0n\0t\0n\0a\0m\0e\0\r\0\0\0M\0S\0 \0S\0a\0n\0s\0 \0S\0e\0r\0i\0f\0\0\0\0\0rÃ–lâ€šÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0Ã¿\0\0\0\0\0\0 \0ÃªÃ‹Ã‚Ã‚Ã„\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\02\0)\0\0Â\0\0\0\0\0\0\0â€œÂ²\0\0Â\0\0\0\0\0dâ€”\râ€ž$\0\0\0n\0a\0m\0e\0\0\0\0O\0d\0d\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã Ã \0\0\0\0\0rÃ–lâ€šâ€Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ«Ã‚Ã‚Ãˆ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\03\0)\0\0â€\0\0\0\0\0\0\0â€œÂ²\0\0â€\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0E\0v\0e\0n\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã°Ã°\0\0\0\0\0rÃ–lâ€šÂÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ‚Ã‚Ã¬\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\04\0)\0\0Â¸\0\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0R\0o\0w\0G\0r\0o\0u\0p\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿ÃÃ\0\0\0\0\0rÃ–lâ€šlÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0Ãª+Ã‚Ã‚ÃŒ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\05\0)\0\0Ëœ\0\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0\0dâ€”\râ€ž,\0\0\0n\0a\0m\0e\0\n\0\0\0P\0r\0e\0v\0i\0e\0w\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0Ã¿\0\0\0\0\0rÃ–lâ€šÅ’Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªKÃ‚Ã‚Ã´\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\06\0)\0\0Ã€\0\0\0\0\0\0\0â€œÂ²\0\0Ã€\0\0\0\0\0dâ€”\râ€ž0\0\0\0n\0a\0m\0e\0\0\0\0S\0e\0l\0e\0c\0t\0e\0d\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0\r\0\0â‚¬\0\0\0\0rÃ–lâ€šdÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0\0\n\0<ZÃ—$\0\0\0i\0m\0a\0g\0e\0c\0o\0u\0n\0t\0\0\0\0\0 \0Ã¤Â¶2ÂxÃŸÃ¿Ã¿p\0r\0i\0n\0t\0e\0r\0p\0r\0o\0p\0e\0r\0t\0i\0e\0s\0\0Â¸\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0	\0\0.Ã·Â®P\0\0\0p\0a\0g\0e\0h\0e\0a\0d\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif	\0\0.Ã½ÃƒÃŸP\0\0\0p\0a\0g\0e\0f\0o\0o\0t\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif\0\082Fâ€ž$\0\0\0o\0r\0i\0e\0n\0t\0a\0t\0i\0o\0n\0\0\0\0Å’YE \0\0\0p\0a\0p\0e\0r\0b\0i\0n\0\0\0\0\0	\0-	3Â« \0\0\0p\0a\0p\0e\0r\0s\0i\0z\0e\0\0\0\0\0Yâ„¢\Z(\0\0\0p\0r\0i\0n\0t\0q\0u\0a\0l\0i\0t\0y\0Ã½Ã¿\0\0\0\0}!Câ€¡0\0\0\0r\0e\0p\0e\0a\0t\0f\0r\0o\0z\0e\0n\0c\0o\0l\0s\0\0\0\0\0\0\r\0|â€™â€“(\0\0\0r\0e\0p\0e\0a\0t\0h\0e\0a\0d\0e\0r\0s\0Ã¿Ã¿\0\0}Â²P\Z|Ã¾Ã¿Ã¿t\0r\0a\0n\0s\0l\0a\0t\0e\0c\0o\0l\0o\0r\0s\0\0\0'),(1003000010,0,0.0000,NULL,NULL,'â€œÂ²\0\0D\0\0\0\0%Y0Â£$\0\0\0v\0e\0r\0s\0i\0o\0n\0\0\0\02\0.\00\0\0\r\0Ã²â€¢Ã¹Â¯(\0\0\0a\0u\0t\0o\0m\0a\0t\0i\0c\0s\0o\0r\0t\0Ã¿Ã¿\0\0ql?,\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0(\0\0\0s\0h\0o\0w\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0<Sâ€¢Ãˆ0\0\0\0b\0o\0u\0n\0d\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0Â¢Ã»0X4\0\0\0r\0e\0p\0l\0a\0c\0e\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0et%Â¬8\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0c\0o\0l\0u\0m\0n\0\0\0\0\0\0\0\0\r\00(Â²,\0\0\0h\0i\0d\0e\0s\0e\0l\0e\0c\0t\0i\0o\0n\0\0\0\0\0\0\0\0Ã¦ÃžÃ¶Â,\0\0\0u\0s\0e\0e\0v\0e\0n\0o\0d\0d\0c\0o\0l\0o\0r\0Ã¿Ã¿\0\0YÃ\nâ€œÃ¦,\0\0\0a\0l\0l\0o\0w\0c\0a\0r\0d\0s\0i\0z\0i\0n\0g\0\0\0\0\r\0&	â‚¬Ã®,\0\0\0r\0e\0c\0o\0r\0d\0s\0e\0t\0t\0y\0p\0e\0\0\0\0\0\0\0\0â€¢4Â¼R\0\0r\0e\0c\0o\0r\0d\0s\0o\0u\0r\0c\0e\0Ã°\0\0\0S\0E\0L\0E\0C\0T\0 \0J\0.\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0,\0 \0J\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0,\0 \0J\0.\0J\0o\0b\0N\0u\0m\0b\0e\0r\0,\0 \0R\0.\0N\0a\0m\0e\0,\0 \0J\0.\0B\0o\0o\0k\0e\0d\0D\0a\0t\0e\0,\0 \0J\0.\0C\0o\0n\0t\0r\0a\0c\0t\0A\0m\0o\0u\0n\0t\0 \0F\0R\0O\0M\0 \0j\0o\0M\0a\0s\0t\0e\0r\0 \0J\0 \0L\0E\0F\0T\0 \0O\0U\0T\0E\0R\0 \0J\0O\0I\0N\0 \0r\0x\0M\0a\0s\0t\0e\0r\0 \0R\0 \0O\0N\0 \0J\0.\0r\0x\0C\0u\0s\0t\0o\0m\0e\0r\0I\0D\0 \0=\0 \0R\0.\0r\0x\0M\0a\0s\0t\0e\0r\0I\0D\0 \0 \0W\0h\0e\0r\0e\0 \0(\0j\0.\0J\0o\0b\0S\0t\0a\0t\0u\0s\0 \0=\0 \03\0)\0 \0A\0N\0D\0 \0(\0j\0.\0c\0u\0A\0s\0s\0i\0g\0n\0m\0e\0n\0t\0I\0D\00\0 \0=\0 \01\00\0)\0 \0O\0R\0D\0E\0R\0 \0B\0Y\0 \0J\0.\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0\0\0Â·Ã·Å“L\0\0d\0a\0t\0a\0b\0a\0s\0e\0n\0a\0m\0e\0\0\0P\0r\0o\0v\0i\0d\0e\0r\0=\0S\0Q\0L\0O\0L\0E\0D\0B\0.\01\0;\0P\0a\0s\0s\0w\0o\0r\0d\0=\04\0b\0@\0r\0t\00\0s\02\0@\0d\0m\0i\0n\0;\0U\0s\0e\0r\0 \0I\0D\0=\0s\0a\0;\0I\0n\0i\0t\0i\0a\0l\0 \0C\0a\0t\0a\0l\0o\0g\0=\0B\0a\0r\0t\0o\0s\0_\0C\0o\0m\0p\0a\0n\0y\0;\0D\0a\0t\0a\0 \0S\0o\0u\0r\0c\0e\0=\0b\0a\0r\0d\0l\0t\0r\0m\00\01\0;\0U\0s\0e\0 \0P\0r\0o\0c\0e\0d\0u\0r\0e\0 \0f\0o\0r\0 \0P\0r\0e\0p\0a\0r\0e\0=\01\0;\0A\0u\0t\0o\0 \0T\0r\0a\0n\0s\0l\0a\0t\0e\0=\0T\0r\0u\0e\0;\0P\0a\0c\0k\0e\0t\0 \0S\0i\0z\0e\0=\04\00\09\06\0;\0W\0o\0r\0k\0s\0t\0a\0t\0i\0o\0n\0 \0I\0D\0=\0B\0A\0R\0D\0L\0T\0R\0M\00\01\0;\0U\0s\0e\0 \0E\0n\0c\0r\0y\0p\0t\0i\0o\0n\0 \0f\0o\0r\0 \0D\0a\0t\0a\0=\0F\0a\0l\0s\0e\0;\0T\0a\0g\0 \0w\0i\0t\0h\0 \0c\0o\0l\0u\0m\0n\0 \0c\0o\0l\0l\0a\0t\0i\0o\0n\0 \0w\0h\0e\0n\0 \0p\0o\0s\0s\0i\0b\0l\0e\0=\0F\0a\0l\0s\0e\0\0	\0(sfÃ· \0\0\0a\0l\0l\0o\0w\0e\0d\0i\0t\0\0\0\0\0FÂ³Ã¶X0\0\0\0g\0r\0o\0u\0p\0b\0y\0b\0o\0x\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Âª?Ã‹0\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0h\0e\0a\0d\0e\0r\0Ã¿Â Â \0\0\0\0\0Ã¶Å¡ \0\0\0d\0a\0t\0a\0m\0o\0d\0e\0\0\0\0\0\09Ã³Â·Å¡(\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0b\0k\0g\0Ã¿Ã€Ã€\0\0\0Ã˜z#4\0\0\0c\0o\0l\0u\0m\0n\0h\0e\0a\0d\0e\0r\0h\0e\0i\0g\0h\0t\0\0â‚¬Å½C\0\0Ã›Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\01\0\0\0\0\0\0\0Ã˜Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\02\0\0\0\0\0\0\0ÃÂ¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\07\0\0\0\0\0\0\0Â¬Æ’â€”Â·(\0\0\0c\0o\0l\0u\0m\0n\0s\0c\0o\0u\0n\0t\0\0\0\0 	\0Ã€tÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\01\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\n\0\0\0j\0o\0M\0a\0s\0t\0e\0r\0I\0D\0\0\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€ÃÃž<\0\0c\0o\0l\0u\0m\0n\0(\02\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0P\0r\0o\0j\0e\0c\0t\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0\0\0Ã©Â´~â€”Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€4ÃÃž0\0\0c\0o\0l\0u\0m\0n\0(\03\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0Â­\ZÂ£(\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0J\0o\0b\0 \0#\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0	\0\0\0J\0o\0b\0N\0u\0m\0b\0e\0r\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0	\0\0\0J\0o\0b\0N\0u\0m\0b\0e\0r\0\0\0Ã©Â´~â€”Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0C\0\0\0\0\0 	\0Ã€Ã”ÃÃž(\0\0c\0o\0l\0u\0m\0n\0(\04\0)\0\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0u\0s\0t\0o\0m\0e\0r\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡,\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0N\0a\0m\0e\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬ \0\0\0k\0e\0y\0\0\0\0N\0a\0m\0e\0\0\0\0\0Ã©Â´~â€”$Ã¿Ã¿Ã¿w\0i\0d\0t\0h\0Ãˆ\0\0\0\0\0 	\0Ã€Ã´ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\05\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0B\0o\0o\0k\0e\0d\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\n\0\0\0B\0o\0o\0k\0e\0d\0D\0a\0t\0e\0\0\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\n\0\0\0B\0o\0o\0k\0e\0d\0D\0a\0t\0e\0\0\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€â€ÃÃžÃˆ\0\0c\0o\0l\0u\0m\0n\0(\06\0)\0\0Â \0\0\0\0\0\0â€œÂ²\0\0Â \0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0o\0n\0t\0r\0a\0c\0t\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡@\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0C\0o\0n\0t\0r\0a\0c\0t\0A\0m\0o\0u\0n\0t\0\0\0\0\0Â¹Ã¼Â²0\0\0\0f\0o\0r\0m\0a\0t\0	\0\0\0#\0#\0,\0#\0#\00\0.\00\00\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬4\0\0\0k\0e\0y\0\0\0\0C\0o\0n\0t\0r\0a\0c\0t\0A\0m\0o\0u\0n\0t\0\0\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\0Ã©Â´~â€”â€žÃ¾Ã¿Ã¿w\0i\0d\0t\0h\0<\0\0\0\0\0\0\0Â¢xÂ°4\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0s\0c\0o\0u\0n\0t\0\0\0\0\0\0 \0ÃªÂ«Ã‚Ã‚L\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\01\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0D\0e\0f\0a\0u\0l\0t\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã€Ã€\0\0\0\0\0;Â¹Tâ€œ$\0\0\0f\0o\0n\0t\0s\0i\0z\0e\0DB\0\0\0\0\0\0\0Â»WVÂ³<\0\0\0f\0o\0n\0t\0n\0a\0m\0e\0\r\0\0\0M\0S\0 \0S\0a\0n\0s\0 \0S\0e\0r\0i\0f\0\0\0\0\0rÃ–lâ€šÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0Ã¿\0\0\0\0\0\0 \0ÃªÃ‹Ã‚Ã‚Ã„\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\02\0)\0\0Â\0\0\0\0\0\0\0â€œÂ²\0\0Â\0\0\0\0\0dâ€”\râ€ž$\0\0\0n\0a\0m\0e\0\0\0\0O\0d\0d\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã Ã \0\0\0\0\0rÃ–lâ€šâ€Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ«Ã‚Ã‚Ãˆ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\03\0)\0\0â€\0\0\0\0\0\0\0â€œÂ²\0\0â€\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0E\0v\0e\0n\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿Ã°Ã°\0\0\0\0\0rÃ–lâ€šÂÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ‚Ã‚Ã¬\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\04\0)\0\0Â¸\0\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0R\0o\0w\0G\0r\0o\0u\0p\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¿ÃÃ\0\0\0\0\0rÃ–lâ€šlÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0Ãª+Ã‚Ã‚ÃŒ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\05\0)\0\0Ëœ\0\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0\0dâ€”\râ€ž,\0\0\0n\0a\0m\0e\0\n\0\0\0P\0r\0e\0v\0i\0e\0w\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0Ã¿\0\0\0\0\0rÃ–lâ€šÅ’Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªKÃ‚Ã‚Ã´\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\06\0)\0\0Ã€\0\0\0\0\0\0\0â€œÂ²\0\0Ã€\0\0\0\0\0dâ€”\râ€ž0\0\0\0n\0a\0m\0e\0\0\0\0S\0e\0l\0e\0c\0t\0e\0d\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0\r\0\0â‚¬\0\0\0\0rÃ–lâ€šdÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0\0\n\0<ZÃ—$\0\0\0i\0m\0a\0g\0e\0c\0o\0u\0n\0t\0\0\0\0\0 \0Ã¤Â¶2ÂÂ´Ã©Ã¿Ã¿p\0r\0i\0n\0t\0e\0r\0p\0r\0o\0p\0e\0r\0t\0i\0e\0s\0\0Â¸\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0	\0\0.Ã·Â®P\0\0\0p\0a\0g\0e\0h\0e\0a\0d\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif	\0\0.Ã½ÃƒÃŸP\0\0\0p\0a\0g\0e\0f\0o\0o\0t\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif\0\082Fâ€ž$\0\0\0o\0r\0i\0e\0n\0t\0a\0t\0i\0o\0n\0\0\0\0Å’YE \0\0\0p\0a\0p\0e\0r\0b\0i\0n\0\0\0\0\0	\0-	3Â« \0\0\0p\0a\0p\0e\0r\0s\0i\0z\0e\0\0\0\0\0Yâ„¢\Z(\0\0\0p\0r\0i\0n\0t\0q\0u\0a\0l\0i\0t\0y\0Ã½Ã¿\0\0\0\0}!Câ€¡0\0\0\0r\0e\0p\0e\0a\0t\0f\0r\0o\0z\0e\0n\0c\0o\0l\0s\0\0\0\0\0\0\r\0|â€™â€“(\0\0\0r\0e\0p\0e\0a\0t\0h\0e\0a\0d\0e\0r\0s\0Ã¿Ã¿\0\0}Â²P\Z|Ã¾Ã¿Ã¿t\0r\0a\0n\0s\0l\0a\0t\0e\0c\0o\0l\0o\0r\0s\0\0\0'),(1005000027,0,0.0000,NULL,NULL,'â€œÂ²\0\0Ã¨M\0\0\0\0%Y0Â£$\0\0\0v\0e\0r\0s\0i\0o\0n\0\0\0\02\0.\00\0\0\r\0Ã²â€¢Ã¹Â¯(\0\0\0a\0u\0t\0o\0m\0a\0t\0i\0c\0s\0o\0r\0t\0Ã¿Ã¿\0\0ql?,\0\0\0s\0c\0r\0o\0l\0l\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0(\0\0\0s\0h\0o\0w\0t\0o\0o\0l\0t\0i\0p\0s\0Ã¿Ã¿\0\0\0\0<Sâ€¢Ãˆ0\0\0\0b\0o\0u\0n\0d\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\0Â¢Ã»0X4\0\0\0r\0e\0p\0l\0a\0c\0e\0c\0o\0l\0u\0m\0n\0i\0n\0d\0e\0x\0\0\0\0\0\0\r\00(Â²,\0\0\0h\0i\0d\0e\0s\0e\0l\0e\0c\0t\0i\0o\0n\0\0\0\0\0\0\0\0Ã¦ÃžÃ¶Â,\0\0\0u\0s\0e\0e\0v\0e\0n\0o\0d\0d\0c\0o\0l\0o\0r\0Ã¿Ã¿\0\0YÃ\nâ€œÃ¦,\0\0\0a\0l\0l\0o\0w\0c\0a\0r\0d\0s\0i\0z\0i\0n\0g\0\0\0\0\r\0&	â‚¬Ã®,\0\0\0r\0e\0c\0o\0r\0d\0s\0e\0t\0t\0y\0p\0e\0\0\0\0\0\0\0\0â€¢4Â¼R|\0\0r\0e\0c\0o\0r\0d\0s\0o\0u\0r\0c\0e\0Âª\0\0S\0E\0L\0E\0C\0T\0 \0A\0l\0e\0r\0t\0I\0D\0,\0 \0O\0w\0n\0e\0r\0I\0D\0,\0 \0S\0t\0a\0t\0u\0s\0,\0 \0A\0l\0e\0r\0t\0O\0n\0,\0 \0A\0l\0e\0r\0t\0O\0n\0 \0A\0S\0 \0A\0D\0a\0t\0e\0,\0 \0(\0c\0a\0s\0e\0 \0w\0h\0e\0n\0 \0(\0d\0a\0t\0e\0p\0a\0r\0t\0(\0h\0h\0,\0a\0l\0e\0r\0t\0o\0n\0)\0=\00\0 \0a\0n\0d\0 \0d\0a\0t\0e\0p\0a\0r\0t\0(\0m\0i\0,\0a\0l\0e\0r\0t\0o\0n\0)\0=\00\0)\0 \0t\0h\0e\0n\0 \0n\0u\0l\0l\0 \0e\0l\0s\0e\0 \0a\0l\0e\0r\0t\0o\0n\0 \0e\0n\0d\0)\0 \0A\0S\0 \0A\0T\0i\0m\0e\0,\0 \0C\0r\0e\0a\0t\0e\0d\0B\0y\0I\0D\0,\0 \0C\0r\0e\0a\0t\0e\0d\0O\0n\0,\0 \0A\0l\0e\0r\0t\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0,\0 \0A\0l\0e\0r\0t\0N\0o\0t\0e\0,\0 \0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0T\0y\0p\0e\0,\0 \0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0I\0D\0,\0 \0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0,\0 \0C\0o\0m\0p\0l\0e\0t\0e\0d\0D\0a\0t\0e\0,\0 \0D\0u\0e\0O\0n\0 \0F\0R\0O\0M\0 \0A\0l\0e\0r\0t\0 \0W\0H\0E\0R\0E\0 \0(\0(\0M\0a\0s\0s\0A\0l\0e\0r\0t\0 \0=\0 \00\0 \0A\0N\0D\0 \0C\0r\0e\0a\0t\0e\0d\0B\0y\0I\0D\0 \0=\02\07\0 \0)\0 \0O\0R\0 \0(\0O\0w\0n\0e\0r\0I\0D\0 \0=\0 \02\07\0)\0)\0 \0A\0N\0D\0 \0(\0(\0S\0T\0A\0T\0U\0S\0=\00\0 \0A\0N\0D\0 \0A\0L\0E\0R\0T\0O\0N\0<\0=\0\'\02\0/\01\02\0/\02\00\01\00\0 \02\0:\04\04\0:\04\03\0 \0P\0M\0\'\0)\0 \0O\0R\0 \0(\01\0=\00\0)\0)\0\0\0Â·Ã·Å“L\0\0d\0a\0t\0a\0b\0a\0s\0e\0n\0a\0m\0e\0\0\0P\0r\0o\0v\0i\0d\0e\0r\0=\0S\0Q\0L\0O\0L\0E\0D\0B\0.\01\0;\0P\0a\0s\0s\0w\0o\0r\0d\0=\04\0b\0@\0r\0t\00\0s\02\0@\0d\0m\0i\0n\0;\0U\0s\0e\0r\0 \0I\0D\0=\0s\0a\0;\0I\0n\0i\0t\0i\0a\0l\0 \0C\0a\0t\0a\0l\0o\0g\0=\0B\0a\0r\0t\0o\0s\0_\0C\0o\0m\0p\0a\0n\0y\0;\0D\0a\0t\0a\0 \0S\0o\0u\0r\0c\0e\0=\0b\0a\0r\0d\0l\0t\0r\0m\00\01\0;\0U\0s\0e\0 \0P\0r\0o\0c\0e\0d\0u\0r\0e\0 \0f\0o\0r\0 \0P\0r\0e\0p\0a\0r\0e\0=\01\0;\0A\0u\0t\0o\0 \0T\0r\0a\0n\0s\0l\0a\0t\0e\0=\0T\0r\0u\0e\0;\0P\0a\0c\0k\0e\0t\0 \0S\0i\0z\0e\0=\04\00\09\06\0;\0W\0o\0r\0k\0s\0t\0a\0t\0i\0o\0n\0 \0I\0D\0=\0B\0A\0R\0D\0L\0T\0R\0M\00\01\0;\0U\0s\0e\0 \0E\0n\0c\0r\0y\0p\0t\0i\0o\0n\0 \0f\0o\0r\0 \0D\0a\0t\0a\0=\0F\0a\0l\0s\0e\0;\0T\0a\0g\0 \0w\0i\0t\0h\0 \0c\0o\0l\0u\0m\0n\0 \0c\0o\0l\0l\0a\0t\0i\0o\0n\0 \0w\0h\0e\0n\0 \0p\0o\0s\0s\0i\0b\0l\0e\0=\0F\0a\0l\0s\0e\0\0\0+ÃƒÃ§$\0\0\0a\0l\0l\0o\0w\0d\0e\0l\0e\0t\0e\0Ã¿Ã¿\0	\0(sfÃ· \0\0\0a\0l\0l\0o\0w\0e\0d\0i\0t\0\0\0\0\0FÂ³Ã¶X0\0\0\0g\0r\0o\0u\0p\0b\0y\0b\0o\0x\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Âª?Ã‹0\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0h\0e\0a\0d\0e\0r\0Ã€Ã€Ã€\0\0\0\0	\0&z!Â¾$\0\0\0m\0a\0s\0k\0c\0o\0l\0o\0r\0Ã¿\0Ã¿\0\0\0\0\n\0<ZÃ—$\0\0\0i\0m\0a\0g\0e\0c\0o\0u\0n\0t\0\0\0\0	\0\r\0Ã·>â‚¬Ã“t\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\01\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\r\0Ã´>â‚¬Ã“t\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\02\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQ\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\r\0Ãµ>â‚¬Ã“t\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\03\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQ\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\r\0Ã²>â‚¬Ã“4\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\04\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\0Ã¶\0\0\0BMÃ¶\0\0\0\0\0\0\0v\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0â‚¬\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0â‚¬\0Ã¿Ã¿Ã¿\0Ã€Ã€Ã€\0â‚¬â‚¬â‚¬\0\0\0\0\0\0â‚¬\0\0\0â‚¬â‚¬\0â‚¬\0\0\0â‚¬\0â‚¬\0â‚¬â‚¬\0\0\0\0Ã¿\0\0Ã¿\0\0\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿\0Ã¿\0Ã¿Ã¿\0\0DDDDAAA\"A!A \0\"A\0A!A\"AAAADDAD\"DADD	\0\r\0Ã³>â‚¬Ã“t\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\05\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0Ã¿\0\0Ã¿\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã†ÃƒÃ†â€ž\0\0Ã¿\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0Ã†ÃƒÃ†Ã†ÃƒÃ†Ã¿Ã¿Ã¿Ã†ÃƒÃ†â€žâ€šâ€žâ€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0\0\0â€žâ€šâ€žÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã†ÃƒÃ†Ã¿\0\0Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\r\0Ã°>â‚¬Ã“t\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\06\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0Ã¿\0\0Ã¿\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã†ÃƒÃ†â€ž\0\0Ã¿\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0Ã†ÃƒÃ†Ã†ÃƒÃ†Ã¿Ã¿Ã¿Ã†ÃƒÃ†â€žâ€šâ€žâ€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0\0\0â€žâ€šâ€žÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã†ÃƒÃ†Ã¿\0\0Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0Ã¶Å¡ \0\0\0d\0a\0t\0a\0m\0o\0d\0e\0\0\0\0\0\09Ã³Â·Å¡(\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0b\0k\0g\0Ã Ã Ã \0\0\0Ã˜z#4\0\0\0c\0o\0l\0u\0m\0n\0h\0e\0a\0d\0e\0r\0h\0e\0i\0g\0h\0t\0\0â‚¬Å½C\0\0Ã›Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\01\0\0\0\0\0\0\0Ã˜Â¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\02\0\0\0\0\0\0\0ÃÂ¹Ã³ \0\0\0i\0n\0t\0p\0r\0o\0p\07\0\0\0\0\0\0\0Â¬Æ’â€”Â·(\0\0\0c\0o\0l\0u\0m\0n\0s\0c\0o\0u\0n\0t\0\0\0\0 	\0Ã€tÃÃžÂ\0\0c\0o\0l\0u\0m\0n\0(\01\0)\0\0h\0\0\0\0\0\0â€œÂ²\0\0h\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0A\0l\0e\0r\0t\0I\0D\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0A\0l\0e\0r\0t\0I\0D\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0A\0l\0e\0r\0t\0I\0D\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¼Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€ÃÃžÂ\0\0c\0o\0l\0u\0m\0n\0(\02\0)\0\0h\0\0\0\0\0\0â€œÂ²\0\0h\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0O\0w\0n\0e\0r\0I\0D\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0O\0w\0n\0e\0r\0I\0D\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0O\0w\0n\0e\0r\0I\0D\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¼Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€4ÃÃžÃ\0\0c\0o\0l\0u\0m\0n\0(\03\0)\0\0Â¨\0\0\0\0\0\0â€œÂ²\0\0Â¨\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0\n\0Â½â€œÅ½$\0\0\0c\0o\0l\0u\0m\0n\0t\0y\0p\0e\0\0\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0S\0t\0a\0t\0u\0s\0\0\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0	\0*Â²ÂÂ¢ \0\0\0f\0e\0t\0c\0h\0i\0c\0o\0n\0Ã¿Ã¿\0\n\0&Â±4Å½$\0\0\0h\0e\0a\0d\0e\0r\0i\0c\0o\0n\0\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0S\0t\0a\0t\0u\0s\0\0\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\0Ã©Â´~â€”|Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0\0\0\0\0\0 	\0Ã€Ã”ÃÃžË†\0\0c\0o\0l\0u\0m\0n\0(\04\0)\0\0`\0\0\0\0\0\0â€œÂ²\0\0`\0\0\0\0Â­\ZÂ£,\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0A\0l\0e\0r\0t\0O\0n\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡0\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0A\0l\0e\0r\0t\0O\0n\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬$\0\0\0k\0e\0y\0\0\0\0A\0l\0e\0r\0t\0O\0n\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Ã„Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€Ã´ÃÃžÅ’\0\0c\0o\0l\0u\0m\0n\0(\05\0)\0\0d\0\0\0\0\0\0â€œÂ²\0\0d\0\0\0\0Â­\ZÂ£(\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0D\0a\0t\0e\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡,\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0A\0D\0a\0t\0e\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬ \0\0\0k\0e\0y\0\0\0\0A\0D\0a\0t\0e\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Ã€Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€â€ÃÃžÂ\0\0c\0o\0l\0u\0m\0n\0(\06\0)\0\0h\0\0\0\0\0\0â€œÂ²\0\0h\0\0\0\0Â­\ZÂ£(\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0T\0i\0m\0e\0\0\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡,\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0A\0T\0i\0m\0e\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²0\0\0\0f\0o\0r\0m\0a\0t\0\n\0\0\0h\0h\0:\0m\0m\0 \0A\0M\0P\0M\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬ \0\0\0k\0e\0y\0\0\0\0A\0T\0i\0m\0e\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”Â¼Ã¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0 	\0Ã€Â´ÃÃžÂ¨\0\0c\0o\0l\0u\0m\0n\0(\07\0)\0\0â‚¬\0\0\0\0\0\0â€œÂ²\0\0â‚¬\0\0\0\0Â­\ZÂ£4\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0C\0r\0e\0a\0t\0e\0d\0B\0y\0I\0D\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡8\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0C\0r\0e\0a\0t\0e\0d\0B\0y\0I\0D\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬,\0\0\0k\0e\0y\0\0\0\0C\0r\0e\0a\0t\0e\0d\0B\0y\0I\0D\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¤Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€TÃŒÃžâ€\0\0c\0o\0l\0u\0m\0n\0(\08\0)\0\0l\0\0\0\0\0\0â€œÂ²\0\0l\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0	\0\0\0C\0r\0e\0a\0t\0e\0d\0O\0n\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0	\0\0\0C\0r\0e\0a\0t\0e\0d\0O\0n\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0	\0\0\0C\0r\0e\0a\0t\0e\0d\0O\0n\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Â¸Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0 	\0Ã€tÃŒÃžP\0\0c\0o\0l\0u\0m\0n\0(\09\0)\0\0(\0\0\0\0\0\0â€œÂ²\0\0(\0\0\0\0Â­\ZÂ£(\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0A\0l\0e\0r\0t\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0	\0\0	\0$ÃpÅ¡D\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0A\0l\0e\0r\0t\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0	\0\0\0xÂ Â¬8\0\0\0k\0e\0y\0\0\0\0A\0l\0e\0r\0t\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0\0\0\0\0Ã©Â´~â€”Ã¼Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0\0\0\0\0 \n\0Ã°;â€ºÂ®X\0\0c\0o\0l\0u\0m\0n\0(\01\00\0)\0\0,\0\0\0\0\0\0â€œÂ²\0\0,\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0	\0\0\0A\0l\0e\0r\0t\0N\0o\0t\0e\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\n\0\0	\0$ÃpÅ¡4\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0	\0\0\0A\0l\0e\0r\0t\0N\0o\0t\0e\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\n\0\0\0xÂ Â¬(\0\0\0k\0e\0y\0	\0\0\0A\0l\0e\0r\0t\0N\0o\0t\0e\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Ã¸Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0\0\0 \n\0Ã°â€ºÂ®Ã„\0\0c\0o\0l\0u\0m\0n\0(\01\01\0)\0\0Ëœ\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0Â­\ZÂ£<\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0T\0y\0p\0e\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡@\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0T\0y\0p\0e\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬4\0\0\0k\0e\0y\0\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0T\0y\0p\0e\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”Å’Ã¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0\0\0 \n\0Ã°{â€ºÂ®Â¸\0\0c\0o\0l\0u\0m\0n\0(\01\02\0)\0\0Å’\0\0\0\0\0\0â€œÂ²\0\0Å’\0\0\0\0Â­\ZÂ£8\0\0\0c\0a\0p\0t\0i\0o\0n\0\r\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0I\0D\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡<\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\r\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0I\0D\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬0\0\0\0k\0e\0y\0\r\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0I\0D\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\r\0ÃŸVEÂ¼(\0\0\0t\0e\0x\0t\0a\0l\0i\0g\0n\0m\0e\0n\0t\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”ËœÃ¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0\0\0 \n\0Ã°[â€ºÂ®t\0\0c\0o\0l\0u\0m\0n\0(\01\03\0)\0\0H\0\0\0\0\0\0â€œÂ²\0\0H\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0	\0\0\0R\0e\0f\0e\0r\0e\0n\0c\0e\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\r\0\0	\0$ÃpÅ¡P\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\r\0\0\0xÂ Â¬D\0\0\0k\0e\0y\0\0\0\0T\0r\0a\0n\0s\0a\0c\0t\0i\0o\0n\0D\0e\0s\0c\0r\0i\0p\0t\0i\0o\0n\0\0\0\0\0Ã©Â´~â€”ÃœÃ¾Ã¿Ã¿w\0i\0d\0t\0h\0\0\0\0\0\0\0 \n\0Ã°Â»â€ºÂ®Â¸\0\0c\0o\0l\0u\0m\0n\0(\01\04\0)\0\0Å’\0\0\0\0\0\0â€œÂ²\0\0Å’\0\0\0\0Â­\ZÂ£0\0\0\0c\0a\0p\0t\0i\0o\0n\0	\0\0\0C\0o\0m\0p\0l\0e\0t\0e\0d\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡<\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\r\0\0\0C\0o\0m\0p\0l\0e\0t\0e\0d\0D\0a\0t\0e\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0Â¹Ã¼Â²,\0\0\0f\0o\0r\0m\0a\0t\0\0\0\0M\0M\0/\0D\0D\0/\0Y\0Y\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬0\0\0\0k\0e\0y\0\r\0\0\0C\0o\0m\0p\0l\0e\0t\0e\0d\0D\0a\0t\0e\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\0Ã©Â´~â€”ËœÃ¾Ã¿Ã¿w\0i\0d\0t\0h\09\0\0\0\0\0\0\0 \n\0Ã°â€ºâ€ºÂ®â‚¬\0\0c\0o\0l\0u\0m\0n\0(\01\05\0)\0\0T\0\0\0\0\0\0â€œÂ²\0\0T\0\0\0\0Â­\ZÂ£(\0\0\0c\0a\0p\0t\0i\0o\0n\0\0\0\0D\0u\0e\0O\0n\0\0	\0Â¿Ã™&Ã‹$\0\0\0c\0e\0l\0l\0s\0t\0y\0l\0e\0\0\0\0\0\0\0\0\0wf/$\0\0\0c\0o\0l\0p\0o\0s\0i\0t\0i\0o\0n\0\0\0	\0$ÃpÅ¡,\0\0\0d\0a\0t\0a\0f\0i\0e\0l\0d\0\0\0\0D\0u\0e\0O\0n\0\0\0Âµ:WÃ‹ \0\0\0e\0d\0i\0t\0t\0y\0p\0e\0\0\0\0\0\0yâ€”Å“â€“\0\0\0i\0n\0d\0e\0x\0\0\0\0xÂ Â¬ \0\0\0k\0e\0y\0\0\0\0D\0u\0e\0O\0n\0\0\0Æ’ÃºU{ \0\0\0s\0o\0r\0t\0t\0y\0p\0e\0\0\0\0\0\064 Â\0\0\0v\0i\0s\0i\0b\0l\0e\0\0\0\0\0Ã©Â´~â€”ÃÃ¾Ã¿Ã¿w\0i\0d\0t\0h\0d\0\0\0\0\0\0\0\0\0Â¢xÂ°4\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0s\0c\0o\0u\0n\0t\0\0\0\0\0\0 \0ÃªÂ«Ã‚Ã‚L\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\01\0)\0\0\0\0\0\0\0\0â€œÂ²\0\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0D\0e\0f\0a\0u\0l\0t\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã Ã Ã \0\0\0\0\0;Â¹Tâ€œ$\0\0\0f\0o\0n\0t\0s\0i\0z\0e\0DB\0\0\0\0\0\0\0Â»WVÂ³<\0\0\0f\0o\0n\0t\0n\0a\0m\0e\0\r\0\0\0M\0S\0 \0S\0a\0n\0s\0 \0S\0e\0r\0i\0f\0\0\0\0\0rÃ–lâ€šÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0Ã¿\0\0\0\0\0\0 \0ÃªÃ‹Ã‚Ã‚Ã„\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\02\0)\0\0Â\0\0\0\0\0\0\0â€œÂ²\0\0Â\0\0\0\0\0dâ€”\râ€ž$\0\0\0n\0a\0m\0e\0\0\0\0O\0d\0d\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã°Ã°Ã°\0\0\0\0\0rÃ–lâ€šâ€Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ«Ã‚Ã‚Ãˆ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\03\0)\0\0â€\0\0\0\0\0\0\0â€œÂ²\0\0â€\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0E\0v\0e\0n\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¸Ã¸Ã¸\0\0\0\0\0rÃ–lâ€šÂÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªÃ‚Ã‚Ã¬\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\04\0)\0\0Â¸\0\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0\0\0\0dâ€”\râ€ž(\0\0\0n\0a\0m\0e\0\0\0\0R\0o\0w\0G\0r\0o\0u\0p\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0Ã¨Ã¨Ã¨\0\0\0\0\0rÃ–lâ€šlÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0Ãª+Ã‚Ã‚ÃŒ\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\05\0)\0\0Ëœ\0\0\0\0\0\0\0â€œÂ²\0\0Ëœ\0\0\0\0\0dâ€”\râ€ž,\0\0\0n\0a\0m\0e\0\n\0\0\0P\0r\0e\0v\0i\0e\0w\0R\0o\0w\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0Ã¿\0\0\0\0\0rÃ–lâ€šÅ’Ã¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0 \0ÃªKÃ‚Ã‚Ã´\0\0\0f\0o\0r\0m\0a\0t\0s\0t\0y\0l\0e\0(\06\0)\0\0Ã€\0\0\0\0\0\0\0â€œÂ²\0\0Ã€\0\0\0\0\0dâ€”\râ€ž0\0\0\0n\0a\0m\0e\0\0\0\0S\0e\0l\0e\0c\0t\0e\0d\0R\0o\0w\0\0\0\0\n\0,Ã¦uËœ$\0\0\0p\0r\0e\0d\0e\0f\0i\0n\0e\0d\0Ã¿Ã¿\0\0\0	\0:1!ÃŽ$\0\0\0f\0o\0r\0e\0c\0o\0l\0o\0r\0\0\0â‚¬\0\0\0	\0&u%Â¾$\0\0\0b\0a\0c\0k\0c\0o\0l\0o\0r\0\r\0\0â‚¬\0\0\0\0rÃ–lâ€šdÃ¿Ã¿Ã¿f\0l\0a\0g\0s\0\0\0\0\0\0\0\0\0\n\0<ZÃ—$\0\0\0i\0m\0a\0g\0e\0c\0o\0u\0n\0t\0\0\0\0	\0\0Ã’ HÂ»x\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\0(\01\0)\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\0Ã’@HÂ»x\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\0(\02\0)\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQ\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\0Ã’`HÂ»x\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\0(\03\0)\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQ\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0\0\0\0\0\0\0\0QQ\0QQ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0Ã¿Ã¿Ã¿Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€Ã€\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\0Ã’â‚¬HÂ»8\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\0(\04\0)\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\0Ã¶\0\0\0BMÃ¶\0\0\0\0\0\0\0v\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0â‚¬\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0â‚¬\0Ã¿Ã¿Ã¿\0Ã€Ã€Ã€\0â‚¬â‚¬â‚¬\0\0\0\0\0\0â‚¬\0\0\0â‚¬â‚¬\0â‚¬\0\0\0â‚¬\0â‚¬\0â‚¬â‚¬\0\0\0\0Ã¿\0\0Ã¿\0\0\0Ã¿Ã¿\0Ã¿\0\0\0Ã¿\0Ã¿\0Ã¿Ã¿\0\0DDDDAAA\"A!A \0\"A\0A!A\"AAAADDAD\"DADD	\0\0Ã’Â HÂ»x\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\0(\05\0)\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0Ã¿\0\0Ã¿\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã†ÃƒÃ†â€ž\0\0Ã¿\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0Ã†ÃƒÃ†Ã†ÃƒÃ†Ã¿Ã¿Ã¿Ã†ÃƒÃ†â€žâ€šâ€žâ€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0\0\0â€žâ€šâ€žÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã†ÃƒÃ†Ã¿\0\0Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•$Ã¿Ã¿$Ã¿Ã¿$Ã¿Ã¿\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•$Ã¿Ã¿\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿	\0\0Ã’Ã€HÂ»x\0\0i\0m\0a\0g\0e\0p\0i\0c\0t\0u\0r\0e\0(\06\0)\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Qlt\0\06\0\0BM6\0\0\0\0\0\06\0\0\0(\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0Ã¿\0\0Ã¿\0\0â€ž\0\0â€ž\0\0â€ž\0\0Ã†ÃƒÃ†â€ž\0\0Ã¿\0\0â€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿â€ž\0\0â€ž\0\0Ã†ÃƒÃ†Ã†ÃƒÃ†Ã¿Ã¿Ã¿Ã†ÃƒÃ†â€žâ€šâ€žâ€ž\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0\0\0â€žâ€šâ€žÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0â€ž\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQ\0QQÃ¿Ã¿Ã¿\0\0\0Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ¿Ã¿Ã¿Ã†ÃƒÃ†Ã¿\0\0Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQÃ†ÃƒÃ†Ã¿Ã¿Ã¿â€žâ€šâ€ž\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQ\0\0\0Ã¿Ã¿Ã¿Ã¿Ã¿Ã¿Ã†ÃƒÃ†\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•\0ÂÂ\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQâ‚¬â‚¬â‚¬\0Ã•Ã•\0Ã•Ã•\0Ã•Ã•â‚¬â‚¬â‚¬\0QQ\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0ÂÂ\0Ã•Ã•\0ÂÂ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿\0QQ\0QQ\0QQÃ¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿Ã¿\0Ã¿ \0Ã¤Â¶2ÂÂ´Ã¿Ã¿p\0r\0i\0n\0t\0e\0r\0p\0r\0o\0p\0e\0r\0t\0i\0e\0s\0\0Â¸\0\0\0\0\0\0â€œÂ²\0\0Â¸\0\0	\0\0.Ã·Â®P\0\0\0p\0a\0g\0e\0h\0e\0a\0d\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif	\0\0.Ã½ÃƒÃŸP\0\0\0p\0a\0g\0e\0f\0o\0o\0t\0e\0r\0f\0o\0n\0t\0RÃ£â€˜ÂÃŽÂÃ£\0Âª\0KÂ¸Q\0\0\0ÂDB\0\rMS Sans Serif\0\082Fâ€ž$\0\0\0o\0r\0i\0e\0n\0t\0a\0t\0i\0o\0n\0\0\0\0Å’YE \0\0\0p\0a\0p\0e\0r\0b\0i\0n\0\0\0\0\0	\0-	3Â« \0\0\0p\0a\0p\0e\0r\0s\0i\0z\0e\0\0\0\0\0Yâ„¢\Z(\0\0\0p\0r\0i\0n\0t\0q\0u\0a\0l\0i\0t\0y\0Ã½Ã¿\0\0\0\0}!Câ€¡0\0\0\0r\0e\0p\0e\0a\0t\0f\0r\0o\0z\0e\0n\0c\0o\0l\0s\0\0\0\0\0\0\r\0|â€™â€“(\0\0\0r\0e\0p\0e\0a\0t\0h\0e\0a\0d\0e\0r\0s\0Ã¿Ã¿\0\0}Â²P\Z|Ã¾Ã¿Ã¿t\0r\0a\0n\0s\0l\0a\0t\0e\0c\0o\0l\0o\0r\0s\0\0\0'),(2014002001,1,NULL,NULL,NULL,NULL),(2014002002,0,NULL,NULL,NULL,NULL),(2014002003,1,NULL,NULL,NULL,NULL),(2014002004,0,NULL,NULL,NULL,NULL),(2014002005,1,NULL,NULL,NULL,NULL),(2014002006,0,NULL,NULL,NULL,NULL),(2014002007,1,NULL,NULL,NULL,NULL),(2014002008,1,NULL,NULL,NULL,NULL),(2014002009,1,NULL,NULL,NULL,NULL),(2014002010,0,NULL,NULL,NULL,NULL),(2014002011,0,NULL,NULL,NULL,NULL),(2014002012,1,NULL,NULL,NULL,NULL),(2014002013,1,NULL,NULL,NULL,NULL),(2014002014,1,NULL,NULL,NULL,NULL),(2014002015,0,NULL,'228259',NULL,NULL),(2014002016,0,NULL,NULL,NULL,NULL),(2014002017,0,NULL,NULL,NULL,NULL),(2014002018,0,NULL,NULL,NULL,NULL),(2014002019,1,0.0000,NULL,NULL,NULL),(2014002020,0,0.0000,NULL,NULL,NULL),(2014002021,1,NULL,NULL,NULL,NULL),(2014002022,1,NULL,NULL,NULL,NULL),(2014003001,0,NULL,NULL,NULL,NULL),(2014003002,0,NULL,NULL,NULL,NULL),(2014003003,0,NULL,NULL,NULL,NULL),(2014003004,0,NULL,NULL,NULL,NULL),(2014003005,0,NULL,NULL,NULL,NULL),(2014003006,0,NULL,NULL,NULL,NULL),(2014003007,0,NULL,NULL,NULL,NULL),(2014003008,0,NULL,NULL,NULL,NULL),(2014004001,1,NULL,NULL,NULL,NULL),(2014004002,NULL,NULL,'Adjustments',NULL,NULL),(2014004003,NULL,NULL,'',NULL,NULL),(2014004004,NULL,NULL,'',NULL,NULL),(2014004005,NULL,NULL,'',NULL,NULL),(2014004006,NULL,NULL,'Job Commission',NULL,NULL),(2014004007,NULL,NULL,'Warehouse Commission',NULL,NULL),(2014004008,NULL,NULL,'Override Job Commission',NULL,NULL),(2014004009,NULL,NULL,'',NULL,NULL),(2014004010,1,NULL,NULL,NULL,NULL),(2014004011,NULL,NULL,NULL,NULL,NULL),(2014004012,1,NULL,NULL,NULL,NULL),(2014004013,0,0.0000,'',NULL,NULL),(2014004014,0,0.0000,NULL,NULL,NULL),(2014004015,0,0.0000,NULL,NULL,NULL),(2014004016,0,0.0000,'Job Commission',NULL,NULL),(2014004017,0,0.0000,'Paid Invoices',NULL,NULL),(2014005001,0,NULL,NULL,NULL,NULL),(2014005002,0,NULL,NULL,NULL,NULL),(2014005003,0,NULL,NULL,NULL,NULL),(2014005004,1,NULL,NULL,NULL,NULL),(2014005005,0,NULL,NULL,NULL,NULL),(2014005006,1,NULL,NULL,NULL,NULL),(2014005007,0,NULL,NULL,NULL,NULL),(2014005008,1,NULL,NULL,NULL,NULL),(2014005009,0,NULL,NULL,NULL,NULL),(2014005010,0,NULL,NULL,NULL,NULL),(2014005011,0,NULL,NULL,NULL,NULL),(2014005012,0,NULL,NULL,NULL,NULL),(2014005013,0,NULL,NULL,NULL,NULL),(2014005014,0,NULL,NULL,NULL,NULL),(2014005015,1,NULL,NULL,NULL,NULL),(2014005016,0,NULL,NULL,NULL,NULL),(2014005017,0,NULL,NULL,NULL,NULL),(2014005018,0,NULL,NULL,NULL,NULL),(2014005019,0,NULL,NULL,NULL,NULL),(2014005020,0,NULL,NULL,NULL,NULL),(2014005021,0,NULL,NULL,NULL,NULL),(2014005022,1,NULL,NULL,NULL,NULL),(2014005023,1,NULL,NULL,NULL,NULL),(2014005024,1,NULL,NULL,NULL,NULL),(2014005025,0,NULL,NULL,NULL,NULL),(2014005026,0,NULL,NULL,NULL,NULL),(2014005027,0,NULL,NULL,NULL,NULL),(2014005028,0,NULL,NULL,NULL,NULL),(2014005029,0,NULL,NULL,NULL,NULL),(2014005030,0,NULL,NULL,NULL,NULL),(2014005031,0,NULL,NULL,NULL,NULL),(2014005032,0,NULL,NULL,NULL,NULL),(2014005033,1,NULL,NULL,NULL,NULL),(2014005034,0,NULL,NULL,NULL,NULL),(2014005035,NULL,NULL,'Specs1',NULL,NULL),(2014005036,NULL,NULL,'Specs',NULL,NULL),(2014005037,NULL,NULL,'SKIHI',NULL,NULL),(2014005038,NULL,NULL,'Vent/Met',NULL,NULL),(2014005039,NULL,NULL,'ISQFT',NULL,NULL),(2014005040,NULL,NULL,'Other',NULL,NULL),(2014005041,NULL,NULL,'Report #',NULL,NULL),(2014005042,NULL,NULL,'Other',NULL,NULL),(2014005043,1,NULL,'check',NULL,NULL),(2014005044,NULL,NULL,NULL,NULL,NULL),(2014005045,1,NULL,'Final',NULL,NULL),(2014005046,NULL,NULL,NULL,NULL,NULL),(2014005047,1,NULL,'Project Data Sheet',NULL,NULL),(2014005048,0,NULL,NULL,NULL,NULL),(2014005049,NULL,NULL,NULL,NULL,NULL),(2014005050,0,NULL,NULL,NULL,NULL),(2014005051,1,NULL,NULL,NULL,NULL),(2014005052,1,NULL,NULL,NULL,NULL),(2014005053,1,NULL,NULL,NULL,NULL),(2014005054,0,NULL,NULL,NULL,NULL),(2014005055,0,NULL,NULL,NULL,NULL),(2014005056,0,NULL,NULL,NULL,NULL),(2014005057,0,NULL,NULL,NULL,NULL),(2014005058,0,NULL,NULL,NULL,NULL),(2014005059,0,NULL,NULL,NULL,NULL),(2014005060,0,NULL,NULL,NULL,NULL),(2014005061,0,NULL,NULL,NULL,NULL),(2014005062,1,0.0000,'10',NULL,NULL),(2014005063,1,0.0000,'Arial',NULL,NULL),(2014005064,1,0.0000,'10',NULL,NULL),(2014005065,0,NULL,NULL,NULL,NULL),(2014005066,1,NULL,'Arial',NULL,NULL),(2014006001,0,NULL,'',NULL,NULL),(2014006002,0,NULL,NULL,NULL,NULL),(2014006003,0,NULL,NULL,NULL,NULL),(2014006004,1,NULL,NULL,NULL,NULL),(2014006005,0,NULL,NULL,NULL,NULL),(2014006006,1,NULL,NULL,NULL,NULL),(2014008006,0,0.0000,NULL,NULL,NULL),(2014008007,0,0.0000,NULL,NULL,NULL),(2014008008,0,0.0000,NULL,NULL,NULL),(2014008009,0,0.0000,NULL,NULL,NULL),(2014008010,0,0.0000,NULL,NULL,NULL),(2014008011,0,0.0000,NULL,NULL,NULL),(2014008012,0,0.0000,NULL,NULL,NULL),(2014008013,0,0.0000,NULL,NULL,NULL),(2014008014,0,0.0000,NULL,NULL,NULL),(2016005058,1,0.0000,NULL,NULL,NULL),(2016010026,0,0.0000,NULL,NULL,NULL),(2016010027,0,0.0000,NULL,NULL,NULL),(2016010028,0,0.0000,NULL,NULL,NULL),(2016010029,0,0.0000,NULL,NULL,NULL),(2016010030,0,0.0000,NULL,NULL,NULL),(2016010031,0,0.0000,NULL,NULL,NULL),(2016010032,0,0.0000,'',NULL,NULL),(2016010033,0,0.0000,'Pending@@Lost@@Sold',NULL,NULL),(2016010034,0,0.0000,NULL,NULL,NULL),(2016010035,1,NULL,'QUARTERLY',NULL,NULL),(2016010036,66,0.0000,NULL,NULL,NULL),(2016010037,0,0.0000,NULL,NULL,NULL),(2016010038,0,0.0000,NULL,NULL,NULL);


END;$$

DELIMITER ;
