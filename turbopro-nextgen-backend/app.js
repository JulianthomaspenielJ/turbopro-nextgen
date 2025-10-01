var createError = require('http-errors');
var express = require('express');
var enableWs = require('express-ws')
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var https = require('https');
var fs = require('fs');
var cron = require('cron').CronJob;
var cron = require('node-cron');
var aws = require('./routes/sendEmail');
var WH_SalesActivity = require('./routes/warehouseBuilder');
var WH_JobActivity = require('./routes/warehouse');
var ftp_File = require('./routes/ftpFile');
let ftpConfig_Call = require('./routes/ftpCofigCall');
let reportMailSend = require('./routes/reportSendMail');

var indexRouter = require('./routes/index');
//var usersRouter = require('./routes/users');

var app = express();
app.disable('etag');
var wssApp = enableWs(app)

app.use(function(req, res, next) {
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
  res.header('Access-Control-Allow-Methods', 'OPTIONS, POST, DELETE')
  next();
});

app.use(express.static('public'))
// view engine setup
//app.set('views', path.join(__dirname, 'views'));
//app.set('view engine', 'jade');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
// app.use(express.json({ limit: "105mb" }));
// app.use(express.urlencoded({ extended: true, limit: "105mb" }));
app.use(cookieParser());
//app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', require('./routes/users'));
app.use('/commissionController', require('./routes/commissionController'));
app.use('/joReleaseController', require('./routes/joReleaseController'));
app.use('/picklistController', require('./routes/picklistController'));
app.use('/binController', require('./routes/binController'));
app.use('/adjustmentController',require('./routes/adjustmentController'))
app.use('/receiveInvController',require('./routes/receiveInvController'))
app.use('/warehouseController',require('./routes/warehouseController'))
app.use('/detailController',require('./routes/detailController'))
app.use('/salesOrderController',require('./routes/salesOrderController'))
app.use('/invoiceController',require('./routes/invoiceController'))
app.use('/customerController',require('./routes/customerController'))
app.use('/backOrderController',require('./routes/backOrderController'))
app.use('/jobController',require('./routes/jobController'))
app.use('/vendorController',require('./routes/vendorController'))
app.use('/inventoryMaintenance',require('./routes/inventoryMaintenance'))
app.use('/notificationController', require('./routes/notificationController'))
app.use('/sendotp', require('./routes/sendotp'))
app.use('/reports', require('./routes/reports'))
app.use('/document', require('./routes/document'))
app.use('/picklist',require('./routes/picklist'))
app.use('/auth',require('./routes/auth'))
app.use('/manufactureController', require('./routes/manufactureController'))
app.use('/submittal', require('./routes/joSubmittal'))
app.use('/search', require('./routes/search'))
app.use('/searchLive', require('./routes/searchLive'))
app.use('/jobDetails', require('./routes/jobDetails'))
app.use('/fileUpload', require('./routes/fileUpload'))
// app.use('/rxMasterCategory', require('./routes/rxMasterCategory'))
// app.get('/reportSendMail', (req,res)=>{
//   console.log("hello");
//   reportMailSend();
// })

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  //res.render('error');
});

var aWss = wssApp.getWss('/');

indexRouter.ws('/', function(ws, req) {
  ws.on('message', function(msg) {
    console.log('++WEBSOCKET', msg);
    aWss.clients.forEach(function (client) {
      client.send(msg);
    });
  });
});

console.log("+++++++++++++++++++++++++++", process.env.NODE_ENV)

if (process.env.NODE_ENV === "production") {
  const options = {
    key: fs.readFileSync('/etc/apache2/SSL/2023/aandespecialties_tld.key'),
    cert: fs.readFileSync('/etc/apache2/SSL/2023/__aandespecialties_com.crt')
  };

  https.createServer(options, app).listen(3003, function () {
    console.log("info", "DTS app listening on port 3003 !");
  });
} else {
  var server = app.listen(3003,'0.0.0.0', function() {
    var host = server.address().address
    var port = server.address().port 
    console.log("TP at http://%s:%s", host, port);
  })
}


// cron.schedule('*/30 * * * * *', async () => {
//   console.log("notificationsystem")
//   await aws.sendemail();
// });

//Uncomment for bartos Start

/*
cron.schedule('0 2 * * *', async () => {
  console.log("WH_JobActivity");
   WH_JobActivity.WH_JobActivity();
   WH_SalesActivity.WH_SalesActivity();
});

cron.schedule('30 22 * * *', async () => {
  console.log("FTP_PROTOCOL");
  ftp_File.ftpProtocol();
});

//Uncomment for bartos End

cron.schedule('0 5 * * *', async () => {
  console.log("Inside cron for cronGenereteReports(Before cronGenereteReports)");
  reportMailSend.cronGenereteReports();
});

*/
module.exports = app;
