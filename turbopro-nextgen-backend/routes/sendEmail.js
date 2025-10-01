var AWS = require("aws-sdk");
var pool = require("../config/db.js");
const sgMail = require("@sendgrid/mail");
sgMail.setApiKey("YOUR_API_KEY");
var fs = require("fs");
const pdf = require('pdf-parse');
const simpleParser = require("mailparser").simpleParser;
const moment = require('moment')

AWS.config.region = "us-east-1";
// Ses configuration
var nodemailer = require("nodemailer");
var sesTransport = require("nodemailer-ses-transport");
var transporter = nodemailer.createTransport(
  sesTransport({
    accessKeyId: " ",
    secretAccessKey: "",
    rateLimit: 5, // do not send more than 5 messages in a second
  })
);

// Set the region
AWS.config.update({
  accessKeyId: "",
  secretAccessKey: "",
  region: "",
});

const config = {
  ses: {
    from: "",
  },
  templates: {
    Email: "Message",
    SMS: "Message",
  },
};
//=============================================================================================================================================
var awsFunctions = function () {
  function sendEmail(emailDetails) {
    return new Promise((resolve, reject) => {
      console.log("emailDetails::::", emailDetails);
      var fromEmail = emailDetails.fromEmail
        ? emailDetails.fromEmail.split("@")[0] + " "
        : " ";
      var fromName = emailDetails.fromContactName
        ? emailDetails.fromContactName
        : " ";
      var params = {
        from: {
          address: fromEmail,
          name: fromName,
        },
        to: [
          {
            address: emailDetails.email,
            name: "",
          },
        ],
        replyTo: emailDetails.fromEmail ? emailDetails.fromEmail : " ",
        subject: emailDetails.subject,
        html: "<p style='font-family:roboto;'>" + emailDetails.body + "</p>",
      };

      transporter.sendMail(params, function (err, info) {
        if (err) {
          console.log("Email sending FAILED", err);
          emailDetails.emailStatus = -1;
          //emailCallback(err, null);
        } else {
          console.log("Email sent to " + emailDetails.email + " SUCCESS");
          emailDetails.emailStatus = 1;
          //emailCallback(null, info);
        }
        resolve(emailDetails);
      });
    });
  }

  function sendSMS(smsDetails, smsCallback) {
    var params = {
      Message: smsDetails.body,
      MessageStructure: "string",
      PhoneNumber: smsDetails.mobile,
    };
    AWS.publish(params, function (err, data) {
      if (err) {
        console.log("SMS sending Failed", err);
      } else {
        console.log("SMS sent successfully", params);
      }
    });
  }

  this.sendNotification = async function (template) {
    console.log("sending notification...\n\n", template);
    if (template.notification_notificationType == "EMAIL") {
      console.log("sending email...");
      await sendEmail({
        fromEmail: template.notification_fromEmail,
        fromContactName: template.fromContactName,
        email: template.notification_toEmail, // template.toEmailId,
        subject: template.notification_subject,
        body: template.notification_content,
      });
    }
    if (template.notification_notificationType == "SMS") {
      console.log("sending SMS...");
      await sendSMS({
        email: template.notification_toEmail, // template.toEmailId,
        subject: template.notification_subject,
        mobile: template.phoneNumber,
        body: template.notification_content,
      });
    }
  };
};
//========================================================================================================
//Send mail using Sendgrid
var mailFunctions = function () {
  function sendgridEmail(data) {
    const msg = {
      //extract the email details
      to: data.email,
      from: data.fromEmail,
      subject: data.subject,
      text: " ",
      html: data.body,
    };
    //send the email
    sgMail
      .send(msg)
      .then((response) => {
        console.log(response[0].statusCode);
        console.log(response[0].headers);
      })
      .catch((error) => {
        console.error(error);
      });
  }

  this.getNotification = async function (_action) {
    let sql =
      "call NOTIFICATION_notification(?,?,?,?,?,  ?,?,?,?,?,  ?,?,?,?,?, ?, ?,?,? ,?);";
    var isInError = 0;
    var isErrorMsg = "";
    var isErrorCode = "";
    return new Promise((resolve, reject) => {
      pool.query(
        sql,
        [
          _action,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null
        ],
        function (err, result) {
          if (err) {
            console.log("error:", err);
            isInError = 1;
            isErrorCode = "FILTER_ERROR";
            if (err.sqlState == 41001) {
              isErrorMsg = "Please report this error";
            } else {
              isErrorMsg =
                err.sqlState +
                ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              //isErrorMsg = err.sqlMessage;
            }
            resolve("");
          } else {
            resolve(result);
          }
        }
      );
    });
  };
  //===========================================================================================================================================================================
  //send enail Using sendgrid
  this.sendGridNotification = async function (template) {
    console.log("sending notification...\n\n", template);
    console.log("sending email...");
    await sendgridEmail({
      fromEmail: template.notification_fromEmail,
      email: template.notification_toEmail,
      subject: template.notification_subject,
      body: template.notification_content,
    });
  };
};

