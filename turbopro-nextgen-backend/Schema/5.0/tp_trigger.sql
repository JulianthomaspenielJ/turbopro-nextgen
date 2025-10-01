DELIMITER $$

DROP TRIGGER /*!50032 IF EXISTS */ `tr_cuinvoice_insert`$$

CREATE TRIGGER `tr_cuinvoice_insert` AFTER INSERT ON `cuInvoice` 
    FOR EACH ROW BEGIN
    IF (NEW.InvoiceAmount<>0) THEN 
    INSERT INTO arhistory(cuInvoiceID,InvoiceAmount,DiscountAmt,Appliedamount,createdOn) VALUES(NEW.cuInvoiceID,NEW.InvoiceAmount,NEW.DiscountAmt,NEW.AppliedAmount,NEW.InvoiceDate);
    END IF;    
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_INSERT_cuSO`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_INSERT_cuSO` AFTER INSERT ON `cuSO` 
    FOR EACH ROW
    BEGIN
	    CALL SEARCH_Build_Orders(NEW.cuSOID,NULL,NULL);
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_UPDATE_cuSO`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_UPDATE_cuSO` AFTER UPDATE ON `cuSO` 
    FOR EACH ROW
    BEGIN
	    CALL SEARCH_Build_Orders(NEW.cuSOID,NULL,"UPDATE");
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_INSERT_prMaster`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_INSERT_prMaster` AFTER INSERT ON `prMaster` 
    FOR EACH ROW
    BEGIN
	    CALL SEARCH_Build_Inventory(NEW.prMasterID,NULL);
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_UPDATE_prMaster`$$

-- CREATE
--     /*!50017 DEFINER = 'root'@'%' */
--     TRIGGER `AFTER_UPDATE_prMaster` AFTER UPDATE ON `prMaster` 
--     FOR EACH ROW
--     BEGIN
-- 	    CALL SEARCH_Build_Inventory(NEW.prMasterID,"UPDATE");
--     END;
-- $$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_INSERT_joMaster`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_INSERT_joMaster` AFTER INSERT ON `joMaster` 
    FOR EACH ROW
    BEGIN
        CALL sp_job_ins_searchindex(NEW.joMasterID, NEW.JobNumber, NEW.Description, NEW.cuAssignmentID0, NEW.BidDate);
        CALL SEARCH_Build_Job(NEW.joMasterID,NULL);
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_UPDATE_joMaster`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_UPDATE_joMaster` AFTER UPDATE ON `joMaster`
    FOR EACH ROW
    BEGIN
        CALL sp_job_upd_searchindex(NEW.joMasterID, NEW.JobNumber, NEW.Description, NEW.cuAssignmentID0, NEW.BidDate);
        CALL SEARCH_Build_Job(NEW.joMasterID,"UPDATE");
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_INSERT_rxMaster`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_INSERT_rxMaster` AFTER INSERT ON `rxMaster` 
    FOR EACH ROW
    BEGIN
        CALL sp_rolodex_ins_searchindex(NEW.rxMasterID, NEW.Name, NEW.SearchName, NEW.Phone1);
        CALL SEARCH_Build_Rolodex(NEW.rxMasterID,NULL);
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_UPDATE_rxMaster`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_UPDATE_rxMaster` AFTER UPDATE ON `rxMaster` 
    FOR EACH ROW
    BEGIN
        CALL sp_rolodex_upd_searchindex(NEW.rxMasterID, NEW.Name, NEW.SearchName, NEW.Phone1);
        CALL SEARCH_Build_Rolodex(NEW.rxMasterID,"UPDATE");
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_INSERT_vePO`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_INSERT_vePO` AFTER INSERT ON `vePO`
    FOR EACH ROW
    BEGIN
	    CALL SEARCH_Build_Orders(NULL,NEW.vePOID,NULL);
    END;
$$

DROP TRIGGER /*!50032 IF EXISTS */ `AFTER_UPDATE_vePO`$$

CREATE
    /*!50017 DEFINER = 'root'@'%' */
    TRIGGER `AFTER_UPDATE_vePO` AFTER UPDATE ON `vePO` 
    FOR EACH ROW
    BEGIN
	    CALL SEARCH_Build_Orders(NULL,NEW.vePOID,"UPDATE");
    END;
$$

DELIMITER ;