var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;


var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";


// ===============================================

  router.post('/updateAdjustmentDetails', function(req, res, next) {
    var _action = (req.body.action ? req.body.action : null); 
    var _userId = (req.body.userId ? req.body.userId : null);
    var _transferDate = (req.body.transferDate ? req.body.transferDate : null);
    var _reference = (req.body.reference ? req.body.reference : null);
    var _resonCode = (req.body.resonCode ? req.body.resonCode : null);
    var _quantityChanged = (req.body.quantityChanged ? req.body.quantityChanged : null);         
    var _fromBinID = (req.body.fromBinID ? req.body.fromBinID : null);
  	var _toBinID = (req.body.toBinID ? req.body.toBinID : null);
    var _estimatedDate = (req.body.estimatedDate ? req.body.estimatedDate : null);
    var _prTransferDetailID = (req.body.prTransferDetailID ? req.body.prTransferDetailID : null);
    var _vePODetailID =   (req.body.vePODetailID ? req.body.vePODetailID : null);
    var _prToWarehouseID =   (req.body.prToWarehouseID ? req.body.prToWarehouseID : null);
      console.log('<==================================================>');
      console.log("POST /adjustmentController/updateAdjustmentDetails", req.body);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call INV_updateInventoryOH(?,?,?,?,?,?,?,?,?,?,?,?)'
                  pool.query(sql,[_action,_transferDate,_estimatedDate,_fromBinID,_toBinID,_reference,_resonCode,_quantityChanged,_prTransferDetailID,_vePODetailID,_prToWarehouseID,_userId],function (err, results) {
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
                            resolve(results); 
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
   
      console.log("post /adjustmentController/updateAdjustmentDetails ERROR ");
  
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


router.post('/getAdjustments', function(req, res, next) {

  var _action = (req.body.action ? req.body.action : null); 
  var _userId = (req.body.userId ? req.body.userId : null);
  var _prTransferID = (req.body.prTransferID ? req.body.prTransferID : null);
  var _search = (req.body.search ? req.body.search : null);
  var _vePODetailID = (req.body.vePODetailID ? req.body.vePODetailID : null);
  var _status = (req.body.status ? req.body.status : null);
     
    console.log('<==================================================>');
    console.log("POST /adjustmentController/getAdjustments", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call INV_getTransferHistory(?,?,?,?,?)'
                pool.query(sql,[_action,_prTransferID,_search,_vePODetailID,_status],function (err, results) {
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
 
    console.log("post /adjustmentController/getAdjustments ERROR ");

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

console.log("exporting router from adjustmentController.js");

module.exports = router;