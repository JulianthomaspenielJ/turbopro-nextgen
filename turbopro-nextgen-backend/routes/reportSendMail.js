const express = require("express");
const router = express.Router();
const pool = require("../config/db.js");
const pdfmake = require("pdfmake");
const path = require("path");
const fs = require("fs");
const moment = require("moment");
//reportSendmail.js

var reportAndHeaderData;
var tableContent;
var attachmentPath = '';

const dollerFormatter = new Intl.NumberFormat("en-US", {
  style: "currency",
  currency: "USD",
});

var percentageFormatter = new Intl.NumberFormat("en-US", {
  style: "percent",
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

function cronGenereteReports() {
  // router.get("/test", function (req, res, next) {
  return new Promise((resolve) => {
console.log("Inside cronGenereteReports TSET API")

    const currDate = new Date().getDate();
    const currDay = new Date().getDay();
    const currMonth = new Date().getMonth()+1;
    const startDate = new Date();

    const sql = `select * from REPORT_reports,tsUserSetting where REPORT_reports.myReportEntityId is not null and REPORT_reports.myScheduleType is not null`;

    pool.query(sql, [], async function (err, results) {
      if (err) {
        console.log("error:", err);
        resolve(err);
      } else {
        for (let temp of results) {
          reportAndHeaderData = temp;
          let myScheduleType = temp.myScheduleType;
          var isSendEmail = null;
          attachmentPath = temp.path;

          if (myScheduleType == 0) {
            isSendEmail = "DAILY";
            await updateSheduleDates(temp);
          } else if (myScheduleType == 1 && currDay == 5) {
            isSendEmail = "WEEKLY";
            await updateSheduleDates(temp);
          } else if (myScheduleType == 2 && currDate == 1) {
            isSendEmail = "MONTHLY";
            await updateSheduleDates(temp)
          } else if (myScheduleType == 3 && currMonth === 1 && currDate === 1) {
            isSendEmail = "YEARLY";
            await updateSheduleDates(temp);
          } else {
            isSendEmail = null;
          }

          if (isSendEmail != null) {
            console.log(`============= ${isSendEmail} ============`);
            const getReport = await reportmail(reportAndHeaderData, startDate);
            resolve(getReport);
          } else {
            resolve("Date is not matching");
          }
        }
      }
    });
  });
  // });
}

const formatDate = (date) => {
  return moment(date).format("YYYY-MM-DD");
};

function updateSheduleDates(report) {
  const currDate = formatDate(new Date());
  const monthEnding = formatDate(moment(currDate).endOf("month"));
  return new Promise((resolve) => {
    const sql = `call REPORT_filters('UPDATE_SCHEDULE_DATES',null,?,null,null,null,null,null,null,?,?,null,null);`;

    pool.query(
      sql,
      [report.reportId, currDate, monthEnding],
      async function (err, results) {
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
          reportAndHeaderData = results[0][0];
          resolve(results[0]);
        }
      }
    ); // end query
  });
}

function reportmail(res, startDate) {
  return new Promise((resolve) => {
    const sql = `call REPORT_report('RUN_REPORT',null,?,null,null,null,null,null,null,null);`;
    pool.query(sql, [res.reportId], async function (err, results) {
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
        tableContent = results[0];
        if (
          tableContent != null &&
          tableContent != undefined &&
          tableContent != ""
        ) {
          var dynamicPDF = await createDynamicPDF(startDate);
        } else {
          var dynamicPDF = "No Contet in Reports";
        }
        resolve(dynamicPDF);
        // resolve(results);
      }
    }); // end query
  });
}

