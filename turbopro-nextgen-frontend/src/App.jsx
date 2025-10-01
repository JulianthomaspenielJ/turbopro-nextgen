import { useState } from 'react';
import axios from 'axios';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

function App() {
  const [file, setFile] = useState(null);
  const [responseData, setResponseData] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const acceptedTypes = [
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', // .xlsx
    'application/vnd.ms-excel', // .xls
    'text/csv', // .csv
  ];

  const handleDrop = (e) => {
    e.preventDefault();
    const droppedFile = e.dataTransfer.files[0];
    if (!droppedFile) return;

    if (!acceptedTypes.includes(droppedFile.type)) {
      toast.error('Only PDF, XLSX, XLS, and CSV files are accepted.');
      return;
    }

    toast.info(`${droppedFile.name} uploaded, starting analysis...`);
    setFile(droppedFile);
    handleUpload(droppedFile);
  };

  const handleUpload = async (uploadFile) => {
    setIsLoading(true);
    const formData = new FormData();
    formData.append('file', uploadFile);

    try {
      const res = await axios.post('http://44.200.2.72:3003/fileUpload/fileContents', formData, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      if (res.data && res.data.data) {
        console.log('Received data:', res.data.data);
        setResponseData(res.data.data);
        toast.success('File analyzed successfully!');
      } else {
        throw new Error('Unexpected response from server');
      }
    } catch (err) {
      console.error('Upload error:', err);
      const errorData = err.response?.data?.data || { documentType: 'Unknown', error: err.message || 'Unknown error occurred' };
      setResponseData(errorData);
      toast.error(`Failed to analyze file: ${errorData.error || 'Unknown error'}`);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 flex flex-col items-center justify-center p-4">
      <div
        className={`border-4 border-dashed border-blue-500 bg-white rounded-xl p-12 w-full max-w-2xl text-center shadow-lg transition hover:bg-blue-50 ${isLoading ? 'opacity-50 cursor-not-allowed' : ''}`}
        onDragOver={(e) => e.preventDefault()}
        onDrop={isLoading ? undefined : handleDrop}
      >
        <h2 className="text-2xl font-semibold text-blue-600 mb-4">
          {isLoading ? 'Analyzing file...' : 'Drag and drop your file here'}
        </h2>
        <p className="text-sm text-gray-500">
          {isLoading ? (
            <div className="flex justify-center items-center">
              <svg className="animate-spin h-5 w-5 mr-3 text-blue-500" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
              Processing...
            </div>
          ) : (
            'Accepted file types: PDF, XLSX, XLS, CSV'
          )}
        </p>
      </div>

      <ToastContainer />

      {responseData && (
        <div className="mt-8 w-full max-w-3xl bg-white p-6 rounded-lg shadow-lg">
          <h3 className="text-xl font-bold text-gray-800 mb-4">Analysis Result</h3>

          {isLoading ? (
            <div className="animate-pulse space-y-4">
              <div className="h-4 bg-gray-200 rounded w-3/4"></div>
              <div className="h-4 bg-gray-200 rounded w-5/6"></div>
              <div className="h-4 bg-gray-200 rounded w-2/3"></div>
              <div className="h-4 bg-gray-200 rounded w-1/2"></div>
            </div>
          ) : (
            <pre className="text-sm text-gray-700 overflow-auto bg-gray-50 p-4 rounded whitespace-pre-wrap break-words">
              {JSON.stringify(responseData, null, 2)}
            </pre>
          )}
        </div>
      )}
    </div>
  );
}

export default App;
