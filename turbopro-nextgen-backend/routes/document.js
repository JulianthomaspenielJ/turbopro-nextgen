var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;
const uploadFileToS3 = require("../helper/uploadFile").uploadFileToS3;
const deleteFileFromS3 = require("../helper/uploadFile").deleteFile;
const multer = require("multer");
const upload = multer();
const fs = require("fs");
const path = require("path");
const { getSignedUrl,getfilesize } = require("../helper/uploadFile");

var sql = "";
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

// ===============================================

// @route   GET /document
// @desc    get document info
// @access  Private/Public
router.get("/list", async function (req, res, next) {
  const action = req.query.action || "GET";
  const userId = req.query.userId || null;
  const name = req.query.document_name;
  const description = req.query.description;
  const extension = req.query.extension;
  const docStorageProvider = req.query.docStorageProvider;
  const uri = req.query.uri;

  const documentId = req.query.documentId || null;
  const clientId = req.query.clientId || null;
  const contractId = req.query.contractId || null;
  const orderId = req.query.orderId || null;
  const entityId = req.query.entityId || null;

  const recruitId = req.query.recruitId || null;
  const contactId = req.query.contactId || null;
  const worklogId = req.query.worklogId || null;
  const presentationId = req.query.presentationId || null;

  const debug = req.query.debug || null;

  let result = [];

  /*
  call DOCUMENT_document(action,_userId, _documentId,_clientId,_contractId,_orderId,_entityId, _recruitId,_contactId,_worklogId,presentationid,_docTypeId, 
	  _extension,_description,_name,_uri,_version, _syncLog,_documentLimit, _DEBUG);
*/

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    let SQL =
      "call DOCUMENT_document(?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?, ?, ?)";
    console.log("SQL --->", SQL, req.query);

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          documentId,
          name,
          description,
          extension,
          docStorageProvider,
          uri,

          userId,

          null,
          clientId,
          contractId,
          orderId,
          entityId,

          recruitId,
          contactId,
          worklogId,
          presentationId,
          null,

          null,

          null,
          debug,
        ],
        (err, result) => {
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
            resolve(result[0]);
          }

                // res.send(result[0]);

        }
      );
    });
  };

  if (isInError == 0) {
    // if (type) {
      try {
        result = await sqlFunction();
        res.send(result)

      } catch(err) {
        res.end(err)

      }
    // }

    // getHeaderNode(isErrorCode, isErrorMsg)
    //   .then((header) => {
    //     let response = {
    //       header: header,
    //       results: result,
    //     };
    //     res.send(response);
    //   })
    //   .catch((err) => {
    //     res.send(err);
    //   }).err((e) => {
    //     console.log(e)
    //   })
  } else {
    // end isError
    console.log("get /document/list ERROR ");
    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } // end isError
});

router.post("/preview", async function (req, res, next) {
  const action = req.query.action || "GET";
  const userId = req.query.userId || null;
  const name = req.query.document_name;
  const description = req.query.description;
  const extension = req.query.extension;
  const docStorageProvider = req.query.docStorageProvider;
  const uri = req.query.uri;

  const documentId = req.query.documentId || null;
  const clientId = req.query.clientId || null;
  const contractId = req.query.contractId || null;
  const orderId = req.query.orderId || null;
  const entityId = req.query.entityId || null;

  const recruitId = req.query.recruitId || null;
  const contactId = req.query.contactId || null;
  const worklogId = req.query.worklogId || null;
  const presentationId = req.query.presentationId || null;

  const debug = req.query.debug || null;

    isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    let SQL =
      "call DOCUMENT_document(?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?, ?, ?)";
    console.log("SQL --->", SQL, req.query);

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          documentId,
          name,
          description,
          extension,
          docStorageProvider,
          uri,

          userId,

          null,
          clientId,
          contractId,
          orderId,
          entityId,

          recruitId,
          contactId,
          worklogId,
          presentationId,
          null,

          null,

          null,
          debug,
        ],
        (err, result) => {
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
            resolve(result[0]);
          }

                // res.send(result[0]);

        }
      );
    });
  };

  if (isInError == 0) {
    // if (type) {
      try {
        result = await sqlFunction();

        if (result) {
          const fileName = result.find(e=> e.documentId === +documentId)?.document_uri;
          try {
            await getSignedUrl(fileName).then((response) => {
            res.send(response)
          }).catch((err) => {console.log(err)})
          } catch(err) {
            console.log(err)
            res.send(err)
          }
        }
      } catch(err) {
        res.end(err)
      }
    // }

    // getHeaderNode(isErrorCode, isErrorMsg)
    //   .then((header) => {
    //     let response = {
    //       header: header,
    //       results: result,
    //     };
    //     res.send(response);
    //   })
    //   .catch((err) => {
    //     res.send(err);
    //   }).err((e) => {
    //     console.log(e)
    //   })
  } else {
    // end isError
    console.log("get /document/list ERROR ");
    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } // end isError
})


