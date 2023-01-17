import React, { useState, } from "react";
import { config } from '../domain/config';
import axios from "axios";

export const FileUpload = () => {
  const [fileSelected, setFileSelected] = useState('');

  const saveFileSelected = (e: any) => {
    //in case you wan to print the file selected
    //console.log(e.target.files[0]);
    setFileSelected(e.target.files[0]);
  };

  const importFile = async (e: any) => {
    const formData = new FormData();
    formData.append("file", fileSelected);

    try {
      const res = await axios.post(config.apiUrl + '/image', formData);
    } catch (ex) {
      console.log(ex);
    }
  };

  return (
    <>
      <input type="file" onChange={saveFileSelected} />
      <input type="button" value="upload" onClick={importFile} />
    </>
  );
};