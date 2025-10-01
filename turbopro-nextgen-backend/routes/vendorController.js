var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;

var sql = "";
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

// ===============================================

router.post("/updateVendorInvoice", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _vebillID = req.body.vebillID ? req.body.vebillID : null;
    var _vePOID = req.body.vePOID ? req.body.vePOID : null;
    var _rxMasterID = req.body.rxMasterID ? req.body.rxMasterID : null;
    var _joReleaseDetailID = req.body.joReleaseDetailID ? req.body.joReleaseDetailID : null;
    var _BillDate = req.body.BillDate ? req.body.BillDate : null;
    var _APAccountID = req.body.APAccountID ? req.body.APAccountID : null;
    var _DueDate = req.body.DueDate ? req.body.DueDate : null;
    var _ShipDate = req.body.ShipDate ? req.body.ShipDate : null;
    var _PostDate = req.body.PostDate ? req.body.PostDate : null;
    var _UsePostDate = req.body.UsePostDate ? req.body.UsePostDate : null;
    var _TrackingNumber = req.body.TrackingNumber ? req.body.TrackingNumber : null;
    var _veShipViaID = req.body.veShipViaID ? req.body.veShipViaID : null;
    var _ReceiveDate = req.body.ReceiveDate ? req.body.ReceiveDate : null;
    var _InvoiceNumber = req.body.InvoiceNumber ? req.body.InvoiceNumber : null;
    var _Freight = req.body.Freight ? req.body.Freight : null;
    var _subTotal = req.body.subTotal ? req.body.subTotal : null;
    var _taxAmount = req.body.taxAmount ? req.body.taxAmount : null;
    var _joReleaseID = req.body.joReleaseID ? req.body.joReleaseID : null;
    var _joMasterID = req.body.joMasterID ? req.body.joMasterID : null;
    var _reason =  req.body.reason ? req.body.reason : null;
    var _updatePO = req.body.updatePO ?  req.body.updatePO :null; 
    var _changedByID = req.body.userID ? req.body.userID : null;
  
  
  
    console.log("<==================================================>");
    console.log("post /vendorController/updateVendorInvoice", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function() {
      return new Promise((resolve, reject) => {
        sql = "call VENDOR_updateInvoive(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        pool.query(sql, [_action,_vebillID,_vePOID,_rxMasterID,_joReleaseDetailID,_BillDate,_APAccountID,_DueDate,_ShipDate,_PostDate,_UsePostDate,_TrackingNumber,_veShipViaID,_ReceiveDate,_InvoiceNumber,_Freight,_subTotal,_taxAmount,_joReleaseID,_joMasterID,_reason,_updatePO,_changedByID], function(err, results) {
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
  
      console.log("post /vendorController/updateVendorInvoice ERROR ");
  
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


  router.post("/updateVendorInvoiceLineDetails", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _veBillID = req.body.veBillID ? req.body.veBillID : null;
    var _veBillDetailID = req.body.veBillDetailID ? req.body.veBillDetailID : null;
    var _vePODetailID = req.body.vePODetailID ? req.body.vePODetailID : null;
    var _prMasterID = req.body.prMasterID ? req.body.prMasterID : null;
    var _QuantityBilled = req.body.QuantityBilled ? req.body.QuantityBilled : null;
    var _UnitCost = req.body.UnitCost ? req.body.UnitCost : null;
    var _PriceMultiplier = req.body.PriceMultiplier ? req.body.PriceMultiplier : null;
    var _Taxable = req.body.Taxable ? req.body.Taxable : null;
    var _Note = req.body.Note ? req.body.Note : null;
    var _Description = req.body.Description ? req.body.Description : null;
    var _changedByID = req.body.userID ? req.body.userID : null;
    
  
  
  
    console.log("<==================================================>");
    console.log("post /vendorController/updateVendorInvoiceLineDetails", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function() {
      return new Promise((resolve, reject) => {
        sql = "call VENDOR_updateInvoiveDetail(?,?,?,?,?,?,?,?,?,?,?,?)";
        pool.query(sql, [_action, _veBillID,_veBillDetailID,_vePODetailID,_prMasterID,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,_Note,_Description,_changedByID], function(err, results) {
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
  
      console.log("post /vendorController/updateVendorInvoiceLineDetails ERROR ");
  
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


  router.post("/saveVendorInvoiceLineDetails", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _veBillID = req.body.veBillID ? req.body.veBillID : null;
    var _array = (req.body.array ? JSON.parse(req.body.array) : []); 
    var _changedByID = req.body.userID ? req.body.userID : null;
   
  
    console.log("<==================================================>");
    console.log("post /vendorController/saveVendorInvoiceLineDetails", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction =  (function() {
      return new Promise(async(resolve, reject) => {      
          for(let i=0 ; i < _array.length ; i++){
              await new Promise((resolve, reject) => {
                sql = "call VENDOR_updateInvoiveDetail(?,?,?,?,?,?,?,?,?,?,?,?)";
                pool.query(sql, [_action,_veBillID, _array[i].veBillDetailID?_array[i].veBillDetailID:null ,_array[i].vePodetailId?_array[i].vePodetailId:null,_array[i].prMasterID?_array[i].prMasterID:null,_array[i].QuantityBilled?_array[i].QuantityBilled:null,_array[i].UnitCost?_array[i].UnitCost:null,_array[i].PriceMultiplier?_array[i].PriceMultiplier:null,_array[i].Taxable,_array[i].Note?_array[i].Note:null,_array[i].description?_array[i].description:null,_changedByID], function(err, results) {
                  console.log("_action,veBillID,veBillDetailID,vePODetailID,prMasterID,QuantityBilled,UnitCost,PriceMultiplier,Taxable,Note,description,_changedByID",_action,_veBillID, _array[i].veBillDetailID?_array[i].veBillDetailID:null ,_array[i].vePodetailId?_array[i].vePodetailId:null,_array[i].prMasterID?_array[i].prMasterID:null,_array[i].QuantityBilled?_array[i].QuantityBilled:null,_array[i].UnitCost?_array[i].UnitCost:null,_array[i].PriceMultiplier?_array[i].PriceMultiplier:null,_array[i].Taxable,_array[i].Note?_array[i].Note:null,_array[i].description?_array[i].description:null,_changedByID);
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
        //   console.log("Recalculate======>")
        //   /*
        //    *if user has saved customer invoice without line items at that time, inserted is not happening in tpcuinvoicelogmaster table .Thatsy commented this line
        //    */
        //   // if(_array.length>0){
            var _recalculateaction = "VENDORINVOICE"
            sql = "call INVOICE_recalculate(?,?,?,?,?,?,?,?,?,?)";
            pool.query(sql, [_recalculateaction,_veBillID,0,_changedByID,null,null,null,null,null,null], function(err, results) {
            console.log(_recalculateaction,_veBillID,0,_changedByID,null,null,null,null,null,null)
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
        // }else
        // {
        //   resolve("");
        // }
          resolve("");  
  }); // end promise
  });
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
  
      console.log("post /vendorController/saveVendorInvoiceLineDetails ERROR ");
  
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

  
  router.post("/updateVendorBillDistribution", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _veBillID = req.body.veBillID ? req.body.veBillID : null;
    var _veBillDistributionID = req.body.veBillDistributionID ? req.body.veBillDistributionID : null;
    var _coExpenseAccountID = req.body.coExpenseAccountID ? req.body.coExpenseAccountID : null;
    var _ExpenseAmount = req.body.ExpenseAmount ? req.body.ExpenseAmount : null;
    var _joMasterID = req.body.joMasterID ? req.body.joMasterID : null;
    var _ecInvoicePeriodID = req.body.ecInvoicePeriodID ? req.body.ecInvoicePeriodID : null;
    var _changedByID = req.body.userID ? req.body.userID : null;
  
  
  
    console.log("<==================================================>");
    console.log("post /vendorController/updateVendorBillDistribution", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction = function() {
      return new Promise((resolve, reject) => {
        sql = "call VENDOR_updateVeBillDistribution(?,?,?,?,?,?,?,?)";
        pool.query(sql, [_action, _veBillID,_veBillDistributionID,_coExpenseAccountID,_ExpenseAmount,_joMasterID,_ecInvoicePeriodID,_changedByID], function(err, results) {
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
  
      console.log("post /vendorController/updateVendorBillDistribution ERROR ");
  
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


  router.post("/saveVendorInvoiceDistributionDetails", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _veBillID = req.body.veBillID ? req.body.veBillID : null;
    var _array = (req.body.array ? JSON.parse(req.body.array) : []); 
    var _changedByID = req.body.userID ? req.body.userID : null;
   
  
    console.log("<==================================================>");
    console.log("post /vendorController/saveVendorInvoiceDistributionDetails", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction =  (function() {
      return new Promise(async(resolve, reject) => {      
          for(let i=0 ; i < _array.length ; i++){
              await new Promise((resolve, reject) => {
                sql = "call VENDOR_updateVeBillDistribution(?,?,?,?,?,?,?,?)";
                pool.query(sql, [_action,_veBillID, _array[i].veBillDistributionID?_array[i].veBillDistributionID:null ,_array[i].coExpenseAccountID?_array[i].coExpenseAccountID:null,_array[i].ExpenseAmount?_array[i].ExpenseAmount:null,_array[i].joMasterID?_array[i].joMasterID:null,_array[i].ecInvoicePeriodID?_array[i].ecInvoicePeriodID:null,_changedByID], function(err, results) {
                  console.log("_action, _veBillID,_veBillDistributionID,_coExpenseAccountID,_ExpenseAmount,_joMasterID,_ecInvoicePeriodID,_changedByID",_action,_veBillID, _array[i].veBillDistributionID?_array[i].veBillDistributionID:null ,_array[i].coExpenseAccountID?_array[i].coExpenseAccountID:null,_array[i].ExpenseAmount?_array[i].ExpenseAmount:null,_array[i].joMasterID?_array[i].joMasterID:null,_array[i].ecInvoicePeriodID?_array[i].ecInvoicePeriodID:null,_changedByID);
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
        //   console.log("Recalculate======>")
        //   /*
        //    *if user has saved customer invoice without line items at that time, inserted is not happening in tpcuinvoicelogmaster table .Thatsy commented this line
        //    */
        //   // if(_array.length>0){
            var _recalculateaction = "VENDORINVOICEWITHOUTPO"
            sql = "call INVOICE_recalculate(?,?,?,?,?,?,?,?,?,?)";
            pool.query(sql, [_recalculateaction,_veBillID,0,_changedByID,null,null,null,null,null,null], function(err, results) {
            console.log(_recalculateaction,_veBillID,0,_changedByID,null,null,null,null,null,null)
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
        // }else
        // {
        //   resolve("");
        // }
          resolve("");  
  }); // end promise
  });
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
  
      console.log("post /vendorController/saveVendorInvoiceDistributionDetails ERROR ");
  
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

  router.post('/VendorAvgDays', function(req, res, next) {

    var _rxMasterId = req.body.rolodexNumber ? req.body.rolodexNumber : null;

      console.log('<==================================================>');
      console.log("POST /vendorController/VendorAvgDays");
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
                 sql = `select avg(TIMESTAMPDIFF(day, pv.billDate, pv.moTransactionDate)) as venAvgDays from PaymentBillMappingView pv left join rxMaster rx 
                 on pv.rxMasterID= rx.rxMasterID
                  where pv.billAmount = pv.billAppliedAmount and rx.rxMasterID = ? ` ;
                 pool.query(sql,[_rxMasterId],function (err, results) {
                      if (err) {
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
  
                      } else {      
                            resolve(results[0]); 
                      }
                      
              }); // end query
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
   
      console.log("post /vendorController/VendorAvgDays ERROR ");
  
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

  console.log("exporting router from vendorController.js");

module.exports = router;