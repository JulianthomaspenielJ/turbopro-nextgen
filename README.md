"# TurboProAI" 
PO_Bid_Document_Parser
Overview
This project provides a full-stack application for uploading and analyzing PDF documents, specifically designed to process Purchase Order Acknowledgements and Bid Lists. The backend, located in the turboproAI-nextgen-backend folder, uses Node.js with Express to handle file uploads and integrates with OpenAI's API to extract structured data from PDFs. The extracted data is processed and stored via a MySQL stored procedure (DOCUMENT_processor). The frontend, located in the turboproAI-nextgen-frontend folder, is a React application that allows users to drag and drop PDF files, displaying the analysis results with a user-friendly interface using Tailwind CSS and React Toastify for notifications.
Features

File Upload: Accepts PDF files via drag-and-drop or file selection.
Document Analysis: Uses OpenAI's GPT-4o model to parse PDFs and identify document types (PO Acknowledgement or Bid List).
Data Extraction: Extracts structured JSON data (e.g., PO number, quantities, dates, etc.) based on predefined rules.
Database Integration: Stores parsed data in a MySQL database using a stored procedure.
User Feedback: Displays real-time feedback with loading states and error notifications.

Prerequisites

Node.js (v14 or higher)
MySQL (v8 or higher)
OpenAI API Key (configured in .env)
Git (for cloning the repository)

Installation

Clone the Repository
git clone <repository-url>
cd pdf-document-parser


Install Backend DependenciesNavigate to the backend directory:
cd turboproAI-nextgen-backend
npm install

Set Up Environment VariablesCreate a .env file in the turboproAI-nextgen-backend directory and add the following:
DB_HOST=<your-mysql-host>
DB_USER=<your-mysql-user>
DB_PASSWORD=<your-mysql-password>
DB_NAME=<your-mysql-database>
OPENAI_API_KEY=<your-openai-api-key>

Note: Replace <your-mysql-*> with your MySQL configuration and <your-openai-api-key> with your OpenAI API key.

Set Up MySQL Database

Ensure MySQL is running.
Connect to NextGen2 database


Install Frontend Dependencies Navigate to the frontend directory and install dependencies:
cd turboproAI-nextgen-frontend
npm install


Run the BackendStart the Express server from the turboproAI-nextgen-backend directory:
node app.js

The server will run on http://localhost:3003 (or the port specified in your configuration).

Run the FrontendIn a separate terminal, start the React app from the turboproAI-nextgen-frontend directory:
npm run dev

The frontend will run on http://localhost:5173 (default for Create React App).

Access the ApplicationOpen your browser and navigate to http://localhost:3000. Drag and drop a PDF file to analyze it.


Usage

Upload a PDF: Drag and drop a PDF file into the designated area on the webpage.
View Results: The application will display a loading state while analyzing the PDF. Once complete, the extracted data (or error message) will be shown in a formatted JSON output.
Error Handling: Invalid file types or processing errors will trigger toast notifications with relevant messages.

Project Structure
pdf-document-parser/
├── turboproAI-nextgen-backend/
│   ├── uploads/                # Directory for uploaded PDF files
│   ├── routes/
│   │   └── fileUpload.js  # Express route for file upload and processing
│   ├── .env                    # Environment variables (not committed)
│   └── package.json            # Backend dependencies and scripts
├── turboproAI-nextgen-frontend/
│   ├── src/
│   │   └── App.jsx             # Main React component
│   ├── .env                    # Frontend environment variables (if needed)
│   └── package.json            # Frontend dependencies and scripts
└── README.md                   # This file

Notes

Security: The OpenAI API key is hardcoded in the provided backend code, which is insecure. Ensure it is moved to the .env file in turboproAI-nextgen-backend and accessed via process.env.OPENAI_API_KEY.
Database: Ensure the DOCUMENT_processor stored procedure exists in your MySQL database and is compatible with the JSON format expected by the backend.
Deployment: The provided frontend code references a specific IP (http://44.200.2.72:3003). Update this to your backend's URL (e.g., http://localhost:3003) or use a relative path for local development.
Dependencies: Ensure all required Node.js packages (express, multer, mysql2, pdf-parse, openai, etc.) are installed in the backend, and frontend dependencies (react, axios, react-toastify, etc.) are installed in the frontend.

Troubleshooting

File Upload Fails: Check if the uploads/ directory exists in turboproAI-nextgen-backend and has write permissions.
Database Errors: Verify MySQL connection details in the backend .env file and ensure the database and stored procedure are set up.
OpenAI Errors: Confirm your API key is valid and that your account has access to the gpt-4o model.
CORS Issues: If the frontend and backend are on different domains/ports, configure CORS in the Express server in turboproAI-nextgen-backend.

