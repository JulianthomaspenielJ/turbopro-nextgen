var express = require('express');
var router = express.Router();
var main = require("./mainFunc.js")
var PATH = require('path').basename(__filename).split('.')[0]

// ===============================================

router.get('/getCustInfo', function(req, res, next) {
  var job = req.query.job
  var sql = `select Name, Description, j.JobStatus
    from joMaster m, rxMaster, joStatus j
    where rxCustomerId = rxMasterId and
    m.JobStatus = joStatusId and
    JobNumber = ?;`
  main(sql, [job], PATH, res)
});

router.get('/getReleases', function(req, res, next) {
  var job = req.query.job
  var sql = `SELECT joRelease.releasedate,
                    joRelease.releasetype,  
                    max(veFactory.veFactoryID),
                    max(rxMaster.name) rmanf,
                    joRelease.releasenote,  
                    cast(joRelease.estimatedbilling as decimal(10,2)) as allocated,
                    max(vePO.OrderDate) OrderDate,
                    max(vePO.BillToMode) BillToMode,
                    max(vePO.rxBillToAddressId) BillToAddressId,
                    max(vePO.ShipToMode) ShipToMode,
                    max(vePO.rxShipToAddressId) ShipToAddressId,
                    cast(max(vePO.subtotal) as decimal(10,2)) Subtotal,
                    cast(max(vePO.taxtotal) as decimal(10,2)) Taxtotal,
                    cast(max(vePO.freight) as decimal(10,2)) Freight,
                    max(joReleaseDetail.joReleaseDetailID),
                    joMaster.JobNumber,
                    max(prw.Description) warehouse,
                    (select EmailName from tsUserLogin
                      where UserLoginId = max(vePO.OrderedById)) OrderedBy,
                    (SELECT cast(SUM(VendorInvoiceAmount) as decimal(10,2))
                      FROM joReleaseDetail vpd
                      WHERE vpd.joReleaseID=joRelease.joReleaseID)
                      as VendorInvoiceAmount,
                    (SELECT cast(SUM(CustomerInvoiceAmount) as decimal(10,2))
                      FROM joReleaseDetail vpd
                      WHERE vpd.joReleaseID=joRelease.joReleaseID)
                      as CustomerInvoiceAmount,  
                    joRelease.joReleaseId id,
                    max(vePO.vePoID) vePOID,
                    max(vePO.poNumber) poNumber,
                    max(vePO.CustomerPONumber) CustomerPONumber,
                    joRelease.BillNote,  
                    max(rxMaster.Websight),
                    max(rxMaster.rxMasterID),
                    max(vePO.rxVendorContactID) VendorContactId,
                    max(vePO.ShipToMode) ShipToMode,  
                    max(cuSO.cuSoid),
                    max(cuSO.sonumber),
                    IFNULL(max(cuSO.TransactionStatus),3),  
                    max(rxAddress.Address1) Address1,
                    max(rxAddress.Address2) Address2,
                    max(rxAddress.City) City,
                    max(rxAddress.State) State,
                    max(rxAddress.Zip) Zip,
                    (SELECT SUM(QuantityBilled) FROM veBill vb
                      JOIN veBillDetail vbd ON(vb.veBillID=vbd.veBillID)
                      WHERE joReleaseDetailID = max(joReleaseDetail.joReleaseDetailID))
                      AS vebilltotalitemqty ,
                    (SELECT SUM(QuantityOrdered) FROM vePODetail vpd WHERE
                      vpd.vePOID=max(vePO.vePOID)) as vepodetailtotalquantity,  
                    joRelease.seq_Number,
                    max(vePO.TransactionStatus) AS vepotrans,
                    joRelease.release_status,
                    max(cuSO.TransactionStatus) as cusotrans,  
                    cod.Description AS coDivision,
                    joRelease.GRTaxRate,
                    max(cuSO.ShipToMode) AS cuSoShipMode,
                    max(ecSplitJobID) ecSplit
                  FROM joMaster
                    LEFT JOIN joRelease ON joMaster.joMasterID=joRelease.joMasterID  
                    LEFT JOIN joReleaseDetail ON joRelease.joReleaseID =
                      joReleaseDetail.joReleaseID  
                    LEFT JOIN vePO ON joRelease.joReleaseID = vePO.joReleaseID  
                    LEFT JOIN cuSO ON cuSO.joReleaseID = joRelease.joReleaseID  
                    LEFT JOIN veFactory ON veFactory.rxMasterID = vePO.rxVendorID  
                    LEFT JOIN rxMaster ON vePO.rxVendorID = rxMaster.rxMasterID OR
                      cuSO.rxCustomerID = rxMaster.rxMasterID  
                    LEFT JOIN rxAddress ON rxMaster.rxMasterID = rxAddress.rxMasterID
                      AND rxAddress.rxAddressID = (SELECT rxAdd.rxAddressID FROM rxAddress
                        AS rxAdd WHERE rxAdd.rxMasterID = rxMaster.rxMasterID LIMIT 1,1)  
                    LEFT JOIN coDivision cod ON cod.coDivisionId = joRelease.coDivisionId  
                    LEFT JOIN prWarehouse prw ON prw.prWarehouseID = cuSO.prFromWarehouseID  
                    LEFT JOIN ecSplitJob sp ON sp.joReleaseID=joRelease.joReleaseID  
                  WHERE joMaster.JobNumber= ? and
                        joRelease.joReleaseID > 0
                  group by joRelease.joReleaseID;`;
  main(sql, [job], PATH, res)
});

