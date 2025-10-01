require("dotenv").config();
const express = require("express");
const router = express.Router();
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const { OpenAI } = require("openai");
const mysql = require("mysql2/promise");
const { spawn } = require("child_process");
const winston = require("winston");

const getHtmlString = require("../helper/getHtmlString");
const { processFileJsonSections } = getHtmlString;
const {refreshCard} = require('../helper/refreshCard')

// Logger setup
const logger = winston.createLogger({
  level: "debug",
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: "logs/file-processing.log" }),
    new winston.transports.Console(),
  ],
});

// These lines simulate __dirname and __filename
// const __filename = fileURLToPath(import.meta.url);
// const __dirname = dirname(__filename);

// Upload directory setup
const upload = multer({ dest: "uploads/" });
const uploadDir = path.join(__dirname, "..", "uploads");
if (!fs.existsSync(uploadDir)) fs.mkdirSync(uploadDir);

// Logs directory setup
const logsDir = path.join(__dirname, "..", "logs");
if (!fs.existsSync(logsDir)) fs.mkdirSync(logsDir);

// OpenAI client
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// MySQL pool setup
const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  connectTimeout: 10000,
  decimalNumbers: true,
});

// Python script to extract data from PDF and Excel
const pythonExtractorScript = `
import pdfplumber
import camelot
import pandas as pd
import json
import sys
import os
import re

def determine_document_type(text_content):
    # Keywords for PO_Acknowledgement
    ack_keywords = [
        r'\\backnowledgement\\b', r'\\bpo number\\b', r'\\border confirmation\\b', 
        r'\\bbill to\\b', r'\\bfrieght\\b', r'\\border date\\b', r'\\bsub total\\b',
        r'\\bship date\\b', r'\\back date\\b', r'\\bquantity\\b', r'\\btotal cost\\b',
         r'\\bship to\\b', r'\\bitem\\b', r'\\border id\\b',
        r'\\bunit cost\\b', r'\\bcustomer po\\b', r'\\bcust po\\b', 
        r'\\bshipping address\\b', r'\\bpurchase order\\b', r'\\bunit price\\b',
    ]
    
    # Keywords for BidList
    bid_keywords = [
        r'\\bproject name\\b', r'\\bbid date\\b', r'\\bbid status\\b', r'\\bjob name\\b',
        r'\\bjob number\\b', r'\\bvendors\\b', r'\\bbidder\\b', r'\\bestimator\\b', r'\\bcontact\\b'
    ]
    
    text = text_content.lower().strip()
    if not text:
        return "Unknown", {"ack_matches": 0, "bid_matches": 0, "text_length": len(text)}
    
    # Count keyword matches
    ack_matches = sum(1 for keyword in ack_keywords if re.search(keyword, text, re.IGNORECASE))
    bid_matches = sum(1 for keyword in bid_keywords if re.search(keyword, text, re.IGNORECASE))
    
    # Log keyword matches for debugging
    debug_info = {
        "ack_matches": ack_matches,
        "bid_matches": bid_matches,
        "text_length": len(text),
        "sample_text": text[:500]  # First 500 chars for context
    }
    
    # Determine document type based on keyword prevalence
    if ack_matches >= 3:
        return "PO_Acknowledgement", debug_info
    elif bid_matches >= 3:
        return "BidList", debug_info
    else:
        return "Unknown", debug_info

def extract_pdf(pdf_path):
    try:
        # Initialize result dictionary
        result = {
            "tables": [],
            "text": [],
            "key_value_pairs": [],
            "documentType": "Unknown",
            "debugInfo": {}
        }
        
        # Extract text using pdfplumber
        full_text = ""
        with pdfplumber.open(pdf_path) as pdf:
            for page in pdf.pages:
                # Extract raw text
                text = page.extract_text()
                if text:
                    result["text"].append({"page": page.page_number, "content": text})
                    full_text += text + " "
                
                # Extract key-value pairs
                words = page.extract_words()
                for i in range(len(words) - 1):
                    if ":" in words[i]["text"] or "=" in words[i]["text"]:
                        key = words[i]["text"].strip(":=")
                        value = words[i + 1]["text"] if i + 1 < len(words) else ""
                        result["key_value_pairs"].append({
                            "page": page.page_number,
                            "key": key,
                            "value": value
                        })
        
        # Determine document type
        result["documentType"], result["debugInfo"] = determine_document_type(full_text)
        
        # Extract tables using camelot
        tables = camelot.read_pdf(pdf_path, pages="all", flavor="stream")
        for i, table in enumerate(tables):
            result["tables"].append({
                "page": table.page,
                "data": table.df.to_dict("records")
            })
        
        return result
    except Exception as e:
        return {"error": str(e), "documentType": "Unknown", "debugInfo": {}}

def extract_excel(excel_path):
    try:
        result = {
            "sheets": [],
            "documentType": "Unknown",
            "debugInfo": {}
        }
        excel_file = pd.ExcelFile(excel_path)
        full_text = ""
        for sheet_name in excel_file.sheet_names:
            df = pd.read_excel(excel_path, sheet_name=sheet_name, dtype=str).fillna("")
            data = df.values.tolist()
            result["sheets"].append({
                "sheet_name": sheet_name,
                "data": data
            })
            # Concatenate all cell content, handling various data types
            for row in data:
                for cell in row:
                    if isinstance(cell, (int, float, bool)):
                        cell = str(cell)
                    if cell:
                        full_text += cell + " "
        
        # Clean up text: remove extra spaces, normalize
        full_text = re.sub(r'\\s+', ' ', full_text).strip()
        
        # Determine document type
        result["documentType"], result["debugInfo"] = determine_document_type(full_text)
        
        return result
    except Exception as e:
        return {"error": str(e), "documentType": "Unknown", "debugInfo": {}}

def main():
    file_path = sys.argv[1]
    ext = os.path.splitext(file_path)[1].lower()
    
    if ext == ".pdf":
        result = extract_pdf(file_path)
    elif ext in [".xlsx", ".xls", ".csv"]:
        result = extract_excel(file_path)
    else:
        result = {"error": "Unsupported file type", "documentType": "Unknown", "debugInfo": {}}
    
    print(json.dumps(result))

if __name__ == "__main__":
    main()
`;