//==============================================
// sendMail using nodeMailer

var sendNodeMailer = function (res) {
  return new Promise(async (resolve, reject) => {
    try {
      //Initating transporter
      var transporter = nodemailer.createTransport({
        pool: true,
        //service: res._mailService ? res._mailService : "",
        //maxConnections: 1,
        host: res.SMTPSvr ? res.SMTPSvr : "",
        port: res.SMTPPort ? res.SMTPPort : "",
        secureConnection: false,
        //secure: false,
        requireTLS: true,
        auth: {
          user: res.LogOnName ? res.LogOnName : "",
          pass: res.LogOnPswd ? res.LogOnPswd : "",
        },
        tls: {
          ciphers: "SSLv3",
          rejectUnauthorized: false,
        },
      });

      // verifying the connection configuration
      transporter.verify(function (error, success) {
        if (error) {
          console.log(error);
          console.log("error in verify");
        } else {
          console.log("Server is ready to take our messages!", success);
        }
      });
      var fromMailID
      if (res.pdfType === "REPORT") {
        fromMailID = res.fromEmailId;
      } else  if (res.pdfType === "DOC")
      {
        fromMailID = res.LogOnName;

      } else {
        fromMailID = res.LogOnName;
      }

      //validating email attributes
      if(res.BCCAddr == null){
        res.BCCAddr = "";
      }
      if(res.ccaddress == null){
        res.ccaddress = "";
      }

      //creating email body
      if (res.filename) {
        var mail = {
          from: fromMailID? fromMailID: "",
          to: res.toEmailId && res.toEmailId.includes(';')?res.toEmailId.split(';'):res.toEmailId.split(','),
          //to: "eric@aandespecialties.com",
          // to: "alladi.vinay@softsuave.com",
          cc: res.ccaddress && res.ccaddress.includes(';')?res.ccaddress.split(';'):res.ccaddress.split(','),
          bcc: res.BCCAddr && res.BCCAddr.includes(';')?res.BCCAddr.split(';'):res.BCCAddr.split(','),
          subject: res.subject ? res.subject : "",
          html: res.content ? res.content : "",
          attachments: [
            {
              // filename: 'image.png',
              filename: res.filename,
              //content: fs.createReadStream('routes/image.png'
              path: res.fileAttachment1
              // path: "/usr/local/tomcat7_BartosUAT/webapps/turbotracker/uploads/"+res.writepdfname
            },
          ],
        };
      }else{
         mail = {
          from: fromMailID? fromMailID: "",
          to: res.toEmailId && res.toEmailId.includes(';')?res.toEmailId.split(';'):res.toEmailId.split(','),
          //to: "eric@aandespecialties.com",
          // to: "alladi.vinay@softsuave.com",
          cc: res.ccaddress && res.ccaddress.includes(';')?res.ccaddress.split(';'):res.ccaddress.split(','),
          bcc: res.BCCAddr && res.BCCAddr.includes(';')?res.BCCAddr.split(';'):res.BCCAddr.split(','),
          subject: res.subject ? res.subject : "",
          html: res.content ? res.content : "",

        };
      }

      //store pdf actual and aftr attachment size
      let actualPDFSize = 0, attachmentPDFSize = 0;
      const checkSize = (mailOptions) => {
        var testTransporter = nodemailer.createTransport({
          streamTransport: true,
          newline: "windows",
        });

        const calPDFSize = () => {
          const fileSize = fs.statSync(mailOptions.attachments[0].path);
          return fileSize.size;
        };

        testTransporter.sendMail(mailOptions, function (error, info) {
          if (error) {
            console.log(error);
          } else {
            simpleParser(info.message, {}, (err, parsed) => {
              if (err) {
                console.log(err);
              } else if (mailOptions.attachments.length > 0) {
                console.log("To Email ---------", mailOptions.to);
                console.log("File Name ---------", mailOptions.attachments[0].filename);
                console.log("Original pdf size ---------", calPDFSize());
                actualPDFSize = calPDFSize();
                console.log("parsed pdf size ---------", parsed.attachments[0].size);
                attachmentPDFSize = parsed.attachments[0].size;
              } else {
                console.log("No attachment found ");
              }
            });
          }
        });
      };
      checkSize(mail);

      //sending email
      await transporter.sendMail(mail, async (err, data) => {
        if (err) {
          let errMsg = err.message;
          let errCode = err.code ;
          console.log("error in transpoter", err);
          let message = await updateMailStatus(
            "FAILEDUPDATE",
            res.userLoginId,
            res.contactId,
            res.fromEmailId,
            res.toEmailId,
            res.PONumber,
            res.id,
            'FAILED',
            res.pdfType,
            errMsg,
            errCode
          );
          console.log("ERROR WAS OCCURED WHILE SENDING MAIL...!!!", err);
          reject("Error while sending the email")
        }
        else if (actualPDFSize > data.messageSize || actualPDFSize != attachmentPDFSize) {
          console.log("size=====>", data.messageSize)
          await updateMailStatus(
            "FAILEDUPDATE",
            res.userLoginId,
            res.contactId,
            res.fromEmailId,
            res.toEmailId,
            res.PONumber,
            res.id,
            'FAILED',
            res.pdfType,
            "Attachment failed",
            ""
          );
          reject("Error with the attachment(s)")
        }
        else {
          console.log("success in transpoter", data);
          let message = await updateMailStatus(
            "UPDATE",
            res.userLoginId,
            res.contactId,
            res.fromEmailId,
            res.toEmailId,
            res.PONumber,
            res.id,
            "SUCCESS",
            res.pdfType
          );
          console.log("MAIL WAS SUCCESSFULLY SENT...!!!");
          if(res.pdfType === "REPORT"){
          try {
            // fs.unlinkSync("/var/lib/tomcat7/webapps/turbotracker/uploads/"+res.writepdfname); // D:\\TurboPro_projects\\TurboPro-Backend\\node-api\\routes\\
            // fs.unlinkSync("/usr/local/apache-tomcat-7.0.57/webapps/turbotracker/uploads/"+res.writepdfname);
            fs.unlinkSync(res.fileAttachment1)
            console.log("Delete File successfully.");
          } catch (error) {
            console.log(error);
          }
          }
          else if(res.pdfType === "DOC"){
            try {
              // fs.unlinkSync("/var/lib/tomcat7/webapps/turbotracker/uploads/"+res.writepdfname); // D:\\TurboPro_projects\\TurboPro-Backend\\node-api\\routes\\
              fs.unlinkSync(res.fileAttachment1);
              console.log("Delete File successfully.");
            } catch (error) {
              console.log(error);
            }
          }
          resolve("MAIL WAS SUCCESSFULLY SENT")
        }
      });
    }
    catch (exp) {
      reject(exp)
    }
  })
};

