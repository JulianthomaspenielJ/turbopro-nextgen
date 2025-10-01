-- CHANGE LOG (update line 24 each change) -- added index to id on table

-- ==================================================================
/*
CALL SEARCH_manager('CREATE',NULL,NULL,NULL,NULL,NULL,NULL,1);  -- REQURIED TO CALL ON NEW INSTALLS or REBUILD OF DB - CREATES TABLES
call SEARCH_manager('BUILD',NULL,NULL,NULL,NULL,NULL,NULL,1); -- FORCES A REBUILD OF THE SEARCH TABLES for all types.

call SEARCH_manager('TEST_DATA',null,null,null,1); -- inserts sample data into the search table for testing. probably after a truncate of the table


-- example searches
call SEARCH_manager('SEARCH','inv','12345',null,1);
call SEARCH_manager('SEARCH','category','search_string','total_count',offset,recent,NULL,1);


*/
-- ==================================================================


-- ==================================================================
-- ==================================================================
-- ==================================================================
DROP procedure IF EXISTS `SEARCH_manager`;

DELIMITER $$
CREATE PROCEDURE `SEARCH_manager`(IN _action varchar(100), _category varchar(100), _searchString varchar(100),_count INT,_offSet INT,_recent INT,_userId int, _DEBUG tinyint )
SEARCH_manager: BEGIN

DECLARE _version varchar(25) DEFAULT '1.0';  -- UPDATE THIS VALUE WITH EACH CHANGE

