
update tp_version set viewVersion=12,viewVersionDesc='BaseInvoiceView' where versionId >0;

-- ======================================

DROP VIEW IF EXISTS InventoryActivityView1;

CREATE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `InventoryActivityView1` AS
    SELECT 
        `d`.`Description` AS `Department`,
        `c`.`Description` AS `Category`,
        `pr`.`ItemCode` AS `ItemCode`,
        `pr`.`Description` AS `Description`,
        `pr`.`InActive` AS `IsActive`,
        `pr`.`IsTaxable` AS `IsTaxable`,
        `pr`.`IsInventory` AS `IsInventory`,
        `pr`.`prMasterID` AS `prMasterID`,
        `pr`.`AverageCost` AS `AverageCost`,
        `pr`.`POMult` AS `Multiplier`,
        FORMAT(`pr`.`LastCost`, 2) AS `FactoryCost`,
        `pwi`.`prWarehouseID` AS `WarehouseID`,
        `pw`.`Description` AS `Warehouse`,
        FORMAT(`pr`.`InventoryOnHand`, 0) AS `PrOnHand`,
        FORMAT(`pwi`.`InventoryOnHand`, 0) AS `WrOnHand`,
        FORMAT(`pr`.`InventoryAllocated`, 0) AS `PrAllocated`,
        FORMAT(`pwi`.`InventoryAllocated`, 0) AS `WrAllocated`,
        FORMAT(`pr`.`InventoryOnOrder`, 0) AS `PrOnOrder`,
        FORMAT(`pwi`.`InventoryOnOrder`, 0) AS `WrOnOrder`,
        `vpo`.`OrderDate` AS `POOrderDate`,
        `vpo`.`PONumber` AS `PONumber`,
        `vpo`.`rxVendorID` AS `POVendorID`,
        `rx`.`Name` AS `POVendorName`,
        'Purchase Order' AS `TransactionType`,
        `vpo`.`TransactionStatus` AS `POTransactionStatus`,
        (CASE
            WHEN (`vpo`.`TransactionStatus` = 1) THEN 'OPEN'
            ELSE (CASE
                WHEN (`vpo`.`TransactionStatus` = 2) THEN 'CLOSE'
                ELSE (CASE
                    WHEN (`vpo`.`TransactionStatus` = 0) THEN 'HOLD'
                    ELSE 'VOID'
                END)
            END)
        END) AS `TransactionStatusDesc`,
        `vpo`.`CreatedByID` AS `POCreatedBy`,
        `vpo`.`CreatedOn` AS `POCreatedOn`,
        `vpo`.`ChangedByID` AS `POChangeddBy`,
        `vpo`.`ChangedOn` AS `POChangedOn`,
        (CASE
            WHEN ISNULL(`vpo`.`joReleaseID`) THEN (IFNULL(`vpod`.`QuantityOrdered`, 0) - IFNULL(`vpod`.`QuantityReceived`, 0))
            ELSE 0
        END) AS `PODnventoryOnOrder`,
        -- FORMAT(`vpod`.`QuantityInvoiced`, 0) AS `PODVendorInvoiced`,
        FORMAT(`vpod`.QuantityBilled, 0) AS `PODVendorInvoiced`,
        FORMAT(`vpod`.`QuantityReceived`, 0) AS `PODInventoryReceived`,
        FORMAT((`vpod`.`QuantityOrdered` - `vpod`.`QuantityReceived`),
            0) AS `PODInventoryNotReceived`,
        FORMAT(`vpod`.`UnitCost`, 2) AS `PODUnitCost`,
        NULL AS `SOID`,
        NULL AS `SOCreatedBy`,
        NULL AS `SOCreatedOn`,
        NULL AS `CustID`,
        NULL AS `CustomerName`,
        0 AS `SOQuantityOrdered`,
        0 AS `SOQuantityInvoiced`,
        0 AS `SONotInvoiced`
    FROM
        ((((((( `prMaster` `pr`
        LEFT JOIN  `prDepartment` `d` ON ((`pr`.`prDepartmentID` = `d`.`prDepartmentID`)))
        LEFT JOIN  `prCategory` `c` ON ((`pr`.`prCategoryID` = `c`.`prCategoryID`)))
        LEFT JOIN  `prWarehouseInventory` `pwi` ON ((`pr`.`prMasterID` = `pwi`.`prMasterID`)))
        LEFT JOIN  `prWarehouse` `pw` ON ((`pwi`.`prWarehouseID` = `pw`.`prWarehouseID`)))
        LEFT JOIN  `vePO` `vpo` ON ((`vpo`.`prWarehouseID` = `pwi`.`prWarehouseID`)))
        LEFT JOIN  `vePODetail` `vpod` ON ((`vpo`.`vePOID` = `vpod`.`vePOID`)))
        LEFT JOIN  `rxMaster` `rx` ON ((`vpo`.`rxVendorID` = `rx`.`rxMasterID`)))
    WHERE
        ((`vpo`.`prWarehouseID` IS NOT NULL)
            AND ISNULL(`vpo`.`joReleaseID`)
            AND (`vpod`.`prMasterID` = `pr`.`prMasterID`)
            AND (`vpo`.`TransactionStatus` <> -(1))) 
    UNION ALL SELECT 
        `d`.`Description` AS `Department`,
        `c`.`Description` AS `Category`,
        `pr`.`ItemCode` AS `ItemCode`,
        `pr`.`Description` AS `Description`,
        `pr`.`InActive` AS `IsActive`,
        `pr`.`IsTaxable` AS `IsTaxable`,
        `pr`.`IsInventory` AS `IsInventory`,
        `pr`.`prMasterID` AS `prMasterID`,
        `pr`.`AverageCost` AS `AverageCost`,
        `pr`.`POMult` AS `Multiplier`,
        FORMAT(`pr`.`LastCost`, 2) AS `FactoryCost`,
        `pwi`.`prWarehouseID` AS `WarehouseID`,
        `pw`.`Description` AS `Warehouse`,
        FORMAT(`pr`.`InventoryOnHand`, 0) AS `PrOnHand`,
        FORMAT(`pwi`.`InventoryOnHand`, 0) AS `WrOnHand`,
        FORMAT(`pr`.`InventoryAllocated`, 0) AS `PrAllocated`,
        FORMAT(`pwi`.`InventoryAllocated`, 0) AS `WrAllocated`,
        FORMAT(`pr`.`InventoryOnOrder`, 0) AS `PrOnOrder`,
        FORMAT(`pwi`.`InventoryOnOrder`, 0) AS `WrOnOrder`,
        `prwht`.`TransferDate` AS `POOrderDate`,
        CAST(`prwht`.`TransNumber` AS CHAR CHARSET UTF8) AS `PONumber`,
        0 AS `POVendorID`,
        'Warehouse Transfer In' AS `POVendorName`,
        'Transfer' AS `TransactionType`,
        NULL AS `POTransactionStatus`,
        NULL AS `TransactionStatusDesc`,
        `prwht`.`CreatedById` AS `POCreatedBy`,
        `prwht`.`CreatedOn` AS `POCreatedOn`,
        NULL AS `POChangeddBy`,
        NULL AS `POChangedOn`,
        FORMAT(`prwhtd`.`QuantityTransfered`, 0) AS `PODnventoryOnOrder`,
        0 AS `PODVendorInvoiced`,
        0 AS `PODInventoryReceived`,
        FORMAT(`prwhtd`.`QuantityTransfered`, 0) AS `PODInventoryNotReceived`,
        FORMAT(`prwhtd`.`InventoryCost`, 2) AS `PODUnitCost`,
        NULL AS `SOID`,
        NULL AS `SOCreatedBy`,
        NULL AS `SOCreatedOn`,
        NULL AS `CustID`,
        `pw`.`Description` AS `CustomerName`,
        0 AS `SOQuantityOrdered`,
        0 AS `SOQuantityInvoiced`,
        FORMAT(`prwhtd`.`QuantityTransfered`, 0) AS `SONotInvoiced`
    FROM
        (((((( `prMaster` `pr`
        LEFT JOIN  `prDepartment` `d` ON ((`pr`.`prDepartmentID` = `d`.`prDepartmentID`)))
        LEFT JOIN  `prCategory` `c` ON ((`pr`.`prCategoryID` = `c`.`prCategoryID`)))
        LEFT JOIN  `prWarehouseInventory` `pwi` ON ((`pr`.`prMasterID` = `pwi`.`prMasterID`)))
        LEFT JOIN  `prWarehouse` `pw` ON ((`pwi`.`prWarehouseID` = `pw`.`prWarehouseID`)))
        LEFT JOIN  `prWHtransfer` `prwht` ON ((`prwht`.`prToWareHouseID` = `pwi`.`prWarehouseID`)))
        LEFT JOIN  `prWHtransferDetail` `prwhtd` ON ((`prwhtd`.`prTransferID` = `prwht`.`prTransferID`)))
    WHERE
        ((`prwht`.`prToWareHouseID` IS NOT NULL)
            AND ISNULL(`prwhtd`.`ReceivedDate`)
            AND (`prwhtd`.`prMasterID` = `pr`.`prMasterID`)) 
    UNION ALL SELECT 
        `d`.`Description` AS `Department`,
        `c`.`Description` AS `Category`,
        `pr`.`ItemCode` AS `ItemCode`,
        `pr`.`Description` AS `Description`,
        `pr`.`InActive` AS `IsActive`,
        `pr`.`IsTaxable` AS `IsTaxable`,
        `pr`.`IsInventory` AS `IsInventory`,
        `pr`.`prMasterID` AS `prMasterID`,
        `pr`.`AverageCost` AS `AverageCost`,
        `pr`.`POMult` AS `Multiplier`,
        FORMAT(`pr`.`LastCost`, 2) AS `FactoryCost`,
        `pwi`.`prWarehouseID` AS `WarehouseID`,
        `pw`.`Description` AS `Warehouse`,
        FORMAT(`pr`.`InventoryOnHand`, 0) AS `PrOnHand`,
        FORMAT(`pwi`.`InventoryOnHand`, 0) AS `WrOnHand`,
        FORMAT(`pr`.`InventoryAllocated`, 0) AS `PrAllocated`,
        FORMAT(`pwi`.`InventoryAllocated`, 0) AS `WrAllocated`,
        FORMAT(`pr`.`InventoryOnOrder`, 0) AS `PrOnOrder`,
        FORMAT(`pwi`.`InventoryOnOrder`, 0) AS `WrOnOrder`,
        NULL AS `POOrderDate`,
        `cs`.`SONumber` AS `PONumber`,
        NULL AS `POVendorID`,
        NULL AS `POVendorName`,
        'Sales Order' AS `TransactionType`,
        NULL AS `POTransactionStatus`,
        NULL AS `TransactionStatusDesc`,
        NULL AS `POCreatedBy`,
        NULL AS `POCreatedOn`,
        NULL AS `POChangeddBy`,
        NULL AS `POChangedOn`,
        0 AS `PODnventoryOnOrder`,
        0 AS `PODVendorInvoiced`,
        0 AS `PODInventoryReceived`,
        0 AS `PODInventoryNotReceived`,
        0 AS `PODUnitCost`,
        `cs`.`cuSOID` AS `SOID`,
        `cs`.`CreatedByID` AS `SOCreatedBy`,
        `cs`.`CreatedOn` AS `SOCreatedOn`,
        `cs`.`rxCustomerID` AS `CustID`,
        `rx`.`Name` AS `CustomerName`,
        FORMAT(IFNULL(`csd`.`QuantityOrdered`, 0),
            0) AS `SOQuantityOrdered`,
        FORMAT(IFNULL(`csd`.`QuantityBilled`, 0),
            0) AS `SOQuantityInvoiced`,
        FORMAT((IFNULL(`csd`.`QuantityOrdered`, 0) - IFNULL(`csd`.`QuantityBilled`, 0)),
            0) AS `SONotInvoiced`
    FROM
        ((((((( `prMaster` `pr`
        LEFT JOIN  `prDepartment` `d` ON ((`pr`.`prDepartmentID` = `d`.`prDepartmentID`)))
        LEFT JOIN  `prCategory` `c` ON ((`pr`.`prCategoryID` = `c`.`prCategoryID`)))
        LEFT JOIN  `prWarehouseInventory` `pwi` ON ((`pr`.`prMasterID` = `pwi`.`prMasterID`)))
        LEFT JOIN  `prWarehouse` `pw` ON ((`pwi`.`prWarehouseID` = `pw`.`prWarehouseID`)))
        LEFT JOIN  `cuSO` `cs` ON ((`cs`.`prFromWarehouseID` = `pwi`.`prWarehouseID`)))
        LEFT JOIN  `cuSODetail` `csd` ON ((`csd`.`cuSOID` = `cs`.`cuSOID`)))
        LEFT JOIN  `rxMaster` `rx` ON ((`cs`.`rxCustomerID` = `rx`.`rxMasterID`)))
    WHERE
        ((`cs`.`prFromWarehouseID` IS NOT NULL)
            AND (`csd`.`prMasterID` = `pr`.`prMasterID`)
            AND (`cs`.`TransactionStatus` = 1)) 
    UNION ALL SELECT 
        `d`.`Description` AS `Department`,
        `c`.`Description` AS `Category`,
        `pr`.`ItemCode` AS `ItemCode`,
        `pr`.`Description` AS `Description`,
        `pr`.`InActive` AS `IsActive`,
        `pr`.`IsTaxable` AS `IsTaxable`,
        `pr`.`IsInventory` AS `IsInventory`,
        `pr`.`prMasterID` AS `prMasterID`,
        `pr`.`AverageCost` AS `AverageCost`,
        `pr`.`POMult` AS `Multiplier`,
        FORMAT(`pr`.`LastCost`, 2) AS `FactoryCost`,
        `pwi`.`prWarehouseID` AS `WarehouseID`,
        `pw`.`Description` AS `Warehouse`,
        FORMAT(`pr`.`InventoryOnHand`, 0) AS `PrOnHand`,
        FORMAT(`pwi`.`InventoryOnHand`, 0) AS `WrOnHand`,
        FORMAT(`pr`.`InventoryAllocated`, 0) AS `PrAllocated`,
        FORMAT(`pwi`.`InventoryAllocated`, 0) AS `WrAllocated`,
        FORMAT(`pr`.`InventoryOnOrder`, 0) AS `PrOnOrder`,
        FORMAT(`pwi`.`InventoryOnOrder`, 0) AS `WrOnOrder`,
        `prwht`.`TransferDate` AS `POOrderDate`,
        CAST(`prwht`.`TransNumber` AS CHAR CHARSET UTF8) AS `PONumber`,
        0 AS `POVendorID`,
        'Warehouse Transfer Out' AS `POVendorName`,
        'Transfer' AS `TransactionType`,
        NULL AS `POTransactionStatus`,
        NULL AS `TransactionStatusDesc`,
        NULL AS `POCreatedBy`,
        NULL AS `POCreatedOn`,
        NULL AS `POChangeddBy`,
        NULL AS `POChangedOn`,
        0 AS `PODnventoryOnOrder`,
        0 AS `PODVendorInvoiced`,
        0 AS `PODInventoryReceived`,
        0 AS `PODInventoryNotReceived`,
        0 AS `PODUnitCost`,
        NULL AS `SOID`,
        `prwht`.`CreatedById` AS `SOCreatedBy`,
        `prwht`.`CreatedOn` AS `SOCreatedOn`,
        NULL AS `CustID`,
        `pw`.`Description` AS `CustomerName`,
        FORMAT(`prwhtd`.`QuantityTransfered`, 0) AS `SOQuantityOrdered`,
        0 AS `SOQuantityInvoiced`,
        FORMAT(`prwhtd`.`QuantityTransfered`, 0) AS `SONotInvoiced`
    FROM
        (((((( `prMaster` `pr`
        LEFT JOIN  `prDepartment` `d` ON ((`pr`.`prDepartmentID` = `d`.`prDepartmentID`)))
        LEFT JOIN  `prCategory` `c` ON ((`pr`.`prCategoryID` = `c`.`prCategoryID`)))
        LEFT JOIN  `prWarehouseInventory` `pwi` ON ((`pr`.`prMasterID` = `pwi`.`prMasterID`)))
        LEFT JOIN  `prWarehouse` `pw` ON ((`pwi`.`prWarehouseID` = `pw`.`prWarehouseID`)))
        LEFT JOIN  `prWHtransfer` `prwht` ON ((`prwht`.`prFromWareHouseID` = `pwi`.`prWarehouseID`)))
        LEFT JOIN  `prWHtransferDetail` `prwhtd` ON ((`prwhtd`.`prTransferID` = `prwht`.`prTransferID`)))
    WHERE
        ((`prwht`.`prToWareHouseID` IS NOT NULL)
            AND ISNULL(`prwhtd`.`ReceivedDate`)
            AND (`prwhtd`.`prMasterID` = `pr`.`prMasterID`)) 
    UNION ALL SELECT 
        `d`.`Description` AS `Department`,
        `c`.`Description` AS `Category`,
        `pr`.`ItemCode` AS `ItemCode`,
        `pr`.`Description` AS `Description`,
        `pr`.`InActive` AS `IsActive`,
        `pr`.`IsTaxable` AS `IsTaxable`,
        `pr`.`IsInventory` AS `IsInventory`,
        `pr`.`prMasterID` AS `prMasterID`,
        `pr`.`AverageCost` AS `AverageCost`,
        `pr`.`POMult` AS `Multiplier`,
        FORMAT(`pr`.`LastCost`, 2) AS `FactoryCost`,
        `pwi`.`prWarehouseID` AS `WarehouseID`,
        `pw`.`Description` AS `Warehouse`,
        FORMAT(`pr`.`InventoryOnHand`, 0) AS `PrOnHand`,
        FORMAT(`pwi`.`InventoryOnHand`, 0) AS `WrOnHand`,
        FORMAT(`pr`.`InventoryAllocated`, 0) AS `PrAllocated`,
        FORMAT(`pwi`.`InventoryAllocated`, 0) AS `WrAllocated`,
        FORMAT(`pr`.`InventoryOnOrder`, 0) AS `PrOnOrder`,
        FORMAT(`pwi`.`InventoryOnOrder`, 0) AS `WrOnOrder`,
        NULL AS `POOrderDate`,
        0 AS `PONumber`,
        0 AS `POVendorID`,
        NULL AS `POVendorName`,
        'Inventory' AS `TransactionType`,
        NULL AS `POTransactionStatus`,
        NULL AS `TransactionStatusDesc`,
        NULL AS `POCreatedBy`,
        NULL AS `POCreatedOn`,
        NULL AS `POChangeddBy`,
        NULL AS `POChangedOn`,
        0 AS `PODnventoryOnOrder`,
        0 AS `PODVendorInvoiced`,
        0 AS `PODInventoryReceived`,
        0 AS `PODInventoryNotReceived`,
        0 AS `PODUnitCost`,
        NULL AS `SOID`,
        NULL AS `SOCreatedBy`,
        NULL AS `SOCreatedOn`,
        NULL AS `CustID`,
        NULL AS `CustomerName`,
        0 AS `SOQuantityOrdered`,
        0 AS `SOQuantityInvoiced`,
        0 AS `SONotInvoiced`
    FROM
        (((( `prMaster` `pr`
        LEFT JOIN  `prDepartment` `d` ON ((`pr`.`prDepartmentID` = `d`.`prDepartmentID`)))
        LEFT JOIN  `prCategory` `c` ON ((`pr`.`prCategoryID` = `c`.`prCategoryID`)))
        LEFT JOIN  `prWarehouseInventory` `pwi` ON ((`pr`.`prMasterID` = `pwi`.`prMasterID`)))
        LEFT JOIN  `prWarehouse` `pw` ON ((`pwi`.`prWarehouseID` = `pw`.`prWarehouseID`)));





