import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { HostComponent, ViewProps } from 'react-native';
import type {
  Double,
  Int32,
  WithDefault,
  DirectEventHandler,
} from 'react-native/Libraries/Types/CodegenTypes';

export type SizeChangedEvent = Readonly<{
  terminalId: Int32;
  newCols: Int32;
  newRows: Int32;
}>;

export type HostCurrentDirectoryUpdateEvent = Readonly<{
  terminalId: Int32;
  directory: string;
}>;

export type ScrollEvent = Readonly<{
  terminalId: Int32;
  position: Double;
}>;

export type RequestOpenLinkEvent = {
  terminalId: Int32;
  link: string;
  params: string;
};

export type BellEvent = Readonly<{
  terminalId: Int32;
}>;

export type ClipboardCopyEvent = Readonly<{
  terminalId: Int32;
  content: string;
}>;

export type ITermContentEvent = Readonly<{
  terminalId: Int32;
  content: string;
}>;

export type RangeChangedEvent = Readonly<{
  terminalId: Int32;
  startY: Int32;
  endY: Int32;
}>;

export type LoadEvent = Readonly<{
  terminalId: Int32;
}>;

export type ConnectEvent = Readonly<{
  terminalId: Int32;
}>;

export type ClosedEvent = Readonly<{
  terminalId: Int32;
  reason: string;
}>;

export type SshErrorEvent = Readonly<{
  terminalId: Int32;
  error: string;
}>;

export type SshConnectionErrorEvent = Readonly<{
  terminalId: Int32;
  error: string;
}>;

export interface NativeProps extends ViewProps {
  /**
   * Prints connection debug output to terminal.
   */
  debug?: WithDefault<boolean, false>;

  /**
   * Initial text to be displayed in the terminal.
   */
  initialText?: WithDefault<
    string,
    'rtn-dev-console - connecting to my localhost\\r\\n\\n'
  >;

  /**
   * SSH server host
   */
  host?: WithDefault<string, '127.0.0.1'>;
  /**
   * SSH server port
   */
  port?: WithDefault<Int32, 22>;
  // TODO: Add support for key auth
  /**
   * SSH server username
   */
  username: string;
  /**
   * SSH server password
   */
  password: string;

  /**
   * Callback invoked when the terminal size changes, for example, after a device rotation.
   */
  onSizeChanged?: DirectEventHandler<SizeChangedEvent>;

  /**
   * Callback invoked when the OSC command 7 for "current directory has changed" command is sent.
   */
  onHostCurrentDirectoryUpdate?: DirectEventHandler<HostCurrentDirectoryUpdateEvent>;

  /**
   * Callback invoked when the terminal has been scrolled and the new position
   * is provided.
   */
  onScrolled?: DirectEventHandler<ScrollEvent>;

  /**
   * Callback invoked when the user opens a link with the terminal.
   */
  onRequestOpenLink?: DirectEventHandler<RequestOpenLinkEvent>;

  /**
   * Callback invoked when the terminal host beeps.
   */
  onBell?: DirectEventHandler<BellEvent>;

  /**
   * Callback invoked when the client application has issued an OSC 52
   * to put data on the clipboard.
   */
  onClipboardCopy?: DirectEventHandler<ClipboardCopyEvent>;

  /**
   * Callback invoked when the client application (iTerm2) has issued a OSC 1337
   * and SwiftTerm did not handle a handler for it.
   *
   * The default implementaiton does nothing.
   */
  onITermContent?: DirectEventHandler<ITermContentEvent>;

  /**
   * Callback invoked when there are visual changes in the terminal buffer if
   * the `notifyUpdateChanges` variable is set to true.
   */
  onRangeChanged?: DirectEventHandler<RangeChangedEvent>;

  /**
   * Callback invoked when a terminal SSH connection error event occurs.
   */
  onTerminalLoad?: DirectEventHandler<LoadEvent>;

  /**
   * Callback invoked when a terminal SSH connection opens.
   */
  onConnect?: DirectEventHandler<ConnectEvent>;

  /**
   * Callback invoked when a terminal SSH connection closes.
   */
  onClosed?: DirectEventHandler<ClosedEvent>;

  /**
   * Callback invoked when a terminal SSH error event occurs.
   */
  onSshError?: DirectEventHandler<SshErrorEvent>;

