const axios = require('axios');
const path = require('path');
const pdfMake = require('pdfmake');
const fs = require('fs');
const mime = require('mime-types');

const downloadPDFFromS3 = async(url, destinationPath)=> {
    const fontDescriptors = {
        Roboto: {
          normal: path.join(
            __dirname,
            "..",
            "./",
            "routes",
            "./",
            "/fonts/Roboto-Regular.ttf"
          ),
          bold: path.join(
            __dirname,
            "..",
            "./",
            "routes",
            "./",
            "/fonts/Roboto-Medium.ttf"
          ),
          italics: path.join(
            __dirname,
            "..",
            "./",
            "routes",
            "./",
            "/fonts/Roboto-Italic.ttf"
          ),
          bolditalics: path.join(
            __dirname,
            "..",
            "./",
            "routes",
            "./",
            "/fonts/Roboto-MediumItalic.ttf"
          ),
        },
      };
       
      const data = {
        pageSize: "A4",
        pageOrientation: "landscape",
        pageSize:  { width: 1010, height: 900.8897637795275 },
  
        content: '',
        styles: {
          tableSumStyle: {
            bold: true,
            fontSize: 14,
            color: "black",
          },
          tableStyle: {
            fontSize: 14,
            color: "black",
          },
          tableHeader: {
            bold: true,
            fontSize: 15,
            color: "black",
          },
        },
      };

     
     
    const response = await axios({
      method: 'GET',
      url: url,
      responseType: 'arraybuffer',
    });
    const fileExtension = mime.extension(response.headers['content-type']);
    
    let fileDestinationPath = destinationPath + '.' + fileExtension
    if (fileExtension == 'pdf'){
        try {
            let printer = new pdfMake(fontDescriptors);
            let pdfDoc = printer.createPdfKitDocument(data);
            pdfDoc.pipe(fs.createWriteStream( fileDestinationPath), { encoding:'utf16' });
            pdfDoc.end();
          } catch (error) {
            console.log(error)
          }
    }
  
    fs.writeFileSync(fileDestinationPath, Buffer.from(response.data, 'binary'));
    return fileExtension
  }


  exports.downloadPDFFromS3 = downloadPDFFromS3;