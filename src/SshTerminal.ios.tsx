import React, { forwardRef, useRef, useImperativeHandle } from 'react';
import { type HostComponent } from 'react-native';

import RtnSshTerminalView, {
  Commands,
  type NativeProps,
} from './RtnSshTerminalViewNativeComponent';
import type { SshTerminalMethods } from './SshTerminalTypes';

const SshTerminal = forwardRef<SshTerminalMethods, NativeProps>(
  (props, ref) => {
    const consoleRef = useRef<React.ComponentRef<
      HostComponent<NativeProps>
    > | null>(null);

    useImperativeHandle(
      ref,
      () => ({
        hideCursor: () => {
          if (!consoleRef.current) {
            console.log('hideCursor invoked but consoleRef is null');
            return;
          }
          console.log('hideCursor iOS invoked');
          consoleRef.current && Commands.hideCursor(consoleRef.current);
        },
        showCursor: () => {
          if (!consoleRef.current) {
            console.log('showCursor invoked but consoleRef is null');
            return;
          }
          console.log('showCursor iOS invoked');
          consoleRef.current && Commands.showCursor(consoleRef.current);
        },
      }),
      [consoleRef]
    );

    return <RtnSshTerminalView {...props} ref={consoleRef} />;
  }
);

export default SshTerminal;
