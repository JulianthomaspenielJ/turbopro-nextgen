var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;
var jwt = require('jsonwebtoken')

router.post('/login', function (req, res) {
    const username = req.body.username;
    const password = req.body.password;
    console.log("<==================================================>");
    console.log(`POST /auth/login`);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";

    let sqlFunction = function () {
        const SQL = `select UserLoginID, FullName from tsUserLogin
                     where LoginName = ? and LoginPassword = ?;`;
        const params = [username, password];
        return new Promise((resolve, reject) => {
            pool.query(
                SQL,
                params,
                (err, result) => {
                  if (err || !(result && result.length)) {
                    isInError = 1;
                    isErrorCode = "INVALID_DATA";
                    isErrorMsg = err.sqlState + ": We had difficulty logging you in. Pleae reporthis number to your contact.";
                    reject(err);
                  } else {
                    try {
                      var {UserLoginID, FullName} = result[0]
                    } catch (err) {
                      isInError = 1;
                      isErrorCode = "INVALID_DATA";
                      isErrorMsg = err.sqlState + ": Bad credentials.";
                      reject(err);
                    }
                    try {
                      var token = jwt.sign({ username: username, password: password },
                        'secret', { expiresIn: 60 * 60 * 24 });
                    } catch (err) {
                      console.log('JWT broken: ', err);
                      reject(err);
                    }
                    console.log('||| result', UserLoginID, FullName)
                    resolve({UserLoginID, FullName, token});
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
else {
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

module.exports = router;