// ===============================================

// @route   POST /document/update
// @desc    get update
// @access  Private/Public
router.post("/update", upload.single("file"), async function (req, res, next) {
  console.log("starting /document/update -->", "req queries: ", req.body);
  const action = req.body.action || "CREATE";
  const userId = req.body.userId || null;
  const jobNumber = req.body.jobNumber || null;

  const documentId = req.body.documentId || null;
  // const joMasterID = req.body.joMasterID || null;
  const joReleaseID = req.body.joReleaseID || null;
  const vePOID = req.body.vePOID || null;
  const cuSOID = req.body.cuSOID || null;

  const cuInvoiceID = req.body.cuInvoiceID || null;
  const veBillID = req.body.veBillID || null;
  const rxMasterID = req.body.rxMasterID || null;
  const rxContactID = req.body.rxContactID || null;
  const docTypeId = req.body.docTypeId || null;
  const joQuoteHeaderID = req.body.joQuoteHeaderID || null;
  const docRelatedTo = req.body.docRelatedTo || null;
  const bucketType  = req.body.bucketType  || "DOCUMENTS"

  let extension = null;
  let description = null;
  let name = null;
  let uri = req.body.uri || null;
  const version = req.body.version || null;

  const debug = req.body.debug || null;
  const file = req.file || null;
  const docStorageProvider = req.body.docStorageProvider || "S3";

    let getJoMasterID = async function() {
    return new Promise((resolve, reject) => {
    let sql = `select joMasterID from joMaster where JobNumber = "${jobNumber}"`;
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
        resolve(results[0].joMasterID);
      }
    }); // end query
  })
  }

  try {
    var output
    if(jobNumber || joReleaseID){
      output = await getJoMasterID();
    }
    const joMasterID = output || null;

    if (file) {
      const fileresult = await uploadFileToS3(file,bucketType);
  
      if (fileresult["Location"] != null) {
        uri = fileresult["Location"];
        let fileResultKey = fileresult["key"] || fileresult["Key"] || "";
        var fresultArr = fileResultKey.split("/");
        description =
          req.body.description || fresultArr[fresultArr.length - 1] || null;
        name = fresultArr[fresultArr.length - 1] || null;
        extension = name.split(".")[1];
      }
    }

    let result = [];
  
    /*
   call DOCUMENT_document(_action,_documentId,_document_docTypeId,_document_name,_document_description,_document_extension,
    _document_storage_provider,_document_uri,_joMasterID,_joReleaseID,_vePOID,_cuSOID,_cuInvoiceID,_veBillID,_rxMasterID,_rxContactID,
    _joQuoteHeaderID,_document_version,_document_relatedTo,_updateById,_DEBUG);
  
  */
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    let sqlFunction = function () {
      let SQL =
        "call DOCUMENT_document(?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?, ?, ?)";
      console.log("SQL --->", SQL, req.query);
  
      return new Promise((resolve, reject) => {
        pool.query(
          SQL,
          [
            action,
            documentId,
            docTypeId,
            name,
            description,
            extension,
            docStorageProvider,
            uri,
            joMasterID,
  
            joReleaseID,
            vePOID,
            cuSOID,
            cuInvoiceID,
            veBillID,
  
            rxMasterID,
            rxContactID,
            joQuoteHeaderID,
            version,
  
            docRelatedTo,
  
            1,
            debug,
          ],
          (err, result) => {
            if (err) {
              console.log("error:", err);
              isInError = 1;
              isErrorCode = "FILTER_ERROR";
              if (err.sqlState == 41001) {
                isErrorMsg = "Make sure to provide your login.";
              } else {
                isErrorMsg =
                  err.sqlState +
                  ": We had difficulty performing this action.  Pleae report his number to your contact.";
              }
              resolve("");
            } else {
              resolve(result[0]);
            }
          }
        );
      });
    };
  
    if (isInError == 0) {
      // if (type) {
        try {
          result = await sqlFunction();
          res.send(result)
        } catch(err) {
          res.send(err)
        }
      // }
  
      // getHeaderNode(isErrorCode, isErrorMsg)
      //   .then((header) => {
      //     let response = {
      //       header: header,
      //       results: result,
      //     };
      //     res.send(response);
      //   })
      //   .catch((err) => {
      //     res.send(err);
      //   });
    } else {
      // end isError
      console.log("get /document/list ERROR ");
      getHeaderNode(isErrorCode, isErrorMsg)
        .then((header) => {
          let response = {
            isErrorMsg: isErrorMsg,
          };
          res.send(response);
        })
        .catch((err) => {
          res.send(err);
        });
    } // end isError
  } catch(err) {
    console.log(err)
  }
});

