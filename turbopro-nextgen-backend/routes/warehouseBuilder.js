
var pool = require("../config/db.js");

function WH_SalesActivity() {
    console.log('<==================================================>');
    console.log("salesActivity");

               var sql = "call WH_update('REBUILD_WH_invoice,REBUILD_WH_sales,REBUILD_WH_splitJob,REBUILD_WH_salesCommission',null);"
               pool.query(sql,function (err, results) {
                if (err) {
                  console.log("err in wh_sales", err);
                }else{
                  console.log("success in wh_sales", results);
                }
 
                    
            }); // end query
 } // end Function

// module.exports = router;
exports.WH_SalesActivity = WH_SalesActivity;