DECLARE _strLen  int;
DECLARE _subStrLen int;
DECLARE _categoryList varchar(5000);
DECLARE _executionStart time;
DECLARE _executionEnd time;
DECLARE _match varchar(255);

	set _executionStart = now();

	IF (_action='SEARCH' AND _category IS NOT NULL AND LENGTH(_searchString)>2) THEN
        SET @condition = SEARCH_getsearchstring(_searchString);
        SET @category = QUOTE(_category);
     
        SET @query = CONCAT('SELECT title AS label, link FROM SEARCH_engine WHERE category = ', @category, @condition, IF(_recent = 1, ' ORDER BY `date` DESC,', ' ORDER BY'),' BINARY LOWER(title) ASC LIMIT 100 OFFSET ', _offSet);
		    PREPARE stm FROM @query;
		    EXECUTE stm;
		    DEALLOCATE PREPARE stm;
	        IF(_count IS NOT NULL) THEN
		        SET @count = CONCAT('SELECT count(*) as total FROM SEARCH_engine WHERE category = ',@category, @condition);
			    PREPARE stmt FROM @count;
			    EXECUTE stmt;
			    DEALLOCATE PREPARE stmt;
            END IF;
        
        IF (_DEBUG) THEN SELECT @query; END IF;
        -- '+inv +1234*'
        
		-- todo consturce and execute sql?
        -- this is not handling a few key scenarios
		-- SELECT * FROM SEARCH_engine WHERE MATCH(category,search) AGAINST (_match IN BOOLEAN MODE) order by id desc;

		-- like is slower
        -- select * from SEARCH_engine where category=_category and search like _match; 
	END IF;

	if (_action='CREATE' or _action='CREATE_BUILD' or _action = 'DROP') THEN
		
        DROP TABLE IF EXISTS SEARCH_engine;
        
        CREATE TABLE IF NOT EXISTS SEARCH_engine (
        searchId INT NOT NULL AUTO_INCREMENT,
		title LONGTEXT, -- computer generated with hyperlink
        category VARCHAR(50) NOT NULL,
        search LONGTEXT NOT NULL,
        link VARCHAR(300) NOT NULL,
        date datetime NOT NULL,
        id INT(11) not null, -- containes the primary key locator
        FULLTEXT(category,search),
        PRIMARY KEY (`searchId`)
        -- ,INDEX IDX_title (search)
        )
		ENGINE = InnoDB AUTO_INCREMENT=5000 DEFAULT CHARSET=utf8mb4;

		ALTER TABLE `SEARCH_engine` ADD INDEX `ID` (`id` ASC);
    
		ALTER TABLE `SEARCH_engine`
			ADD INDEX `IDCAT` (`category` ASC, `id` ASC);

		select _action, 'SEARCH_engine table created need to rebuild data';
        
	END IF;

	if (_action='TEST_DATA') THEN
		
        truncate TABLE SEARCH_engine;
        
        insert into SEARCH_engine (title,category,search,id) values ('Title inventory 1','inv', '12345 Tom Sizmore',10);
        insert into SEARCH_engine (title,category,search,id) values ('Title inventory 2','inv', '6789 Dick Thomas',11);
        insert into SEARCH_engine (title,category,search,id) values ('Title SO 1','so', '12345 Dick Thomas',12);
        insert into SEARCH_engine (title,category,search,id) values ('Title SO 1','rolodex', '9876, Sam Smith',12);
        insert into SEARCH_engine (title,category,search,id) values ('Starbucs','so', 'abcdef, Starbucs',13);

		select * from SEARCH_engine;
        
	END IF;

    
	IF (_action = 'BUILD' or _action='CREATE_BUILD' ) THEN

        truncate TABLE SEARCH_engine;

    
		set _categoryList = 'dex, inv, job, order';
		do_records:
			LOOP
				set _category = null;
				SET _strLen = CHAR_LENGTH(_categoryList);
				set _category=TRIM(SUBSTRING_INDEX(_categoryList, ',', 1));
				
        IF (_category = 'dex') THEN
          CALL SEARCH_Build_Rolodex(NULL,NULL);
        ELSEIF (_category = 'inv') THEN
          CALL SEARCH_Build_Inventory(NULL,NULL);
        ELSEIF (_category = 'job') THEN
          CALL SEARCH_Build_Job(NULL,NULL);
        ELSEIF (_category = 'order') THEN
          CALL SEARCH_Build_Orders(NULL,NULL,NULL);
        END IF;

				SET _subStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_categoryList, ',', 1))+2;
				SET _categoryList = MID(_categoryList, _subStrLen, _strLen);
				IF (_categoryList = '' or _categoryList is null) THEN LEAVE do_records; END IF;
						
			END LOOP do_records; 	
		
		set _executionEnd = now();

		select concat('SEARCH_engine table rebuilt EXECUTION TIME=',TIMEDIFF(_executionEnd,_executionStart));
 
    END IF;

	set _executionEnd = now();

	if (_DEBUG is not null) THEN
		select _action, TIMEDIFF(_executionEnd,_executionStart) as EXECUTION_TIME;
    END IF;

END$$

DELIMITER ;

DROP PROCEDURE IF EXISTS `SEARCH_Build_Job`;
DELIMITER //