router.get('/getManf', function(req, res, next) {
  var sql = `select distinct name m from rxMaster where isVendor = 1 order by name;`
  main(sql, [], PATH, res)
});

router.get('/getInfo', function(req, res, next) {
  var job = req.query.job
  var sql = `select ReleaseNotes,
                    noticeId, contactId, otherContact, notice,
                    LocationName, LocationAddress1, LocationAddress2, LocationCity,
                    LocationState, LocationZip,
                    cast((ContractAmount + sum(ChangeAmount)) as decimal(10,2)) 
                    ContractAmount,
                    Commission
             from joChange c, joMaster m
             where m.joMasterId = c.joMasterId and JobNumber = ?
             group by c.joMasterId;`
  main(sql, [job], PATH, res)
});

router.get('/getCustPO', function(req, res, next) {
  var job = req.query.job
  var sql = `set @id = (select joMasterId from joMaster where JobNumber = ?);
    select CustomerPONumber, ChangeAmount amt
       from joChange
	     where joMasterId = @id
    UNION
    select CustomerPONumber, ContractAmount amt from joMaster
       where joMasterId = @id
    UNION
    select CustomerPONumber1 CustomerPONumber, POAmount1 amt from joCustPO
       where joMasterId = @id and POAmount1 > 0
    UNION
    select CustomerPONumber2 CustomerPONumber, POAmount2 amt from joCustPO
       where joMasterId = @id and POAmount2 > 0
    UNION
    select CustomerPONumber3 CustomerPONumber, POAmount3 amt from joCustPO
       where joMasterId = @id and POAmount3 > 0
    UNION
    select CustomerPONumber4 CustomerPONumber, POAmount4 amt from joCustPO
       where joMasterId = @id and POAmount4 > 0
    UNION
    select CustomerPONumber5 CustomerPONumber, POAmount5 amt from joCustPO
       where joMasterId = @id and POAmount5 > 0
       order by CustomerPONumber;`
  main(sql, [job], PATH, res)
});

router.get('/getCustPO2', function(req, res, next) {
  var job = req.query.job
  var sql = `select distinct(v.CustomerPONumber)
             from joMaster m, joRelease r, vePO v
             where m.joMasterId = r.joMasterId and 
             v.joReleaseId = r.joReleaseId and
             JobNumber = ?;`
  main(sql, [job], PATH, res)
});

router.get('/getContacts', function(req, res, next) {
  var job = req.query.job
  var sql = `select r.rxContactId Id, concat(r.FirstName, ' ', r.LastName) Name
             from rxContact r, joMaster m
             where r.rxMasterId = m.rxCustomerId and JobNumber = ?
             order by r.LastName;`
  main(sql, [job], PATH, res)
});

