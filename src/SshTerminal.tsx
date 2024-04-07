import React, { forwardRef } from 'react';
import { Text, View } from 'react-native';
import styles from './SshTerminal.styles';
import type { NativeProps } from './RtnSshTerminalViewNativeComponent';
import type { SshTerminalMethods } from './SshTerminalTypes';

const SshTerminal = forwardRef<SshTerminalMethods, NativeProps>(
  (_props, _ref) => {
    return (
      <View style={styles.flexStart}>
        <Text style={styles.colorRed}>
          SshTerminal does not support this platform.
        </Text>
      </View>
    );
  }
);

export default SshTerminal;
