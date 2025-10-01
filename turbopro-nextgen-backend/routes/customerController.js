var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;


var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";


// ===============================================

  router.post('/updateFinancials', function(req, res, next) {
    var _action = (req.body.action ? req.body.action : null); 
    var _userId = (req.body.userId ? req.body.userId : null);
    var _cuMasterID = (req.body.cuMasterID ? req.body.cuMasterID :null);
    var _invoiceYesNoMethod = (req.body.invoiceYesNoMethod ? req.body.invoiceYesNoMethod : null);
    var _statementYesNoMethod = (req.body.statementYesNoMethod ? req.body.statementYesNoMethod : null);
    var _invoiceYesDate = (req.body.invoiceYesDate ? req.body.invoiceYesDate : null);
    var _statementYesDate = (req.body.statementYesDate ? req.body.statementYesDate : null);
 
      console.log('<==================================================>');
      console.log("POST /customerController/updateFinancials", req.body);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call CO_updateCustomerFinancial(?,?,?,?,?,?,?)'
                  pool.query(sql,[_action,_cuMasterID,_invoiceYesNoMethod,_statementYesNoMethod,_invoiceYesDate,_statementYesDate,_userId],function (err, results) {
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
   
      console.log("post /customerController/updateFinancials ERROR ");
  
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


router.post('/getFinancials', function(req, res, next) {
    var _cuMasterID = (req.body.cuMasterID ? req.body.cuMasterID :null);
 
      console.log('<==================================================>');
      console.log("POST /customerController/getFinancials", req.body);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
                var action = "getCustomerFinancial";
                  sql = 'call CO_getCustomerFinancial(?,?,?,?)'
                  pool.query(sql,[action,_cuMasterID,null,null],function (err, results) {
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
   
      console.log("post /customerController/getFinancials ERROR ");
  
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


router.post('/getrxCustomerID', function(req, res, next) {
  var _customerName = (req.body.customerName ? req.body.customerName :null);
  var _date = (req.body.date ? req.body.date :null);


    console.log('<==================================================>');
    console.log("POST /customerController/getrxCustomerID",_customerName);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {
               //sql = `select * from rxMaster where Name = ?`
               var action = "getSingleCustomerFinancial"
               sql = 'call CO_getCustomerFinancial(?,?,?,?)' 
               pool.query(sql,[action,0,_customerName,_date],function (err, results) {
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
 
    console.log("post /customerController/getrxCustomerID ERROR ");

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

router.post('/updateCuMaster', function(req, res, next) {
  var _action = (req.body.action ? req.body.action :null);
  var _loginID = req.body.loginID ? req.body.loginID :null;
  var _rxMasterID = req.body.rxMasterID ? req.body.rxMasterID :null;


    console.log('<==================================================>');
    console.log("POST /customerController/updateCuMaster ",_rxMasterID);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {
               sql = 'call CO_getCustomerFinancial(?,?,?,?)' 
               pool.query(sql,[_action,_rxMasterID,_loginID,null],function (err, results) {
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
 
    console.log("post /customerController/getrxCustomerID ERROR ");

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


console.log("exporting router from customerController.js");

module.exports = router;