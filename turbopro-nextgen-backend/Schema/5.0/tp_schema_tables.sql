

DROP procedure IF EXISTS `upgradeTPDatabase`;

DELIMITER $$
CREATE PROCEDURE `upgradeTPDatabase` (
IN _version INT,
IN _versionDesc varchar(255),
IN _schema  varchar(255)
)
upgradeTPDatabase: BEGIN
DECLARE colName varchar(25) default null;


  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'prWHtransferDetail' AND column_name = 'fromBinId' and TABLE_SCHEMA = _schema;
    IF (colName is null) THEN
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

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuMaster' AND column_name = 'CreditApp' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE cuMaster ADD COLUMN `CreditApp` TINYINT(4) NOT NULL DEFAULT '0' AFTER `FinCharge`;
    END IF;

  ALTER TABLE prMaster CHANGE COLUMN `Description` `Description` VARCHAR(4294967295) CHARACTER SET 'utf8' NULL DEFAULT NULL ;
  ALTER TABLE prMaster CHANGE COLUMN `ItemCode` `ItemCode` VARCHAR(4294967295) CHARACTER SET 'utf8' NULL DEFAULT NULL ;

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'glLinkage' AND column_name = 'vePODetailID' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  glLinkage  ADD  vePODetailID INT;
       -- select '..column binId added to prWHtransferDetail' ;
    END IF;

    set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'glLinkage' AND column_name = 'veReceiveDetailID' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  glLinkage  ADD  veReceiveDetailID INT;
       -- select '..column binId added to prWHtransferDetail' ;
    END IF;

set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserLogin' AND column_name = 'entity_loginEmailValidationCode' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  tsUserLogin  ADD  entity_loginEmailValidationCode VARCHAR(45);
    END IF;

set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserLogin' AND column_name = 'entity_loginFailedAttempts' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  tsUserLogin  ADD  entity_loginFailedAttempts INT NOT NULL DEFAULT 0;
    END IF;

set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserLogin' AND column_name = 'phoneNumber' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  tsUserLogin  ADD  phoneNumber VARCHAR(255);
    END IF;

set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'veBill' AND column_name = 'lineItemCount' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  veBill  ADD  lineItemCount int(100);
    END IF;


--     ALTER TABLE `veBill` 
-- ADD COLUMN `lineItemCount` INT(100) NULL DEFAULT NULL AFTER `assignCuinvoiceId`;


set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserLogin' AND column_name = 'ack_forOtp' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  tsUserLogin  ADD  ack_forOtp INT NOT NULL DEFAULT 1;
    END IF;


set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserSetting' AND column_name = 'commissionType'  and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  tsUserSetting  ADD  commissionType varchar(100);
END IF;

set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserSetting' AND column_name = 'path'  and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  tsUserSetting  ADD  path text;
END IF;
        
IF colName is null THEN
  
  UPDATE `tsAccessProcedure` SET `ProcedureName` = 'Change_Contract_Amount' WHERE (`AccessProcedureID` = '29012');



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
         nodeVersion varchar(10) NULL,
          PRIMARY KEY (`versionId`))
      ENGINE = InnoDB;

    
    END IF;


    set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tp_version' AND column_name = 'nodeVersion' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
       ALTER TABLE  tp_version  ADD  nodeVersion varchar(10);
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

    -- Table to hold reversals.
    set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'cuSODetailTicket' AND column_name = 'pickTicketId'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN


        CREATE TABLE `cuSODetailTicket` (
           pickTicketId INT(11) NOT NULL auto_increment,
           printNumber INT(11) NOT NULL,
           cuSOID INT(11) NOT NULL,
           cuSODetailId INT(11) NOT NULL,
           ticketStatus INT(11) NOT NULL DEFAULT 0, -- 0=voided, 1=picking, 2=invoiced
           toPick decimal(19,4)  NOT NULL Default 0,
           ordered decimal(19,4)  NOT NULL Default 0,
           backOrdered decimal(19,4)  NOT NULL Default 0,
           alreadyPromised decimal(19,4)  NOT NULL Default 0,
           inventoryOHAtTime decimal(19,4)  NOT NULL Default 0,
           ItemCode varchar(20) NULL,
           Description varchar(70) NULL,
           binName varchar(20) NULL,
           binId int(11) NULL,
           lastUpdated datetime  NULL,
           created datetime NOT NULL Default now(),
            PRIMARY KEY (`pickTicketId`),
            INDEX INDEX_CUSSODETAILID (cuSODetailId),
            INDEX INDEX_CUSSOID (cuSOID)
          )
        ENGINE = InnoDB  AUTO_INCREMENT=1000;

    END IF;
   set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'joQuoteStatus' AND column_name = 'description' and TABLE_SCHEMA = _schema;

    IF colName is null THEN
        CREATE TABLE `joQuoteStatus` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `description` VARCHAR(45) NOT NULL,
          PRIMARY KEY (`id`)
        );
        CREATE TABLE `joQuoteSellingType` (
          `id` INT(11) NOT NULL AUTO_INCREMENT,
          `description` VARCHAR(45) NOT NULL,
          PRIMARY KEY (`id`)
        );
    END IF;

