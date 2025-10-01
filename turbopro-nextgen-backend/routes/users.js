var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;

/* GET users listing. */
router.get('/', function(req, res, next) {
  const sql = "select * from tsUserLogin"
  pool.query(sql, (err, result) => {
    if (err) {
      res.send({msg: 'error in executing query', error: err });
    } else {
      res.send({msg: '-------Successfully connected--------', users: result });
    }
  })
});

router.post('/updatesignature', function (req, res) {
  const esDetails = req.body.esDetails;
  const loginId = req.body.loginId;
  console.log("<==================================================>");
  console.log("POST /users/updatesignature");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    const SQL = "UPDATE tsUserLogin SET signature = ? WHERE UserLoginID = ?;";
    const params = [esDetails,loginId];
    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        params,
        (err, result) => {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "INVALID_DATA";
            if (err.sqlState == 41001) {
              isErrorMsg = "Make sure to provide your login.";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
            }
            reject(err);
          } else {
            console.log(result)
            resolve(result);
          }
        }
      );
    });
  }  

  var main = async function () {
    var result = await sqlFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
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
  else{
    // end isError

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  }// end isError
});



router.get('/getsignature', function (req, res) {
  const loginId = req.query.loginId;
  console.log("<==================================================>");
  console.log("GET /users/getsignature");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    const SQL = "select signature from tsUserLogin where UserLoginID = ?;";
    const params = [loginId];
    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        params,
        (err, result) => {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "INVALID_DATA";
            if (err.sqlState == 41001) {
              isErrorMsg = "Make sure to provide your login.";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
            }
            reject(err);
          } else {
            resolve(result);
          }
        }
      );
    });
  }  

  var main = async function () {
    var result = await sqlFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
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
  else{
    // end isError

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  }// end isError
});

router.post('/updateemailnotes', function (req, res) {
  const emailQuoteNote = req.body.emailQuoteNote;
  const loginId = req.body.loginId;
  const emailQuoteOptions = req.body.emailQuoteOptions;
  console.log(req.body.emailQuoteOptions.quote);
  console.log("<==================================================>");
  console.log("POST /users/updateemailnotes");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    const SQL = "UPDATE tsUserLogin SET emailNotes = ?, emailNoteOption = ? WHERE UserLoginID = ?;";
    const params = [emailQuoteNote, emailQuoteOptions, loginId];
    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        params,
        (err, result) => {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "INVALID_DATA";
            if (err.sqlState == 41001) {
              isErrorMsg = "Make sure to provide your login.";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
            }
            reject(err);
          } else {
            console.log(result)
            resolve(result);
          }
        }
      );
    });
  }  

  var main = async function () {
    var result = await sqlFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
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
  else{
    // end isError

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  }// end isError
});

router.get('/getemailnotes', function (req, res) {
  const loginId = req.query.loginId;
  console.log("<==================================================>");
  console.log("GET /users/getemailnotes");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    const SQL = "select emailNotes,emailNoteOption from tsUserLogin where UserLoginID = ?;";
    const params = [loginId];
    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        params,
        (err, result) => {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "INVALID_DATA";
            if (err.sqlState == 41001) {
              isErrorMsg = "Make sure to provide your login.";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
            }
            reject(err);
          } else {
            console.log(result)
            resolve(result);
          }
        }
      );
    });
  }  

  var main = async function () {
    var result = await sqlFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
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
  else{
    // end isError
    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  }// end isError
});



router.get('/docPermission', function (req, res) {
  console.log("<==================================================>");
  console.log("GET /users/docPermission");
  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";
  let sqlFunction = function () {
    const SQL = "select Doc_Permission from tsUserSetting;";
    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        (err, result) => {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "INVALID_DATA";
            if (err.sqlState == 41001) {
              isErrorMsg = "error occured";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
            }
            reject(err);
          } else {
            console.log(result)
            resolve(result);
          }
        }
      );
    });
  }  
  var main = async function () {
    var result = await sqlFunction();
    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
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
  else{
    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      }
    });
  }// end isError
});
console.log("exporting router from users.js");

module.exports = router;