router.post("/fileContents", upload.single("file"), async (req, res) => {
  const startTime = Date.now();
  const file = req.file;
  const userId = req.body.userId;
  const requestId = req.headers["x-request-id"] || `req-${Date.now()}`;

  logger.info(
    `Starting file processing for ${file?.originalname || "unknown"}`,
    { requestId }
  );

  // Validate file type
  const validExtensions = [".pdf", ".xlsx", ".xls", ".csv"];
  if (
    !file ||
    !validExtensions.includes(path.extname(file.originalname).toLowerCase())
  ) {
    logger.error("Invalid file type", {
      requestId,
      fileName: file?.originalname,
    });
    return res.status(400).json({
      data: {
        parseSuccess: false,
        fileName: file?.originalname || null,
        documentType: "Unknown",
        error: "Invalid file type. Only PDF and Excel files are allowed.",
      },
    });
  }

  let targetPath;
  try {
    // Rename file to include original extension
    const originalExt = path.extname(file.originalname).toLowerCase();
    const tempPath = file.path;
    targetPath = `${tempPath}${originalExt}`;
    fs.renameSync(tempPath, targetPath);
    logger.info(`File renamed to ${targetPath}`, { requestId });

    // Run Python script to extract data
    logger.info("Starting Python extraction", { requestId });
    const pythonProcess = spawn("python", [
      "-c",
      pythonExtractorScript,
      targetPath,
    ]);

    let extractedData = "";
    let pythonError = "";

    pythonProcess.stdout.on("data", (data) => {
      extractedData += data.toString();
    });

    pythonProcess.stderr.on("data", (data) => {
      pythonError += data.toString();
    });

    await new Promise((resolve, reject) => {
      pythonProcess.on("close", (code) => {
        if (code !== 0) {
          logger.error(`Python extraction failed: ${pythonError}`, {
            requestId,
          });
          reject(
            new Error(`Python process exited with code ${code}: ${pythonError}`)
          );
        } else {
          resolve();
        }
      });
    });

     let parsedData;
    try {
      parsedData = JSON.parse(extractedData);
      logger.info("Extracted data", { 
        requestId, 
        documentType: parsedData.documentType,
        debugInfo: parsedData.debugInfo 
      });
    } catch (e) {
      logger.error(`Failed to parse Python output: ${e.message}`, { requestId });
      throw new Error(`Failed to parse extracted data: ${e.message}`);
    }

    if (parsedData.error) {
      logger.error(`Extraction error: ${parsedData.error}`, { requestId });
      throw new Error(parsedData.error);
    }

    // Extract document type from Python output
    const documentType = parsedData.documentType || "Unknown";
    logger.info(`Document type determined by Python: ${documentType}`, { 
      requestId, 
      debugInfo: parsedData.debugInfo 
    });

    // If document type is Unknown, return early with debug info
    if (documentType === "Unknown") {
      logger.warn("Unsupported document type detected", { 
        requestId, 
        debugInfo: parsedData.debugInfo 
      });
      return res.status(400).json({
        data: {
          parseSuccess: false,
          fileName: file.originalname,
          documentType: "Unknown",
          error: "Unsupported document type. Only Acknowledgement and Bid List documents are accepted.",
          debugInfo: parsedData.debugInfo
        },
      });
    }

    let instructions = "";
if (documentType === "PO_Acknowledgement") {
  instructions = `
You are a document parser that converts extracted data from PDFs and Excel files
 into structured JSON. The input contains raw extracted data (tables, text, key-value pairs) The input contains raw extracted data (tables, text, key-value pairs) 
 and a determined document type ("PO_Acknowledgement"). Your task is to process the data accordingly and return the structured JSON in this format:
1. For "purchase order" phrases, only treat text containing exactly “purchase order” followed by a number or code (e.g., “Purchase Order: KKT130913C”) as valid poNumber.
2. For quantities, only *recognize terms like "qty", "qty ordered", "qty shipped", "total count", "count", "sum", "qty needed". Sum multiple line items for totalQuantity.
3. Map "ack date" to "Acknowledgement Date" and "est ship date" to "Ship Date".
Expected JSON Outputs:
{
  "documentType": "PO_Acknowledgement",
  "isSigned": true or false,
  "poNumber": "string or null",
  "ackDate": "MM-DD-YYYY or null",
  "shipDate": "MM-DD-YYYY or null",
  "totalQuantity": "string or null",
  "totalAmount": "string or null",
  "customerPO": "string or null",
  "orderNumber": "string or null",
  "companyName": "string or null",
  "clientName": "string or null",
  "clientId": "string or null",
  "shipTo": "string or null",
  "soldTo": "string or null",
  "billTo": "string or null",
  "orderedDate": "MM-DD-YYYY or null",
  "orderedBy": "string or null",
  "projectName": "string or null",
  "projectNo": "string or null",
  "FreightType": "string or null",
  "shipVia": "string or null",
  "contactName": "string or null",
  "contactEmailAddress": "string or null",
  "contactPhone": "string or null",
  "items": [
    {
      "quantity": "string or null",
      "unitCost": "string or null",
      "totalCost": "string or null",
      "description": "string or null",
      "shipDate": "MM-DD-YYYY or null",
      "tax": "string or null",
      "discount": "string or null",
      "position": "string or null"
    }
  ]
}
`;
} else if (documentType === "BidList") {
  instructions = `
You are a document parser that converts extracted data from PDFs and Excel files into structured JSON. The input contains raw extracted data (tables, text, key-value pairs) and a determined document type ("BidList"). Your task is to process the data accordingly and return the structured JSON in this format:
- Treat "est" as jobNumber
- Treat "Contact" and "Estimator" as contact
- Treat "Project Name" as jobName
- Return the complete JSON with no missing extracted values.
Expected JSON Outputs:
{
  "documentType": "BidList",
  "job": [
    {
      "jobName": "string or null",
      "customerName": "string or null",
      "jobNumber": "string or null",
      "bidDate": "MM-DD-YYYY or null",
      "jobStatus": "string or null",
      "bidders": [
        {
          "bidder": "string or null",
          "contact": "string or null",
          "jobNumber": "string or null",
          "from": "string or null"
        }
      ]
    }
  ]
}
`;
} else {
  // Fallback
  instructions = `Document type is unknown. Please return an error with message "Unsupported document type."`;
}


    // Create Assistant with instructions
    const assistant = await openai.beta.assistants.create({
      name: "Document_Parser",
      instructions,
      model: "gpt-4o",
      tools: [],
    });
    logger.info("Assistant created", { requestId, assistantId: assistant.id });

    // Create Thread with extracted data
    const thread = await openai.beta.threads.create({
      messages: [
        {
          role: "user",
          content: `Process this extracted data and return the structured JSON output as per the instructions. Ensure no data is missed:
${JSON.stringify(parsedData, null, 2)}`,
        },
      ],
      metadata: {
        source: "fileContentsAPI",
        fileName: file.originalname,
        requestId,
      },
    });
    logger.info("Thread created", { requestId, threadId: thread.id });

    // Run & wait for result
    const run = await openai.beta.threads.runs.createAndPoll(thread.id, {
      assistant_id: assistant.id,
      metadata: {
        fileName: file.originalname,
        trace: "fileUpload-debug",
        userId: "5",
      },
    });
    logger.info("Run completed", { requestId, runId: run.id });

    // Retrieve result
const messages = await openai.beta.threads.messages.list(thread.id);
   if (!messages.data.length) {
      return res.status(500).json({
        data: {
          documentType: "Unknown",
          error: "No response received from assistant.",
        },
      });
    }

// const rawReply = messages.data[0].content[0]?.text?.value;
    const rawReply = messages.data.find((m) => m.role === "assistant")
      ?.content[0]?.text?.value;
logger.info("Assistant raw reply", { requestId, rawReply });

let resultJson;
 try {
      // Extract JSON from markdown or text
      const cleanedReply = rawReply
        .replace(/```json|```/g, "")
        .replace(/\/\/.*$/gm, "")
        .trim();

      const jsonMatch = cleanedReply.match(/{[\s\S]*}/);

      if (!jsonMatch) {
        throw new Error("No valid JSON found in response");
      }
      const jsonString = jsonMatch[0];
      resultJson = JSON.parse(jsonString);
    } catch (e) {
      // Pass OpenAI error to procedure
      resultJson = {
        documentType: "Unknown",
        error: "Failed to parse JSON response from assistant: " + e.message,
      };
    }

    // Map OpenAI response to DOCUMENT_processor JSON format
    let docJson;
    let action;
    const isAcknowledgement = resultJson.documentType === "PO_Acknowledgement";
    const isBidList = resultJson.documentType === "BidList";
    const parseSuccess = isAcknowledgement || isBidList;

    if (isAcknowledgement) {
      action = "ACKNOWLEDGEMENT";
      const parsedAmount = resultJson.totalAmount
        ? resultJson.totalAmount.replace(/[$,]/g, "").replace(/USD|usd/g, "")
        : null;

      docJson = JSON.stringify({
        documentType: resultJson.documentType || null,
        poNumber: resultJson.poNumber || null,
        totalAmount: parsedAmount ? parseFloat(parsedAmount) : null,
        vendorOrderNumber: resultJson.orderNumber || null,
        ackDate: resultJson.ackDate || null,
        shipDate: resultJson.shipDate || null,
        items: resultJson.items.map((item) => ({
          qty: item.quantity
            ? parseFloat(item.quantity.replace(/[^0-9.]/g, ""))
            : null,
          Description: item.description || null,
          unitCost: item.unitCost
            ? parseFloat(
              item.unitCost.replace(/[$,]/g, "").replace(/USD|usd/g, "")
            )
            : null,
        })),
      });
    } else if (isBidList) {
      action = "BID_LIST";
      const jobs = resultJson.job || [];
      const mappedJobs = jobs.map((job) => ({
        jobName: job.jobName || null,
        customerName: job.customerName || null,
        jobNumber: job.jobNumber || null,
        bidDate: job.bidDate || null,
        jobStatus: job.jobStatus || null,
        bidders: (job.bidders || []).map((bidder) => ({
          bidder: bidder.bidder || null,
          contact: bidder.contact || null,
          jobNumber: bidder.jobNumber || null,
          from: bidder.from || null,
        })),
      }));

      docJson = JSON.stringify({
        documentType: "BidList",
        job: mappedJobs,
      });
    } else {
      action = "UNKNOWN";
      docJson = JSON.stringify({
        documentType: resultJson.documentType || null,
        error: resultJson.error || "Unsupported document type.",
      });
    }

    logger.info("JSON sent to procedure", { requestId, docJson });

    try {
      // Call DOCUMENT_processor stored procedure
      if (!docJson) {
        logger.error("Error: docJson not found")
        throw new Error("docJson not found");
      }
      const [rows] = await pool.query("CALL DOCUMENT_processor(?, ?, ?, ?)", [
        action,
        docJson,
        5, // _userId
        15, // _debug
      ]);

      logger.info("Raw procedure result", {
        requestId,
        procedureResult: rows[0][0],
      });
      const procedureResult =
        rows[0] && rows[0][0] && rows[0][0].result
          ? typeof rows[0][0].result === "string"
            ? JSON.parse(rows[0][0].result)
            : rows[0][0].result
          : {};
      let mainJson = {};
      if (resultJson.documentType === "BidList") {
        try {
          if (process.env.SERVER = 'nextgen') {
            // **** PROCEDURE CALL TO - Process data and create Html****
            const response = await pool.query("CALL JOB_bidllist_processor(?,?,?,?)", [
              action,
              docJson,
              5,
              0
            ])

            const fileProcessingJson = response[0][0][0].result.fileProcessingJson;
            mainJson = fileProcessingJson
            const htmlString = await processFileJsonSections(fileProcessingJson);
            procedureResult.fileProcessingMsg = htmlString;
            procedureResult.fileProcessingJson = mainJson;
           await refreshCard(pool ,16,userId); 
            
          } else if (process.env.SERVER = 'legacy') {
            const jobList = docJson.job || [];
            const newJobs = [];
            const updatedJobs = [];
            const errorJobs = [];
            const newBidders = [];
            const updatedBidders = [];
            const errorBidders = [];

            for (const job of jobList) {
              const {
                jobNumber = null,
                customerName = null,
                bidDate = null,
                bidders = [],
              } = job;

              let _joMasterId = null;
              let _customerId = null;
              let _jobStatus = 0;
              let _salesRep = null;

              // **** PROCEDURE CALL TO - Process Jobs ****
              const [jobRes] = await pool.query("CALL JOB_bidllist_upsert(?,?,?,?,?,?,?,?,?,@responseJson); SELECT @responseJson AS responseJson;", [
                jobNumber, _joMasterId, customerName, _customerId,
                bidDate, _jobStatus, _salesRep, userId, 0
              ]);

              const responseJson = JSON.parse(jobRes[1][0].responseJson);
              const responseCode = responseJson.code;

              if (responseCode === '1') {
                newJobs.push(responseJson);
              } else if (responseCode === '0') {
                updatedJobs.push(responseJson);
              } else {
                errorJobs.push(responseJson);
              }

              // Update jobNumber and joMasterId from response
              const returnedJobNumber = responseJson.jobNumber;
              const returnedJoMasterId = parseInt(responseJson.joMasterId);

              // Call JOB_bidllist_bidder_upsert for each bidder
              // **** PROCEDURE CALL TO - Process Bidders ****

              for (const bidder of bidders) {
                const contact = bidder.contact || null;
                const bidderName = bidder.bidder || null;

                const [bidderRes] = await pool.query("CALL JOB_bidllist_bidder_upsert(?,?,?,?,?,?,@responseJson); SELECT @responseJson AS responseJson;", [
                  returnedJoMasterId, returnedJobNumber, contact, bidderName, userId, 0
                ]);

                const bidderResponseJson = JSON.parse(bidderRes[1][0].responseJson);
                const bidderCode = bidderResponseJson.code;

                if (bidderCode === '1') {
                  newBidders.push(bidderResponseJson);
                } else if (bidderCode === '0') {
                  updatedBidders.push(bidderResponseJson);
                } else {
                  errorBidders.push(bidderResponseJson);
                }
              }
            }

            mainJson = {
              newJobs,
              updatedJobs,
              errorJobs,
              newBidders,
              updatedBidders,
              errorBidders,
            };
            const htmlString = await processFileJsonSections(fileProcessingJson);
            procedureResult.fileProcessingMsg = htmlString;
            procedureResult.fileProcessingJson = mainJson;

          }

        } catch (error) {
          console.log('error occured bids processing ', error)
        }
      }

      return res.status(200).json({
        data: {
          parseSuccess,
          fileName: file.originalname,
          openAIModelUsed: "gpt-4o",
          processingTimeMs: Date.now() - startTime,
          procedureResult,
          openAIResponse: resultJson,
        },
      });
    } catch (dbErr) {
      logger.error(`Error : ${dbErr.message}`, { requestId });
      return res.status(500).json({
        data: {
          parseSuccess: false,
          fileName: file?.originalname || null,
          documentType: "Unknown",
          error: "Database error: " + dbErr.message,
        },
      });
    }
  } catch (err) {
    logger.error(`Error processing file: ${err.message}`, { requestId });
    return res.status(500).json({
      data: {
        parseSuccess: false,
        fileName: file?.originalname || null,
        documentType: "Unknown",
        error: `Failed to process file: ${err.message}`,
      },
    });
  } finally {
    // Clean up uploaded file
    if (targetPath && fs.existsSync(targetPath)) {
      fs.unlinkSync(targetPath);
      logger.info(`Cleaned up file: ${targetPath}`, { requestId });
    }
  }
});

module.exports = router;
