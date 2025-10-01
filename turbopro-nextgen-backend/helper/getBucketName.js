const pool = require('../config/db.js');
const getBucket = (bucketType) => {
    return new Promise((resolve, reject) => {
        let SQL = `call TSUSERSETTINGS_settings(?, ?,null);`;    
         pool.query(SQL, ["getBucket", bucketType], (err, results) => {
        if (err) {
          reject(err);
        } else {
          // const documentBuckets = JSON.parse(results[0][0].documentBuckets)
          const documentBuckets = results[0][0].bucket

          resolve(documentBuckets);
        }
      });
    });
  };
  
  // Usage example
  

  exports.getBucket = getBucket;