// SEARCH document
router.post("/search", async function (req, res, next) {
  console.log("starting /document/search -->", "req queries: ", req.body);

  const action = "SEARCH";
  const name = req.body.documentName || null;
  const jobNumber = req.body.jobNumber || null;
  const jobName = req.body.jobName || null;
  const rolodexId = req.body.rolodexId || null;
  const tsUserId = req.body.tsUserId || null;
  const debug = req.body.debug || null;

  var jobnumber1 =null;

  if (jobNumber != null && jobNumber != undefined && jobNumber != "") {
    jobnumber1 = jobNumber.trim();
  }
  
  console.log(jobnumber1);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    let SQL =
      "call DOCUMENT_search(?,?, ?,?,?,?,?)";
    console.log("SQL --->", SQL, req.body);

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          name,
          jobnumber1,
          jobName,
          rolodexId,
          tsUserId,
        
          null,
        ],
        (err, result) => {
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
            result.map((res) => {
              console.log(res)
            })
            let output = Object.values(result[0].reduce((acc,cur)=>Object.assign(acc,{[cur.documentId]:cur}),{}));
            resolve(output);
          }
        }
      );
    });
  };

  if (isInError == 0) {
    // if (type) {
      try {
        result = await sqlFunction();
        res.send({"results": result})
      } catch(err) {
        res.end(err)
      }
    // }

    // getHeaderNode(isErrorCode, isErrorMsg)
    //   .then((header) => {
    //     let response = {
    //       header: header,
    //       results: result,
    //     };
    //     res.send(response);
    //   })
    //   .catch((err) => {
    //     res.send(err);
    //   }).err((e) => {
    //     console.log(e)
    //   })
  } else {
    // end isError
    console.log("get /search ERROR ");
    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } // end isError
})

// ===============================================