CREATE PROCEDURE SEARCH_Build_Job(_joMasterID INT,_action VARCHAR(30))
BEGIN
    SET SESSION group_concat_max_len = 10000000;
        
    IF (_action = "UPDATE") THEN
    DELETE FROM SEARCH_engine WHERE id = _joMasterID AND category = 'JOB';
    END IF;
    
    INSERT IGNORE INTO `SEARCH_engine` (search, title, link, category,`date`, id)
    SELECT CONCAT(IFNULL(REPLACE(j.Description, '"', '\\"'), ''), ',', j.JobNumber, ',', IFNULL(cust.Name, ''), IFNULL(rxm.Name, ''), IFNULL(CONCAT(rxc.FirstName,' ',rxc.LastName), ''),
    IFNULL(cu1.FullName, ''), IFNULL(cu2.FullName, ''), IFNULL(cu3.FullName, ''), IFNULL(cu4.FullName, ''), IFNULL(cu5.FullName, ''),
    IFNULL(cu6.FullName, ''), IFNULL(cu7.FullName, ''), ' ',
    CASE WHEN j.QuoteNumber != "Quick Book" THEN j.QuoteNumber ELSE '' END,
    GROUP_CONCAT(IFNULL(cui.InvoiceNumber,''),',',CASE WHEN (jr.ReleaseType = 1 OR jr.ReleaseType = 3) THEN IFNULL(vePO.PONumber, '') ELSE IFNULL(cuSO.SONumber, '') END)) AS search,
        CONCAT('{"title":"',IFNULL(j.Description, ''),' ',IFNULL(j.JobNumber, ''),'","desc":[{"details":"Job Status:',CASE j.JobStatus WHEN '0' THEN 'Bid'
            WHEN -4 THEN 'Planning'
            WHEN 6 THEN 'Budget'
            WHEN 1 THEN 'Quote'
            WHEN 5 THEN 'Submitted'
            WHEN 3 THEN 'Booked'
            WHEN 4 THEN 'Closed'
            WHEN 2 THEN 'Lost'
            WHEN -1 THEN 'Abandoned'
            WHEN -2 THEN 'Prospected'
            WHEN -3 THEN 'Over Budget'
            WHEN -5 THEN 'No Bid'
            ELSE 'Unknown'
            END,IFNULL(CONCAT(', Bid Date: ', DATE(j.bidDate)),''),IFNULL(CONCAT(', Status Type: ', jbs.Description),''),IFNULL(CONCAT(', Division: ', cd.Description),''),'"}]}') AS title,
        CONCAT('jobflow?token=view&jobNumber=',j.jobNumber,'&joMasterID=',j.joMasterID) AS link,
    "JOB" AS category,
    COALESCE(j.ChangedOn,BidDate,STR_TO_DATE('01-01-2000', '%m-%d-%Y')) AS `date`,
    j.joMasterID AS id
    FROM `joMaster` j LEFT JOIN rxMaster cust ON (cust.rxMasterID = j.rxCustomerID) LEFT JOIN tsUserLogin cu1 ON (cu1.UserLoginID = j.cuAssignmentID0) 
    LEFT JOIN tsUserLogin cu2 ON (cu2.UserLoginID = j.cuAssignmentID1) LEFT JOIN tsUserLogin cu3 ON (cu3.UserLoginID = j.cuAssignmentID2) LEFT JOIN tsUserLogin cu4 ON (cu4.UserLoginID = j.cuAssignmentID3) LEFT JOIN tsUserLogin cu5 ON (cu5.UserLoginID = j.cuAssignmentID4)
    LEFT JOIN tsUserLogin cu6 ON (cu6.UserLoginID = j.cuAssignmentID5) LEFT JOIN tsUserLogin cu7 ON (cu7.UserLoginID = j.cuAssignmentID6) LEFT JOIN rxMaster AS rxm ON(j.rxCategory2 = rxm.rxMasterID) LEFT JOIN rxContact AS rxc ON(j.cuAssignmentID7 = rxc.rxContactID)
    LEFT JOIN joRelease jr ON (j.joMasterID = jr.joMasterID)
    LEFT JOIN vePO ON (jr.joReleaseID = vePO.joReleaseID AND (jr.ReleaseType = 1 OR jr.ReleaseType = 3))
    LEFT JOIN cuSO ON (jr.joReleaseID = cuSO.joReleaseID AND (jr.ReleaseType = 2))
    LEFT JOIN joReleaseDetail jrd ON(jrd.joMasterID = j.joMasterID) 
    LEFT JOIN cuInvoice cui ON (cui.joReleaseDetailID = jrd.joReleaseDetailID)
    LEFT JOIN joBidStatus jbs ON j.joBidStatusID = jbs.joBidStatusID
    LEFT JOIN coDivision cd ON cd.coDivisionID = j.coDivisionID
    WHERE _joMasterID IS NULL OR (_joMasterID IS NOT NULL AND j.joMasterID = _joMasterID)
    GROUP BY j.joMasterID;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS `SEARCH_Build_Rolodex`;
DELIMITER //