set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'bin' AND column_name = 'inTransfer'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

      ALTER TABLE  bin  ADD  inTransfer decimal(19,4) DEFAULT null;

    END IF;

-- Table to hold reversals.
set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUser_global_notification' AND column_name = 'id'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN

        CREATE TABLE `tsUser_global_notification` (
			id bigint(20) NOT NULL auto_increment,
			userLoginId int(11) NULL,
			contactId int(11) NULL,
			fromEmailId varchar(100) NULL, 
			toEmailId varchar(100) NULL,
			subject LONGTEXT NULL,
			content LONGTEXT NULL,
			SSL_FACTORY varchar(45) NULL,
			JobNumber varchar(45) NULL,
			BCCAddr varchar(100) NULL,
			PONumber varchar(45) NULL,
			filename varchar(100) NULL,
			ccaddress varchar(100) NULL,
			writepdfname varchar(100) NULL,
			statusId int(11) NOT NULL Default 0,
			createdOn datetime,
			changedOn datetime,
			tryes int(11) NOT NULL Default 0,
			pdfType varchar(100) NULL,
      fileAttachment1 varchar(300) NULL,
      fileAttachment2 varchar(300) NULL,
      fileAttachment3 varchar(300) NULL,
      readyOn varchar(300) NULL,
			PRIMARY KEY (`id`))
		  
        ENGINE = InnoDB;

    END IF;

  
  SET colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUser_global_notification' AND column_name = 'fileAttachment1'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN
      ALTER TABLE  tsUser_global_notification  ADD  fileAttachment1 varchar(100) NULL;  
    END IF;

  SET colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUser_global_notification' AND column_name = 'fileAttachment2'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN
      ALTER TABLE  tsUser_global_notification  ADD  fileAttachment3 varchar(100) NULL;
    END IF;

  SET colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUser_global_notification' AND column_name = 'fileAttachment3'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN
      ALTER TABLE  tsUser_global_notification  ADD  fileAttachment3 varchar(100) NULL;
    END IF;

  SET colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUser_global_notification' AND column_name = 'readyOn'  and TABLE_SCHEMA = _schema;
        
    IF colName is null THEN
      ALTER TABLE  tsUser_global_notification  ADD  readyOn varchar(100) NULL;  
    END IF;


  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'ts_Correspondance' AND column_name = 'Id'  and TABLE_SCHEMA = _schema;
	
	IF colName is null THEN
		
		CREATE TABLE `ts_Correspondance`(
			Id int(11) AUTO_INCREMENT,
      tsUser_notification_Id int(11),
			tsUserLoginId int(11) NULL,
			contactId int(11) NULL,
			PONumber varchar(45) NULL,
			fromEmail varchar(100) NULL,
			toEmail varchar(100) NULL,
			pdfType varchar(100) NULL,
			createdOn datetime ,
			message longtext NULL,
      errMessage varchar(100),
      errCode int(11),
			PRIMARY KEY (`Id`)
		)
		ENGINE = InnoDB;
		
	END IF;



    set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'att_configuration' AND column_name = 'configurationId'  and TABLE_SCHEMA = _schema;
	
	IF colName is null THEN
		
		CREATE TABLE `att_configuration`(
			configurationId int(11) AUTO_INCREMENT,
			topic varchar(100) NULL,
			configKey varchar(100) NULL,
			valueText varchar(255) NULL,
      service varchar(45) NULL,
			valueInt int(11) NULL,
			description LONGTEXT,
			PRIMARY KEY (`configurationId`)
		)
		ENGINE = InnoDB;
        
	insert  into att_configuration (configurationId,topic,configKey,valueText,service,valueInt,description)
    values(1,'SENDMAIL','NOTIFICATION_ENABLED',NULL,'gmail',1,'do not send mail if valueInt = 0');
		
	END IF;

update tp_version set tableVersion=_version,tableVersionDesc=_versionDesc where versionId >0;

END$$

DELIMITER ;

call upgradeTPDatabase(17,'test', 'dbbackup_13_09_2023');

select 'SUCCESS TABLE UPGRADE!!';
select * from tp_version;