var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;

router.post("/getStandardReports", function (req, res, next) {
  console.log("<==================================================>");
  console.log("POST /reports/getStandardReports");
  const action = req.body.action ? req.body.action : null;
  const reportID = req.body.reportID ? req.body.reportID : null;

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_report(?,null,?,null,null,null,null,null,null,null);  `;
      pool.query(sql, [action, reportID], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getStandardReports ERROR ");

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
  } // end isError
}); // end POST

// ===============================================

router.post("/getMyReports", function (req, res, next) {
  console.log("<==================================================>");
  console.log("POST /reports/getMyReports");

  const _userID = req.body.userID  ? req.body.userID : "";

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_report('GET_REPORTS',?,null,null,null,null,null,null,null,null); `;
      pool.query(sql, [_userID], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getMyReports ERROR ");

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
  } // end isError
}); // end POST
//==============================================

router.post("/addStandardMyReports", function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : "";
  const _userID = req.body.userID ? req.body.userID : "";

  console.log("<==================================================>");
  console.log("POST /reports/addStandardMyReports");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_report('CLONE_REPORT',?,?,null,null,null,null,null,null,null); `;
      pool.query(sql, [_userID, _reportID], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/addStandardMyReports ERROR ");

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
  } // end isError
}); // end POST

// ===============================================

router.post("/getStandardFilterDataMyReports", function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : null;
  const _reportType = req.body.reportType ? req.body.reportType : null;

  console.log("<==================================================>");
  console.log("POST /reports/getStandardFilterDataMyReports");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_filters('GET_FILTER_DATA',null,?,?,null,null,null,null,null,null,null,null,null); `;
      pool.query(sql, [_reportID, _reportType], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getStandardFilterDataMyReports ERROR ");

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
  } // end isError
}); // end POST

// ===============================================

router.post("/getIncludeCehckboxDataMyReports", function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : null;
  const _reportType = req.body.reportType ? req.body.reportType : null;
  const _filters = req.body.filters ? req.body.filters : null;

  console.log("<==================================================>");
  console.log("POST /reports/getIncludeCehckboxDataMyReports");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_filters('GET_FILTER_TYPES',null,?,?,null,?,null,null,null,null,null,null,null); `;
      pool.query(
        sql,
        [_reportID, _reportType, _filters],
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
      ); // end query
    }); // end promise
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

    console.log("post /reports/getIncludeCehckboxDataMyReports ERROR ");

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
  } // end isError
}); // end POST
// ===============================================

router.post("/getFilterDataMyReports", function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : null;
  const _reportType = req.body.reportType ? req.body.reportType : null;

  console.log("<==================================================>");
  console.log("POST /reports/getFilterDataMyReports");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_filters('GET_FILTER_TYPES',1,?,?,null,null,null,null,null,null,null,null,null); `;
      pool.query(sql, [_reportID, _reportType], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getFilterDataMyReports ERROR ");

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
  } // end isError
}); // end POST

// ===============================================

router.post("/getReportType", function (req, res, next) {
  console.log("<==================================================>");
  console.log("POST /reports/getReportType");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_filters('GET_FILTER_TYPES',1,null,null,null,null,null,null,null,null,null,null,null); `;
      pool.query(sql, [], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getReportType ERROR ");

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
  } // end isError
}); // end POST

//============================================================

router.post("/addMyReport", function (req, res, next) {
  const _action = req.body.action ? req.body.action : "";
  const _userID = req.body.userID ? req.body.userID : "";
  const _reportType = req.body.reportType ? req.body.reportType : "";
  const _myReportName = req.body.newReportName ? req.body.newReportName : "";
  const _myScheduleType = req.body.myScheduleType ? req.body.myScheduleType : null;
  const _myEmail = req.body.myEmail ? req.body.myEmail : null;
  const _reportID = req.body.reportID ? req.body.reportID : null;
  const _myFilterValueId= req.body.myFilterValueId ? req.body.myFilterValueId: null;

  console.log("<==================================================>");
  console.log("POST /reports/addMyReport");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_report(?,?,?,?,?,?,?,null,?,null); `;
      pool.query(
        sql,
        [
          _action,
          _userID,
          _reportID,
          _reportType,
          _myReportName,
          _myFilterValueId,
          _myScheduleType,
          _myEmail,
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
            resolve("ERROR OCCURED WHILE CREATEING NEW MY REPORT");
          } else {
            resolve(results);
          }
        }
      ); // end query
    }); // end promise
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

    console.log("post /reports/addMyReport ERROR ");

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
  } // end isError
}); // end POST

//==============================================

