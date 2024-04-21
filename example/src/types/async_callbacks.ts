// TODO: Improve comments

/**
 * Types for handling native command callbacks
 */

import type { CommandExecutedEventData } from './TerminalEvents';

/**
 * FileTransferProgress is the progress of a file transfer
 */
export interface FileTransferProgress {
  percentageComplete: number;
}

/**
 * FileTransferCompletion is the completion of a file transfer
 */
export interface FileTransferCompletion {
  file: string;
  status: string;
}

// TODO: Review the connection completion event types

export interface ConnectCompletion {
  terminalId: string;
  sessionId: string;
}

export interface DisconnectCompletion {
  terminalId: string;
  sessionId: string;
  reason: string;
}

/**
 * AsyncEventData is the union type for all possible asynchronous event data
 */
export type AsyncEventData =
  | ConnectCompletion
  | DisconnectCompletion
  | CommandExecutedEventData
  | FileTransferProgress
  | FileTransferCompletion;

/**
 * Asynchronous event type.
 *
 * Defaults to AsyncEventData for data type, but can be overridden by the
 * caller.
 */
export interface AsyncEvent<T = AsyncEventData> {
  type: string; // TODO: Specific type?
  callbackId?: string; // Hrm
  data?: T;
  error?: string;
}
