var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;

router.post('/searchEngine', function (req, res, next) {
    const category = req.body.category;
    const searchTerm = req.body.searchTerm;
    const count = req.body.count ? req.body.count : null;
    const offSet = req.body.offSet;
    const recent = req.body.recent;
    console.log('<==================================================>');
    console.log("post submittal/searchEngine");
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    let sqlFunction = function () {
      const SQL = "CALL SEARCH_manager(?, ?, ?, ?, ?, ?, ?, ?);";
      const params = ["SEARCH", category, searchTerm, count, offSet, recent, null, null];
      return new Promise((resolve, reject) => {
        pool.query(
          SQL,
          params,
          (err, result) => {
            if (err) {
              isInError = 1;
              isErrorCode = "INVALID_DATA";
              isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              reject(err);
            } else {
              resolve(result);
            }
          }
        );
      });
    }
  
    const main = async function () {
      try {
        var result = await sqlFunction();
      } catch (error) {
        console.log(error)
      }
  
      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          const response = {
            header: header,
            results: result,
          };
          res.send(response);
        }
      });
    };
  
    if (isInError == 0) {
      main();
    }
  });

module.exports = router;