// @route   POST /document/updateDoc
// @desc    get update
// @access  Private/Public
router.post("/updateDoc", async function (req, res, next) {
  console.log("starting /document/updateDoc -->", "req queries: ", req.body);
  const action = "UPDATE";
  const userId = req.body.userId || null;

  const documentId = req.body.documentId || null;
  const clientId = req.body.clientId || null;
  const contractId = req.body.contractId || null;
  const orderId = req.body.orderId || null;
  const entityId = req.body.entityId || null;

  const recruitId = req.body.recruitId || null;
  const contactId = req.body.contactId || null;
  const worklogId = req.body.worklogId || null;
  const presentationId = req.body.presentationId || null;
  const docTypeId = req.body.docTypeId || null;

  const extension = req.body.extension || null;
  const description = req.body.description || null;
  const document_name = req.body.name || null;
  const uri = req.body.uri || null;
  const version = req.body.version || null;
  const docStorageProvider = req.body.docStorageProvider || null;
  const file = req.file || null;
  const debug = req.body.debug || null;

  let result = [];
  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    let SQL =
      "call DOCUMENT_document(?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?, ?, ?)";
    console.log("SQL --->", SQL, req.query);
    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          "UPDATE",documentId, null,document_name,null,null,null, null,null,null,null,null, null,null,null,null,null, null,null, null, null
        ],
        (err, result) => {
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
            resolve(result[0]);
          }
        }
      );
    });
  };

  if (isInError == 0) {
    result = await sqlFunction();
    if (file) {
      let isValidName = /^[\w,\s-]+\.[A-Za-z]{2,4}$/.test(file);

      if (isValidName) {
        const isExist = (await fs.existsSync(filePath)) || false;

        if (isExist) {
          let readStream = fs.createReadStream(filePath);

          if (readStream && _type) {
            const file = {
              originalname: _fileName,
              buffer: readStream,
              mimetype: _type,
            };

            const result = await uploadFileToS3(file);

            if (result && result.Location) {
              await getDocuments("UPDATE_DOCUMENT_URI", {
                documentId: documentId,
                uri: result.Location,
              });
            }
          }
        } else {
          console.log(" --------------> FILE DOESN'T EXIST");

          await getDocuments("UPDATE_DOCUMENT_URI", {
            documentId: documentId,
            syncLog: "FILE DOESN'T EXIST",
          });
        }
      } else {
        console.log(" --------------> INVALID FILE NAME");

        await getDocuments("UPDATE_DOCUMENT_URI", {
          documentId: documentId,
          syncLog: "INVALID FILE NAME",
        });
      }
    } else {
      console.log(" --------------> FILE NAME CANNOT BE NULL/EMPTY");

      await getDocuments("UPDATE_DOCUMENT_URI", {
        documentId: documentId,
        syncLog: "FILE NAME IS NULL/EMPTY",
      });
    }
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
  } else {
    // end isError
    console.log("get /document/list ERROR ");
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

// ===============================================

// @route   POST /document/upload-documents
// @desc    upload file
// @access  Private/Public

router.post("/upload-documents", async function (req, res, next) {
  const _limit = req.query.limit || "100";

  const mimetype = {
    pdf: "application/pdf",
    doc: "application/msword",
    docx: "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    txt: "text/plain",
    xls: "application/vnd.ms-excel",
    xlsx: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
  };

  const documentsArr =
    (await getDocuments("GET_DOCUMENTS", { limit: _limit })) || [];

  if (documentsArr && documentsArr.length > 0) {
    for (let i = 0; i < documentsArr.length; i++) {
      let document = documentsArr[i];

      if (document && document.document_extension) {
        let _documentId = document.documentId;
        let _type =
          (document.document_extension &&
            mimetype[document.document_extension.toLowerCase()]) ||
          "";
        let _fileName = document.document_name || null;
        // let _dirname = getDirString(document.document_legacyPath);
        let _dirname = document.document_legacyPath;
        let filePath = path.join(_dirname, _fileName);

        console.log(" --------------> ", filePath);

        if (_fileName) {
          let isValidName = /^[\w,\s-]+\.[A-Za-z]{2,4}$/.test(_fileName);

          if (isValidName) {
            const isExist = (await fs.existsSync(filePath)) || false;

            if (isExist) {
              let readStream = fs.createReadStream(filePath);

              if (readStream && _type) {
                const file = {
                  originalname: _fileName,
                  buffer: readStream,
                  mimetype: _type,
                };

                const result = await uploadFileToS3(file);

                if (result && result.Location) {
                  await getDocuments("UPDATE_DOCUMENT_URI", {
                    documentId: _documentId,
                    uri: result.Location,
                  });
                }
              }
            } else {
              console.log(" --------------> FILE DOESN'T EXIST");

              await getDocuments("UPDATE_DOCUMENT_URI", {
                documentId: _documentId,
                syncLog: "FILE DOESN'T EXIST",
              });
            }
          } else {
            console.log(" --------------> INVALID FILE NAME");

            await getDocuments("UPDATE_DOCUMENT_URI", {
              documentId: _documentId,
              syncLog: "INVALID FILE NAME",
            });
          }
        } else {
          console.log(" --------------> FILE NAME CANNOT BE NULL/EMPTY");

          await getDocuments("UPDATE_DOCUMENT_URI", {
            documentId: _documentId,
            syncLog: "FILE NAME IS NULL/EMPTY",
          });
        }
      }
    }
  }
});

// const getDirString = (str) => {
//   let path = str || "";

//   if (path) {
//     if (path.indexOf("|") > -1) {
//       path = path.substring(0, path.indexOf("|"));
//     }

//     if (path.indexOf(":") === 1) {
//       path = path.substring(0, 2) + "\\" + path.substring(2);
//     }
//   }

//   return path;
// };

async function getDocuments(action, data = null) {
  const SQL =
    "call DOCUMENT_document(?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?, ?, ?)";

  const documentId = (data && data.documentId) || null;
  const uri = (data && data.uri) || "";
  const syncLog = (data && data.syncLog) || null;
  const limit = (data && data.limit) || "100";

  return new Promise((resolve, reject) => {
    pool.query(
      SQL,
      [
        action,
        null,

        documentId,
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
        uri,
        null,

        syncLog,
        limit,

        null,
        null
      ],
      (err, result) => {
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
          resolve(err);
        } else {
          resolve(result[0]);
        }
      }
    );
  });
}

