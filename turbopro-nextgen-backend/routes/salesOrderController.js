var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;
const fs = require("fs");
const moment = require('moment')


var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";


// ===============================================


router.post('/updateSalesOrder', function(req, res, next) {
    var _action = (req.body.action ? req.body.action : null); 
      var _userId = (req.body.userId ? req.body.userId : null);
      var _array = (req.body.array ? JSON.parse(req.body.array) : []); 
    console.log(_array)
       
      console.log('<==================================================>');
      console.log("POST /salesOrderController/updateSalesOrder", req.body);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise(async(resolve, reject) => {      
                  for(let i=0 ; i < _array.length ; i++){
                      await new Promise((resolve, reject) => {
                          sql = 'call INV_updateInventoryOH(?,null,null,null,null,null,null,null,null,?,null,?)'
                         pool.query(sql,[_action,_array[i],_userId],function (err, results) {
                          if(err) {
                            console.log("error:",err);
                          isInError =1;
                          isErrorCode =  "FILTER_ERROR";
                          if (err.sqlState==41001){
                          isErrorMsg = "Make sure to provide your login.";
                          }
                          else {
                          isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
                          }
                          resolve("");  
                          }else{
                            resolve(results[0])
                          }
                        });  
          
                      })
                  }  
                  resolve("");  
          }); // end promise
          }); 
  
  
      var main = async function() {
  
          var first = await (firstFunction());
  
              getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
              if(err){
                  res.send(err);
              }else{
                  var response = {
                  header : header,
                  results : first
                  }                    
                  res.send(response);
              }
          });
  
      }; // end MAIN
  
  
    if (isInError == 0) {
  
      main();
    
    } else { // end isError
   
      console.log("post /salesOrderController/updateSalesOrder ERROR ");
  
         getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
          if(err){
            res.send(err);
          }else{
            var response = {
              isErrorMsg : isErrorMsg
            }                    
            res.send(response);
          }
        });
    
    } // end isError
  
    }); // end POST




    // ===============================================


router.post('/deleteSalesOrder', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null); 
    var _userId = (req.body.userId ? req.body.userId : null);
    var _array = (req.body.array ? JSON.parse(req.body.array) : []); 
  console.log(_array)
     
    console.log('<==================================================>');
    console.log("POST /salesOrderController/deleteSalesOrder", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise(async(resolve, reject) => {      
                for(let i=0 ; i < _array.length ; i++){
                    await new Promise((resolve, reject) => {
                        sql = 'call INV_updateInventoryOH(?,null,null,null,null,null,null,?,null,?,null,?)'
                       pool.query(sql,[_action,0,_array[i],_userId],function (err, results) {
                        if(err) {
                          console.log("error:",err);
                        isInError =1;
                        isErrorCode =  "FILTER_ERROR";
                        if (err.sqlState==41001){
                        isErrorMsg = "Make sure to provide your login.";
                        }
                        else {
                        isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
                        }
                        resolve("");  
                        }else{
                          resolve(results[0])
                        }
                      });  
        
                    })
                }  
                resolve("");  
        }); // end promise
        }); 


    var main = async function() {

        var first = await (firstFunction());

            getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
            if(err){
                res.send(err);
            }else{
                var response = {
                header : header,
                results : first
                }                    
                res.send(response);
            }
        });

    }; // end MAIN


  if (isInError == 0) {

    main();
  
  } else { // end isError
 
    console.log("post /salesOrderController/deleteSalesOrder ERROR ");

       getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
        if(err){
          res.send(err);
        }else{
          var response = {
            isErrorMsg : isErrorMsg
          }                    
          res.send(response);
        }
      });
  
  } // end isError

  }); // end POST
