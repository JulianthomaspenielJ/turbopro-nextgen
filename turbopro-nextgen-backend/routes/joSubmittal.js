var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;
const pdf = require('pdf-creator-node');
const fs = require('fs');


router.get('/getPDF', function (req, res, next) {
  console.log('<==================================================>');
  console.log("post submittal/getPDF");

  const jobNumber = req.query.jobNumber;

  readFile(jobNumber)
    .then(pdfFile => {
      res.contentType("application/pdf");
      res.send(pdfFile);
      fs.unlink('submittal' + jobNumber + '.pdf', (error) => {
        if (error) {
          console.error("Error occurred while deleting the PDF file:", error);
        } else {
          console.log("PDF file deleted.");
        }
      });
    })
    .catch(error => {
      res.status(500).send(error);
    });

  function readFile(jobNumber) {
    return new Promise((resolve, reject) => {
      if (req.query.jobNumber) {
        fs.readFile('submittal' + jobNumber + '.pdf', (error, data) => {
          if (error) {
            reject("Error occurred while reading the PDF file.");
          } else {
            resolve(data);
          }
        });
      }
      else {
        reject("Jobnumber is required for pdf file to generate.");
      }
    });
  }
});

router.post('/submittalController', function (req, res, next) {
  const action = req.body.action;
  const joMasterId = req.body.joMasterId;
  const status = req.body.status ?? null;
  const joSubmittalDetailID = req.body.joSubmittalDetailID ?? null;
  const category = req.body.category ?? null;
  const description = req.body.description ?? null;
  const texteditor = req.body.texteditor ?? null;
  const quantity = req.body.quantity ?? null;
  const vendorname = req.body.vendorname ?? null;
  const statusDate = req.body.statusDate ?? null;
  const cost = req.body.cost ?? null;
  const inlineNote = req.body.inlineNote ?? null;
  console.log('<==================================================>');
  console.log("post submittal/submittalController");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    const SQL = "CALL SUBMITTAL_submittal(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);";
    const params = [action, joMasterId, joSubmittalDetailID, category, description, texteditor, quantity, vendorname, status, statusDate, cost, inlineNote, null, null, null, null, null];
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

router.post('/submittalPDF', function (req, res, next) {
  const joMasterId = req.body.joMasterId;
  const customer = req.body.customer;
  const jobName = req.body.jobName;
  const architect = req.body.architect ? req.body.architect : "";
  const date = req.body.date;
  const jobNumber = req.body.jobNumber;

  console.log('<==================================================>');
  console.log("post submittal/submittalPDF");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    const sql = `SELECT jom.LocationCity as city,jom.LocationState AS state,jos.category,jos.texteditor,jos.quantity,CONCAT(rxc.FirstName,' ',rxc.LastName) AS promanager,rxm.Name AS engineer,ts.FullName AS submittedBy,DATE_FORMAT(jom.planDate, '%m/%d/%Y') AS planDate,us.companyLogo,us.HeaderText FROM joSubmittalDetail AS jos LEFT JOIN joMaster AS jom ON(jom.joMasterID = jos.joMasterID)
                   LEFT JOIN rxContact AS rxc ON(jom.cuAssignmentID7 = rxc.rxContactID) LEFT JOIN rxMaster AS rxm ON(jom.rxCategory2 = rxm.rxMasterID) LEFT JOIN tsUserLogin AS ts ON(ts.UserLoginID = jom.cuAssignmentID0)
                  CROSS JOIN tsUserSetting AS us WHERE joSubmittalID = (SELECT joSubmittalID FROM joSubmittal WHERE joMasterID = ?);`;
    return new Promise((resolve, reject) => {
      pool.query(sql, [joMasterId], async function (err, results) {
        if (err) {
          isInError = 1;
          isErrorCode = "INVALID_DATA";
          isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
          reject(err);
        } else {
          createAPDF(results);
          resolve(jobNumber);
        }
      })
    });
  };

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

  function createAPDF(results) {

    const base64Image = results[0].companyLogo.toString('base64');
    imageSrc = `data:image/jpeg;base64,${base64Image}`;

    var options = {
      format: "A3",
      orientation: "portrait",
      border: "5mm",
      header: {
        height: "1mm",
        contents: ``
      },
      footer: {
        height: "28mm",
        contents: {
          default: `<table style="width: 99%; border: 1px solid #000; table-layout: fixed;">
              <tr>
                  <td style="width: 50%; border-right: 1px solid #000; height: 40px; text-align: center; vertical-align: middle;">
                      <strong style="font-size: 13px;">SUBMITTED BY:&nbsp;</strong>${results[0].submittedBy}
                  </td>
                  <td style="width: 50%; height: 40px; text-align: center; vertical-align: middle;">
                      <strong style="font-size: 13px;">DATED:&nbsp;</strong>${date}
                  </td>
              </tr>
          </table>
          `
        }
      }
    };
    const generateContentForPage = (values) => {
      const content = `
          <div class="page" style="position: relative;">
              <div style="width:100%;">
                  <section style="float: left;">
                      <img style="width:200px;" src="${imageSrc}" alt="Image">
                      ${results[0].HeaderText}
                  </section>
                  <h1 style="float: right;">SUBMITTAL</h1>
              </div>
      
              <table style="width: 99%; border-collapse: collapse;padding-top: 150px;">
                  <tr>
                      <td style="border: 1px solid #000; width: 50%; padding: 5px;">
                          
                          <strong style="font-size: 13px;">PROJECT:&nbsp;</strong>${jobName}<br>
                          <strong style="font-size: 13px;">LOCATION:&nbsp;</strong>${values.city === '' && values.state ==='' ? "Not Available" : values.city + ',' + values.state}<br>
                          <strong style="font-size: 13px;">CUSTOMER:&nbsp;</strong>${customer}<br>
                          <strong style="font-size: 13px;">ATTENTION:&nbsp;</strong>${values.promanager ? values.promanager : "Not Available"}<br>
                          <strong style="font-size: 13px;">JOB NUMBER:&nbsp;</strong>${jobNumber}<br>
                          
                      </td>
                      <td style="border: 1px solid #000; width: 50%;padding: 5px;">
                          <strong style="font-size: 13px;">ARCHITECT:&nbsp;</strong>${architect}<br>
                          <strong style="font-size: 13px;">ENGINEER:&nbsp;</strong>${values.engineer ? values.engineer : "Not Available"}<br>
                          <strong style="font-size: 13px;">PLAN DATE:&nbsp;</strong>${values.planDate ? values.planDate : "Not Available"}<br>
                      </td>
                  </tr>
              </table>
              <div style="margin-top: 30px;">
                <strong style="text-decoration: underline;line-height: 1.5;">${values.category == 0 ? "" : `${values.category} :`}</strong><br>
                <table style="width: 100%; border-collapse: collapse;margin-top: 10px;">
                  <tr>
                      <td style="vertical-align:top;width: 50px;"><strong>${values.quantity == 0 ? "" : `${values.quantity}`}</strong></td>
                      <td>
                          ${values.texteditor}
                      </td>
                  </tr>
              </table>
              </div>
          </div>`
      return content;
    };
  
      let allPagesContent = ``;
  
      results.forEach((values, index) => {
        let content = generateContentForPage(values);
        allPagesContent += content;
      });

    let html = `<!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8" />
          <title>Submittal</title>
        </head>
        <body>
          <style>
              .page {
                page-break-after: always;
              }
              .page:last-child {
                page-break-after: avoid;
              }
              p {
                margin-top: 0;
                }            
            </style>
            ${allPagesContent}
            </body>
            </html>`
    var document = {
      html: html,
      data: {
        users: "",
      },
      path: `./submittal${jobNumber}.pdf`,
      type: "",
    };

    pdf.create(document, options).then((res) => {
      console.log(res);
    }).catch((error) => {
      console.error(error);
    });
  }
});

module.exports = router;