var express = require('express');
var router = express.Router();
var pool = require('../config/db.js');
var getHeaderNode = require("../models/header.js").header;
const fs = require('fs');
const { getSignedUrl } = require("../helper/uploadFile.js");
const {downloadPDFFromS3} =  require("../helper/PDFshare.js");

router.get("/getNotifications", function (req, res, next) {
  var _action = (req.query.action ? req.query.action : "CREATE")
  var _userLoginId = req.query.userLoginId ? req.query.userLoginId : null

    console.log("<==================================================>");
    console.log('/getNotifications')

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function () {
      let sql =
        `call NOTIFICATION_notification(?,?,?,?,?, ?,?,?,?,?,  ?,?,?,?,?, ?, ?,?,?,?);`;
      return new Promise((resolve, reject) => {
        pool.query(
          sql,
          [_action, _userLoginId, null, null, null,  null, null, null, null, null,  null, null, null, null, null,  null,   null, null, null, null],
          function (err, results) {
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
          }
        );
      });
    };

    var main = async function () {
      var first = await firstFunction();

      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            header: header,
            results: first,
          };
          res.send(response);
        }
      });
    }; // end MAIN

    if (isInError == 0) {
      main();
    } else {
      // end isError

      console.log("get /notificationController/getNotifications ERROR ");

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
    }
});

router.post("/resendEmail", function (req, res, next) {
  var _toEmailID = req.body.toEmailId ? req.body.toEmailId : null;
  var _id = req.body.id ? req.body.id : null;
  var _subject = req.body.subject? req.body.subject: null;

  console.log("<==================================================>");
  console.log("/resendEmail");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    let sql = `call NOTIFICATION_notification(?, null, null, null, ?, ?, null, null, null, null, null, null, null, null, ?, null,   null, null, null, null);`;
    return new Promise((resolve, reject) => {
      pool.query(sql, ["RESEND", _toEmailID, _subject, _id], function (err, results) {
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
          console.log(_toEmailID, _subject, _id);
          resolve(results[0]);
        }
      });
    });
  };

  var main = async function () {
    var first = await firstFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          results: first,
        };
        res.send(response);
      }
    });
  }; // end MAIN

  if (isInError == 0) {
    main();
  } else {
    // end isError

    console.log("post /notificationController/resendEmail ERROR ");

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
  }
});

router.post("/acknowledge", function(req, res, next) {
  var _id = req.body.id ? req.body.id : null;

  console.log("<==================================================>");
  console.log("/acknowledge");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    let sql = `UPDATE tsUser_global_notification SET statusId = 3, changedOn = now() where id = ?;`;
    return new Promise((resolve, reject) => {
      pool.query(sql, [_id], function (err, results) {
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
      });
    });
  };

  var main = async function () {
    var first = await firstFunction();

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          results: first,
        };
        res.send(response);
      }
    });
  }; // end MAIN

  if (isInError == 0) {
    main();
  } else {
    // end isError

    console.log("post /notificationController/acknowledge ERROR ");

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
  }
});


router.post("/shareDocument", async function (req, res, next) {
  var _action = (req.body.action ? req.body.action : "CREATE")
  var userLoginId = req.body.userLoginId ? req.body.userLoginId : null
  var toEmailId =req.body.toEmail ? req.body.toEmail : null 
  var fromEmailId =req.body.fromEmail ? req.body.fromEmail : null
  var subject=req.body.subject ? req.body.subject : null
  var content =req.body.content ? req.body.content : null
  var fileAttachment1 =req.body.attachmentURI ? req.body.attachmentURI : null
  var ccaddress =req.body.ccaddress ? req.body.ccaddress : null 
  var PONumber =req.body.PONumber ? req.body.PONumber : null 
  var JobNumber = req.body.JobNumber ? req.body.JobNumber : null 
  var writepdfname =  req.body.writepdfname ? req.body.writepdfname : null 
  var pdfType = req.body.pdfType ? req.body.pdfType : null 
  var contactId =  req.body.contactId ? req.body.contactId : null 
  var filename =  req.body.filename ? req.body.filename : null 

  // SSL_FACTORY, JobNumber, BCCAddr, PONumber, filename, ccaddress, writepdfname, statusId, tryes, pdfType
    console.log("<==================================================>");
    console.log('/shareDocument')

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";

    try {
    await getSignedUrl(fileAttachment1).then((response) => {
      fileurl =response
    }).catch((err) => {console.log(err)})
    } catch(err) {
      console.log(err)
      res.send(err)
    }
   
    // directoryPath="/usr/local/apache-tomcat-7.0.57/webapps/turbotracker/uploads/"
    directoryPath = fileAttachment1
    if (!fs.existsSync(directoryPath)) {
      try {
        fs.mkdirSync(directoryPath, { recursive: true });
        console.log('Upload directory created successfully.');
      } catch (err) {
        console.error('Error creating upload directory:', err);
      }
    }
    let docname = filename.split('.')
    //  let filePath="/usr/local/apache-tomcat-7.0.57/webapps/turbotracker/uploads/" +docname[0];
    let filePath = fileAttachment1

   
    let extension
    await downloadPDFFromS3(fileurl, filePath)
      .then((data) => {
        extension=data
        console.log('DOC downloaded and saved successfully.');
      })
      .catch((error) => {
        console.error('Error downloading PDF:', error);
      });

      writepdfname = docname[0]+'.' + extension
      filename = writepdfname
  
    var firstFunction = function () {
      let sql = `INSERT INTO tsUser_global_notification (userLoginId, fromEmailId, toEmailId, subject, content,fileAttachment1,ccaddress,PONumber,JobNumber,writepdfname,pdfType,contactId,filename,createdOn) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())`;

      return new Promise((resolve, reject) => {
        pool.query(sql, [userLoginId, fromEmailId, toEmailId, subject, content, fileAttachment1,ccaddress,PONumber,JobNumber,writepdfname,pdfType,contactId,filename], function (err, results) {
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
        });
      });
    };
  

    var main = async function () {
      var first = await firstFunction();

      getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if (err) {
          res.send(err);
        } else {
          var response = {
            header: header,
            results: first,
          };
          res.send(response);
        }
      });
    }; // end MAIN

    if (isInError == 0) {
      main();
    } else {
      // end isError

      console.log("get /notificationController/shareDocument ERROR ");

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
    }
});

module.exports = router;