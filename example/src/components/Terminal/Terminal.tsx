import React, {
  forwardRef,
  useEffect,
  type ForwardedRef,
  type RefObject,
} from 'react';
import { SafeAreaView, StyleSheet, Platform } from 'react-native';

import {
  SshTerminal,
  type OSCEvent,
  type SshTerminalMethods,
  type TerminalLogEvent,
} from 'rtn-dev-console';
import Config from 'react-native-config';

import { log, LogLevel } from '../../utils/log';
import { OSC_CODES } from '../../utils/osc';

import {
  registerTerminal,
  unregisterTerminal,
} from '../../observables/SshConnectionService';

import { useTerminal } from '../../hooks/useTerminal';

import TerminalLogs from '../TerminalLogs';
import { addLogEntry } from '../../observables/LogDataService';
import { bindFabricEvent } from '../../observables/RTNEventService';

// TODO: Move event interfaces to rtn-dev-console
export interface DownloadCompleteEvent {
  terminalId: number;
  data?: string;
  fileInfo?: any;
  error?: string;
}

export interface UploadCompleteEvent {
  terminalId: number;
  bytesTransferred?: string;
  error?: string;
}

export interface DownloadProgressEvent {
  terminalId: number;
  bytesTransferred: number;
}

export interface UploadProgressEvent {
  terminalId: number;
  bytesTransferred: number;
  totalBytes: number;
}

const logModule = 'Terminal';

const initialText = 'rtn-dev-console - connecting to my localhost\r\n\n';

interface TerminalProps {}

// TODO: Improve comments

const Terminal = forwardRef<SshTerminalMethods, TerminalProps>(
  ({}, ref: ForwardedRef<SshTerminalMethods>) => {
    const { setTerminal, sessionId, terminalId } = useTerminal();
    const terminalRef = ref as RefObject<SshTerminalMethods>;

    const host = Config.SSH_HOST;
    const port = Config.SSH_PORT;
    const username = Config.SSH_USER;
    const password = Config.SSH_PASS;

    useEffect(() => {
      if (!terminalRef.current) return;
      if (terminalRef.current) {
        log(
          LogLevel.DEBUG,
          logModule,
          `registering terminal [${terminalId}], session [${sessionId}]`
        );
        setTerminal(terminalRef.current);
        registerTerminal(sessionId, terminalId);
      }

      log(LogLevel.DEBUG, logModule, 'mounted');

      return () => {
        log(
          LogLevel.DEBUG,
          logModule,
          `cleaning up terminal [${terminalId}], session [${sessionId}]`
        );
        unregisterTerminal(sessionId, terminalId);
      };
      // TODO: Review dep array
      // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    const onTerminalLog = ({
      nativeEvent: { logType, message },
    }: TerminalLogEvent) => {
      let logMessage = `${logType}: ${message}`;
      addLogEntry(terminalId, logMessage);
    };

    const onOSC = ({
      nativeEvent: {
        code,
        // data
      },
    }: OSCEvent) => {
      switch (code) {
        case OSC_CODES.NOTIFICATION:
          // dispatch({ type: ActionType.OSC_EVENT, payload: data });
          break;
        default:
          log(LogLevel.INFO, logModule, `unhandled OSC code [${code}]`);
          break;
      }
    };

    const onBell = () => {
      log(LogLevel.DEBUG, logModule, `onBell invoked`);
      // dispatch({ type: ActionType.BELL });
    };

    const onConnect = bindFabricEvent('onConnect');
    const onClosed = bindFabricEvent('onClosed');

    const onCommandExecuted = bindFabricEvent('onCommandExecuted');

    const onTransferStart = bindFabricEvent('onTransferStart');
    const onTransferProgress = bindFabricEvent('onTransferProgress');
    const onTransferEnd = bindFabricEvent('onTransferEnd');

    return (
      <SafeAreaView style={styles.container}>
        <SshTerminal
          ref={terminalRef}
          terminalId={terminalId}
          sessionId={sessionId}
          hostConfig={{
            host,
            port,
            terminal: 'xterm',
            environment: [
              {
                name: 'LC_RTN_DEV_CONSOLE',
                variable:
                  Platform.OS === 'ios' ? 'Apple_Terminal' : 'Android_Terminal',
              },
            ],
          }}
          authConfig={{
            authType: 'password',
            username,
            password,
          }}
          initialText={initialText}
          oscHandlerCodes={[OSC_CODES.NOTIFICATION]}
          onOSC={onOSC}
          onBell={onBell}
          onConnect={onConnect}
          onClosed={onClosed}
          onTerminalLog={onTerminalLog}
          onCommandExecuted={onCommandExecuted}
          onTransferStart={onTransferStart}
          onTransferProgress={onTransferProgress}
          onTransferEnd={onTransferEnd}
          style={styles.terminalContainer}
        />
        <TerminalLogs terminalId={terminalId} />
      </SafeAreaView>
    );
  }
);

const styles = StyleSheet.create({
  container: { flex: 1 },
  terminalContainer: {
    flex: 1,
  },
  button: {
    padding: 10,
    marginTop: 20,
    backgroundColor: 'blue',
    borderRadius: 10,
  },
  buttonText: {
    color: 'white',
    fontWeight: 'bold',
  },
});

export default Terminal;