DROP VIEW IF EXISTS MerCommissionCalculator;

CREATE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `MerCommissionCalculator` AS
	select 
		bjs.JobNumber,
		bjs.JobName,
        bjs.InvoiceNumber,
        bjs.InvoiceDate,
        bjs.InvoiceSubtotal,
        bjs.Freight,
        (bjs.`InvoiceSubtotal` + bjs.`Freight`) as BookProjectSellPrice,
        bjs.`InvoiceCostStock` AS `InvoiceCostStock`,
        bjs.`InvoiceCostDrop` AS `InvoiceCostDrop`,
        bjs.CalcRawInvoiceProfit as BookedProjectProfit,
		bjs.splitUserID,
		bjs.splitUserName,
		-- bjs.splitType,
        -- bjs.Allocated,
        (select Allocated from BaseJobSplit where ecSplitCodeID=1 and InvoiceNumber = bjs.InvoiceNumber and splitUserID=bjs.splitUserID ) as OwnerCredit,
        (select Allocated from BaseJobSplit where ecSplitCodeID=2 and InvoiceNumber = bjs.InvoiceNumber and splitUserID=bjs.splitUserID) as EngineerCredit,
        (select Allocated from BaseJobSplit where ecSplitCodeID=3 and InvoiceNumber = bjs.InvoiceNumber and splitUserID=bjs.splitUserID) as ContractorCredit,
        FORMAT(sum(bjs.Allocated),3) as TotalCredit,
		-- FORMAT(     (bjs.CalcRawInvoiceProfit * sum(bjs.Allocated) )/100 ,3) as CommissionableProfit,
		((bjs.CalcRawInvoiceProfit * sum(bjs.Allocated) )/100)  as CommissionableProfit,
		-- FORMAT((bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100)) * 0.15 ,3) as BookedSalesCommission,
		e.GetsCommission,
        e.GetsBonus as GetsBonus,
        FORMAT((case when e.GetsBonus=1 and e.GetsCommission=1 THEN
			
            -- need to sum up from current period back to first period.
            -- if (amt > bonusLevle2) then all invoices paid forward are at bonuslevel2
            (case when (bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100))>=e.BonusLevel2 THEN
				(bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100)) * (e.BonusCOmm2/100)
                ELSE
				(bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100)) * (e.BonusComm1/100)
            END)
        ELSE
			0
        END),3) as BookedSalesCommission,
		FORMAT(((bjs.`InvoiceSubtotal` + bjs.`Freight`) * (sum(bjs.Allocated)/100)),3) as FactoredSales,
        IF((`bjs`.`InvoiceAmount` = 0),
            `bjs`.`InvoiceDate`,
            `bjs`.`CustomerDatePaid`) AS `CustomerPaidDate`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`DatePaid`)
            FROM
                `ecInvoicePeriod`
            WHERE
                ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                    AND ((`ecInvoicePeriod`.`ecType` = 'I')
                    OR (`ecInvoicePeriod`.`ecType` = 'IA')))) AS `CommPaidDate`,             
		e.BonusLevel1, e.BonusComm1, e.BonusLevel2, e.BonusCOmm2,
        (select fiscalYear from coFiscalYear where startDate<= '2019-04-23 00:00:00' and endDate >= '2019-04-23 00:00:00' limit 1) as fiscalYear,
        (select coFiscalYearID from coFiscalYear where startDate<= '2019-04-23 00:00:00' and endDate >= '2019-04-23 00:00:00' limit 1) as coFiscalYearID
	from
		BaseJobSplit bjs
        left join emMaster e on (e.UserLoginID = bjs.splitUserID)
	group by bjs.InvoiceNumber,bjs.splitUserID;


-- ======================================

DROP VIEW  IF EXISTS v_TIER_commission;

CREATE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `v_TIER_commission` AS
	select 
		bjs.JobNumber,
		bjs.JobName,
        bjs.InvoiceNumber,
        bjs.InvoiceDate,
        bjs.InvoiceSubtotal,
        bjs.Freight,
        (bjs.`InvoiceSubtotal` + bjs.`Freight`) as BookProjectSellPrice,
        bjs.`InvoiceCostStock` AS `InvoiceCostStock`,
        bjs.`InvoiceCostDrop` AS `InvoiceCostDrop`,
        bjs.CalcRawInvoiceProfit as BookedProjectProfit,
		bjs.splitUserID,
		bjs.splitUserName,
		-- bjs.splitType,
        -- bjs.Allocated,
        (select Allocated from BaseJobSplit where ecSplitCodeID=1 and InvoiceNumber = bjs.InvoiceNumber and splitUserID=bjs.splitUserID ) as EngineerCredit,
        (select Allocated from BaseJobSplit where ecSplitCodeID=2 and InvoiceNumber = bjs.InvoiceNumber and splitUserID=bjs.splitUserID) as ContractorCredit,
        (select Allocated from BaseJobSplit where ecSplitCodeID=3 and InvoiceNumber = bjs.InvoiceNumber and splitUserID=bjs.splitUserID) as OwnerCredit,
        FORMAT(sum(bjs.Allocated),3) as TotalCredit,
		-- FORMAT(     (bjs.CalcRawInvoiceProfit * sum(bjs.Allocated) )/100 ,3) as CommissionableProfit,
		((bjs.CalcRawInvoiceProfit * sum(bjs.Allocated) )/100)  as CommissionableProfit,
		-- FORMAT((bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100)) * 0.15 ,3) as BookedSalesCommission,
		e.GetsCommission,
        e.GetsBonus as GetsBonus,
        FORMAT((case when e.GetsBonus=1 and e.GetsCommission=1 THEN
			
            -- need to sum up from current period back to first period.
            -- if (amt > bonusLevle2) then all invoices paid forward are at bonuslevel2
            (case when (bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100))>=e.BonusLevel2 THEN
				(bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100)) * (e.BonusCOmm2/100)
                ELSE
				(bjs.CalcRawInvoiceProfit * (sum(bjs.Allocated)/100)) * (e.BonusComm1/100)
            END)
        ELSE
			0
        END),3) as BookedSalesCommission,
		((bjs.`InvoiceSubtotal` + bjs.`Freight`) * (sum(bjs.Allocated)/100)) as FactoredSales,
        IF((`bjs`.`InvoiceAmount` = 0),
            `bjs`.`InvoiceDate`,
            `bjs`.`CustomerDatePaid`) AS `CustomerPaidDate`,
        (SELECT 
                MAX(`ecInvoicePeriod`.`DatePaid`)
            FROM
                `ecInvoicePeriod`
            WHERE
                ((`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`)
                    AND ((`ecInvoicePeriod`.`ecType` = 'I')
                    OR (`ecInvoicePeriod`.`ecType` = 'IA')))) AS `CommPaidDate`,             
		e.BonusLevel1, e.BonusComm1, e.BonusLevel2, e.BonusCOmm2,
        (select fiscalYear from coFiscalYear where startDate<= '2019-04-23 00:00:00' and endDate >= '2019-04-23 00:00:00' limit 1) as fiscalYear,
        (select coFiscalYearID from coFiscalYear where startDate<= '2019-04-23 00:00:00' and endDate >= '2019-04-23 00:00:00' limit 1) as coFiscalYearID
	from
		BaseJobSplit bjs
        left join emMaster e on (e.UserLoginID = bjs.splitUserID)
	group by bjs.InvoiceNumber,bjs.splitUserID;



-- =================================================

