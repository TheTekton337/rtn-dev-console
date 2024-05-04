import { BehaviorSubject, Subject } from 'rxjs';

import type { SshTerminalMethods } from 'rtn-dev-console';

import type { FileInfo } from '../types/ScpTransfer';

import type {
  TransferStartEvent,
  TransferEndEvent,
  TransferProgressEvent,
} from '../types/TerminalEvents';

import {
  type BaseTransferStatus,
  type TransferErrorStatus,
  type TransferDirection,
  type TransferEndedStatus,
  type TransferPendingStatus,
  type TransferProgressStatus,
  type TransferStartedStatus,
} from '../types/TransferService';

import { registerAsyncCallback } from './RTNEventService';

import { log, LogLevel } from '../utils/log';

const logModule = 'ScpTransferService';

/**
 * Map of ongoing transfers
 */
const transferStatusMap = new Map<
  string,
  BehaviorSubject<BaseTransferStatus>
>();

/**
 * Observable subject for transfer events
 */
const transferEvents$ = new Subject<BaseTransferStatus>();

/**
 * Sets initial transfer status if not present
 * @param transferId Unique transfer ID
 * @param transferDirection Direction of transfer (upload/download)
 */
export function ensureTransferStatus(
  transferId: string,
  transferDirection: TransferDirection
) {
  if (!transferStatusMap.has(transferId)) {
    const initialStatus: TransferPendingStatus = {
      state: 'pending',
      transferDirection,
    };
    transferStatusMap.set(
      transferId,
      new BehaviorSubject<BaseTransferStatus>(initialStatus)
    );
    log(
      LogLevel.DEBUG,
      logModule,
      `Transfer session registered [${transferId}]`
    );
  }
}

/**
 * Emits a transfer event for the given transfer ID
 * @param transferId Unique transfer ID
 */
function emitTransferEvent(transferId: string) {
  const statusSubject = transferStatusMap.get(transferId);
  if (statusSubject) {
    log(
      LogLevel.DEBUG,
      logModule,
      `Emitting transfer event for session ${transferId}`,
      statusSubject.value
    );
    transferEvents$.next(statusSubject.value);
  }
}

/**
 * Update transfer status and emit event
 * @param transferId Unique transfer ID
 * @param status New transfer status
 * @param transferDirection Direction of transfer (upload/download)
 */
export function updateTransferStatus<T extends BaseTransferStatus>(
  transferId: string,
  status: T,
  transferDirection: TransferDirection
) {
  ensureTransferStatus(transferId, transferDirection);
  const statusSubject = transferStatusMap.get(transferId);
  statusSubject!.next(status);
  emitTransferEvent(transferId);
}

/**
 * Start a SCP transfer
 * @param transferDirection Direction of transfer (upload/download)
 * @param remotePath Path on remote system
 * @param localPath Path on local system
 * @param terminal Terminal instance to use for transfer
 * @param transferId Optional transfer ID, will generate if not provided
 * @returns Transfer ID
 */
export function scpTransfer(
  transferDirection: TransferDirection,
  remotePath: string,
  localPath: string,
  terminal: SshTerminalMethods,
  transferId?: string
) {
  let transferFileInfo: FileInfo;

  const scpTransferId = registerAsyncCallback<TransferStartEvent>(
    'onTransferStart',
    ({ callbackId: startId, fileInfo }) => {
      transferFileInfo = JSON.parse(fileInfo) as unknown as FileInfo;

      log(
        LogLevel.INFO,
        logModule,
        `${transferDirection} started with transfer ID ${scpTransferId}`
      );

      updateTransferStatus<TransferStartedStatus>(
        startId,
        {
          state: 'started',
          transferDirection,
          fileInfo: transferFileInfo,
        },
        transferDirection
      );
    },
    transferId
  );

  ensureTransferStatus(scpTransferId, transferDirection);

  registerAsyncCallback<TransferProgressEvent>(
    'onTransferProgress',
    ({
      callbackId: progressId,
      bytesTransferred,
      transferRate,
    }: TransferProgressEvent) => {
      log(
        LogLevel.INFO,
        logModule,
        `${transferDirection} progress: ${bytesTransferred}/${transferFileInfo?.fileSize} [${progressId}]`
      );

      updateTransferStatus<TransferProgressStatus>(
        progressId,
        {
          state: 'in_progress',
          transferDirection,
          bytesTransferred,
          transferRate,
        },
        transferDirection
      );
    },
    scpTransferId
  );

  registerAsyncCallback<TransferEndEvent>(
    'onTransferEnd',
    ({ callbackId: completionId, error }: TransferEndEvent) => {
      if (error) {
        log(
          LogLevel.INFO,
          logModule,
          `${transferDirection} error: ${error} [${completionId}]`
        );

        updateTransferStatus<TransferErrorStatus>(
          completionId,
          {
            state: 'error',
            transferDirection,
            errorMessage: error,
          },
          transferDirection
        );
        return;
      }

      log(
        LogLevel.INFO,
        logModule,
        `${transferDirection} complete: [${completionId}]`
      );

      updateTransferStatus<TransferEndedStatus>(
        completionId,
        {
          state: 'completed',
          transferDirection,
          fileInfo: transferFileInfo,
        },
        transferDirection
      );
    },
    scpTransferId
  );

  if (transferDirection === 'download') {
    terminal.download(scpTransferId, remotePath, localPath);
  } else {
    terminal.upload(scpTransferId, localPath, remotePath);
  }

  log(
    LogLevel.INFO,
    logModule,
    `${transferDirection} pending with transfer ID ${scpTransferId}`
  );

  return scpTransferId;
}

/**
 * Observable for external subscribers to listen to transfer events
 */
export const transferEventsObservable = transferEvents$.asObservable();
