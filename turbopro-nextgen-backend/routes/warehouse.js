
var pool = require("../config/db.js");

function WH_JobActivity() {
    console.log('<==================================================>');
    console.log("jobActivity");

               var action = 'QUOTE';
               var sql = 'call WH_updateWarehouse(?,?,?,?);' 
              // call WH_updateWarehouse('QUOTE', 1, 1, null);
               pool.query(sql,[action,1,1,0],function (err, results) {
                if (err) {
                  console.log("err in wh_job", err);
                }else{
                  console.log("success in wh_job", results);
                }
 
                    
            }); // end query
 } // end Function

// module.exports = router;
exports.WH_JobActivity = WH_JobActivity;