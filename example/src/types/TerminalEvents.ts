import type { FileInfo } from './ScpTransfer';

// TODO: Add comments

export type TerminalView = number;
export type TerminalId = string;
export type SessionId = string;
export type CallbackId = string;

export interface TerminalLogEvent {
  terminalId: TerminalId;
  logType: 'info' | 'warning' | 'error' | 'connectionError';
  message: string;
}

export interface ConnectEvent {
  terminalView: TerminalView;
  terminalId: TerminalId;
  sessionId: SessionId;
}

export interface ClosedEvent {
  terminalView: TerminalView;
  terminalId: TerminalId;
  sessionId: SessionId;
  reason: string;
}

export interface OSCEvent {
  terminalId: TerminalId;
  code: number;
  data: string;
}

export interface DownloadCompleteEvent {
  terminalId: TerminalId;
  callbackId: CallbackId;
  data?: string;
  fileInfo?: FileInfo; // Update based on the more precise file info structure if available
  error?: string;
}

export interface UploadCompleteEvent {
  terminalId: TerminalId;
  callbackId: CallbackId;
  bytesTransferred: number;
  error?: string;
}

export interface DownloadProgressEvent {
  terminalId: TerminalId;
  callbackId: CallbackId;
  bytesTransferred: number;
  totalBytes: number;
}

export interface UploadProgressEvent {
  terminalId: TerminalId;
  callbackId: CallbackId;
  bytesTransferred: number;
  totalBytes: number;
}

export interface CommandExecutedEvent {
  terminalId: TerminalId;
  callbackId: CallbackId;
  data?: string;
  error?: string;
}

export type CommandExecutedEventData = string;
