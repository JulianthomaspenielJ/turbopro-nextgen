-- CHANGE LOG (update line 24 each change) -- added index to id on table

-- ==================================================================
/*

-- example searches

call SEARCH_live('SEARCH','category','search_string','total_count',offset,recent,NULL,1);
call SEARCH_live('SEARCH','JOB','',25,0,1,5,1);

*/
-- ==================================================================


-- ==================================================================
-- ==================================================================
-- ==================================================================
DROP procedure IF EXISTS `SEARCH_live`;


DELIMITER $$
CREATE PROCEDURE `SEARCH_live`(IN _action varchar(100), _category varchar(100), _searchString varchar(100),_count INT,_offSet INT,_recent INT,_userId int, _DEBUG tinyint )
SEARCH_live: BEGIN

DECLARE _version varchar(25) DEFAULT '1.0';  -- UPDATE THIS VALUE WITH EACH CHANGE

DECLARE _strLen  int;
DECLARE _subStrLen int;
DECLARE _categoryList varchar(5000);
DECLARE _executionStart time;
DECLARE _executionEnd time;
DECLARE _match varchar(255);

	set _executionStart = now();

	IF (_action='SEARCH' AND _category = 'JOB' AND _userId is not null and (_searchString is null or _searchString='')) THEN
		
		SELECT jobHis.jobNumber, jobHis.jobName, jobHis.jobOpenedDate , jobHis.BidDate,jobHis.joMasterID, js.jobStatus FROM jobHistory jobHis 
		JOIN (SELECT MAX(jobHistoryID) as jobHisID FROM jobHistory GROUP BY jobNumber,tsUserLoginID) jh ON jobHis.jobHistoryID = jh.jobHisID 
		LEFT JOIN joMaster jm on jobHis.joMasterID = jm.joMasterID LEFT JOIN joStatus js on js.joStatusID = jm.jobStatus where tsUserLoginID = 
		_userId AND jobHis.joMasterID>0 AND jobHis.jobNumber<> 'null' 
        -- AND jm.coDivisionID = 2 
        ORDER BY jobHis.jobHistoryID DESC LIMIT 0, 25;

	elseIF (_action='SEARCH' AND _category IS NOT NULL AND LENGTH(_searchString)>2) THEN
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
    

end$$


DELIMITER ;