router.delete('/delete',  async function (req, res, next) {
  const action = req.query.action || "DELETE";
  const documentId = req.query.documentId;

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function (action) {
    let SQL =
      "call DOCUMENT_document(?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?, ?, ?)";
    console.log("SQL --->", SQL, req.query);

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          documentId,
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
          null,
        ],
        (err, result) => {
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
            reject(err);
          } else {
            console.log(result)
            resolve(result);
          }
        }
      );
    });
  };

  if (isInError == 0) {
    try {
      let result = await sqlFunction();
      console.log(result)

      if (result && result[0]) {
        var fileName = result[0].document_uri.split("/").pop();
        if (fileName) {
          try {
            deleteFileFromS3(fileName);
          } catch(err) {
            console.log(err);
            isInError = 1;
            isErrorCode = "FILE_DELETE_ERROR";
            isErrorMsg =
              "We had difficulty deleting the file. Pleae report this number to your contact.";
          }
        }
      }

      if (isInError == 0) {
        try {
          result = await sqlFunction(action);
          res.send(result)
        } catch(err) {
          console.log(err)
          res.write(err)
        }
      } else {
        console.log("get /document/list ERROR ");
        getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
          if (err) {
            res.send(err);
          } else {
            res.send(response);
          }
        });
      }
    } catch(err) {
      console.log(err)
      res.write(err)
    }
  } else {
    console.log("get /document/list ERROR ");
    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
			if (err) {
				res.send(err);
			} else {
				var response = {
					isErrorMsg: isErrorMsg
				}
				res.send(response);
			}
		});
  }
});


// ===============================================