-- select * from InvoiceView;
/* -- Moved to warehouse script file for warehouse cron
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
*/



/*  OLD VIEW 8-10-23  - added vendorName to the new view
CREATE 
VIEW `InvoiceView` AS
    SELECT 
        `ci`.`cuInvoiceID` AS `cuInvoiceID`,
        `ci`.`joReleaseDetailID` AS `joReleaseDetailID`,
        `ci`.`coTaxTerritoryID` AS `coTaxTerritoryID`,
        `ci`.`InvoiceDate` AS `InvoiceDate`,

        (select rxMaster.name from rxMaster 
            left join vePO on (vePO.rxVendorID = rxMaster.rxMasterID)
            left join veBill on ( veBill.vePOID = vePO.vePOID)
            where `veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID` limit 1) as vendorName,
        
        (CASE
            WHEN (`ci`.`ShipToMode` = 1) THEN `rxA2`.`State`
            ELSE (CASE
                WHEN (`ci`.`ShipToMode` = 2) THEN `j`.`LocationState`
                ELSE (CASE
                    WHEN (`ci`.`ShipToMode` = 3) THEN `rxA1`.`State`
                    ELSE (CASE
                        WHEN
                            ((`ci`.`ShipToMode` = 0)
                                AND (`ci`.`veShipViaID` IS NOT NULL))
                        THEN
                            'NV'
                        ELSE NULL
                    END)
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
        `ci`.`cuAssignmentID0` AS `SalesPersonID`
    FROM
        (((((((((((((((`cuInvoice` `ci`
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
        LEFT JOIN `rxAddress` `rxA1` ON ((`rxA1`.`rxAddressID` = `ci`.`rxShipToAddressID`)))
        LEFT JOIN `joStatus` `js` ON ((`js`.`joStatusID` = `j`.`JobStatus`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `ci`.`coDivisionID`)))
        LEFT JOIN `joReleaseType` `rt` ON ((`r`.`ReleaseType` = `rt`.`joReleaseTypeID`)))
        LEFT JOIN `tsUserLogin` `sp` ON ((`sp`.`UserLoginID` = `ci`.`cuAssignmentID0`)))
    -- WHERE
    --     (`ci`.`InvoiceDate` > '2014-10-31 00:00:00') uat
    --        (`ci`.`cuInvoiceID` >= 83861) bartos

    GROUP BY `ci`.`cuInvoiceID`;
*/

/*  OLD VIEW 12-15-21  - added vendorName to the new view

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `InvoiceView` AS
    SELECT 
        `ci`.`cuInvoiceID` AS `cuInvoiceID`,
        `ci`.`joReleaseDetailID` AS `joReleaseDetailID`,
        `ci`.`coTaxTerritoryID` AS `coTaxTerritoryID`,
        `ci`.`InvoiceDate` AS `InvoiceDate`,
        (CASE
            WHEN (`ci`.`ShipToMode` = 1) THEN `rxA2`.`State`
            ELSE (CASE
                WHEN (`ci`.`ShipToMode` = 2) THEN `j`.`LocationState`
                ELSE (CASE
                    WHEN (`ci`.`ShipToMode` = 3) THEN `rxA1`.`State`
                    ELSE (CASE
                        WHEN
                            ((`ci`.`ShipToMode` = 0)
                                AND (`ci`.`veShipViaID` IS NOT NULL))
                        THEN
                            'NV'
                        ELSE NULL
                    END)
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
                        `veBill`.`BillAmount`
                    FROM
                        `veBill`
                    WHERE
                        (`veBill`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)
                    LIMIT 1),
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
            WHEN ISNULL(`ci`.`whseCostTotal`) THEN 0
            ELSE `ci`.`whseCostTotal`
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
        `sp`.`FullName` AS `SalesPersonName`
    FROM
        ((((((((((((((`cuInvoice` `ci`
        LEFT JOIN `tsUserLogin` `u` ON ((`ci`.`CreatedByID` = `u`.`UserLoginID`)))
        LEFT JOIN `joInvoiceCost` `jo` ON ((`ci`.`joReleaseDetailID` = `jo`.`joReleaseDetailID`)))
        LEFT JOIN `coTaxTerritory` `taxterr` ON ((`taxterr`.`coTaxTerritoryID` = `ci`.`coTaxTerritoryID`)))
        LEFT JOIN `rxMaster` `rxm` ON ((`rxm`.`rxMasterID` = `ci`.`rxCustomerID`)))
        LEFT JOIN `rxAddress` `rxA` ON ((`rxA`.`rxMasterID` = `ci`.`rxShipToID`)))
        LEFT JOIN `rxAddress` `rxA2` ON ((`rxA2`.`rxAddressID` = `ci`.`rxShipToID`)))
        LEFT JOIN `joReleaseDetail` `rd` ON ((`rd`.`joReleaseDetailID` = `ci`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `r` ON ((`r`.`joReleaseID` = `rd`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `r`.`joMasterID`)))
        LEFT JOIN `rxAddress` `rxA1` ON ((`rxA1`.`rxAddressID` = `ci`.`rxShipToAddressID`)))
        LEFT JOIN `joStatus` `js` ON ((`js`.`joStatusID` = `j`.`JobStatus`)))
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `ci`.`coDivisionID`)))
        LEFT JOIN `joReleaseType` `rt` ON ((`r`.`ReleaseType` = `rt`.`joReleaseTypeID`)))
        LEFT JOIN `tsUserLogin` `sp` ON ((`sp`.`UserLoginID` = `ci`.`cuAssignmentID0`)))
    WHERE
        (`ci`.`cuInvoiceID` >= 83861)
    GROUP BY `ci`.`cuInvoiceID`

*/



-- ===================================================================
/* -- Moved to warehouse script file for warehouse cron
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
*/


/*
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
        `eS`.`IsRelease` AS `esIsRelease`
    FROM
        ((((((((`cuInvoice` `cc`
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `joReleaseDetail` `jrd` ON ((`cc`.`joReleaseDetailID` = `jrd`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `jr` ON ((`jr`.`joReleaseID` = `jrd`.`joReleaseID`)))
        LEFT JOIN `ecSplitJob` `eS` ON ((`jr`.`joReleaseID` = `eS`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `jr`.`joMasterID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
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
        `eS`.`IsRelease` AS `esIsRelease`
    FROM
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
        0 AS `esIsRelease`
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

*/
/*
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
        `eS`.`IsRelease` AS `esIsRelease`
    FROM
        ((((((((`cuInvoice` `cc`
        LEFT JOIN `coDivision` `div` ON ((`div`.`coDivisionID` = `cc`.`coDivisionID`)))
        LEFT JOIN `joReleaseDetail` `jrd` ON ((`cc`.`joReleaseDetailID` = `jrd`.`joReleaseDetailID`)))
        LEFT JOIN `joRelease` `jr` ON ((`jr`.`joReleaseID` = `jrd`.`joReleaseID`)))
        LEFT JOIN `ecSplitJob` `eS` ON ((`jr`.`joReleaseID` = `eS`.`joReleaseID`)))
        LEFT JOIN `joMaster` `j` ON ((`j`.`joMasterID` = `jr`.`joMasterID`)))
        LEFT JOIN `rxMaster` `crx` ON ((`crx`.`rxMasterID` = `cc`.`rxCustomerID`)))
        LEFT JOIN `emMaster` `em` ON ((`em`.`UserLoginID` = `cc`.`cuAssignmentID0`)))
        LEFT JOIN `veBill` `v` ON ((`v`.`joReleaseDetailID` = `cc`.`joReleaseDetailID`)))
    WHERE
        ((`em`.`isJobPaidInFull` = 0)
            AND (`cc`.`InvoiceDate` >= '2017-10-01')
            AND (`cc`.`joReleaseDetailID` IS NOT NULL) and (`v`.`joReleaseDetailID` > 0)) 
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
        `eS`.`IsRelease` AS `esIsRelease`
    FROM
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
        0 AS `esIsRelease`
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
*/


-- ===================================  

