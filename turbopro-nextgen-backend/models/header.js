
  var getHeaderNode = function(code, msg, headerCallback){
    //console.log("Header Node");
    var header = {
      "message": msg,
      "errorMessage": "",
      "errorCode": "0"
    }      


    var getErrorCode = function(){
      return new Promise(function(resolve, reject){
        //console.log("Error code function");
        if(code){
          //console.log("is Code True");
          switch(code){
            case "INVALID_PASSWORD" : {
              header.message = "Password Is Invalid.";
              header.errorCode = 1
              break;
            }
            case "LOGIN_FAILED" : {
              header.message = "Login failed, please confirm your email and password and the account is active.";
              header.errorCode = 1
              break;
            }
            case "INVALID_KEY_URL" : {
              header.message = "A new version is available, please download. <br><br><a href='https://www.google.com/url?q=https%3A%2F%2Fsites.google.com%2Fdsdar.com%2Fryder-compliance-app%2Fhome&sa=D&sntz=1&usg=AFQjCNFZtzXhrm80YHW3uE76EX4QwwngfQ'>Click here to download</a>";
              header.errorCode = 404
              break;
            }
            case "INVALID_CONTACT" : {
              header.message = "This contact was not found in the system.";
              header.errorCode = 1
              break;
            }
            case "CONNECTION_ERROR" : {
              header.message = "There is a problem connecting to server, please try again.";
              break;
            }
            case "OPERATION_FAILED" : {
              header.message = "Failed to perform the operation, please try again.";
              break;
            }
           case "INVALID_DATA" : {
              header.message = "Your parameters appear to be invalid.";
              header.errorCode = 1
              break;
            }
            case "INVALID_EMAIL" : {
              header.message = "Please check the eamil used, it was not found.";
              header.errorCode = 1
              break;
            }
           case "FILTER_ERROR" : {
              header.errorCode = 1
              break;
            }
            case "FILE_UPDATE_ERRO" : {
              header.errorCode = 1    
              break;
            }
            case "UPLOAD_ERROR" : {
              header.errorCode = 1    
              break;
            }
            case "UPDATE_ERROR" : {
              header.errorCode = 1    
              break;
            }
             default : {
              header.message = "";
              break;  
            }
          }
          return resolve();
        }else{
          return resolve();        
        }
      })
    }

    Promise.all([getErrorCode()])
    .then(function(allData){          
      //console.log("header from promise all", header);
      headerCallback(null, header);
    })
    .catch(function(err){
      console.log(err);
      headerCallback(err, null);
    })
  }

  exports.header = getHeaderNode;