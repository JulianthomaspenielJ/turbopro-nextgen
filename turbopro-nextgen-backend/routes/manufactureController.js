var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;

var sql = "";
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";




//================================================
// API call to get verdor name based on search
router.post("/getSearchVendor", function (req, res, next) {
  let searchDate = (req.body.vendorSerachName ? req.body.vendorSerachName : null);    

  console.log("<==================================================>");
  console.log("POST /jobManufacture/addManufacture ", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
     let sql1 =  `select  CONCAT(Name, ' ',FirstName) as vendorName from rxMaster where Name like "${searchDate}%" order by vendorName`;
      pool.query(
          sql1,
        [],
        function (err, results) {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "FILTER_ERROR";
            if (err.sqlState == 41001) {
              isErrorMsg = "Please report this error";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              //isErrorMsg = err.sqlMessage;
            }
            resolve("");
          } else {
            resolve(results);
          }
        }
      ); // end query
    }); // end promise
  };

  var main = async function () {
    var first = await firstFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          results: first,
        };
        res.send(response);
      }
    });
  }; // end MAIN

  if (isInError == 0) {
    main();
  } else {
    // end isError

    console.log("post /jobManufacture/getSearchVendor ERROR ", _action);

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  } // end isError
}); // end POST
// ===============================================


// ===============================================
// API call to add/get/delete manufacturers details as per action
router.post("/addManufacture", function (req, res, next) {
  var _action = req.body.action ? req.body.action : req.query.action;
  var _userLoginID = req.body.userLoginID ? req.body.userLoginID : req.query.userLoginID;
  var _manufactureName = req.body.jobManufactureName ? req.body.jobManufactureName
    : null;

  console.log("<==================================================>");
  console.log("POST /jobManufacture/addManufacture ", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      sql = "";
      // if (_action  == "SAVE"){
      //   // sql=`insert into jobManufacture(userLoginID, jobManufactureName) values(${_userLoginID}, '${_manufactureName}');`;
      //   sql=`insert into jobQuoteManufacturer( jobManufactureName) values('${_manufactureName}');`;
      // }else if(_action == "DELETE"){
      //   sql=`delete from jobQuoteManufacturer where jobManufactureName = '${_manufactureName}';`
      // }
      // else if(_action == "GetManufactureList"){
      //   // sql=`select * from jobManufacture where userLoginID= ${_userLoginID};`;
      //   sql=`select * from jobQuoteManufacturer`;
      // }
      sql  = `select rxMasterID from rxMaster where Name = "${_manufactureName}"`
      pool.query(
        sql,
        [],
        function (err, results) {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "FILTER_ERROR";
            if (err.sqlState == 41001) {
              isErrorMsg = "Please report this error";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              //isErrorMsg = err.sqlMessage;
            }
            resolve("");
          } else {
            let rxMasterID = results[0] ? results[0].rxMasterID: null;

            let sql1 = `call MANUFACTURER_manufacturer(?,?,?,?,?)`;

            pool.query(
              sql1,
              [_action,null,rxMasterID,_userLoginID,null],
              function (err, results) {
                if (err) {
                  console.log("error:", err);
                  isInError = 1;
                  isErrorCode = "FILTER_ERROR";
                  if (err.sqlState == 41001) {
                    isErrorMsg = "Please report this error";
                  } else {
                    isErrorMsg =
                      err.sqlState +
                      ": We had difficulty performaing this action.  Pleae report his number to your contact.";
                    //isErrorMsg = err.sqlMessage;
                  }
                  resolve("");
                } else {
                  resolve(results[0]);
                }
              });



            // resolve(results);
          }
        }
      ); // end query
    }); // end promise
  };

  var main = async function () {
    var first = await firstFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          rows: first,
        };
        res.send(response);
      }
    });
  }; // end MAIN

  if (isInError == 0) {
    main();
  } else {
    // end isError

    console.log("post /jobManufacture/addManufacture ERROR ", _action);

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  } // end isError
}); // end POST
// ===============================================


