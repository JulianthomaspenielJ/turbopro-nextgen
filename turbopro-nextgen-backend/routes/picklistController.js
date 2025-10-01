var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;
var getPicklistNode = require("../models/picklist.js").picklists;

var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";


// ===============================================

  router.post('/getPicklist', function(req, res, next) {
    var _type = (req.body.type ? req.body.type : null); 
    var _userId = (req.body.userId ? req.body.userId : null); 
       
      console.log('<==================================================>');
      console.log("POST /picklistController/getPicklist", _type);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call getPicklist(?);';
  
                  pool.query(sql,[_type],function (err, results) {
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

                            getPicklistNode(results[0], (err, picklists) => {
                                if(err){
                                    // res.send(err);
                                }    
                            resolve(picklists); 
                        
                            })

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
                  picklists : first
                  }                    
                  res.send(response);
              }
          });
  
      }; // end MAIN
  
  
    if (isInError == 0) {
  
      main();
    
    } else { // end isError
   
      console.log("get /picklistController/getPicklist ERROR ", _action);
  
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



console.log("exporting router from picklistController.js");

module.exports = router;
