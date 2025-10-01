var fs = require("fs");
const AWS = require("aws-sdk");
const AmazonS3URI = require("amazon-s3-uri");
const { getBucket } = require("./getBucketName");

const BUCKET_NAME = "tp-client-documents";
const ACCESS_KEY_ID = "AKIAIRAKEFEDIHVTNXAA";
const SECRET_ACCESS_KEY = "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";

const s3bucket = new AWS.S3({
  accessKeyId: ACCESS_KEY_ID,
  secretAccessKey: SECRET_ACCESS_KEY,
});

const uploadFileToS3 = async (file,bucketType, path = null) => {
  bucketType='QUOTE'
  await getBucket(bucketType)
  .then((documentBuckets) => {
    console.log("Retrieved documentBuckets:", documentBuckets);
    path= documentBuckets
  })
  .catch((error) => {
    console.log("Error occurred while retrieving documentBuckets:", error);
  });
  const uploadOnDebug = 0;

  let filePath = "";

  filePath = path + "/" + file.originalname + "_" + Date.parse(new Date());

  const params = {
    Bucket: BUCKET_NAME,
    Key: filePath,
    Body: file.buffer,
    ContentType: file.mimetype
  };

  return new Promise((resolve, reject) => {
    if (uploadOnDebug === 1) {
      console.log(
        "<==================== UPLOAD FILE ON DEBUG MODE - NOT UPLOADED!"
      );
      resolve(1);
    } else {
      s3bucket.upload(params, function (err, result) {
        if (err) {
          console.log("<==================== FILE UPLOADED FAILED!");
          return reject(err);
        }

        console.log("<==================== FILE UPLOADED SUCCESSFULLY!");
        return resolve(result);
      });
    }
  });
};

const readFile = async (fileName, path = null) => {
  await getBucket()
  .then((documentBuckets) => {
    console.log("Retrieved documentBuckets:", documentBuckets);
    BUCKET_NAME= documentBuckets.BUCKET_NAME
  })
  .catch((error) => {
    console.log("Error occurred while retrieving documentBuckets:", error);
  });
  let filePath = "";

  if (path) {
    filePath = path;
  } else {
    filePath = "UAT/" + fileName;
  }

  const params = {
    Bucket: BUCKET_NAME,
    Key: decodeURIComponent(filePath),
  };

  return new Promise((resolve, reject) => {
    s3bucket.getObject(params, function (err, data) {
      if (err) {
        reject(err);
      } else {
        console.log("Successfully dowloaded data from  bucket");
        resolve(data);
      }
    });
  });
};

const deleteFile = async (fileName, path = null) => {
  await getBucket()
  .then((documentBuckets) => {
    console.log("Retrieved documentBuckets:", documentBuckets);
    BUCKET_NAME= documentBuckets.BUCKET_NAME
  })
  .catch((error) => {
    console.log("Error occurred while retrieving documentBuckets:", error);
  });
  let filePath = "";

  if (path) {
    filePath = path;
  } else {
    filePath = "UAT/" + fileName;
  }
  const params = {
    Bucket: BUCKET_NAME,
    Key: filePath,
  };

  return new Promise((resolve, reject) => {
    s3bucket.deleteObject(params, function (err, data) {
      if (err) {
        reject(err);
      } else {
        console.log("Successfully deleted data from  bucket");
        resolve(data);
      }
    });
  });
};

const getSignedUrl = async (fileName, path = null) => {

  const { bucket, key } = AmazonS3URI(fileName)
        const params = {
          Bucket: bucket,
          Key: key,
          Expires: (60 * 10)
        };
  return new Promise((resolve, reject) => {
    const url = s3bucket.getSignedUrl("getObject", params);
    resolve(url);
  });
};
const getfilesize = async (fileName, path = null) => {

  const { bucket, key } = AmazonS3URI(fileName)
        const params = {
          Bucket: bucket,
          Key: key,
        };
        return new Promise((resolve, reject) => {
          const data =  s3bucket.headObject(params, (err, data) => {
            if (err) {
              reject(err);
              return;
            }
          resolve(data.ContentLength);
          });
        });
 
};


exports.deleteFile = deleteFile;
exports.readFile = readFile;
exports.getSignedUrl = getSignedUrl;
exports.uploadFileToS3 = uploadFileToS3;
exports.getfilesize = getfilesize;