async function updateMailStatus(
  action,
  userLoginId,
  contactId,
  fromEmail,
  toEmail,
  PONumber,
  id,
  status,
  pdfType,
  errMsg,
  errCode
) {
  var sql1 = `call NOTIFICATION_notification(?,?,?,?,?, null,null,null,null,null, ?,?,?,?,?, ?, ?,?,? ,?)`;
  pool.query(
    sql1,
    [
      action,
      userLoginId,
      contactId,
      fromEmail,
      toEmail,
      PONumber,
      errMsg,
      errCode,
      status,
      id,
      pdfType,
      null,
      null,
      null,
      null
    ],
    async function (err, res) {
      if (err) {
        console.log("ERROR IN UPDATE", err);
        return { message: "error occured during update" };
      } else {
        console.log("UPDATE SUCCESS", res);
        return { message: "update success" };
      }
    }
  );
}

function updateAsPDFError( action,userLoginId, contactId,fromEmail,toEmail,PONumber,id,status, pdfType,errMsg,errCode) {
  let sql2 = `call NOTIFICATION_notification(?,?,?,?,? ,null,null,null,null,null, ?,?,?,?,?, ?,?,?,?,?)`;
  pool.query(sql2,[ action, userLoginId,contactId,fromEmail, toEmail,PONumber,errMsg,errCode,status,id, pdfType, null,null,null,null],async function (err, res) {
      if (err) {
        console.log("ERROR IN SENDMAIL WHILE ENABLEING", err);
      } else {
        console.log(" PDF is not found", res);
      }
    })
}

