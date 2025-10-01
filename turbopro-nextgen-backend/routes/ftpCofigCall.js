'use strict';

const ftp = require('./ftpconfig');
// process.env.DB_HOST

// DestinationDirectory=/home/turboftp/ftp/files
// FTPHost=157.55.201.56
// FTPPassword=65a5285658b5dad9f9e0d8f012691e1c
// FTPPort=21
// FTPUserName=turboftp
function ftpProtocolCall(){
    //const client = new ftp('192.168.1.4', 21, 'username', 'password', false);

   const client = new ftp('157.55.201.56', 21, 'turboftp', '65a5285658b5dad9f9e0d8f012691e1c', false);
    try {
                client.upload('/home/GeneratePositivePay/OutputFile/Positive_Pay_Bartos.txt','turboftp@157.55.201.56:/home/turboftp/ftp/files/',755)
                return "success";
    }catch(err) {
        console.log(err);
    }
    return res.status(200).send({message: "Success"})
}

exports.ftpProtocolCall = ftpProtocolCall;
console.log("exporting router from ftpConfigCall.js");
//module.exports = router;