import * as React from 'react';
import { useRef, useState } from 'react';

import {
  SafeAreaView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import {
  SshTerminal,
  type ClosedEvent,
  type OSCEvent,
  type TerminalLogEvent,
  type SshTerminalMethods,
} from 'rtn-dev-console';

const initialText = 'rtn-dev-console - connecting to my localhost\r\n\n';

export default function App() {
  const ref = useRef<SshTerminalMethods | null>(null);
  const [connected, setConnected] = useState(false);
  const [borderColor, setBorderColor] = useState('transparent');
  const [borderWidth, setBorderWidth] = useState(0);
  const [_, setCursorVisible] = useState(true);

  const onBell = () => {
    console.log('handleBell invoked');
    setBorderColor('red');
    setBorderWidth(1);
    setTimeout(() => {
      setBorderColor('transparent');
      setBorderWidth(1);
    }, 1000);
  };

  const onConnect = () => {
    console.log('Connected');
    setConnected(true);
  };

  const onClosed = ({ nativeEvent: { reason } }: ClosedEvent) => {
    console.log(`Connection closed: ${reason}`);
    setConnected(false);
  };

  const onTerminalLog = ({
    nativeEvent: { logType, message },
  }: TerminalLogEvent) => {
    console.log(`onTerminalLog: ${logType}: ${message}`);
  };

  const onOSC = ({ nativeEvent: { code, data } }: OSCEvent) => {
    console.log(`onOSC: ${code} | ${data}`);
    setBorderColor('green');
    setBorderWidth(1);
    setTimeout(() => {
      setBorderColor('transparent');
      setBorderWidth(1);
    }, 1000);
  };

  const onToggleCursorPress = () => {
    setCursorVisible((prevCursorVisible) => {
      const nextCursorVisible = !prevCursorVisible;

      if (nextCursorVisible) {
        ref.current?.showCursor();
      } else {
        ref.current?.hideCursor();
      }

      return !prevCursorVisible;
    });
  };

  const onToggleConnectionPress = () => {
    if (connected) {
      ref.current?.close();
    } else {
      ref.current?.connect();
    }
  };

  const onSendPress = () => {
    ref.current?.writeCommand('ls -la\n');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.toolbar}>
        <View
          style={[
            styles.statusDot,
            // eslint-disable-next-line react-native/no-inline-styles
            { backgroundColor: connected ? 'green' : 'red' },
          ]}
        />
        <TouchableOpacity onPress={onToggleCursorPress}>
          <Text>Toggle Cursor</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={onToggleConnectionPress}
          style={styles.button}
        >
          <Text>{connected ? 'Disconnect' : 'Connect'}</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={onSendPress}
          disabled={!connected}
          style={styles.button}
        >
          <Text>ls -la</Text>
        </TouchableOpacity>
      </View>
      <View style={[styles.container, { borderColor, borderWidth }]}>
        <SshTerminal
          ref={ref}
          style={styles.container}
          autoConnect
          hostConfig={{
            host: '192.168.1.1',
            port: 22,
          }}
          authConfig={{
            authType: 'password',
            username: 'your_username',
            password: 'your_password',
          }}
          oscHandlerCodes={[337]}
          initialText={initialText}
          onOSC={onOSC}
          onBell={onBell}
          onClosed={onClosed}
          onConnect={onConnect}
          onTerminalLog={onTerminalLog}
          // authConfig={{
          //   authType: 'pubkeyFile',
          //   username: 'your_username',
          //   privateKeyPath: 'privateKey.txt',
          //   // publicKeyPath: 'publicKey.txt', // Optional
          //   // password: 'your_passhrase', // Optional
          // }}
          // authConfig={{
          //   authType: 'pubkeyMemory',
          //   username: 'your_username',
          //   privateKey: privateKeyString,
          //   // publicKey: publickKeyString, // Optional
          //   // password: 'your_passhrase', // Optional
          // }}
          // TODO: Add support for callback and interactive auth
          // authConfig={{
          //   type: 'interactive',
          //   username: 'your_username',
          //   interactiveCallback: handleInteractiveAuth
          // }}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  toolbar: {
    flexDirection: 'row',
    alignItems: 'center',
    height: 50,
    paddingHorizontal: 10,
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 10,
  },
  button: {
    backgroundColor: '#e7e7e7',
    paddingHorizontal: 15,
    paddingVertical: 5,
    borderRadius: 5,
    marginLeft: 10,
  },
});
