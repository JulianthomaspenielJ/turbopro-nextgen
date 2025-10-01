var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;
var nodemailer = require("nodemailer");

// Aws referrence
const AWS = require('aws-sdk');
AWS.config.region = 'us-east-1';
var sns = new AWS.SNS();
var pool = require('../config/db.js')

sns.config.update({
  accessKeyId: "AKIAXNMEG2APDSTCJ7X7",
  secretAccessKey: "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",
  rateLimit: 5 // do not send more than 5 messages in a second
})
const config = {
  "ses": {
    "from": "support@dsdarcommercial.com"
  },
  "templates": {
    "Email": "Message",
    "SMS": "Message"
  }
}

var sql = "";

//===============================================================

router.post("/sendOtptoMail", async function (req, res, next) {
  let action = req.body.action ? req.body.action : null;
  let userName = req.body.userName ? req.body.userName : null;
  let password = req.body.password ? req.body.password : null;

  console.log("<==================================================>");
  console.log("POST /sendotp/sendOtptoMail");
  res.send(await getResponse(action, userName, password)); 
}); // end POST

// ===============================================

function getResponse(action, userName, password){
  const sql = "call NOTIFICATION_notification(?,null,null,?,?, null,null,null,null,null, null,null,null,null,null, null,null,null,null, null);";
  return new Promise((resolve, reject) => {
    pool.query(
      sql, [action, userName, password],
      async function (err, results) {
        if (err) {
          console.log("error:", err);
          resolve(err);
        } else {
          if (results[0][0]._tryes < 3) {
            if (results[0][0].ack_forOtp == 0) {
              resolve(await sendSMS(results[0]));
            } else if (results[0][0].ack_forOtp == 1) {
              resolve(await sendOtpTomail(results[0]));
            }
          } else {
            resolve("tryes:3");
          }
        }
      }
    );
  });
}

function sendOtpTomail(res) {
  return new Promise((resolve, reject) => {
    var transporter = nodemailer.createTransport({
      pool: true,
        host: "smtp.gmail.com",
        port: 587,
      auth: {
        user: "eric@turboproonline.com",
        pass: "ErBa0076",
      },
    });

    // verifying the connection configuration
    transporter.verify(function (error, success) {
      if (error) {
        console.log(error);
        console.log("error in verify");
        resolve(error);
      } else {
        console.log("Server is ready to take our messages!", success);
      }
    });

    var mail = {
      from: "info@turboproonline.com",
       to: res[0].EmailAddr,
       // to:"alladi.vinay@softsuave.com",
      // to:"eric@aandespecialties.com",
      subject: "TurboPro Code",
      html: "Your code is " + res[0].entity_loginEmailValidationCode,
     
    };

    transporter.sendMail(mail, async (err, data) => {
      if (err) {
        console.log("error in transpoter", err);
        console.log("ERROR WAS OCCURED WHILE SENDING MAIL...!!!", err);
        resolve(err);
      } else {
        console.log("success in transpoter", data);
        console.log("MAIL WAS SUCCESSFULLY SENT...!!!");
        resolve("otp sent successfully");
      }
    });
  });
};

//==========================================================

function sendSMS(res) {
  return new Promise((resolve, reject) => {
    var params = {
      Message: "Your TurboPro Multi-factor Authentication code is  "+ res[0].entity_loginEmailValidationCode + ". Text HELP for more info or STOP to otp out.",
      MessageStructure: "string",
       PhoneNumber: '+1'+res[0].phoneNumber.replace(/-/g,"")
      // PhoneNumber: "+16783001464",
      // PhoneNumber: "+916301008650"
    };
    // console.log("sms params [system.js]", params)
    sns.publish(params, function (err, data) {
      if (err) {
        console.log("SMS sending Failed", err);
        // smsCallback(err, null);
        resolve(err);
      } else {
        console.log("SMS sent successfully", params);
        // smsCallback(null, data);
        resolve("SMS sent successfully");
      }
    });
  });
};

//==================================================================
router.post("/resetPassword", async function (req, res, next) {
  let action = req.body.action ? req.body.action : null;
  let userName = req.body.username ? req.body.username : null;
  let email = req.body.email ? req.body.email : null;

  console.log("<==================================================>");
  console.log("POST /sendotp/resetPassword");

  const sql = "call NOTIFICATION_notification(?,null,null,?,?, null,null,null,null,null, null,null,null,null,null, null,null,null,null,null);";
  return new Promise((resolve, reject) => {
    pool.query(
      sql, [action, userName, email],
      async function (err, results) {
        if (err) {
          console.log("error:", err);
          resolve(err);
        } else {
          resolve(await getrestPassword(results[0]));
        }
      }
    );
  });
});

//===========================================================

function getrestPassword(res) {
  return new Promise((resolve, reject) => {
    var transporter = nodemailer.createTransport({
      pool: true,
      host: "smtp.gmail.com",
      port: 587,
      auth: {
        user: "eric@turboproonline.com",
        pass: "ErBa0076",
      },
    });

    // verifying the connection configuration
    transporter.verify(function (error, success) {
      if (error) {
        console.log(error);
        console.log("error in verify");
        resolve(error);
      } else {
        console.log("Server is ready to take our messages!", success);
      }
    });

    var mail = {
      from: "info@turboproonline.com",
      to: res[0]._mailAddress,
      // to: "alladi.vinay@softsuave.com",
      // to:"eric@aandespecialties.com",
      subject: "TurboPro Code",
      html: "Your Password after Reset is : " + res[0]._resetpassword, // + res[0].entity_loginEmailValidationCode,

    };

    transporter.sendMail(mail, async (err, data) => {
      if (err) {
        console.log("error in transpoter", err);
        console.log("ERROR WAS OCCURED WHILE SENDING MAIL...!!!", err);
        resolve(err);
      } else {
        console.log("success in transpoter", data);
        console.log("MAIL WAS SUCCESSFULLY SENT...!!!");
        resolve("Reset Password sent successfully");
      }
    });
  });
};

module.exports = router;