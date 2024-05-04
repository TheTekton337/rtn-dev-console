import type { FileInfo } from './ScpTransfer';

/**
 * Direction of the transfer
 */
export type TransferDirection = 'upload' | 'download';

/**
 * Transfer statuses
 */
export type TransferState =
  | 'pending'
  | 'started'
  | 'in_progress'
  | 'completed'
  | 'cancelled'
  | 'error';

/**
 * Base transfer status used by all transfer status types
 */
export interface BaseTransferStatus {
  state: TransferState;
  transferDirection: TransferDirection;
}

/**
 * Status when the transfer is pending
 */
export interface TransferPendingStatus extends BaseTransferStatus {
  state: 'pending';
  transferDirection: TransferDirection;
}

/**
 * Status when the transfer has started
 */
export interface TransferStartedStatus extends BaseTransferStatus {
  state: 'started';
  transferDirection: TransferDirection;
  fileInfo: FileInfo;
}

/**
 * Status when the transfer is in progress
 */
export interface TransferProgressStatus extends BaseTransferStatus {
  state: 'in_progress';
  transferDirection: TransferDirection;
  bytesTransferred: number;
  transferRate: number;
}

/**
 * Status when the transfer is completed
 */
export interface TransferEndedStatus extends BaseTransferStatus {
  state: 'completed';
  transferDirection: TransferDirection;
  fileInfo: FileInfo;
}

/**
 * Status when the transfer was cancelled
 */
export interface TransferCancelledStatus extends BaseTransferStatus {
  state: 'cancelled';
  transferDirection: TransferDirection;
  reason?: string;
}

/**
 * Status when the transfer encountered an error
 */
export interface TransferErrorStatus extends BaseTransferStatus {
  state: 'error';
  transferDirection: TransferDirection;
  errorMessage: string;
}