CREATE PROCEDURE SEARCH_Build_Rolodex(_rxMasterID INT,_action VARCHAR(30))
BEGIN
    SET SESSION group_concat_max_len = 10000000;
            
    IF (_action = "UPDATE") THEN
    DELETE FROM SEARCH_engine WHERE id = _rxMasterID AND category = 'DEX';
    END IF;
    
    INSERT IGNORE INTO `SEARCH_engine` (search, title, link, category,`date`, id)
    SELECT CONCAT(IFNULL(NAME, ''), ', ', IFNULL(SearchName, ''), ',', IFNULL(REPLACE(REPLACE(REPLACE(REPLACE(phone1, '(', ''), ')', ''), '-', ''), ' ', ''),''),',',COALESCE(GROUP_CONCAT(CONCAT(rxc.FirstName, ' ', rxc.LastName) SEPARATOR ', '), '')) AS "search",
           CONCAT('{"title":"',IFNULL(NAME, ''),' ',IFNULL(phone1, ''),'","desc":',CASE WHEN rxc.rxContactID IS NULL THEN '[]' ELSE CONCAT('[', (SELECT GROUP_CONCAT(CONCAT('{"details":"',CASE WHEN (rxc.FirstName IS NULL OR rxc.FirstName = '') AND (rxc.LastName IS NULL OR rxc.LastName = '') THEN '' ELSE 'Contact: ' END,IFNULL(NULLIF(REPLACE(rxc.FirstName, '"', '\\"'), ''), ''), ' ', IFNULL(NULLIF(rxc.LastName, ''), ''),IFNULL(CONCAT(', Role: ', NULLIF(JobPosition, '')), ''),
            IFNULL(CONCAT(', DirectLine: ', NULLIF(DirectLine, '')), ''),
            IFNULL(CONCAT(', Extension: ', NULLIF(extension, '')), ''),
            IFNULL(CONCAT(', Email: ', NULLIF(EMail, '')), ''),'"}')ORDER BY rxc.FirstName SEPARATOR ', ') FROM rxContact rxc WHERE rxc.rxMasterID = rm.rxMasterID AND rxc.InActive = 0), ']')
            END,'}') AS title,
           CONCAT('rolodexdetails?rolodexNumber=',rm.rxMasterID) AS link,
           "DEX" AS category,
           COALESCE(MAX(rxc.ChangedOn),rm.ChangedOn,rm.CreatedOn,STR_TO_DATE('01-01-2000', '%m-%d-%Y')) AS `date`,
           rm.rxMasterID AS id
    FROM `rxMaster` rm LEFT JOIN rxContact rxc ON (rm.rxMasterID = rxc.rxMasterID AND (rxc.InActive=0))
    WHERE _rxMasterID IS NULL OR (_rxMasterID IS NOT NULL AND rm.rxMasterID = _rxMasterID)
    GROUP BY rm.rxMasterID;
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS `SEARCH_Build_Inventory`;
DELIMITER //

CREATE PROCEDURE SEARCH_Build_Inventory(_prMasterID INT,_action VARCHAR(30))
BEGIN

    IF (_action = "UPDATE") THEN
    DELETE FROM SEARCH_engine WHERE id = _prMasterID AND category = 'INV';
    END IF;

    INSERT IGNORE INTO `SEARCH_engine` (search, title, link, category, `date`, id)
    SELECT CONCAT(pr.ItemCode,',',IFNULL(pr.Description, ''),',',IFNULL(rm.Name,'')) AS "search",
        CONCAT('{"title":"',IFNULL(pr.Description, ''),'","desc":[{"details":"ItemCode:',REPLACE(pr.ItemCode, '\t', ' '),IFNULL(
        CONCAT(', Warehouse Cost: $',CASE
            WHEN vpr.catMarkupAmount < 0 THEN
                ROUND((vpr.sysMarkupAmount * (pr.AverageCost * 100) / 100), 2)
            ELSE
                ROUND((vpr.catMarkupAmount * (pr.AverageCost * 100) / 100), 2) 
            END),""),IFNULL(CONCAT(', On Hand: ', ROUND(vpr.prInventoryOnHand)),''),IFNULL(CONCAT(', Available: ', ROUND(vpr.prInventoryAvailable)),''),IFNULL(CONCAT(', Vendor Name: ', rm.Name),''),'"}]}') AS title,
        CONCAT('inventoryDetails?token=view&inventoryId=',pr.prMasterID,'&itemCode=',pr.ItemCode) AS link,
       "INV" AS category,
       COALESCE(pr.CreatedOn,pr.LastUpdatedTime,STR_TO_DATE('01-01-2000', '%m-%d-%Y')) AS `date`,
       pr.prMasterID AS id
    FROM `prMaster` pr LEFT JOIN rxMaster rm ON (pr.rxMasterIDPrimaryVendor = rm.rxMasterID) LEFT JOIN v_PR_product vpr ON (vpr.prMasterID = pr.prMasterID)
    WHERE _prMasterID IS NULL OR (_prMasterID IS NOT NULL AND pr.prMasterID = _prMasterID);
