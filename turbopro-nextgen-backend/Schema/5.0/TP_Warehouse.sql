-- ======================================================================================
-- SCRIPT VERSION:  1.0 -- please update _version on line 41
-- 
-- 
-- ======================================================================================
-- clean up some unnecessary procedures
DROP procedure IF EXISTS `WH_updateWarehouse`;
DROP procedure IF EXISTS WH_updateJobActivity;
DROP table IF EXISTS  wh_logStatus;
DROP table IF EXISTS `WH_JobActivity`;
-- ======================================================================================


-- call WH_update('REBUILD_WH_logStatus',null); -- recreate log table.  loss of existing data.

-- ORDER MAY MATTER, so when adding WH tables make sure it is proper order in the WH_Update procedure.


-- call WH_update('REBUILD_WH_salesCommission',null); -- drop table, create table, populate table`  175 seconds
-- call WH_update('REBUILD_WH_splitJob',null); -- drop table, create table, populate table`
-- call WH_update('REBUILD_WH_invoice',null); -- drop table, create table, populate table` 120 seconds
-- call WH_update('REBUILD_WH_invoice_investigate',null); -- may need to depricate, not sure what this is.  53 seconds
-- call WH_update('REBUILD_WH_sales',null); -- drop table, create table, populate table`
-- call WH_update('REBUILD_WH_inventory',null); -- drop table, create table, populate table` 112 sec

-- 274 seconds
-- call WH_update('REBUILD_WH_invoice,REBUILD_WH_sales,REBUILD_WH_splitJob,REBUILD_WH_salesCommission',null); -- drop table, create table, populate table`

DROP procedure IF EXISTS `WH_update`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `WH_update`(
	IN _action varchar(100),
    IN _DEBUG TINYINT
)
WH_update : BEGIN

DECLARE _startTime datetime;
DECLARE _count int;
DECLARE _version varchar(25) DEFAULT '1.0';


-- =========================================================================
-- 137 seconds
if (select LOCATE('REBUILD_WH_logStatus',_action)>0) THEN

DROP table IF EXISTS `WH_logStatus`;

CREATE TABLE `WH_logStatus` (
  `logId` int(11) NOT NULL AUTO_INCREMENT,
  `startTime` datetime DEFAULT NULL,
  `endTime` datetime DEFAULT NULL,
  `logStatus` varchar(25) DEFAULT NULL,
  `recordsProcessed` int(11) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `userId` int(11) DEFAULT NULL,
  `action` varchar(255) DEFAULT NULL,
  `procedureName` varchar(255) DEFAULT NULL,
  `tableName` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`logId`)
) ENGINE=InnoDB AUTO_INCREMENT=182 DEFAULT CHARSET=latin1;

end if;

-- =========================================================================

-- Takes 120 seconds on average.
if (select LOCATE('REBUILD_WH_inventory',_action)>0) THEN

set _startTime = now();

drop table if exists  WH_inventory;

CREATE TABLE WH_inventory AS 
    SELECT 
        `ci`.`cuInvoiceID` AS `cuInvoiceID`,
        `ci`.`joReleaseDetailID` AS `joReleaseDetailID`,
        -- `ci`.`coTaxTerritoryID` AS `coTaxTerritoryID`,
        `ci`.`InvoiceDate` AS `InvoiceDate`,

        `ci`.`InvoiceNumber` AS `InvoiceNumber`,

        -- `taxterr`.`County` AS `County`,
        -- `taxterr`.`State` AS `State`,
        `ci`.`InvoiceAmount` AS `InvoiceAmount`,
        `ci`.`DiscountAmt` AS `DiscountAmt`,
        `ci`.`Subtotal` AS `SubTotal`,
        `ci`.`Freight` AS `Freight`,

        (CASE
            WHEN ISNULL(`ci`.`CostTotal`) THEN 0
            ELSE `ci`.`CostTotal`
        END) AS `CostTotal`,
        (CASE
            WHEN
                ISNULL(`ci`.`cuSOID`)
            THEN
                (CASE
                    WHEN ISNULL(`ci`.`whseCostTotal`) THEN 0
                    ELSE `ci`.`whseCostTotal`
                END)
            ELSE (CASE
                WHEN ISNULL(`so`.`whseCostTotal`) THEN 0
                ELSE `so`.`whseCostTotal`
            END)
        END) AS `whseCostTotal`,
        (CASE
            WHEN ISNULL(`jo`.`cost`) THEN 0
            ELSE `jo`.`cost`
        END) AS `AddCost`,

        `u`.`FullName` AS `CreateBy`,
        `jo`.`enteredBy` AS `AddCostEnteredBy`,
        `jo`.`enteredDate` AS `AddCostEnteredDate`,
        `ci`.`CreatedOn` AS `CreatedOn`,
        `ci`.`ChangedOn` AS `ChangedOn`,
        `ci`.`ChangedByID` AS `ChangedByID`,

        -- `ci`.`memoStatus` AS `memoStatusFlag`,
        -- `ci`.`CreditMemo` AS `CreditMemoFlag`,
        -- `ci`.`IsCredit` AS `IsCreditFlag`,
        `rxm`.`Name` AS `CustomerName`,
        -- `ci`.`PrintDate` AS `PrintDate`,
        -- `ci`.`AppliedAmount` AS `AppliedAmount`,
        -- `ci`.`Description` AS `Description`,
        -- `ci`.`Note` AS `Note`,
        -- `ci`.`CustomerPONumber` AS `PONumber`,
        `j`.`Description` AS `JobDescription`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`JobStatus` AS `JobStatusID`,
        `js`.`JobStatus` AS `JobStatus`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `r`.`ReleaseType` AS `ReleaseType`,
        IFNULL(`rt`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `sp`.`FullName` AS `SalesPersonName`,
        `ci`.`cuAssignmentID0` AS `SalesPersonID`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`,
        `j`.`joMasterID` AS `joMasterID`,
	id.cuInvoiceDetailID,
    id.Description as ItemDescription,
    id.prMasterID,
    id.QuantityBilled,
    id.UnitCost,
    id.UnitPrice,
    id.whseCost,
	p.AverageCost,
    p.InventoryAllocated,
    p.InventoryOnHand,
    p.InventoryOnOrder,
    p.ItemCode,
    p.prCategoryID,
    p.rxMasterIDPrimaryVendor as Vendor_rxMasterID,
	pq.Description as CategoryDesc,
    pq.MarkupAmount,
    pq.MarkupCost,
    rxV.Name as productVendorName
    FROM
        (((((((((((((((((((((`cuInvoice` `ci`
        LEFT JOIN cuInvoiceDetail id ON (id.cuInvoiceID = ci.cuInvoiceID))
        LEFT JOIN prMaster p ON (p.prMasterID = id.prMasterID and p.IsInventory=1 and p.InActive=0))
        LEFT JOIN prCategory pq ON ( p.prCategoryID = pq.prCategoryID and pq.InActive=0))
        LEFT JOIN rxMaster rxV ON (rxV.rxMasterID = p.rxMasterIDPrimaryVendor))
        LEFT JOIN `cuSO` `so` ON ((`ci`.`cuSOID` = `so`.`cuSOID`)))
        LEFT JOIN `tsUserLogin` `u` ON ((`ci`.`CreatedByID` = `u`.`UserLoginID`)))
        LEFT JOIN `joInvoiceCost` `jo` ON ((`ci`.`joReleaseDetailID` = `jo`.`joReleaseDetailID`)))
        -- LEFT JOIN `coTaxTerritory` `taxterr` ON ((`taxterr`.`coTaxTerritoryID` = `ci`.`coTaxTerritoryID`)))
        LEFT JOIN `rxMaster` `rxm` ON ((`rxm`.`rxMasterID` = `ci`.`rxCustomerID`)))
        LEFT JOIN `rxAddress` `rxA` ON ((`rxA`.`rxMasterID` = `ci`.`rxShipToID`)))
        LEFT JOIN `rxAddress` `rxA2` ON ((`rxA2`.`rxAddressID` = `ci`.`rxShipToID`)))
        LEFT JOIN `joReleaseDetail` `rd` ON ((`rd`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `r` ON ((`r`.`joReleaseID` = `rd`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `r`.`joMasterID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
        LEFT JOIN `rxAddress` `rxA1` ON ((`rxA1`.`rxAddressID` = `ci`.`rxShipToAddressID`)))
        LEFT JOIN `joStatus` `js` ON ((`js`.`joStatusID` = `j`.`JobStatus`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `ci`.`coDivisionID`)))
        LEFT JOIN `joReleaseType` `rt` ON ((`r`.`ReleaseType` = `rt`.`joReleaseTypeID`)))
        LEFT JOIN `tsUserLogin` `sp` ON ((`sp`.`UserLoginID` = `ci`.`cuAssignmentID0`)))
        -- where r.ReleaseType in (2,5)
    -- GROUP BY `id`.`cuInvoiceDetailID`;    
        where FALSE;

insert into WH_inventory 
    SELECT 
        `ci`.`cuInvoiceID` AS `cuInvoiceID`,
        `ci`.`joReleaseDetailID` AS `joReleaseDetailID`,
        -- `ci`.`coTaxTerritoryID` AS `coTaxTerritoryID`,
        `ci`.`InvoiceDate` AS `InvoiceDate`,

        `ci`.`InvoiceNumber` AS `InvoiceNumber`,

        -- `taxterr`.`County` AS `County`,
        -- `taxterr`.`State` AS `State`,
        `ci`.`InvoiceAmount` AS `InvoiceAmount`,
        `ci`.`DiscountAmt` AS `DiscountAmt`,
        `ci`.`Subtotal` AS `SubTotal`,
        `ci`.`Freight` AS `Freight`,

        (CASE
            WHEN ISNULL(`ci`.`CostTotal`) THEN 0
            ELSE `ci`.`CostTotal`
        END) AS `CostTotal`,
        (CASE
            WHEN
                ISNULL(`ci`.`cuSOID`)
            THEN
                (CASE
                    WHEN ISNULL(`ci`.`whseCostTotal`) THEN 0
                    ELSE `ci`.`whseCostTotal`
                END)
            ELSE (CASE
                WHEN ISNULL(`so`.`whseCostTotal`) THEN 0
                ELSE `so`.`whseCostTotal`
            END)
        END) AS `whseCostTotal`,
        (CASE
            WHEN ISNULL(`jo`.`cost`) THEN 0
            ELSE `jo`.`cost`
        END) AS `AddCost`,
        `u`.`FullName` AS `CreateBy`,
        `jo`.`enteredBy` AS `AddCostEnteredBy`,
        `jo`.`enteredDate` AS `AddCostEnteredDate`,
        `ci`.`CreatedOn` AS `CreatedOn`,
        `ci`.`ChangedOn` AS `ChangedOn`,
        `ci`.`ChangedByID` AS `ChangedByID`,

        -- `ci`.`memoStatus` AS `memoStatusFlag`,
        -- `ci`.`CreditMemo` AS `CreditMemoFlag`,
        -- `ci`.`IsCredit` AS `IsCreditFlag`,
        `rxm`.`Name` AS `CustomerName`,
        -- `ci`.`PrintDate` AS `PrintDate`,
        -- `ci`.`AppliedAmount` AS `AppliedAmount`,
        -- `ci`.`Description` AS `Description`,
        -- `ci`.`Note` AS `Note`,
        -- `ci`.`CustomerPONumber` AS `PONumber`,
        `j`.`Description` AS `JobDescription`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`JobStatus` AS `JobStatusID`,
        `js`.`JobStatus` AS `JobStatus`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `r`.`ReleaseType` AS `ReleaseType`,
        IFNULL(`rt`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `sp`.`FullName` AS `SalesPersonName`,
        `ci`.`cuAssignmentID0` AS `SalesPersonID`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`,
        `j`.`joMasterID` AS `joMasterID`,
	id.cuInvoiceDetailID,
    id.Description as ItemDescription,
    id.prMasterID,
    id.QuantityBilled,
    id.UnitCost,
    id.UnitPrice,
    id.whseCost,
	p.AverageCost,
    p.InventoryAllocated,
    p.InventoryOnHand,
    p.InventoryOnOrder,
    p.ItemCode,
    p.prCategoryID,
    p.rxMasterIDPrimaryVendor as Vendor_rxMasterID,
	pq.Description as CategoryDesc,
    pq.MarkupAmount,
    pq.MarkupCost,
    rxV.Name as productVendorName
    FROM
		(((((((((((((((((((((`cuInvoice` `ci`
        LEFT JOIN cuInvoiceDetail id ON (id.cuInvoiceID = ci.cuInvoiceID))
        LEFT JOIN prMaster p ON (p.prMasterID = id.prMasterID and p.IsInventory=1 and p.InActive=0))
        LEFT JOIN prCategory pq ON ( p.prCategoryID = pq.prCategoryID and pq.InActive=0))
        LEFT JOIN rxMaster rxV ON (rxV.rxMasterID = p.rxMasterIDPrimaryVendor))
        LEFT JOIN `cuSO` `so` ON ((`ci`.`cuSOID` = `so`.`cuSOID`)))
        LEFT JOIN `tsUserLogin` `u` ON ((`ci`.`CreatedByID` = `u`.`UserLoginID`)))
        LEFT JOIN `joInvoiceCost` `jo` ON ((`ci`.`joReleaseDetailID` = `jo`.`joReleaseDetailID`)))
        -- LEFT JOIN `coTaxTerritory` `taxterr` ON ((`taxterr`.`coTaxTerritoryID` = `ci`.`coTaxTerritoryID`)))
        LEFT JOIN `rxMaster` `rxm` ON ((`rxm`.`rxMasterID` = `ci`.`rxCustomerID`)))
        LEFT JOIN `rxAddress` `rxA` ON ((`rxA`.`rxMasterID` = `ci`.`rxShipToID`)))
        LEFT JOIN `rxAddress` `rxA2` ON ((`rxA2`.`rxAddressID` = `ci`.`rxShipToID`)))
        LEFT JOIN `joReleaseDetail` `rd` ON ((`rd`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `r` ON ((`r`.`joReleaseID` = `rd`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `r`.`joMasterID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
        LEFT JOIN `rxAddress` `rxA1` ON ((`rxA1`.`rxAddressID` = `ci`.`rxShipToAddressID`)))
        LEFT JOIN `joStatus` `js` ON ((`js`.`joStatusID` = `j`.`JobStatus`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `ci`.`coDivisionID`)))
        LEFT JOIN `joReleaseType` `rt` ON ((`r`.`ReleaseType` = `rt`.`joReleaseTypeID`)))
        LEFT JOIN `tsUserLogin` `sp` ON ((`sp`.`UserLoginID` = `ci`.`cuAssignmentID0`)))
        where r.ReleaseType in (2,5)
    GROUP BY `id`.`cuInvoiceDetailID`;    
    -- GROUP BY `ci`.`cuInvoiceID`;

	select count(*) into _count from WH_inventory;

	call WH_log('INSERT',_startTime,now(),_count, null,null,'REBUILD_WH_inventory','WH_update','Success', 'WH_inventory');

END IF;




if (select LOCATE('REBUILD_WH_sales',_action)>0) THEN

set _startTime = now();

drop table if exists  WH_sales;

CREATE TABLE WH_sales AS 
    SELECT a.*
    FROM InvoiceView a  -- base this on the already working InvoiceView
    WHERE FALSE;

