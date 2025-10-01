var express = require('express');
var router = express.Router();
var pool = require('../config/db.js')
var getHeaderNode = require("../models/header.js").header;

var sql ='';
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

// ===============================================

router.get('/getProductDetails', function(req, res, next) {
    var _search = (req.query.search ? req.query.search : null);    
    var _inactive = (req.query.inactive  ? req.query.inactive : null);    
    var _prWarehouseID = (req.query.prWarehouseID ? req.query.prWarehouseID : null);    
      
      console.log('<==================================================>');
      console.log("POST /detailController/getProductDetails ", _search,_inactive,_prWarehouseID);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call INV_Productdetails(?,?,?);';
                   
                  pool.query(sql,[_search,_inactive,_prWarehouseID],function (err, results) {
                      if (err) {
                          console.log("error:",err);
                          isInError =1;
                          isErrorCode =  "FILTER_ERROR";
                          if (err.sqlState==41001){
                          isErrorMsg = "Please report this error";
                          }
                          else {
                          isErrorMsg = err.sqlState + ": We had difficulty performaing this action.  Pleae report his number to your contact.";
                          //isErrorMsg = err.sqlMessage;
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
   
      console.log("post /detailController/getProductDetails ERROR ", _action);
  
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

   router.post('/getDetProduct', function(req, res, next) {
    var _action = (req.body.action ? req.body.action : null); 
    var _prMasterID = (req.body.prMasterID ? req.body.prMasterID : null); 
    var _search = (req.body.search ? req.body.search : null); 
       
      console.log('<==================================================>');
      console.log("POST /detailController/getDetProduct", req.body);
  
      isInError = 0;
      isErrorMsg = "";
      isErrorCode = "";
      
          var firstFunction =  (function() {
              return new Promise((resolve, reject) => {
  
                  sql = 'call PR_getProductDetail(?,?,?)'
                  pool.query(sql,[_action,_prMasterID,_search],function (err, results) {
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
                            resolve(results); 
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
   
      console.log("post /detailController/getDetProduct ERROR ");
  
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

router.post('/updateProductDetails', function(req, res, next) {

  var _action = (req.body.action ? req.body.action : null);
  var _userId = (req.body.userId ? req.body.userId : null); 
  var _prMasterID = (req.body.prMasterID ? req.body.prMasterID : null); 
  var _itemCode = (req.body.itemCode ? req.body.itemCode : null); 
  var _description = (req.body.description ? req.body.description : null); 
  var _departmentName = (req.body.departmentName ? req.body.departmentName : null); 
  var _categoryName = (req.body.categoryName ? req.body.categoryName : null); 
  var _boxName = (req.body.boxName ? req.body.boxName : null); 
  var _weightName = (req.body.weightName ? parseInt(req.body.weightName) : null); 
  var _ounces = (req.body.ounces ? parseInt(req.body.ounces) : null); 
  var _productSiteName = (req.body.productSiteName ? req.body.productSiteName : null); 
  var _primaryVendorName = (req.body.primaryVendorName ? req.body.primaryVendorName : null); 
  var _vendorItemCodeName = (req.body.vendorItemCodeName ? req.body.vendorItemCodeName : null); 
  var _vendorName = (req.body.vendorName ? req.body.vendorName : null); 
  var _sellingPriceName = (req.body.sellingPriceName ? req.body.sellingPriceName : null); 
  var _multiplierName = (req.body.multiplierName ? req.body.multiplierName : null); 
  var _factoryCostName = (req.body.factoryCostName ? req.body.factoryCostName : null); 
  var _salesOrderSelectedName = (req.body.salesOrderSelectedName ? req.body.salesOrderSelectedName : null); 
  var _invoiceSelectedName = (req.body.invoiceSelectedName ? req.body.invoiceSelectedName : null); 
  var _purchaseOrderSelectedName = (req.body.purchaseOrderSelectedName ? req.body.purchaseOrderSelectedName : null); 
  var _inactive = (req.body.inactive ? req.body.inactive : null);
  var _inventory = (req.body.inventory ? req.body.inventory : null);
  var _taxable = (req.body.taxable ? req.body.taxable : null);
  var _singleItem = (req.body.singleItem ? req.body.singleItem : null);
  var _RetailName = (req.body.RetailName ? req.body.RetailName : null);
  var _special1Name = (req.body.special1Name ? req.body.special1Name : null);
  var _wholeSaleName = (req.body.wholeSaleName ? req.body.wholeSaleName : null);
  var _distributorName = (req.body.distributorName ? req.body.distributorName : null);
  var _dealerName = (req.body.dealerName ? req.body.dealerName : null);
  var _special2Name = (req.body.special2Name ? req.body.special2Name : null);
  var _QuantityName = (req.body.QuantityName ? req.body.QuantityName : null);
  var _overName = (req.body.overName ? req.body.overName : null);
  var _secondaryVendorName1 = (req.body.secondaryVendorName1 ? req.body.secondaryVendorName1 : null);
  var _vendorItemCode1 = (req.body.vendorItemCode1 ? req.body.vendorItemCode1 : null);
  var _secondaryVendorName2 = (req.body.secondaryVendorName2 ? req.body.secondaryVendorName2 : null);
  var _vendorItemCode2 = (req.body.vendorItemCod2 ? req.body.vendorItemCode2 : null);
  var _secondaryVendorName3 = (req.body.secondaryVendorName3 ? req.body.secondaryVendorName3 : null);
  var _vendorItemCode3 = (req.body.vendorItemCode3 ? req.body.vendorItemCode3 : null);
  var _secondaryVendorName4 = (req.body.secondaryVendorName4 ? req.body.secondaryVendorName4 : null);
  var _vendorItemCode4 = (req.body.vendorItemCode4 ? req.body.vendorItemCode4 : null);

    console.log('<==================================================>');
    console.log("POST /detailController/updateProductDetails", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call INV_updatePrMaster(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)'
                pool.query(sql,[_action,_prMasterID,_itemCode,_description,_departmentName,_categoryName,_boxName,_weightName,_ounces,_sellingPriceName,_multiplierName,_factoryCostName,_productSiteName,_primaryVendorName,_vendorItemCodeName,_vendorName,_salesOrderSelectedName,_invoiceSelectedName,_purchaseOrderSelectedName,_inactive,_inventory,_taxable,_singleItem,
                  _RetailName,_special1Name,_wholeSaleName,_distributorName,_dealerName,_special2Name,_overName,_QuantityName,_secondaryVendorName1,_vendorItemCode1,_secondaryVendorName2,_vendorItemCode2,_secondaryVendorName3,_vendorItemCode3,_secondaryVendorName4,_vendorItemCode4,_userId],function (err, results) {
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
 
    console.log("post /detailController/updateProductDetails ERROR ");

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

router.post('/getAllocatedDetails', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null); 
  var _prMasterID = (req.body.prMasterID ? req.body.prMasterID : null); 
 
     
    console.log('<==================================================>');
    console.log("POST /detailController/getAllocatedDetails", req.body);

    isInError = 0;
    isErrorMsg = "";
    isErrorCode = "";
    
        var firstFunction =  (function() {
            return new Promise((resolve, reject) => {

                sql = 'call INV_PR_Allocated(?,?)'
                pool.query(sql,[_action,_prMasterID],function (err, results) {
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
 
    console.log("post /detailController/getAllocatedDetails ERROR ");

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

    console.log("exporting router from detailController.js");

module.exports = router;