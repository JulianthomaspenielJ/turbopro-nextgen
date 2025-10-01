var express = require("express");
var router = express.Router();
var pool = require("../config/db.js");
var getHeaderNode = require("../models/header.js").header;
// const recruitNode = require("../models/recruit.js").recruitNode;

var sql = "";
var isInError = 0;
var isErrorMsg = "";
var isErrorCode = "";

// ===============================================

// @route   POST /picklist
// @desc    gets picklist for select comps
// @access  Private/Public
router.post("/get_doc_type", async function (req, res, next) {
	// const id = req.query.id || null;
	const type = req.body.params && req.body.params.type || "";
	const fetchAll = req.body.fetchAll && req.body.fetchAll || 0;

	let result = [];

	isInError = 0;
	isErrorMsg = "";
	isErrorCode = "";

	let sqlFunction = function () {

		let SQL = "call ATT_getPicklist(?,?,?)";
		console.log("SQL --->", SQL);

		return new Promise((resolve, reject) => {
			pool.query(SQL, [type, null, fetchAll], (err, result) => {
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
					resolve(result);
				}
			});
		});
	};

	if (isInError == 0) {
		result = await sqlFunction();
		getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
			if (err) {
				res.send(err);
			} else {
				var response = {
					header: header,
					results: result
				}
				res.send(response);
			}

		});

		// getHeaderNode(isErrorCode, isErrorMsg)
		// 	.then((header) => {
		// 		let response = {
		// 			header: header,
		// 			results: result,
		// 		};
		// 		res.send(response);
		// 	})
		// 	.catch((err) => {
		// 		res.send(err);
		// 	});
	} else {
		// end isError
		console.log("get /picklist ERROR ");
		getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
			if (err) {
				res.send(err);
			} else {
				var response = {
					isErrorMsg: isErrorMsg
				}
				res.send(response);
			}
		});
		// getHeaderNode(isErrorCode, isErrorMsg)
		// 	.then((header) => {
		// 		let response = {
		// 			isErrorMsg: isErrorMsg,
		// 		};
		// 		res.send(response);
		// 	})
		// 	.catch((err) => {
		// 		res.send(err);
		// 	});
	} // end isError
});
// router.post("/get_doc_type", async function (req, res, next) {
// 	const type = req.body.params && req.body.params.type || "";
// 	const fetchAll = req.body.params && req.body.params.fetchAll || 0;
// 	let result = [];
// 		let sqlFunction = function () {
// 			let SQL = "call ATT_getPicklist(?,?,?)";
// 			console.log("SQL --->", SQL);
// 			return new Promise((resolve, reject) => {
// 				pool.query(SQL, [type, null, fetchAll], (err, result) => {
// 					if (err) {
// 						console.log("error:", err);
// 						isInError = 1;
// 						isErrorCode = "FILTER_ERROR";
// 						if (err.sqlState == 41001) {
// 							isErrorMsg = "Make sure to provide your login.";
// 						} else {
// 							isErrorMsg =
// 								err.sqlState +
// 								": We had difficulty performaing this action.  Pleae report his number to your contact.";
// 						}
// 						resolve("");
// 					} else {
// 						resolve(result);
// 					}
// 				});
// 			});
// 		};
	  
// 	  if (isInError == 0) {
// 		result = await sqlFunction();
// 		getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
// 			if(err){
// 				res.send(err);
// 			}else{
// 				var response = {
// 				header : header,
// 				results : result
// 				}                    
// 				res.send(response);
// 			}
			
// 		});
// 	  } else {
// 		// end isError
// 		console.log("get /picklist ERROR ");
// 		getHeaderNode(isErrorCode, isErrorMsg, (err, header) => {
// 			if(err){
// 			  res.send(err);
// 			}else{
// 			  var response = {
// 				isErrorMsg : isErrorMsg
// 			  }                    
// 			  res.send(response);
// 			}
// 		  });
// 	} // end isError
//   });



module.exports = router;
