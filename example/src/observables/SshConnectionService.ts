import { BehaviorSubject, Subject } from 'rxjs';

import { log, LogLevel } from '../utils/log';

import type {
  ConnectionStatus,
  DisconnectReason,
} from '../types/SshConnection';

const logModule = 'SshConnectionService';

/**
 * List of sessions listening to connection events
 */
const connectionStatusMap = new Map<
  string,
  BehaviorSubject<ConnectionStatus>
>();

/**
 * List of terminals associated with a session
 */
const sessionTerminalMap = new Map<string, Set<string>>();

/**
 * Subject that emits connection status changes
 */
const connectionEvents$ = new Subject<{
  sessionId: string;
  status: ConnectionStatus;
}>();

/**
 * Adds the sessionId to the list of sessions listening to connection events
 * @param sessionId The session id
 */
export function ensureSessionStatus(sessionId: string) {
  if (!connectionStatusMap.has(sessionId)) {
    connectionStatusMap.set(
      sessionId,
      new BehaviorSubject<ConnectionStatus>({
        connected: false,
        isConnecting: false,
        desiredState: null,
        disconnectReason: null,
      })
    );

    log(LogLevel.DEBUG, logModule, `session registered [${sessionId}]`);
  }
}

/**
 * Emits a connection event for the given sessionId
 * @param sessionId The session id
 */
function emitConnectionEvent(sessionId: string) {
  const statusSubject = connectionStatusMap.get(sessionId);
  if (statusSubject) {
    log(
      LogLevel.DEBUG,
      logModule,
      `emitting connection event for session ${sessionId}`,
      statusSubject.value
    );
    connectionEvents$.next({ sessionId, status: statusSubject.value });
  }
}

/**
 * Emits a connection event to open the connection
 * @param sessionId The session id
 */
export function connect(sessionId: string) {
  ensureSessionStatus(sessionId);
  const statusSubject = connectionStatusMap.get(sessionId);
  log(LogLevel.DEBUG, logModule, `connect [${sessionId}]`);
  statusSubject!.next({
    connected: false,
    isConnecting: true,
    desiredState: 'open',
    disconnectReason: null,
  });
  emitConnectionEvent(sessionId);
}

/**
 * Emits a connection event when a connection is opened
 * @param sessionId The session id
 */
export function onConnected(sessionId: string) {
  ensureSessionStatus(sessionId);
  const statusSubject = connectionStatusMap.get(sessionId);
  statusSubject!.next({
    connected: true,
    isConnecting: false,
    desiredState: null,
    disconnectReason: null,
  });
  log(LogLevel.INFO, logModule, `connected [${sessionId}]`);
  emitConnectionEvent(sessionId);
}

/**
 * Emits a connection event when a connection is closing
 * @param sessionId The session id
 * @param reason The close reason
 */
export function close(
  sessionId: string,
  reason: 'user' | 'error' | 'timeout' = 'user'
) {
  ensureSessionStatus(sessionId);
  const statusSubject = connectionStatusMap.get(sessionId);
  statusSubject!.next({
    connected: false,
    isConnecting: false,
    desiredState: 'closed',
    disconnectReason: reason,
  });
  log(LogLevel.DEBUG, logModule, `closing [${sessionId}]`);
  emitConnectionEvent(sessionId);
}

/**
 * Emits a connection event when a connection is closed
 * @param sessionId The session id
 * @param reason The close reason
 */
export function onClosed(sessionId: string, reason: DisconnectReason) {
  ensureSessionStatus(sessionId);
  const statusSubject = connectionStatusMap.get(sessionId);
  statusSubject!.next({
    connected: false,
    isConnecting: false,
    desiredState: null,
    disconnectReason: reason,
  });
  log(LogLevel.INFO, logModule, `closed [${sessionId}]`);
  emitConnectionEvent(sessionId);
}

/**
 * Connect events Observable
 */
export const connectionEventsObservable = connectionEvents$.asObservable();

/**
 * Registers a terminal with the given sessionId
 * @param sessionId The session id
 * @param terminalId The terminal id
 */
export function registerTerminal(sessionId: string, terminalId: string) {
  if (!sessionTerminalMap.has(sessionId)) {
    sessionTerminalMap.set(sessionId, new Set());
  }
  sessionTerminalMap.get(sessionId)!.add(terminalId);
  log(
    LogLevel.DEBUG,
    logModule,
    `registered terminal [${terminalId}] for session [${sessionId}]`
  );
}

/**
 * Unregisters a terminal from the given sessionId
 * @param sessionId The session id
 * @param terminalId The terminal id
 * @param disconnectLast Disconnect the session if this was the last terminal
 */
export function unregisterTerminal(
  sessionId: string,
  terminalId: string,
  disconnectLast: boolean = true
) {
  const terminals = sessionTerminalMap.get(sessionId);
  if (terminals) {
    terminals.delete(terminalId);
    log(
      LogLevel.DEBUG,
      logModule,
      `unregistered terminal [${terminalId}] for session [${sessionId}]`
    );
    if (terminals.size === 0) {
      sessionTerminalMap.delete(sessionId);
      log(
        LogLevel.DEBUG,
        logModule,
        `last terminal [${terminalId}] for session [${sessionId}]`
      );
      if (disconnectLast) {
        log(
          LogLevel.DEBUG,
          logModule,
          `disconnecting last terminal [${terminalId}] for session [${sessionId}]`
        );
        close(sessionId, 'user');
      }
    }
  }
}
