
DROP TABLE IF EXISTS global_notification_queue;


CREATE TABLE `global_notification_queue` (
  `notificationId` int NOT NULL AUTO_INCREMENT,
  `notification_messageId` int DEFAULT NULL,
  `notification_templateKey` varchar(100) DEFAULT NULL,
  `notification_notificationType` varchar(25) NOT NULL,
  `notification_docTypeId` int DEFAULT NULL,
  `notification_toEntityId` int DEFAULT NULL,
  `notification_toEmail` varchar(255) DEFAULT NULL,
  `notification_fromEntityId` int DEFAULT NULL,
  `notification_fromEmail` varchar(255) DEFAULT NULL,
  `notification_toSMS` varchar(50) DEFAULT NULL,
  `notification_statusId` int NOT NULL DEFAULT '0',
  `notification_readyOn` timestamp NOT NULL,
  `notification_expiresOn` timestamp NOT NULL,
  `notification_sentOn` timestamp NULL DEFAULT NULL,
  `notification_subject` varchar(255) DEFAULT NULL,
  `notification_content` text,
  `notification_attachmentURI1` varchar(400) DEFAULT NULL,
  `notification_attachmentURI2` varchar(400) DEFAULT NULL,
  `notification_attachmentURI3` varchar(400) DEFAULT NULL,
  `notification_attachmentURI4` varchar(400) DEFAULT NULL,
  `notification_attachmentURI5` varchar(400) DEFAULT NULL,
  `notification_attachmentURI6` varchar(400) DEFAULT NULL,
  `notification_created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notificationId`),
  UNIQUE KEY `notify_UNIQUE` (`notification_toEntityId`,`notification_notificationType`,`notification_messageId`)
) ENGINE=InnoDB AUTO_INCREMENT=514 DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS att_configuration;

CREATE TABLE `att_configuration` (
   configurationId INT(11) NOT NULL  AUTO_INCREMENT,
   topic varchar(100) NOT NULL,
   configKey varchar(100) NOT NULL,
   valueText varchar(255)  NULL,
   valueInt int(11)  NULL,
   description varchar(500)  NULL,
    PRIMARY KEY (configurationId),
    unique index UNIQUE_KEY_INDEX(configKey))
ENGINE = InnoDB;

insert into att_configuration  (topic,configKey,valueText,valueInt,description) values ('LOGIN','LOGIN_ENCRYPT',null,1,'1=encrypt, 0=not encrypted');
insert into att_configuration  (topic,configKey,valueText,valueInt,description) values ('LOGIN','LOGIN_FAILED_ATTEMPTS',null,3,'Attempts to login before locked out');
insert into att_configuration  (topic,configKey,valueText,valueInt,description) values ('LOGIN','LOGIN_SESSION_DURATION',null,1,'Duration in hours if idle time');
insert into att_configuration  (topic,configKey,valueText,valueInt,description) values ('LOGIN','LOGIN_TEMP_PASS_EXPIRE',null,10,'Duration in hours if idle time');
insert into att_configuration  (topic,configKey,valueText,valueInt,description) values ('NOTIFICATION','NOTIFICATION_ENABLED',null,1,'EMAIL or SMS will be sent');

insert into att_configuration  (topic,configKey,valueText,valueInt,description) values ('NOTIFICATION','OVERRIDE_EMAIL',null,null,'If not null, then always send emails to this test email.');




-- ====================================================================
/*


      call NOTIFICATION_notification(
      'CREATE',
      null, 'MFA', 'EMAIL', null,
      _entityId,_USER_loginEmail,_fromEntityId,'support@mail.com',_loginPhone,
      null,null, 
      concat('You have 4 minutes to enter this access code: ',_USER_loginEmailValidationCode),
      concat('You have 4 minutes to enter this access code: ',_USER_loginEmailValidationCode), 
      null,null,null,null,null,null
      );

      call NOTIFICATION_notification(
      'CREATE',
      null, 'MFA', 'EMAIL', null,
      1,'_USER_loginEmail',2,'support@mail.com','_loginPhone',
      null,null, 
      concat('You have 4 minutes to enter this access code: ','_USER_loginEmailValidationCode'),
      concat('You have 4 minutes to enter this access code: ','_USER_loginEmailValidationCode'), 
      null,null,null,null,null,null
      );

call NOTIFICATION_notification('DELETE',null, 'EMAILCAMPAIGN', 'EMAIL', null,null,null,null,null, _campaignId,null,null, null,null,null, null,null, null,null,null, null,null, null);


*/


