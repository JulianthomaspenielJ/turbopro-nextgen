var express = require('express');
var router = express.Router();
var mainFunc = require("./mainFunc.js")
var PATH = require('path').basename(__filename).split('.')[0]

// ===============================================

  router.post('/updateInventoryBin', function(req, res, next) {
    var _action = (req.body.action ? req.body.action : null);
    var _userId = (req.body.userId ? req.body.userId : null);
    var _binID = (req.body.binID ? req.body.binID : null);
    var _prMasterID = (req.body.prMasterID ? req.body.prMasterID : null);
    var _prWarehouseID = (req.body.prWarehouseID ? req.body.prWarehouseID : null);

    var _rack = (req.body.rack ? req.body.rack : null);
    var _slot = (req.body.slot ? req.body.slot : null);
    var _row = (req.body.row ? req.body.row : null);
    var _overrideName = (req.body.overrideName ? req.body.overrideName : null);
    var _barcode = (req.body.barcode ? req.body.prWarehouseID : null);
    var _maxQty = (req.body.maxQty ? req.body.maxQty : null);
    var _inventoryOnHand = (req.body.inventoryOnHand ? req.body.inventoryOnHand : null);
    var _inventoryOnOrder = (req.body.inventoryOnOrder ? req.body.inventoryOnOrder : null);
    var _inventoryAllocated = (req.body.inventoryAllocated ? req.body.inventoryAllocated : null);
    var _averageCost = (req.body.averageCost ? req.body.averageCost : 0);
    var _transferBinId = (req.body.transferBinID ? req.body.transferBinID : null);

    console.log('<==================================================>');
    console.log("POST /binController/updateInventoryBin ", req.body);

    var sql = 'call INV_updateBin(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);';
    var args = [_action,_binID,_prWarehouseID,_prMasterID,_rack,_row,_slot,_overrideName,_maxQty,_inventoryOnHand,_inventoryAllocated,_inventoryOnOrder,_averageCost,_transferBinId,_userId]

  (async function () {
    await mainFunc(isInError, isErrorCode, isErrorMsg, sql, args, PATH, res)
  })()
}); // end POST  
//
// ===============================================

router.post('/getInventoryBin', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null);
  var _userId = (req.body.userId ? req.body.userId : null);
  var _binID = (req.body.binID ? req.body.binID : null);
  var _search = (req.body.search ? req.body.search : null);
  var _prMasterID = (req.body.prMasterID ? req.body.prMasterID : null);
  var _prWarehouseID = (req.body.prWarehouseID ? req.body.prWarehouseID : null);

    console.log('<==================================================>');
    console.log("POST /binController/getInventoryBin ", req.body);


  var sql = 'call INV_getBin(?,?,?,?,?);';
  var args = [_action,_binID,_prWarehouseID,_prMasterID,_search]

  (async function () {
    await mainFunc(isInError, isErrorCode, isErrorMsg, sql, args, PATH, res)
  })()
}); // end POST  


// ===============================================

router.post('/getProduct', function(req, res, next) {
  var _action = (req.body.action ? req.body.action : null);
  var _userId = (req.body.userId ? req.body.userId : null);
  var _search = (req.body.search ? req.body.search : null);
  var _prMasterID = (req.body.prMasterID ? req.body.prMasterID : null);
  var _prWarehouseID = (req.body.prWarehouseID ? req.body.prWarehouseID : null);

    console.log('<==================================================>');
    console.log("POST /binController/getProduct ", req.body);


  var sql = 'call INV_getProduct(?,?,?,?);';
  var args = [_action,_prMasterID,_prWarehouseID,_search]

  (async function () {
    await mainFunc(sql, args, PATH, res)
  })()

}); // end POST  

// ===============================================

router.get('/getSummary', function(req, res, next) {
  console.log('<==================================================>');
  console.log("GET /binController/getSummary ");

  let sql = 'call INV_getSummary();';
  let args = []

  try {
    (async function () {
      await mainFunc(sql, args, PATH, res)
    })()
  } catch (err) {
    console.log('+++ ERROR:', sql, PATH, err)
  }
});

router.get("/getDetail", function (req, res, next) {
  console.log("<==================================================>");
  console.log('/binController/getDetail')

  let sql = 'call INV_getDetail(?);';
  var args = [req.query.item]
  try {
    (async function () {
      await mainFunc(sql, args, PATH, res)
    })()
  } catch (err) {
    console.log('+++ ERROR:', sql, PATH, err)
  }
});

module.exports = router;
