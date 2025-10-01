var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;

var isInError
var isErrorMsg
var isErrorCode

function firstFunction(sql, args) {
  return new Promise((resolve, reject) => {
    pool.query(sql, args, function (err, results) {
      if (err) {
        console.log("error:", err);
        isInError = 1;
        isErrorCode = "FILTER_ERROR";
        isErrorMsg = err.sqlState
        resolve("");
      } else {
        resolve(results);
      }
    });
  });
};

async function main(sql, args, log_msg, res) {
  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  console.log('=====================', log_msg, args)

  var first = await firstFunction(sql, args);

  getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
    if(err){
      res.send(err);
    } else {
      var response = {
        header : header,
        results : first
      }
      console.log('+++++++ first', first)
      res.send(response);
    }
  })
}

function mainFunc(sql, args, log_msg, res) {
  try {
    (async () => {
      await main(sql, args, log_msg, res);
    })();
  } catch (err) {
    console.log('++ ERROR ++', err)
  }
}

module.exports = mainFunc