DROP procedure IF EXISTS `NOTIFICATION_notification`;

DELIMITER $$
CREATE PROCEDURE `NOTIFICATION_notification`(
IN _action VARCHAR(100),
IN _notificationId INT, 
IN _notification_templateKey VARCHAR(255), 
IN _notification_notificationType VARCHAR(255),
IN _notification_docTypeId INT, 
IN _notification_toEntityId VARCHAR(255), 
IN _notification_toEmail VARCHAR(255), 
IN _notification_fromEntityId VARCHAR(255), 
IN _notification_fromEmail VARCHAR(255), 
IN _notification_toSMS VARCHAR(255), 
-- notification_statusId, -- 0=ready, 1=immediate, 2=sent, 2=delete
IN _notification_readyOn VARCHAR(255), 
IN _notification_expiresOn VARCHAR(255), 
IN _notification_subject VARCHAR(255), 
IN _notification_content TEXT, 
IN _notification_attachmentURI1 VARCHAR(255), 
IN _notification_attachmentURI2 VARCHAR(255), 
IN _notification_attachmentURI3 VARCHAR(255), 
IN _notification_attachmentURI4 VARCHAR(255), 
IN _notification_attachmentURI5 VARCHAR(255), 
IN _notification_attachmentURI6 VARCHAR(255)

)
NOTIFICATION_notification: BEGIN

DECLARE _DEBUG INT DEFAULT 0;

DECLARE _dateFormat varchar(100) DEFAULT '%d-%m-%Y %H:%i:%s';
DECLARE _notificationFoundId INT;
DECLARE _commaNeeded INT;
DECLARE _notification_messageId INT;

DECLARE _readyDate datetime;
DECLARE _expireDate datetime;

DECLARE _immediate_notificationId INT DEFAULT 0;
DECLARE NOTIFICATION_ENABLED INT;
DECLARE CAMPAIGN_NOTIFICATION_ENABLED INT;
DECLARE OVERRIDE_EMAIL VARCHAR(255);

IF(_action IS NULL ) THEN
  SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call NOTIFICATION_notification: _action can not be empty';
  LEAVE NOTIFICATION_notification;
END IF;

SELECT 
    valueInt
INTO NOTIFICATION_ENABLED FROM
    att_configuration
WHERE
    configKey = 'NOTIFICATION_ENABLED';

SELECT 
    valueText
INTO OVERRIDE_EMAIL FROM
    att_configuration
WHERE
    configKey = 'OVERRIDE_EMAIL';


IF(_action ='GETSMS') THEN

  select NOTIFICATION_ENABLED,OVERRIDE_EMAIL,q.* from global_notification_queue q where notification_notificationType='SMS'and notification_expiresOn > now() 
    and notification_readyOn < now() and notification_statusId =0;

ELSEIF(_action ='GETEMAIL') THEN

  select NOTIFICATION_ENABLED,OVERRIDE_EMAIL,q.* from global_notification_queue q 
    where notification_notificationType='EMAIL'
    and notification_expiresOn > now() 
    and notification_readyOn < now() and notification_statusId =0 and notification_templateKey != 'EMAILCAMPAIGN';

ELSEIF(_action ='GETBYKEY' AND _notification_templateKey IS NOT NULL) THEN

  select CAMPAIGN_NOTIFICATION_ENABLED,OVERRIDE_EMAIL,q.* from global_notification_queue q WHERE notification_templateKey = _notification_templateKey and
    notification_readyOn < now() and notification_statusId =0;

ELSEIF(_action ='GET NOTIFICATION' AND _notificationId IS NOT NULL) THEN

  select NOTIFICATION_ENABLED,OVERRIDE_EMAIL,q.* from global_notification_queue q WHERE notificationId = _notificationId;

