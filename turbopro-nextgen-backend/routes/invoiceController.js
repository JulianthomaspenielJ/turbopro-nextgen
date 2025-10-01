var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;

var sql = "";
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

// ===============================================

router.post("/getInvoiceDetails", function(req, res, next) {
  var _action = req.body.action ? req.body.action : null;
  var _cuInvoiceID = req.body.cuInvoiceID ? req.body.cuInvoiceID : null;
  var _cuSOID = req.body.cuSOID ? req.body.cuSOID : null;
  var _vePOID = req.body.vePOID ? req.body.vePOID : null;
  var _veBillID = req.body.veBillID ? req.body.veBillID :null;
  var _joReleaseId = req.body.joReleaseId ? req.body.joReleaseId :null;

  console.log("<==================================================>");
  console.log("post /invoiceController/getInvoiceDetails", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function() {
    return new Promise((resolve, reject) => {
      sql = "call INVOICE_getInvoiceDetail(?,?,?,?,?,?)";	 
      pool.query(sql, [_action, _cuInvoiceID, _cuSOID,_vePOID,_veBillID,_joReleaseId], function(err, results) {
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

    console.log("post /invoiceController/getInvoiceDetails ERROR ");

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


router.post("/updateInvoiceDetails", function(req, res, next) {
  var _action = req.body.action ? req.body.action : null;
  var _cuInvoiceID = req.body.cuInvoiceID ? req.body.cuInvoiceID : null;
  var _cuSOID = req.body.cuSOID ? req.body.cuSOID : null;
  var _vePOID = req.body.vePOID ? req.body.vePOID : null;
  var _rxCustomerID = req.body.rxCustomerID ? req.body.rxCustomerID : null;
  var _rxBillToID = req.body.rxBillToID ? req.body.rxBillToID : null;
  var _rxBillToAddressID = req.body.rxBillToAddressID ? req.body.rxBillToAddressID : null;
  var _rxContactID = req.body.rxContactID ? req.body.rxContactID : null;
  var _rxShipToID = req.body.rxShipToID ? req.body.rxShipToID : null;
  var _rxShipToAddressID = req.body.rxShipToAddressID ? req.body.rxShipToAddressID : null;
  var _ShipToMode = req.body.ShipToMode ? req.body.ShipToMode : null;
  var _veShipViaID = req.body.veShipViaID ? req.body.veShipViaID : null;
  var _isCareOfRequired = req.body.isCareOfRequired ? req.body.isCareOfRequired : null;
  var _Tag = req.body.Tag ? req.body.Tag : null;
  var _empSalesRepID = req.body.empSalesRepID ? req.body.empSalesRepID : null;
  var _empAEID = req.body.empAEID ? req.body.empAEID : null;
  var _empCostID = req.body.empCostID ? req.body.empCostID : null;
  var _empSubmitID = req.body.empSubmitID ? req.body.empSubmitID : null;
  var _empOrderID = req.body.empOrderID ? req.body.empOrderID : null;
  var _coDivisionID = req.body.coDivisionID ? req.body.coDivisionID : null;
  var _CustomerPONumber = req.body.CustomerPONumber ? req.body.CustomerPONumber : null;
  var _DoNotMail = req.body.DoNotMail ? req.body.DoNotMail : null;
  var _coTaxTerritoryID = req.body.coTaxTerritoryID ? req.body.coTaxTerritoryID : null;
  var _cuTermsID = req.body.cuTermsID ? req.body.cuTermsID : null;
  var _dueDate = req.body.dueDate ? req.body.dueDate : null;
  var _changedByID = req.body.userID ? req.body.userID : null;
  var _Freight = req.body.Freight ? req.body.Freight : null;
  var _subTotal = req.body.subTotal ? req.body.subTotal : null;
  var _taxTotal = req.body.taxTotal ? req.body.taxTotal : null;
  var _joReleaseDetailID  = req.body.joReleaseDetailID ? req.body.joReleaseDetailID : null;
  var _shipDate = req.body.dueDate ? req.body.shipDate : null;
  var _prToWareHouseID = req.body.prToWareHouseID ? req.body.prToWareHouseID : null;
  var _shipToName = req.body.shipToName ? req.body.shipToName : null;
  var _shipToAddress1 = req.body.shipToAddress1 ? req.body.shipToAddress1 : null;
  var _shipToAddress2 = req.body.shipToAddress2 ? req.body.shipToAddress2 : null;
  var _shipToCity = req.body.shipToCity ? req.body.shipToCity : null;
  var _shipToState = req.body.shipToState ? req.body.shipToState : null;
  var _shipToZip = req.body.shipToZip ? req.body.shipToZip : null;
  var _joReleaseId=req.body.joReleaseID ? req.body.joReleaseID : null;
  var _joMasterId=req.body.joMasterID ? req.body.joMasterID : null;
  var _joReleaseSeq=req.body.joReleaseSeq ? req.body.joReleaseSeq : null;
  var _trackingNumber=req.body.trackingNumber ? req.body.trackingNumber : null;
  var _invoiceDate=req.body.invoiceDate ? req.body.invoiceDate : null;
    
  console.log("<==================================================>");
  console.log("post /invoiceController/updateInvoiceDetails", req.body);


  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function() {
    return new Promise((resolve, reject) => {
      sql = "call INVOICE_updateInvoice(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      pool.query(sql, [_action, _cuInvoiceID, _cuSOID,_vePOID,_rxCustomerID,_rxBillToID,_rxBillToAddressID,_rxContactID,_rxShipToID,_rxShipToAddressID,_ShipToMode,_veShipViaID,_isCareOfRequired,_Tag,_empSalesRepID,_empAEID,_empCostID,_empSubmitID,_empOrderID,_coDivisionID,_CustomerPONumber,_DoNotMail,_coTaxTerritoryID,_cuTermsID,_dueDate,_changedByID,_Freight,_subTotal,_taxTotal,_joReleaseDetailID,_shipDate,_prToWareHouseID,
                       _shipToName,_shipToAddress1,_shipToAddress2,_shipToCity,_shipToState,_shipToZip,_joReleaseId,_joMasterId,_joReleaseSeq,_trackingNumber,_invoiceDate
                        ], function(err, results) {
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

    console.log("post /invoiceController/updateInvoiceDetails ERROR ");

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

router.post("/updateInvoiceLineDetails", function(req, res, next) {
  var _action = req.body.action ? req.body.action : null;
  var _cuInvoiceID = req.body.cuInvoiceID ? req.body.cuInvoiceID : null;
  var _cuInvoiceDetailID = req.body.cuInvoiceDetailID ? req.body.cuInvoiceDetailID : null;
  var _cuSODetailID = req.body.cuSODetailID ? req.body.cuSODetailID : null;
  var _vePODetailID = req.body.vePODetailID ? req.body.vePODetailID : null;
  var _prMasterID = req.body.prMasterID ? req.body.prMasterID : null;
  var _QuantityBilled = req.body.QuantityBilled ? req.body.QuantityBilled : null;
  var _UnitCost = req.body.UnitCost ? req.body.UnitCost : null;
  var _PriceMultiplier = req.body.PriceMultiplier ? req.body.PriceMultiplier : null;
  var _Taxable = req.body.Taxable ? req.body.Taxable : null;
  var _Note = req.body.Note ? req.body.Note : '';
  var _Description = req.body.Description ? req.body.Description : null;
  var _changedByID = req.body.userID ? req.body.userID : null;



  console.log("<==================================================>");
  console.log("post /invoiceController/updateInvoiceLineDetails", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction = function() {
    return new Promise((resolve, reject) => {
      sql = "call INVOICE_updateInvoiceDetail(?,?,?,?,?,?,?,?,?,?,?,?,?)";
      pool.query(sql, [_action, _cuInvoiceID, _cuInvoiceDetailID,_cuSODetailID,_vePODetailID,_prMasterID,_QuantityBilled,_UnitCost,_PriceMultiplier,_Taxable,_Note,_Description,_changedByID], function(err, results) {
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

    console.log("post /invoiceController/updateInvoiceLineDetails ERROR ");

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

router.post("/saveInvoiceLineDetails", function(req, res, next) {
  var _action = req.body.action ? req.body.action : null;
  var _cuInvoiceID = req.body.cuInvoiceID ? req.body.cuInvoiceID : null;
  var _vePODetailID = req.body.vePODetailID ? req.body.vePODetailID : null;
  var _array = (req.body.array ? JSON.parse(req.body.array) : []); 
  var _changedByID = req.body.userID ? req.body.userID : null;
  var _transType =  req.body.transType ? req.body.transType : null;
  var _lastSubTotal =  req.body.lastSubTotal ? req.body.lastSubTotal : null;
  var _lastFreight =  req.body.lastFreight ? req.body.lastFreight : null;
  var _lastTaxAmount =  req.body.lastTaxAmount ? req.body.lastTaxAmount : null;
  var _LastcoTaxTerritoryID = req.body.LastcoTaxTerritoryID ? req.body.LastcoTaxTerritoryID : null;
  var _LastInvoiceDate = req.body.LastInvoiceDate ? req.body.LastInvoiceDate : null;

  console.log("<==================================================>");
  console.log("post /invoiceController/saveInvoiceLineDetails", req.body);

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  var firstFunction =  (function() {
    return new Promise(async(resolve, reject) => {      
        for(let i=0 ; i < _array.length ; i++){
            await new Promise((resolve, reject) => {
              sql = "call INVOICE_updateInvoiceDetail(?,?,?,?,?,?,?,?,?,?,?,?,?)";
              pool.query(sql, [_action, _array[i].cuInvoiceID?_array[i].cuInvoiceID:null, _array[i].cuInvoiceDetailID?_array[i].cuInvoiceDetailID:null ,_array[i].cuSoDetailId?_array[i].cuSoDetailId:null,_array[i].vePodetailId?_array[i].vePodetailId:null,_array[i].prMasterID?_array[i].prMasterID:null,_array[i].QuantityBilled?_array[i].QuantityBilled:null,_array[i].UnitCost?_array[i].UnitCost:null,_array[i].PriceMultiplier?_array[i].PriceMultiplier:null,_array[i].Taxable,_array[i].Note?_array[i].Note:'',_array[i].description?_array[i].description:null,_changedByID], function(err, results) {
                console.log("_action, _array[i].cuInvoiceID?_array[i].cuInvoiceID:null, _array[i].cuInvoiceDetailID?_array[i].cuInvoiceDetailID:null ,_array[i].cuSoDetailId?_array[i].cuSoDetailId:null,_array[i].vePodetailId?_array[i].vePodetailId:null,_array[i].prMasterID?_array[i].prMasterID:null,_array[i].QuantityBilled?_array[i].QuantityBilled:null,_array[i].UnitCost?_array[i].UnitCost:null,_array[i].PriceMultiplier?_array[i].PriceMultiplier:null,_array[i].Taxable,_array[i].Note?_array[i].Note:null,_array[i].description?_array[i].description:null,_changedByID",_action, _array[i].cuInvoiceID?_array[i].cuInvoiceID:null, _array[i].cuInvoiceDetailID?_array[i].cuInvoiceDetailID:null ,_array[i].cuSoDetailId?_array[i].cuSoDetailId:null,_array[i].vePodetailId?_array[i].vePodetailId:null,_array[i].prMasterID?_array[i].prMasterID:null,_array[i].QuantityBilled?_array[i].QuantityBilled:null,_array[i].UnitCost?_array[i].UnitCost:null,_array[i].PriceMultiplier?_array[i].PriceMultiplier:null,_array[i].Taxable,_array[i].Note?_array[i].Note:null,_array[i].description?_array[i].description:null,_changedByID);
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
        console.log("Recalculate======>")
        /*
         *if user has saved customer invoice without line items at that time, inserted is not happening in tpcuinvoicelogmaster table .Thatsy commented this line
         */
        // if(_array.length>0){
          var _recalculateaction = "CUSTOMERINVOICE"
          sql = "call INVOICE_recalculate(?,?,?,?,?,?,?,?,?,?)";
          pool.query(sql, [_recalculateaction,_cuInvoiceID,0,_changedByID,_transType,_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastInvoiceDate], function(err, results) {
          console.log(_recalculateaction,_cuInvoiceID,0,_changedByID,_transType,_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastInvoiceDate)
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
       // resolve("");  
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

    console.log("post /invoiceController/saveInvoiceLineDetails ERROR ");

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

router.post('/getBilledQuantity', function(req, res, next) {

  var _action = (req.body.action ? req.body.action : null);
  var _cuSOID = (req.body.cuSOID ? req.body.cuSOID : null); 
 
     
    console.log('<==================================================>');
    console.log("POST /invoiceController/getBilledQuantity", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call Invoice_billedQuantity(?,?)'
                pool.query(sql,[_action,_cuSOID],function (err, results) {
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
 
    console.log("post /invoiceController/getBilledQuantity ERROR ");

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



router.post('/changeSoStatus', function(req, res, next) {

  var _cuSOID = (req.body.cuSOID ? req.body.cuSOID : null); 
 
     
    console.log('<==================================================>');
    console.log("POST /invoiceController/changeSoStatus", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call update_SoStatus(?)'
                pool.query(sql,[_cuSOID],function (err, results) {
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
 
    console.log("post /invoiceController/changeSoStatus ERROR ");

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



  router.post("/recalculate", function(req, res, next) {
    var _action = req.body.action ? req.body.action : null;
    var _cuInvoiceID = req.body.cuInvoiceID ? req.body.cuInvoiceID : null;
    var _changedByID = req.body.userID ? req.body.userID : null;
    var _transType =  req.body.transType ? req.body.transType : null;
    var _lastSubTotal =  req.body.lastSubTotal ? req.body.lastSubTotal : null;
    var _lastFreight =  req.body.lastFreight ? req.body.lastFreight : null;
    var _lastTaxAmount =  req.body.lastTaxAmount ? req.body.lastTaxAmount : null;
    var _LastcoTaxTerritoryID = req.body.LastcoTaxTerritoryID ? req.body.LastcoTaxTerritoryID : null;
    var _LastInvoiceDate = req.body.LastInvoiceDate ? req.body.LastInvoiceDate : null;
  
    console.log("<==================================================>");
    console.log("post /invoiceController/recalculate", req.body);
  
    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
  
    var firstFunction =  (function() {
      return new Promise(async(resolve, reject) => {      
         
            sql = "call INVOICE_recalculate(?,?,?,?,?,?,?,?,?,?)";
            pool.query(sql, [_action,_cuInvoiceID,0,_changedByID,_transType,_lastSubTotal,_lastFreight,_lastTaxAmount,_LastcoTaxTerritoryID,_LastInvoiceDate], function(err, results) {
    
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
  
      console.log("post /invoiceController/recalculate ERROR ");
  
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

console.log("exporting router from invoiceController.js");

module.exports = router;