// @route   GET / doc_Type
// @desc    get doc Type 
// @access  Private/Public
router.get("/doc_type", async function (req, res, next) {
  console.log("<==================================================>");
  console.log("POST /documents/doc_type");

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";
  var firstFunction = function () {
    return new Promise((resolve, reject) => {
      const sql = `select * from DOC_types`;
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

    console.log("get /reports/get_ReportType ERROR ");

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

// ===============================================

// @route   POST /document/check-job-number
// @desc    Check for Job Number 
// @access  Private/Public
router.post("/check-job-number", async function (req, res, next) {
  const jobNumber = req.body.jobNumber || null;
  const rxMasterID = req.body.rolodexId || null;

  let getJoMasterID = async function () {
    return new Promise((resolve, reject) => {
      let sql = `SELECT COUNT(*) AS joMasterID FROM joMaster WHERE JobNumber = "${jobNumber}"`
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
          resolve(results[0].joMasterID);
        }
      }); // end query
    })
  }
  let getRxMasterID = async function () {
    return new Promise((resolve, reject) => {
      let sql = `SELECT COUNT(*) AS rxMasterID from rxMaster where rxMasterID = "${rxMasterID}"`;
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
          resolve(results[0].rxMasterID);
        }
      }); 
    })
  }

  try {
    if(jobNumber){
      var output = await getJoMasterID();
      console.log("output",output)
    } else if(rxMasterID){
      var rxMaster = await getRxMasterID();
      console.log("output",rxMaster)
    }
    result = {joMasterID: output,rxMasterID : rxMaster }  ;
    console.log("result",result) ;
    res.send(result);
  } catch(err) {
    res.send(err);
    console.log(err)
  }
});

// SEARCH document
router.get("/document-search", async function (req, res, next) {
  const action = req.query.action || "GET";
  const jobNumber = req.query.jobNumber || null;

  let getJoMasterID = async function () {
    return new Promise((resolve, reject) => {
      let sql = `select joMasterID from joMaster where JobNumber = "${jobNumber}"`;
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
          resolve(results[0].joMasterID);
        }
      });
    })
  }

  try {
    var output = await getJoMasterID();
    const joMasterID = output || null;

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";

    let sqlFunction = function () {
      let SQL =
        "call DOCUMENT_document(?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?, ?,?, ?, ?)";
      console.log("SQL --->", SQL, req.query);
      
      return new Promise((resolve, reject) => {
        pool.query(
          SQL,
          [
            action,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            joMasterID,
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
          ],
          (err, result) => {
            if (err) {
              console.log("error:", err);
              isInError = 1;
              isErrorCode = "FILTER_ERROR";
              if (err.sqlState == 41001) {
                isErrorMsg = "Make sure to provide your login.";
              } else {
                isErrorMsg =
                  err.sqlState +
                  ": We had difficulty performing this action.  Pleae report his number to your contact.";
              }
              resolve("");
            } else {
              Promise.all(result[0].map(async (res) => {
                let size = await getfilesize(res.document_uri);
                res.size = size;
                console.log(size);
                return res;
              }))
                .then((updatedResult) => {
                  let output = Object.values(updatedResult.reduce((acc, cur) => Object.assign(acc, { [cur.documentId]: cur }), {}));
                  resolve(output);
                })
                .catch((error) => {
                  reject(error);
                });
            }
          }
        );
      });
    };

    if (isInError == 0) {
      try {
        result = await sqlFunction();
        res.send({"results": result})
      } catch (err) {
        res.send(err)
      }
    } else {
      console.log("get /document/list ERROR ");
      getHeaderNode(isErrorCode, isErrorMsg)
        .then((header) => {
          let response = {
            isErrorMsg: isErrorMsg,
          };
          res.send(response);
        })
        .catch((err) => {
          res.send(err);
        });
    }
  } catch (err) {
    console.log(err)
  }
})

router.get("/getJobNumber", async function (req, res, next) {
  const joReleaseId = req.query.joReleaseId || null;
  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = async function () {
    return new Promise((resolve, reject) => {
      let sql = `SELECT jm.JobNumber FROM joRelease jo LEFT JOIN joMaster jm ON jo.joMasterId = jm.joMasterId WHERE jo.joReleaseId =${joReleaseId}`;
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
          resolve(results[0].JobNumber);
        }
      });
    })
  }

  try {
    if (isInError == 0) {
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
    } else {
      console.log("get /document/list ERROR ");
      getHeaderNode(isErrorCode, isErrorMsg)
        .then((header) => {
          let response = {
            isErrorMsg: isErrorMsg,
          };
          res.send(response);
        })
        .catch((err) => {
          res.send(err);
        });
    }
  } catch (err) {
    console.log(err)
  }
})

module.exports = router;