  /**
   * Callback invoked when a terminal SSH connection error event occurs.
   */
  onSshConnectionError?: DirectEventHandler<SshConnectionErrorEvent>;
}

export interface NativeCommands {
  sendMotionWithButtonFlags: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    buttonFlags: Int32,
    x: Int32,
    y: Int32,
    pixelX: Int32,
    pixelY: Int32
  ) => void;
  encodeButtonWithButton: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    button: Int32,
    release: boolean,
    shift: boolean,
    meta: boolean,
    control: boolean
  ) => Promise<Int32>;
  sendEventWithButtonFlags: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    buttonFlags: Int32,
    x: Int32,
    y: Int32
  ) => void;
  sendEventWithButtonFlagsPixel: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    buttonFlags: Int32,
    x: Int32,
    y: Int32,
    pixelX: Int32,
    pixelY: Int32
  ) => void;
  // TODO: Create conversion util if feedBuffer, feedByteArray, or sendResponse
  //       are needed.
  // feedBuffer: (
  //   viewRef: React.ElementRef<HostComponent<NativeProps>>,
  //   buffer: ArrayBuffer
  // ) => void;
  feedText: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    text: string
  ) => void;
  // feedByteArray: (
  //   viewRef: React.ElementRef<HostComponent<NativeProps>>,
  //   byteArray: ArrayBuffer
  // ) => void;
  // getText: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => Promise<string>;
  // sendResponse: (
  //   viewRef: React.ElementRef<HostComponent<NativeProps>>,
  //   items: ArrayBuffer
  // ) => void;
  sendResponseText: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    text: string
  ) => void;
  changedLines: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => Promise<Set<Int32>>;
  clearUpdateRange: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => void;
  emitLineFeed: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
  garbageCollectPayload: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => void;
  getBufferAsData: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => Promise<string>;
  // getCharData: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => Promise<any>;
  // getCharacter: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => Promise<string>;
  // getCursorLocation: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => Promise<{x: Int32, y: Int32}>;
  // getDims: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => Promise<{cols: Int32, rows: Int32}>;
  // getLine: (viewRef: React.ElementRef<HostComponent<NativeProps>>, lineIndex: Int32) => Promise<string>;
  // getScrollInvariantLine: (viewRef: React.ElementRef<HostComponent<NativeProps>>, lineIndex: Int32) => Promise<string>;
  // getScrollInvariantUpdateRange: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => Promise<any>;
  getTopVisibleRow: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => Promise<Int32>;
  // getUpdateRange: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => Promise<any>;
  hideCursor: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
  showCursor: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
  installColors: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    colors: string
  ) => void;
  refresh: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    startRow: Int32,
    endRow: Int32
  ) => void;
  // registerOscHandler: (viewRef: React.ElementRef<HostComponent<NativeProps>>, command: number, callback: (data: string) => void) => void;
  resetToInitialState: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => void;
  resizeTerminal: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    cols: Int32,
    rows: Int32
  ) => void;
  scroll: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
  // setCursorStyle: (viewRef: React.ElementRef<HostComponent<NativeProps>>, style: string) => void;
  setIconTitle: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    text: string
  ) => void;
  setTitle: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    text: string
  ) => void;
  softReset: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
  updateFullScreen: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: [
    'sendMotionWithButtonFlags',
    'encodeButtonWithButton',
    'sendEventWithButtonFlags',
    'sendEventWithButtonFlagsPixel',
    // 'feedBuffer',
    'feedText',
    // 'feedByteArray',
    // 'sendResponse',
    'sendResponseText',
    'changedLines',
    'clearUpdateRange',
    'emitLineFeed',
    'garbageCollectPayload',
    'getBufferAsData',
    // 'getText',
    'getTopVisibleRow',
    // 'getCharData',
    // 'getCharacter',
    // 'getCursorLocation',
    // 'getDims',
    // 'getLine',
    // 'getScrollInvariantLine',
    // 'getScrollInvariantUpdateRange',
    // 'getUpdateRange',
    'hideCursor',
    'showCursor',
    'installColors',
    'refresh',
    'resetToInitialState',
    'resizeTerminal',
    'scroll',
    // 'setCursorStyle',
    'setIconTitle',
    'setTitle',
    'softReset',
    'updateFullScreen',
    // 'registerOscHandler'
  ],
});

export default codegenNativeComponent<NativeProps>('RtnSshTerminalView');
