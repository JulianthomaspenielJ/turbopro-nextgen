

DROP TABLE IF EXISTS joManufacturers;

CREATE TABLE `joManufacturers` (
	joManufacturersId INT  NOT NULL AUTO_INCREMENT,
	rxMasterId INT(11) NOT NULL,
	createDate datetime DEFAULT NULL,
	updateDate datetime DEFAULT NULL,
	updateById INT,    
  PRIMARY KEY (`joManufacturersId`),
  UNIQUE INDEX rxmaster_IDX (`rxMasterId`)
  )
ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS joMasterManufacturer;

CREATE TABLE `joMasterManufacturer` (
	joMasterManufacturerId INT  NOT NULL AUTO_INCREMENT,
   	rxMasterId INT(11) NOT NULL,
   	joMasterId INT(11) NOT NULL,
    isListed tinyint NOT NULL DEFAULT 0, -- 0=no 1=yes
    isBod tinyint NOT NULL DEFAULT 0, -- 0=no 1=yes
	createDate datetime DEFAULT NULL,
	updateDate datetime DEFAULT NULL,
	updateById INT,   	PRIMARY KEY (`joMasterManufacturerId`),
	UNIQUE INDEX master_IDX (joMasterId,rxMasterId )
  )
ENGINE=InnoDB AUTO_INCREMENT=1000 DEFAULT CHARSET=utf8mb4;   


-- call PROCEDURE_build('PROCEDURE','noFile','dbbackup_BartosProd1_18012023','joManufacturers','MANUFACTURER_manufacturer',0);
-- call PROCEDURE_build('NODE','MANUFACTURER','dbbackup_BartosProd1_18012023','joManufacturers','MANUFACTURER_manufacturer',0);

-- call PROCEDURE_build('PROCEDURE','noFile','dbbackup_BartosProd1_18012023','joMasterManufacturer','MANUFACTURER_master',0);
-- call PROCEDURE_build('NODE','MANUFACTURER','dbbackup_BartosProd1_18012023','joMasterManufacturer','MANUFACTURER_master',0);


-- ==================================================================

DROP PROCEDURE IF EXISTS MANUFACTURER_master;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `MANUFACTURER_master`(
IN _action VARCHAR(50),
IN _joMasterManufacturerId int,
IN _rxMasterId int,
IN _joMasterId int,
IN _isListed tinyint,
IN _isBod tinyint,
IN _updateById int,
IN _DEBUG TINYINT
)
MANUFACTURER_master: BEGIN


-- ==================================
/*
call MANUFACTURER_master(_action,_joMasterManufacturerId,_rxMasterId,_joMasterId,_isListed,_isBod,_updateById,_DEBUG);
call MANUFACTURER_master('GET',null,null,null,null,null,null,null);
call MANUFACTURER_master('CREATE',null,null,null,null,null,null,null);
call MANUFACTURER_master('UPDATE',null,null,null,null,null,null,null);
call MANUFACTURER_master('DELETE',null,null,null,null,null,null,null);
call MANUFACTURER_master('MAKE_ACTIVE',null,null,null,null,null,null,null);
call MANUFACTURER_master('MAKE_INACTIVE',null,null,null,null,null,null,null);
*/
-- ==================================

DECLARE _dateFormat varchar(100) DEFAULT '%m-%d-%Y';
DECLARE _timeFormat varchar(100) DEFAULT '%H:%m';

-- =========== for loops =======
/*
DECLARE _strLen    INT DEFAULT 0;
DECLARE _subStrLen INT DEFAULT 0;
DECLARE _recordIDs TEXT;
DECLARE _recordID INT;
DECLARE _finished INTEGER DEFAULT 0;
DECLARE _columns CURSOR FOR select MY_COLUMN_NAME from table;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
*/
-- =========== for loops =======

IF (_DEBUG in (1,2,3)) THEN SELECT _action,_joMasterManufacturerId,_rxMasterId,_joMasterId,_isListed,_isBod,_updateById,_updateById,_DEBUG; END IF;