insert into WH_sales 
    SELECT 
        `ci`.`cuInvoiceID` AS `cuInvoiceID`,
        `ci`.`joReleaseDetailID` AS `joReleaseDetailID`,
        `ci`.`coTaxTerritoryID` AS `coTaxTerritoryID`,
        `ci`.`InvoiceDate` AS `InvoiceDate`,
        (SELECT 
                `rxMaster`.`Name`
            FROM
                ((`rxMaster`
                LEFT JOIN `vePO` ON ((`vePO`.`rxVendorID` = `rxMaster`.`rxMasterID`)))
                LEFT JOIN `veBill` ON ((`veBill`.`vePOID` = `vePO`.`vePOID`)))
            WHERE
                (`veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)
            LIMIT 1) AS `vendorName`,
        (CASE
            WHEN (`ci`.`ShipToMode` = 1) THEN `rxA2`.`State`
            ELSE (CASE
                WHEN (`ci`.`ShipToMode` = 2) THEN `j`.`LocationState`
                ELSE (CASE
                    WHEN (`ci`.`ShipToMode` = 3) THEN `rxA1`.`State`
                    ELSE CONVERT( (CASE
                        WHEN
                            ((`ci`.`ShipToMode` = 0)
                                AND (`ci`.`veShipViaID` IS NOT NULL))
                        THEN
                            'NV'
                        ELSE NULL
                    END) USING UTF8)
                END)
            END)
        END) AS `ShipToState`,
        `ci`.`InvoiceNumber` AS `InvoiceNumber`,
        (CASE
            WHEN (`ci`.`TransactionStatus` = -(1)) THEN 'Void'
            ELSE (CASE
                WHEN (`ci`.`TransactionStatus` = 0) THEN 'Hold'
                ELSE (CASE
                    WHEN (`ci`.`TransactionStatus` = 1) THEN 'New'
                    ELSE 'Printed'
                END)
            END)
        END) AS `TransactionStatus`,
        `taxterr`.`County` AS `County`,
        `taxterr`.`CountyCode` AS `CountyCode`,
        `taxterr`.`State` AS `State`,
        `ci`.`InvoiceAmount` AS `InvoiceAmount`,
        `ci`.`DiscountAmt` AS `DiscountAmt`,
        `ci`.`Subtotal` AS `SubTotal`,
        `ci`.`Freight` AS `Freight`,
        IFNULL((SELECT 
                        MAX(`veBill`.`BillAmount`) AS `BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)),
                0) AS `InvoiceCostDrop`,
        `taxterr`.`TaxShipping` AS `TaxShippingFlag`,
        IF((`taxterr`.`TaxRate` = 0),
            0,
            (IF((`taxterr`.`TaxShipping` = 1),
                (`ci`.`Subtotal` + `ci`.`Freight`),
                `ci`.`Subtotal`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END))) AS `TaxableSales`,
        IF((`taxterr`.`TaxRate` = 0),
            (IF((`taxterr`.`TaxShipping` = 1),
                (`ci`.`Subtotal` + `ci`.`Freight`),
                (`ci`.`Subtotal` + `ci`.`Freight`)) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)),
            IF(((`ci`.`Subtotal` - IF((`taxterr`.`TaxShipping` = 1),
                    (`ci`.`Subtotal` + `ci`.`Freight`),
                    (`ci`.`Subtotal` + `ci`.`Freight`))) > 1),
                (`ci`.`Subtotal` - IF((`taxterr`.`TaxShipping` = 1),
                    (`ci`.`Subtotal` + `ci`.`Freight`),
                    (`ci`.`Subtotal` + `ci`.`Freight`))),
                0)) AS `NonTaxableSales`,
        `ci`.`TaxRate` AS `TaxRate`,
        (CASE
            WHEN (`ci`.`CreditMemo` = 1) THEN 1
            ELSE 1
        END) AS `ApplyTaxFlag`,
        `ci`.`TaxAmount` AS `TaxAmount`,
        (CASE
            WHEN ISNULL(`ci`.`CostTotal`) THEN 0
            ELSE `ci`.`CostTotal`
        END) AS `CostTotal`,
        (CASE
            WHEN
                ISNULL(`ci`.`cuSOID`)
            THEN
                (CASE
                    WHEN ISNULL(`ci`.`whseCostTotal`) THEN 0
                    ELSE `ci`.`whseCostTotal`
                END)
            ELSE (CASE
                WHEN ISNULL(`so`.`whseCostTotal`) THEN 0
                ELSE `so`.`whseCostTotal`
            END)
        END) AS `whseCostTotal`,
        (CASE
            WHEN ISNULL(`jo`.`cost`) THEN 0
            ELSE `jo`.`cost`
        END) AS `AddCost`,
        FORMAT((((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`TaxRate`) - ((((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution1`) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution2`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution3`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution4`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution5`))) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `StateTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution1`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CityTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution2`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CountyTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution3`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `MTATax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution4`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CCDTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution5`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `OtherTax`,
        `u`.`FullName` AS `CreateBy`,
        `jo`.`enteredBy` AS `AddCostEnteredBy`,
        `jo`.`enteredDate` AS `AddCostEnteredDate`,
        `ci`.`CreatedOn` AS `CreatedOn`,
        `ci`.`ChangedOn` AS `ChangedOn`,
        `ci`.`ChangedByID` AS `ChangedByID`,
        (CASE
            WHEN
                ((`ci`.`memoStatus` = 0)
                    AND (`ci`.`CreditMemo` = 1))
            THEN
                0
            ELSE 1
        END) AS `IsRollbackFlag`,
        `ci`.`memoStatus` AS `memoStatusFlag`,
        `ci`.`CreditMemo` AS `CreditMemoFlag`,
        `ci`.`IsCredit` AS `IsCreditFlag`,
        `taxterr`.`Distribution1` AS `TaxDistribution1`,
        `taxterr`.`Distribution2` AS `TaxDistribution2`,
        `taxterr`.`Distribution3` AS `TaxDistribution3`,
        `taxterr`.`Distribution4` AS `TaxDistribution4`,
        `taxterr`.`Distribution5` AS `TaxDistribution5`,
        `rxm`.`Name` AS `CustomerName`,
        `ci`.`PrintDate` AS `PrintDate`,
        `ci`.`AppliedAmount` AS `AppliedAmount`,
        `ci`.`Description` AS `Description`,
        `ci`.`Note` AS `Note`,
        `ci`.`CustomerPONumber` AS `PONumber`,
        `j`.`Description` AS `JobDescription`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`JobStatus` AS `JobStatusID`,
        `js`.`JobStatus` AS `JobStatus`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `r`.`ReleaseType` AS `ReleaseType`,
        IFNULL(`rt`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `sp`.`FullName` AS `SalesPersonName`,
        `ci`.`cuAssignmentID0` AS `SalesPersonID`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`,
        `j`.`joMasterID` AS `joMasterID`
    FROM
        ((((((((((((((((((`cuInvoice` `ci`
        LEFT JOIN `cuSO` `so` ON ((`ci`.`cuSOID` = `so`.`cuSOID`)))
        LEFT JOIN `tsUserLogin` `u` ON ((`ci`.`CreatedByID` = `u`.`UserLoginID`)))
        LEFT JOIN `joInvoiceCost` `jo` ON ((`ci`.`joReleaseDetailID` = `jo`.`joReleaseDetailID`)))
        LEFT JOIN `coTaxTerritory` `taxterr` ON ((`taxterr`.`coTaxTerritoryID` = `ci`.`coTaxTerritoryID`)))
        LEFT JOIN `rxMaster` `rxm` ON ((`rxm`.`rxMasterID` = `ci`.`rxCustomerID`)))
        LEFT JOIN `rxAddress` `rxA` ON ((`rxA`.`rxMasterID` = `ci`.`rxShipToID`)))
        LEFT JOIN `rxAddress` `rxA2` ON ((`rxA2`.`rxAddressID` = `ci`.`rxShipToID`)))
        LEFT JOIN `joReleaseDetail` `rd` ON ((`rd`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `r` ON ((`r`.`joReleaseID` = `rd`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `r`.`joMasterID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
        LEFT JOIN `rxAddress` `rxA1` ON ((`rxA1`.`rxAddressID` = `ci`.`rxShipToAddressID`)))
        LEFT JOIN `joStatus` `js` ON ((`js`.`joStatusID` = `j`.`JobStatus`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `ci`.`coDivisionID`)))
        LEFT JOIN `joReleaseType` `rt` ON ((`r`.`ReleaseType` = `rt`.`joReleaseTypeID`)))
        LEFT JOIN `tsUserLogin` `sp` ON ((`sp`.`UserLoginID` = `ci`.`cuAssignmentID0`)))
    GROUP BY `ci`.`cuInvoiceID`;
	
	select count(*) into _count from WH_sales;

	call WH_log('INSERT',_startTime,now(),_count, null,null,'REBUILD_WH_sales','WH_update','Success', 'WH_sales');
	
END IF;


-- Takes 120 seconds on average.
if (select LOCATE('REBUILD_WH_invoice',_action)>0) THEN

set _startTime = now();

drop table if exists  WH_invoice;

CREATE TABLE WH_invoice AS 
    SELECT a.*
    FROM InvoiceView a  -- base this on the already working BaseInvoiceView
    WHERE FALSE;

insert into WH_invoice 
    SELECT 
        `ci`.`cuInvoiceID` AS `cuInvoiceID`,
        `ci`.`joReleaseDetailID` AS `joReleaseDetailID`,
        `ci`.`coTaxTerritoryID` AS `coTaxTerritoryID`,
        `ci`.`InvoiceDate` AS `InvoiceDate`,
        (SELECT 
                `rxMaster`.`Name`
            FROM
                ((`rxMaster`
                LEFT JOIN `vePO` ON ((`vePO`.`rxVendorID` = `rxMaster`.`rxMasterID`)))
                LEFT JOIN `veBill` ON ((`veBill`.`vePOID` = `vePO`.`vePOID`)))
            WHERE
                (`veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)
            LIMIT 1) AS `vendorName`,
        (CASE
            WHEN (`ci`.`ShipToMode` = 1) THEN `rxA2`.`State`
            ELSE (CASE
                WHEN (`ci`.`ShipToMode` = 2) THEN `j`.`LocationState`
                ELSE (CASE
                    WHEN (`ci`.`ShipToMode` = 3) THEN `rxA1`.`State`
                    ELSE CONVERT( (CASE
                        WHEN
                            ((`ci`.`ShipToMode` = 0)
                                AND (`ci`.`veShipViaID` IS NOT NULL))
                        THEN
                            'NV'
                        ELSE NULL
                    END) USING UTF8)
                END)
            END)
        END) AS `ShipToState`,
        `ci`.`InvoiceNumber` AS `InvoiceNumber`,
        (CASE
            WHEN (`ci`.`TransactionStatus` = -(1)) THEN 'Void'
            ELSE (CASE
                WHEN (`ci`.`TransactionStatus` = 0) THEN 'Hold'
                ELSE (CASE
                    WHEN (`ci`.`TransactionStatus` = 1) THEN 'New'
                    ELSE 'Printed'
                END)
            END)
        END) AS `TransactionStatus`,
        `taxterr`.`County` AS `County`,
        `taxterr`.`CountyCode` AS `CountyCode`,
        `taxterr`.`State` AS `State`,
        `ci`.`InvoiceAmount` AS `InvoiceAmount`,
        `ci`.`DiscountAmt` AS `DiscountAmt`,
        `ci`.`Subtotal` AS `SubTotal`,
        `ci`.`Freight` AS `Freight`,
        IFNULL((SELECT 
                        MAX(`veBill`.`BillAmount`) AS `BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)),
                0) AS `InvoiceCostDrop`,
        `taxterr`.`TaxShipping` AS `TaxShippingFlag`,
        IF((`taxterr`.`TaxRate` = 0),
            0,
            (IF((`taxterr`.`TaxShipping` = 1),
                (`ci`.`Subtotal` + `ci`.`Freight`),
                `ci`.`Subtotal`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END))) AS `TaxableSales`,
        IF((`taxterr`.`TaxRate` = 0),
            (IF((`taxterr`.`TaxShipping` = 1),
                (`ci`.`Subtotal` + `ci`.`Freight`),
                (`ci`.`Subtotal` + `ci`.`Freight`)) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)),
            IF(((`ci`.`Subtotal` - IF((`taxterr`.`TaxShipping` = 1),
                    (`ci`.`Subtotal` + `ci`.`Freight`),
                    (`ci`.`Subtotal` + `ci`.`Freight`))) > 1),
                (`ci`.`Subtotal` - IF((`taxterr`.`TaxShipping` = 1),
                    (`ci`.`Subtotal` + `ci`.`Freight`),
                    (`ci`.`Subtotal` + `ci`.`Freight`))),
                0)) AS `NonTaxableSales`,
        `ci`.`TaxRate` AS `TaxRate`,
        (CASE
            WHEN (`ci`.`CreditMemo` = 1) THEN 1
            ELSE 1
        END) AS `ApplyTaxFlag`,
        `ci`.`TaxAmount` AS `TaxAmount`,
        (CASE
            WHEN ISNULL(`ci`.`CostTotal`) THEN 0
            ELSE `ci`.`CostTotal`
        END) AS `CostTotal`,
        (CASE
            WHEN
                ISNULL(`ci`.`cuSOID`)
            THEN
                (CASE
                    WHEN ISNULL(`ci`.`whseCostTotal`) THEN 0
                    ELSE `ci`.`whseCostTotal`
                END)
            ELSE (CASE
                WHEN ISNULL(`so`.`whseCostTotal`) THEN 0
                ELSE `so`.`whseCostTotal`
            END)
        END) AS `whseCostTotal`,
        (CASE
            WHEN ISNULL(`jo`.`cost`) THEN 0
            ELSE `jo`.`cost`
        END) AS `AddCost`,
        FORMAT((((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`TaxRate`) - ((((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution1`) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution2`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution3`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution4`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution5`))) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `StateTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution1`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CityTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution2`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CountyTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution3`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `MTATax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution4`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CCDTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution5`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `OtherTax`,
        `u`.`FullName` AS `CreateBy`,
        `jo`.`enteredBy` AS `AddCostEnteredBy`,
        `jo`.`enteredDate` AS `AddCostEnteredDate`,
        `ci`.`CreatedOn` AS `CreatedOn`,
        `ci`.`ChangedOn` AS `ChangedOn`,
        `ci`.`ChangedByID` AS `ChangedByID`,
        (CASE
            WHEN
                ((`ci`.`memoStatus` = 0)
                    AND (`ci`.`CreditMemo` = 1))
            THEN
                0
            ELSE 1
        END) AS `IsRollbackFlag`,
        `ci`.`memoStatus` AS `memoStatusFlag`,
        `ci`.`CreditMemo` AS `CreditMemoFlag`,
        `ci`.`IsCredit` AS `IsCreditFlag`,
        `taxterr`.`Distribution1` AS `TaxDistribution1`,
        `taxterr`.`Distribution2` AS `TaxDistribution2`,
        `taxterr`.`Distribution3` AS `TaxDistribution3`,
        `taxterr`.`Distribution4` AS `TaxDistribution4`,
        `taxterr`.`Distribution5` AS `TaxDistribution5`,
        `rxm`.`Name` AS `CustomerName`,
        `ci`.`PrintDate` AS `PrintDate`,
        `ci`.`AppliedAmount` AS `AppliedAmount`,
        `ci`.`Description` AS `Description`,
        `ci`.`Note` AS `Note`,
        `ci`.`CustomerPONumber` AS `PONumber`,
        `j`.`Description` AS `JobDescription`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`JobStatus` AS `JobStatusID`,
        `js`.`JobStatus` AS `JobStatus`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `r`.`ReleaseType` AS `ReleaseType`,
        IFNULL(`rt`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `sp`.`FullName` AS `SalesPersonName`,
        `ci`.`cuAssignmentID0` AS `SalesPersonID`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`,
        `j`.`joMasterID` AS `joMasterID`
    FROM
        ((((((((((((((((((`cuInvoice` `ci`
        LEFT JOIN `cuSO` `so` ON ((`ci`.`cuSOID` = `so`.`cuSOID`)))
        LEFT JOIN `tsUserLogin` `u` ON ((`ci`.`CreatedByID` = `u`.`UserLoginID`)))
        LEFT JOIN `joInvoiceCost` `jo` ON ((`ci`.`joReleaseDetailID` = `jo`.`joReleaseDetailID`)))
        LEFT JOIN `coTaxTerritory` `taxterr` ON ((`taxterr`.`coTaxTerritoryID` = `ci`.`coTaxTerritoryID`)))
        LEFT JOIN `rxMaster` `rxm` ON ((`rxm`.`rxMasterID` = `ci`.`rxCustomerID`)))
        LEFT JOIN `rxAddress` `rxA` ON ((`rxA`.`rxMasterID` = `ci`.`rxShipToID`)))
        LEFT JOIN `rxAddress` `rxA2` ON ((`rxA2`.`rxAddressID` = `ci`.`rxShipToID`)))
        LEFT JOIN `joReleaseDetail` `rd` ON ((`rd`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `r` ON ((`r`.`joReleaseID` = `rd`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `r`.`joMasterID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
        LEFT JOIN `rxAddress` `rxA1` ON ((`rxA1`.`rxAddressID` = `ci`.`rxShipToAddressID`)))
        LEFT JOIN `joStatus` `js` ON ((`js`.`joStatusID` = `j`.`JobStatus`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `ci`.`coDivisionID`)))
        LEFT JOIN `joReleaseType` `rt` ON ((`r`.`ReleaseType` = `rt`.`joReleaseTypeID`)))
        LEFT JOIN `tsUserLogin` `sp` ON ((`sp`.`UserLoginID` = `ci`.`cuAssignmentID0`)))
    GROUP BY `ci`.`cuInvoiceID`;

	select count(*) into _count from WH_invoice;

	call WH_log('INSERT',_startTime,now(),_count, null,null,'REBUILD_WH_invoice','WH_update','Success', 'WH_invoice');

END IF;



-- Takes 53 seconds on average.
if (select LOCATE('REBUILD_WH_invoice_investigate',_action)>0) THEN

set _startTime = now();

drop table if exists  WH_invoice;

CREATE TABLE WH_invoice AS 
    SELECT a.*
    FROM BaseInvoiceView a  -- base this on the already working BaseInvoiceView
    WHERE FALSE;

insert into WH_invoice 
SELECT DISTINCT
        `cc`.`cuInvoiceID` AS `InvoiceID`,
        `cc`.`InvoiceNumber` AS `InvoiceNumber`,
        `cc`.`InvoiceDate` AS `InvoiceDate`,
        (SELECT 
                `joReleaseDetail`.`joReleaseID`
            FROM
                `joReleaseDetail`
            WHERE
                (`joReleaseDetail`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)) AS `ReleaseId`,
        `cc`.`joReleaseDetailID` AS `ReleasedetailID`,
        `cc`.`InvoiceAmount` AS `InvoiceAmount`,
        IFNULL(`cc`.`DiscountAmt`, 0) AS `Discount`,
        (`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) AS `AmountToBePaid`,
        `cc`.`AppliedAmount` AS `AmountPaid`,
        ((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) AS `CustomerBalance`,
        IF((IFNULL(`em`.`CommAfterPayment`, 1) = 1),
            IF((((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) = 0),
                IF((`cc`.`InvoiceAmount` <> 0),
                    (SELECT 
                            MAX(`cuLinkageDetail`.`datePaid`) AS `datePaid`
                        FROM
                            `cuLinkageDetail`
                        WHERE
                            (`cuLinkageDetail`.`cuInvoiceID` = `cc`.`cuInvoiceID`)),
                    `cc`.`InvoiceDate`),
                NULL),
            (`cc`.`InvoiceDate` + INTERVAL IFNULL(`em`.`dayAfter`, 0) DAY)) AS `CustomerDatePaid`,
        IFNULL(`cc`.`FreightCost`, 0) AS `AddCostTotal`,
        `cc`.`cuAssignmentID0` AS `SalesPerson`,
        `cc`.`cuAssignmentID0` AS `SalesPersonID`,
        (SELECT 
                `tsUserLogin`.`FullName`
            FROM
                `tsUserLogin`
            WHERE
                (`tsUserLogin`.`UserLoginID` = `cc`.`cuAssignmentID0`)) AS `SalesPersonName`,
        `cc`.`Subtotal` AS `InvoiceSubtotal`,
        `cc`.`Freight` AS `Freight`,
        IFNULL(`cc`.`CostTotal`, 0) AS `InvoiceCostStock`,
        (IFNULL((SELECT 
                        `veBill`.`BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)),
                0) + IFNULL((SELECT 
                        SUM(`veBill`.`BillAmount`)
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`cuInvoiceID_ApplyCost` = `cc`.`cuInvoiceID`)
                    GROUP BY `veBill`.`cuInvoiceID_ApplyCost`),
                0)) AS `InvoiceCostDrop`,
        IFNULL(`v`.`FreightAmount`, 0) AS `InvoiceCostDropFreight`,
        IF((`v`.`UsePostDate` = 0),
            IFNULL(`v`.`BillDate`, 0),
            IFNULL(`v`.`PostDate`, 0)) AS `BillDate`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`Description` AS `JobName`,
        `cc`.`memoStatus` AS `Info_memoStatus`,
        `cc`.`CreditMemo` AS `Info_CreditMemo`,
        `cc`.`rxCustomerID` AS `Info_rxCustomerID`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `crx`.`Name` AS `CustomerName`,
        `cc`.`cuInvoiceID` AS `Info_cuInvoiceID`,
        `jr`.`ReleaseType` AS `Info_ReleaseType`,
        `jr`.`joMasterID` AS `joMasterID`,
        `em`.`isJobPaidInFull` AS `isJobPaidInFull`,
        `em`.`UserLoginID` AS `UserLoginID`,
        `em`.`emMasterID` AS `emMasterID`,
        `eS`.`joMasterID` AS `esjoMasterID`,
        IFNULL(`eS`.`joReleaseID`,
                IF(ISNULL(`eS`.`IsRelease`),
                    10102,
                    10101)) AS `esJoReleaseID`,
        `eS`.`IsRelease` AS `esIsRelease`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`
        
    FROM ((
        ((((((((`cuInvoice` `cc`
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `joReleaseDetail` `jrd` ON ((`cc`.`joReleaseDetailID` = `jrd`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `jr` ON ((`jr`.`joReleaseID` = `jrd`.`joReleaseID`)))
        LEFT JOIN `ecSplitJob` `eS` ON ((`jr`.`joReleaseID` = `eS`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `jr`.`joMasterID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory2` `rxmc1` ON ((`rxmc1`.`rxMasterCategory2ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`))
        
    WHERE
        ((`em`.`isJobPaidInFull` = 0)
            AND (`cc`.`InvoiceDate` >= '2017-10-01')
            AND (`cc`.`joReleaseDetailID` IS NOT NULL)) 
    UNION ALL SELECT DISTINCT
        `cc`.`cuInvoiceID` AS `InvoiceID`,
        `cc`.`InvoiceNumber` AS `InvoiceNumber`,
        `cc`.`InvoiceDate` AS `InvoiceDate`,
        (SELECT 
                `joReleaseDetail`.`joReleaseID`
            FROM
                `joReleaseDetail`
            WHERE
                (`joReleaseDetail`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)) AS `ReleaseId`,
        `cc`.`joReleaseDetailID` AS `ReleasedetailID`,
        `cc`.`InvoiceAmount` AS `InvoiceAmount`,
        IFNULL(`cc`.`DiscountAmt`, 0) AS `Discount`,
        (`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) AS `AmountToBePaid`,
        `cc`.`AppliedAmount` AS `AmountPaid`,
        ((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) AS `CustomerBalance`,
        IF((IFNULL(`em`.`isFollowingPeriod`, 1) = 0),
            IF((((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) = 0),
                IF((`cc`.`InvoiceAmount` <> 0),
                    (SELECT 
                            MAX(`cuLinkageDetail`.`datePaid`) AS `datePaid`
                        FROM
                            `cuLinkageDetail`
                        WHERE
                            (`cuLinkageDetail`.`cuInvoiceID` = `cc`.`cuInvoiceID`)),
                    `cc`.`InvoiceDate`),
                NULL),
            (`cc`.`InvoiceDate` + INTERVAL 30 DAY)) AS `CustomerDatePaid`,
        IFNULL(`cc`.`FreightCost`, 0) AS `AddCostTotal`,
        `cc`.`cuAssignmentID0` AS `SalesPerson`,
        `cc`.`cuAssignmentID0` AS `SalesPersonID`,
        (SELECT 
                `tsUserLogin`.`FullName`
            FROM
                `tsUserLogin`
            WHERE
                (`tsUserLogin`.`UserLoginID` = `cc`.`cuAssignmentID0`)) AS `SalesPersonName`,
        `cc`.`Subtotal` AS `InvoiceSubtotal`,
        `cc`.`Freight` AS `Freight`,
        IFNULL(`cc`.`CostTotal`, 0) AS `InvoiceCostStock`,
        (IFNULL((SELECT 
                        `veBill`.`BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)),
                0) + IFNULL((SELECT 
                        SUM(`veBill`.`BillAmount`)
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`cuInvoiceID_ApplyCost` = `cc`.`cuInvoiceID`)
                    GROUP BY `veBill`.`cuInvoiceID_ApplyCost`),
                0)) AS `InvoiceCostDrop`,
        IFNULL(`v`.`FreightAmount`, 0) AS `InvoiceCostDropFreight`,
        IF((`v`.`UsePostDate` = 0),
            IFNULL(`v`.`BillDate`, 0),
            IFNULL(`v`.`PostDate`, 0)) AS `BillDate`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`Description` AS `JobName`,
        `cc`.`memoStatus` AS `Info_memoStatus`,
        `cc`.`CreditMemo` AS `Info_CreditMemo`,
        `cc`.`rxCustomerID` AS `Info_rxCustomerID`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `crx`.`Name` AS `CustomerName`,
        `cc`.`cuInvoiceID` AS `Info_cuInvoiceID`,
        `jr`.`ReleaseType` AS `Info_ReleaseType`,
        `jr`.`joMasterID` AS `joMasterID`,
        `em`.`isJobPaidInFull` AS `isJobPaidInFull`,
        `em`.`UserLoginID` AS `UserLoginID`,
        `em`.`emMasterID` AS `emMasterID`,
        `eS`.`joMasterID` AS `esjoMasterID`,
        IFNULL(`eS`.`joReleaseID`,
                IF(ISNULL(`eS`.`IsRelease`),
                    10102,
                    10101)) AS `esJoReleaseID`,
        `eS`.`IsRelease` AS `esIsRelease`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`
        
    FROM ((
        (((((((((`JobCustomerInvoiceInsideView` `tb2`
        LEFT JOIN `cuInvoice` `cc` ON ((`tb2`.`cuInvoiceID` = `cc`.`cuInvoiceID`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `joReleaseDetail` `jrd` ON ((`cc`.`joReleaseDetailID` = `jrd`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `jr` ON ((`jr`.`joReleaseID` = `jrd`.`joReleaseID`)))
        LEFT JOIN `ecSplitJob` `eS` ON ((`jr`.`joReleaseID` = `eS`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `tb2`.`joMasterID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`))
    WHERE
        ((`em`.`isJobPaidInFull` = 1)
            AND (`cc`.`InvoiceDate` >= '2017-10-01')
            AND (`cc`.`joReleaseDetailID` IS NOT NULL)) 
 
    UNION ALL SELECT DISTINCT
        `cc`.`cuInvoiceID` AS `InvoiceID`,
        `cc`.`InvoiceNumber` AS `InvoiceNumber`,
        `cc`.`InvoiceDate` AS `InvoiceDate`,
        0 AS `ReleaseId`,
        `cc`.`joReleaseDetailID` AS `ReleasedetailID`,
        `cc`.`InvoiceAmount` AS `InvoiceAmount`,
        IFNULL(`cc`.`DiscountAmt`, 0) AS `Discount`,
        (`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) AS `AmountToBePaid`,
        `cc`.`AppliedAmount` AS `AmountPaid`,
        ((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) AS `CustomerBalance`,
        IF((IFNULL(`em`.`CommAfterPayment`, 1) = 1),
            IF((((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) = 0),
                IF((`cc`.`InvoiceAmount` <> 0),
                    (SELECT 
                            MAX(`cuLinkageDetail`.`datePaid`) AS `datePaid`
                        FROM
                            `cuLinkageDetail`
                        WHERE
                            (`cuLinkageDetail`.`cuInvoiceID` = `cc`.`cuInvoiceID`)),
                    `cc`.`InvoiceDate`),
                NULL),
            (`cc`.`InvoiceDate` + INTERVAL IFNULL(`em`.`dayAfter`, 0) DAY)) AS `CustomerDatePaid`,
        IFNULL(`cc`.`FreightCost`, 0) AS `AddCostTotal`,
        `cc`.`cuAssignmentID0` AS `SalesPerson`,
        `cc`.`cuAssignmentID0` AS `SalesPersonID`,
        (SELECT 
                `tsUserLogin`.`FullName`
            FROM
                `tsUserLogin`
            WHERE
                (`tsUserLogin`.`UserLoginID` = `cc`.`cuAssignmentID0`)) AS `SalesPersonName`,
        `cc`.`Subtotal` AS `InvoiceSubtotal`,
        `cc`.`Freight` AS `Freight`,
        IFNULL(`cc`.`CostTotal`, 0) AS `InvoiceCostStock`,
        0.0000 AS `InvoiceCostDrop`,
        IFNULL(`v`.`FreightAmount`, 0) AS `InvoiceCostDropFreight`,
        0 AS `BillDate`,
        NULL AS `JobNumber`,
        NULL AS `JobName`,
        `cc`.`memoStatus` AS `Info_memoStatus`,
        `cc`.`CreditMemo` AS `Info_CreditMemo`,
        `cc`.`rxCustomerID` AS `Info_rxCustomerID`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `crx`.`Name` AS `CustomerName`,
        `cc`.`cuInvoiceID` AS `Info_cuInvoiceID`,
        NULL AS `Info_ReleaseType`,
        NULL AS `joMasterID`,
        `em`.`isJobPaidInFull` AS `isJobPaidInFull`,
        `em`.`UserLoginID` AS `UserLoginID`,
        `em`.`emMasterID` AS `emMasterID`,
        0 AS `esjoMasterID`,
        0 AS `esJoReleaseID`,
        0 AS `esIsRelease`,
        null AS `Engineer`,
        null AS `SalesEngineer`
         
    FROM
        ((((`OutsidejobView` `cc`
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
    WHERE
        ((`em`.`isJobPaidInFull` = 1)
            AND (`cc`.`InvoiceDate` >= '2017-10-01')
            AND (`cc`.`joReleaseDetailID` = 0));


	select count(*) into _count from WH_invoice;

	call WH_log('INSERT',_startTime,now(),_count, null,null,'REBUILD_WH_invoice_investigate','WH_update','Success', 'WH_invoice');

END IF;


 -- 30 seconds
if (select LOCATE('REBUILD_WH_splitJob',_action)>0) THEN

set _startTime = now();

drop table if exists WH_splitJob;

CREATE TABLE WH_splitJob AS 
    SELECT 
		BaseInvoiceView.*,
        (SELECT 
                `emMaster`.`CommissionJobProfit`
            FROM
                `emMaster`
            WHERE
                (`emMaster`.`UserLoginID` = `BaseInvoiceView`.`SalesPersonID`)
            LIMIT 0 , 1) AS `commissionJobProfit`,
        `ecSplitJob`.`ecSplitJobID` AS `ecSplitJobID`,
        -- `ecSplitJob`.`joMasterID` AS `joMasterID`,
        `ecSplitJob`.`rxMasterID` AS `rxMasterID`,
        `ecSplitJob`.`joReleaseID` AS `joReleaseId`,
        IFNULL(`ecSplitJob`.`Allocated`, 100) AS `Allocated`,
        IF((MONTH(`BaseInvoiceView`.`InvoiceDate`) < MONTH(`BaseInvoiceView`.`BillDate`)),
            IFNULL(((0.00 - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),
                    0),
            IFNULL((((`BaseInvoiceView`.`InvoiceSubtotal` + `BaseInvoiceView`.`Freight`) - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),
                    0)) AS `CalcRawInvoiceProfit`,
        (SELECT 
                `c`.`CodeName`
            FROM
                `ecSplitCode` `c`
            WHERE
                (`c`.`ecSplitCodeID` = `ecSplitJob`.`ecSplitCodeID`)) AS `splitType`,
        `ecSplitJob`.`ecSplitCodeID` AS `ecSplitCodeID`,
        `ecSplitJob`.`ChangedByID` AS `ChangedByID`,
        `ecSplitJob`.`ChangedOn` AS `ChangedOn`,
        IF(ISNULL(`ecSplitJob`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPerson`,
            `emMaster`.`UserLoginID`) AS `SplitUserID`,
        IF(ISNULL(`ecSplitJob`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPersonName`,
            CONVERT( `rxMaster`.`Name` USING UTF8)) AS `SplitUserName`,
        `ecSplitJob`.`IsRelease` AS `IsRelease`
        -- `BaseInvoiceView`.`Engineer` AS `Engineer`,
        -- `BaseInvoiceView`.`SalesEngineer` AS `SalesEngineer`
    FROM
        (((`WH_invoice` as BaseInvoiceView
        LEFT JOIN `ecSplitJob` ON ((`BaseInvoiceView`.`esJoReleaseID` = `ecSplitJob`.`joReleaseID`)))
        LEFT JOIN `emMaster` ON ((`emMaster`.`emMasterID` = `ecSplitJob`.`rxMasterID`)))
        LEFT JOIN `rxMaster` ON ((`ecSplitJob`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
    WHERE FALSE;
    
    
insert into WH_splitJob 
    SELECT 
		BaseInvoiceView.*,
        (SELECT 
                `emMaster`.`CommissionJobProfit`
            FROM
                `emMaster`
            WHERE
                (`emMaster`.`UserLoginID` = `BaseInvoiceView`.`SalesPersonID`)
            LIMIT 0 , 1) AS `commissionJobProfit`,
        `ecSplitJob`.`ecSplitJobID` AS `ecSplitJobID`,
        -- `ecSplitJob`.`joMasterID` AS `joMasterID`,
        `ecSplitJob`.`rxMasterID` AS `rxMasterID`,
        `ecSplitJob`.`joReleaseID` AS `joReleaseId`,
        IFNULL(`ecSplitJob`.`Allocated`, 100) AS `Allocated`,
        IF((MONTH(`BaseInvoiceView`.`InvoiceDate`) < MONTH(`BaseInvoiceView`.`BillDate`)),
            IFNULL(((0.00 - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),
                    0),
            IFNULL((((`BaseInvoiceView`.`InvoiceSubtotal` + `BaseInvoiceView`.`Freight`) - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),
                    0)) AS `CalcRawInvoiceProfit`,
        (SELECT 
                `c`.`CodeName`
            FROM
                `ecSplitCode` `c`
            WHERE
                (`c`.`ecSplitCodeID` = `ecSplitJob`.`ecSplitCodeID`)) AS `splitType`,
        `ecSplitJob`.`ecSplitCodeID` AS `ecSplitCodeID`,
        `ecSplitJob`.`ChangedByID` AS `ChangedByID`,
        `ecSplitJob`.`ChangedOn` AS `ChangedOn`,
        IF(ISNULL(`ecSplitJob`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPerson`,
            `emMaster`.`UserLoginID`) AS `SplitUserID`,
        IF(ISNULL(`ecSplitJob`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPersonName`,
            CONVERT( `rxMaster`.`Name` USING UTF8)) AS `SplitUserName`,
        `ecSplitJob`.`IsRelease` AS `IsRelease`
        -- `BaseInvoiceView`.`Engineer` AS `Engineer`,
        -- `BaseInvoiceView`.`SalesEngineer` AS `SalesEngineer`
    FROM
        (((`WH_invoice` as BaseInvoiceView
        LEFT JOIN `ecSplitJob` ON ((`BaseInvoiceView`.`esJoReleaseID` = `ecSplitJob`.`joReleaseID`)))
        LEFT JOIN `emMaster` ON ((`emMaster`.`emMasterID` = `ecSplitJob`.`rxMasterID`)))
        LEFT JOIN `rxMaster` ON ((`ecSplitJob`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
    WHERE
        (`ecSplitJob`.`IsRelease` = 1) 
    UNION ALL SELECT 
        `BaseInvoiceView`.*,
        (SELECT 
                `emMaster`.`CommissionJobProfit`
            FROM
                `emMaster`
            WHERE
                (`emMaster`.`UserLoginID` = `BaseInvoiceView`.`SalesPersonID`)
            LIMIT 0 , 1) AS `commissionJobProfit`,
        `ecSplitJob`.`ecSplitJobID` AS `ecSplitJobID`,
        -- `ecSplitJob`.`joMasterID` AS `joMasterID`,
        `ecSplitJob`.`rxMasterID` AS `rxMasterID`,
        `ecSplitJob`.`joReleaseID` AS `joReleaseId`,
        IFNULL(`ecSplitJob`.`Allocated`, 100) AS `Allocated`,
        IF((MONTH(`BaseInvoiceView`.`InvoiceDate`) < MONTH(`BaseInvoiceView`.`BillDate`)),
            IFNULL(((0.00 - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),
                    0),
            IFNULL((((`BaseInvoiceView`.`InvoiceSubtotal` + `BaseInvoiceView`.`Freight`) - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),
                    0)) AS `CalcRawInvoiceProfit`,
        (SELECT 
                `c`.`CodeName`
            FROM
                `ecSplitCode` `c`
            WHERE
                (`c`.`ecSplitCodeID` = `ecSplitJob`.`ecSplitCodeID`)) AS `splitType`,
        `ecSplitJob`.`ecSplitCodeID` AS `ecSplitCodeID`,
        `ecSplitJob`.`ChangedByID` AS `ChangedByID`,
        `ecSplitJob`.`ChangedOn` AS `ChangedOn`,
        IF(ISNULL(`ecSplitJob`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPerson`,
            `emMaster`.`UserLoginID`) AS `SplitUserID`,
        IF(ISNULL(`ecSplitJob`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPersonName`,
            CONVERT( `rxMaster`.`Name` USING UTF8)) AS `SplitUserName`,
        `ecSplitJob`.`IsRelease` AS `IsRelease`
        -- `BaseInvoiceView`.`Engineer` AS `Engineer`,
        -- `BaseInvoiceView`.`SalesEngineer` AS `SalesEngineer`
    FROM
        (((WH_invoice as `BaseInvoiceView`
        LEFT JOIN `ecSplitJob` ON ((`BaseInvoiceView`.`joMasterID` = `ecSplitJob`.`joMasterID`)))
        LEFT JOIN `emMaster` ON ((`emMaster`.`emMasterID` = `ecSplitJob`.`rxMasterID`)))
        LEFT JOIN `rxMaster` ON ((`ecSplitJob`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
    WHERE
        ((`BaseInvoiceView`.`esJoReleaseID` = 10102)
            AND (`ecSplitJob`.`IsRelease` = 0));


	select count(*) into _count from WH_splitJob;

	call WH_log('INSERT',_startTime,now(),_count, null,null,'REBUILD_WH_splitJob','WH_update','Success', 'WH_splitJob');


END IF;

-- 30 seconds
if (select LOCATE('REBUILD_WH_salesCommission',_action)>0) THEN

set _startTime = now();

drop table if exists WH_salesCommission;

CREATE TABLE WH_salesCommission AS 
    SELECT 
        'Invoice' AS `RecordType`,
        IF((`bjs`.`InvoiceAmount` = 0),
            'Paid',
            IF(ISNULL(`bjs`.`CustomerDatePaid`),
                'Balance',
                'Paid')) AS `CustomerStatus`,
        `bjs`.`JobNumber` AS `JobNumber`,
        `bjs`.`JobName` AS `JobName`,
        `bjs`.`InvoiceNumber` AS `InvoiceNumber`,
        IFNULL(`joReleaseType`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `bjs`.`InvoiceDate` AS `InvoiceDate`,
        `bjs`.`InvoiceSubtotal` AS `InvoiceSubtotal`,
        `bjs`.`Freight` AS `InvoiceFreight`,
        `bjs`.`InvoiceCostStock` AS `InvoiceCostStock`,
        `bjs`.`InvoiceCostDrop` AS `InvoiceCostDrop`,
        `bjs`.`InvoiceCostDropFreight` AS `InvoiceCostDropFreight`,
        `bjs`.`InvoiceAmount` AS `InvoiceAmount`,
        `bjs`.`Discount` AS `InvoiceDiscount`,
        `bjs`.`AmountToBePaid` AS `InvoiceToBePaid`,
        `bjs`.`AmountPaid` AS `InvoicePaid`,
        `bjs`.`CustomerBalance` AS `CustomerBalance`,
        IF((`bjs`.`InvoiceAmount` = 0),
            `bjs`.`InvoiceDate`,
            `bjs`.`CustomerDatePaid`) AS `CustomerPaidDate`,
        `bjs`.`AddCostTotal` AS `AddCostTotals`,
        `bjs`.`SalesPersonName` AS `SalesRepAssigned`,
        `bjs`.`Info_memoStatus` AS `info_memoStatus`,
        `bjs`.`Info_CreditMemo` AS `info_CreditMemo`,
        IFNULL(`bjs`.`Info_rxCustomerID`, 0) AS `info_rxCustomerID`,
        IFNULL(`bjs`.`Info_cuInvoiceID`, 0) AS `info_cuInvoiceID`,
        NULL AS `info_veCommDetailID`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`ecInvoicePeriodID`)
            FROM
                `ecInvoicePeriod`
            WHERE
                (`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)) AS `info_ecInvoicePeriodID`,
        `bjs`.`ecSplitJobID` AS `info_ecSplitjobID`,
        `bjs`.`joReleaseId` AS `info_joReleaseID`,
        IFNULL(`bjs`.`SplitUserID`, 0) AS `info_userLoginID`,
        IFNULL(`bjs`.`Info_ReleaseType`, -(1)) AS `ReleaseTypes`,
        `bjs`.`ReleasedetailID` AS `Info_ReleasedetailID`,
        0 AS `info_joInvoiceCostID`,
        IFNULL((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`),
                0) AS `CalcRawInvoiceProfit`,
        IFNULL(`bjs`.`commissionJobProfit`, 0) AS `SalesRepJobProfit`,
        IFNULL((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100),
                0) AS `CalcRevShare`,
        IFNULL((((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) * IFNULL(`bjs`.`Allocated`, 100)) / 100),
                0) AS `CalcSplitRev`,
        IFNULL(`bjs`.`splitType`, 'N/A') AS `CommSplitType`,
        IFNULL(`bjs`.`Allocated`, 100) AS `CommPercent`,
        `bjs`.`ChangedOn` AS `CommSplitChangedOn`,
        `bjs`.`SplitUserName` AS `CommSalesRep`,
        `bjs`.`CustomerDatePaid` AS `CommAvailableDate`,
        IF(((SELECT 
                    COUNT(0)
                FROM
                    `ecInvoicePeriod`
                WHERE
                    ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                        AND ((`ecInvoicePeriod`.`ecType` = 'I')
                        OR (`ecInvoicePeriod`.`ecType` = 'IA')))) = 0),
            'No',
            'Yes') AS `IsCommPaid`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`DatePaid`)
            FROM
                `ecInvoicePeriod`
            WHERE
                ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                    AND ((`ecInvoicePeriod`.`ecType` = 'I')
                    OR (`ecInvoicePeriod`.`ecType` = 'IA')))) AS `CommPaidDate`,
        CAST((SELECT 
                    MAX(`ecInvoicePeriod`.`enteredDate`)
                FROM
                    `ecInvoicePeriod`
                WHERE
                    ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                        AND ((`ecInvoicePeriod`.`ecType` = 'I')
                        OR (`ecInvoicePeriod`.`ecType` = 'IA'))))
            AS DATE) AS `CommEnteredDate`,
        `bjs`.`coDivisionID` AS `coDivisionID`,
        `bjs`.`DivDescription` AS `DivDescription`,
        `bjs`.`DivCode` AS `DivCode`,
        `bjs`.`CustomerName` AS `CustomerName`,
        NULL AS `joMasterID`,
        NULL AS `veBillID`,
        IFNULL(`rM`.`Name`,
                (SELECT 
                        `rxMaster`.`Name`
                    FROM
                        `rxMaster`
                    WHERE
                        (`rxMaster`.`rxMasterID` = `vP`.`rxVendorID`))) AS `VendorName`,
        `bjs`.`Engineer` AS `Engineer`,
        `bjs`.`SalesEngineer` AS `SalesEngineer`
    FROM
        ((((`WH_splitJob` `bjs`
        LEFT JOIN `joReleaseType` ON ((`bjs`.`Info_ReleaseType` = `joReleaseType`.`joReleaseTypeID`)))
        LEFT JOIN `cuSO` `cO` ON ((`cO`.`joReleaseID` = `bjs`.`ReleaseId`)))
        LEFT JOIN `rxMaster` `rM` ON ((`cO`.`rxCustomerID` = `rM`.`rxMasterID`)))
        LEFT JOIN `vePO` `vP` ON ((`vP`.`joReleaseID` = `bjs`.`ReleaseId`))) 
	where FALSE;
    

insert into  WH_salesCommission  
    SELECT 
        'Invoice' AS `RecordType`,
        IF((`bjs`.`InvoiceAmount` = 0),
            'Paid',
            IF(ISNULL(`bjs`.`CustomerDatePaid`),
                'Balance',
                'Paid')) AS `CustomerStatus`,
        `bjs`.`JobNumber` AS `JobNumber`,
        `bjs`.`JobName` AS `JobName`,
        `bjs`.`InvoiceNumber` AS `InvoiceNumber`,
        IFNULL(`joReleaseType`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `bjs`.`InvoiceDate` AS `InvoiceDate`,
        `bjs`.`InvoiceSubtotal` AS `InvoiceSubtotal`,
        `bjs`.`Freight` AS `InvoiceFreight`,
        `bjs`.`InvoiceCostStock` AS `InvoiceCostStock`,
        `bjs`.`InvoiceCostDrop` AS `InvoiceCostDrop`,
        `bjs`.`InvoiceCostDropFreight` AS `InvoiceCostDropFreight`,
        `bjs`.`InvoiceAmount` AS `InvoiceAmount`,
        `bjs`.`Discount` AS `InvoiceDiscount`,
        `bjs`.`AmountToBePaid` AS `InvoiceToBePaid`,
        `bjs`.`AmountPaid` AS `InvoicePaid`,
        `bjs`.`CustomerBalance` AS `CustomerBalance`,
        IF((`bjs`.`InvoiceAmount` = 0),
            `bjs`.`InvoiceDate`,
            `bjs`.`CustomerDatePaid`) AS `CustomerPaidDate`,
        `bjs`.`AddCostTotal` AS `AddCostTotals`,
        `bjs`.`SalesPersonName` AS `SalesRepAssigned`,
        `bjs`.`Info_memoStatus` AS `info_memoStatus`,
        `bjs`.`Info_CreditMemo` AS `info_CreditMemo`,
        IFNULL(`bjs`.`Info_rxCustomerID`, 0) AS `info_rxCustomerID`,
        IFNULL(`bjs`.`Info_cuInvoiceID`, 0) AS `info_cuInvoiceID`,
        NULL AS `info_veCommDetailID`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`ecInvoicePeriodID`)
            FROM
                `ecInvoicePeriod`
            WHERE
                (`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)) AS `info_ecInvoicePeriodID`,
        `bjs`.`ecSplitJobID` AS `info_ecSplitjobID`,
        `bjs`.`joReleaseId` AS `info_joReleaseID`,
        IFNULL(`bjs`.`SplitUserID`, 0) AS `info_userLoginID`,
        IFNULL(`bjs`.`Info_ReleaseType`, -(1)) AS `ReleaseTypes`,
        `bjs`.`ReleasedetailID` AS `Info_ReleasedetailID`,
        0 AS `info_joInvoiceCostID`,
        IFNULL((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`),
                0) AS `CalcRawInvoiceProfit`,
        IFNULL(`bjs`.`commissionJobProfit`, 0) AS `SalesRepJobProfit`,
        IFNULL((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100),
                0) AS `CalcRevShare`,
        IFNULL((((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) * IFNULL(`bjs`.`Allocated`, 100)) / 100),
                0) AS `CalcSplitRev`,
        IFNULL(`bjs`.`splitType`, 'N/A') AS `CommSplitType`,
        IFNULL(`bjs`.`Allocated`, 100) AS `CommPercent`,
        `bjs`.`ChangedOn` AS `CommSplitChangedOn`,
        `bjs`.`SplitUserName` AS `CommSalesRep`,
        `bjs`.`CustomerDatePaid` AS `CommAvailableDate`,
        IF(((SELECT 
                    COUNT(0)
                FROM
                    `ecInvoicePeriod`
                WHERE
                    ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                        AND ((`ecInvoicePeriod`.`ecType` = 'I')
                        OR (`ecInvoicePeriod`.`ecType` = 'IA')))) = 0),
            'No',
            'Yes') AS `IsCommPaid`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`DatePaid`)
            FROM
                `ecInvoicePeriod`
            WHERE
                ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                    AND ((`ecInvoicePeriod`.`ecType` = 'I')
                    OR (`ecInvoicePeriod`.`ecType` = 'IA')))) AS `CommPaidDate`,
        CAST((SELECT 
                    MAX(`ecInvoicePeriod`.`enteredDate`)
                FROM
                    `ecInvoicePeriod`
                WHERE
                    ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                        AND ((`ecInvoicePeriod`.`ecType` = 'I')
                        OR (`ecInvoicePeriod`.`ecType` = 'IA'))))
            AS DATE) AS `CommEnteredDate`,
        `bjs`.`coDivisionID` AS `coDivisionID`,
        `bjs`.`DivDescription` AS `DivDescription`,
        `bjs`.`DivCode` AS `DivCode`,
        `bjs`.`CustomerName` AS `CustomerName`,
        NULL AS `joMasterID`,
        NULL AS `veBillID`,
        IFNULL(`rM`.`Name`,
                (SELECT 
                        `rxMaster`.`Name`
                    FROM
                        `rxMaster`
                    WHERE
                        (`rxMaster`.`rxMasterID` = `vP`.`rxVendorID`))) AS `VendorName`,
        `bjs`.`Engineer` AS `Engineer`,
        `bjs`.`SalesEngineer` AS `SalesEngineer`
    FROM
        ((((`WH_splitJob` `bjs`
        LEFT JOIN `joReleaseType` ON ((`bjs`.`Info_ReleaseType` = `joReleaseType`.`joReleaseTypeID`)))
        LEFT JOIN `cuSO` `cO` ON ((`cO`.`joReleaseID` = `bjs`.`ReleaseId`)))
        LEFT JOIN `rxMaster` `rM` ON ((`cO`.`rxCustomerID` = `rM`.`rxMasterID`)))
        LEFT JOIN `vePO` `vP` ON ((`vP`.`joReleaseID` = `bjs`.`ReleaseId`))) 
    UNION ALL SELECT 
        'AddCost' AS `RecordType`,
        IF((`bjs`.`InvoiceAmount` = 0),
            'Paid',
            IF(ISNULL(`bjs`.`CustomerDatePaid`),
                'Balance',
                'Paid')) AS `CustomerStatus`,
        `bjs`.`JobNumber` AS `JobNumber`,
        `bjs`.`JobName` AS `JobName`,
        `bjs`.`InvoiceNumber` AS `InvoiceNumber`,
        IFNULL(`joReleaseType`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `bjs`.`InvoiceDate` AS `InvoiceDate`,
        `bjs`.`InvoiceSubtotal` AS `InvoiceSubtotal`,
        `bjs`.`Freight` AS `InvoiceFreight`,
        `bjs`.`InvoiceCostStock` AS `InvoiceCostStock`,
        `bjs`.`InvoiceCostDrop` AS `InvoiceCostDrop`,
        `bjs`.`InvoiceCostDropFreight` AS `InvoiceCostDropFreight`,
        `bjs`.`InvoiceAmount` AS `InvoiceAmount`,
        `bjs`.`Discount` AS `InvoiceDiscount`,
        `bjs`.`AmountToBePaid` AS `InvoiceToBePaid`,
        `bjs`.`AmountPaid` AS `InvoicePaid`,
        `bjs`.`CustomerBalance` AS `CustomerBalance`,
        `bjs`.`CustomerDatePaid` AS `CustomerPaidDate`,
        `bjs`.`AddCostTotal` AS `AddCostTotals`,
        `bjs`.`SalesPersonName` AS `SalesRepAssigned`,
        `bjs`.`Info_memoStatus` AS `info_memoStatus`,
        `bjs`.`Info_CreditMemo` AS `info_CreditMemo`,
        IFNULL(`bjs`.`Info_rxCustomerID`, 0) AS `info_rxCustomerID`,
        IFNULL(`bjs`.`Info_cuInvoiceID`, 0) AS `info_cuInvoiceID`,
        NULL AS `info_veCommDetailID`,
        `jic`.`ecInvoicePeriodID` AS `info_ecInvoicePeriodID`,
        `bjs`.`ecSplitJobID` AS `info_ecSplitjobID`,
        `bjs`.`joReleaseId` AS `info_joReleaseID`,
        IFNULL(`bjs`.`SplitUserID`, 0) AS `info_userLoginID`,
        IFNULL(`bjs`.`Info_ReleaseType`, -(1)) AS `ReleaseTypes`,
        `bjs`.`ReleasedetailID` AS `Info_ReleasedetailID`,
        `jic`.`joInvoiceCostID` AS `info_joInvoiceCostID`,
        IFNULL((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) - `jic`.`cost`) - (((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`)),
                0) AS `CalcRawInvoiceProfit`,
        IFNULL(`bjs`.`commissionJobProfit`, 0) AS `SalesRepJobProfit`,
        IFNULL((((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) - `jic`.`cost`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) - (((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100)),
                0) AS `CalcRevShare`,
        IFNULL((((((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) - `jic`.`cost`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) * IFNULL(`bjs`.`Allocated`, 100)) / 100) - (((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) * IFNULL(`bjs`.`Allocated`, 100)) / 100)),
                0) AS `CalcSplitRev`,
        IFNULL(`bjs`.`splitType`, 'N/A') AS `CommSplitType`,
        IFNULL(`bjs`.`Allocated`, 100) AS `CommPercent`,
        `bjs`.`ChangedOn` AS `CommSplitChangedOn`,
        `bjs`.`SplitUserName` AS `CommSalesRep`,
        `jic`.`enteredDate` AS `CommAvailableDate`,
        IF(ISNULL(`jic`.`ecInvoicePeriodID`),
            'No',
            'Yes') AS `IsCommPaid`,
        (SELECT 
                `ecInvoicePeriod`.`DatePaid`
            FROM
                `ecInvoicePeriod`
            WHERE
                (`ecInvoicePeriod`.`ecInvoicePeriodID` = `jic`.`ecInvoicePeriodID`)) AS `CommPaidDate`,
        CAST((SELECT 
                    MAX(`ecInvoicePeriod`.`enteredDate`)
                FROM
                    `ecInvoicePeriod`
                WHERE
                    ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                        AND (`ecInvoicePeriod`.`ecType` = 'A')))
            AS DATE) AS `CommEnteredDate`,
        `bjs`.`coDivisionID` AS `coDivisionID`,
        `bjs`.`DivDescription` AS `DivDescription`,
        `bjs`.`DivCode` AS `DivCode`,
        `bjs`.`CustomerName` AS `CustomerName`,
        NULL AS `joMasterID`,
        NULL AS `veBillID`,
        IFNULL(`rM`.`Name`,
                (SELECT 
                        `rxMaster`.`Name`
                    FROM
                        `rxMaster`
                    WHERE
                        (`rxMaster`.`rxMasterID` = `vP`.`rxVendorID`))) AS `VendorName`,
        `bjs`.`Engineer` AS `Engineer`,
        `bjs`.`SalesEngineer` AS `SalesEngineer`
    FROM
        (((((`WH_splitJob` `bjs`
        JOIN `joInvoiceCost` `jic` ON ((`bjs`.`ReleasedetailID` = `jic`.`joReleaseDetailID`)))
        LEFT JOIN `joReleaseType` ON ((`bjs`.`Info_ReleaseType` = `joReleaseType`.`joReleaseTypeID`)))
        LEFT JOIN `cuSO` `cO` ON ((`cO`.`joReleaseID` = `bjs`.`ReleaseId`)))
        LEFT JOIN `rxMaster` `rM` ON ((`cO`.`rxCustomerID` = `rM`.`rxMasterID`)))
        LEFT JOIN `vePO` `vP` ON ((`vP`.`joReleaseID` = `bjs`.`ReleaseId`))) 
    UNION ALL SELECT 
        'VendorComm' AS `RecordType`,
        NULL AS `CustomerStatus`,
        `joM`.`JobNumber` AS `JobNumber`,
        `joM`.`Description` AS `JobName`,
        `veC`.`InvoiceNumber` AS `InvoiceNumber`,
        IFNULL(`joReleaseType`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `veC`.`ShipDate` AS `InvoiceDate`,
        NULL AS `InvoiceSubtotal`,
        NULL AS `InvoiceFreight`,
        NULL AS `InvoiceCostStock`,
        NULL AS `InvoiceCostDrop`,
        NULL AS `InvoiceCostDropFreight`,
        IFNULL(`veC`.`BillAmount`, 0) AS `InvoiceAmount`,
        NULL AS `InvoiceDiscount`,
        NULL AS `InvoiceToBePaid`,
        NULL AS `InvoicePaid`,
        NULL AS `CustomerBalance`,
        NULL AS `CustomerPaidDate`,
        NULL AS `AddCostTotals`,
        `tsUL`.`FullName` AS `SalesRepAssigned`,
        NULL AS `info_memoStatus`,
        NULL AS `info_CreditMemo`,
        0 AS `info_rxCustomerID`,
        0 AS `info_cuInvoiceID`,
        `veC`.`veCommDetailID` AS `info_veCommDetailID`,
        `veC`.`ecInvoicePeriodID` AS `info_ecInvoicePeriodID`,
        `ecS`.`ecSplitJobID` AS `info_ecSplitjobID`,
        `joR`.`joReleaseID` AS `info_joReleaseID`,
        IFNULL(`tsUL1`.`UserLoginID`,
                `tsUL`.`UserLoginID`) AS `info_userLoginID`,
        IFNULL(`joR`.`ReleaseType`, -(1)) AS `ReleaseTypes`,
        `veC`.`joReleaseDetailID` AS `Info_ReleasedetailID`,
        0 AS `info_joInvoiceCostID`,
        `veC`.`CommAmount` AS `CalcRawInvoiceProfit`,
        IFNULL((SELECT 
                        `emMaster`.`CommissionJobProfit`
                    FROM
                        `emMaster`
                    WHERE
                        (`emMaster`.`UserLoginID` = `joM`.`cuAssignmentID0`)
                    LIMIT 0 , 1),
                0) AS `SalesRepJobProfit`,
        ((`veC`.`CommAmount` * IFNULL((SELECT 
                        `emMaster`.`CommissionJobProfit`
                    FROM
                        `emMaster`
                    WHERE
                        (`emMaster`.`UserLoginID` = `joM`.`cuAssignmentID0`)
                    LIMIT 0 , 1),
                0)) / 100) AS `CalcRevShare`,
        ((((`veC`.`CommAmount` * IFNULL((SELECT 
                        `emMaster`.`CommissionJobProfit`
                    FROM
                        `emMaster`
                    WHERE
                        (`emMaster`.`UserLoginID` = `joM`.`cuAssignmentID0`)
                    LIMIT 0 , 1),
                0)) / 100) * IFNULL(`ecS`.`Allocated`, 100)) / 100) AS `CalcSplitRev`,
        IFNULL(`ecS`.`splitType`, 'N/A') AS `CommSplitType`,
        IFNULL(`ecS`.`Allocated`, 100) AS `CommPercent`,
        `ecS`.`ChangedOn` AS `CommSplitChangedOn`,
        IFNULL(`tsUL1`.`FullName`, `tsUL`.`FullName`) AS `CommSalesRep`,
        `veC`.`CommDate` AS `CommAvailableDate`,
        IF(ISNULL(`veC`.`ecInvoicePeriodID`),
            'No',
            'Yes') AS `IsCommPaid`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`DatePaid`)
            FROM
                `ecInvoicePeriod`
            WHERE
                (`veC`.`ecInvoicePeriodID` = `ecInvoicePeriod`.`ecInvoicePeriodID`)) AS `CommPaidDate`,
        `veC`.`ShipDate` AS `CommEnteredDate`,
        NULL AS `coDivisionID`,
        NULL AS `DivDescription`,
        NULL AS `DivCode`,
        NULL AS `CustomerName`,
        NULL AS `joMasterID`,
        NULL AS `veBillID`,
        `rM`.`Name` AS `VendorName`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`
    FROM
        (((((((((((((`veCommDetail` `veC`
        JOIN `joReleaseDetail` `jRD` ON ((`jRD`.`joReleaseDetailID` = `veC`.`joReleaseDetailID`)))
        JOIN `joRelease` `joR` ON ((`joR`.`joReleaseID` = `jRD`.`joReleaseID`)))
        JOIN `joMaster` `joM` ON ((`joM`.`joMasterID` = `joR`.`joMasterID`)))
        JOIN `tsUserLogin` `tsUL` ON ((`tsUL`.`UserLoginID` = `joM`.`cuAssignmentID0`)))
        LEFT JOIN `ecSplitJob` `ecS` ON ((`ecS`.`joMasterID` = `joR`.`joMasterID`)))
        LEFT JOIN `emMaster` `emM` ON ((`emM`.`emMasterID` = `ecS`.`rxMasterID`)))
        LEFT JOIN `tsUserLogin` `tsUL1` ON ((`emM`.`UserLoginID` = `tsUL1`.`UserLoginID`)))
        LEFT JOIN `joReleaseType` ON ((`joR`.`ReleaseType` = `joReleaseType`.`joReleaseTypeID`)))
        LEFT JOIN `vePO` `vP` ON ((`vP`.`joReleaseID` = `joR`.`joReleaseID`)))
        LEFT JOIN `rxMaster` `rM` ON ((`vP`.`rxVendorID` = `rM`.`rxMasterID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `joM`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `joM`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
    WHERE
        ((`joR`.`ReleaseType` = 4)
            AND (`veC`.`ShipDate` >= '2014-09-01')
            AND (`jRD`.`joReleaseDetailID` IS NOT NULL)
            AND (`veC`.`hasCustomerInvoice` <> 1)) 
    UNION ALL SELECT 
        'VendorExpense' AS `RecordType`,
        NULL AS `CustomerStatus`,
        `joM`.`JobNumber` AS `JobNumber`,
        `joM`.`Description` AS `JobName`,
        `vB`.`InvoiceNumber` AS `InvoiceNumber`,
        NULL AS `ReleaseTypeDescription`,
        `vB`.`BillDate` AS `InvoiceDate`,
        `veC`.`ExpenseAmount` AS `InvoiceSubtotal`,
        NULL AS `InvoiceFreight`,
        NULL AS `InvoiceCostStock`,
        NULL AS `InvoiceCostDrop`,
        NULL AS `InvoiceCostDropFreight`,
        NULL AS `InvoiceAmount`,
        NULL AS `InvoiceDiscount`,
        NULL AS `InvoiceToBePaid`,
        NULL AS `InvoicePaid`,
        NULL AS `CustomerBalance`,
        NULL AS `CustomerPaidDate`,
        NULL AS `AddCostTotals`,
        `tsUL`.`FullName` AS `SalesRepAssigned`,
        NULL AS `info_memoStatus`,
        NULL AS `info_CreditMemo`,
        0 AS `info_rxCustomerID`,
        0 AS `info_cuInvoiceID`,
        `veC`.`veBillDistributionID` AS `info_veCommDetailID`,
        NULL AS `info_ecInvoicePeriodID`,
        `ecS`.`ecSplitJobID` AS `info_ecSplitjobID`,
        NULL AS `info_joReleaseID`,
        IFNULL(`tsUL1`.`UserLoginID`,
                `tsUL`.`UserLoginID`) AS `info_userLoginID`,
        -(2) AS `ReleaseTypes`,
        NULL AS `Info_ReleasedetailID`,
        0 AS `info_joInvoiceCostID`,
        -(`veC`.`ExpenseAmount`) AS `CalcRawInvoiceProfit`,
        IFNULL((SELECT 
                        `emMaster`.`CommissionJobProfit`
                    FROM
                        `emMaster`
                    WHERE
                        (`emMaster`.`UserLoginID` = `joM`.`cuAssignmentID0`)
                    LIMIT 0 , 1),
                0) AS `SalesRepJobProfit`,
        -(((`veC`.`ExpenseAmount` * IFNULL((SELECT 
                        `emMaster`.`CommissionJobProfit`
                    FROM
                        `emMaster`
                    WHERE
                        ((`emMaster`.`UserLoginID` = `joM`.`cuAssignmentID0`)
                            AND (`emMaster`.`GetsCommission` = 1))
                    LIMIT 0 , 1),
                0)) / 100)) AS `CalcRevShare`,
        -(((((`veC`.`ExpenseAmount` * IFNULL((SELECT 
                        `emMaster`.`CommissionJobProfit`
                    FROM
                        `emMaster`
                    WHERE
                        ((`emMaster`.`UserLoginID` = `joM`.`cuAssignmentID0`)
                            AND (`emMaster`.`GetsCommission` = 1))
                    LIMIT 0 , 1),
                0)) / 100) * IFNULL(`ecS`.`Allocated`, 100)) / 100)) AS `CalcSplitRev`,
        IFNULL(`ecS`.`splitType`, 'N/A') AS `CommSplitType`,
        IFNULL(`ecS`.`Allocated`, 100) AS `CommPercent`,
        `ecS`.`ChangedOn` AS `CommSplitChangedOn`,
        IF(ISNULL(`ecS`.`rxMasterID`),
            IFNULL(`tsUL1`.`FullName`, `tsUL`.`FullName`),
            CONVERT( `rxMaster`.`Name` USING UTF8)) AS `CommSalesRep`,
        `vB`.`BillDate` AS `CommAvailableDate`,
        IF(ISNULL(`veC`.`ecInvoicePeriodID`),
            'No',
            'Yes') AS `IsCommPaid`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`DatePaid`)
            FROM
                `ecInvoicePeriod`
            WHERE
                (`veC`.`ecInvoicePeriodID` = `ecInvoicePeriod`.`ecInvoicePeriodID`)) AS `CommPaidDate`,
        NULL AS `CommEnteredDate`,
        NULL AS `coDivisionID`,
        NULL AS `DivDescription`,
        NULL AS `DivCode`,
        NULL AS `CustomerName`,
        `veC`.`joMasterID` AS `joMasterID`,
        `veC`.`veBillID` AS `veBillID`,
        NULL AS `VendorName`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`
    FROM
        ((((((((((`veBillDistribution` `veC`
        JOIN `joMaster` `joM` ON ((`joM`.`joMasterID` = `veC`.`joMasterID`)))
        LEFT JOIN `veBill` `vB` ON ((`veC`.`veBillID` = `vB`.`veBillID`)))
        JOIN `tsUserLogin` `tsUL` ON ((`tsUL`.`UserLoginID` = `joM`.`cuAssignmentID0`)))
        LEFT JOIN `ecSplitJob` `ecS` ON (((`joM`.`joMasterID` = `ecS`.`joMasterID`)
            AND ISNULL(`ecS`.`joReleaseID`))))
        LEFT JOIN `emMaster` `emM` ON ((`emM`.`emMasterID` = `ecS`.`rxMasterID`)))
        LEFT JOIN `tsUserLogin` `tsUL1` ON ((`emM`.`UserLoginID` = `tsUL1`.`UserLoginID`)))
        LEFT JOIN `rxMaster` ON ((`ecS`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `joM`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `joM`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)));   
   
    
    

	select count(*) into _count from WH_salesCommission;

	call WH_log('INSERT',_startTime,now(),_count, null,null,'REBUILD_WH_salesCommission','WH_update','Success', 'WH_salesCommission');


END IF;




END$$ -- WH_update

DELIMITER ;

-- ======================================================================================

-- ======================================================================================


-- ============================================================
-- call WH_updateJobActivity('CLEAR_WH_JOBACTIVITY',1,0,1);
-- call WH_updateJobActivity('UPDATE_QUOTE',1,100,1);
/*
DROP procedure IF EXISTS `WH_updateJobActivity`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `WH_updateJobActivity`(
	IN _action varchar(100),
    IN _userID INT,
    IN _totalRecordsToProcess INT,
    IN _DEBUG TINYINT
)
WH_updateJobActivity : BEGIN

DECLARE _startTime datetime;
DECLARE _endTime datetime;
DECLARE _createdOnDate datetime;
DECLARE _createdonWH datetime;
DECLARE _changedOn datetime;

DECLARE _JobNumber varchar(255);
DECLARE _previousJobNumber varchar(255);
DECLARE _JobNumbers longtext;
DECLARE _foundWHJob int;
DECLARE _foundJob int;

DECLARE strLen    longtext DEFAULT 0;
DECLARE SubStrLen longtext DEFAULT 0;

declare _no_of_records int default 0;
declare _no_of_recordsInsert int default 0;
declare _no_of_recordsNotInsert int default 0;
declare _no_of_recordsUpdate int default 0;
DECLARE _logNotesInsert longtext;
DECLARE _logNotesNotInsert longtext;
DECLARE _logNotesUpdate longtext;
DECLARE _errorStatus tinyint default 0;
DECLARE _logNotes longtext default '';
DECLARE _tableName varchar(255);

declare _count int;
declare _num1 int default 0;
declare _num int default 0;
declare _countOfNotInserted int default 0;

SET _startTime = now();
set _tableName = "WH_JobActivity";

-- deprecate this procedure until further notice.
LEAVE WH_updateJobActivity;
    
if (_DEBUG) THEN
	SELECT _action, _startTime, (SELECT count(*) as StartingRecordsWHJobActivity FROM WH_JobActivity);
END IF;
    
if (_action='CLEAR_WH_JOBACTIVITY') THEN

	truncate WH_JobActivity;
    SET _endTime = now();
    SET _logNotesInsert = " Truncate WH_JobActivity"; 
    call WH_log('INSERT',_startTime,_endTime,_no_of_recordsInsert, _logNotesInsert,_userID,_action,"WH_updateJobActivity",_errorStatus,_tableName);
    
    if (_DEBUG) THEN
		SELECT * FROM wh_logStatus ORDER BY logId DESC limit 5;
	END IF;
    
    LEAVE WH_updateJobActivity;
    
ELSEIF (_action='UPDATE_QUOTE') THEN

	SELECT max(WHJA_CreatedOn) INTO _createdonWH FROM WH_JobActivity;
    SELECT max(ChangedOn) INTO _changedOn FROM joMaster;

	IF(_createdonWH IS NULL or _createdonWH = '') THEN
		SET _createdonWH = '2005-12-28 00:00:00';
        SELECT group_concat(JobNumber) INTO _JobNumbers FROM (SELECT JobNumber FROM joMaster WHERE CreatedOn >= _createdonWH limit _totalRecordsToProcess) as res;
	ELSE
		-- SELECT group_concat(JobNumber) INTO _JobNumbers FROM (SELECT JobNumber FROM joMaster WHERE DATE_FORMAT(CreatedOn, '%Y-%m-%d') > DATE_FORMAT(_createdonWH, '%Y-%m-%d') or DATE_FORMAT(ChangedOn, '%Y-%m-%d') >= DATE_FORMAT(_changedOn, '%Y-%m-%d') limit _totalRecordsToProcess) as res;
		SELECT group_concat(JobNumber) INTO _JobNumbers FROM (SELECT JobNumber FROM joMaster WHERE CreatedOn >= _createdonWH limit _totalRecordsToProcess) as res;
    END IF;
    
    IF (_DEBUG) THEN
		SELECT _action, (SELECT count(*) as EndingRecordsWHJobActivity FROM WH_JobActivity), "No.of jobNumbers are fetched : ",_JobNumbers;
     END IF;

	IF (_JobNumbers = '' or _JobNumbers IS NULL) THEN    
		SET _errorStatus = 0;
		SET _logNotes = concat(_logNotes,':', 'JobNumbers are Not Found for ',_createdonWH);
        call WH_log('INSERT',_startTime,now(),0, _logNotes,_userID,_action,"WH_updateJobActivity",_errorStatus,_tableName);
        
		IF (_DEBUG) THEN
			SELECT *,"empty jobs",_createdonWH FROM wh_logStatus ORDER BY logId desc limit 5;
		END IF;
        
        LEAVE WH_updateJobActivity;
	ELSE
		SET _logNotes = concat(_logNotes,':', _JobNumbers, "These JobNumbers are Found ");
	END IF;
    
		SET _logNotesUpdate = 'Update: ';
        SET _logNotesInsert = 'Insert: ';
        SET _logNotesNotInsert = 'Not Insert : ';
        
	_process_jobs:LOOP	
		SET _JobNumber = null;
		SET strLen = CHAR_LENGTH(_JobNumbers);
		SET _JobNumber=SUBSTRING_INDEX(_JobNumbers, ',', 1);
            
		SELECT WHJA_JobNumber INTO _foundWHJob FROM  WH_JobActivity WHERE WHJA_JobNumber = _JobNumber LIMIT 1;
        
        -- SELECT count(*) into _count FROM joQuoteHeader WHERE joMasterID in (SELECT joMasterID FROM joMaster WHERE JobNumber in (_JobNumber));
        
        -- IF(_count > 0) THEN
            
			if (_foundWHJob = '' or _foundWHJob IS NULL) THEN
				
			insert INTO WH_JobActivity( WHJA_CreatedOn,WHJA_JobNumber, WHJA_JobName, WHJA_JobStatus, WHJA_BidStatus,WHJA_BidStatusID, WHJA_CustomerID,
				WHJA_Customer, WHJA_EmployeeAssigned0,WHJA_EmployeeAssigned1,WHJA_EmployeeAssigned2,WHJA_EmployeeAssigned3,WHJA_EmployeeAssigned4,
                WHJA_EmployeeAssigned5,WHJA_BidderName,WHJA_BidderContactName,WHJA_JobTotalAmount_Calc,WHJA_JobProfitAmount_Calc,
				WHJA_ChangeOrderProfitAmount_Calc, WHJA_JobTotalProfitAmount_Calc,WHJA_JobProfitMargin_Calc, WHJA_PercentOfQuota_Calc,
                WHJA_QuoteType, WHJA_QuoteItemCategory, WHJA_BidDate, WHJA_Division,WHJA_coDivisionID, WHJA_Architect, WHJA_Engineer, 
                WHJA_cuAssignmentID0, WHJA_cuAssignmentID1, WHJA_cuAssignmentID2, WHJA_cuAssignmentID3, WHJA_cuAssignmentID4,
				WHJA_cuAssignmentID5, WHJA_cuAssignmentID6, WHJA_joMasterID,WHJA_joQuoteHeaderID, WHJA_ReleaseTypeID, WHJA_LocationAddress1, WHJA_LocationAddress2, WHJA_LocationCity, WHJA_LocationState, WHJA_LocationZip, WHJA_QuoteItemVendor,
				WHJA_QuoteRevision, WHJA_QuoteCreatedBy, WHJA_QuoteItemCost, WHJA_QuoteHeaderAmount, WHJA_QuoteItemSellPrice, WHJA_QuoteDiscountPrice,WHJA_JobNumberTypeRev, WHJA_QuoteNumberType,
                WHJA_JobStatusID, WHJA_BidderID, WHJA_QuoteTypeID, WHJA_QuoteItemCategoryID)				
                
                SELECT `jo`.`CreatedOn` AS `CreatedOn`,`jo`.`JobNumber` AS `JobNumber`,`jo`.`Description` AS `JobName`, `joS`.`JobStatus` AS `JobStatus`,
                `bs`.`Description` AS `BidStatus`, `bs`.`joBidStatusID` as `BidStatusID`, `rm`.`Name` AS `Customer`, `rm`.`rxMasterID` AS `CustomerID`, 
                (SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID0`)) AS `EmployeeAssigned0`,
				(SELECT  `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID1`)) AS `EmployeeAssigned1`,
				(SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID2`)) AS `EmployeeAssigned2`,
				(SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID3`)) AS `EmployeeAssigned3`,
				(SELECT  `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID4`)) AS `EmployeeAssigned4`,
				(SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID5`)) AS `EmployeeAssigned5`,
				`rxb`.`Name` AS `BidderName`,CONCAT(`c`.`FirstName`, ' ', `c`.`LastName`) AS `BidderContactName`,                
				(IFNULL(`jo`.`ContractAmount`, 0) + IFNULL(`joChg`.`ChangeAmount`, 0)) AS `JobTotalAmount_Calc`,
				(IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) AS `JobProfitAmount_Calc`,
				(IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0)) AS `ChangeOrderProfitAmount_Calc`,
				((IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) + (IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0))) AS `JobTotalProfitAmount_Calc`,
				(((IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) + (IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0))) / IFNULL((`jo`.`ContractAmount` + `joChg`.`ChangeAmount`),1)) AS `JobProfitMargin_Calc`,
				((((IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) + (IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0))) / IFNULL((`jo`.`ContractAmount` + `joChg`.`ChangeAmount`),1)) / IFNULL(`em`.`Quota`, 1)) AS `PercentOfQuota_Calc`,               
                `cmt`.`Code` AS `QuoteType`,`joQCat`.`description` AS `QuoteItemCategory`,`jo`.`BidDate` AS `BidDate`,`d`.`Description` AS `Division`, `d`.`coDivisionID`,
				(SELECT  `ts`.`Name` FROM `rxMaster` `ts` WHERE (`ts`.`rxMasterID` = `jo`.`rxCategory1`)) AS `Architect`,
				(SELECT  `ts`.`Name` FROM `rxMaster` `ts` WHERE (`ts`.`rxMasterID` = `jo`.`rxCategory2`)) AS `Engineer`,              
				`jo`.`cuAssignmentID0` AS `cuAssignmentID0`,`jo`.`cuAssignmentID1` AS `cuAssignmentID1`,`jo`.`cuAssignmentID2` AS `cuAssignmentID2`,
                `jo`.`cuAssignmentID3` AS `cuAssignmentID3`,`jo`.`cuAssignmentID4` AS `cuAssignmentID4`,`jo`.`cuAssignmentID5` AS `cuAssignmentID5`,
                `jo`.`cuAssignmentID6` AS `cuAssignmentID6`,`jo`.`joMasterID` AS `joMasterID`,`q`.`joQuoteHeaderID` AS `joQuoteHeaderID`, `rt`.`joReleaseTypeID` AS `ReleaseTypeID`, `jo`.`LocationAddress1` AS `LocationAddress1`,
				`jo`.`LocationAddress2` AS `LocationAddress2`,`jo`.`LocationCity` AS `LocationCity`,`jo`.`LocationState` AS `LocationState`,`jo`.`LocationZip` AS `LocationZip`,
				(SELECT `rxMaster`.`Name` FROM `rxMaster` WHERE (`rxMaster`.`rxMasterID` = `joQDM`.`manufacturer`)) AS `QuoteItemVendor`,
				`q`.`QuoteRev` AS `QuoteRevision`,`u`.`FullName` AS `QuoteCreatedBy`,`joQDM`.`cost` AS `QuoteItemCost`,
				`q`.`QuoteAmount` AS `QuoteHeaderAmount`,`joQDM`.`sellprice` AS `QuoteItemSellPrice`,
			    `q`.`DiscountedPrice` AS `QuoteDiscountPrice`, CONCAT(`jo`.`JobNumber`,`cmt`.`Code`,`q`.`QuoteRev`),
                CONCAT(`jo`.`JobNumber`,`cmt`.`Code`) as `QuoteNumberType`, `joS`.`joStatusID` as `joStatusID`,
                `b`.`joBidderID` as `BidderID`, `cmt`.`cuMasterTypeID` as `QuoteTypeID`, `joQCat`.`id` as `QuoteItemCategoryID` 
                FROM `joQuoteHeader` `q` 
				LEFT JOIN `joMaster` `jo` on ((`jo`.`joMasterID` = `q`.`joMasterID`))
				LEFT JOIN `rxAddress` `rA` ON ((`rA`.`rxMasterID` = `jo`.`rxCustomerID`) AND (`rA`.`IsMailing` = 1))
				LEFT JOIN `rxMaster` `rm` ON ((`rm`.`rxMasterID` = `jo`.`rxCustomerID`))
				LEFT JOIN `joStatus` `joS` ON ((`joS`.`joStatusID` = `jo`.`JobStatus`))
				LEFT JOIN `coDivision` `d` ON ((`d`.`coDivisionID` = `jo`.`coDivisionID`))
				LEFT JOIN `tsUserLogin` `ts` ON ((`ts`.`UserLoginID` = `jo`.`cuAssignmentID0`))
				LEFT JOIN `emMaster` `em` ON ((`ts`.`UserLoginID` = `em`.`UserLoginID`))
				LEFT JOIN `joChange` `joChg` ON ((`joChg`.`joMasterID` = `jo`.`joMasterID`))
				LEFT JOIN `joBidStatus` `bs` ON ((`bs`.`joBidStatusID` = `jo`.`joBidStatusID`))
				LEFT JOIN `joQuoteDetailMstr` `joQDM` ON ((`joQDM`.`joQuoteHeaderID` = `q`.`joQuoteHeaderID`))
				LEFT JOIN `joQuoteCategory` `joQCat` ON ((`joQCat`.`id` = `joQDM`.`category`))
				LEFT JOIN `tsUserLogin` `u` ON ((`u`.`UserLoginID` = `q`.`CreatedByID`))
				LEFT JOIN `cuMasterType` `cmt` ON ((`cmt`.`cuMasterTypeID` = `q`.`cuMasterTypeID`))
				LEFT JOIN `joBidder` `b` ON (((`b`.`joMasterID` = `jo`.`joMasterID`) AND (`b`.`cuMasterTypeID` = `q`.`cuMasterTypeID`)))
				LEFT JOIN `rxContact` `c` ON ((`b`.`rxContactID` = `c`.`rxContactID`))
				LEFT JOIN `rxMaster` `rxb` ON ((`b`.`rxMasterID` = `rxb`.`rxMasterID`))
				LEFT JOIN `joRelease` `joR` ON ((`joR`.`joMasterID` = `jo`.`joMasterID`))
				LEFT JOIN `joReleaseType` `rt` ON ((`joR`.`ReleaseType` = `rt`.`joReleaseTypeID`))
				WHERE `jo`.`JobNumber` = _JobNumber ;	
					
				SET _logNotesInsert = concat(_logNotesInsert,':',_JobNumber );
				
				SELECT count(*) into _num FROM joMaster WHERE JobNumber = _JobNumber;
				SET _no_of_recordsInsert = _no_of_recordsInsert + _num;
				
			else
			
				SET _logNotesUpdate = concat(_logNotesUpdate,':',_JobNumber );
				delete FROM WH_JobActivity WHERE WHJA_JobNumber = _JobNumber;
				
                -- set sql_safe_updates = 0;
                
				insert INTO WH_JobActivity( WHJA_CreatedOn,WHJA_JobNumber, WHJA_JobName, WHJA_JobStatus, WHJA_BidStatus,WHJA_BidStatusID, WHJA_CustomerID,
				WHJA_Customer, WHJA_EmployeeAssigned0,WHJA_EmployeeAssigned1,WHJA_EmployeeAssigned2,WHJA_EmployeeAssigned3,WHJA_EmployeeAssigned4,
                WHJA_EmployeeAssigned5,WHJA_BidderName,WHJA_BidderContactName,WHJA_JobTotalAmount_Calc,WHJA_JobProfitAmount_Calc,
				WHJA_ChangeOrderProfitAmount_Calc, WHJA_JobTotalProfitAmount_Calc,WHJA_JobProfitMargin_Calc, WHJA_PercentOfQuota_Calc,
                WHJA_QuoteType, WHJA_QuoteItemCategory, WHJA_BidDate, WHJA_Division,WHJA_coDivisionID, WHJA_Architect, WHJA_Engineer, 
                WHJA_cuAssignmentID0, WHJA_cuAssignmentID1, WHJA_cuAssignmentID2, WHJA_cuAssignmentID3, WHJA_cuAssignmentID4,
				WHJA_cuAssignmentID5, WHJA_cuAssignmentID6, WHJA_joMasterID,WHJA_joQuoteHeaderID, WHJA_ReleaseTypeID, WHJA_LocationAddress1, WHJA_LocationAddress2, WHJA_LocationCity, WHJA_LocationState, WHJA_LocationZip, WHJA_QuoteItemVendor,
				WHJA_QuoteRevision, WHJA_QuoteCreatedBy, WHJA_QuoteItemCost, WHJA_QuoteHeaderAmount, WHJA_QuoteItemSellPrice, WHJA_QuoteDiscountPrice,WHJA_JobNumberTypeRev, WHJA_QuoteNumberType,
                WHJA_JobStatusID, WHJA_BidderID, WHJA_QuoteTypeID, WHJA_QuoteItemCategoryID)				
                
                SELECT  `jo`.`CreatedOn` AS `CreatedOn`,`jo`.`JobNumber` AS `JobNumber`,`jo`.`Description` AS `JobName`, `joS`.`JobStatus` AS `JobStatus`,
                `bs`.`Description` AS `BidStatus`, `bs`.`joBidStatusID` as `BidStatusID`, `rm`.`Name` AS `Customer`, `rm`.`rxMasterID` AS `CustomerID`, 
                (SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID0`)) AS `EmployeeAssigned0`,
				(SELECT  `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID1`)) AS `EmployeeAssigned1`,
				(SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID2`)) AS `EmployeeAssigned2`,
				(SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID3`)) AS `EmployeeAssigned3`,
				(SELECT  `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID4`)) AS `EmployeeAssigned4`,
				(SELECT `ts`.`FullName` FROM `tsUserLogin` `ts` WHERE (`ts`.`UserLoginID` = `jo`.`cuAssignmentID5`)) AS `EmployeeAssigned5`,
				`rxb`.`Name` AS `BidderName`,CONCAT(`c`.`FirstName`, ' ', `c`.`LastName`) AS `BidderContactName`,                
				(IFNULL(`jo`.`ContractAmount`, 0) + IFNULL(`joChg`.`ChangeAmount`, 0)) AS `JobTotalAmount_Calc`,
				(IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) AS `JobProfitAmount_Calc`,
				(IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0)) AS `ChangeOrderProfitAmount_Calc`,
				((IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) + (IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0))) AS `JobTotalProfitAmount_Calc`,
				(((IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) + (IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0))) / IFNULL((`jo`.`ContractAmount` + `joChg`.`ChangeAmount`),1)) AS `JobProfitMargin_Calc`,
				((((IFNULL(`jo`.`ContractAmount`, 0) - IFNULL(`jo`.`EstimatedCost`, 0)) + (IFNULL(`joChg`.`ChangeAmount`, 0) - IFNULL(`joChg`.`ChangeCost`, 0))) / IFNULL((`jo`.`ContractAmount` + `joChg`.`ChangeAmount`),1)) / IFNULL(`em`.`Quota`, 1)) AS `PercentOfQuota_Calc`,               
                `cmt`.`Code` AS `QuoteType`,`joQCat`.`description` AS `QuoteItemCategory`,`jo`.`BidDate` AS `BidDate`,`d`.`Description` AS `Division`, `d`.`coDivisionID`,
				(SELECT  `ts`.`Name` FROM `rxMaster` `ts` WHERE (`ts`.`rxMasterID` = `jo`.`rxCategory1`)) AS `Architect`,
				(SELECT  `ts`.`Name` FROM `rxMaster` `ts` WHERE (`ts`.`rxMasterID` = `jo`.`rxCategory2`)) AS `Engineer`,              
				`jo`.`cuAssignmentID0` AS `cuAssignmentID0`,`jo`.`cuAssignmentID1` AS `cuAssignmentID1`,`jo`.`cuAssignmentID2` AS `cuAssignmentID2`,
                `jo`.`cuAssignmentID3` AS `cuAssignmentID3`,`jo`.`cuAssignmentID4` AS `cuAssignmentID4`,`jo`.`cuAssignmentID5` AS `cuAssignmentID5`,
                `jo`.`cuAssignmentID6` AS `cuAssignmentID6`,`jo`.`joMasterID` AS `joMasterID`,`q`.`joQuoteHeaderID` AS `joQuoteHeaderID`, `rt`.`joReleaseTypeID` AS `ReleaseTypeID`, `jo`.`LocationAddress1` AS `LocationAddress1`,
				`jo`.`LocationAddress2` AS `LocationAddress2`,`jo`.`LocationCity` AS `LocationCity`,`jo`.`LocationState` AS `LocationState`,`jo`.`LocationZip` AS `LocationZip`,
				(SELECT `rxMaster`.`Name` FROM `rxMaster` WHERE (`rxMaster`.`rxMasterID` = `joQDM`.`manufacturer`)) AS `QuoteItemVendor`,
				`q`.`QuoteRev` AS `QuoteRevision`,`u`.`FullName` AS `QuoteCreatedBy`,`joQDM`.`cost` AS `QuoteItemCost`,
				`q`.`QuoteAmount` AS `QuoteHeaderAmount`,`joQDM`.`sellprice` AS `QuoteItemSellPrice`,
			    `q`.`DiscountedPrice` AS `QuoteDiscountPrice`, CONCAT(`jo`.`JobNumber`,`cmt`.`Code`,`q`.`QuoteRev`),
                CONCAT(`jo`.`JobNumber`,`cmt`.`Code`) as `QuoteNumberType`, `joS`.`joStatusID` as `joStatusID`,
                `b`.`joBidderID` as `BidderID`, `cmt`.`cuMasterTypeID` as `QuoteTypeID`, `joQCat`.`id` as `QuoteItemCategoryID` 
                FROM `joQuoteHeader` `q` 
				LEFT JOIN `joMaster` `jo` on ((`jo`.`joMasterID` = `q`.`joMasterID`))
				LEFT JOIN `rxAddress` `rA` ON ((`rA`.`rxMasterID` = `jo`.`rxCustomerID`) AND (`rA`.`IsMailing` = 1))
				LEFT JOIN `rxMaster` `rm` ON ((`rm`.`rxMasterID` = `jo`.`rxCustomerID`))
				LEFT JOIN `joStatus` `joS` ON ((`joS`.`joStatusID` = `jo`.`JobStatus`))
				LEFT JOIN `coDivision` `d` ON ((`d`.`coDivisionID` = `jo`.`coDivisionID`))
				LEFT JOIN `tsUserLogin` `ts` ON ((`ts`.`UserLoginID` = `jo`.`cuAssignmentID0`))
				LEFT JOIN `emMaster` `em` ON ((`ts`.`UserLoginID` = `em`.`UserLoginID`))
				LEFT JOIN `joChange` `joChg` ON ((`joChg`.`joMasterID` = `jo`.`joMasterID`))
				LEFT JOIN `joBidStatus` `bs` ON ((`bs`.`joBidStatusID` = `jo`.`joBidStatusID`))
				LEFT JOIN `joQuoteDetailMstr` `joQDM` ON ((`joQDM`.`joQuoteHeaderID` = `q`.`joQuoteHeaderID`))
				LEFT JOIN `joQuoteCategory` `joQCat` ON ((`joQCat`.`id` = `joQDM`.`category`))
				LEFT JOIN `tsUserLogin` `u` ON ((`u`.`UserLoginID` = `q`.`CreatedByID`))
				LEFT JOIN `cuMasterType` `cmt` ON ((`cmt`.`cuMasterTypeID` = `q`.`cuMasterTypeID`))
				LEFT JOIN `joBidder` `b` ON (((`b`.`joMasterID` = `jo`.`joMasterID`) AND (`b`.`cuMasterTypeID` = `q`.`cuMasterTypeID`)))
				LEFT JOIN `rxContact` `c` ON ((`b`.`rxContactID` = `c`.`rxContactID`))
				LEFT JOIN `rxMaster` `rxb` ON ((`b`.`rxMasterID` = `rxb`.`rxMasterID`))
				LEFT JOIN `joRelease` `joR` ON ((`joR`.`joMasterID` = `jo`.`joMasterID`))
				LEFT JOIN `joReleaseType` `rt` ON ((`joR`.`ReleaseType` = `rt`.`joReleaseTypeID`))
				WHERE `jo`.`JobNumber` = _JobNumber ;				
				SELECT count(*) INTO _num1 FROM WH_JobActivity WHERE WHJA_JobNumber = _JobNumber;
				SET _no_of_recordsUpdate = _no_of_recordsUpdate + _num1;
				
			END IF;
        
		-- else
		-- 	SELECT count(*) INTO _countOfNotInserted FROM joMaster WHERE JobNumber = _JobNumber;
		-- 	SET _no_of_recordsNotInsert = _no_of_recordsNotInsert + _countOfNotInserted;
         --   SET _logNotesNotInsert = concat(_logNotesNotInsert,':',_JobNumber );
		-- END IF;
        
		SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_JobNumbers, ',', 1))+2;
		SET _JobNumbers = MID(_JobNumbers, SubStrLen, strLen);

		-- IF(_JobNumbers = '' or _JobNumbers IS NULL) THEN
			-- SELECT group_concat(JobNumber) INTO _JobNumbers FROM (SELECT JobNumber FROM joMaster WHERE  DATE_FORMAT(ChangedOn, '%Y-%m-%d') >= DATE_FORMAT(now(), '%Y-%m-%d') limit _totalRecordsToProcess) as res;
            IF(_JobNumbers = '' or _JobNumbers IS NULL) THEN
				LEAVE _process_jobs;
			END IF;
	-- END IF;
        
	END LOOP _process_jobs;
        	
	SET _endTime  = now();
	IF(_no_of_recordsInsert > 0) THEN
		call WH_log('INSERT',_startTime,_endTime,_no_of_recordsInsert, _logNotesInsert,_userID,_action,"WH_updateJobActivity",_errorStatus,_tableName);
    END IF;
    IF(_no_of_recordsNotInsert > 0) THEN
		call WH_log('INSERT',_startTime,_endTime,_no_of_recordsNotInsert, _logNotesNotInsert,_userID,_action,"WH_updateJobActivity",_errorStatus,_tableName);
	END IF;
    IF(_no_of_recordsUpdate > 0)THEN
		call WH_log('INSERT',_startTime,_endTime,_no_of_recordsUpdate, _logNotesUpdate,_userID,_action,"WH_updateJobActivity",_errorStatus,_tableName);
	END IF;

	if (_DEBUG) THEN
		SELECT *,_createdonWH FROM wh_logStatus ORDER BY logId desc limit 5;
        SELECT _action, _endTime, (SELECT count(*) as EndingRecordsWHJobActivity FROM WH_JobActivity);
	END IF;
    

    
ELSEIF (_action='UPDATE_WH_JOBACTIVITY_TABLE') THEN

   
   -- select group_concat(WHJA_JobNumber) into _JobNumbers from WH_JobActivity where WHJA_joMasterID = 0 limit _totalRecordsToProcess ; 
   select group_concat(JobNumber) into _JobNumbers from joMaster where JobNumber in (select WHJA_JobNumber from WH_JobActivity where WHJA_joMasterID = 0 group by WHJA_JobNumber) limit _totalRecordsToProcess;
     
	IF (_JobNumbers = '' or _JobNumbers IS NULL) THEN    
        
        LEAVE WH_updateJobActivity;
	END IF;
    
         	_process_jobs:LOOP 
		SET _JobNumber = null;
		SET strLen = CHAR_LENGTH(_JobNumbers);
		SET _JobNumber=SUBSTRING_INDEX(_JobNumbers, ',', 1);
        
        if(_jobNumber = _previousJobNumber) then
			set _previousJobNumber = _JobNumber;
			SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_JobNumbers, ',', 1))+2;
			SET _JobNumbers = MID(_JobNumbers, SubStrLen, strLen);
		else
        
--             
		SELECT WHJA_JobNumber INTO _foundWHJob FROM  WH_JobActivity WHERE WHJA_JobNumber = _JobNumber LIMIT 1;
        
        SELECT count(*) into _count FROM joQuoteHeader WHERE joMasterID in (SELECT joMasterID FROM joMaster WHERE JobNumber in (_JobNumber));
        
         IF(_count > 0) THEN

			select `rm`.`Name` AS `Customer`,  `jo`.`joMasterID` AS `joMasterID` into @customer, @joMasterID FROM `joQuoteHeader` `q` 
			LEFT JOIN `joMaster` `jo` on ((`jo`.`joMasterID` = `q`.`joMasterID`))
			LEFT JOIN `rxAddress` `rA` ON ((`rA`.`rxMasterID` = `jo`.`rxCustomerID`) AND (`rA`.`IsMailing` = 1))
			LEFT JOIN `rxMaster` `rm` ON ((`rm`.`rxMasterID` = `jo`.`rxCustomerID`))
			LEFT JOIN `joStatus` `joS` ON ((`joS`.`joStatusID` = `jo`.`JobStatus`))
			LEFT JOIN `coDivision` `d` ON ((`d`.`coDivisionID` = `jo`.`coDivisionID`))
			LEFT JOIN `tsUserLogin` `ts` ON ((`ts`.`UserLoginID` = `jo`.`cuAssignmentID0`))
			LEFT JOIN `emMaster` `em` ON ((`ts`.`UserLoginID` = `em`.`UserLoginID`))
			LEFT JOIN `joChange` `joChg` ON ((`joChg`.`joMasterID` = `jo`.`joMasterID`))
			LEFT JOIN `joBidStatus` `bs` ON ((`bs`.`joBidStatusID` = `jo`.`joBidStatusID`))
			LEFT JOIN `joQuoteDetailMstr` `joQDM` ON ((`joQDM`.`joQuoteHeaderID` = `q`.`joQuoteHeaderID`))
			LEFT JOIN `joQuoteCategory` `joQCat` ON ((`joQCat`.`id` = `joQDM`.`category`))
			LEFT JOIN `tsUserLogin` `u` ON ((`u`.`UserLoginID` = `q`.`CreatedByID`))
			LEFT JOIN `cuMasterType` `cmt` ON ((`cmt`.`cuMasterTypeID` = `q`.`cuMasterTypeID`))
			LEFT JOIN `joBidder` `b` ON (((`b`.`joMasterID` = `jo`.`joMasterID`) AND (`b`.`cuMasterTypeID` = `q`.`cuMasterTypeID`)))
			LEFT JOIN `rxContact` `c` ON ((`b`.`rxContactID` = `c`.`rxContactID`))
			LEFT JOIN `rxMaster` `rxb` ON ((`b`.`rxMasterID` = `rxb`.`rxMasterID`))
			LEFT JOIN `joRelease` `joR` ON ((`joR`.`joMasterID` = `jo`.`joMasterID`))
			LEFT JOIN `joReleaseType` `rt` ON ((`joR`.`ReleaseType` = `rt`.`joReleaseTypeID`))
				WHERE `jo`.`JobNumber` = _jobNumber limit 1;
                
               -- select `CreatedOn`;
                -- SELECT * FROM WH_JobActivity limit 50;
                
                 UPDATE WH_JobActivity set WHJA_Customer = @customer, WHJA_joMasterID = @joMasterID where WHJA_JobNumber =  _jobNumber;
                
               --  SELECT * FROM WH_JobActivity limit 50;
					
		 END IF;
			set _previousJobNumber = _JobNumber;
		SET SubStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_JobNumbers, ',', 1))+2;
		SET _JobNumbers = MID(_JobNumbers, SubStrLen, strLen);

            IF(_JobNumbers = '' or _JobNumbers IS NULL) THEN
				LEAVE _process_jobs;
			END IF;
		end if;
 	-- END IF;
--         
END LOOP _process_jobs;
        	
END IF;

END$$
*/

DELIMITER ;

/*
-- ============================================================
-- call WH_updateWarehouse('QUOTE', 1, 1, null);
-- call WH_updateWarehouse('SALES', 1, null, null);
-- call WH_updateWarehouse('INVOICE', 1, null, null);

DROP procedure IF EXISTS `WH_updateWarehouse`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `WH_updateWarehouse`(
	IN _action varchar(100),
    IN _userID INT,
    IN _rebuildAllFlag TINYINT,
	IN _DEBUG TINYINT
)
WH_updateWarehouse : BEGIN

DECLARE _loopIterations INT;
DECLARE _noOfRecords INT;
DECLARE _recordCount int default 1000;
DECLARE _loopCounter int default 0;
DECLARE _recordsToProcess int default 100;
DECLARE _createdOn datetime;
declare wh_createdOn datetime;

IF(_action = 'QUOTE') THEN

    

    if (_rebuildAllFlag=1) THEN
		call WH_updateJobActivity('CLEAR_WH_JOBACTIVITY',_userID,0,_DEBUG);
	end if;
	IF(_DEBUG) THEN
        SELECT ROUND(count(JobNumber)/_recordCount) into _loopIterations FROM joMaster;
		SELECT _action, _loopIterations/60 as DurationMin, concat(_action, ' rebuild loop counter : ', ifnull(_loopIterations,0));
		select max(joMasterID) into _createdOn from joMaster;
	END IF;
			
	loopiterations:loop
		select max(WHJA_joMasterID) into wh_createdOn from  WH_JobActivity;
		SET _loopCounter = _loopCounter + 1;
			
		IF(_loopCounter> _loopIterations) THEN
			LEAVE loopiterations;
		END IF;
		IF(wh_createdOn = _createdOn) THEN
			LEAVE loopiterations;
		END IF;
				
		call WH_updateJobActivity('UPDATE_QUOTE',_userID,_recordCount,0);
				
	END LOOP loopiterations;
    
   -- ELSE
	-- 	call WH_updateJobActivity('UPDATE_QUOTE',_userID,_recordCount,_DEBUG);    
   -- END IF;

    IF(_DEBUG = 1) THEN
		SELECT * FROM wh_logStatus ORDER BY logId desc limit 5;
		SELECT _action, now() as endTime, (SELECT count(*) as EndingRecordsWHJobActivity FROM WH_JobActivity);
	END IF;

    ELSEIF(_action = 'UPDATE_QUOTE') THEN
		IF(_DEBUG) THEN
            SELECT ROUND(count(JobNumber)/_recordCount) into _loopIterations FROM joMaster;
			SELECT _action, _loopIterations/60 as DurationMin, concat(_action, ' rebuild loop counter : ', ifnull(_loopIterations,0));
			select max(joMasterID) into _createdOn from joMaster;
		END IF;
			
		loopiterations:loop
			select max(WHJA_joMasterID) into wh_createdOn from  WH_JobActivity;
			SET _loopCounter = _loopCounter + 1;
			
			IF(_loopCounter> _loopIterations) THEN
				LEAVE loopiterations;
			END IF;
			IF(wh_createdOn = _createdOn) THEN
				LEAVE loopiterations;
			END IF;
				
			call WH_updateJobActivity('UPDATE_QUOTE',_userID,_recordCount,0);
				
		END LOOP loopiterations;

   -- IF(_DEBUG = 1) THEN
		-- SELECT * FROM wh_logStatus ORDER BY logId desc limit 5;
		-- SELECT _action, now() as endTime, (SELECT count(*) as EndingRecordsWHJobActivity FROM WH_JobActivity);
	-- END IF;


ELSEIF(_action = 'SALES') THEN


    if (_rebuildAllFlag=1) THEN
    
		call WH_updateSalesActivity('CLEAR_WH_SALESACTIVITY',_userID,0,_DEBUG);
	end if;

	SELECT ROUND(count(JobNumber)/_recordCount) into _loopIterations FROM joMaster;

	IF(_DEBUG) THEN
		SELECT _action, _loopIterations/60 as DurationMin, concat(_action, ' rebuild loop counter : ', ifnull(_loopIterations,0));
		select max(CreatedOn) into _createdOn from joMaster;
	END IF;
			
	loopiterations:loop
		select max(WHJA_CreatedOn) into wh_createdOn from  WH_JobActivity;
		SET _loopCounter = _loopCounter + 1;
			
				-- IF(_loopCounter> _loopIterations) THEN
					-- LEAVE loopiterations;
				-- END IF;
		IF(wh_createdOn = _createdOn) THEN
			LEAVE loopiterations;
		END IF;
				
		call WH_updateSalesActivity('UPDATE_SALES',_userID,_recordCount,0);
				
	END LOOP loopiterations;
    
   --  ELSE
	-- 	call WH_updateSalesActivity('UPDATE_SALES',_userID,_recordCount,_DEBUG);    
   --  END IF;

    IF(_DEBUG = 1) THEN
		SELECT * FROM wh_logStatus ORDER BY logId desc limit 5;
		SELECT _action, now() as endTime, (SELECT count(*) as EndingRecordsWHJobActivity FROM WH_JobActivity);
	END IF;
    
		
END IF;


END$$
*/

DELIMITER ;

-- ============================================================================


DROP procedure IF EXISTS `WH_log`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `WH_log`(
	IN _action VARCHAR(100),
	IN _startTime datetime,
	IN _endTime datetime,
	IN _total_no_of_Records_processed int,
	IN _note text,
	IN _userID tinyint,
	IN _procedure_action varchar(100),
	IN _procedureName varchar(255),
	IN _successStatus varchar(25),
	IN _tableName VARCHAR(255)

)
WH_log: BEGIN

-- iF (_action = 'GET' ) THEN
-- 	select * from wh_log order by logId DESC limit 1000;

IF(_action = 'INSERT' ) THEN
	insert into WH_logStatus(startTime,endTime,logStatus,recordsProcessed,notes,userId,action,procedureName,tableName)
	values (_startTime,_endTime,_successStatus,_total_no_of_Records_processed,_note,_userID,_action,_procedureName,_tableName);
END IF;

-- IF (_DEBUG=1) THEN SELECT _action,_entityId,_shipmentId, _bidId ; END IF;
END$$


DELIMITER ;



-- DROP table IF EXISTS `WH_JobActivity`;

/*

CREATE TABLE `WH_JobActivity` (
  `WHJA_CreatedOn` datetime DEFAULT NULL,
  `WHJA_JobNumber` longtext CHARACTER SET utf8 NOT NULL,
  `WHJA_JobName` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_JobStatus` varchar(12) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_BidStatus` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_BidStatusID` int(10) DEFAULT NULL,
  `WHJA_Customer` varchar(40) CHARACTER SET utf8 DEFAULT NULL,
    `WHJA_CustomerID` int(10) DEFAULT '0',
  `WHJA_EmployeeAssigned0` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_EmployeeAssigned1` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_EmployeeAssigned2` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_EmployeeAssigned3` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_EmployeeAssigned4` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_EmployeeAssigned5` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_BidderName` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_BidderContactName` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_QuoteType` varchar(6) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_QuoteItemCategory` varchar(45) DEFAULT NULL,
  `WHJA_QuoteItemVendor` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_QuoteRevision` varchar(3) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_QuoteCreatedBy` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_QuoteItemCost` decimal(19,2) DEFAULT NULL,
  `WHJA_QuoteHeaderAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_QuoteItemSellPrice` decimal(19,4) DEFAULT '0.0000',
  `WHJA_QuoteDiscountPrice` decimal(19,4) DEFAULT '0.0000',
  `WHJA_BidderLowBid` tinyint(4) DEFAULT '0',
  `WHJA_CustomerPONumber` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_JobTotalAmount_Calc` decimal(20,4) NOT NULL DEFAULT '0.0000',
  `WHJA_JobProfitAmount_Calc` decimal(20,4) NOT NULL DEFAULT '0.0000',
  `WHJA_ChangeOrderProfitAmount_Calc` decimal(20,4) NOT NULL DEFAULT '0.0000',
  `WHJA_JobTotalProfitAmount_Calc` decimal(21,4) NOT NULL DEFAULT '0.0000',
  `WHJA_JobProfitMargin_Calc` decimal(29,8) DEFAULT NULL,
  `WHJA_PercentOfQuota_Calc` decimal(37,12) DEFAULT NULL,
  `WHJA_JobEstimatedCost` decimal(19,4) DEFAULT '0.0000',
  `WHJA_JobContractAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_ChangeOrderCost` decimal(19,4) DEFAULT NULL,
  `WHJA_ChangeOrderAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_ChangeOrderCustomerPO` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_ReleaseType` varchar(50) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `WHJA_SOReleaseNumber` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_SOReleaseSubTotal` decimal(19,4) DEFAULT '0.0000',
  `WHJA_SOReleaseFreight` decimal(19,4) DEFAULT '0.0000',
  `WHJA_SOReleaseCostTotal` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VenPOReleaseNumber` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_VenPOReleaseVendor` varchar(40) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_VenPOReleaseSubTotal` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VenPOReleaseFreight` decimal(19,4) DEFAULT '0.0000',
  `WHJA_POprMasterID` int(10) DEFAULT NULL,
  `WHJA_POProductName` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_POEstimatedShipDate` datetime DEFAULT NULL,
  `WHJA_POQuantityOrdered` decimal(19,4) DEFAULT '0.0000',
  `WHJA_POQuantityReceived` decimal(19,4) DEFAULT '0.0000',
  `WHJA_POQuantityBilled` decimal(19,4) DEFAULT '0.0000',
  `WHJA_Allocated` decimal(19,4) DEFAULT NULL,
  `WHJA_CommissionReleaseAmount` decimal(19,4) DEFAULT NULL,
  `WHJA_CommissionReleaseReceived` tinyint(4) DEFAULT '0',
  `WHJA_CuInvoiceNumber` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_cuInvoiceSubTotal` decimal(19,4) DEFAULT '0.0000',
  `WHJA_CuInvoiceFreight` decimal(19,4) DEFAULT '0.0000',
  `WHJA_CuInvoiceAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_CuInvoiceAppliedAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_LastActivityDate` datetime DEFAULT NULL,
  `WHJA_BidDate` datetime DEFAULT NULL,
  `WHJA_BookedDate` datetime DEFAULT NULL,
  `WHJA_ClosedDate` datetime DEFAULT NULL,
  `WHJA_ChangeOrderDate` datetime DEFAULT NULL,
  `WHJA_ReleaseDate` datetime DEFAULT NULL,
  `WHJA_SOReleaseDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `WHJA_VenPOReleaseDate` datetime DEFAULT NULL,
  `WHJA_CommissionReleaseDate` datetime DEFAULT NULL,
  `WHJA_CuInvoiceDate` datetime DEFAULT NULL,
  `WHJA_DiscountAmt` decimal(19,4) DEFAULT NULL,
  `WHJA_SubTotal` decimal(19,4) DEFAULT '0.0000',
  `WHJA_Freight` decimal(19,4) DEFAULT '0.0000',
  `WHJA_DivisionCode` varchar(6) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_Division` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_MonthlyQuota` decimal(19,4) DEFAULT '0.0000',
  `WHJA_Architect` varchar(40) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_Engineer` varchar(40) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_GeneralContractor` varchar(40) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_JoOwner` varchar(40) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_BondAgent` varchar(40) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_ClaimFiled` varchar(4) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_ClaimFiledDate` datetime DEFAULT NULL,
  `WHJA_GCContact` varchar(81) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_OwnerContact` varchar(81) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_BondAgentContact` varchar(81) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_CreditNotes` longtext,
  `WHJA_CreditReferenceNumber` varchar(12) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_CreditStatus` varchar(8) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_CreditStatusDate` datetime DEFAULT NULL,
  `WHJA_CreditType` varchar(14) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_CreditTypeDate` datetime DEFAULT NULL,
  `WHJA_LienWaverSigned` varchar(3) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `WHJA_LienWaverSignedDate` datetime DEFAULT NULL,
  `WHJA_LienWaverThrough` varchar(3) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `WHJA_LienWaverThroughAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_LienWaverThroughDate` datetime DEFAULT NULL,
  `WHJA_LienWaverThroughFinal` varchar(3) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `WHJA_ReceivedNOC` varchar(3) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `WHJA_ReceivedNOCDate` datetime DEFAULT NULL,
  `WHJA_RequestedNOC` varchar(3) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `WHJA_RequestedNOCDate` datetime DEFAULT NULL,
  `WHJA_SentNTC` varchar(3) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `WHJA_SentNTCDate` datetime DEFAULT NULL,
  `WHJA_ReleaseBillNote` longtext,
  `WHJA_ReleaseNote` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `WHJA_JobReleaseNotes` longtext,
  `WHJA_RequestedShipDate` datetime DEFAULT NULL,
  `WHJA_coDivisionID` int(10) DEFAULT NULL,
  `WHJA_cuAssignmentID0` int(10) DEFAULT NULL,
  `WHJA_cuAssignmentID1` int(10) DEFAULT NULL,
  `WHJA_cuAssignmentID2` int(10) DEFAULT NULL,
  `WHJA_cuAssignmentID3` int(10) DEFAULT NULL,
  `WHJA_cuAssignmentID4` int(10) DEFAULT NULL,
  `WHJA_cuAssignmentID5` int(10) DEFAULT NULL,
  `WHJA_cuAssignmentID6` int(10) DEFAULT NULL,
  `WHJA_cuInvoiceID` int(10) DEFAULT '0',
  `WHJA_emMasterID` int(10) DEFAULT '0',
  `WHJA_joMasterID` int(10) NOT NULL DEFAULT '0',
  `WHJA_joReleaseID` int(10) DEFAULT '0',
  `WHJA_vePOID` int(10) DEFAULT '0',
  `WHJA_joQuoteHeaderID` int(10) DEFAULT '0',
  `WHJA_IsRollbackFlag` int(11) DEFAULT NULL,
  `WHJA_PODescription` varchar(70) DEFAULT NULL,
  `WHJA_vePODetailID` int(10) DEFAULT NULL,
  `WHJA_POQuantityOrderedCost` decimal(19,4) DEFAULT '0.0000',
  `WHJA_ReleaseTypeID` int(10) DEFAULT NULL,
  `WHJA_CustomerInvoiceAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_BalanceDue` decimal(19,4) DEFAULT '0.0000',
  `WHJA_DaysAged` int(11) DEFAULT NULL,
  `WHJA_joReleaseDetailID` int(11) DEFAULT '0',
  `WHJA_vendorInvoiceNumber` varchar(45) DEFAULT NULL,
  `WHJA_ProjectManagerName` varchar(45) DEFAULT NULL,
  `WHJA_LocationAddress1` varchar(45) DEFAULT NULL,
  `WHJA_LocationAddress2` varchar(45) DEFAULT NULL,
  `WHJA_LocationCity` varchar(45) DEFAULT NULL,
  `WHJA_LocationState` varchar(45) DEFAULT NULL,
  `WHJA_LocationZip` varchar(45) DEFAULT NULL,
  `WHJA_Address1` varchar(45) DEFAULT NULL,
  `WHJA_Address2` varchar(45) DEFAULT NULL,
  `WHJA_City` varchar(45) DEFAULT NULL,
  `WHJA_State` varchar(45) DEFAULT NULL,
  `WHJA_Zip` varchar(45) DEFAULT NULL,
  `WHJA_Phone1` varchar(45) DEFAULT NULL,
  `WHJA_Phone2` varchar(45) DEFAULT NULL,
  `WHJA_Fax` varchar(45) DEFAULT NULL,
  `WHJA_County` varchar(45) DEFAULT NULL,
  `WHJA_TaxRate` decimal(19,4) DEFAULT '0.0000',
  `WHJA_isDrawInfo` tinyint(4) DEFAULT '0',
  `WHJA_DrawInfo` varchar(45) DEFAULT NULL,
  `WHJA_SellPrice` decimal(19,4) DEFAULT '0.0000',
  `WHJA_ExpenseAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_BillDate` datetime DEFAULT NULL,
  `WHJA_CostTotal` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VeBillBillAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VeBillAppliedAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VeBillFreightAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_CommAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_ShipDateAcknowledgement` varchar(10) DEFAULT NULL,
  `WHJA_VeBillTaxAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VeBillSubTotal` decimal(19,4) DEFAULT '0.0000',
  `WHJA_CuInvoiceDiscountAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VeCommInvoiceAmount` decimal(19,4) DEFAULT '0.0000',
  `WHJA_VeCommDate` datetime DEFAULT NULL,
  `WHJA_VeCommInvoiceNumber` varchar(45) DEFAULT NULL,
  `WHJA_VeCommDetailID` int(10) DEFAULT NULL,
  `WHJA_SODescription` varchar(50) DEFAULT NULL,
  `WHJA_SOQuantityOrderedCost` decimal(19,4) DEFAULT NULL,
  `WHJA_cuSODetailID` int(10) DEFAULT NULL,
  `WHJA_POCustomerPONumber` varchar(20) DEFAULT NULL,
  `WHJA_SOCustomerPONumber` varchar(20) DEFAULT NULL,
  `WHJA_JobNumberTypeRev` longtext,
  `WHJA_QuoteNumberType` longtext,
  `WHJA_JobStatusID` int(11),
  `WHJA_BidderID` int(11),
  `WHJA_QuoteTypeID` int(11),
  `WHJA_QuoteItemCategoryID` int(11),
  KEY `joMasterID` (`WHJA_joMasterID`),
  KEY `joReleaseID` (`WHJA_joReleaseID`),
  KEY `CustomerID` (`WHJA_CustomerID`),
  KEY `cuAssignmentID0` (`WHJA_cuAssignmentID0`),
  KEY `CuInvoiceDate` (`WHJA_CuInvoiceDate`),
  KEY `ReleaseDate` (`WHJA_ReleaseDate`),
  KEY `ReleaseType` (`WHJA_ReleaseType`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
*/

-- =========================================================================

DELIMITER ;



-- =================================================

-- select * from InvoiceView;

DROP view IF EXISTS `InvoiceView`;

DELIMITER $$

CREATE 
VIEW `InvoiceView` AS

    SELECT 
        `ci`.`cuInvoiceID` AS `cuInvoiceID`,
        `ci`.`joReleaseDetailID` AS `joReleaseDetailID`,
        `ci`.`coTaxTerritoryID` AS `coTaxTerritoryID`,
        `ci`.`InvoiceDate` AS `InvoiceDate`,
        (SELECT 
                `rxMaster`.`Name`
            FROM
                ((`rxMaster`
                LEFT JOIN `vePO` ON ((`vePO`.`rxVendorID` = `rxMaster`.`rxMasterID`)))
                LEFT JOIN `veBill` ON ((`veBill`.`vePOID` = `vePO`.`vePOID`)))
            WHERE
                (`veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)
            LIMIT 1) AS `vendorName`,
        (CASE
            WHEN (`ci`.`ShipToMode` = 1) THEN `rxA2`.`State`
            ELSE (CASE
                WHEN (`ci`.`ShipToMode` = 2) THEN `j`.`LocationState`
                ELSE (CASE
                    WHEN (`ci`.`ShipToMode` = 3) THEN `rxA1`.`State`
                    ELSE CONVERT( (CASE
                        WHEN
                            ((`ci`.`ShipToMode` = 0)
                                AND (`ci`.`veShipViaID` IS NOT NULL))
                        THEN
                            'NV'
                        ELSE NULL
                    END) USING UTF8)
                END)
            END)
        END) AS `ShipToState`,
        `ci`.`InvoiceNumber` AS `InvoiceNumber`,
        (CASE
            WHEN (`ci`.`TransactionStatus` = -(1)) THEN 'Void'
            ELSE (CASE
                WHEN (`ci`.`TransactionStatus` = 0) THEN 'Hold'
                ELSE (CASE
                    WHEN (`ci`.`TransactionStatus` = 1) THEN 'New'
                    ELSE 'Printed'
                END)
            END)
        END) AS `TransactionStatus`,
        `taxterr`.`County` AS `County`,
        `taxterr`.`CountyCode` AS `CountyCode`,
        `taxterr`.`State` AS `State`,
        `ci`.`InvoiceAmount` AS `InvoiceAmount`,
        `ci`.`DiscountAmt` AS `DiscountAmt`,
        `ci`.`Subtotal` AS `SubTotal`,
        `ci`.`Freight` AS `Freight`,
        IFNULL((SELECT 
                        MAX(`veBill`.`BillAmount`) AS `BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)),
                0) AS `InvoiceCostDrop`,
        `taxterr`.`TaxShipping` AS `TaxShippingFlag`,
        IF((`taxterr`.`TaxRate` = 0),
            0,
            (IF((`taxterr`.`TaxShipping` = 1),
                (`ci`.`Subtotal` + `ci`.`Freight`),
                `ci`.`Subtotal`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END))) AS `TaxableSales`,
        IF((`taxterr`.`TaxRate` = 0),
            (IF((`taxterr`.`TaxShipping` = 1),
                (`ci`.`Subtotal` + `ci`.`Freight`),
                (`ci`.`Subtotal` + `ci`.`Freight`)) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)),
            IF(((`ci`.`Subtotal` - IF((`taxterr`.`TaxShipping` = 1),
                    (`ci`.`Subtotal` + `ci`.`Freight`),
                    (`ci`.`Subtotal` + `ci`.`Freight`))) > 1),
                (`ci`.`Subtotal` - IF((`taxterr`.`TaxShipping` = 1),
                    (`ci`.`Subtotal` + `ci`.`Freight`),
                    (`ci`.`Subtotal` + `ci`.`Freight`))),
                0)) AS `NonTaxableSales`,
        `ci`.`TaxRate` AS `TaxRate`,
        (CASE
            WHEN (`ci`.`CreditMemo` = 1) THEN 1
            ELSE 1
        END) AS `ApplyTaxFlag`,
        `ci`.`TaxAmount` AS `TaxAmount`,
        (CASE
            WHEN ISNULL(`ci`.`CostTotal`) THEN 0
            ELSE `ci`.`CostTotal`
        END) AS `CostTotal`,
        (CASE
            WHEN
                ISNULL(`ci`.`cuSOID`)
            THEN
                (CASE
                    WHEN ISNULL(`ci`.`whseCostTotal`) THEN 0
                    ELSE `ci`.`whseCostTotal`
                END)
            ELSE (CASE
                WHEN ISNULL(`so`.`whseCostTotal`) THEN 0
                ELSE `so`.`whseCostTotal`
            END)
        END) AS `whseCostTotal`,
        (CASE
            WHEN ISNULL(`jo`.`cost`) THEN 0
            ELSE `jo`.`cost`
        END) AS `AddCost`,
        FORMAT((((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`TaxRate`) - ((((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution1`) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution2`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution3`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution4`)) + ((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution5`))) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `StateTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution1`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CityTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution2`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CountyTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution3`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `MTATax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution4`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `CCDTax`,
        FORMAT(((((0.01 * (CASE
                WHEN (`taxterr`.`TaxShipping` = 1) THEN (`ci`.`Subtotal` + `ci`.`Freight`)
                ELSE `ci`.`Subtotal`
            END)) * `taxterr`.`Distribution5`) * (CASE
                WHEN (`ci`.`CreditMemo` = 1) THEN 1
                ELSE 1
            END)) * (CASE
                WHEN
                    ((`ci`.`memoStatus` = 0)
                        AND (`ci`.`CreditMemo` = 1))
                THEN
                    0
                ELSE 1
            END)),
            2) AS `OtherTax`,
        `u`.`FullName` AS `CreateBy`,
        `jo`.`enteredBy` AS `AddCostEnteredBy`,
        `jo`.`enteredDate` AS `AddCostEnteredDate`,
        `ci`.`CreatedOn` AS `CreatedOn`,
        `ci`.`ChangedOn` AS `ChangedOn`,
        `ci`.`ChangedByID` AS `ChangedByID`,
        (CASE
            WHEN
                ((`ci`.`memoStatus` = 0)
                    AND (`ci`.`CreditMemo` = 1))
            THEN
                0
            ELSE 1
        END) AS `IsRollbackFlag`,
        `ci`.`memoStatus` AS `memoStatusFlag`,
        `ci`.`CreditMemo` AS `CreditMemoFlag`,
        `ci`.`IsCredit` AS `IsCreditFlag`,
        `taxterr`.`Distribution1` AS `TaxDistribution1`,
        `taxterr`.`Distribution2` AS `TaxDistribution2`,
        `taxterr`.`Distribution3` AS `TaxDistribution3`,
        `taxterr`.`Distribution4` AS `TaxDistribution4`,
        `taxterr`.`Distribution5` AS `TaxDistribution5`,
        `rxm`.`Name` AS `CustomerName`,
        `ci`.`PrintDate` AS `PrintDate`,
        `ci`.`AppliedAmount` AS `AppliedAmount`,
        `ci`.`Description` AS `Description`,
        `ci`.`Note` AS `Note`,
        `ci`.`CustomerPONumber` AS `PONumber`,
        `j`.`Description` AS `JobDescription`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`JobStatus` AS `JobStatusID`,
        `js`.`JobStatus` AS `JobStatus`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `r`.`ReleaseType` AS `ReleaseType`,
        IFNULL(`rt`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
        `sp`.`FullName` AS `SalesPersonName`,
        `ci`.`cuAssignmentID0` AS `SalesPersonID`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`,
        `j`.`joMasterID` AS `joMasterID`
    FROM
        ((((((((((((((((((`cuInvoice` `ci`
        LEFT JOIN `cuSO` `so` ON ((`ci`.`cuSOID` = `so`.`cuSOID`)))
        LEFT JOIN `tsUserLogin` `u` ON ((`ci`.`CreatedByID` = `u`.`UserLoginID`)))
        LEFT JOIN `joInvoiceCost` `jo` ON ((`ci`.`joReleaseDetailID` = `jo`.`joReleaseDetailID`)))
        LEFT JOIN `coTaxTerritory` `taxterr` ON ((`taxterr`.`coTaxTerritoryID` = `ci`.`coTaxTerritoryID`)))
        LEFT JOIN `rxMaster` `rxm` ON ((`rxm`.`rxMasterID` = `ci`.`rxCustomerID`)))
        LEFT JOIN `rxAddress` `rxA` ON ((`rxA`.`rxMasterID` = `ci`.`rxShipToID`)))
        LEFT JOIN `rxAddress` `rxA2` ON ((`rxA2`.`rxAddressID` = `ci`.`rxShipToID`)))
        LEFT JOIN `joReleaseDetail` `rd` ON ((`rd`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `r` ON ((`r`.`joReleaseID` = `rd`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `r`.`joMasterID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
        LEFT JOIN `rxAddress` `rxA1` ON ((`rxA1`.`rxAddressID` = `ci`.`rxShipToAddressID`)))
        LEFT JOIN `joStatus` `js` ON ((`js`.`joStatusID` = `j`.`JobStatus`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `ci`.`coDivisionID`)))
        LEFT JOIN `joReleaseType` `rt` ON ((`r`.`ReleaseType` = `rt`.`joReleaseTypeID`)))
        LEFT JOIN `tsUserLogin` `sp` ON ((`sp`.`UserLoginID` = `ci`.`cuAssignmentID0`)))
    GROUP BY `ci`.`cuInvoiceID`;


-- ===================================================================


DROP VIEW  IF EXISTS BaseInvoiceView;

/* adding engineer and sales engineer */

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `BaseInvoiceView` AS
    SELECT DISTINCT
        `cc`.`cuInvoiceID` AS `InvoiceID`,
        `cc`.`InvoiceNumber` AS `InvoiceNumber`,
        `cc`.`InvoiceDate` AS `InvoiceDate`,
        (SELECT 
                `joReleaseDetail`.`joReleaseID`
            FROM
                `joReleaseDetail`
            WHERE
                (`joReleaseDetail`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)) AS `ReleaseId`,
        `cc`.`joReleaseDetailID` AS `ReleasedetailID`,
        `cc`.`InvoiceAmount` AS `InvoiceAmount`,
        IFNULL(`cc`.`DiscountAmt`, 0) AS `Discount`,
        (`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) AS `AmountToBePaid`,
        `cc`.`AppliedAmount` AS `AmountPaid`,
        ((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) AS `CustomerBalance`,
        IF((IFNULL(`em`.`CommAfterPayment`, 1) = 1),
            IF((((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) = 0),
                IF((`cc`.`InvoiceAmount` <> 0),
                    (SELECT 
                            MAX(`cuLinkageDetail`.`datePaid`) AS `datePaid`
                        FROM
                            `cuLinkageDetail`
                        WHERE
                            (`cuLinkageDetail`.`cuInvoiceID` = `cc`.`cuInvoiceID`)),
                    `cc`.`InvoiceDate`),
                NULL),
            (`cc`.`InvoiceDate` + INTERVAL IFNULL(`em`.`dayAfter`, 0) DAY)) AS `CustomerDatePaid`,
        IFNULL(`cc`.`FreightCost`, 0) AS `AddCostTotal`,
        `cc`.`cuAssignmentID0` AS `SalesPerson`,
        `cc`.`cuAssignmentID0` AS `SalesPersonID`,
        (SELECT 
                `tsUserLogin`.`FullName`
            FROM
                `tsUserLogin`
            WHERE
                (`tsUserLogin`.`UserLoginID` = `cc`.`cuAssignmentID0`)) AS `SalesPersonName`,
        `cc`.`Subtotal` AS `InvoiceSubtotal`,
        `cc`.`Freight` AS `Freight`,
        IFNULL(`cc`.`CostTotal`, 0) AS `InvoiceCostStock`,
        (IFNULL((SELECT 
                        `veBill`.`BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)),
                0) + IFNULL((SELECT 
                        SUM(`veBill`.`BillAmount`)
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`cuInvoiceID_ApplyCost` = `cc`.`cuInvoiceID`)
                    GROUP BY `veBill`.`cuInvoiceID_ApplyCost`),
                0)) AS `InvoiceCostDrop`,
        IFNULL(`v`.`FreightAmount`, 0) AS `InvoiceCostDropFreight`,
        IF((`v`.`UsePostDate` = 0),
            IFNULL(`v`.`BillDate`, 0),
            IFNULL(`v`.`PostDate`, 0)) AS `BillDate`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`Description` AS `JobName`,
        `cc`.`memoStatus` AS `Info_memoStatus`,
        `cc`.`CreditMemo` AS `Info_CreditMemo`,
        `cc`.`rxCustomerID` AS `Info_rxCustomerID`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `crx`.`Name` AS `CustomerName`,
        `cc`.`cuInvoiceID` AS `Info_cuInvoiceID`,
        `jr`.`ReleaseType` AS `Info_ReleaseType`,
        `jr`.`joMasterID` AS `joMasterID`,
        `em`.`isJobPaidInFull` AS `isJobPaidInFull`,
        `em`.`UserLoginID` AS `UserLoginID`,
        `em`.`emMasterID` AS `emMasterID`,
        `eS`.`joMasterID` AS `esjoMasterID`,
        IFNULL(`eS`.`joReleaseID`,
                IF(ISNULL(`eS`.`IsRelease`),
                    10102,
                    10101)) AS `esJoReleaseID`,
        `eS`.`IsRelease` AS `esIsRelease`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`
    FROM
        (((((((((((`cuInvoice` `cc`
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `joReleaseDetail` `jrd` ON ((`cc`.`joReleaseDetailID` = `jrd`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `jr` ON ((`jr`.`joReleaseID` = `jrd`.`joReleaseID`)))
        LEFT JOIN `ecSplitJob` `eS` ON ((`jr`.`joReleaseID` = `eS`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `jr`.`joMasterID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
    WHERE
        ((`em`.`isJobPaidInFull` = 0)
            AND (`cc`.`InvoiceDate` >= '2017-10-01')
            AND (`cc`.`joReleaseDetailID` IS NOT NULL)) 
    UNION ALL SELECT DISTINCT
        `cc`.`cuInvoiceID` AS `InvoiceID`,
        `cc`.`InvoiceNumber` AS `InvoiceNumber`,
        `cc`.`InvoiceDate` AS `InvoiceDate`,
        (SELECT 
                `joReleaseDetail`.`joReleaseID`
            FROM
                `joReleaseDetail`
            WHERE
                (`joReleaseDetail`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)) AS `ReleaseId`,
        `cc`.`joReleaseDetailID` AS `ReleasedetailID`,
        `cc`.`InvoiceAmount` AS `InvoiceAmount`,
        IFNULL(`cc`.`DiscountAmt`, 0) AS `Discount`,
        (`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) AS `AmountToBePaid`,
        `cc`.`AppliedAmount` AS `AmountPaid`,
        ((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) AS `CustomerBalance`,
        IF((IFNULL(`em`.`isFollowingPeriod`, 1) = 0),
            IF((((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) = 0),
                IF((`cc`.`InvoiceAmount` <> 0),
                    (SELECT 
                            MAX(`cuLinkageDetail`.`datePaid`) AS `datePaid`
                        FROM
                            `cuLinkageDetail`
                        WHERE
                            (`cuLinkageDetail`.`cuInvoiceID` = `cc`.`cuInvoiceID`)),
                    `cc`.`InvoiceDate`),
                NULL),
            (`cc`.`InvoiceDate` + INTERVAL 30 DAY)) AS `CustomerDatePaid`,
        IFNULL(`cc`.`FreightCost`, 0) AS `AddCostTotal`,
        `cc`.`cuAssignmentID0` AS `SalesPerson`,
        `cc`.`cuAssignmentID0` AS `SalesPersonID`,
        (SELECT 
                `tsUserLogin`.`FullName`
            FROM
                `tsUserLogin`
            WHERE
                (`tsUserLogin`.`UserLoginID` = `cc`.`cuAssignmentID0`)) AS `SalesPersonName`,
        `cc`.`Subtotal` AS `InvoiceSubtotal`,
        `cc`.`Freight` AS `Freight`,
        IFNULL(`cc`.`CostTotal`, 0) AS `InvoiceCostStock`,
        (IFNULL((SELECT 
                        `veBill`.`BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)),
                0) + IFNULL((SELECT 
                        SUM(`veBill`.`BillAmount`)
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`cuInvoiceID_ApplyCost` = `cc`.`cuInvoiceID`)
                    GROUP BY `veBill`.`cuInvoiceID_ApplyCost`),
                0)) AS `InvoiceCostDrop`,
        IFNULL(`v`.`FreightAmount`, 0) AS `InvoiceCostDropFreight`,
        IF((`v`.`UsePostDate` = 0),
            IFNULL(`v`.`BillDate`, 0),
            IFNULL(`v`.`PostDate`, 0)) AS `BillDate`,
        `j`.`JobNumber` AS `JobNumber`,
        `j`.`Description` AS `JobName`,
        `cc`.`memoStatus` AS `Info_memoStatus`,
        `cc`.`CreditMemo` AS `Info_CreditMemo`,
        `cc`.`rxCustomerID` AS `Info_rxCustomerID`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `crx`.`Name` AS `CustomerName`,
        `cc`.`cuInvoiceID` AS `Info_cuInvoiceID`,
        `jr`.`ReleaseType` AS `Info_ReleaseType`,
        `jr`.`joMasterID` AS `joMasterID`,
        `em`.`isJobPaidInFull` AS `isJobPaidInFull`,
        `em`.`UserLoginID` AS `UserLoginID`,
        `em`.`emMasterID` AS `emMasterID`,
        `eS`.`joMasterID` AS `esjoMasterID`,
        IFNULL(`eS`.`joReleaseID`,
                IF(ISNULL(`eS`.`IsRelease`),
                    10102,
                    10101)) AS `esJoReleaseID`,
        `eS`.`IsRelease` AS `esIsRelease`,
        `engineer`.`Name` AS `Engineer`,
        `sales_engineer`.`FullName` AS `SalesEngineer`
    FROM
        ((((((((((((`JobCustomerInvoiceInsideView` `tb2`
        LEFT JOIN `cuInvoice` `cc` ON ((`tb2`.`cuInvoiceID` = `cc`.`cuInvoiceID`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `joReleaseDetail` `jrd` ON ((`cc`.`joReleaseDetailID` = `jrd`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `jr` ON ((`jr`.`joReleaseID` = `jrd`.`joReleaseID`)))
        LEFT JOIN `ecSplitJob` `eS` ON ((`jr`.`joReleaseID` = `eS`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `tb2`.`joMasterID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
        LEFT JOIN `rxMaster` `engineer` ON ((`engineer`.`rxMasterID` = `j`.`rxCategory2`)))
        LEFT JOIN `rxMasterCategory1` `rxmc1` ON ((`rxmc1`.`rxMasterCategory1ID` = `j`.`rxCategory2`)))
        LEFT JOIN `tsUserLogin` `sales_engineer` ON ((`sales_engineer`.`UserLoginID` = `rxmc1`.`cuAssignmentID0`)))
    WHERE
        ((`em`.`isJobPaidInFull` = 1)
            AND (`cc`.`InvoiceDate` >= '2017-10-01')
            AND (`cc`.`joReleaseDetailID` IS NOT NULL)) 
    UNION ALL SELECT DISTINCT
        `cc`.`cuInvoiceID` AS `InvoiceID`,
        `cc`.`InvoiceNumber` AS `InvoiceNumber`,
        `cc`.`InvoiceDate` AS `InvoiceDate`,
        0 AS `ReleaseId`,
        `cc`.`joReleaseDetailID` AS `ReleasedetailID`,
        `cc`.`InvoiceAmount` AS `InvoiceAmount`,
        IFNULL(`cc`.`DiscountAmt`, 0) AS `Discount`,
        (`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) AS `AmountToBePaid`,
        `cc`.`AppliedAmount` AS `AmountPaid`,
        ((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) AS `CustomerBalance`,
        IF((IFNULL(`em`.`CommAfterPayment`, 1) = 1),
            IF((((`cc`.`InvoiceAmount` - IFNULL(`cc`.`DiscountAmt`, 0)) - `cc`.`AppliedAmount`) = 0),
                IF((`cc`.`InvoiceAmount` <> 0),
                    (SELECT 
                            MAX(`cuLinkageDetail`.`datePaid`) AS `datePaid`
                        FROM
                            `cuLinkageDetail`
                        WHERE
                            (`cuLinkageDetail`.`cuInvoiceID` = `cc`.`cuInvoiceID`)),
                    `cc`.`InvoiceDate`),
                NULL),
            (`cc`.`InvoiceDate` + INTERVAL IFNULL(`em`.`dayAfter`, 0) DAY)) AS `CustomerDatePaid`,
        IFNULL(`cc`.`FreightCost`, 0) AS `AddCostTotal`,
        `cc`.`cuAssignmentID0` AS `SalesPerson`,
        `cc`.`cuAssignmentID0` AS `SalesPersonID`,
        (SELECT 
                `tsUserLogin`.`FullName`
            FROM
                `tsUserLogin`
            WHERE
                (`tsUserLogin`.`UserLoginID` = `cc`.`cuAssignmentID0`)) AS `SalesPersonName`,
        `cc`.`Subtotal` AS `InvoiceSubtotal`,
        `cc`.`Freight` AS `Freight`,
        IFNULL(`cc`.`CostTotal`, 0) AS `InvoiceCostStock`,
        0.0000 AS `InvoiceCostDrop`,
        IFNULL(`v`.`FreightAmount`, 0) AS `InvoiceCostDropFreight`,
        0 AS `BillDate`,
        NULL AS `JobNumber`,
        NULL AS `JobName`,
        `cc`.`memoStatus` AS `Info_memoStatus`,
        `cc`.`CreditMemo` AS `Info_CreditMemo`,
        `cc`.`rxCustomerID` AS `Info_rxCustomerID`,
        `div`.`coDivisionID` AS `coDivisionID`,
        `div`.`Description` AS `DivDescription`,
        `div`.`Code` AS `DivCode`,
        `crx`.`Name` AS `CustomerName`,
        `cc`.`cuInvoiceID` AS `Info_cuInvoiceID`,
        NULL AS `Info_ReleaseType`,
        NULL AS `joMasterID`,
        `em`.`isJobPaidInFull` AS `isJobPaidInFull`,
        `em`.`UserLoginID` AS `UserLoginID`,
        `em`.`emMasterID` AS `emMasterID`,
        0 AS `esjoMasterID`,
        0 AS `esJoReleaseID`,
        0 AS `esIsRelease`,
        NULL AS `Engineer`,
        NULL AS `SalesEngineer`
    FROM
        ((((`OutsidejobView` `cc`
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
    WHERE
        ((`em`.`isJobPaidInFull` = 1)
            AND (`cc`.`InvoiceDate` >= '2017-10-01')
            AND (`cc`.`joReleaseDetailID` = 0));
