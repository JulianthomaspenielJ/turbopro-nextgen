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
    console.log("post /commissionController", _action,_period);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call COMMISSION_TIER_updateStatement(?, ?);';

                pool.query(sql,[_action,_period],function (err, results) {
                    if (err) {
                        console.log("error:",err);
                        isInError =1;
                        isErrorCode =  "FILTER_ERROR";
                        if (err.sqlState==41001){
                        isErrorMsg = "Make sure to provide your login.";
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
 
    console.log("post /commissionController ERROR ", _action);

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

/* GET users listing. */
router.get('/commissionStrategy', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null);    
    
    console.log('<==================================================>');
    console.log("get /commissionController/commissionStrategy", _action);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call COMMISSION_strategy(?);';

                pool.query(sql,[_action],function (err, results) {
                    if (err) {
                        console.log("error:",err);
                        isInError =1;
                        isErrorCode =  "FILTER_ERROR";
                        if (err.sqlState==41001){
                        isErrorMsg = "Make sure to provide your login.";
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
 
    console.log("get /commissionController/commissionStrategy ERROR ", _action);

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

  router.get('/tiredCalculation', function(req, res, next) {
    var _action = (req.query.action ? req.query.action : null); 
    var _userId = (req.query.userId ? req.query.userId : null); 
    var _ecPeriod = (req.query.ecPeriod ? req.query.ecPeriod : null);    
      
      console.log('<==================================================>');
      console.log("get /commissionController/tiredCalculation==============> ", req.query);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call COMMISSION_TIER_getCalculations(?,?,?);';
  
                  pool.query(sql,[_action,_userId,_ecPeriod],function (err, results) {
                      if (err) {
                          console.log("error:",err);
                          isInError =1;
                          isErrorCode =  "FILTER_ERROR";
                          if (err.sqlState==41001){
                          isErrorMsg = "Make sure to provide your login.";
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
   
      console.log("get /commissionController/tiredCalculation ERROR ", _action);
  
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


console.log("exporting router from commissionController.js");

module.exports = router;