ELSEIF(_action ='CREATE') THEN

  if (_notification_readyOn IS NOT NULL) THEN 
    set _readyDate = (STR_TO_DATE(_notification_readyOn, _dateFormat)); 
    ELSE 
    set _readyDate = now();
    END IF;
  
    if (_notification_expiresOn IS NOT NULL) THEN 
    set _expireDate = (STR_TO_DATE(_notification_expiresOn, _dateFormat));
    ELSE 
    set _expireDate = DATE_ADD(now() , INTERVAL 2 WEEK);
    END IF;

  set _notification_messageId = ifnull(_notification_toEntityId,0) + length(ifnull(_notification_content,''));
    
  -- attempt to find duplicates

  SELECT 
    notificationId
INTO _notificationFoundId FROM
    `global_notification_queue`
WHERE
    notification_messageId = _notification_messageId
        AND notification_toEntityId = _notification_toEntityId
        AND notification_notificationType = _notification_notificationType;

  IF (_notificationFoundId is null) THEN

    insert into `global_notification_queue` (
notification_messageId, notification_templateKey, notification_notificationType, notification_docTypeId,
notification_toEntityId, notification_toEmail, notification_toSMS, notification_fromEntityId, notification_fromEmail, 
notification_statusId, 
notification_readyOn, notification_expiresOn, notification_sentOn, 
notification_subject, notification_content, 
notification_attachmentURI1, notification_attachmentURI2, notification_attachmentURI3, notification_attachmentURI4, notification_attachmentURI5, notification_attachmentURI6, 
notification_created  
    )
    values (
_notification_messageId, _notification_templateKey, _notification_notificationType, _notification_docTypeId,
_notification_toEntityId, _notification_toEmail, _notification_toSMS, _notification_fromEntityId,_notification_fromEmail, 
0, 
_readyDate, _expireDate, null, 
_notification_subject, _notification_content, 
_notification_attachmentURI1, _notification_attachmentURI2, _notification_attachmentURI3, _notification_attachmentURI4, _notification_attachmentURI5, _notification_attachmentURI6, 
now()   
    );
  
    END IF;
    
ELSEIF(_action ='IMMEDIATE') THEN

  if (_notification_readyOn IS NOT NULL) THEN 
    set _readyDate = (STR_TO_DATE(_notification_readyOn, _dateFormat)); 
    ELSE 
    set _readyDate = now();
    END IF;
  
    if (_notification_expiresOn IS NOT NULL) THEN 
    set _expireDate = (STR_TO_DATE(_notification_expiresOn, _dateFormat));
    ELSE 
    set _expireDate = DATE_ADD(now() , INTERVAL 2 WEEK);
    END IF;

  set _notification_messageId = ifnull(_notification_toEntityId,0) + ifnull(_notification_campaignId,0) + length(ifnull(_notification_content,''));
    
  -- attempt to find duplicates

  SELECT 
    notificationId
INTO _notificationFoundId FROM
    `global_notification_queue`
WHERE
    notification_messageId = _notification_messageId
        AND notification_toEntityId = _notification_toEntityId
        AND notification_notificationType = _notification_notificationType;

  IF (_notificationFoundId is null) THEN

    insert into `global_notification_queue` (
notification_messageId, notification_templateKey, notification_notificationType, notification_docTypeId,
notification_toEntityId, notification_toEmail, notification_toSMS, notification_fromEntityId, notification_fromEmail, 
notification_statusId, 
notification_readyOn, notification_expiresOn, notification_sentOn, 
notification_subject, notification_content, 
notification_attachmentURI1, notification_attachmentURI2, notification_attachmentURI3, notification_attachmentURI4, notification_attachmentURI5, notification_attachmentURI6, 
notification_created  
    )
    values (
_notification_messageId, _notification_templateKey, _notification_notificationType, _notification_docTypeId,
_notification_toEntityId, _notification_toEmail, _notification_toSMS,_notification_fromEntityId, _notification_fromEmail, 
1, 
now(), now(), now(), 
_notification_subject, _notification_content, 
_notification_attachmentURI1, _notification_attachmentURI2, _notification_attachmentURI3, _notification_attachmentURI4, _notification_attachmentURI5, _notification_attachmentURI6, 
now()   
    );
  SET _immediate_notificationId = last_insert_id();
    END IF;
  
    IF (_immediate_notificationId > 0) THEN 
    SELECT _immediate_notificationId AS notificationId;
        SET _immediate_notificationId = 0;
  END IF;
