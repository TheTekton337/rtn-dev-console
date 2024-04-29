import type { FileInfo } from './ScpTransfer';

// TODO: Add comments

export type TerminalView = number;
export type TerminalId = string;
export type SessionId = string;
export type CallbackId = string;

export interface RTNEvent {
  callbackId?: CallbackId;
}

export interface TerminalLogEvent {
  type: 'onTerminalLog';
  terminalId: TerminalId;
  logType: 'info' | 'warning' | 'error' | 'connectionError';
  message: string;
}

export interface ConnectEvent {
  type: 'onConnect';
  terminalView: TerminalView;
  terminalId: TerminalId;
  sessionId: SessionId;
}

export interface ConnectCompletion {
  type: 'connectCompletion';
  terminalId: string;
  sessionId: string;
}

export interface DisconnectCompletion {
  type: 'disconnectCompletion';
  terminalId: string;
  sessionId: string;
  reason: string;
}

export interface ClosedEvent {
  type: 'onClosed';
  terminalView: TerminalView;
  terminalId: TerminalId;
  sessionId: SessionId;
  reason: string;
}

export interface OSCEvent {
  type: 'onOSC';
  terminalId: TerminalId;
  code: number;
  data: string;
}

export interface DownloadCompleteEvent {
  type: 'downloadComplete';
  sessionId: SessionId;
  terminalId: TerminalId;
  data?: string;
  fileInfo?: FileInfo;
  error?: string;
}

export interface UploadCompleteEvent {
  type: 'uploadComplete';
  sessionId: SessionId;
  terminalId: TerminalId;
  bytesTransferred: number;
  error?: string;
}

export interface DownloadProgressEvent {
  type: 'downloadProgress';
  sessionId: SessionId;
  terminalId: TerminalId;
  bytesTransferred: number;
  totalBytes: number;
}

export interface UploadProgressEvent {
  type: 'uploadProgress';
  sessionId: SessionId;
  terminalId: TerminalId;
  bytesTransferred: number;
  totalBytes: number;
}

export interface CommandExecutedEvent {
  type: 'onCommandExecuted';
  terminalId: TerminalId;
  output?: string;
  error?: string;
}

/**
 * AsyncEventData is the union type for all possible asynchronous event data
 */
export type AsyncEventData =
  | ConnectEvent
  | ClosedEvent
  | ConnectCompletion
  | DisconnectCompletion
  | CommandExecutedEvent
  | DownloadProgressEvent
  | DownloadCompleteEvent
  | UploadProgressEvent
  | UploadCompleteEvent;

/**
 * AsyncEventKind is the event type.
 */
export type AsyncEventKind = AsyncEventData['type'];

/**
 * Asynchronous event type.
 *
 * Defaults to AsyncEventData for data type, but can be overridden by the
 * caller.
 */
export interface AsyncEvent<T = AsyncEventData> {
  type: AsyncEventKind;
  callbackId?: string;
  data?: T;
}
