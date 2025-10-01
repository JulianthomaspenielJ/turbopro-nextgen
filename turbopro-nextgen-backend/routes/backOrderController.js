var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;


var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";


// ===============================================

  router.post('/getBackOrders', function(req, res, next) {
    var _action = (req.body.action ? req.body.action : null); 
    var _vePOID = (req.body.vePOID ? req.body.vePOID : null); 
    var _warehouseID = (req.body.warehouseID ? req.body.warehouseID : null); 
    var _coDivisionID = (req.body.coDivisionID ? req.body.coDivisionID : null); 
    var _fromDate = (req.body.fromDate ? req.body.fromDate : null); 
    var _toDate = (req.body.toDate ? req.body.toDate : null); 
      console.log('<==================================================>');
      console.log("POST /backOrderController/getBackOrders", req.body);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call getBinBackOrder(?,?,?,?,?,?)'
                  pool.query(sql,[_action,_vePOID,_warehouseID,_coDivisionID,_fromDate,_toDate],function (err, results) {
                      if (err) {
                          console.log("error:",err);
                          isInError =1;
                          isErrorCode =  "FILTER_ERROR";
                          if (err.sqlState==41001){
                          isErrorMsg = "Make sure to provide your login.";
                          }
                          else {
                          isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
                          }
                          resolve(""); 
  
                      } else {      
                            resolve(results[0]); 
                      }
                      
              }); // end query
          }); // end promise
          }); 
  
  
      var main = async function() {
  
          var first = await (firstFunction());
  
              getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
              if(err){
                  res.send(err);
              }else{
                  var response = {
                  header : header,
                  results : first
                  }                    
                  res.send(response);
              }
          });
  
      }; // end MAIN
  
  
    if (isInError == 0) {
  
      main();
    
    } else { // end isError
   
      console.log("post /backOrderController/getBackOrders ERROR ");
  
         getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
          if(err){
            res.send(err);
          }else{
            var response = {
              isErrorMsg : isErrorMsg
            }                    
            res.send(response);
          }
        });
    
    } // end isError
  
    }); // end POST

// ===============================================

console.log("exporting router from warehouseInvController.js");

module.exports = router;