END //

DELIMITER ;

DROP PROCEDURE IF EXISTS `SEARCH_Build_Orders`;
DELIMITER //

CREATE PROCEDURE SEARCH_Build_Orders(_cuSOID INT,_vePOID INT,_action VARCHAR(30))
BEGIN
    SET SESSION group_concat_max_len = 10000000;

    IF (_action = "UPDATE") THEN
    DELETE FROM SEARCH_engine WHERE id = COALESCE(_cuSOID, _vePOID) AND category = 'ORDER';
    END IF;
IF (_cuSOID is null and _vePOID is null) then
    INSERT IGNORE INTO `SEARCH_engine` (search, title, link, category, `date`, id)
       SELECT CONCAT(rm.NAME,',',so.SONumber,',',IFNULL(so.Tag, ''),',',IFNULL(cu1.FullName,''),',',DATE_FORMAT(so.CreatedOn, '%m/%d/%Y')) AS search,
       CONCAT('{"title":"SO: ',so.SONumber,'","desc":[{"details":"Name:',rm.Name,', CreatedOn: ',DATE_FORMAT(so.CreatedOn, '%m/%d/%Y'),IFNULL(CONCAT(', Tag: ', so.Tag),''),IFNULL(CONCAT(', Sales Rep: ', cu1.FullName),''),'"}]}') AS title,
       CONCAT('salesorder?oper=create&joReleaseID=',so.joReleaseID,'&cuSO=',so.cuSOID,'&vendorID=',so.rxCustomerID,'&sonumber=',SONumber) AS link,
       "ORDER" AS category,
       IFNULL(so.CreatedOn, STR_TO_DATE('01-01-2000', '%m-%d-%Y'))  AS `date`,
       so.cuSOID AS id
    FROM `cuSO` so LEFT JOIN rxMaster rm ON so.rxCustomerID = rm.rxMasterID LEFT JOIN tsUserLogin cu1 ON (cu1.UserLoginID = so.cuAssignmentID0) WHERE so.joReleaseID IS NOT NULL AND so.rxCustomerID IS NOT NULL

    UNION

    SELECT CONCAT(IFNULL(rm.NAME, ''),',',vp.PONumber,',',IFNULL(ts.FullName,'')) AS search,
       CONCAT('{"title":"PO: ',vp.PONumber,'","desc":[{"details":"Name: ',IFNULL(rm.NAME, ''),IFNULL(CONCAT(', Sales Rep: ', ts.FullName),''),'"}]}') AS title,     
       CONCAT('editpurchaseorder?token=view&aVePOId=',vp.vePOID) AS link,
       "ORDER" AS category,
       COALESCE(vp.CreatedOn,vp.OrderDate,vp.ChangedOn,STR_TO_DATE('01-01-2000', '%m-%d-%Y')) AS `date`,
       vp.vePOID AS id
    FROM `vePO` vp LEFT JOIN rxMaster rm ON vp.rxVendorID = rm.rxMasterID LEFT JOIN joMaster jom ON (jom.JobNumber = vp.PONumber) LEFT JOIN tsUserLogin ts ON (ts.UserLoginID = jom.cuAssignmentID0) WHERE vp.joReleaseID IS NOT NULL;
    end if;

    if(_cuSOID is not null) then
        INSERT IGNORE INTO `SEARCH_engine` (search, title, link, category, `date`, id)
       SELECT CONCAT(rm.NAME,',',so.SONumber,',',IFNULL(so.Tag, ''),',',IFNULL(cu1.FullName,''),',',DATE_FORMAT(so.CreatedOn, '%m/%d/%Y')) AS search,
       CONCAT('{"title":"SO: ',so.SONumber,'","desc":[{"details":"Name:',rm.Name,', CreatedOn: ',DATE_FORMAT(so.CreatedOn, '%m/%d/%Y'),IFNULL(CONCAT(', Tag: ', so.Tag),''),IFNULL(CONCAT(', Sales Rep: ', cu1.FullName),''),'"}]}') AS title,
       CONCAT('salesorder?oper=create&joReleaseID=',so.joReleaseID,'&cuSO=',so.cuSOID,'&vendorID=',so.rxCustomerID,'&sonumber=',SONumber) AS link,
       "ORDER" AS category,
       IFNULL(so.CreatedOn, STR_TO_DATE('01-01-2000', '%m-%d-%Y'))  AS `date`,
       so.cuSOID AS id
    FROM `cuSO` so LEFT JOIN rxMaster rm ON so.rxCustomerID = rm.rxMasterID LEFT JOIN tsUserLogin cu1 ON (cu1.UserLoginID = so.cuAssignmentID0) WHERE so.joReleaseID IS NOT NULL AND so.rxCustomerID IS NOT NULL AND _cuSOID IS NULL OR (_cuSOID IS NOT NULL AND so.cuSOID = _cuSOID);
    end if;
    if(_vePOID is not null) then
        INSERT IGNORE INTO `SEARCH_engine` (search, title, link, category, `date`, id)
        SELECT CONCAT(IFNULL(rm.NAME, ''),',',vp.PONumber,',',IFNULL(ts.FullName,'')) AS search,
       CONCAT('{"title":"PO: ',vp.PONumber,'","desc":[{"details":"Name: ',IFNULL(rm.NAME, ''),IFNULL(CONCAT(', Sales Rep: ', ts.FullName),''),'"}]}') AS title,     
       CONCAT('editpurchaseorder?token=view&aVePOId=',vp.vePOID) AS link,
       "ORDER" AS category,
       COALESCE(vp.CreatedOn,vp.OrderDate,vp.ChangedOn,STR_TO_DATE('01-01-2000', '%m-%d-%Y')) AS `date`,
       vp.vePOID AS id
    FROM `vePO` vp LEFT JOIN rxMaster rm ON vp.rxVendorID = rm.rxMasterID LEFT JOIN joMaster jom ON (jom.JobNumber = vp.PONumber) LEFT JOIN tsUserLogin ts ON (ts.UserLoginID = jom.cuAssignmentID0) WHERE vp.joReleaseID IS NOT NULL AND _vePOID IS NULL OR (_vePOID IS NOT NULL AND vp.vePOID = _vePOID);
    end if;
END //

DELIMITER ;

DROP FUNCTION IF EXISTS `SEARCH_getsearchstring`;
DELIMITER //

CREATE FUNCTION SEARCH_getsearchstring(_searchstring VARCHAR(300))
RETURNS VARCHAR(300) DETERMINISTIC
BEGIN
  SET @query = '';

  WHILE CHAR_LENGTH(_searchstring) > 0 DO
    SET @word = TRIM(SUBSTRING_INDEX(_searchstring, ' ', 1));
    SET _searchstring = TRIM(SUBSTRING(_searchstring, LENGTH(@word) + 1));
    SET @query = CONCAT(@query, ' AND search LIKE CONCAT(\'%\', "', @word, '", \'%\')');
  END WHILE;
   RETURN @query;
END //

DELIMITER ;