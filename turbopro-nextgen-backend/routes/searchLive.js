var express = require('express');
var router = express.Router();
var main = require("./mainFunc.js")
var PATH = require('path').basename(__filename).split('.')[0]

router.post('/searchLive', function (req, res, next) {
  var sql = `SELECT m.jobNumber, max(Description) jobName,
                    max(h.jobOpenedDate) jobOpenedDate,
                    max(h.BidDate) BidDate,
                    max(s.jobStatus) jobStatus,
                    max(h.jobHistoryId) h1
             FROM joMaster m, joStatus s, jobHistory h
             WHERE m.jobStatus = s.joStatusId and
                   m.JobNumber = h.jobNumber and
                   tsUserLoginId = ?
             GROUP BY m.jobNumber
             ORDER BY h1 DESC LIMIT 0, 25;`
    main(sql, [req.body.userId], PATH, res)
});

module.exports = router;