ELSEIF(_action ='DELETE') THEN

    if (_notificationId is not null) then
      DELETE from global_notification_queue where notificationId = _notificationId;
    elseif (_notification_toEntityId is not null and _notification_templateKey is not null) then
      DELETE from global_notification_queue where notification_toEntityId = _notification_toEntityId
      and notification_templateKey = _notification_templateKey; -- deleted
    elseif (_notification_toEntityId is not null) then
      DELETE from global_notification_queue where notification_toEntityId = _notification_toEntityId; -- deleted
    END IF;
        
ELSEIF(_action ='CLEANUP') THEN

    DELETE from global_notification_queue where notification_expiresOn < now() and notification_statusId > 0; -- deleted
        
ELSEIF(_action ='ACKNOWLEDGE' and _notificationId is not null) THEN
        
  UPDATE global_notification_queue 
  SET 
    notification_messageId = (IFNULL(notification_messageId, 0) + notificationId),
    notification_statusId = 2,
    notification_sentOn = NOW()
  WHERE
    notificationId = _notificationId;
    
    
ELSE
  SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'call NOTIFICATION_notification: _action is of type invalid';
  LEAVE NOTIFICATION_notification;
END IF;


IF (_DEBUG=1) THEN 
  select _action,_notification_messageId, _notification_templateKey, _notification_notificationType, _notification_docTypeId,
_notification_toEntityId, _notification_toEmail, _notification_toSMS, _notification_fromEntityId,_notification_fromEmail, 
_readyDate, _expireDate, 
_notification_subject, _notification_content, 
_notification_attachmentURI1, _notification_attachmentURI2, _notification_attachmentURI3, _notification_attachmentURI4, _notification_attachmentURI5, _notification_attachmentURI6;
    
END IF;

END $$


DELIMITER ;