function createDynamicPDF(startTime) {
  var pageSizeval;
  var marginsize = '';
  var rowData;
  let keys = Object.keys(tableContent[0]);
  let address = reportAndHeaderData.HeaderText;
  const subReportName = reportAndHeaderData.reportSubType;

  var strippedHtml = address.replace(/<[^>]+>/g, "");
  strippedHtml = strippedHtml.replace("&nbsp;", "");
  strippedHtml = strippedHtml.replace("&nbsp;", "");
  strippedHtml = strippedHtml.replace("\n\n", "\n");
  strippedHtml = strippedHtml.replace(/^\n+|\n+$/g, "");
  strippedHtml = strippedHtml + "\n\n";
  // const text = htmlToText(address, {
  //   wordwrap: 130,
  // });

  const blob = new Buffer.from(
    reportAndHeaderData.companyLogo,
    "binary"
  ).toString("base64");

  if (reportAndHeaderData.reportHeaderIncludeAddress === 0) {
    if (subReportName === "Invoice Cost Summary") {
      var logo = {
        image: "data:application/pdf;base64," + blob.toString("base64"),
        width: 200,
        margin: [100, 0, 0, 0],
      };
      var addressess = {
        text: strippedHtml,
        italics: true,
        fontSize: 10,
        margin: [100, 0, 0, 0],
      };
    } else {
      var logo = {
        image: "data:application/pdf;base64," + blob.toString("base64"),
        width: 200,
      };
      var addressess = { text: strippedHtml, italics: true, fontSize: 10 };
    }
  } else {
    var logo = "";
    var addressess = "";
  }

  let tempArray = [];
  let customer = "",
    columns = [],
    sum_data = {},
    total_sum = {};
  keys.forEach((key) => {
    if (
      !isNaN(tableContent[0][key]) &&
      key != "Ordered" &&
      key != "Billed" &&
      key != "B/O" &&
      key != "ReleaseType" &&
      key != ("Job Number"||"JobNumber")&&
      key != "Sales Engineer" &&
      key != "Costing" &&
      key != "Address1" &&
      key != "Address2" &&
      key != "City" &&
      key != "State" &&
      key != "Zip" &&
      key != "Phone1" &&
      key != "FirstName" &&
      key != "LastName" &&
      key != "JobPosition" &&
      key != "DirectLine"  &&
      key != "Cell" &&
      key != "EMail" &&
      key != ("Division" || "100_Division") &&
      key != "SalesRep" &&
      key !="BidYear" &&
      key !="BidMonth" &&
      key !="TakeOffName" &&
      key !="BidStatusDescription" &&
      key !="JobStatus" &&
      key !="CreatedBy" &&
      key !="QuoteType" && 
      key !="BidderName"&&
      key !="SalesRepName"&&
      key !="BidDate"&& 
      key !="Description"&&
      key !="QuoteNumber"&&
      key !="Code"&&
      key !="QuoteRev"&&
      key !="QuoteDate"&&
      key !="QuoteTime" &&
      key != "TakeOff" &&
      key != "Bid Status" &&
      key != "Architect" &&
      key != "Engineer" &&
      key != "Bidder Contact" &&
      key != "Bidder" &&		
      key != "Bidder Salesrep" &&
      key != "Quote Type" &&
      key != "Quoted Date" &&
      key != "Job #"
    ) {
      columns.push(key);
    }
  });

  tableContent.forEach((ele, index) => {
    if (customer !== ele[keys[0]]) {
      if (Object.keys(sum_data).length) {
        let tempData1 = { isSum: true };
        if(subReportName != "Quoted Job Details"){
        keys.forEach((tempKey) => {
          if (columns.includes(tempKey))
            tempData1[tempKey] = sum_data[tempKey];
          else tempData1[tempKey] = "";
        });
      }
        if (subReportName != "Invoice Cost Summary" && subReportName != "Quoted Job Details") {
          if (subReportName === "Invoice Cost Detail") {
            const margin = (tempData1.Profit / tempData1.InvoiceAmount) * 100;
            tempData1.Margin = margin ? margin : "0";
          }
          tempArray.push(tempData1);
          if (
            !Object.keys(total_sum).length &&
            subReportName === "Open Jobs"
          ) {
            total_sum = JSON.parse(JSON.stringify(tempData1));
          } else {
            Object.keys(total_sum).forEach(
              (ele) => (total_sum[ele] += tempData1[ele])
            );
          }
          sum_data = {};
        }
      }
      customer = ele[keys[0]];
      if (subReportName != "Inventory Backorders" && subReportName != "Quoted Job Details") {
        keys.forEach((tempKey) => {
          if (columns.includes(tempKey)) {
            sum_data[tempKey]
              ? (sum_data[tempKey] += ele[tempKey])
              : (sum_data[tempKey] = ele[tempKey]);
          }
        });
      }
    } else {
      if (subReportName != "Inventory Backorders" && subReportName != "Quoted Job Details") {
        keys.forEach((tempKey) => {
          if (columns.includes(tempKey)) {
            sum_data[tempKey]
              ? (sum_data[tempKey] += ele[tempKey])
              : (sum_data[tempKey] = ele[tempKey]);
          }
        });
      }
    }
    tempArray.push(ele);
     if(reportAndHeaderData.reportName != "ROLODEX") {
    if (subReportName != "Inventory Backorders" && subReportName != "Quoted Job Details") {
      if (index === tableContent.length - 1) {
        let tempData2 = { isSum: true };
        keys.forEach((tempKey) => {
          if (columns.includes(tempKey))
            tempData2[tempKey] = sum_data[tempKey];
          else tempData2[tempKey] = "";
        });

        if (subReportName === "Invoice Cost Summary") {
          if (tableContent.length - 1 === index) {
            const margin = (tempData2.Profit / tempData2.InvoiceAmount) * 100;
            tempData2.Margin = margin ? margin : "0";
            tempArray.push(tempData2);
          }
        } else if (subReportName === "Invoice Cost Detail") {
          const margin = (tempData2.Profit / tempData2.InvoiceAmount) * 100;
          tempData2.Margin = margin ? margin : "0";
          tempArray.push(tempData2);
          sum_data = {};
        } else {
          tempArray.push(tempData2);
          if (
            !Object.keys(total_sum).length &&
            subReportName === "Open Jobs"
          ) {
            total_sum = JSON.parse(JSON.stringify(tempData2));
          } else {
            Object.keys(total_sum).forEach(
              (ele) => (total_sum[ele] += tempData2[ele])
            );
          }
          sum_data = {};
        }
      }
    }
  }
  });
  if (subReportName === "Open Jobs") {
    tempArray.push(total_sum);
  }

  const getColumnHeader = (headerStr) => {
    const strArr = headerStr.split("_");
    let returnStr = "";

    strArr.map((itm, index) => {
      if (index > 0) {
        returnStr = strArr[1];
      } else {
        returnStr = strArr[0];
      }
    });

    return returnStr;
  };

  keys.map((head) => getColumnHeader(head));
  return new Promise((resolve) => {
    const fontDescriptors = {
      Roboto: {
        normal: path.join(
          __dirname,
          "..",
          "./",
          "routes",
          "./",
          "/fonts/Roboto-Regular.ttf"
        ),
        bold: path.join(
          __dirname,
          "..",
          "./",
          "routes",
          "./",
          "/fonts/Roboto-Medium.ttf"
        ),
        italics: path.join(
          __dirname,
          "..",
          "./",
          "routes",
          "./",
          "/fonts/Roboto-Italic.ttf"
        ),
        bolditalics: path.join(
          __dirname,
          "..",
          "./",
          "routes",
          "./",
          "/fonts/Roboto-MediumItalic.ttf"
        ),
      },
    };
    const tableHead = [];
    keys.map((head) =>
      tableHead.push({
        text: getColumnHeader(head),
        style: "tableHeader",
        border: [false, false, false, false],
      })
    );

    rowData = [tableHead];
    tempArray.map((row) =>
      rowData.push(
        keys.map((cell) => ({
          text:
            cell === keys[0]
              ? isNaN(row[cell])
                ? row[cell].substring(0, 14)
                : row[cell]
              : columns.includes(cell)
              ? cell === "Margin"
                ? percentageFormatter.format(row[cell] / 100)
                : dollerFormatter.format(row[cell]) //formatter.format(row[cell])
              : // : row[cell]
              isNaN(row[cell])
              ? row[cell].substring(0, 24)
              : row[cell],
          alignment: !isNaN(row[cell]) ? "center" : "",
          style: row.isSum ? "tableSumStyle" : "tableStyle",
          border:
            row.isSum && row[cell] !== ""
              ? [false, true, false, false]
              : [false, false, false, false],
        }))
      )
    );

    if (subReportName === "Open Jobs") {
      pageSizeval = { width: 1010, height: 900.8897637795275 };
    } else if (subReportName === "Bill Only") {
      pageSizeval = { width: 905, height: 900.8897637795275 };
    } else if (subReportName === "Inventory Backorders") {
      pageSizeval = { width: 1040, height: 900.8897637795275 };
    } else if (subReportName === "Invoice Cost Detail") {
      pageSizeval = { width: 1205, height: 900.8897637795275 };
    } else if (subReportName === "Invoice Cost Summary") {
      marginsize = [100, 0, 0, 0];
    } else if (subReportName === "Quoted Job Details"){
      pageSizeval = {width: 1040, height: 900.8897637795275};
    } else {
      pageSizeval = "";
    }
    const tableReportContent = [
      logo,
      addressess,
      {
        style: "tableStyle",
        margin: marginsize,
        table: { headerRows: 1, heights: 30, body: rowData },
      },
    ];
var style_data
    if (subReportName === "Quoted Job Details") {
      style_data = {tableHeader: {
        bold: true,
        // fontSize: 15,
        color: "black",
      }}
     } else {
        style_data = { 
          tableSumStyle: {
            bold: true,
            fontSize: 14,
            color: "black",
          },
          tableStyle: {
            fontSize: 14,
            color: "black",
          },
          tableHeader: {
            bold: true,
            fontSize: 15,
            color: "black",
          },
        }
      }

    const data = {
      pageSize: "A4",
      pageOrientation: "landscape",
      pageSize: pageSizeval,

      content: tableReportContent,
      styles: style_data,
      // { 
      //   tableSumStyle: {
      //     bold: true,
      //     fontSize: 14,
      //     color: "black",
      //   },
      //   tableStyle: {
      //     fontSize: 14,
      //     color: "black",
      //   },
      //   tableHeader: {
      //     bold: true,
      //     fontSize: 15,
      //     color: "black",
      //   },
      // },
    };

    const printer = new pdfmake(fontDescriptors);

    const doc = printer.createPdfKitDocument(data);

    const chunks = [];

    doc.on("data", function (chunk) {
      chunks.push(chunk);
    });
    doc.on("end", async function () {
      let result = Buffer.concat(chunks);
      let pdfResult = createPDF(result, startTime);
      resolve(pdfResult);
      // resolve("data:application/pdf;base64," + result.toString("base64"));
    });
    doc.end();
  });
}