set @l_sqlrxMasterId = (select rxMasterId from joMasterManufacturer where rxMasterId = _rxMasterId and joMasterID=_joMasterId and  updateById = _updateById); 
-- If (_action = 'UPDATE' and @l_sqlrxMasterId is null) THEN set _action='CREATE';
-- elseIf (_action = 'CREATE' and @l_sqlrxMasterId is not null) THEN set _action='UPDATE'; END IF;
 If (_action = 'UPDATE' and @l_sqlrxMasterId is null) THEN set _action='CREATE';
 elseIf (_action = 'UPDATE' and @l_sqlrxMasterId is not null) THEN set _action='UPDATE'; END IF;


IF (_action = 'GET' ) THEN

	if (_joMasterManufacturerId is not null) THEN
		select * from joMasterManufacturer where joMasterManufacturerId = _joMasterManufacturerId;
	elseif (_updateById is not null) THEN
		SELECT 
    rm.Name AS jobManufactureName,
    jmf.rxMasterID,
    jmm.joMasterManufacturerId,
    jmm.isListed AS listed,
    jmm.isBod AS bod,
    jmm.joMasterId
FROM
    joManufacturers jmf
        LEFT JOIN
    rxMaster rm ON jmf.rxMasterId = rm.rxMasterId
        LEFT JOIN
    joMasterManufacturer jmm ON jmf.rxMasterId = jmm.rxMasterId and jmm.joMasterId= _joMasterId
WHERE
    jmf.updateById = jmf.updateById
ORDER BY jobManufactureName , jmf.updateById; 
            -- jmm.joMasterId= _joMasterId  and
	else
		select * from joMasterManufacturer order by updateById;
	END IF;

