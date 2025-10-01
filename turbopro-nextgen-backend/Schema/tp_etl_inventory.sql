/*


mysql --local-infile=1 -uroot -p
password=   Pa55w0rd#$ems
set global local_infile=true;

use premierhvac;

LOAD DATA LOCAL INFILE '/home/ubuntu/DataImport/premier_inventory.csv' INTO TABLE ETL_SOURCE_inventory CHARACTER
SET UTF8MB4 FIELDS TERMINATED BY '|' ENCLOSED BY '' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;


DROP TABLE IF EXISTS ETL_error;

CREATE TABLE `ETL_error` (
  errorId INT  NOT NULL  AUTO_INCREMENT,
  description varchar(100),
  `created` datetime  NOT NULL DEFAULT now(),
  PRIMARY KEY (errorId))
ENGINE = InnoDB  AUTO_INCREMENT=1000;

DROP TABLE IF EXISTS ETL_SOURCE_inventory;

CREATE TABLE `ETL_SOURCE_inventory` (
  itemCode varchar(100),
  Description varchar(255),
  rxMasterIDPrimaryVendor int,
  InventoryOnHand int,
  AverageCost DECIMAL(19,4),
  IsInventory int,
  IsTaxable int,
  prDepartmentID int,
  prWarehouseID int)
ENGINE = InnoDB;

*/


/* ==========================================

call ETL_manage_inventory('LOAD_PRMASTER',9999);
call ETL_manage_inventory('CREATE_PRWAREHOUSEINVENTORY',9999);
call ETL_manage_inventory('LOAD_PRWAREHOUSEINVENTORY',9999);
call ETL_manage_inventory('DELETE_INVENTORY',9999);

-- call this afterwards to create the bins
call INV_createBinsFromWarehouseInventory('INIT',null,null); 

=============================================*/

DROP procedure IF EXISTS `ETL_manage_inventory`;

DELIMITER $$

CREATE PROCEDURE `ETL_manage_inventory` ( IN _action varchar(100), _loadedBy INT )
ETL_manage_inventory: BEGIN

DECLARE _report1,_report2,_report3 int;
DECLARE _finished INTEGER DEFAULT 0;
DECLARE _prMasterFound int;
DECLARE _prMasterInventoryFound int;

DECLARE _prCategoryID INT default null;
DECLARE _prMasterID INT;
DECLARE _itemCode varchar(100);
DECLARE _Description varchar(255);
DECLARE _rxMasterIDPrimaryVendor int;
DECLARE _InventoryOnHand int;
DECLARE _AverageCost DECIMAL(19,4);
DECLARE _IsInventory int;
DECLARE _IsTaxable int;
DECLARE _prDepartmentID int;
DECLARE _prWarehouseID int;
DECLARE _loadedOn datetime;

DECLARE _prMaster CURSOR FOR 
select itemCode,Description,prDepartmentID, IsInventory, IsTaxable, AverageCost,sum(InventoryOnHand),rxMasterIDPrimaryVendor 
from ETL_SOURCE_inventory group by itemCode,Description;

DECLARE _prWarehouse CURSOR FOR 
select s.itemCode, ifnull(p.prMasterID,0) , s.prWarehouseID, s.InventoryOnHand, p.CreatedOn from ETL_SOURCE_inventory s
left join prMaster p on (p.ItemCode = s.itemCode) where p.IsInventory=1;


DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET _finished = 1;


	-- select _action;
	select count(*) into _report1 from ETL_SOURCE_inventory;
	select count(*) into _report2 from prMaster;
	select count(*) into _report3 from prWarehouseInventory;

	select _action, _report1 as SOURCE_record_count,_report2 as BEGIN_prMaster_count,_report3 as BEGIN_prWarehhouseInventoryCount;


if (_action = 'DELETE_INVENTORY') THEN

    select CreatedOn into _loadedOn from prMaster where CreatedByID = _loadedBy limit 1;
	delete from prMaster where CreatedByID = _loadedBy;
	delete from prWarehouseInventory where LastUpdatedTime = _loadedOn;

elseif (_action = 'CREATE_PRWAREHOUSEINVENTORY') THEN

	set _loadedOn = now();

	OPEN _prMaster;
		readRecords: LOOP
			-- FETCH _recruitIds INTO _recruitId;
            FETCH _prMaster INTO _itemCode,_Description,_prDepartmentID,_IsInventory,_IsTaxable,_AverageCost,_InventoryOnHand,_rxMasterIDPrimaryVendor;
			IF _finished = 1 THEN 
				LEAVE readRecords;
			END IF;
			
			select count(*) into _prMasterFound from prMaster where itemCode =_itemCode;

			if (_prMasterFound > 0) THEN

				select prMasterID into _prMasterID from prMaster where itemCode =_itemCode;
				
                -- hard coded to 5 and 6 to save time for this tool TODO area for wider use
				select count(*) into _prMasterInventoryFound from  prWarehouseInventory 
                where  prMasterID=_prMasterID and  prWarehouseID=5;
			
				if (_prMasterInventoryFound=0) THEN
					insert into prWarehouseInventory
					(prMasterID,prWarehouseID, InventoryOnHand, InventoryAllocated, InventoryOnOrder, HasInitialCost, LastUpdatedTime)
					values
					(_prMasterID,5, 0, 0, 0, 0, _loadedOn);
				END IF;
			
				set _prMasterInventoryFound=0;


				select count(*) into _prMasterInventoryFound from  prWarehouseInventory 
                where  prMasterID=_prMasterID and  prWarehouseID=6;
			
				if (_prMasterInventoryFound=0) THEN
					insert into prWarehouseInventory
					(prMasterID,prWarehouseID, InventoryOnHand, InventoryAllocated, InventoryOnOrder, HasInitialCost, LastUpdatedTime)
					values
					(_prMasterID,6, 0, 0, 0, 0, _loadedOn);
				END IF;
			
				set _prMasterInventoryFound=0;


				
		END IF;
        
        set _prMasterFound = 0;

		END LOOP readRecords;
		
	CLOSE _prMaster;