function sendemail() {
  var sql2 = `call NOTIFICATION_notification(?,null,null,null,null, null,null,null,null,null, null,null,null,null,null, null,null,null,null,null)`;
  pool.query(sql2, ["MAILSEND"], async function (err, res) {
    if (err) {
      console.log("ERROR IN SENDMAIL WHILE ENABLEING", err);
    } else {
      console.log("ALLOW TO SENDING MAILS");
    }
    if (res[0][0].valueInt === 1) {
      var sql = `call NOTIFICATION_notification(?,null,null,null,null, null,null,null,null,null, null,null,null,null,null, null,null,null,null,null)`;
      return new Promise((resolve, reject) => {
        pool.query(sql, ["GETMAIL"], async function (err, res) {
          if (err) {
            resolve({
              message: "failure",
              error: err,
            });
          } else {
            var response = res[0];
            const start = new Date().getTime();
            const cron_trigger = 30;
            for (let temp of response) {
              let current = new Date().getTime();

              console.log(`${temp.id} -  the process took ${(current - start) / 1000}`)

              if (((current - start) / 1000) <= cron_trigger - 5) {
                // Checking the PDF is crpted
                try {
                  if (temp.readyOn) {
                    if (moment().format("YYYY-MM-DD HH:mm") == temp.readyOn) {
                      let dataBuffer = fs.readFileSync(temp.fileAttachment1);
                      await pdf(dataBuffer).then(async function (data) {
                        // Sending email if it is not crpted
                        let result = await sendNodeMailer(temp);
                        console.log(result);
                      }).catch(e => {
                        console.log("PDF is Corrupted");
                        const id = temp.id;
                        updateAsPDFError("ATTACHMENTCORUPTTED", temp.userLoginId, temp.contactId, temp.fromEmailId, temp.toEmailId, temp.PONumber, id, 'FAILED', temp.pdfType, "PDF is Corrupted", "");
                        console.log(e);
                      });
                    }
                  }
                  else {
                    let dataBuffer = fs.readFileSync(temp.fileAttachment1);

                  if(temp.pdfType == 'DOC'){
                    let result = await sendNodeMailer(temp);
                    console.log(result)
                  }
                  else{
                    await pdf(dataBuffer).then(async function (data) {
                      let result = await sendNodeMailer(temp);
                      console.log(result)
                    }).catch(e => {
                      console.log("PDF is Corrupted")
  
                      const id = temp.id;
                      updateAsPDFError("ATTACHMENTCORUPTTED",temp.userLoginId, temp.contactId,temp.fromEmailId,temp.toEmailId, temp.PONumber, id,'FAILED', temp.pdfType, "PDF is Corrupted", "");
                      console.log(e);
                    })
                  }
                  }             
                }
                catch (err) {
                  // Handeling exception when checking if file is getting crpted
                  const id = temp.id;
                  updateAsPDFError("ATTACHMENTCORUPTTED",temp.userLoginId, temp.contactId,temp.fromEmailId,temp.toEmailId, temp.PONumber, id,'FAILED', temp.pdfType, "PDF is Corrupted", "");
                  console.log("PDF is not available ", err);
                }
              }
              else {
                console.log("###### Time out ######");
                
                break;
                
              }
            }
            resolve(res);
          }
        });
      });
    } else {
      console.log("STOPPED TO SEND MAILS");
    }
  });
}
exports.awsFunctions = awsFunctions;
exports.mailFunctions = mailFunctions;
exports.sendNodeMailer = sendNodeMailer;
exports.sendemail = sendemail;
//module.exports = router;
