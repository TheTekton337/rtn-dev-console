import { useEffect, useRef, useState } from 'react';

import type { Subscription } from 'rxjs';

import { log, LogLevel } from '../utils/log';

import type { AsyncEvent, AsyncEventData } from '../types/async_callbacks';
import type {
  ConnectionStatus,
  DisconnectReason,
} from '../types/SshConnection';
import type { NativeTerminal } from '../types/Terminal';
import type { ClosedEvent, ConnectEvent } from '../types/TerminalEvents';

import {
  connectionEventsObservable,
  ensureSessionStatus,
  onConnected,
  onClosed,
} from '../observables/SshConnectionService';
import { asyncEventsObservable } from '../observables/RTNEventService';

// TODO: Improve comments

const logModule = 'useSshConnectionStatus';

/**
 * Subscribes to SSH connection status updates and handles terminal async events.
 * @param sessionId The unique identifier for the SSH session.
 * @param terminal The unique identifier for the terminal.
 * @returns The current connection status for the specified session.
 */
function useSshConnectionStatus(
  sessionId: string,
  terminal: NativeTerminal | null
): [ConnectionStatus] {
  const connectionSubscriptionRef = useRef<Subscription>();
  const asyncEventSubscriptionRef = useRef<Subscription>();
  const [connectionStatus, setConnectionStatus] = useState<ConnectionStatus>({
    connected: false,
    isConnecting: true,
    desiredState: null,
    disconnectReason: null,
  });

  useEffect(() => {
    log(LogLevel.DEBUG, logModule, 'mounted');
    return () => {
      log(LogLevel.DEBUG, logModule, 'dismount cleanup');
      if (connectionSubscriptionRef.current) {
        log(LogLevel.DEBUG, logModule, 'connection unsubscribing');
        connectionSubscriptionRef.current.unsubscribe();
      }
      if (asyncEventSubscriptionRef.current) {
        log(LogLevel.DEBUG, logModule, 'async observer unsubscribing');
        asyncEventSubscriptionRef.current.unsubscribe();
      }
    };
  }, []);

  useEffect(() => {
    if (!terminal) {
      return;
    } else if (
      connectionSubscriptionRef.current ||
      asyncEventSubscriptionRef.current
    ) {
      return;
    }

    ensureSessionStatus(sessionId);

    connectionSubscriptionRef.current = initSshServiceListeners(
      sessionId,
      terminal,
      setConnectionStatus
    );

    asyncEventSubscriptionRef.current = initTerminalServiceListeners();

    // NOTE: Unsubscribing on component dismount.
  }, [terminal, sessionId]);

  return [
    {
      connected: connectionStatus.connected,
      isConnecting: connectionStatus.isConnecting,
      desiredState: connectionStatus.desiredState,
      disconnectReason: connectionStatus.disconnectReason,
    },
  ];
}

const initSshServiceListeners = (
  sessionId: string,
  terminal: NativeTerminal,
  setConnectionStatus: React.Dispatch<React.SetStateAction<ConnectionStatus>>
): Subscription => {
  return connectionEventsObservable.subscribe((event) => {
    if (event.sessionId === sessionId) {
      setConnectionStatus({ ...event.status });
      if (event.status.desiredState === 'open') {
        log(LogLevel.DEBUG, logModule, 'connectionSubscription opening');
        terminal.connect();
      } else if (event.status.desiredState === 'closed') {
        log(LogLevel.DEBUG, logModule, 'connectionSubscription closing');
        terminal.close();
      } else if (!event.status.desiredState && event.status.connected) {
        log(
          LogLevel.DEBUG,
          logModule,
          'connectionSubscription connected',
          event.sessionId
        );
      } else if (!event.status.desiredState && !event.status.connected) {
        log(
          LogLevel.DEBUG,
          logModule,
          'connectionSubscription closed',
          event.sessionId
        );
      } else {
        log(
          LogLevel.WARN,
          logModule,
          'connectionSubscription ignoring connection event for session',
          event.sessionId,
          event
        );
      }
    } else {
      log(
        LogLevel.WARN,
        logModule,
        'connectionSubscription ignoring connection event for unhandled session',
        sessionId,
        event.sessionId,
        event
      );
    }
  });
};

/**
 * Initialize listeners for terminal async events.
 * NOTE: This is the ssh auto-connect init path.
 * @returns Subscription to unsubscribe from events
 */
const initTerminalServiceListeners = (): Subscription => {
  return asyncEventsObservable.subscribe(
    (event: AsyncEvent<AsyncEventData>) => {
      // TODO: Fix need to cast below.
      if (event.type === 'onConnect') {
        const { sessionId: cbSessionId } = event as unknown as ConnectEvent;
        log(LogLevel.DEBUG, logModule, `onConnect`, cbSessionId, event);
        onConnected(cbSessionId);
      } else if (event.type === 'onClosed') {
        const { sessionId: cbSessionId, reason } =
          event as unknown as ClosedEvent;
        const disconnectReason = reason as DisconnectReason;
        log(LogLevel.DEBUG, logModule, `onClosed`, cbSessionId, event);
        onClosed(cbSessionId, disconnectReason);
      }
    }
  );
};

export default useSshConnectionStatus;
