import React, { useEffect, useRef, useState, type RefObject } from 'react';
import { SafeAreaView, StyleSheet, View } from 'react-native';

import ErrorBoundary from 'react-native-error-boundary';
import uuid from 'react-native-uuid';
import type { SshTerminalMethods } from 'rtn-dev-console';

import { log, LogLevel } from './utils/log';

import type { NativeTerminal } from './types/Terminal';

import TerminalProvider from './providers/TerminalProvider';

import { setTerminalInstance } from './observables/TerminalService';

import Terminal from './components/Terminal/Terminal';
import Toolbar from './components/Toolbar/Toolbar';

import useSshConnectionStatus from './hooks/useSshConnectionStatus';

const logModule = 'App';

export default function App() {
  const sshTerminalRef = useRef<SshTerminalMethods>(null);

  const [sessionId] = useState(uuid.v4().toString());
  const [terminalId] = useState(uuid.v4().toString());
  const [terminal, setInternalTerminal] = useState<NativeTerminal | null>(null);

  const [connectionStatus] = useSshConnectionStatus(sessionId, terminal);

  const setTerminal = (ref: NativeTerminal) => {
    setInternalTerminal(ref);
  };

  useEffect(() => {
    let cleanupRef: RefObject<SshTerminalMethods>;

    if (sshTerminalRef.current) {
      cleanupRef = sshTerminalRef;
      setTerminalInstance(sshTerminalRef.current);
    } else {
      log(LogLevel.WARN, logModule, 'sshTerminalRef is null');
    }

    return () => {
      log(LogLevel.DEBUG, logModule, 'cleanup');
      if (cleanupRef.current) {
        log(LogLevel.DEBUG, logModule, 'closing');
        cleanupRef.current?.close();
      }
    };
  }, []);

  return (
    <ErrorBoundary>
      <SafeAreaView style={styles.container}>
        <View style={styles.container}>
          <TerminalProvider
            sessionId={sessionId}
            terminalId={terminalId}
            connectionStatus={connectionStatus}
            terminal={terminal}
            setTerminal={setTerminal}
          >
            <Toolbar />
            <Terminal ref={sshTerminalRef} />
          </TerminalProvider>
        </View>
      </SafeAreaView>
    </ErrorBoundary>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
