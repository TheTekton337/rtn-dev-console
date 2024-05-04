// TODO: Add comments

export type FileInfo = {
  fileSize: number;
  modificationTime?: number;
  accessTime?: number;
  permissions?: number;
};

// TODO: Simply scp native interface
export interface ScpDownloadProgress {}

export interface ScpDownloadCompletion {}

export interface ScpUploadProgress {}

export interface ScpUploadCompletion {}
