import React from 'react';
import { Button, Box, Typography } from '@mui/material';
import { styled } from '@mui/system';

const Input = styled('input')({
  display: 'none',
});

const FileUpload = ({ onChange }) => {
  return (
    <Box display="flex" flexDirection="column" alignItems="center" justifyContent="center" p={2} border={1} borderRadius={4} borderColor="grey.400">
      <Typography variant="h6" gutterBottom>
        Upload your PowerPoint file
      </Typography>
      <label htmlFor="file-upload">
        <Input id="file-upload" type="file" onChange={onChange} />
        <Button variant="contained" component="span">
          Choose File
        </Button>
      </label>
    </Box>
  );
};

export default FileUpload;
