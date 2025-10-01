var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;


var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";


// ===============================================

  router.post('/getPurchaseOrders', function(req, res, next) {
    var _action = (req.body.action ? req.body.action : null); 
    var _userId = (req.body.userId ? req.body.userId : null);
    var _dateFrom = (req.body.fromDate ? req.body.fromDate : null);
    var _dateTo = (req.body.toDate ? req.body.toDate : null);
    var _searchData = (req.body.searchData ? req.body.searchData : null);
    var _poNumber = (req.body.poNumber>0 ? req.body.poNumber : null);
       
      console.log('<==================================================>');
      console.log("POST /receiveInvController/getPurchaseOrders", req.body);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call INV_getPO(?,?,?,?,?)'
                  pool.query(sql,[_action,_searchData,_dateFrom,_dateTo,_poNumber],function (err, results) {
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
   
      console.log("post /receiveInvController/getPurchaseOrders ERROR ");
  
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

router.post('/getPurchaseItems', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null); 
  var _vePOID = (req.body.vePOID ? req.body.vePOID : null); 
     
    console.log('<==================================================>');
    console.log("POST /receiveInvController/getPurchaseItems", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call PO_getPurchaseItems(?,?)'
                pool.query(sql,[_action,_vePOID],function (err, results) {
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
 
    console.log("post /receiveInvController/getPurchaseItems ERROR ");

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


router.post('/getPurchaseItemBins', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null); 
  var __vePODetailID = (req.body.vePODetailID ? req.body.vePODetailID : null); 
     
    console.log('<==================================================>');
    console.log("POST /receiveInvController/getPurchaseItemBins", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call PO_getReceivedBinsWithUpdate(?,?)'
                pool.query(sql,[_action,__vePODetailID],function (err, results) {
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
 
    console.log("post /receiveInvController/getPurchaseItemBins ERROR ");

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

router.post('/savepurchaseItems', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null); 
    var _userId = (req.body.userId ? req.body.userId : null);
    var _reference = (req.body.reference ? req.body.reference : null);
    var _array = (req.body.array ? JSON.parse(req.body.array) : []); 
  console.log(_array)
     
    console.log('<==================================================>');
    console.log("POST /receiveInvController/savepurchaseItems", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise(async(resolve, reject) => {      
                for(let i=0 ; i < _array.length ; i++){
                    await new Promise((resolve, reject) => {
                        sql = 'call INV_updateInventoryOH(?,null,null,?,null,null,?,?,null,?,null,?)'
                       pool.query(sql,[_action,_array[i].fromBinID,_reference,_array[i].quantityChanged,_array[i].vePODetailID,_userId],function (err, results) {
                        if(err) {
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
                        }else{
                          resolve(results[0])
                        }
                      });  
        
                    })
                }  
                resolve("");  
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
 
    console.log("post /receiveInvController/savepurchaseItems ERROR ");

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

router.post('/getPriorReceipts', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null); 
  var _vePOID = (req.body.vePOID ? req.body.vePOID : null); 
     
    console.log('<==================================================>');
    console.log("POST /receiveInvController/getPriorReceipts", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call PO_PriorReceipts(?)'
                pool.query(sql,[_vePOID],function (err, results) {
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
 
    console.log("post /receiveInvController/getPriorReceipts ERROR ");

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

console.log("exporting router from receiveInvController.js");

module.exports = router;