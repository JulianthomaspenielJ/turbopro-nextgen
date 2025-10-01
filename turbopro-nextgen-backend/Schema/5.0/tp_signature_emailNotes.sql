DROP procedure IF EXISTS `upgradeTPDatabaseFor_signature_emailNotes`;

DELIMITER $$
CREATE PROCEDURE `upgradeTPDatabaseFor_signature_emailNotes` (IN _schema  varchar(255))
upgradeTPDatabaseFor_signature_emailNotes: BEGIN
DECLARE colName varchar(25) default null;

-- call upgradeTPDatabaseFor_signature_emailNotes('dbbackup_BartosProd1_27032023');

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserLogin' AND column_name = 'signature' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
    -- ALTER TABLE `veBill` ADD COLUMN `lineItemCount` INT NULL DEFAULT NULL AFTER `assignCuinvoiceId`;
     ALTER TABLE  tsUserLogin  ADD  signature text AFTER `ack_forOtp`;

    END IF;

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserLogin' AND column_name = 'emailNotes' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
    -- ALTER TABLE `veBill` ADD COLUMN `lineItemCount` INT NULL DEFAULT NULL AFTER `assignCuinvoiceId`;
     ALTER TABLE  tsUserLogin  ADD  emailNotes text AFTER `signature`;
 
    END IF;

  set colName = null;
    SELECT column_name INTO colName FROM information_schema.columns 
    WHERE table_name = 'tsUserLogin' AND column_name = 'emailNoteOption' and TABLE_SCHEMA = _schema;
    IF colName is null THEN
    -- ALTER TABLE `veBill` ADD COLUMN `lineItemCount` INT NULL DEFAULT NULL AFTER `assignCuinvoiceId`;
     ALTER TABLE  tsUserLogin  ADD  emailNoteOption text AFTER `emailNotes`;

    select 'SUCCESS TABLE UPGRADE FOR SIGNATURE, EMAIL NOTES AND EMAILNOTEOPTION !!';
    select 'Please  DROP procedure IF EXISTS upgradeTPDatabaseFor_signature_emailNotes; ';

    END IF;

END$$

DELIMITER ;
