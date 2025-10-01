var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;

var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";


/* GET users listing. */
router.post('/', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null);    
  var _period = (req.body.period ? req.body.period : null);    
    
    console.log('<==================================================>');
    console.log("post /joReleaseController", _action,_period);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
    var main = async function() {

        //var first = await (firstFunction());
            console.log("POST joReleaseController - call not supported.");
            getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
            if(err){
                res.send(err);
            }else{
                var response = {
                header : header,
                results : "The droids you are looking for are not here!"
                }                    
                res.send(response);
            }
        });

    }; // end MAIN


  if (isInError == 0) {

    main();
  
  } else { // end isError
 
    console.log("post /joReleaseController ERROR ", _action);

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



/* . */
router.post('/addRelease', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null);    
  var _userId = (req.body._userId ? req.body._userId : null);    
  var _joMasterID = (req.body._joMasterID ? req.body._joMasterID : null);    
  var _releaseType = (req.body._releaseType ? req.body._releaseType : null);    
  var _releaseDate = (req.body._releaseDate ? req.body._releaseDate : null);    
  var _rxVendorId = (req.body._rxVendorId ? req.body._rxVendorId : null);    
  var _estimatedBilling = (req.body._estimatedBilling ? req.body._estimatedBilling : null);    
  var _GRTaxRate = (req.body._GRTaxRate ? req.body._GRTaxRate : null);    
  var _ReleaseNote = (req.body._ReleaseNote ? req.body._ReleaseNote : null);    
  var _CustomerPONumber = (req.body._CustomerPONumber ? req.body._CustomerPONumber : null);    
  var _output = null;    
    
    console.log('<==================================================>');
    console.log("post /joReleaseController/addRelease", _action,_userId,_joMasterID,_releaseType,_releaseDate,_rxVendorId,_estimatedBilling,_GRTaxRate,_ReleaseNote,_CustomerPONumber);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call TP_jobRelease_controller(?,?,?,?,?,?,?,?,?,?,_output);';

                pool.query(sql,[_action,_userId,_joMasterID,_releaseType,_releaseDate,_rxVendorId,_estimatedBilling,_GRTaxRate,_ReleaseNote,_CustomerPONumber,_idUpdated],function (err, results) {
                    if (err) {
                        console.log("error:",err);
                        isInError =1;
                        isErrorCode =  "FILTER_ERROR";
                        if (err.sqlState==41001){
                        isErrorMsg = "Custom Error.";
                        }
                        else {
                        isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
                        //isErrorMsg = err.sqlMessage;
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



/* . */
router.post('/addReleaseDetail', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null);    
  var _userId = (req.body._userId ? req.body._userId : null);    
  var _joMasterID = (req.body._joMasterID ? req.body._joMasterID : null);    
  var _releaseType = (req.body._releaseType ? req.body._releaseType : null);    
  var _releaseDate = (req.body._releaseDate ? req.body._releaseDate : null);    
  var _rxVendorId = (req.body._rxVendorId ? req.body._rxVendorId : null);    
  var _estimatedBilling = (req.body._estimatedBilling ? req.body._estimatedBilling : null);    
  var _GRTaxRate = (req.body._GRTaxRate ? req.body._GRTaxRate : null);    
  var _ReleaseNote = (req.body._ReleaseNote ? req.body._ReleaseNote : null);    
  var _CustomerPONumber = (req.body._CustomerPONumber ? req.body._CustomerPONumber : null);    
  var _output = null;    
    
    console.log('<==================================================>');
    console.log("post /joReleaseController/addReleaseDetail", _action,_userId,_joMasterID,_releaseType,_releaseDate,_rxVendorId,_estimatedBilling,_GRTaxRate,_ReleaseNote,_CustomerPONumber);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

              //call TP_joReleaseDetail_update('UPDATE',1,465,null,'2019-08-29 00:00:00','2019-08-29 00:00:00','2019-08-29 00:00:00','2019-08-29 00:00:00',0,0,0,0,@out);

                sql = 'call TP_joReleaseDetail_update(?,?,?,?,?,?,?,?,?,?,_output);';

                pool.query(sql,[_action,_userId,_joMasterID,_releaseType,_releaseDate,_rxVendorId,_estimatedBilling,_GRTaxRate,_ReleaseNote,_CustomerPONumber,_idUpdated],function (err, results) {
                    if (err) {
                        console.log("error:",err);
                        isInError =1;
                        isErrorCode =  "FILTER_ERROR";
                        if (err.sqlState==41001){
                        isErrorMsg = "Custom Error.";
                        }
                        else {
                        isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
                        //isErrorMsg = err.sqlMessage;
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
// ------------------------------------------------------
router.post('/updateReleaseCustomer', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null);
  var _joMasterID = (req.body.joMasterID ? req.body.joMasterID : null);   

    console.log('<==================================================>');
    console.log("POST /joReleaseController/updateReleaseCustomer", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call TP_jobRelease_customer(?,?)'
                pool.query(sql,[_action,_joMasterID],function (err, results) {
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
 
    console.log("post /joReleaseController/updateReleaseCustomer ERROR ");

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




console.log("exporting router from joReleaseController.js");

module.exports = router;
