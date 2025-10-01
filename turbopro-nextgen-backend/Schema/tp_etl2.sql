DROP procedure IF EXISTS `ETL_table2`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_table2` (
    IN _truncate int
)
BEGIN
 
 if (_truncate=1) THEN truncate table `tsUserLogin`; END IF;

 insert ignore  into tsUserLogin(
     UserLoginID,
      LoginName, 
      LoginPassword,
       FullName, 
       Initials, 
       SystemAdministrator, 
       SalesRep, 
       Employee0, 
       Employee1, 
       Employee2, 
       Employee3, 
       Employee4, 
       Inactive, 
       EmailName, 
       EmailAddr, 
       LogOnName, 
       LogOnPswd,
        UseAuthentication, 
        CCAddr1,
         CCName1, 
         CCAddr2, 
         CCName2, 
         CCAddr3, 
         CCName3,
          CCAddr4, 
          CCName4, 
          BCCaddr, 
          SMTPSvr, 
          SMTPEmailActive, 
          SMTPPort
 )
 select 
    UserLogin.UserLoginID, 
    UserLogin.LoginName, 
    UserLogin.LoginPassword, 
    UserLogin.FullName, 
    UserLogin.Initials, 
    UserLogin.SystemAdministrator, 
    UserLogin.SalesRep, 
    UserLogin.Employee0, 
    UserLogin.Employee1, 
    UserLogin.Employee2, 
    UserLogin.Employee3, 
    UserLogin.Employee4, 
    UserLogin.Inactive, 
    UserLogin.EmailName, 
    UserLogin.EmailAddr, 
    UserLogin.LogOnName, 
    UserLogin.LogOnPswd, 
    UserLogin.UseAuthentication, 
    UserLogin.CCAddr1, 
    UserLogin.CCName1, 
    UserLogin.CCAddr2, 
    UserLogin.CCName2, 
    UserLogin.CCAddr3, 
    UserLogin.CCName3, 
    UserLogin.CCAddr4, 
    UserLogin.CCName4, 
    UserLogin.BCCaddr, 
    UserLogin.SMTPSvr, 
    UserLogin.SMTPEmailActive, 
    UserLogin.SMTPPort

        FROM HVAC_System.UserLogin;
END$$

DELIMITER ;

-- =========================================


insert into tsUserSetting
(CompanyID, LoginID, Quote, QuickQuote, Invoices, PurchaseOrders, HeaderText, Terms, quotesFooter, headerQuote, headerQuickQuote, headerInvoices, headerPurchaseOrders, termsQuote, termsQuickQuote, termsInvoices, termsPurchaseOrders, IsBillTo, billToAddress1, billToAddress2, billToCity, billToState, billToZip, billToDescription, companyLogo, IsLogYN, IsMailYN, remitToAddress1, remitToAddress2, remitToCity, remitToState, remitToZip, remitToDescription, vendorProductID, vendorProductDeptID, SofooterText, isCustomerInvoice, isCustomerStatement, isPickTicket, isOrderAck, isQuotes, isPageBreak, TermsConditionsText)
select 
CompanyID, LoginID, Quote, QuickQuote, Invoices, PurchaseOrders, HeaderText, Terms, quotesFooter, headerQuote, headerQuickQuote, headerInvoices, headerPurchaseOrders, termsQuote, termsQuickQuote, termsInvoices, termsPurchaseOrders, IsBillTo, billToAddress1, billToAddress2, billToCity, billToState, billToZip, billToDescription, companyLogo, IsLogYN, IsMailYN, remitToAddress1, remitToAddress2, remitToCity, remitToState, remitToZip, remitToDescription, vendorProductID, vendorProductDeptID, SofooterText, isCustomerInvoice, isCustomerStatement, isPickTicket, isOrderAck, isQuotes, isPageBreak, TermsConditionsText
from HVAC.tsUserSetting;




DROP procedure IF EXISTS `ETL_jorelease_curs`;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `ETL_jorelease_curs`()
BEGIN
	DECLARE v_finished INT default 0;
    DECLARE iBinId INT ;
    DECLARE iBinId1 INT ;
    DECLARE _releasecount INT ;
	DECLARE task_cursor CURSOR FOR select joReleaseID,joMasterID from joRelease ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
    
		OPEN task_cursor;
		getTaskId : LOOP
		FETCH task_cursor INTO iBinId1,iBinId;
			IF(v_finished = 1) THEN
			CLOSE task_cursor;
			LEAVE getTaskId;
			END IF;
            SELECT count(*) into _releasecount FROM joRelease where seq_Number > 0 and joMasterID =iBinId;
			update joRelease set seq_Number = _releasecount + 1 where joReleaseID = iBinId1;
		END LOOP;
END$$

DELIMITER ;


-- ===================================================================


update 
         cuInvoice ci

		 left join joReleaseDetail jd on jd.joReleaseDetailID = ci.joReleaseDetailID
		 left join joRelease jr on jr.joReleaseID = jd.joReleaseID 
        -- left join vePO vp on vp.joReleaseID = jr.joReleaseID
		left join cuSO cu on cu.joReleaseID = jr.joReleaseID 
		set
         ci.cuSOID = cu.cuSOID
         
         where  jr.ReleaseType in (2,5) and ci.joReleaseDetailID is not null 
          and ci.cuSOID is null and cu.cuSOID is not null ;

update 
         cuInvoice ci

		 left join joReleaseDetail jd on jd.joReleaseDetailID = ci.joReleaseDetailID
		 left join joRelease jr on jr.joReleaseID = jd.joReleaseID 
         left join vePO vp on vp.joReleaseID = jr.joReleaseID
		-- left join cuSO cu on cu.joReleaseID = jr.joReleaseID 
		set
         ci.cuSOID = vp.vePOID
         
         where  jr.ReleaseType in (1,4) and ci.joReleaseDetailID is not null 
          and ci.cuSOID is null and vp.vePOID is not null ;


           select jr.ReleaseType,jr.joReleaseID,ci.cuInvoiceID,jr.joReleaseID,jr.joMasterID,vp.vePOID,ci.cuSOID  
         from cuInvoice ci
		 left join joReleaseDetail jd on jd.joReleaseDetailID = ci.joReleaseDetailID
		 left join joRelease jr on jr.joReleaseID = jd.joReleaseID 
          left join vePO vp on vp.joReleaseID = jr.joReleaseID
      --  left join cuSO cu on cu.joReleaseID = jr.joReleaseID 
         where  jr.ReleaseType in (1,4) and ci.joReleaseDetailID is not null 
          and ci.cuSOID is null 
          -- and cu.cuSOID is not null 
          ;