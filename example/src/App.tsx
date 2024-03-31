import * as React from 'react';
import { useRef, useState } from 'react';

import {
  SafeAreaView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from 'react-native';
import { DevConsole, type DevConsoleMethods } from 'rtn-dev-console';

export default function App() {
  const ref = useRef<DevConsoleMethods | null>(null);
  // const ref = useRef<React.Ref<typeof DevConsole> | null>(null);
  // const ref = useRef<DevConsoleMethods>(null);
  // const ref = useRef<React.ComponentRef<typeof DevConsole> | null>();
  const [borderColor, setBorderColor] = useState('transparent');
  const [borderWidth, setBorderWidth] = useState(0);
  const [_, setCursorVisible] = useState(true);

  // TODO: Change auth to { type: 'password', config: { username: '<USERNAME>', password: '<PASSWORD>' } } }
  // TODO: Add support for localization
  // TODO: Review accessibility

  const handleBell = () => {
    console.log('handleBell invoked');
    setBorderColor('red');
    setBorderWidth(1);
    setTimeout(() => {
      setBorderColor('transparent');
      setBorderWidth(1);
    }, 1000);
  };

  const handleClose = () => {
    console.log('handleClose invoked');
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

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.toolbar}>
        <TouchableOpacity onPress={onToggleCursorPress}>
          <Text>Toggle Cursor</Text>
        </TouchableOpacity>
      </View>
      <View style={[styles.container, { borderColor, borderWidth }]}>
        <DevConsole
          ref={ref}
          host="192.168.0.1"
          port={22}
          username="username"
          password="password"
          onBell={handleBell}
          onClosed={handleClose}
          style={styles.box}
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // alignItems: 'center',
    // justifyContent: 'center',
  },
  toolbar: {
    height: 50,
  },
  box: {
    flex: 1,
    // width: 60,
    // height: 60,
    // marginVertical: 20,
  },
});
