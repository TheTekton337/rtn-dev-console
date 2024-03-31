import React, {
  forwardRef,
  useRef,
  useImperativeHandle,
  useEffect,
} from 'react';
import { type HostComponent } from 'react-native';

import RtnDevConsoleView, {
  Commands,
  type NativeProps,
} from './RtnDevConsoleViewNativeComponent';
import type { DevConsoleMethods } from './DevConsoleTypes';

const DevConsole = forwardRef<DevConsoleMethods, NativeProps>((props, ref) => {
  const consoleRef = useRef<React.ComponentRef<
    HostComponent<NativeProps>
  > | null>(null);

  useEffect(() => {
    console.log('DevConsole iOS useEffect invoked');
  }, []);

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

  return <RtnDevConsoleView {...props} ref={consoleRef} />;
});

export default DevConsole;