router.post("/updateManufactureChecks", function (req, res, next) {
  var _action = req.body.action ? req.body.action : req.query.action;
  var _userLoginID = req.body.userLoginID ? req.body.userLoginID : req.query.userLoginID;
  let _joMasterID= req.body.joMasterID ? req.body.joMasterID: null;
  let _bod= req.body.bod ? req.body.bod: 0;
  let _listed= req.body.listed ? req.body.listed: 0;

  let _rowData = req.body.rowData ? req.body.rowData : null;

  let _rxMasterID= req.body.rxMasterID ? req.body.rxMasterID: null;
  let _joMasterManufacturerId= req.body.joMasterManufacturerId? req.body.joMasterManufacturerId: null;

  console.log("<==================================================>");
  console.log("POST /ManufactureController/updateManufactureChecks ", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  // let checkedBod = _rowData.filter((item)=> item.bod == 'True').length > 0;
  // let bodval= "";

  // let checkedListed = _rowData.filter((item)=> item.listed == 'True').length > 0;
  // let listedVal= "";


  // for(let i=0 ; i < _rowData.length ; i++){
  //   let manufactureName= _rowData[i].jobManufactureName;

  // }

  var firstFunction = function () {
    return new Promise((resolve, reject) => {

      let sql=`call MANUFACTURER_master(?,?,?,?,  ?,?,?,?)`;
        pool.query(sql, [_action, _joMasterManufacturerId, _rxMasterID, _joMasterID, _listed, _bod, _userLoginID, null], function (err, results) {
          if (err) {
            console.log("error:", err) ;
            isInError = 1;
            isErrorCode = "FILTER_ERROR";
            if (err.sqlState == 41001) {
              isErrorMsg = "Please report this error";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              //isErrorMsg = err.sqlMessage;
            }
            resolve("");
          } else {
            resolve(results);
          }
        }); // end query
    }); // end promise
  };

  var main = async function () {
    var first = await firstFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          rows: first,
        };
        res.send(response);
      }
    });
  }; // end MAIN

  if (isInError == 0) {
    main();
  } else {
    // end isError

    console.log("post /manufactureController/updateManufactureChecks ERROR ", _action);

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  } // end isError
}); // end POST
// ===============================================

router.post("/getInsideJobManufacturer", function (req, res, next) {
  
  console.log("POST /ManufactureController/getInsideJobManufacturer ");
  var _action = req.body.action ? req.body.action : req.query.action;
  var _userLoginID = req.body.userLoginID ? req.body.userLoginID : req.query.userLoginID;
  let _joMasterID= req.body.joMasterId ? req.body.joMasterId: req.query.joMasterId;
  // let _bod= req.body.bod ? req.body.bod: 0;
  // let _listed= req.body.listed ? req.body.listed: 0;

  // let _rowData = req.body.rowData ? req.body.rowData : null;

  // let _rxMasterID= req.body.rxMasterID ? req.body.rxMasterID: null;
  // let _joMasterManufacturerId= req.body.joMasterManufacturerId? req.body.joMasterManufacturerId: null;

  console.log("<==================================================>");
  console.log("POST /ManufactureController/getInsideJobManufacturer ", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";


  var firstFunction = function () {
    return new Promise((resolve, reject) => {

      let sql=`call MANUFACTURER_master(?,?,?,?,  ?,?,?,?)`;
        pool.query(sql, [_action, null, null, _joMasterID, null, null, _userLoginID, null], function (err, results) {
          if (err) {
            console.log("error:", err) ;
            isInError = 1;
            isErrorCode = "FILTER_ERROR";
            if (err.sqlState == 41001) {
              isErrorMsg = "Please report this error";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              //isErrorMsg = err.sqlMessage;
            }
            resolve("");
          } else {
            resolve(results[0]);
          }
        }); // end query
    }); // end promise
  };

  var main = async function () {
    var first = await firstFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          rows: first,
        };
        res.send(response);
      }
    });
  }; // end MAIN

  if (isInError == 0) {
    main();
  } else {
    // end isError

    console.log("post /manufactureController/getInsideJobManufacturer ERROR ", _action);

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  } // end isError
}); // end POST
// ===============================================

// ===============================================
// API call to update isListedChecked, isBodChecked columns into joMaster table 


module.exports = router;
