var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;


router.post("/saveMaintenance", function (req, res, next) {
  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
    
      var _action = req.body.action ? req.body.action : null;
      var _prMasterID = req.body.reprMasterID ? req.body.reprMasterID : null;
      var _maintenanceDepartment = req.body.maintenanceDepartment ? req.body.maintenanceDepartment : null;
      var _maintenanceCategory = req.body.maintenanceCategory ? req.body.maintenanceCategory : null;
      var _primaryVendorID = req.body.primaryVendorID ?  req.body.primaryVendorID : null;
      var _baseSellingPriceID = req.body.baseSellingPriceID ?  req.body.baseSellingPriceID : null;
      var _multiplierId = req.body.multiplierId ?  req.body.multiplierId : null;
      var _factoryCostId = req.body.factoryCostId ?  req.body.factoryCostId : null;

      var sql = `call INV_maintenance(?,?,?,?,?,?,?,?)`;

      pool.query(
        sql,
        [
          _action,
          _prMasterID,
          _maintenanceDepartment,
          _maintenanceCategory,
          _primaryVendorID,
          _baseSellingPriceID,
          _multiplierId,
          _factoryCostId,
        ],
        async function (err, results) {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "FILTER_ERROR";
            if (err.sqlState == 41001) {
              isErrorMsg = "Make sure to provide your login.";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
            }
            resolve("");
          } else {
            resolve(results[0]);
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

    console.log("post /inventoryMaintenance/saveMaintenance ERROR ");

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
module.exports = router;
