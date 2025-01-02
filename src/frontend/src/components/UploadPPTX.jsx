import React, { useState, useCallback } from 'react';
import axios from 'axios';
import FileUpload from './FileUpload.jsx';

const UploadPPTX = () => {
  const [text, setText] = useState("");

  const handleFileUpload = useCallback(async (event) => {
    const file = event.target.files[0];
    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await axios.post('http://localhost:8080/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      });

      const data = response.data;
      setText(data);
    } catch (error) {
      console.error('Error uploading file:', error);
    }
  }, [text]);


  return (
    <div>
      <FileUpload onChange={handleFileUpload} />

      <div id="gjs">{text}</div>
    </div>
  );
};

export default UploadPPTX;