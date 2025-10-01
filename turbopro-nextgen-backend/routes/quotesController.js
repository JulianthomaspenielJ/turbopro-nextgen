var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;

var sql = "";
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

// API call to updated Quote dates
router.post("/updateQuoteDates", function (req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _joBidderID = req.body.joBidderID ? req.body.joBidderID : null;
    var _joMasterID = req.body.joMasterID ? req.body.joMasterID  : null;
    var _quoteTypeID   = req.body.quoteTypeID ? req.body.quoteTypeID  : null;
    var _quoteDate  = req.body.quoteDate ? req.body.quoteDate  : null;
    var _rxContactId = req.body.rxContactId ? req.body.rxContactId  : null;
    var _rxMasterId = req.body.rxMasterId ? req.body.rxMasterId  : null;
    var _emailStatus = req.body.emailStatus == "sent" ? req.body.emailStatus  : "failed"; 
  
    console.log("<==================================================>");
    console.log("post /updateQuoteDates ", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function () {
      return new Promise((resolve, reject) => {
        let sql = `call UPDATE_updateQuoteDate(?,?,?,?,  ?,?,?,?)`;
        pool.query(
          sql,
          [_action, _joBidderID, _joMasterID, _quoteTypeID, _quoteDate, _rxContactId, _rxMasterId, _emailStatus],
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
              }
              resolve("");
            } else {
              resolve(results[0]);
            }
          }
        );
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
  
      console.log("post /updateQuoteDatese ERROR ", _action);
  
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