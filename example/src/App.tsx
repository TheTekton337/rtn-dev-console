import * as React from 'react';
import { useEffect, useRef, useState } from 'react';

import {
  Platform,
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

import uuid from 'react-native-uuid';

import { Notifications } from 'react-native-notifications';

import { handleOSCEvent, OSC_CODES } from './utils/osc';
import { useEventCallbackManager } from './hooks/useEventCallbackManager';

const initialText = 'rtn-dev-console - connecting to my localhost\r\n\n';

interface ScpReadCompleteEvent {
  data?: string;
  fileInfo?: any;
  error?: string;
}

interface ScpWriteCompleteEvent {
  bytesTransferred?: string;
  error?: string;
}

interface ScpReadProgressEvent {
  bytesTransferred: number;
}

interface ScpWriteProgressEvent {
  bytesTransferred: number;
  totalBytes: number;
}

export default function App() {
  const ref = useRef<SshTerminalMethods | null>(null);
  const [connected, setConnected] = useState(false);
  const [borderColor, setBorderColor] = useState('transparent');
  const [borderWidth, setBorderWidth] = useState(0);
  const [_, setCursorVisible] = useState(true);

  const { registerCallback, getHandler } = useEventCallbackManager();

  useEffect(() => {
    requestPermissionsIos(['providesAppNotificationSettings']);
    registerNotificationEvents();
    // setCategories();
    // getInitialNotification();
  }, []);

  const registerNotificationEvents = () => {
    if (Platform.OS === 'ios') {
      Notifications.ios.events().appNotificationSettingsLinked(() => {
        console.warn('App Notification Settings Linked');
      });
    }
  };

  const requestPermissionsIos = (options: string[]) => {
    Notifications.ios.registerRemoteNotifications(
      Object.fromEntries(options.map((opt) => [opt, true]))
    );
  };

  // const requestPermissions = () => {
  //   Notifications.registerRemoteNotifications();
  // };

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
    switch (code) {
      case OSC_CODES.NOTIFICATION:
        handleOSCEvent(code, data);
        break;
      default:
        console.warn(`Unhandled OSC code: ${code}`);
        break;
    }
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

  const onScpReceivePress = () => {
    console.log('onScpReceivePress');

    const callbackId = uuid.v4().toString();

    const from = '/home/tekton/test_nb.txt';
    const to = 'test_nb.txt';

    registerCallback<ScpReadCompleteEvent>(
      callbackId,
      'onScpReadComplete',
      (data) => {
        console.log(`ID: ${callbackId} File: ${data.data}`);
      }
    );

    registerCallback<ScpReadProgressEvent>(
      callbackId,
      'onScpReadProgress',
      (data) => {
        console.log(
          `ID: ${callbackId} Progress: ${data.bytesTransferred} bytes`
        );
      }
    );

    ref.current?.scpRead(callbackId, from, to);
  };

  const handleScpReadComplete = getHandler('onScpReadComplete');
  const handleScpReadProgress = getHandler('onScpReadProgress');

  const onScpWritePress = () => {
    console.log('onScpWritePress');

    const callbackId = uuid.v4().toString();

    const from = 'test_scp2.txt';
    const to = '/home/tekton/test_scp2.txt';

    registerCallback<ScpWriteCompleteEvent>(
      callbackId,
      'onScpWriteComplete',
      (data) => {
        console.log(
          `ID: ${callbackId} Transfer Complete: ${data.bytesTransferred}`
        );
      }
    );

    registerCallback<ScpWriteProgressEvent>(
      callbackId,
      'onScpWriteProgress',
      (data) => {
        console.log(
          `ID: ${callbackId} Progress: ${data.bytesTransferred} bytes`
        );
      }
    );

    ref.current?.scpWrite(callbackId, from, to);
  };

  const handleScpWriteComplete = getHandler('onScpWriteComplete');
  const handleScpWriteProgress = getHandler('onScpWriteProgress');

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
        {/* <TouchableOpacity
          onPress={onTestScpSendPress}
          disabled={!connected}
          style={styles.button}
        >
          <Text>Send test_send.txt</Text>
        </TouchableOpacity> */}
        <TouchableOpacity
          onPress={onScpReceivePress}
          disabled={!connected}
          style={styles.button}
        >
          <Text>Get test_scp.txt</Text>
        </TouchableOpacity>
        <TouchableOpacity
          onPress={onScpWritePress}
          disabled={!connected}
          style={styles.button}
        >
          <Text>Send test_scp2.txt</Text>
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
            username: 'your_username',
            password: 'your_password',
          }}
          initialText={initialText}
          oscHandlerCodes={[337]}
          onOSC={onOSC}
          onBell={onBell}
          onClosed={onClosed}
          onConnect={onConnect}
          onTerminalLog={onTerminalLog}
          onScpReadComplete={handleScpReadComplete}
          onScpWriteComplete={handleScpWriteComplete}
          onScpReadProgress={handleScpReadProgress}
          onScpWriteProgress={handleScpWriteProgress}
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
