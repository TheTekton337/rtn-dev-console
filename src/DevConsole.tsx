import React, { forwardRef } from 'react';
import { Text, View } from 'react-native';
import styles from './DevConsole.styles';
import type { NativeProps } from './RtnDevConsoleViewNativeComponent';
import type { DevConsoleMethods } from './DevConsoleTypes';

const DevConsole = forwardRef<DevConsoleMethods, NativeProps>(
  (_props, _ref) => {
    return (
      <View style={styles.flexStart}>
        <Text style={styles.colorRed}>
          DevConsole does not support this platform.
        </Text>
      </View>
    );
  }
);

export default DevConsole;
