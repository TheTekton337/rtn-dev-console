import * as React from 'react';

import { SafeAreaView, StyleSheet } from 'react-native';
import { RtnDevConsoleView } from 'rtn-dev-console';

export default function App() {
  // TODO: Change auth to { type: 'password', config: { username: '<USERNAME>', password: '<PASSWORD>' } } }
  // TODO: Add support for localization
  return (
    <SafeAreaView style={styles.container}>
      <RtnDevConsoleView
        host="192.168.0.1"
        port={22}
        username="username"
        password="password"
        style={styles.box}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    // alignItems: 'center',
    // justifyContent: 'center',
  },
  box: {
    flex: 1,
    // width: 60,
    // height: 60,
    // marginVertical: 20,
  },
});