elseif (_action = 'LOAD_PRMASTER') THEN

	set _loadedOn = now();

	OPEN _prMaster;
		readRecords: LOOP
			-- FETCH _recruitIds INTO _recruitId;
            FETCH _prMaster INTO _itemCode,_Description,_prDepartmentID,_IsInventory,_IsTaxable,_AverageCost,_InventoryOnHand,_rxMasterIDPrimaryVendor;
			IF _finished = 1 THEN 
				LEAVE readRecords;
			END IF;
			
			select count(*) into _prMasterFound from prMaster where itemCode =_itemCode;

			if (_prMasterFound = 0) THEN

		insert into prMaster ( 
		prDepartmentID, prCategoryID, ItemCode, Description, InActive, IsInventory, IsTaxable, 
		PrintOnPOs, PrintOnSOs, PurchasingUnitMultiplier, PurchasingUnitOfMeasure, SalesUnitMultiplier, 
        SalesUnitOfMeasure, rxMasterIDPrimaryVendor, VendorItemNumber, 
		NewPrice, OldPrice, LastCost, 
		InitialCost, AverageCost, oldAverageCost, 
		InventoryOnHand, InventoryAllocated, InventoryOnOrder, InventoryOrderPoint, InventoryOrderQuantity, 
		QuantityBreak0, QuantityBreak1, QuantityBreak2, QuantityBreak3, QuantityBreak4, 
		QuantityBreak5, SingleItemTax, HasInitialCost, CostAsOf, InitialOnHand, 
		Weight, POCost, BoxQty, CreatedOn, CreatedByID, 
		AverageCost_Old, AverageCost_New, POMult, SOPopup, Consignment, 
		POPopup, CUPopup, PrintOnCUs, PrintOnPTs, Labor, 
		AutoAssemble, Serialized, Submitted, LastUpdatedTime )
		value
		(
		_prDepartmentID, _prCategoryID, _ItemCode, _Description, 0, _IsInventory, _IsTaxable, 
		1, 1, 0.0000, NULL, 0.0000, 
		NULL, _rxMasterIDPrimaryVendor, NULL, 
        NULL, NULL, NULL, 
		_AverageCost, _AverageCost, _AverageCost, _InventoryOnHand, 0, 0, 
		0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, null, 
		null, null, 0, 1, _loadedOn, _loadedBy, _AverageCost, 
		_AverageCost, 1, null, 0, null, null, 1, 1, 
		0, 0, 0, 0, _loadedOn
		);

			select prMasterID into _prMasterID from prMaster where itemCode =_itemCode;

		ELSE 

			select prMasterID into _prMasterID from prMaster where itemCode =_itemCode;
			update prMaster set rxMasterIDPrimaryVendor=_rxMasterIDPrimaryVendor where itemCode =_itemCode;

		END IF;
        
        set _prMasterFound = 0;

		END LOOP readRecords;
		
	CLOSE _prMaster;


elseif (_action = 'LOAD_PRWAREHOUSEINVENTORY') THEN

	-- set _loadedOn = now();
    
	OPEN _prWarehouse;
		readRecords2: LOOP
			-- FETCH _recruitIds INTO _recruitId;
            FETCH _prWarehouse INTO _itemCode,_prMasterID,_prWarehouseID,_InventoryOnHand,_loadedOn;
			IF _finished = 1 THEN 
				LEAVE readRecords2;
			END IF;

		-- select _itemCode,_prMasterID,_prWarehouseID,_InventoryOnHand,_loadedOn;
        
		if (_prMasterID >0) THEN

		select count(*) into _prMasterInventoryFound from  prWarehouseInventory where  prMasterID=_prMasterID and  prWarehouseID=_prWarehouseID;
        
			if (_prMasterInventoryFound=0) THEN
				insert into prWarehouseInventory
				(prMasterID,prWarehouseID, InventoryOnHand, InventoryAllocated, InventoryOnOrder, HasInitialCost, LastUpdatedTime)
				values
				(_prMasterID,_prWarehouseID, _InventoryOnHand, 0, 0, 0, _loadedOn);
			END IF;
        
			set _prMasterInventoryFound=0;
            
		END IF;

		END LOOP readRecords2;

	CLOSE _prWarehouse;


END IF;



	select count(*) into _report2 from prMaster;
	select count(*) into _report3 from prWarehouseInventory;


	select * from ETL_error;
	select _report2 as END_prMaster_count,_report3 as END_prWarehhouseInventoryCount;


END$$

DELIMITER ; 