// ===================================================


  router.get("/GetPdfFile", function(req, res, next) {
    var _action = (req.query.action ? req.query.action : null); 
    var _cusoID = (req.query.cusoID ? req.query.cusoID : null);
    var _debug = (req.query.debug ? req.query.debug : null);
 
   console.log("<==================================================>");
   console.log("get /salesOrderController/GetPdfFile", req.query);

   
  const pathDate = moment(new Date()).format("YYYY-MM-DD")
   const path = '/root/TurboPro-Backend/node-logs/pickTicketLogs_'+pathDate+'.txt'
  //  const path = 'D:/TurboPro_projects/test_'+pathDate+'.txt'
   const currentDate = moment(new Date()).format("YYYY-MM-DD hh:mm:ss")
   try { 
    fs.writeFileSync(path, currentDate+ "\n" ,{flag: 'a+'})
   fs.writeFileSync(path, JSON.stringify(req.query)+"\n\n",{flag: 'a+'}); 
   console.log("File has been saved."); 
   } catch (error) { 
   console.error(err); 
   } 
    
   isInError = 0;
   isErrorMsg = "";
   isErrorCode = "";
 
   var firstFunction = function() {
     return new Promise((resolve, reject) => {
       sql = "call INV_createPickTicket_v2(?,?,?)";	 
       pool.query(sql, [_action, _cusoID,_debug], function(err, results) {
        if(err) {
          console.log("error:",err);
          isInError =1;
          isErrorCode =  "FILTER_ERROR";
          if (err.sqlState==41001){
            isErrorMsg = "Make sure to provide your login.";
          }
          else {
          isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
          }
          resolve("");  
        }else{
          resolve(results[0])
        }
       }); // end query
     }); // end promise
   };
 
   var main = async function() {
     var first = await firstFunction();
 
     getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
       if (err) {
         res.send(err);
       } else {
         var response = {
           header: header,
           results: first
         };
         res.send(response);
       }
     });
   }; // end MAIN
 
   if (isInError == 0) {
     main();
   } else {
     // end isError
 
     console.log("get /salesOrderController/GetPdfFile ERROR ");
 
     getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
       if (err) {
         res.send(err);
       } else {
         var response = {
           isErrorMsg: isErrorMsg
         };
         res.send(response);
       }
     });
   } // end isError
 }); // end POST
 
 // ===============================================
 
 router.post("/deleteSO", function (req, res, next) {
  var _action = req.body.action ? req.body.action : null;
  var _cuSODetailArray = req.body.cuSODetailArray ? JSON.parse(req.body.cuSODetailArray) : [];
  var _debug = req.body.debug ? req.body.debug : null;

  console.log("<==================================================>");
  console.log("get /salesOrderController/deleteSO", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function () {
    return new Promise(async (resolve, reject) => {
      for (var i = 0; i < _cuSODetailArray.length; i++) {
        await new Promise((resolve, reject) => {
          sql = "call INV_createPickTicket_v2(?,?,?)";
          pool.query(
            sql,
            [_action, _cuSODetailArray[i], _debug],
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
        }); // end query
      }
      resolve("");
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

    console.log("get /salesOrderController/deleteSO ERROR ");

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


 router.post('/updatevePOIDSalesOrder', function(req, res, next) {
// let {vsr1, var2} = req.body
let {vePOID, cusoDetailId} = req.body
   const sql=`update cuSODetail set vePOID=? where cuSODetailID=?`;
   pool.query(sql,[vePOID,cusoDetailId],function(err,result){
  if(err){
    res.send(err);
  }else{
    res.send(result)
  }
   })
  }); // end POST

  // ===============================================

  router.post('/selectvePO',function(req,res,next){
    let {vePOID}=req.body
    console.log(vePOID);
     const cmd=`SELECT vp.*,rx.Name FROM vePO  vp 
     left join rxMaster rx  on vp.rxVendorID = rx.rxMasterID
     where vePOID=?`
      pool.query(cmd,[vePOID],function(err,result){
        if(err){
          console.log(err)
          res.send(err);
        }else{
          console.log(result)
          res.send(result);
        }
      })
    })  //END POST

    //==================================[]

    router.post('/isSalesOrder',function(req,res,next){
      let {PONumber,isSalesOrder}=req.body
      const sql= `select count(*) as count from vePO  where PONumber=? and isSalesOrder = ? group by PONumber`
        pool.query(sql,[PONumber,isSalesOrder],function(err,result){
          if(err){
            console.log(err)
            res.send(err);
          }else{
            console.log(result)
            res.send(result);
          }
        })
      })
    
    router.post('/getCuSoDetail', function (req, res, next) {
    const _cuSoDetailId = req.body.cusoDetailId ? req.body.cusoDetailId : 0;
    
    const sql = `SELECT SO.cuSODetailID, SO.cuSOID, SO.prMasterID, SO.Description AS description, SO.QuantityOrdered AS quantityOrdered, SO.Taxable AS taxable, SO.UnitCost AS unitCost, 
      SO.PriceMultiplier AS priceMultiplier, pr.ItemCode AS note, cuso.TaxTotal, SO.Note FROM cuSODetail SO Left Join prMaster pr on SO.prMasterID = pr.prMasterID
      Right Join cuSO cuso on cuso.cuSOID = SO.cuSOID where SO.cuSODetailID =  ${_cuSoDetailId} `;
    
    pool.query(sql, [], function (err, result) {
    if (err) {
      console.log(err);
      res.send(err);
    } else {
      console.log(result);
      res.send({ rows: result });
    }
    })
    })
 // ===============================================
 
router.post("/getInvTransactionStatus", function (req, res, next) {
  let _action = req.body.action ? req.body.action : null;
  let _cusoID = req.body.cusoid ? req.body.cusoid : null


  console.log("<==================================================>");
  console.log("post /salesOrderController/getInvTransactionStatus", req.body);
  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = (function () {
    return new Promise((resolve, reject) => {

      let sql = 'call INVOICE_updateInvoice(?,null,?, null, null, null, null, null,null,null, null,null,null, null, null, null, null, null, null,null, null, null, null, null, null,1,null,null,null,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL );'
      pool.query(sql, [_action, _cusoID], function (err, results) {
        if (err) {
          console.log("error:", err);
          isInError = 1;
          isErrorCode = "FILTER_ERROR";
          if (err.sqlState == 41001) {
            isErrorMsg = "Make sure to provide your login.";
          }
          else {
            isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
          }
          resolve("");

        } else {
          resolve(results[0]);
        }

      }); // end query
    }); // end promise
  });


  var main = async function () {

    var first = await (firstFunction());

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          results: first
        }
        res.send(response);
      }
    });

  }; // end MAIN


  if (isInError == 0) {

    main();

  } else { // end isError

    console.log("post /salesOrderController/getInvTransactionStatus ERROR ");

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

  } // end isError
});

 // ===============================================

router.get("/getTransactionStatus", function (req, res, next) {
  var cusoid = (req.query.cuSOID ? req.query.cuSOID : null); 

  console.log('<==================================================>');
  console.log("POST /salesOrderController/getTransactionStatus", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = (function () {
    return new Promise((resolve, reject) => {

      let sql = `select TransactionStatus as _TransactionStatus from cuSO where cuSOID = ${cusoid} `
      pool.query(sql, [], function (err, results) {
        if (err) {
          console.log("error:", err);
          isInError = 1;
          isErrorCode = "FILTER_ERROR";
          if (err.sqlState == 41001) {
            isErrorMsg = "Make sure to provide your login.";
          }
          else {
            isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
          }
          resolve("");

        } else {
          resolve(results[0]);
        }

      }); // end query
    }); // end promise
  });


  var main = async function () {

    var first = await (firstFunction());

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          results: first
        }
        res.send(response);
      }
    });

  }; // end MAIN


  if (isInError == 0) {

    main();

  } else { // end isError

    console.log("post /salesOrderController/getTransactionStatus ERROR ");

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

  } // end isError
});

