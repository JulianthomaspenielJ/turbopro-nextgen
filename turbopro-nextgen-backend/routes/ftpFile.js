const Client = require("ssh2-sftp-client");
const express = require("express");
const router = express.Router();
const pool = require("../config/db.js");
const fs = require("fs");
const moment = require("moment");

class SFTPClient {
  constructor() {
    this.client = new Client();
  }

  async connect(options) {
    console.log(`Connecting to ${options.host}:${options.port}`);
    try {
      await this.client.connect(options);
    } catch (err) {
      console.log("Failed to connect:", err);
    }
  }

  async disconnect() {
    await this.client.end();
  }

  async uploadFile(localFile, remoteFile) {
    console.log(`Uploading ${localFile} to ${remoteFile} ...`);
    try {
      let result = await this.client.put(localFile, remoteFile);
      return result;
    } catch (err) {
      console.error("Uploading failed:", err);
      return err;
    }
  }
}

function ftpProtocol() {
  const client = new SFTPClient();
  let resp = { status: 500 };

  return new Promise(async (resolve, _) => {
    try {
      await client.connect({
        host: "157.55.201.56",
        port: 22,
        username: "turboftp",
        password: "Turbo!13579",
      });

      // var postDate ="2023-07-13"; //'2023-06-08'
      let postDate = moment().format("YYYY-MM-DD");
      sql = "CALL sp_positivePay(?,?);";
      // resolve(
        // await new Promise((resol, __) =>
          pool.query(sql, [postDate, 0], async function (err, results) {
            try {
              if (err) {
                console.log(err);
                resolve("Error while fechting data");
              } else {
                if (results[0].length > 0) {
                  console.log("Inside updoad if condition >>>>>>>>> DATE = ", postDate,"  Total record =", results[0].length);
                  var arrVal = [];
                  var arrPush = [];
                  // var arrKeys = Object.keys(results[0][0])
                  // arrPush.push(arrKeys.join());
                  for (var i = 0; i < results[0].length; i++) {
                    arrVal = Object.values(results[0][i]);
                    arrPush.push(arrVal.join());
                  }
      
                  // let filePath = "D:\\Positive_Pay_Bartos_2023-06-08.txt";
                  // let fileName = "testing_ftp_" + postDate + ".txt";
                  let filePath = "/home/GeneratePositivePay/OutputFile/PositivePay_Bartos.txt";
                  let fileName = "Positive_Pay_Bartos_" + postDate + ".txt";
                 
                  fs.writeFileSync(filePath, arrPush.join("\n"));
                  console.log("============================= after fs.writeFileSync =============================");
                  console.log(" filePath = "+filePath+"      and        fileName = " +fileName);
                  let result_ftp = await client.uploadFile(filePath, `/home/turboftp/ftp/files/${fileName}`);
                  console.log("============================= result_ftp=============================>", result_ftp);
                  await client.disconnect();

                  if (result_ftp?.includes("Uploaded data stream")) {
                    fs.unlink(filePath, (err) => {
                      if (err) console.log("error while deleting file ", err);
                    });
                    console.log(result_ftp);
                    resp.status = 200;
                    resp.result = result_ftp;
                    resolve(resp);
                  } else {
                    resolve(resp);
                  }
                } else {
                  console.log("=======================No Data for Positive Pay on Date :"+postDate+"====================================");
                  resolve("No Data for Positive Pay");
                }
              }
            } catch (ex) {
              console.log("Error in ftpFile.js in inner try block", ex);
              // resp = { error: JSON.stringify(ex), status: 500 };
              // resol(resp);
              resolve("Error while Processing upload")
            }
          })
        // )
      // );
    } catch (ex) {
      console.log("", ex);
      // resp = { error: JSON.stringify(ex), status: 500 };
      resolve("Error in try block");
    }
  });
}

exports.ftpProtocol = ftpProtocol;

// router.get("/checkFTP", async (req, res, next) => {
//   let resp = await ftpProtocol();
//   // res.status(resp.status).send({ response: resp });
//   console.log("resp last:  ", resp)
//   res.send(resp);
// });
// module.exports = router;
