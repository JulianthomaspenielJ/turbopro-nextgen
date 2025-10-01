var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;
var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

router.post("/getQuotesStatusList", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    
    console.log("<==================================================>");
    console.log("post /jobController/getQuotesStatus", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function() {
      return new Promise((resolve, reject) => {
        sql = "call sp_updateQuotesStatus(?,?,?)";	 
        pool.query(sql, [_action, null,null], function(err, results) {
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
            resolve(results[0]==null?[]:results[0]);
          }
        }); // end query
      }); // end promise
    };
  
    var main = async function() {
      var first = await firstFunction();
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            header: header,
            results: first
          };
          res.send(response);
        }
      });
    }; // end MAIN
  
    if (isInError == 0) {
      main();
    } else {
      // end isError
  
      console.log("post /jobController/getQuotesStatus ERROR ");
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            isErrorMsg: isErrorMsg
          };
          res.send(response);
        }
      });
    } // end isError
  }); // end POST
  
  router.post("/updateQuotesStatus", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _id = req.body.id ? req.body.id : null;
    var _description = req.body.description ? req.body.description : null;
  
    console.log("<==================================================>");
    console.log("post /jobController/updateQuotesStatus", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function() {
      return new Promise((resolve, reject) => {
        sql = "call sp_updateQuotesStatus(?,?,?)";	 
        pool.query(sql, [_action, _id,_description], function(err, results) {
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
        }); // end query
      }); // end promise
    };
  
    var main = async function() {
      var first = await firstFunction();
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            header: header,
            results: first
          };
          res.send(response);
        }
      });
    }; // end MAIN
  
    if (isInError == 0) {
      main();
    } else {
      // end isError
  
      console.log("post /jobController/updateQuotesStatus ERROR ");
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            isErrorMsg: isErrorMsg
          };
          res.send(response);
        }
      });
    } // end isError
  }); // end POST




  router.post("/getQuotesSellingTypeList", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    
    console.log("<==================================================>");
    console.log("post /jobController/getQuotesSellingTypeList", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function() {
      return new Promise((resolve, reject) => {
        sql = "call sp_updateQuotesSellingType(?,?,?)";	 
        pool.query(sql, [_action, null,null], function(err, results) {
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
            resolve(results[0]==null?[]:results[0]);
          }
        }); // end query
      }); // end promise
    };
  
    var main = async function() {
      var first = await firstFunction();
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            header: header,
            results: first
          };
          res.send(response);
        }
      });
    }; // end MAIN
  
    if (isInError == 0) {
      main();
    } else {
      // end isError
  
      console.log("post /jobController/getQuotesSellingTypeList ERROR ");
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            isErrorMsg: isErrorMsg
          };
          res.send(response);
        }
      });
    } // end isError
  }); // end POST
  
  router.post("/updateQuotesSellingType", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _id = req.body.id ? req.body.id : null;
    var _description = req.body.description ? req.body.description : null;
  
    console.log("<==================================================>");
    console.log("post /jobController/updateQuotesSellingType", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function() {
      return new Promise((resolve, reject) => {
        sql = "call sp_updateQuotesSellingType(?,?,?)";	 
        pool.query(sql, [_action, _id,_description], function(err, results) {
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
        }); // end query
      }); // end promise
    };
  
    var main = async function() {
      var first = await firstFunction();
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            header: header,
            results: first
          };
          res.send(response);
        }
      });
    }; // end MAIN
  
    if (isInError == 0) {
      main();
    } else {
      // end isError
  
      console.log("post /jobController/updateQuotesSellingType ERROR ");
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            isErrorMsg: isErrorMsg
          };
          res.send(response);
        }
      });
    } // end isError
  }); // end POST

  module.exports = router;