//====================================================
router.post('/updaterxMasterCategory', function (req, res, next) {
  console.log('<==================================================>');
  console.log("POST /salesOrderController/updaterxMasterCategory", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var rolodexNumber = req.body.rolodexNumber;
  var action_type = req.body.action_type;
  // var userID = req.body.userID;
  var cuAssignmentId0 = req.body.cuAssignmentId0 ? req.body.cuAssignmentId0 : null;
  var cuAssignmentId1 = req.body.cuAssignmentId1 ? req.body.cuAssignmentId1 : null;
  var cuAssignmentId2 = req.body.cuAssignmentId2 ? req.body.cuAssignmentId2 : null;
  var cuAssignmentId3 = req.body.cuAssignmentId3 ? req.body.cuAssignmentId3 : null;
  var cuAssignmentId4 = req.body.cuAssignmentId4 ? req.body.cuAssignmentId4 : null;


  var firstFunction = (function () {
    return new Promise(async (resolve, reject) => {
      await new Promise((resolve, reject) => {
        let sql = "CALL updaterxMasterCategory(?,?,?,?,?,?,?)";
        // let sql = "CALL updaterxMasterCategory(?,?,?,?,?,?,?,?)";
        pool.query(
          sql, [rolodexNumber, action_type, cuAssignmentId0, cuAssignmentId1, cuAssignmentId2, cuAssignmentId3, cuAssignmentId4],
          // sql, [rolodexNumber, action_type, cuAssignmentId0, cuAssignmentId1, cuAssignmentId2, cuAssignmentId3, cuAssignmentId4,userID],
          function (err, results) {
            if (err) {
              console.log("error:", err);
              isInError = 1;
              isErrorCode = "ERROR";
              if (err.sqlState) {
                isErrorMsg = "Error message";
              }
              else {
                isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              }
              resolve("");
            } else {
              resolve(results[0])
            }
          });

      })
      resolve("");
    }); // end promise
  });




  var main = async function () {

    var first = await (firstFunction());

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          results: first
        }
        res.send(response);
      }
    });

  }; // end MAIN




  if (isInError == 0) {

    main();

  } else { // end isError

    console.log("post /rxMasterCategory/rxMasterCategoryUpdate ERROR ");

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

  } // end isError

}); // end POST