router.get('/getAssignees', function(req, res, next) {
  var job = req.query.job
  var sql = `select t0.EmailName e0, t1.EmailName e1, t2.EmailName e2, t3.EmailName e3,
                    t4.EmailName e4
             from joMaster 
               LEFT JOIN tsUserLogin t0 ON cuAssignmentId0 = t0.UserLoginId  
               LEFT JOIN tsUserLogin t1 ON cuAssignmentId1 = t1.UserLoginId  
               LEFT JOIN tsUserLogin t2 ON cuAssignmentId2 = t2.UserLoginId  
               LEFT JOIN tsUserLogin t3 ON cuAssignmentId3 = t3.UserLoginId  
               LEFT JOIN tsUserLogin t4 ON cuAssignmentId4 = t4.UserLoginId  
             where JobNumber = ?;`
  main(sql, [job], PATH, res)
});

router.get('/getPODetail', function(req, res, next) {
  var po = req.query.po
  var sql = `SELECT vePODetailID id,
       p.Description ProductCode,
       v.Description,
       Note,
       QuantityOrdered,
       QuantityReceived,
       QuantityBilled,
       cast(UnitCost as decimal(10,2)) UnitCost,
       PriceMultiplier,
       Taxable,
       EstimatedShipDate,
       joSchedDetailID,
       Acknowledged,
       AcknowledgementDate,
       VendorOrderNumber,
       cuSODetailID,
       posistion,
       QuantityInvoiced
  from vePODetail v, prMaster p
  where p.prMasterId = v.prMasterId and
        vePOID = ?;`
  main(sql, [po], PATH, res)
});

router.get('/getSysInfo', function(req, res, next) {
  var sql = `select POName, POStreet1, POStreet2, POCity, POState, POZip
    from sysInfo;`
  main(sql, [], PATH, res)
});

router.get('/getAddress', function(req, res, next) {
  var addr = req.query.id
  var sql = `select Name, Address1, Address2, City, State, Zip
    from rxAddress where rxAddressId = ?;`
  main(sql, [addr], PATH, res)
});

router.get('/getSplits', function(req, res, next) {
  var job = req.query.job
  var sql = `SELECT c.Name, cast(sp.Allocated as decimal(10,2)) Allocated, r.joReleaseId
    from joMaster m
    LEFT JOIN joRelease r ON m.joMasterID = r.joMasterID
    LEFT JOIN ecSplitJob sp ON sp.joReleaseID = r.joReleaseID
    LEFT JOIN rxMaster c ON c.rxMasterId = sp.rxMasterID
    where m.JobNumber = ?
    order by r.joReleaseId;`
  main(sql, [job], PATH, res)
});

router.get("/getTodo", function(req, res, next) {
  var r = req.query
  var sql = `select t.*, group_concat(a.UserLogin) team
             from TODO t, TODO_ASSIGNMENT a
             where a.TODO_id = t.id
             group by a.TODO_id;`
  main(sql, [], PATH, res)
});

router.get("/getTodoAssignees", function(req, res, next) {
  var sql = `select UserLoginID id, EmailName name from tsUserLogin
    where LENGTH(EmailName) > 0 limit 5;`
  main(sql, [], PATH, res)
});

router.post("/updateTodo", function(req, res, next) {
  var r = req.body
  var sql = `update TODO set title=?, detail=?, color=?, type1=?
    where id=?;`
  main(sql, [r.title, r.detail, r.color, r.type1, r.id], PATH, res)
});

router.post("/insertTodo", function(req, res, next) {
  var r = req.body
  var sql = `insert into TODO (title, detail, color, type1)
    values (?,?,?,?);`
  var team = r.team.split(',')
  sql = `${sql} SELECT @id:= LAST_INSERT_ID();`
  team.forEach(x => {
    sql = `${sql} insert into TODO_ASSIGNMENT (TODO_id, UserLogin)
      values (@id, ${x});`
  })
  main(sql, [r.title, r.detail, r.color, r.type1], PATH, res)
})

module.exports = router;
