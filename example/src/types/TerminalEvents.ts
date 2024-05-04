import type { FileInfo } from './ScpTransfer';
import type { TransferDirection } from './TransferService';

// TODO: Add comments

// TODO: The terminalView or terminalId can be used for lookup.

export type TerminalView = number;
export type Identity = string;

export interface RTNEvent {
  callbackId: Identity;
}

// TODO: Is there a benefit to using the terminal ref?
// export interface RTNViewEvent extends RTNEvent {
//   terminalView: TerminalView;
// }

export interface TerminalLogEvent {
  type: 'onTerminalLog';
  terminalId: Identity;
  logType: 'info' | 'warning' | 'error' | 'connectionError';
  message: string;
}

export interface ConnectEvent extends RTNEvent {
  type: 'onConnect';
  terminalView: TerminalView;
  terminalId: Identity;
  sessionId: Identity;
}

export interface ConnectCompletion extends RTNEvent {
  type: 'connectCompletion';
  terminalId: string;
  sessionId: string;
}

export interface DisconnectCompletion extends RTNEvent {
  type: 'disconnectCompletion';
  terminalId: string;
  sessionId: string;
  reason: string;
}

export interface ClosedEvent extends RTNEvent {
  type: 'onClosed';
  terminalView: TerminalView;
  terminalId: Identity;
  sessionId: Identity;
  reason: string;
}

export interface OSCEvent extends RTNEvent {
  type: 'onOSC';
  terminalId: Identity;
  code: number;
  data: string;
}

export interface TransferStartEvent extends RTNEvent {
  type: 'onTransferStart';
  callbackId: Identity;
  direction: TransferDirection;
  fileInfo: string;
}

export interface TransferProgressEvent extends RTNEvent {
  type: 'onTransferProgress';
  callbackId: Identity;
  direction: TransferDirection;
  fileInfo: FileInfo;
  bytesTransferred: number;
  transferRate: number;
}

export interface TransferEndEvent extends RTNEvent {
  type: 'onTransferEnd';
  callbackId: Identity;
  direction: TransferDirection;
  fileInfo?: FileInfo;
  error?: string;
}

export interface DownloadCompleteEvent extends RTNEvent {
  type: 'downloadComplete';
  sessionId: Identity;
  terminalId: Identity;
  data?: string;
  fileInfo?: FileInfo;
  error?: string;
}

export interface UploadCompleteEvent extends RTNEvent {
  type: 'uploadComplete';
  sessionId: Identity;
  terminalId: Identity;
  bytesTransferred: number;
  error?: string;
}

export interface DownloadProgressEvent extends RTNEvent {
  type: 'downloadProgress';
  sessionId: Identity;
  terminalId: Identity;
  bytesTransferred: number;
  totalBytes: number;
}

export interface UploadProgressEvent extends RTNEvent {
  type: 'uploadProgress';
  sessionId: Identity;
  terminalId: Identity;
  bytesTransferred: number;
  totalBytes: number;
}

export interface CommandExecutedEvent {
  type: 'onCommandExecuted';
  terminalId: Identity;
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
  | TransferStartEvent
  | TransferProgressEvent
  | TransferEndEvent
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