router.post('/updaterxMasterCategory_Check', function (req, res, next) {
  console.log('<==================================================>');
  console.log("POST /salesOrderController/updaterxMasterCategory_Check", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var rolodexNumber = req.body.rolodexNumber ? req.body.rolodexNumber : null;


  var firstFunction = (function () {
    return new Promise(async (resolve, reject) => {
      await new Promise((resolve, reject) => {
        let sql = "CALL updateRxMasterCatagory_Check(?)";
       var a= pool.query(
          sql, [rolodexNumber],
          function (err, results) {
            if (err) {
              console.log("error:", err);
              isInError = 1;
              isErrorCode = "ERROR";
              if (err.sqlState) {
                isErrorMsg = "Error message";
              }
              else {
                isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
              }
              resolve("");
            } else {
              resolve(results[0])
            }
          });
          console.log("=====================",a)

      })
      resolve("");
    }); // end promise
  });




  var main = async function () {

    var first = await (firstFunction());

    getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
      if (err) {
        res.send(err);
      } else {
        var response = {
          header: header,
          results: first
        }
        res.send(response);
      }
    });

  }; // end MAIN




  if (isInError == 0) {

    main();

  } else { // end isError

    console.log("post /salesOrderController/rxMasterCategoryUpdate_Check ERROR ");

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

  } // end isError

}); // end POST

// ===============================================

router.post("/updateTimeStamp", function (req, res, next) {
  let _id = (req.body.ID ? req.body.ID : null)
  let _action = (req.body.Action ? req.body.Action : null); 



  console.log('<==================================================>');
  console.log("POST /salesOrderController/updateTimeStamp", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

var firstFunction = function() {
  return new Promise((resolve, reject) => {
    let sql = "call updateTimeStamp(?,?)";
    pool.query(sql, [_action,_id], function (err, results) {
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
        var a = results[0][0].emailTimeStamp
        //moment(results[0][0].emailTimeStampTime).format("YYYY-MM-DD HH:MM:SS");
        if(a != null && a!= undefined && a!= ""){
        var dd = a.getDate();
        var mm = a.getMonth()+1; 
        var yyyy = a.getFullYear().toString();
        var hours = a.getHours();
        var minutes = a.getMinutes();
        var ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12;
        hours = hours ? hours : 12;
        if(dd<10){dd='0'+dd;} if(mm<10){mm='0'+mm;} 
        if(hours<10){hours='0'+hours;} 	if(minutes<10){minutes='0'+minutes;} a = mm+'/'+dd+'/'+yyyy+ " "+hours+":"+minutes+" "+ampm;
        console.log(a);
        // console.log(dateTime);
        resolve(a);
      } else {
        resolve("")
      }
        // resolve(results[0]);
      }
    }); // end query
  }); // end promise
};

var main = async function() {
  var first = await firstFunction();

  getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
    if (err) {
      res.send(err);
    } else {
      var response = {
        header: header,
        results: first
      };
      res.send(response);
    }
  });
}; // end MAIN

if (isInError == 0) {
  main();
} else {
  // end isError

  console.log("post /salesOrderController/updateTimeStamp ERROR ");

  getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
    if (err) {
      res.send(err);
    } else {
      var response = {
        isErrorMsg: isErrorMsg
      };
      res.send(response);
    }
  });
} // end isError
}); // end POST

//==============================================================

console.log("exporting router from salesOrderController.js");

module.exports = router;