router.post("/setFiltervalue", function (req, res, next) {
  const _action = req.body.action ? req.body.action : null;
  const _reportID = req.body.reportID ? req.body.reportID : null;
  const _reportType = req.body.reportType ? req.body.reportType : null;
  const _filterName = req.body.filterName ? req.body.filterName : null;
  const _filterID = req.body.filterID ? req.body.filterID : null;
  const _fromDate = req.body.fromDate ? req.body.fromDate : null;
  const _toDate = req.body.toDate ? req.body.toDate : null;
  const _myFilterId = req.body.myFilterId ? req.body.myFilterId : null;

  console.log("<==================================================>");
  console.log("POST /reports/setFiltervalue");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  if (_reportID == "" || _reportID == null) {
    _reportID = null;
  }
  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_filters(?,1,?,?,?,?,?,?,NULL,?,?,NULL,NULL);`;
      pool.query(
        sql,
        [
          _action,
          _reportID,
          _reportType,
          _myFilterId,
          _filterName,
          _filterID,
          null,
          _fromDate,
          _toDate,
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
    }); // end promise
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

    console.log("post /reports/setFiltervalue ERROR ");

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
  } // end isError
}); // end POST

//==============================================

router.post("/setSandardFilterValues", function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : null;
  const _array = req.body.filterObj ? req.body.filterObj : [];

  console.log("<==================================================>");
  console.log("POST /reports/setSandardFilterValues");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  if (_reportID == "" || _reportID == null) {
    _reportID = null;
  }
  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      for (let i = 0; i < _array.length; i++) {
        // if (_array[i].myFilterValueId) {
          let sql = `call REPORT_filters('UPDATE_MY_FILTER',1,?,?,null,?,?,?,NULL,?,?,NULL,NULL);`;
        pool.query(
          sql,
          [
            //_reportID,_reportType,_filterName,_filterID,null,_fromDate,_toDate
            _reportID,
            _array[i].reportType,
            _array[i].filterName,
            _array[i].myFilterValueId,
            null,
            _array[i].dateFrom,
            _array[i].dateTo,
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
        );
        // } // end query
      }
    }); // end promise
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

    console.log("post /reports/setFiltervalue ERROR ");

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
  } // end isError
}); // end POST

//==============================================

router.get("/getEndingPeriodListfortrialBalance", function (req, res, next) {
  console.log("<==================================================>");
  console.log("POST /reports/getEndingPeriodListfortrialBalance");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `select * FROM coFiscalPeriod cp  where cp.period <> 13  GROUP BY cp.endDate order by cp.coFiscalPeriodId desc`;
      pool.query(sql, [], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getEndingPeriodListfortrialBalance ERROR ");

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
  } // end isError
}); // end POST

//==============================================



router.post("/deleteMyReport", async function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : "";

  console.log("<==================================================>");
  console.log("POST /reports/deleteMyReport");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";


  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_report('DELETE_REPORT',null,?,null,null,null,null,null,null,null); `;
      pool.query(sql, [_reportID], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/deleteMyReport ERROR ");

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
  } // end isError
}); // end POST

//==============================================

router.post("/deleteMyReportCheckbox", function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : "";
  const _filterText = req.body.filterName ? req.body.filterName : "";

  console.log("<==================================================>");
  console.log("POST /reports/deleteMyReportCheckbox");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      const  sql = `call REPORT_filters('DELETE_FILTER_INCLUDE_THE_FOLLOWING',1,?,null,null,?,null,null,null,null,null,null,null); `;
      pool.query(sql, [_reportID, _filterText], function (err, results) {
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
          resolve(results, "Deleted unChecked include the following");
        }
      }); // end query
    }); // end promise
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

    console.log("post /reports/deleteMyReportCheckbox ERROR ");

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
  } // end isError
}); // end POST

//==============================================

router.get("/runReport", function (req, res, next) {
  const _reportID = req.query.reportID ? req.query.reportID : "";

  console.log("<==================================================>");
  console.log("Get /reports/runReport");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      //call REPORT_report('RUN_REPORT',null,1000,null,null,null,null,null,null,null);
      let sql = `call REPORT_report('RUN_REPORT',null,?,null,null,null,null,null,null,null); `;
      pool.query(sql, [_reportID], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/runReport ERROR ");

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
  } // end isError
}); // end POST
//========================================================================
router.post("/getHeaederData", function (req, res, next) {
  const _reportID = req.body.reportID ? req.body.reportID : "";

  console.log("<==================================================>");
  console.log("POST /reports/getHeaederData");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      let sql = `call REPORT_report('RUN_REPORT',null,?,null,null,null,null,null,null,null); `
      pool.query(sql, [_reportID], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getHeaederData ERROR ");

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
  } // end isError
}); // end POST
//====================================================================

router.post("/getJobNumber", function (req, res, next) {
  const searchVal = req.body.jobNumVal ? req.body.jobNumVal : "";

  console.log("<==================================================>");
  console.log("POST /reports/getJobNumber");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      // var sql = `select JobNumber from joMaster `
      let sql = `select JobNumber from joMaster where JobNumber like "%${searchVal}%" order by JobNumber asc`;
      pool.query(sql, [], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getJobNumber ERROR ");

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
  } // end isError
}); // end POST
//====================================================================

router.get("/get_ReportType", function (req, res, next) {
  // var _reportID = req.body.reportID ? req.body.reportID : "";

  console.log("<==================================================>");
  console.log("POST /reports/get_ReportType");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      // var sql = `call REPORT_report('RUN_REPORT',null,?,null,null,null,null,null,null,null); `;
      const sql = `call REPORT_report('GET_REPORT_TYPE',null,null,null,null,null,null,null,null,null); `;
      pool.query(sql, [], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/get_ReportType ERROR ");

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
  } // end isError
}); // end POST
//====================================================================

router.post("/getLoggedUserDetails", function (req, res, next) {
  const _userID = req.body.userID ? req.body.userID : null;

  console.log("<==================================================>");
  console.log("POST /reports/getLoggedUserDetails");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      // var sql = `call REPORT_report('RUN_REPORT',null,?,null,null,null,null,null,null,null); `;
      let sql = `select * from tsUserLogin where UserLoginID = ${_userID}`;

      pool.query(sql, [], function (err, results) {
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
      }); // end query
    }); // end promise
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

    console.log("post /reports/getLoggedUserDetails ERROR ");

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
  } // end isError
});
//====================================================================

console.log("exporting router from reports.js");

module.exports = router;