const createPDF = (pdfcode, startTime) => {
  return new Promise((resolve) => {
    let createdOn = moment().format("YYYY-MM-DD HH:MM:SS");
    let currentDate = new Date().getTime();
    let loginID = reportAndHeaderData.myReportEntityId;
    let reportName = reportAndHeaderData.reportName;
    let reportFileName =
      loginID + "_" + reportName + "_" + currentDate + ".pdf";

      // for Bartos and Pennergy
      let filePath=attachmentPath + reportFileName;

    // For EMS, HD_Grant, Grant_equip, DynamicFan, PremierHVAC
    // let filePath="/usr/local/apache-tomcat-7.0.57/webapps/turbotracker/uploads/" + reportFileName;

    // For BartosUAT
    // let filePath="/usr/local/tomcat7_BartosUAT/webapps/turbotracker/uploads/" + reportFileName;
    fs.writeFile(
      filePath,
      pdfcode,
      "base64",
      function (err, res) {
        if (err) {
          console.log(err);
        } else {
          var endTime = new Date();
          let timeDuration = parseFloat(
            (endTime.getTime() - startTime.getTime()) / 1000
          ).toFixed(1);
          let updateLastRun = `update REPORT_reports set lastRun= '${createdOn}', lastRunDuration= '${timeDuration} Sec' where reportId= ${reportAndHeaderData.reportId}`;
          pool.query(updateLastRun, [], function (err, res) {
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
              resolve(res);
            }
          });
          console.log("<------PDF Created Successfully------>");
        }
      }
    );

    let sql = `insert into tsUser_global_notification (userLoginID, fromEmailId, toEmailID, subject,filename,writepdfname,createdOn,pdfType,fileAttachment1,fileAttachment2,fileAttachment3) values (?,?,?,?,  ?,?,?,?,  ?,?,?);`;
    pool.query(
      sql,
      [
        loginID,
        "info@turboproonline.com",
        reportAndHeaderData.myEmail,
        "Report : " + reportName,
        reportFileName,
        reportFileName,
        createdOn,
        "REPORT",
        filePath,
        null,
        null,
      ],
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
          resolve(results);
        }
      }
    ); // end query
  });
};

// module.exports = router;
exports.cronGenereteReports = cronGenereteReports;
console.log("exporting router from reportSendEmail.js");
