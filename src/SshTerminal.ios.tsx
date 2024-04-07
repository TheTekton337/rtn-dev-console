import React, { forwardRef, useRef, useImperativeHandle } from 'react';
import { type HostComponent } from 'react-native';

import RtnSshTerminalView, {
  Commands,
  type NativeProps,
} from './RtnSshTerminalViewNativeComponent';
import type { SshTerminalMethods } from './SshTerminalTypes';

const SshTerminal = forwardRef<SshTerminalMethods, NativeProps>(
  ({ ...props }, ref) => {
    const consoleRef = useRef<React.ComponentRef<
      HostComponent<NativeProps>
    > | null>(null);

    useImperativeHandle(
      ref,
      () => ({
        connect: () => {
          consoleRef.current && Commands.connect(consoleRef.current);
        },
        close: () => {
          consoleRef.current && Commands.close(consoleRef.current);
        },
        writeCommand: (command: string) => {
          consoleRef.current &&
            Commands.writeCommand(consoleRef.current, command);
        },
        // TerminalView methods
        sendMotionWithButtonFlags: (
          buttonFlags: number,
          x: number,
          y: number,
          pixelX: number,
          pixelY: number
        ) => {
          consoleRef.current &&
            Commands.sendMotionWithButtonFlags(
              consoleRef.current,
              buttonFlags,
              x,
              y,
              pixelX,
              pixelY
            );
        },
        encodeButtonWithButton: (
          button: number,
          release: boolean,
          shift: boolean,
          meta: boolean,
          control: boolean
        ) => {
          return consoleRef.current
            ? Commands.encodeButtonWithButton(
                consoleRef.current,
                button,
                release,
                shift,
                meta,
                control
              )
            : Promise.reject();
        },
        sendEventWithButtonFlags: (
          buttonFlags: number,
          x: number,
          y: number
        ) => {
          consoleRef.current &&
            Commands.sendEventWithButtonFlags(
              consoleRef.current,
              buttonFlags,
              x,
              y
            );
        },
        sendEventWithButtonFlagsPixel: (
          buttonFlags: number,
          x: number,
          y: number,
          pixelX: number,
          pixelY: number
        ) => {
          consoleRef.current &&
            Commands.sendEventWithButtonFlagsPixel(
              consoleRef.current,
              buttonFlags,
              x,
              y,
              pixelX,
              pixelY
            );
        },
        // feedBuffer: (buffer: ArrayBuffer) => {
        //   consoleRef.current && Commands.feedBuffer(consoleRef.current, buffer);
        // },
        feedText: (text: string) => {
          consoleRef.current && Commands.feedText(consoleRef.current, text);
        },
        // feedByteArray: (byteArray: ArrayBuffer) => {
        //   consoleRef.current &&
        //     Commands.feedByteArray(consoleRef.current, byteArray);
        // },
        // getText: () => {
        //   return consoleRef.current ? Commands.getText(consoleRef.current) : Promise.reject();
        // },
        // sendResponse: (items: ArrayBuffer) => {
        //   consoleRef.current &&
        //     Commands.sendResponse(consoleRef.current, items);
        // },
        sendResponseText: (text: string) => {
          consoleRef.current &&
            Commands.sendResponseText(consoleRef.current, text);
        },
        changedLines: async () => {
          return consoleRef.current
            ? Commands.changedLines(consoleRef.current)
            : Promise.reject();
        },
        clearUpdateRange: () => {
          consoleRef.current && Commands.clearUpdateRange(consoleRef.current);
        },
        emitLineFeed: () => {
          consoleRef.current && Commands.emitLineFeed(consoleRef.current);
        },
        garbageCollectPayload: () => {
          consoleRef.current &&
            Commands.garbageCollectPayload(consoleRef.current);
        },
        // getBufferAsData: async () => {
        //   return consoleRef.current
        //     ? Commands.getBufferAsData(consoleRef.current)
        //     : Promise.reject();
        // },
        // getCharData: async () => {
        //   return consoleRef.current ? Commands.getCharData(consoleRef.current) : Promise.reject();
        // },
        // getCharacter: async () => {
        //   return consoleRef.current ? Commands.getCharacter(consoleRef.current) : Promise.reject();
        // },
        // getCursorLocation: async () => {
        //   return consoleRef.current ? Commands.getCursorLocation(consoleRef.current) : Promise.reject();
        // },
        // getDims: async () => {
        //   return consoleRef.current ? Commands.getDims(consoleRef.current) : Promise.reject();
        // },
        // getLine: async (lineIndex: number) => {
        //   return consoleRef.current ? Commands.getLine(consoleRef.current, lineIndex) : Promise.reject();
        // },
        // getScrollInvariantLine: async (lineIndex: number) => {
        //   return consoleRef.current ? Commands.getScrollInvariantLine(consoleRef.current, lineIndex) : Promise.reject();
        // },
        // getScrollInvariantUpdateRange: async () => {
        //   return consoleRef.current ? Commands.getScrollInvariantUpdateRange(consoleRef.current) : Promise.reject();
        // },
        getTopVisibleRow: () => {
          return consoleRef.current
            ? Commands.getTopVisibleRow(consoleRef.current)
            : Promise.reject();
        },
        // getUpdateRange: async () => {
        //   return consoleRef.current ? Commands.getUpdateRange(consoleRef.current) : Promise.reject();
        // },
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
        installColors: (colors: string) => {
          consoleRef.current &&
            Commands.installColors(consoleRef.current, colors);
        },
        refresh: (startRow: number, endRow: number) => {
          consoleRef.current &&
            Commands.refresh(consoleRef.current, startRow, endRow);
        },
        // registerOscHandler: (command: number, callback: (data: string) => void) => {
        //   consoleRef.current && Commands.registerOscHandler(consoleRef.current, command, callback);
        // },
        resetToInitialState: () => {
          consoleRef.current &&
            Commands.resetToInitialState(consoleRef.current);
        },
        resize: (cols: number, rows: number) => {
          consoleRef.current && Commands.resize(consoleRef.current, cols, rows);
        },
        scroll: () => {
          consoleRef.current && Commands.scroll(consoleRef.current);
        },
        // setCursorStyle: (style: string) => {
        //   consoleRef.current && Commands.setCursorStyle(consoleRef.current, style);
        // },
        setIconTitle: (text: string) => {
          consoleRef.current && Commands.setIconTitle(consoleRef.current, text);
        },
        setTitle: (text: string) => {
          consoleRef.current && Commands.setTitle(consoleRef.current, text);
        },
        softReset: () => {
          consoleRef.current && Commands.softReset(consoleRef.current);
        },
        updateFullScreen: () => {
          consoleRef.current && Commands.updateFullScreen(consoleRef.current);
        },
      }),
      [consoleRef]
    );

    return <RtnSshTerminalView {...props} ref={consoleRef} />;
  }
);

export default SshTerminal;