--- NODE API to insert into notification table
/*
var express = require("express");
var router = express.Router();
var getHeaderNode = require("../models/header.js").header;
var sendEmail = require("../helpers/sendNotification").sendEmail;
var sendSMS = require("../helpers/sendNotification").sendSMS;
var pool = require("../config/db.js");

var sql = "";
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

// @route   POST /update-queue
// @desc    post update-notification-queue
// @access  Private/Public
router.post("/update-queue", async function (req, res, next) {
  console.log("starting /update-queue -->", "req queries: ", req.query);

  var action = req.body.params.action || null;
  var toEmail = req.body.params.toEmail || null;
  var toSMS = req.body.params.toSMS || null;
  var content = req.body.params.content || null;
  var subject = req.body.params.subject || null;
  var toEntityId = req.body.params.toEntityId || null;
  var templateKey = req.body.params.templateKey || null;
  var fromEmail = req.body.params.fromEmail || "support@cancercare.dsdar.net";
  var notificationType = req.body.params.notificationType || "EMAIL";
  var docTypeId = req.body.params.docType || null;
  var readyDate = req.body.params.readyDate || null;
  var expireDate = req.body.params.expireDate || null;
  var notificationId = req.body.params.notificationId || null;
  var presentationId = req.body.params.presentationId || null;

  var campaignId = req.body.params.campaignId || null;
  var contractId = req.body.params.contractId || null;
  var orderId = req.body.params.orderId || null;

  var attachmentURI1 = req.body.params.attachmentURI1 || null;
  var attachmentURI2 = req.body.params.attachmentURI2 || null;
  var attachmentURI3 = req.body.params.attachmentURI3 || null;
  var attachmentURI4 = req.body.params.attachmentURI4 || null;
  var attachmentURI5 = req.body.params.attachmentURI5 || null;
  var attachmentURI6 = req.body.params.attachmentURI6 || null;

  let result = [];

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    let SQL =
      "call NOTIFICATION_notification(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    console.log("SQL --->", SQL);

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          notificationId,
          templateKey,
          notificationType,
          docTypeId,
          toEntityId,
          toEmail,
          toSMS,
          fromEmail,
          campaignId,
          contractId,
          orderId,
          presentationId,
          readyDate,
          expireDate,
          subject,
          content,
          attachmentURI1,
          attachmentURI2,
          attachmentURI3,
          attachmentURI4,
          attachmentURI5,
          attachmentURI6,
        ],
        (err, result) => {
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
            resolve(-1);
          } else {
            resolve(1);
          }
        }
      );
    });
  };

  if (isInError == 0) {
    result = await sqlFunction();

    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          header: header,
          results: result,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } else {
    // end isError
    console.log("post /update-queue ERROR ");
    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } // end isError
});

//==========================================================================
// @route   GET /queue-list
// @desc    get notification queue list
// @access  Private/Public
router.get("/queue-list", async function (req, res, next) {
  console.log("starting /search -->", "req queries: ", req.query);

  var action = req.body.params.action || null;

  let result = [];

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    let SQL =
      "call NOTIFICATION_notification(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null
        ],
        (err, result) => {
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
            resolve(result[0]);
          }
        }
      );
    });
  };

  if (isInError == 0) {
    result = await sqlFunction();

    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          header: header,
          results: result,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } else {
    // end isError
    console.log("get /queue-list ERROR ");

    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } // end isError
});

// @route   POST /send-mail
// @desc    post send-mail
// @access  Private/Public
router.post("/send-notification", async function (req, res, next) {
  console.log("starting /update-queue -->", "req queries: ", req.query);

  var action = req.body.params.action || "IMMEDIATE";
  var toEmail = req.body.params.toEmail || null;
  var toSMS = req.body.params.toSMS || null;
  var content = req.body.params.content || null;
  var subject = req.body.params.subject || null;
  var toEntityId = req.body.params.toEntityId || null;
  var templateKey = req.body.params.templateKey || null;
  var fromEmail = req.body.params.fromEmail || "support@dsdar.com";
  var notificationType = req.body.params.notificationType || "EMAIL";
  var readyDate = req.body.params.readyDate || null;
  var expireDate = req.body.params.expireDate || null;
  var notificationId = req.body.params.notificationId || null;

  var campaignId = req.body.params.campaignId || null;
  var contractId = req.body.params.contractId || null;
  var orderId = req.body.params.orderId || null;

  var attachmentURI1 = req.body.params.attachmentURI1 || null;
  var attachmentURI2 = req.body.params.attachmentURI2 || null;
  var attachmentURI3 = req.body.params.attachmentURI3 || null;
  var attachmentURI4 = req.body.params.attachmentURI4 || null;
  var attachmentURI5 = req.body.params.attachmentURI5 || null;
  var attachmentURI6 = req.body.params.attachmentURI6 || null;

  let result = [];

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  const getNotifications = async function (action, notificationId) {
    const SQL =
      "call NOTIFICATION_notification(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          notificationId,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null
        ],
        (err, result) => {
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
            resolve(result[0]);
          }
        }
      );
    });
  };

  const updateNotification = async function () {
    const SQL =
      "call NOTIFICATION_notification(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    console.log("SQL --->", SQL);

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          notificationId,
          templateKey,
          notificationType,
          docTypeId,
          toEntityId,
          toEmail,
          toSMS,
          fromEmail,
          campaignId,
          contractId,
          orderId,
          null,
          readyDate,
          expireDate,
          subject,
          content,
          attachmentURI1,
          attachmentURI2,
          attachmentURI3,
          attachmentURI4,
          attachmentURI5,
          attachmentURI6,
        ],
        (err, result) => {
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
            resolve(-1);
          } else {
            resolve(result[0]);
          }
        }
      );
    });
  };

  const acknowledgeQueue = async function (notificationId) {
    const SQL =
      "call NOTIFICATION_notification(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          "ACKNOWLEDGE",
          notificationId,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null
        ],
        (err, result) => {
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
            resolve(err);
          } else {
            resolve(result);
          }
        }
      );
    });
  };

  const sendNotification = async (notification) => {
    let notify = null;

    if (notification.notification_notificationType === "SMS") {
      notify = {
        notificationId: notification.notificationId,
        notificationType: notification.notification_notificationType,
        message: notification.notification_content,
        phoneNumber:
          (notification.notification_toSMS &&
            notification.notification_toSMS.toString()) ||
          "",
      };

      result = await sendSMS(notify);
    } else if (notification.notification_notificationType === "EMAIL") {
      notify = {
        notificationId: notification.notificationId,
        toEmail: notification.notification_toEmail,
        content: notification.notification_content,
        subject: notification.notification_subject,
        notificationType: notification.notification_notificationType,
        fromEmail: notification.notification_fromEmail || null,
      };

      result = await sendEmail(notify);
    }

    if (result === 1) {
      await acknowledgeQueue(notification.notificationId);
      return result;
    }
  };

  const sendImmediateNotification = async function () {
    if (!notificationId && action === "IMMEDIATE") {
      const data = await updateNotification();
      notificationId =
        (data && data.length > 0 && data[0].notificationId) || -1;
    }

    if (notificationId && notificationId > 0) {
      const notificationData = await getNotifications(
        "GET NOTIFICATION",
        notificationId
      );
      const notification =
        (notificationData &&
          notificationData.length > 0 &&
          notificationData[0]) ||
        null;

      if (notification) {
        sendNotification(notification);
      }
    } else if (action === "IMMEDIATE-NOTIFICATIONS") {
      const immediateNotifications = (await getNotifications(action)) || [];

      for (let i = 0; i < immediateNotifications.length; i++) {
        const notification = immediateNotifications[i];

        if (notification) {
          sendNotification(notification);
        }
      }
    }

    return result;
  };

  if (isInError == 0) {
    if (action) {
      result = await sendImmediateNotification();
    }

    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          header: header,
          results: result,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } else {
    // end isError
    console.log("get /send-email ERROR ");
    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } // end isError
});

// @route   POST /preview
// @desc    post preview the notification message
// @access  Private/Public
router.post("/preview", async function (req, res, next) {
  console.log("starting /preview -->", "req queries: ", req.body.params);

  var action = req.body.params.action || null;
  var notificationId = req.body.params.notificationId || null;
  var campaignResultId = req.body.params.campaignResultId || null;
  var presentationId = req.body.params.presentationId || null;
  var templateKey = req.body.params.templateKey || null;
  var notificationType = req.body.params.notificationType || null;
  var content = req.body.params.content || null;
  let toEntityId = req.body.params.toEntityId || null;
  let clientId = req.body.params.clientId || null;
  let fromEmail = req.body.params.fromEmail || null;

  let result = [];

  isInError = 0;
  isErrorMsg = "";
  isErrorCode = "";

  let sqlFunction = function () {
    let SQL =
      "call NOTIFICATION_buildMessage(?,?,?,?,?,?,?,?,?,?)";
      
    console.log("SQL --->", SQL);

    return new Promise((resolve, reject) => {
      pool.query(
        SQL,
        [
          action,
          notificationId,
          campaignResultId,
          presentationId,
          templateKey,
          notificationType,
          content,
          toEntityId,
          clientId,
          fromEmail
        ],
        (err, result) => {
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
           // resolve(-1);
          } else {
            resolve(result[0]);
           // resolve(1);
          }
        }
      );
    });
  };

  if (isInError == 0) {
    result = await sqlFunction();

    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          header: header,
          results: result,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } else {
    // end isError
    console.log("post /preview ERROR ");
    getHeaderNode(isErrorCode, isErrorMsg)
      .then((header) => {
        let response = {
          isErrorMsg: isErrorMsg,
        };
        res.send(response);
      })
      .catch((err) => {
        res.send(err);
      });
  } // end isError
});

module.exports = router;


*/