DROP VIEW  IF EXISTS BaseJobSplit;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `BaseJobSplit` AS
/*SELECT
  `BaseInvoiceView`.`InvoiceID`              AS `InvoiceID`,
  `BaseInvoiceView`.`InvoiceNumber`          AS `InvoiceNumber`,
  `BaseInvoiceView`.`InvoiceDate`            AS `InvoiceDate`,
  `BaseInvoiceView`.`ReleaseId`              AS `ReleaseId`,
  `BaseInvoiceView`.`ReleasedetailID`        AS `ReleasedetailID`,
  `BaseInvoiceView`.`InvoiceAmount`          AS `InvoiceAmount`,
  `BaseInvoiceView`.`Discount`               AS `Discount`,
  `BaseInvoiceView`.`AmountToBePaid`         AS `AmountToBePaid`,
  `BaseInvoiceView`.`AmountPaid`             AS `AmountPaid`,
  `BaseInvoiceView`.`CustomerBalance`        AS `CustomerBalance`,
  `BaseInvoiceView`.`CustomerDatePaid`       AS `CustomerDatePaid`,
  `BaseInvoiceView`.`AddCostTotal`           AS `AddCostTotal`,
  `BaseInvoiceView`.`SalesPerson`            AS `SalesPerson`,
  `BaseInvoiceView`.`SalesPersonID`          AS `SalesPersonID`,
  `BaseInvoiceView`.`SalesPersonName`        AS `SalesPersonName`,
  `BaseInvoiceView`.`InvoiceSubtotal`        AS `InvoiceSubtotal`,
  `BaseInvoiceView`.`Freight`                AS `Freight`,
  `BaseInvoiceView`.`InvoiceCostStock`       AS `InvoiceCostStock`,
  `BaseInvoiceView`.`InvoiceCostDrop`        AS `InvoiceCostDrop`,
  `BaseInvoiceView`.`InvoiceCostDropFreight` AS `InvoiceCostDropFreight`,
  `BaseInvoiceView`.`JobNumber`              AS `JobNumber`,
  `BaseInvoiceView`.`JobName`                AS `JobName`,
  `BaseInvoiceView`.`Info_memoStatus`        AS `Info_memoStatus`,
  `BaseInvoiceView`.`Info_CreditMemo`        AS `Info_CreditMemo`,
  `BaseInvoiceView`.`Info_rxCustomerID`      AS `Info_rxCustomerID`,
  `BaseInvoiceView`.`Info_cuInvoiceID`       AS `Info_cuInvoiceID`,
  `BaseInvoiceView`.`Info_ReleaseType`       AS `Info_ReleaseType`,
  `BaseInvoiceView`.`coDivisionID`           AS `coDivisionID`,
  `BaseInvoiceView`.`DivDescription`         AS `DivDescription`,
  `BaseInvoiceView`.`DivCode`                AS `DivCode`,
  `BaseInvoiceView`.`CustomerName`           AS `CustomerName`,
  `BaseInvoiceView`.`BillDate`               AS `BillDate`,
  (SELECT
     `emMaster`.`CommissionJobProfit`
   FROM `emMaster`
   WHERE (`emMaster`.`UserLoginID` = `BaseInvoiceView`.`SalesPersonID`)
   LIMIT 0,1) AS `commissionJobProfit`,
  `ecSplitJob`.`ecSplitJobID`                AS `ecSplitJobID`,
  `BaseInvoiceView`.`joMasterID`             AS `joMasterID`,
  `ecSplitJob`.`rxMasterID`                  AS `rxMasterID`,
  `ecSplitJob`.`joReleaseID`                 AS `joReleaseId`,
  IFNULL(`ecSplitJob`.`Allocated`,100)       AS `Allocated`,
  IF((MONTH(`BaseInvoiceView`.`InvoiceDate`) < MONTH(`BaseInvoiceView`.`BillDate`)),IFNULL(((0.00 - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),0),IFNULL((((`BaseInvoiceView`.`InvoiceSubtotal` + `BaseInvoiceView`.`Freight`) - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),0)) AS `CalcRawInvoiceProfit`,
  (SELECT
     `c`.`CodeName`
   FROM `ecSplitCode` `c`
   WHERE (`c`.`ecSplitCodeID` = `ecSplitJob`.`ecSplitCodeID`)) AS `splitType`,
  `ecSplitJob`.`ecSplitCodeID`               AS `ecSplitCodeID`,
  `ecSplitJob`.`ChangedByID`                 AS `ChangedByID`,
  `ecSplitJob`.`ChangedOn`                   AS `ChangedOn`,
  IF(ISNULL(`ecSplitJob`.`rxMasterID`),`BaseInvoiceView`.`SalesPerson`,`emMaster`.`UserLoginID`) AS `SplitUserID`,
  IF(ISNULL(`ecSplitJob`.`rxMasterID`),`BaseInvoiceView`.`SalesPersonName`,CONVERT(`rxMaster`.`Name` USING utf8)) AS `SplitUserName`,
  `ecSplitJob`.`IsRelease`                   AS `IsRelease`,
  IF(ISNULL(`ecSplitJob`.`rxMasterID`),`BaseInvoiceView`.`isJobPaidInFull`,`emMaster`.`isJobPaidInFull`) AS `isJobPaidInFull`,
  IF(ISNULL(`ecSplitJob`.`rxMasterID`),`BaseInvoiceView`.`isFollowingPeriod`,`emMaster`.`isFollowingPeriod`) AS `isFollowingPeriod`,
  IF(ISNULL(`ecSplitJob`.`rxMasterID`),`BaseInvoiceView`.`CommAfterPayment`,`emMaster`.`CommAfterPayment`) AS `CommAfterPayment`,
  IF(ISNULL(`ecSplitJob`.`rxMasterID`),`BaseInvoiceView`.`dayAfter`,`emMaster`.`dayAfter`) AS `dayAfter`
FROM (((`BaseInvoiceView`
     LEFT JOIN `ecSplitJob`
       ON ((`BaseInvoiceView`.`esJoReleaseID` = `ecSplitJob`.`joReleaseID`)))
    LEFT JOIN `emMaster`
      ON ((`emMaster`.`emMasterID` = `ecSplitJob`.`rxMasterID`)))
   LEFT JOIN `rxMaster`
     ON ((`ecSplitJob`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
WHERE (`ecSplitJob`.`IsRelease` = 1)UNION ALL SELECT
                                                `BaseInvoiceView`.`InvoiceID`               AS `InvoiceID`,
                                                `BaseInvoiceView`.`InvoiceNumber`           AS `InvoiceNumber`,
                                                `BaseInvoiceView`.`InvoiceDate`             AS `InvoiceDate`,
                                                `BaseInvoiceView`.`ReleaseId`               AS `ReleaseId`,
                                                `BaseInvoiceView`.`ReleasedetailID`         AS `ReleasedetailID`,
                                                `BaseInvoiceView`.`InvoiceAmount`           AS `InvoiceAmount`,
                                                `BaseInvoiceView`.`Discount`                AS `Discount`,
                                                `BaseInvoiceView`.`AmountToBePaid`          AS `AmountToBePaid`,
                                                `BaseInvoiceView`.`AmountPaid`              AS `AmountPaid`,
                                                `BaseInvoiceView`.`CustomerBalance`         AS `CustomerBalance`,
                                                `BaseInvoiceView`.`CustomerDatePaid`        AS `CustomerDatePaid`,
                                                `BaseInvoiceView`.`AddCostTotal`            AS `AddCostTotal`,
                                                `BaseInvoiceView`.`SalesPerson`             AS `SalesPerson`,
                                                `BaseInvoiceView`.`SalesPersonID`           AS `SalesPersonID`,
                                                `BaseInvoiceView`.`SalesPersonName`         AS `SalesPersonName`,
                                                `BaseInvoiceView`.`InvoiceSubtotal`         AS `InvoiceSubtotal`,
                                                `BaseInvoiceView`.`Freight`                 AS `Freight`,
                                                `BaseInvoiceView`.`InvoiceCostStock`        AS `InvoiceCostStock`,
                                                `BaseInvoiceView`.`InvoiceCostDrop`         AS `InvoiceCostDrop`,
                                                `BaseInvoiceView`.`InvoiceCostDropFreight`  AS `InvoiceCostDropFreight`,
                                                `BaseInvoiceView`.`JobNumber`               AS `JobNumber`,
                                                `BaseInvoiceView`.`JobName`                 AS `JobName`,
                                                `BaseInvoiceView`.`Info_memoStatus`         AS `Info_memoStatus`,
                                                `BaseInvoiceView`.`Info_CreditMemo`         AS `Info_CreditMemo`,
                                                `BaseInvoiceView`.`Info_rxCustomerID`       AS `Info_rxCustomerID`,
                                                `BaseInvoiceView`.`Info_cuInvoiceID`        AS `Info_cuInvoiceID`,
                                                `BaseInvoiceView`.`Info_ReleaseType`        AS `Info_ReleaseType`,
                                                `BaseInvoiceView`.`coDivisionID`            AS `coDivisionID`,
                                                `BaseInvoiceView`.`DivDescription`          AS `DivDescription`,
                                                `BaseInvoiceView`.`DivCode`                 AS `DivCode`,
                                                `BaseInvoiceView`.`CustomerName`            AS `CustomerName`,
                                                `BaseInvoiceView`.`BillDate`                AS `BillDate`,
                                                (SELECT
                                                   `emMaster`.`CommissionJobProfit`
                                                 FROM `emMaster`
                                                 WHERE (`emMaster`.`UserLoginID` = `BaseInvoiceView`.`SalesPersonID`)
                                                 LIMIT 0,1) AS `commissionJobProfit`,
                                                `jobsplit`.`ecSplitJobID`                   AS `ecSplitJobID`,
                                                `BaseInvoiceView`.`joMasterID`              AS `joMasterID`,
                                                `jobsplit`.`rxMasterID`                     AS `rxMasterID`,
                                                `jobsplit`.`joReleaseId`                    AS `joReleaseId`,
                                                IFNULL(`jobsplit`.`Allocated`,100)          AS `Allocated`,
                                                IF((MONTH(`BaseInvoiceView`.`InvoiceDate`) < MONTH(`BaseInvoiceView`.`BillDate`)),IFNULL(((0.00 - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),0),IFNULL((((`BaseInvoiceView`.`InvoiceSubtotal` + `BaseInvoiceView`.`Freight`) - `BaseInvoiceView`.`InvoiceCostDrop`) - `BaseInvoiceView`.`InvoiceCostStock`),0)) AS `CalcRawInvoiceProfit`,
                                                (SELECT
                                                   `c`.`CodeName`
                                                 FROM `ecSplitCode` `c`
                                                 WHERE (`c`.`ecSplitCodeID` = `jobsplit`.`ecSplitCodeID`)) AS `splitType`,
                                                `jobsplit`.`ecSplitCodeID`                  AS `ecSplitCodeID`,
                                                `jobsplit`.`ChangedByID`                    AS `ChangedByID`,
                                                `jobsplit`.`ChangedOn`                      AS `ChangedOn`,
                                                IF(ISNULL(`jobsplit`.`rxMasterID`),`BaseInvoiceView`.`SalesPerson`,`emMaster`.`UserLoginID`) AS `SplitUserID`,
                                                IF(ISNULL(`jobsplit`.`rxMasterID`),`BaseInvoiceView`.`SalesPersonName`,CONVERT(`rxMaster`.`Name` USING utf8)) AS `SplitUserName`,
                                                `jobsplit`.`IsRelease`                      AS `IsRelease`,
                                                IF(ISNULL(`jobsplit`.`rxMasterID`),`BaseInvoiceView`.`isJobPaidInFull`,`emMaster`.`isJobPaidInFull`) AS `isJobPaidInFull`,
                                                IF(ISNULL(`jobsplit`.`rxMasterID`),`BaseInvoiceView`.`isFollowingPeriod`,`emMaster`.`isFollowingPeriod`) AS `isFollowingPeriod`,
                                                IF(ISNULL(`jobsplit`.`rxMasterID`),`BaseInvoiceView`.`CommAfterPayment`,`emMaster`.`CommAfterPayment`) AS `CommAfterPayment`,
                                                IF(ISNULL(`jobsplit`.`rxMasterID`),`BaseInvoiceView`.`dayAfter`,`emMaster`.`dayAfter`) AS `dayAfter`
                                              FROM (((`BaseInvoiceView`
                                                   LEFT JOIN `SplitJobView` `jobsplit`
                                                     ON ((`BaseInvoiceView`.`InvoiceID` = `jobsplit`.`InvoiceID`)))
                                                  LEFT JOIN `emMaster`
                                                    ON ((`emMaster`.`emMasterID` = `jobsplit`.`rxMasterID`)))
                                                 LEFT JOIN `rxMaster`
                                                   ON ((`jobsplit`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
                                              WHERE ISNULL(`BaseInvoiceView`.`esIsRelease`)
ORDER BY `InvoiceNumber` DESC;
*/
    SELECT 
        `BaseInvoiceView`.`InvoiceID` AS `InvoiceID`,
        `BaseInvoiceView`.`InvoiceNumber` AS `InvoiceNumber`,
        `BaseInvoiceView`.`InvoiceDate` AS `InvoiceDate`,
        `BaseInvoiceView`.`ReleaseId` AS `ReleaseId`,
        `BaseInvoiceView`.`ReleasedetailID` AS `ReleasedetailID`,
        `BaseInvoiceView`.`InvoiceAmount` AS `InvoiceAmount`,
        `BaseInvoiceView`.`Discount` AS `Discount`,
        `BaseInvoiceView`.`AmountToBePaid` AS `AmountToBePaid`,
        `BaseInvoiceView`.`AmountPaid` AS `AmountPaid`,
        `BaseInvoiceView`.`CustomerBalance` AS `CustomerBalance`,
        `BaseInvoiceView`.`CustomerDatePaid` AS `CustomerDatePaid`,
        `BaseInvoiceView`.`AddCostTotal` AS `AddCostTotal`,
        `BaseInvoiceView`.`SalesPerson` AS `SalesPerson`,
        `BaseInvoiceView`.`SalesPersonID` AS `SalesPersonID`,
        `BaseInvoiceView`.`SalesPersonName` AS `SalesPersonName`,
        `BaseInvoiceView`.`InvoiceSubtotal` AS `InvoiceSubtotal`,
        `BaseInvoiceView`.`Freight` AS `Freight`,
        `BaseInvoiceView`.`InvoiceCostStock` AS `InvoiceCostStock`,
        `BaseInvoiceView`.`InvoiceCostDrop` AS `InvoiceCostDrop`,
        `BaseInvoiceView`.`InvoiceCostDropFreight` AS `InvoiceCostDropFreight`,
        `BaseInvoiceView`.`JobNumber` AS `JobNumber`,
        `BaseInvoiceView`.`JobName` AS `JobName`,
        `BaseInvoiceView`.`Info_memoStatus` AS `Info_memoStatus`,
        `BaseInvoiceView`.`Info_CreditMemo` AS `Info_CreditMemo`,
        `BaseInvoiceView`.`Info_rxCustomerID` AS `Info_rxCustomerID`,
        `BaseInvoiceView`.`Info_cuInvoiceID` AS `Info_cuInvoiceID`,
        `BaseInvoiceView`.`Info_ReleaseType` AS `Info_ReleaseType`,
        `BaseInvoiceView`.`coDivisionID` AS `coDivisionID`,
        `BaseInvoiceView`.`DivDescription` AS `DivDescription`,
        `BaseInvoiceView`.`DivCode` AS `DivCode`,
        `BaseInvoiceView`.`CustomerName` AS `CustomerName`,
        `BaseInvoiceView`.`BillDate` AS `BillDate`,
        (SELECT 
                `emMaster`.`CommissionJobProfit`
            FROM
                `emMaster`
            WHERE
                (`emMaster`.`UserLoginID` = `BaseInvoiceView`.`SalesPersonID`)
            LIMIT 0 , 1) AS `commissionJobProfit`,
        `ecSplitJob`.`ecSplitJobID` AS `ecSplitJobID`,
        `ecSplitJob`.`joMasterID` AS `joMasterID`,
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
    FROM
        (((`BaseInvoiceView`
        LEFT JOIN `ecSplitJob` ON ((`BaseInvoiceView`.`esJoReleaseID` = `ecSplitJob`.`joReleaseID`)))
        LEFT JOIN `emMaster` ON ((`emMaster`.`emMasterID` = `ecSplitJob`.`rxMasterID`)))
        LEFT JOIN `rxMaster` ON ((`ecSplitJob`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
    WHERE
        (`ecSplitJob`.`IsRelease` = 1) 
    UNION ALL SELECT 
        `BaseInvoiceView`.`InvoiceID` AS `InvoiceID`,
        `BaseInvoiceView`.`InvoiceNumber` AS `InvoiceNumber`,
        `BaseInvoiceView`.`InvoiceDate` AS `InvoiceDate`,
        `BaseInvoiceView`.`ReleaseId` AS `ReleaseId`,
        `BaseInvoiceView`.`ReleasedetailID` AS `ReleasedetailID`,
        `BaseInvoiceView`.`InvoiceAmount` AS `InvoiceAmount`,
        `BaseInvoiceView`.`Discount` AS `Discount`,
        `BaseInvoiceView`.`AmountToBePaid` AS `AmountToBePaid`,
        `BaseInvoiceView`.`AmountPaid` AS `AmountPaid`,
        `BaseInvoiceView`.`CustomerBalance` AS `CustomerBalance`,
        `BaseInvoiceView`.`CustomerDatePaid` AS `CustomerDatePaid`,
        `BaseInvoiceView`.`AddCostTotal` AS `AddCostTotal`,
        `BaseInvoiceView`.`SalesPerson` AS `SalesPerson`,
        `BaseInvoiceView`.`SalesPersonID` AS `SalesPersonID`,
        `BaseInvoiceView`.`SalesPersonName` AS `SalesPersonName`,
        `BaseInvoiceView`.`InvoiceSubtotal` AS `InvoiceSubtotal`,
        `BaseInvoiceView`.`Freight` AS `Freight`,
        `BaseInvoiceView`.`InvoiceCostStock` AS `InvoiceCostStock`,
        `BaseInvoiceView`.`InvoiceCostDrop` AS `InvoiceCostDrop`,
        `BaseInvoiceView`.`InvoiceCostDropFreight` AS `InvoiceCostDropFreight`,
        `BaseInvoiceView`.`JobNumber` AS `JobNumber`,
        `BaseInvoiceView`.`JobName` AS `JobName`,
        `BaseInvoiceView`.`Info_memoStatus` AS `Info_memoStatus`,
        `BaseInvoiceView`.`Info_CreditMemo` AS `Info_CreditMemo`,
        `BaseInvoiceView`.`Info_rxCustomerID` AS `Info_rxCustomerID`,
        `BaseInvoiceView`.`Info_cuInvoiceID` AS `Info_cuInvoiceID`,
        `BaseInvoiceView`.`Info_ReleaseType` AS `Info_ReleaseType`,
        `BaseInvoiceView`.`coDivisionID` AS `coDivisionID`,
        `BaseInvoiceView`.`DivDescription` AS `DivDescription`,
        `BaseInvoiceView`.`DivCode` AS `DivCode`,
        `BaseInvoiceView`.`CustomerName` AS `CustomerName`,
        `BaseInvoiceView`.`BillDate` AS `BillDate`,
        (SELECT 
                `emMaster`.`CommissionJobProfit`
            FROM
                `emMaster`
            WHERE
                (`emMaster`.`UserLoginID` = `BaseInvoiceView`.`SalesPersonID`)
            LIMIT 0 , 1) AS `commissionJobProfit`,
        `jobSplit`.`ecSplitJobID` AS `ecSplitJobID`,
        `jobSplit`.`joMasterID` AS `joMasterID`,
        `jobSplit`.`rxMasterID` AS `rxMasterID`,
        `jobSplit`.`joReleaseId` AS `joReleaseId`,
        IFNULL(`jobSplit`.`Allocated`, 100) AS `Allocated`,
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
                (`c`.`ecSplitCodeID` = `jobSplit`.`ecSplitCodeID`)) AS `splitType`,
        `jobSplit`.`ecSplitCodeID` AS `ecSplitCodeID`,
        `jobSplit`.`ChangedByID` AS `ChangedByID`,
        `jobSplit`.`ChangedOn` AS `ChangedOn`,
        IF(ISNULL(`jobSplit`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPerson`,
            `emMaster`.`UserLoginID`) AS `SplitUserID`,
        IF(ISNULL(`jobSplit`.`rxMasterID`),
            `BaseInvoiceView`.`SalesPersonName`,
            CONVERT( `rxMaster`.`Name` USING UTF8)) AS `SplitUserName`,
        `jobSplit`.`IsRelease` AS `IsRelease`
    FROM
        (((`BaseInvoiceView`
        LEFT JOIN `SplitJobView` `jobSplit` ON ((`BaseInvoiceView`.`InvoiceID` = `jobSplit`.`InvoiceID`)))
        LEFT JOIN `emMaster` ON ((`emMaster`.`emMasterID` = `jobSplit`.`rxMasterID`)))
        LEFT JOIN `rxMaster` ON ((`jobSplit`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
    WHERE
        ISNULL(`BaseInvoiceView`.`esIsRelease`)
    ORDER BY `InvoiceNumber` DESC;
    


-- ===================================        
/*  

please compare the salesCommissionView in the tp_schema_views.sql.  
The commented out view is the latest, and the active view was copied 
from EMS Legacy Production on Pronto.  Note the old view was good.  
But why was it overwritten with the new view?


DROP VIEW  IF EXISTS SalesCommissionView;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `SalesCommissionView` AS
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
        NULL as VendorName
    FROM
        (`BaseJobSplit` `bjs`
        LEFT JOIN `joReleaseType` ON ((`bjs`.`Info_ReleaseType` = `joReleaseType`.`joReleaseTypeID`))) 
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
        NULL as VendorName
    FROM
        ((`BaseJobSplit` `bjs`
        JOIN `joInvoiceCost` `jic` ON ((`bjs`.`ReleasedetailID` = `jic`.`joReleaseDetailID`)))
        LEFT JOIN `joReleaseType` ON ((`bjs`.`Info_ReleaseType` = `joReleaseType`.`joReleaseTypeID`))) 
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
        NULL as VendorName
    FROM
        ((((((((`veCommDetail` `veC`
        JOIN `joReleaseDetail` `jRD` ON ((`jRD`.`joReleaseDetailID` = `veC`.`joReleaseDetailID`)))
        JOIN `joRelease` `joR` ON ((`joR`.`joReleaseID` = `jRD`.`joReleaseID`)))
        JOIN `joMaster` `joM` ON ((`joM`.`joMasterID` = `joR`.`joMasterID`)))
        JOIN `tsUserLogin` `tsUL` ON ((`tsUL`.`UserLoginID` = `joM`.`cuAssignmentID0`)))
        LEFT JOIN `ecSplitJob` `ecS` ON ((`ecS`.`joMasterID` = `joR`.`joMasterID`)))
        LEFT JOIN `emMaster` `emM` ON ((`emM`.`emMasterID` = `ecS`.`rxMasterID`)))
        LEFT JOIN `tsUserLogin` `tsUL1` ON ((`emM`.`UserLoginID` = `tsUL1`.`UserLoginID`)))
        LEFT JOIN `joReleaseType` ON ((`joR`.`ReleaseType` = `joReleaseType`.`joReleaseTypeID`)))
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
        vend.Name as VendorName
    FROM
        ((((((((`veBillDistribution` `veC`
        JOIN `joMaster` `joM` ON ((`joM`.`joMasterID` = `veC`.`joMasterID`)))
        LEFT JOIN `veBill` `vB` ON ((`veC`.`veBillID` = `vB`.`veBillID`)))
        JOIN `tsUserLogin` `tsUL` ON ((`tsUL`.`UserLoginID` = `joM`.`cuAssignmentID0`)))
        LEFT JOIN `ecSplitJob` `ecS` ON (((`joM`.`joMasterID` = `ecS`.`joMasterID`)
            AND ISNULL(`ecS`.`joReleaseID`))))
        LEFT JOIN `emMaster` `emM` ON ((`emM`.`emMasterID` = `ecS`.`rxMasterID`)))
        LEFT JOIN `tsUserLogin` `tsUL1` ON ((`emM`.`UserLoginID` = `tsUL1`.`UserLoginID`)))
        LEFT JOIN `rxMaster` ON ((`ecS`.`rxMasterID` = `rxMaster`.`rxMasterID`)))
        LEFT JOIN `rxMaster` vend ON ((`vend`.`rxMasterID` = `vB`.`rxMasterID`)));
*/

/*
We are updating a view for some changes
*/
DROP VIEW  IF EXISTS SalesCommissionView;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `SalesCommissionView` AS
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
                        (`rxMaster`.`rxMasterID` = `vP`.`rxVendorID`))) AS `VendorName`
    FROM
        ((((`BaseJobSplit` `bjs`
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
                        (`rxMaster`.`rxMasterID` = `vP`.`rxVendorID`))) AS `VendorName`
    FROM
        (((((`BaseJobSplit` `bjs`
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
        `rM`.`Name` AS `VendorName`
    FROM
        ((((((((((`veCommDetail` `veC`
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
        NULL AS `VendorName`
    FROM
        (((((((`veBillDistribution` `veC`
        JOIN `joMaster` `joM` ON ((`joM`.`joMasterID` = `veC`.`joMasterID`)))
        LEFT JOIN `veBill` `vB` ON ((`veC`.`veBillID` = `vB`.`veBillID`)))
        JOIN `tsUserLogin` `tsUL` ON ((`tsUL`.`UserLoginID` = `joM`.`cuAssignmentID0`)))
        LEFT JOIN `ecSplitJob` `ecS` ON (((`joM`.`joMasterID` = `ecS`.`joMasterID`)
            AND ISNULL(`ecS`.`joReleaseID`))))
        LEFT JOIN `emMaster` `emM` ON ((`emM`.`emMasterID` = `ecS`.`rxMasterID`)))
        LEFT JOIN `tsUserLogin` `tsUL1` ON ((`emM`.`UserLoginID` = `tsUL1`.`UserLoginID`)))
        LEFT JOIN `rxMaster` ON ((`ecS`.`rxMasterID` = `rxMaster`.`rxMasterID`)));

/*

DROP view IF EXISTS `SalesCommissionView`;
CREATE 
VIEW `SalesCommissionView` AS
SELECT
   'Invoice' AS `RecordType`,
   IF((`bjs`.`InvoiceAmount` = 0), 'Paid', IF(ISNULL(`bjs`.`CustomerDatePaid`), 'Balance', 'Paid')) AS `CustomerStatus`,
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
   IF((`bjs`.`InvoiceAmount` = 0), `bjs`.`InvoiceDate`, `bjs`.`CustomerDatePaid`) AS `CustomerPaidDate`,
   `bjs`.`AddCostTotal` AS `AddCostTotals`,
   `bjs`.`SalesPersonName` AS `SalesRepAssigned`,
   `bjs`.`Info_memoStatus` AS `info_memoStatus`,
   `bjs`.`Info_CreditMemo` AS `info_CreditMemo`,
   IFNULL(`bjs`.`Info_rxCustomerID`, 0) AS `info_rxCustomerID`,
   IFNULL(`bjs`.`Info_cuInvoiceID`, 0) AS `info_cuInvoiceID`,
   NULL AS `info_veCommDetailID`,
   (
      SELECT
         MAX(`ecp`.`ecInvoicePeriodID`) 
      FROM
         (
(`ecInvoicePeriod` `ecp` 
            LEFT JOIN
               `ecInvoiceRepSplit` `ecrs` 
               ON((`ecp`.`ecInvoicePeriodID` = `ecrs`.`ecInvoicePeriodID`))) 
            LEFT JOIN
               `ecStatement` `ecs` 
               ON((`ecrs`.`ecStatementID` = `ecs`.`ecStatementID`))
         )
      WHERE
         (
(`ecp`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`) 
            AND 
            (
               `ecs`.`RepLoginID` = `bjs`.`SplitUserID`
            )
         )
   )
   AS `info_ecInvoicePeriodID`,
   `bjs`.`ecSplitJobID` AS `info_ecSplitjobID`,
   `bjs`.`joReleaseId` AS `info_joReleaseID`,
   IFNULL(`bjs`.`SplitUserID`, 0) AS `info_userLoginID`,
   IFNULL(`bjs`.`Info_ReleaseType`, - (1)) AS `ReleaseTypes`,
   `bjs`.`ReleasedetailID` AS `Info_ReleasedetailID`,
   0 AS `info_joInvoiceCostID`,
   IFNULL((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`), 0) AS `CalcRawInvoiceProfit`,
   IFNULL(`bjs`.`commissionJobProfit`, 0) AS `SalesRepJobProfit`,
   IFNULL((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100), 0) AS `CalcRevShare`,
   IFNULL((((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) * IFNULL(`bjs`.`Allocated`, 100)) / 100), 0) AS `CalcSplitRev`,
   IFNULL(`bjs`.`splitType`, 'N/A') AS `CommSplitType`,
   IFNULL(`bjs`.`Allocated`, 100) AS `CommPercent`,
   `bjs`.`ChangedOn` AS `CommSplitChangedOn`,
   `bjs`.`SplitUserName` AS `CommSalesRep`,
   `bjs`.`InvoiceDate` AS `CommAvailableDate`,
   IF(((
   SELECT
      IFNULL(COUNT(`ecp`.`ecInvoicePeriodID`), 0) 
   FROM
      (
(`ecInvoicePeriod` `ecp` 
         LEFT JOIN
            `ecInvoiceRepSplit` `ecrs` 
            ON((`ecp`.`ecInvoicePeriodID` = `ecrs`.`ecInvoicePeriodID`))) 
         LEFT JOIN
            `ecStatement` `ecs` 
            ON((`ecrs`.`ecStatementID` = `ecs`.`ecStatementID`))
      )
   WHERE
      (
(`ecp`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`) 
         AND 
         (
            `ecs`.`RepLoginID` = `bjs`.`SplitUserID`
         )
      )
) = 0), 'No', 'Yes') AS `IsCommPaid`,
      (
         SELECT
            MAX(`ecp`.`DatePaid`) 
         FROM
            (
(`ecInvoicePeriod` `ecp` 
               LEFT JOIN
                  `ecInvoiceRepSplit` `ecrs` 
                  ON((`ecp`.`ecInvoicePeriodID` = `ecrs`.`ecInvoicePeriodID`))) 
               LEFT JOIN
                  `ecStatement` `ecs` 
                  ON((`ecrs`.`ecStatementID` = `ecs`.`ecStatementID`))
            )
         WHERE
            (
(`ecp`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`) 
               AND 
               (
                  `ecs`.`RepLoginID` = `bjs`.`SplitUserID`
               )
            )
      )
      AS `CommPaidDate`,
      CAST((
      SELECT
         MAX(`ecp`.`enteredDate`) 
      FROM
         (
(`ecInvoicePeriod` `ecp` 
            LEFT JOIN
               `ecInvoiceRepSplit` `ecrs` 
               ON((`ecp`.`ecInvoicePeriodID` = `ecrs`.`ecInvoicePeriodID`))) 
            LEFT JOIN
               `ecStatement` `ecs` 
               ON((`ecrs`.`ecStatementID` = `ecs`.`ecStatementID`))
         )
      WHERE
         (
(`ecp`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`) 
            AND 
            (
               `ecs`.`RepLoginID` = `bjs`.`SplitUserID`
            )
         )
) AS DATE) AS `CommEnteredDate`,
         `bjs`.`coDivisionID` AS `coDivisionID`,
         `bjs`.`DivDescription` AS `DivDescription`,
         `bjs`.`DivCode` AS `DivCode`,
         `bjs`.`CustomerName` AS `CustomerName`,
         `bjs`.`joMasterID` AS `joMasterID`,
         NULL AS `veBillID`,
         IFNULL(`rm`.`Name`, 
         (
            SELECT
               `rxMaster`.`Name` 
            FROM
               `rxMaster` 
            WHERE
               (
                  `rxMaster`.`rxMasterID` = `vp`.`rxVendorID`
               )
         )
) AS `VendorName`,
         `bjs`.`isJobPaidInFull` AS `isJobPaidInFull`,
         `bjs`.`isFollowingPeriod` AS `isFollowingPeriod`,
         `bjs`.`CommAfterPayment` AS `CommAfterPayment`,
         `bjs`.`dayAfter` AS `dayAfter` 
      FROM
         (
(((`BaseJobSplit` `bjs` 
            LEFT JOIN
               `joReleaseType` 
               ON((`bjs`.`Info_ReleaseType` = `joReleaseType`.`joReleaseTypeID`))) 
            LEFT JOIN
               `cuSO` `co` 
               ON((`co`.`joReleaseID` = `bjs`.`ReleaseId`))) 
            LEFT JOIN
               `rxMaster` `rm` 
               ON((`co`.`rxCustomerID` = `rm`.`rxMasterID`))) 
            LEFT JOIN
               `vePO` `vp` 
               ON((`vp`.`joReleaseID` = `bjs`.`ReleaseId`))
         )
      UNION ALL
      SELECT
         'AddCost' AS `RecordType`,
         IF((`bjs`.`InvoiceAmount` = 0), 'Paid', IF(ISNULL(`bjs`.`CustomerDatePaid`), 'Balance', 'Paid')) AS `CustomerStatus`,
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
         IFNULL(`bjs`.`Info_ReleaseType`, - (1)) AS `ReleaseTypes`,
         `bjs`.`ReleasedetailID` AS `Info_ReleasedetailID`,
         `jic`.`joInvoiceCostID` AS `info_joInvoiceCostID`,
         IFNULL((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) - `jic`.`cost`) - (((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`)), 0) AS `CalcRawInvoiceProfit`,
         IFNULL(`bjs`.`commissionJobProfit`, 0) AS `SalesRepJobProfit`,
         IFNULL((((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) - `jic`.`cost`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) - (((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100)), 0) AS `CalcRevShare`,
         IFNULL((((((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) - `jic`.`cost`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) * IFNULL(`bjs`.`Allocated`, 100)) / 100) - (((((((`bjs`.`InvoiceSubtotal` + `bjs`.`Freight`) - `bjs`.`InvoiceCostDrop`) - `bjs`.`InvoiceCostStock`) * IFNULL(`bjs`.`commissionJobProfit`, 0)) / 100) * IFNULL(`bjs`.`Allocated`, 100)) / 100)), 0) AS `CalcSplitRev`,
         IFNULL(`bjs`.`splitType`, 'N/A') AS `CommSplitType`,
         IFNULL(`bjs`.`Allocated`, 100) AS `CommPercent`,
         `bjs`.`ChangedOn` AS `CommSplitChangedOn`,
         `bjs`.`SplitUserName` AS `CommSalesRep`,
         `jic`.`enteredDate` AS `CommAvailableDate`,
         IF(ISNULL(`jic`.`ecInvoicePeriodID`), 'No', 'Yes') AS `IsCommPaid`,
         (
            SELECT
               `ecInvoicePeriod`.`DatePaid` 
            FROM
               `ecInvoicePeriod` 
            WHERE
               (
                  `ecInvoicePeriod`.`ecInvoicePeriodID` = `jic`.`ecInvoicePeriodID`
               )
         )
         AS `CommPaidDate`,
         CAST((
         SELECT
            MAX(`ecInvoicePeriod`.`enteredDate`) 
         FROM
            `ecInvoicePeriod` 
         WHERE
            (
(`ecInvoicePeriod`.`cuInvoiceID` = `bjs`.`Info_cuInvoiceID`) 
               AND 
               (
                  `ecInvoicePeriod`.`ecType` = 'A'
               )
            )
) AS DATE) AS `CommEnteredDate`,
            `bjs`.`coDivisionID` AS `coDivisionID`,
            `bjs`.`DivDescription` AS `DivDescription`,
            `bjs`.`DivCode` AS `DivCode`,
            `bjs`.`CustomerName` AS `CustomerName`,
            `bjs`.`joMasterID` AS `joMasterID`,
            NULL AS `veBillID`,
            IFNULL(`rm`.`Name`, 
            (
               SELECT
                  `rxMaster`.`Name` 
               FROM
                  `rxMaster` 
               WHERE
                  (
                     `rxMaster`.`rxMasterID` = `vp`.`rxVendorID`
                  )
            )
) AS `VendorName`,
            `bjs`.`isJobPaidInFull` AS `isJobPaidInFull`,
            `bjs`.`isFollowingPeriod` AS `isFollowingPeriod`,
            `bjs`.`CommAfterPayment` AS `CommAfterPayment`,
            `bjs`.`dayAfter` AS `dayAfter` 
         FROM
            (
((((`BaseJobSplit` `bjs` 
               JOIN
                  `joInvoiceCost` `jic` 
                  ON((`bjs`.`ReleasedetailID` = `jic`.`joReleaseDetailID`))) 
               LEFT JOIN
                  `joReleaseType` 
                  ON((`bjs`.`Info_ReleaseType` = `joReleaseType`.`joReleaseTypeID`))) 
               LEFT JOIN
                  `cuSO` `co` 
                  ON((`co`.`joReleaseID` = `bjs`.`ReleaseId`))) 
               LEFT JOIN
                  `rxMaster` `rm` 
                  ON((`co`.`rxCustomerID` = `rm`.`rxMasterID`))) 
               LEFT JOIN
                  `vePO` `vp` 
                  ON((`vp`.`joReleaseID` = `bjs`.`ReleaseId`))
            )
         UNION ALL
         SELECT
            'VendorComm' AS `RecordType`,
            NULL AS `CustomerStatus`,
            `jom`.`JobNumber` AS `JobNumber`,
            `jom`.`Description` AS `JobName`,
            `vec`.`InvoiceNumber` AS `InvoiceNumber`,
            IFNULL(`joReleaseType`.`Description`, 'Sales') AS `ReleaseTypeDescription`,
            `vec`.`ShipDate` AS `InvoiceDate`,
            NULL AS `InvoiceSubtotal`,
            NULL AS `InvoiceFreight`,
            NULL AS `InvoiceCostStock`,
            NULL AS `InvoiceCostDrop`,
            NULL AS `InvoiceCostDropFreight`,
            IFNULL(`vec`.`BillAmount`, 0) AS `InvoiceAmount`,
            NULL AS `InvoiceDiscount`,
            NULL AS `InvoiceToBePaid`,
            NULL AS `InvoicePaid`,
            NULL AS `CustomerBalance`,
            NULL AS `CustomerPaidDate`,
            NULL AS `AddCostTotals`,
            `tsul`.`FullName` AS `SalesRepAssigned`,
            NULL AS `info_memoStatus`,
            NULL AS `info_CreditMemo`,
            0 AS `info_rxCustomerID`,
            0 AS `info_cuInvoiceID`,
            `vec`.`veCommDetailID` AS `info_veCommDetailID`,
            `vec`.`ecInvoicePeriodID` AS `info_ecInvoicePeriodID`,
            `ecs`.`ecSplitJobID` AS `info_ecSplitjobID`,
            `jor`.`joReleaseID` AS `info_joReleaseID`,
            IFNULL(`tsul1`.`UserLoginID`, `tsul`.`UserLoginID`) AS `info_userLoginID`,
            IFNULL(`jor`.`ReleaseType`, - (1)) AS `ReleaseTypes`,
            `vec`.`joReleaseDetailID` AS `Info_ReleasedetailID`,
            0 AS `info_joInvoiceCostID`,
            `vec`.`CommAmount` AS `CalcRawInvoiceProfit`,
            IFNULL((
            SELECT
               `emMaster`.`CommissionJobProfit` 
            FROM
               `emMaster` 
            WHERE
               (
                  `emMaster`.`UserLoginID` = `jom`.`cuAssignmentID0`
               )
               LIMIT 0, 1), 0) AS `SalesRepJobProfit`,
               (
(`vec`.`CommAmount` * IFNULL((
                  SELECT
                     `emMaster`.`CommissionJobProfit` 
                  FROM
                     `emMaster` 
                  WHERE
                     (
                        `emMaster`.`UserLoginID` = `jom`.`cuAssignmentID0`
                     )
                     LIMIT 0, 1), 0)) / 100
               )
               AS `CalcRevShare`,
               (
(((`vec`.`CommAmount` * IFNULL((
                  SELECT
                     `emMaster`.`CommissionJobProfit` 
                  FROM
                     `emMaster` 
                  WHERE
                     (
                        `emMaster`.`UserLoginID` = `jom`.`cuAssignmentID0`
                     )
                     LIMIT 0, 1), 0)) / 100) * IFNULL(`ecs`.`Allocated`, 100)) / 100
               )
               AS `CalcSplitRev`,
               IFNULL(`ecs`.`splitType`, 'N/A') AS `CommSplitType`,
               IFNULL(`ecs`.`Allocated`, 100) AS `CommPercent`,
               `ecs`.`ChangedOn` AS `CommSplitChangedOn`,
               IFNULL(`tsul1`.`FullName`, `tsul`.`FullName`) AS `CommSalesRep`,
               `vec`.`CommDate` AS `CommAvailableDate`,
               IF(ISNULL(`vec`.`ecInvoicePeriodID`), 'No', 'Yes') AS `IsCommPaid`,
               (
                  SELECT
                     MAX(`ecInvoicePeriod`.`DatePaid`) 
                  FROM
                     `ecInvoicePeriod` 
                  WHERE
                     (
                        `vec`.`ecInvoicePeriodID` = `ecInvoicePeriod`.`ecInvoicePeriodID`
                     )
               )
               AS `CommPaidDate`,
               `vec`.`ShipDate` AS `CommEnteredDate`,
               NULL AS `coDivisionID`,
               NULL AS `DivDescription`,
               NULL AS `DivCode`,
               NULL AS `CustomerName`,
               `jom`.`joMasterID` AS `joMasterID`,
               NULL AS `veBillID`,
               `rm`.`Name` AS `VendorName`,
               `emm`.`isJobPaidInFull` AS `isJobPaidInFull`,
               `emm`.`isFollowingPeriod` AS `isFollowingPeriod`,
               `emm`.`CommAfterPayment` AS `CommAfterPayment`,
               `emm`.`dayAfter` AS `dayAfter` 
            FROM
               (
(((((((((`veCommDetail` `vec` 
                  JOIN
                     `joReleaseDetail` `jrd` 
                     ON((`jrd`.`joReleaseDetailID` = `vec`.`joReleaseDetailID`))) 
                  JOIN
                     `joRelease` `jor` 
                     ON((`jor`.`joReleaseID` = `jrd`.`joReleaseID`))) 
                  JOIN
                     `joMaster` `jom` 
                     ON((`jom`.`joMasterID` = `jor`.`joMasterID`))) 
                  JOIN
                     `tsUserLogin` `tsul` 
                     ON((`tsul`.`UserLoginID` = `jom`.`cuAssignmentID0`))) 
                  LEFT JOIN
                     `ecSplitJob` `ecs` 
                     ON((`ecs`.`joMasterID` = `jor`.`joMasterID`))) 
                  LEFT JOIN
                     `emMaster` `emm` 
                     ON((`emm`.`emMasterID` = `ecs`.`rxMasterID`))) 
                  LEFT JOIN
                     `tsUserLogin` `tsul1` 
                     ON((`emm`.`UserLoginID` = `tsul1`.`UserLoginID`))) 
                  LEFT JOIN
                     `joReleaseType` 
                     ON((`jor`.`ReleaseType` = `joReleaseType`.`joReleaseTypeID`))) 
                  LEFT JOIN
                     `vePO` `vp` 
                     ON((`vp`.`joReleaseID` = `jor`.`joReleaseID`))) 
                  LEFT JOIN
                     `rxMaster` `rm` 
                     ON((`vp`.`rxVendorID` = `rm`.`rxMasterID`))
               )
            WHERE
               (
(`jor`.`ReleaseType` = 4) 
                  AND 
                  (
                     `vec`.`ShipDate` >= '2014-09-01'
                  )
                  AND 
                  (
                     `jrd`.`joReleaseDetailID` IS NOT NULL
                  )
                  AND 
                  (
                     `vec`.`hasCustomerInvoice` <> 1
                  )
               )
            UNION ALL
            SELECT
               'VendorExpense' AS `RecordType`,
               NULL AS `CustomerStatus`,
               `jom`.`JobNumber` AS `JobNumber`,
               `jom`.`Description` AS `JobName`,
               `vb`.`InvoiceNumber` AS `InvoiceNumber`,
               NULL AS `ReleaseTypeDescription`,
               `vb`.`BillDate` AS `InvoiceDate`,
               `vec`.`ExpenseAmount` AS `InvoiceSubtotal`,
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
               `tsul`.`FullName` AS `SalesRepAssigned`,
               NULL AS `info_memoStatus`,
               NULL AS `info_CreditMemo`,
               0 AS `info_rxCustomerID`,
               0 AS `info_cuInvoiceID`,
               `vec`.`veBillDistributionID` AS `info_veCommDetailID`,
               NULL AS `info_ecInvoicePeriodID`,
               `ecs`.`ecSplitJobID` AS `info_ecSplitjobID`,
               NULL AS `info_joReleaseID`,
               IFNULL(`tsul1`.`UserLoginID`, `tsul`.`UserLoginID`) AS `info_userLoginID`,
                - (2) AS `ReleaseTypes`,
               NULL AS `Info_ReleasedetailID`,
               0 AS `info_joInvoiceCostID`,
                - (`vec`.`ExpenseAmount`) AS `CalcRawInvoiceProfit`,
               IFNULL((
               SELECT
                  `emMaster`.`CommissionJobProfit` 
               FROM
                  `emMaster` 
               WHERE
                  (
                     `emMaster`.`UserLoginID` = `jom`.`cuAssignmentID0`
                  )
                  LIMIT 0, 1), 0) AS `SalesRepJobProfit`,
                   - (((`vec`.`ExpenseAmount` * IFNULL((
                  SELECT
                     `emMaster`.`CommissionJobProfit` 
                  FROM
                     `emMaster` 
                  WHERE
                     (
(`emMaster`.`UserLoginID` = `jom`.`cuAssignmentID0`) 
                        AND 
                        (
                           `emMaster`.`GetsCommission` = 1
                        )
                     )
                     LIMIT 0, 1), 0)) / 100)) AS `CalcRevShare`,
                      - (((((`vec`.`ExpenseAmount` * IFNULL((
                     SELECT
                        `emMaster`.`CommissionJobProfit` 
                     FROM
                        `emMaster` 
                     WHERE
                        (
(`emMaster`.`UserLoginID` = `jom`.`cuAssignmentID0`) 
                           AND 
                           (
                              `emMaster`.`GetsCommission` = 1
                           )
                        )
                        LIMIT 0, 1), 0)) / 100) * IFNULL(`ecs`.`Allocated`, 100)) / 100)) AS `CalcSplitRev`,
                        IFNULL(`ecs`.`splitType`, 'N/A') AS `CommSplitType`,
                        IFNULL(`ecs`.`Allocated`, 100) AS `CommPercent`,
                        `ecs`.`ChangedOn` AS `CommSplitChangedOn`,
                        IF(ISNULL(`ecs`.`rxMasterID`), IFNULL(`tsul1`.`FullName`, `tsul`.`FullName`), CONVERT(`rxMaster`.`Name` USING utf8)) AS `CommSalesRep`,
                        `vb`.`BillDate` AS `CommAvailableDate`,
                        IF(ISNULL(`vec`.`ecInvoicePeriodID`), 'No', 'Yes') AS `IsCommPaid`,
                        (
                           SELECT
                              MAX(`ecInvoicePeriod`.`DatePaid`) 
                           FROM
                              `ecInvoicePeriod` 
                           WHERE
                              (
                                 `vec`.`ecInvoicePeriodID` = `ecInvoicePeriod`.`ecInvoicePeriodID`
                              )
                        )
                        AS `CommPaidDate`,
                        NULL AS `CommEnteredDate`,
                        NULL AS `coDivisionID`,
                        NULL AS `DivDescription`,
                        NULL AS `DivCode`,
                        NULL AS `CustomerName`,
                        `vec`.`joMasterID` AS `joMasterID`,
                        `vec`.`veBillID` AS `veBillID`,
                        NULL AS `VendorName`,
                        `emm`.`isJobPaidInFull` AS `isJobPaidInFull`,
                        `emm`.`isFollowingPeriod` AS `isFollowingPeriod`,
                        `emm`.`CommAfterPayment` AS `CommAfterPayment`,
                        `emm`.`dayAfter` AS `dayAfter` 
                     FROM
                        (
((((((`veBillDistribution` `vec` 
                           JOIN
                              `joMaster` `jom` 
                              ON((`jom`.`joMasterID` = `vec`.`joMasterID`))) 
                           LEFT JOIN
                              `veBill` `vb` 
                              ON((`vec`.`veBillID` = `vb`.`veBillID`))) 
                           JOIN
                              `tsUserLogin` `tsul` 
                              ON((`tsul`.`UserLoginID` = `jom`.`cuAssignmentID0`))) 
                           LEFT JOIN
                              `ecSplitJob` `ecs` 
                              ON(((`jom`.`joMasterID` = `ecs`.`joMasterID`) 
                              AND ISNULL(`ecs`.`joReleaseID`)))) 
                           LEFT JOIN
                              `emMaster` `emm` 
                              ON((`emm`.`emMasterID` = `ecs`.`rxMasterID`))) 
                           LEFT JOIN
                              `tsUserLogin` `tsul1` 
                              ON((`emm`.`UserLoginID` = `tsul1`.`UserLoginID`))) 
                           LEFT JOIN
                              `rxMaster` 
                              ON((`ecs`.`rxMasterID` = `rxMaster`.`rxMasterID`))
                        );
                         

*/


-- ==================================================

DROP VIEW  IF EXISTS v_INV_ALLBINS;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_INV_ALLBINS` AS
    SELECT 
        `b`.`binId` AS `binId`,
        `b`.`prWarehouseID` AS `prWarehouseID`,
        `b`.`prWarehouseInventoryID` AS `prWarehouseInventoryID`,
        `b`.`prMasterID` AS `prMasterID`,
        `b`.`binSequence` AS `binSequence`,
        `b`.`rack` AS `rack`,
        `b`.`row` AS `row`,
        `b`.`slot` AS `slot`,
        `b`.`overrideName` AS `overrideName`,
        `b`.`searchName` AS `searchName`,
        `b`.`maxQuantity` AS `maxQuantity`,
        `b`.`InventoryOnHand` AS `InventoryOnHand`,
        `b`.`InventoryAllocated` AS `InventoryAllocated`,
        `b`.`InventoryOnOrder` AS `InventoryOnOrder`,
        `b`.`AverageCost` AS `AverageCost`,
        `b`.`LastUpdatedTime` AS `LastUpdatedTime`,
        `b`.`changedByID` AS `changedByID`,
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
        `wi`.`AverageCost` AS `whAverageCost`,
        `ic`.`CountedOnHand` AS `inventoryCounted`,
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
        ISNULL(`b`.`inTransfer`)
    ORDER BY `w`.`Description` , `pm`.`ItemCode` , `b`.`binSequence`;


-- ==================================================

DROP VIEW  IF EXISTS v_INV_bin;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_INV_bin` AS
select b.*,
pm.ItemCode, 
pm.Description, 
dept.Description as Department,
`dept`.`prDepartmentID` AS `prDepartmentId`,
cat.Description as Category,
`cat`.`prCategoryID` AS `prCategoryId`,
vend.Name as PrimaryVendor,
pm.InventoryOnHand as prInventoryOnHand, 
pm.InventoryAllocated as prInventoryAllocated, 
PO_getOnOrder(pm.prMasterID) as prInventoryOnOrder,
pm.AverageCost as prAverageCost,
w.Description as whDescription,
w.Address1 as whAddress1,
wi.InventoryOnHand as whInventoryOnHand, 
wi.InventoryAllocated as whInventoryAllocated, 
wi.InventoryOnOrder as whInventoryOnOrder, 
wi.AverageCost as whAverageCost,
ic.`CountedOnHand` AS `inventoryCounted`,
CONCAT(b.searchName,IFNULL(pm.ItemCode,''),IFNULL(w.Description,'')) as detailed_search
from bin b
left join prMaster pm on (pm.prMasterID = b.prMasterID)
left join prDepartment dept on (dept.prDepartmentID = pm.prDepartmentID)
left join prCategory cat on (cat.prCategoryID = pm.prCategoryID)
left join rxMaster vend on (vend.rxMasterID = pm.rxMasterIDPrimaryVendor)
left join prWarehouse w on (w.prWarehouseID = b.prWarehouseID)
left join prWarehouseInventory wi on (wi.prWarehouseInventoryID = b.prWarehouseInventoryID)
LEFT JOIN `prInventoryCount` `ic` ON (`pm`.`prMasterID` = `ic`.`prMasterID`)
    WHERE
        `pm`.`InActive` = 0
            AND `pm`.`IsInventory` = 1
            and ISNULL(`b`.`inTransfer`)
order by whDescription, pm.ItemCode, binSequence;


-- ==================================================

DROP VIEW  IF EXISTS v_INV_bin_warehouseRollup;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_INV_bin_warehouseRollup` AS
    SELECT 
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
INV_getYearToDateSold(`b`.`prMasterID`,`b`.`prWarehouseID`)  AS `YTDSold`,
/*
        IFNULL((SELECT 
                        SUM(`cud`.`QuantityBilled`)
                    FROM
                        (((`cuInvoiceDetail` `cud`
                        LEFT JOIN `cuInvoice` `cu` ON ((`cud`.`cuInvoiceID` = `cu`.`cuInvoiceID`)))
                        LEFT JOIN `joReleaseDetail` `jrd` ON ((`jrd`.`joReleaseDetailID` = `cu`.`joReleaseDetailID`)))
                        LEFT JOIN `joRelease` `jo` ON ((`jo`.`joReleaseID` = `jrd`.`joReleaseID`)))
                    WHERE
                        ((`cud`.`prMasterID` = `b`.`prMasterID`)
                            AND (`cu`.`prFromWarehouseID` = `b`.`prWarehouseID`)
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
                0) AS `YTDSold`,
*/                
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
        (`w`.`InActive` = 0)
    GROUP BY `b`.`prWarehouseID` , `b`.`prMasterID`;

-- select * from v_INV_bin_warehouseRollup
-- having prMasterID=878;


-- select * from v_INV_bin_warehouseRollup
-- having prWarehouseID=879810;


DROP VIEW  IF EXISTS v_INV_bin_productRollup;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_INV_bin_productRollup` AS
select 
-1 as binId,
-1 as prWarehouseID,
-1 as prWarehouseInventoryID,
b.prMasterID,
null as primaryBin,
max(b.binSequence) as binSequence,
sum(b.InventoryOnHand) as InventoryOnHand,
sum(b.InventoryAllocated) as InventoryAllocated,
sum(b.InventoryOnOrder) as InventoryOnOrder,
avg(b.AverageCost) as AverageCost,
pm.ItemCode, 
pm.Description, 
dept.Description as Department,
`dept`.`prDepartmentID` AS `prDepartmentId`,
cat.Description as Category,
`cat`.`prCategoryID` AS `prCategoryId`,
vend.Name as PrimaryVendor,
pm.InventoryOnHand as prInventoryOnHand, 
pm.InventoryAllocated as prInventoryAllocated, 
pm.InventoryOnOrder as prInventoryOnOrder, 
pm.AverageCost as prAverageCost,
w.Description as whDescription,
w.Address1 as whAddress1,
wi.InventoryOnHand as whInventoryOnHand, 
wi.InventoryAllocated as whInventoryAllocated, 
wi.InventoryOnOrder as whInventoryOnOrder, 
`ic`.`CountedOnHand` AS `inventoryCounted`,
CONCAT(b.searchName,IFNULL(pm.ItemCode,''),IFNULL(w.Description,'')) as detailed_search
from bin b
left join prMaster pm on (pm.prMasterID = b.prMasterID)
left join prDepartment dept on (dept.prDepartmentID = pm.prDepartmentID)
left join prCategory cat on (cat.prCategoryID = pm.prCategoryID)
left join rxMaster vend on (vend.rxMasterID = pm.rxMasterIDPrimaryVendor)
left join prWarehouse w on (w.prWarehouseID = b.prWarehouseID)
left join prWarehouseInventory wi on (wi.prWarehouseInventoryID = b.prWarehouseInventoryID)
LEFT JOIN `prInventoryCount` `ic` ON (`pm`.`prMasterID` = `ic`.`prMasterID`)
group by b.prMasterID;

-- select * from v_INV_bin_productRollup
-- having prWarehouseID=1 and prMasterID=339;






-- ======================================

DROP VIEW  IF EXISTS v_INV_product;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_INV_product` AS
    SELECT 
        `pm`.`prMasterID` AS `prMasterID`,
        `pm`.`InActive` AS `InActive`,
        `pm`.`ItemCode` AS `ItemCode`,
        `pm`.`Description` AS `Description`,
        `cat`.`Description` AS `Category`,
        `pm`.`prCategoryID` AS `prCategoryID`,
        `pm`.`InventoryOnHand` AS `prInventoryOnHand`,
        `pm`.`InventoryAllocated` AS `prInventoryAllocated`,
        -- `pm`.`InventoryOnOrder` AS `prInventoryOnOrder`,
PO_getOnOrder(pm.prMasterID) as prInventoryOnOrder,
        `pm`.`AverageCost` AS `prAverageCost`,
        `wi`.`prWarehouseID` AS `prWarehouseID`,
        `wi`.`InventoryOnHand` AS `whInventoryOnHand`,
        `wi`.`InventoryAllocated` AS `whInventoryAllocated`,
        `wi`.`InventoryOnOrder` AS `whInventoryOnOrder`,
        CONCAT(IFNULL(`cat`.`Description`, ''),
                `pm`.`ItemCode`,
                IFNULL(`pm`.`Description`, '')) AS `detailed_search`,
        `vend`.`Name` AS `PrimaryVendor`
    FROM
        (((`prMaster` `pm`
        LEFT JOIN `prWarehouseInventory` `wi` ON ((`wi`.`prMasterID` = `pm`.`prMasterID`)))
        LEFT JOIN `prCategory` `cat` ON ((`cat`.`prCategoryID` = `pm`.`prCategoryID`)))
        LEFT JOIN `rxMaster` `vend` ON ((`vend`.`rxMasterID` = `pm`.`rxMasterIDPrimaryVendor`)))
    WHERE
        ((`pm`.`InActive` = 0)
            AND (`pm`.`IsInventory` = 1));



-- ======================================


DROP VIEW  IF EXISTS v_PR_product;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_PR_product` AS
    SELECT 
        `pm`.`prMasterID` AS `prMasterID`,
        `pm`.`InActive` AS `InActive`,
        `pm`.`IsInventory` AS `IsInventory`,
        `pm`.`ItemCode` AS `ItemCode`,
        `pm`.`Description` AS `Description`,
        `cat`.`Description` AS `Category`,
        `pm`.`prCategoryID` AS `prCategoryID`,
        `dep`.`Description` AS `Department`,
        `pm`.`prDepartmentID` AS `prDepartmentID`,
        `pm`.`InventoryOnHand` AS `prInventoryOnHand`,
        `pm`.`InventoryAllocated` AS `prInventoryAllocated`,
        -- `pm`.`InventoryOnOrder` AS `prInventoryOnOrder`,
        (case when `pm`.`InventoryAllocated` - `pm`.`InventoryOnHand`>0 THEN `pm`.`InventoryAllocated` - `pm`.`InventoryOnHand` else 0 END ) AS `BackOrder`,
        -- (case when `pm`.`InventoryAllocated` - `pm`.`InventoryOnHand`>0 THEN `pm`.`InventoryAllocated` - `pm`.`InventoryOnHand` else 0 END ) AS `prInventoryOnOrder`,

PO_getOnOrder(pm.prMasterID) as prInventoryOnOrder,
-- and prod.IsInventory=1;

        (`pm`.`InventoryOnHand` - `pm`.`InventoryAllocated`) AS `prInventoryAvailable`,
        `pm`.`AverageCost` AS `prAverageCost`,
        `pm`.`Website` AS `website`,
        `pm`.`BoxQty` AS `Box`,
        `pm`.`Weight` AS `WeightLbs`,
        `pm`.`Weight` AS `WeightOz`,
        `pm`.`rxMasterIDPrimaryVendor` AS `PrimaryVendorID`,
        `vend`.`Name` AS `PrimaryVendor`,
        `pm`.`VendorItemNumber` AS `PrimaryVendorItemCode`,
        `pm`.`rxMasterIDSecondaryVendor01` AS `SecondaryVendor1ID`,
        `vend1`.`Name` AS `SecondaryVendor1`,
        `pm`.`VendorItemNumber01` AS `SecondaryVendor1ItemCode`,
        `pm`.`SalesPrice00` AS `BaseSellingPrice`,
        `pm`.`IsTaxable` AS `isTaxable`,
        `pm`.`SingleItemTax` AS `singleItemTax`,
        (`pm`.`SalesPrice00` - `pm`.`AverageCost`) AS `ProfitMargin`,
        (((`pm`.`SalesPrice00` - `pm`.`AverageCost`) / `pm`.`SalesPrice00`) * 100) AS `ProfitPercent`,
        `pm`.`AverageCost` AS `SV_AvgCost`,
        `pm`.`Consignment` AS `SV_WhseCost`,
        `pm`.`LastCost` AS `SV_FactoryCost`,
        `pm`.`POMult` AS `SV_Multiplier`,
        `sys`.`prPriceLevel0` AS `prPriceLevel0`,
        `sys`.`prPriceLevel1` AS `prPriceLevel1`,
        `sys`.`prPriceLevel2` AS `prPriceLevel2`,
        `sys`.`prPriceLevel3` AS `prPriceLevel3`,
        `sys`.`prPriceLevel4` AS `prPriceLevel4`,
        `sys`.`prPriceLevel5` AS `prPriceLevel5`,
        `sys`.`prPriceLevel6` AS `prPriceLevel6`,
        `sys`.`prPriceLevelval0` AS `prPriceLevelval0`,
        `sys`.`prPriceLevelval1` AS `prPriceLevelval1`,
        `sys`.`prPriceLevelval2` AS `prPriceLevelval2`,
        `sys`.`prPriceLevelval3` AS `prPriceLevelval3`,
        `sys`.`prPriceLevelval4` AS `prPriceLevelval4`,
        `sys`.`prPriceLevelval5` AS `prPriceLevelval5`,
        CONCAT(IFNULL(`cat`.`Description`, ''),
                `pm`.`ItemCode`,
                IFNULL(`pm`.`Description`, '')) AS `detailed_search`,
        `sysv`.`ValueCurrency` AS `sysMarkupAmount`,
        `cat`.`MarkupAmount` AS `catMarkupAmount`,
        `pm`.`SOPopup` AS `SOPopup`,
        `pm`.`POPopup` AS `POPopup`,
        `pm`.`CUPopup` AS `CUPopup`
    FROM
        ((((((`prMaster` `pm`
        LEFT JOIN `prCategory` `cat` ON (((`cat`.`prCategoryID` = `pm`.`prCategoryID`)
            AND (`cat`.`MarkupCost` = 1))))
        LEFT JOIN `prDepartment` `dep` ON ((`dep`.`prDepartmentID` = `pm`.`prDepartmentID`)))
        LEFT JOIN `rxMaster` `vend` ON ((`vend`.`rxMasterID` = `pm`.`rxMasterIDPrimaryVendor`)))
        LEFT JOIN `rxMaster` `vend1` ON ((`vend1`.`rxMasterID` = `pm`.`rxMasterIDSecondaryVendor01`)))
        LEFT JOIN `sysInfo` `sys` ON ((`sys`.`sysInfoID` = 1)))
        LEFT JOIN `sysVariable` `sysv` ON ((`sysv`.`sysVariableID` = 1020000)));

-- ======================================

DROP VIEW  IF EXISTS v_INV_WHtransfer;

CREATE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `v_INV_WHtransfer` AS		
select 
        prWHtransfer.prTransferID as prTransferId ,
        prWHtransfer.TransferDate as transferDate,
        prWHtransfer.prFromWareHouseID as prFromWarehouseId,
        prWHtransfer.prToWareHouseID as prToWarehouseId,
        prWHtransfer.Description as descr,
        prWHtransfer.coAccountID,
        prWHtransfer.adjustCogAccountID,
        prWHtransfer.reasonCode as reasonCode,
         (SELECT 
                COUNT(`d`.`prTransferID`)
            FROM
                `prWHtransferDetail` `d`
            WHERE
                (`d`.`prTransferID` = `prWHtransfer`.`prTransferID`)) AS `count1`,
        (SELECT 
                COUNT(`d`.`prTransferID`)
            FROM
                `prWHtransferDetail` `d`
            WHERE
                ((`d`.`prTransferID` = `prWHtransfer`.`prTransferID`)
                    AND ISNULL(`d`.`ReceivedDate`))) AS `count2`,

         (SELECT 
                IFNULL(COUNT(0), 0)
            FROM
                `prWHtransferDetail` `d`
            WHERE
                (`d`.`prTransferID` = `prWHtransfer`.`prTransferID`)) AS `count3`,
        (SELECT 
                (CASE
                        WHEN (`count3` = 0) THEN 'No Transfers'
                        ELSE (CASE
                            WHEN (`count1` = `count2`) THEN ''
                            WHEN (`count2` = 0) THEN 'Received'
                            ELSE 'Partial'
                        END)
                    END)
            ) AS `sessionStatus`,
        prWHtransfer.ReceivedDate,
        prWHtransfer.EstreceiveDate,
        prWHtransfer.screenno,
        prWHtransfer.TransNumber,
        prWHtransfer.CreatedById,
        `pr1`.`SearchName` AS `from`,
        `pr2`.`SearchName` AS `to`
        from prWHtransfer 
         LEFT JOIN `prWarehouse` `pr1` ON ((`pr1`.`prWarehouseID` = `prWHtransfer`.`prFromWareHouseID`))
        LEFT JOIN `prWarehouse` `pr2` ON ((`pr2`.`prWarehouseID` = `prWHtransfer`.`prToWareHouseID`))
        ORDER BY  TransferDate desc;


-- ======================================
DROP VIEW  IF EXISTS v_INV_getPO;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_INV_getPO` AS
    SELECT 
        `vp`.`vePOID` AS `vePOID`,
        `vp`.`CreatedOn` AS `createdOn`,
        `vp`.`joReleaseID` AS `joReleaseID`,
        `vp`.`rxVendorID` AS `rxVendorID`,
        `vp`.`PONumber` AS `ponumber`,
        `rm`.`Name` AS `vendorName`,
        `vp`.`Subtotal` AS `subtotal`,
        `vp`.`TransactionStatus` AS `TransactionStatus`,
        `vp`.`Tag` AS `Tag`,
        `vp`.`receiveddate` AS `receiveddate`,
        (SUM(`ve`.`QuantityOrdered`) - SUM(IF((ISNULL(`ve`.`QuantityReceived`)
                OR (`ve`.`QuantityReceived` = '')),
            0,
            `ve`.`QuantityReceived`))) AS `difference`,
        MAX(`vr`.`veReceiveID`) AS `veReceiveID`,
        CONCAT(`vp`.`PONumber`, `rm`.`Name`) AS `detailSearch`
    FROM
        ((((`vePODetail` `ve`
        LEFT JOIN `vePO` `vp` ON ((`vp`.`vePOID` = `ve`.`vePOID`)))
        LEFT JOIN `rxMaster` `rm` ON ((`vp`.`rxVendorID` = `rm`.`rxMasterID`)))
        LEFT JOIN `veReceive` `vr` ON ((`vr`.`vePOID` = `ve`.`vePOID`)))
        LEFT JOIN `prMaster` `pr` ON ((`pr`.`prMasterID` = `ve`.`prMasterID`)))
    WHERE
        ((`ve`.`vePOID` = `vp`.`vePOID`)
            AND (`pr`.`IsInventory` <> 0)
            AND ISNULL(`vp`.`joReleaseID`)
            AND (`vp`.`TransactionStatus` <> -(1)))
    GROUP BY `vp`.`vePOID`;

  --  ===================================================

DROP VIEW  IF EXISTS v_INV_WHtransferDetail;

CREATE 
    ALGORITHM = UNDEFINED 
    SQL SECURITY DEFINER
VIEW `v_INV_WHtransferDetail` AS
select 
t.Description as descr,
t.TransNumber as TransNumber,
t.TransferDate as TransferDate,
t.reasonCode as reasonCode,
t.EstreceiveDate as EstreceiveDate,
d.prTransferDetailID as prTransferDetailId, 
d.prTransferID as prTransferId, 
d.prMasterID as prMasterId, 
p.Description as description , 
d.QuantityTransfered as quantityTransfered , 
p.AverageCost as inventoryCost, 
d.QuantityAvailable as quantityAvailable, 
p.ItemCode as itemCode,
d.difference as difference, 
d.fromBinId as fromBinId , 
d.toBinId as toBinId , 
b1.searchName as fromBinlocation,
b2.searchName as toBinlocation,
b1.InventoryOnHand as currentInventoryOnHand,
d.ReceivedDate as ReceivedDate 
from prWHtransferDetail d
left join prWHtransfer t on (d.prTransferID = t.prTransferID)
left join prMaster p on (d.prMasterID = p.prMasterID)
left join bin b1 on (b1.binId = d.fromBinId)
left join bin b2 on (b2.binId = d.toBinId);




-- ==================================================

 DROP VIEW  IF EXISTS v_PO_vePODetailBin;
/*
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_PO_vePODetailBin` AS
    SELECT 
		b.*,
        -- a.prWarehouseID,
        -- a.vePODetailID,
        -- a.prMasterID,
        -- a.vePODetailBinID,
        a.vePODetailBinID,
        a.vePODetailID,
        a.InventoryPutAway,
        a.reversed,
        a.GlRecordedTime,
        a.LastUpdatedTime as poDetailLastUpdatedTime
    FROM
		bin b
        left join `vePODetailBin` `a` on (a.binId = b.binId and a.reversed=0); */


DROP VIEW  IF EXISTS v_PriorReceipts;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `v_PriorReceipts` AS
    SELECT DISTINCT
        DATE_FORMAT(`vr`.`ReceiveDate`, "%Y-%m-%d") AS `receiveDate`,
        `vr`.`veReceiveID` AS `veReceiveId`,
        `vr`.`vePOID` AS `vePOID`,
        (SELECT 
                COUNT(0)
            FROM
                `tpInventoryLogMaster`
            WHERE
                ((`tpInventoryLogMaster`.`transID` = `vr`.`veReceiveID`)
                    AND (`tpInventoryLogMaster`.`referenceNo` = `vr`.`vePOID`))) AS `count`,
        (SELECT 
                (CASE
                        WHEN
                            (`count` = 1)
                        THEN
                            (SELECT 
                                    `tpInventoryLogMaster`.`vendorNumber`
                                FROM
                                    `tpInventoryLogMaster`
                                WHERE
                                    ((`tpInventoryLogMaster`.`transID` = `vr`.`veReceiveID`)
                                        AND (`tpInventoryLogMaster`.`referenceNo` = `vr`.`vePOID`)))
                        ELSE 'MULTIPLE'
                    END)
            ) AS `vendorNumber`
    FROM
        (`veReceive` `vr`
        LEFT JOIN `vePO` `tp` ON ((`vr`.`vePOID` = `tp`.`vePOID`)));

DROP VIEW  IF EXISTS SalesOrderInvoicesView;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `SalesOrderInvoicesView` AS
SELECT cuSOID,CASE jr.ReleaseType WHEN 1 THEN "DropShip" WHEN 2 THEN "StockOrder" WHEN 3 THEN "BillOnly" WHEN 4 THEN "CommissionOrder" WHEN 5 THEN "ServiceOrder" ELSE "SalesOrder" END AS releaseType ,SUM(IFNULL(InvoiceAmount,0))AS totalInvoiceAmount,SUM(IFNULL(ci.SubTotal,0)) AS totalInvoiceSubTotal FROM cuInvoice ci  
	LEFT JOIN  joReleaseDetail jrd ON(ci.joReleaseDetailID=jrd.joReleaseDetailID) 
	LEFT JOIN  joRelease jr ON(jrd.joReleaseID=jr.joReleaseID) GROUP BY cuSOID,jr.joReleaseID 
	HAVING cuSOID IS NOT NULL AND cuSOID>0 AND releaseType IN("StockOrder","ServiceOrder","SalesOrder");


-- ======================================

DROP VIEW  IF EXISTS InvoiceView_emMaster;

CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `InvoiceView_emMaster` AS
SELECT v.*,m.CommissionJobProfit, m.CommissionInvoiceProfit FROM InvoiceView v
left join emMaster m on (m.UserLoginID = v.SalesPersonID and m.EmploymentStatus=1);





select 'SUCCESS VIEW CREATION!!';
select * from tp_version;