ELSEIF (_action = 'CREATE' ) THEN

	if (_rxMasterId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CREATE joMasterManufacturer requires rxMasterId';
		LEAVE MANUFACTURER_master;
	END IF;
	if (_joMasterId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CREATE joMasterManufacturer requires joMasterId';
		LEAVE MANUFACTURER_master;
	END IF;

	insert into joMasterManufacturer (
		rxMasterId,joMasterId,isListed,isBod,createDate,updateDate,updateById
		) values (
		_rxMasterId,_joMasterId,_isListed,_isBod,now(),now(),_updateById
		);

	SET _joMasterManufacturerId = LAST_INSERT_ID();

	select _joMasterManufacturerId as joMasterManufacturerId;

ELSEIF (_action = 'UPDATE') THEN

	if (_joMasterManufacturerId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joMasterManufacturer requires joMasterManufacturerId';
		LEAVE MANUFACTURER_master;
	END IF;

	if (_rxMasterId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joMasterManufacturer requires rxMasterId';
		LEAVE MANUFACTURER_master;
	END IF;

	if (_joMasterId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joMasterManufacturer requires joMasterId';
		LEAVE MANUFACTURER_master;
	END IF;

	if (_isListed is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joMasterManufacturer requires isListed';
		LEAVE MANUFACTURER_master;
	END IF;

	if (_isBod is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joMasterManufacturer requires isBod';
		LEAVE MANUFACTURER_master;
	END IF;

	set  @l_sql = 'update joMasterManufacturer set updateDate=now()';

		if (_rxMasterId is not null) THEN
			set @l_sql = CONCAT(@l_sql,', rxMasterId= ',_rxMasterId);
		ELSE
			set @l_sql = CONCAT(@l_sql,', rxMasterId= NULL');
		END IF;

		if (_joMasterId is not null) THEN
			set @l_sql = CONCAT(@l_sql,', joMasterId= ',_joMasterId);
		ELSE
			set @l_sql = CONCAT(@l_sql,', joMasterId= null');
		END IF;

		if (_isListed is not null) THEN
			set @l_sql = CONCAT(@l_sql,', isListed= ',_isListed);
		ELSE
			set @l_sql = CONCAT(@l_sql,', isListed= NULL');
		END IF;

		if (_isBod is not null) THEN
			set @l_sql = CONCAT(@l_sql,', isBod= ',_isBod);
		ELSE
			set @l_sql = CONCAT(@l_sql,', isBod= 0');
		END IF;

		set @l_sql = CONCAT(@l_sql,', updateById= ',_updateById);

		set @l_sql = CONCAT(@l_sql,' where joMasterManufacturerId= ',_joMasterManufacturerId);

	IF (_DEBUG in (1,2,3)) THEN select _action,@l_sql; END IF;

	PREPARE stmt FROM @l_sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	set @l_sql = null;

ELSEIF (_action = 'DELETE') THEN

	if (_joMasterManufacturerId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE joMasterManufacturer requires joMasterManufacturerId';
		LEAVE MANUFACTURER_master;
	END IF;

	DELETE FROM joMasterManufacturer where joMasterManufacturerId = _joMasterManufacturerId;

ELSE

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ACTION NOT SUPPORTED for MANUFACTURER_master';
	LEAVE MANUFACTURER_master;

END IF;

-- Update joMaster for bod and listed 
if(_action = "UPDATE" or _action = "CREATE") then

	select group_concat(isBod) into @l_sqlBod from joMasterManufacturer where joMasterId = _joMasterId and isBod=1;
	select group_concat(isListed) into @l_sqlListed from joMasterManufacturer where joMasterId = _joMasterId and isListed=1;
    
	update joMaster set isBodChecked=IF(@l_sqlBod is null, 0,1), isListedChecked=IF(@l_sqlListed is null, 0,1) where joMasterId = _joMasterId;

end if;

IF (_DEBUG in (1,2,3)) THEN SELECT _action, t.* from joMasterManufacturer t where joMasterManufacturerId = _joMasterManufacturerId; END IF;

-- ============== EXAMPLE LOOP CODE ========
/*
	set _finished=0;
	OPEN _columns;
		readRecords: LOOP
			FETCH _columns INTO _MY_COLUMN_NAME;

			IF _finished = 1 THEN LEAVE readRecords; END IF;

			[ put code here ]

			IF _finished = 1 THEN LEAVE readRecords; END IF;

		END LOOP readRecords;
	    
	CLOSE _columns;
		
        
	select GROUP_CONCAT(valueId) into _recordIDs from myTable;
	do_records:
		LOOP
			set _recordID = null;
			SET _strLen = CHAR_LENGTH(_recordIDs);
			set _recordID=SUBSTRING_INDEX(_recordIDs, ',', 1);

			[ put code here ]
    
			SET _subStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_recordIDs, ',', 1))+2;
			SET _recordIDs = MID(_recordIDs, _subStrLen, _strLen);
			IF (_recordIDs = ' or _recordIDs is null) THEN LEAVE do_records; END IF;
                    
	END LOOP do_records; 	
*/
-- ============== EXAMPLE LOOP CODE ========

END$$

DELIMITER ;


-- ==================================================================

DROP PROCEDURE IF EXISTS MANUFACTURER_manufacturer;

DELIMITER $$

CREATE DEFINER=`root`@`%` PROCEDURE `MANUFACTURER_manufacturer`(
IN _action VARCHAR(50),
IN _joManufacturersId int,
IN _rxMasterId int,
IN _updateById int,
IN _DEBUG TINYINT
)
MANUFACTURER_manufacturer: BEGIN


-- ==================================
/*
call MANUFACTURER_manufacturer(_action,_joManufacturersId,_rxMasterId,_updateById,_DEBUG);
call MANUFACTURER_manufacturer('GET',null,null,null,null);
call MANUFACTURER_manufacturer('CREATE',null,null,null,null);
call MANUFACTURER_manufacturer('UPDATE',null,null,null,null);
call MANUFACTURER_manufacturer('DELETE',null,null,null,null);
call MANUFACTURER_manufacturer('MAKE_ACTIVE',null,null,null,null);
call MANUFACTURER_manufacturer('MAKE_INACTIVE',null,null,null,null);
*/
-- ==================================

DECLARE _dateFormat varchar(100) DEFAULT '%m-%d-%Y';
DECLARE _timeFormat varchar(100) DEFAULT '%H:%m';

-- =========== for loops =======
/*
DECLARE _strLen    INT DEFAULT 0;
DECLARE _subStrLen INT DEFAULT 0;
DECLARE _recordIDs TEXT;
DECLARE _recordID INT;
DECLARE _finished INTEGER DEFAULT 0;
DECLARE _columns CURSOR FOR select MY_COLUMN_NAME from table;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;
*/
-- =========== for loops =======

IF (_DEBUG in (1,2,3)) THEN SELECT _action,_joManufacturersId,_rxMasterId,_updateById,_updateById,_DEBUG; END IF;


If (_action = 'UPDATE' and _joManufacturersId is null) THEN set _action='CREATE';
elseIf (_action = 'CREATE' and _joManufacturersId is not null) THEN set _action='UPDATE'; END IF;


IF (_action = 'GET' ) THEN

	if (_joManufacturersId is not null) THEN
		select * from joManufacturers where joManufacturersId = _joManufacturersId;
	elseif (_updateById is not null) THEN
        select rm.Name as jobManufactureName, jmf.rxMasterID
			from joManufacturers jmf 
			left join rxMaster rm on jmf.rxMasterId = rm.rxMasterId 
			where jmf.updateById = jmf.updateById order by jobManufactureName,jmf.updateById; 
	else
		select * from joManufacturers order by updateById;
	END IF;

ELSEIF (_action = 'CREATE' ) THEN

	if (_rxMasterId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CREATE joManufacturers requires rxMasterId';
		LEAVE MANUFACTURER_manufacturer;
	END IF;		
    
	Set @l_isMasterId = (select rxMasterId from joManufacturers where rxMasterId = _rxMasterId);
    if (@l_isMasterId is null) then
		insert into joManufacturers (
			rxMasterId,createDate,updateDate,updateById
			) values (
			_rxMasterId,now(),now(),_updateById
			);

	SET _joManufacturersId = LAST_INSERT_ID();

		select _joManufacturersId as joManufacturersId;
    else
		select "Manufacture is already Exist" as isRxMasterExist;
    end if;
	

ELSEIF (_action = 'UPDATE') THEN

	if (_joManufacturersId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joManufacturers requires joManufacturersId';
		LEAVE MANUFACTURER_manufacturer;
	END IF;

	if (_rxMasterId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE joManufacturers requires rxMasterId';
		LEAVE MANUFACTURER_manufacturer;
	END IF;

	set  @l_sql = 'update joManufacturers set updateDate=now()';

		if (_rxMasterId is not null) THEN
			set @l_sql = CONCAT(@l_sql,', rxMasterId= ',_rxMasterId);
		ELSE
			set @l_sql = CONCAT(@l_sql,', rxMasterId= NULL');
		END IF;

		set @l_sql = CONCAT(@l_sql,', updateById= ',_updateById);

		set @l_sql = CONCAT(@l_sql,' where joManufacturersId= ',_joManufacturersId);

	IF (_DEBUG in (1,2,3)) THEN select _action,@l_sql; END IF;

	PREPARE stmt FROM @l_sql;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	set @l_sql = null;

ELSEIF (_action = 'DELETE') THEN

	if (_rxMasterId is null) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'DELETE joManufacturers requires _rxMasterId';
		LEAVE MANUFACTURER_manufacturer;
	END IF;

	DELETE FROM joManufacturers where rxMasterId = _rxMasterId;

ELSE

	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ACTION NOT SUPPORTED for MANUFACTURER_manufacturer';
	LEAVE MANUFACTURER_manufacturer;

END IF;

IF (_DEBUG in (1,2,3)) THEN SELECT _action, t.* from joManufacturers t where joManufacturersId = _joManufacturersId; END IF;

-- ============== EXAMPLE LOOP CODE ========
/*
	set _finished=0;
	OPEN _columns;
		readRecords: LOOP
			FETCH _columns INTO _MY_COLUMN_NAME;

			IF _finished = 1 THEN LEAVE readRecords; END IF;

			[ put code here ]

			IF _finished = 1 THEN LEAVE readRecords; END IF;

		END LOOP readRecords;
	    
	CLOSE _columns;
		
        
	select GROUP_CONCAT(valueId) into _recordIDs from myTable;
	do_records:
		LOOP
			set _recordID = null;
			SET _strLen = CHAR_LENGTH(_recordIDs);
			set _recordID=SUBSTRING_INDEX(_recordIDs, ',', 1);

			[ put code here ]
    
			SET _subStrLen = CHAR_LENGTH(SUBSTRING_INDEX(_recordIDs, ',', 1))+2;
			SET _recordIDs = MID(_recordIDs, _subStrLen, _strLen);
			IF (_recordIDs = ' or _recordIDs is null) THEN LEAVE do_records; END IF;
                    
	END LOOP do_records; 	
*/
-- ============== EXAMPLE LOOP CODE ========

END$$

DELIMITER ;





-- ROUTES - delete later
/*
// ============== ADD TO APP.js ===============
// var MANUFACTURERRouter = require("./routes/MANUFACTURER");
// app.use("/MANUFACTURER", MANUFACTURERRouter);
// ============================================

const express = require("express");
const router = express.Router();
const pool = require("../config/db.js");
const getHeaderNode = require("../models/header.js").header;

let sql = "";
let isInError = 0;
let isErrorMsg = "";
let isErrorCode = "";

// ===============================================

// @route   GET /MANUFACTURER/list/
// @desc    get list
// @access  Private/Public

router.get("/list", async function (req, res, next) {

	console.log("MANUFACTURER.get("/list") -->", "req queries: ", req.body.params);

	const _token = req.query.token || null;
	const _action = "GET";
	const _joManufacturersId = req.query.joManufacturersId || null;
	const _rxMasterId = req.query.rxMasterId || null;
	const _updateById = req.query.updateById || null;
	const _userId = req.query.userId || null;
	const _DEBUG = req.query.DEBUG || null;

	let result = [];

	isInError = 0;
	isErrorMsg = "";
	isErrorCode = "";

	let sqlFunction = function () { 
	let SQL = "call MANUFACTURER_manufacturer(?,?,?,?,?)";
	console.log("SQL --->", SQL, req.body.params);

	return new Promise((resolve, reject) => {
		pool.query(
			SQL,
			[_action,_joManufacturersId,_rxMasterId,_updateById,_DEBUG],
			(err, result) => {
				if (err) {
				console.log("error:", err);
				isInError = 1;
				isErrorCode = "FILTER_ERROR";
				if (err.sqlState == 45000) {
					isErrorMsg = err.MESSAGE_TEXT;
				} else {
					isErrorMsg = err.sqlState +
					": We had difficulty performaing this action.  Please report his number to your contact.";
				}
					resolve("");
				} else {
					resolve(result[0]);
				}
			}
			);
		});
	};

	if (isInError == 0) {
		if (_userId) {
			result = await sqlFunction();
		}

		getHeaderNode(isErrorCode, isErrorMsg)
			.then((header) => {
				let response = {
				header: header,
				results: result,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} else {
		console.log("get  ERROR ");
		getHeaderNode(isErrorCode, isErrorMsg)
				.then((header) => {
				let response = {
				isErrorMsg: isErrorMsg,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} // end isError
	});


// ===============================================

// @route   POST /MANUFACTURER/list/
// @desc    post update
// @access  Private/Public

router.post("/update", async function (req, res, next) {

	console.log("MANUFACTURER.post("/update") -->", "req queries: ", req.body.params);

	const _token = req.query.token || null;
	const _action = "UPDATE";
	const _userId = req.query.userId || null;
	const _DEBUG = req.query.DEBUG || null;

	let result = [];

	isInError = 0;
	isErrorMsg = "";
	isErrorCode = "";

	let sqlFunction = function () { 
	let SQL = "call MANUFACTURER_manufacturer(?)";
	console.log("SQL --->", SQL, req.body.params);

	return new Promise((resolve, reject) => {
		pool.query(
			SQL,
			[_action],
			(err, result) => {
				if (err) {
				console.log("error:", err);
				isInError = 1;
				isErrorCode = "FILTER_ERROR";
				if (err.sqlState == 45000) {
					isErrorMsg = err.MESSAGE_TEXT;
				} else {
					isErrorMsg = err.sqlState +
					": We had difficulty performaing this action.  Please report his number to your contact.";
				}
					resolve("");
				} else {
					resolve(result[0]);
				}
			}
			);
		});
	};

	if (isInError == 0) {
		if (_userId) {
			result = await sqlFunction();
		}

		getHeaderNode(isErrorCode, isErrorMsg)
			.then((header) => {
				let response = {
				header: header,
				results: result,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} else {
		console.log("get  ERROR ");
		getHeaderNode(isErrorCode, isErrorMsg)
				.then((header) => {
				let response = {
				isErrorMsg: isErrorMsg,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} // end isError
	});

module.exports = router;


// ============== ADD TO APP.js ===============
// var MANUFACTURERRouter = require("./routes/MANUFACTURER");
// app.use("/MANUFACTURER", MANUFACTURERRouter);
// ============================================

const express = require("express");
const router = express.Router();
const pool = require("../config/db.js");
const getHeaderNode = require("../models/header.js").header;

let sql = "";
let isInError = 0;
let isErrorMsg = "";
let isErrorCode = "";

// ===============================================

// @route   GET /MANUFACTURER/list/
// @desc    get list
// @access  Private/Public

router.get("/list", async function (req, res, next) {

	console.log("MANUFACTURER.get("/list") -->", "req queries: ", req.body.params);

	const _token = req.query.token || null;
	const _action = "GET";
	const _joMasterManufacturerId = req.query.joMasterManufacturerId || null;
	const _rxMasterId = req.query.rxMasterId || null;
	const _joMasterId = req.query.joMasterId || null;
	const _isListed = req.query.isListed || null;
	const _isBod = req.query.isBod || null;
	const _updateById = req.query.updateById || null;
	const _userId = req.query.userId || null;
	const _DEBUG = req.query.DEBUG || null;

	let result = [];

	isInError = 0;
	isErrorMsg = "";
	isErrorCode = "";

	let sqlFunction = function () { 
	let SQL = "call MANUFACTURER_master(?,?,?,?,?,?,?,?)";
	console.log("SQL --->", SQL, req.body.params);

	return new Promise((resolve, reject) => {
		pool.query(
			SQL,
			[_action,_joMasterManufacturerId,_rxMasterId,_joMasterId,_isListed,_isBod,_updateById,_DEBUG],
			(err, result) => {
				if (err) {
				console.log("error:", err);
				isInError = 1;
				isErrorCode = "FILTER_ERROR";
				if (err.sqlState == 45000) {
					isErrorMsg = err.MESSAGE_TEXT;
				} else {
					isErrorMsg = err.sqlState +
					": We had difficulty performaing this action.  Please report his number to your contact.";
				}
					resolve("");
				} else {
					resolve(result[0]);
				}
			}
			);
		});
	};

	if (isInError == 0) {
		if (_userId) {
			result = await sqlFunction();
		}

		getHeaderNode(isErrorCode, isErrorMsg)
			.then((header) => {
				let response = {
				header: header,
				results: result,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} else {
		console.log("get  ERROR ");
		getHeaderNode(isErrorCode, isErrorMsg)
				.then((header) => {
				let response = {
				isErrorMsg: isErrorMsg,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} // end isError
	});


// ===============================================

// @route   POST /MANUFACTURER/list/
// @desc    post update
// @access  Private/Public

router.post("/update", async function (req, res, next) {

	console.log("MANUFACTURER.post("/update") -->", "req queries: ", req.body.params);

	const _token = req.query.token || null;
	const _action = "UPDATE";
	const _userId = req.query.userId || null;
	const _DEBUG = req.query.DEBUG || null;

	let result = [];

	isInError = 0;
	isErrorMsg = "";
	isErrorCode = "";

	let sqlFunction = function () { 
	let SQL = "call MANUFACTURER_master(?)";
	console.log("SQL --->", SQL, req.body.params);

	return new Promise((resolve, reject) => {
		pool.query(
			SQL,
			[_action],
			(err, result) => {
				if (err) {
				console.log("error:", err);
				isInError = 1;
				isErrorCode = "FILTER_ERROR";
				if (err.sqlState == 45000) {
					isErrorMsg = err.MESSAGE_TEXT;
				} else {
					isErrorMsg = err.sqlState +
					": We had difficulty performaing this action.  Please report his number to your contact.";
				}
					resolve("");
				} else {
					resolve(result[0]);
				}
			}
			);
		});
	};

	if (isInError == 0) {
		if (_userId) {
			result = await sqlFunction();
		}

		getHeaderNode(isErrorCode, isErrorMsg)
			.then((header) => {
				let response = {
				header: header,
				results: result,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} else {
		console.log("get  ERROR ");
		getHeaderNode(isErrorCode, isErrorMsg)
				.then((header) => {
				let response = {
				isErrorMsg: isErrorMsg,
				};
				res.send(response);
			})
			.catch((err) => {
				res.send(err);
			});
	} // end isError
	});

module.exports = router;

*/
