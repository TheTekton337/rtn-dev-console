import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { HostComponent, ViewProps } from 'react-native';
import type {
  Double,
  Int32,
  WithDefault,
  DirectEventHandler,
} from 'react-native/Libraries/Types/CodegenTypes';

export type EnvironmentVariable = {
  name: string;
  variable: string;
};

export type HostConfiguration = {
  /**
   * The host to connect to.
   */
  host: string;
  /**
   * The port to connect to.
   */
  port?: WithDefault<Int32, 22>;
  /**
   * The terminal environment variables to use.
   */
  environment?: ReadonlyArray<EnvironmentVariable>;
  /**
   * The terminal type to use.
   */
  terminal?: WithDefault<string, 'xterm-256color'>;
};

export type AuthConfiguration = {
  /**
   * The type of authentication to use.
   */
  authType?: WithDefault<
    'password' | 'pubkeyFile' | 'pubkeyMemory' | 'interactive',
    'password'
  >;
  /**
   * The username to use.
   */
  username?: string;
  /**
   * The password to use. (Used as passphrase for pubkey auth.)
   */
  password?: string;
  /**
   * The optional path to the public key file in the documents directory.
   */
  publicKeyPath?: string;
  /**
   * The path to the private key file in the documents directory.
   */
  privateKeyPath?: string;
  /**
   * The optional public key string.
   */
  publicKey?: string;
  /**
   * The private key string.
   */
  privateKey?: string;
};

export type TerminalLogEvent = Readonly<{
  /**
   * The terminal that logged the event.
   */
  terminalId?: Int32;
  /**
   * The type of log.
   */
  logType?: WithDefault<
    'info' | 'warning' | 'error' | 'connectionError',
    'info'
  >;
  /**
   * The message of the log.
   */
  message: string;
}>;

export type ConnectEvent = Readonly<{
  /**
   * The terminal that was connected.
   */
  terminalId: Int32;
}>;

export type ClosedEvent = Readonly<{
  /**
   * The terminal that was closed.
   */
  terminalId: Int32;
  /**
   * The reason for the close.
   */
  reason: string;
}>;

export type OSCEvent = Readonly<{
  /**
   * The terminal that received the OSC.
   */
  terminalId?: Int32;
  /**
   * The OSC code.
   */
  code: Int32;
  /**
   * The OSC command.
   */
  data: string;
}>;

export type DownloadCompleteEvent = Readonly<{
  /**
   * The terminal that completed the SCP.
   */
  terminalId?: Int32;
  /**
   * The SCP callback ID.
   */
  callbackId: string;
  /**
   * The data transferred.
   */
  data?: string;
  /**
   * The exit code of the SCP.
   */
  // fileInfo: Readonly<{
  //   /**
  //    * The file size.
  //    */
  //   fileSize: Double;
  //   /**
  //    * The modification time.
  //    */
  //   modificationTime: Double;
  //   /**
  //    * The access time.
  //    */
  //   accessTime: Double;
  //   /**
  //    * The permissions.
  //    */
  //   permissions: Int32;
  // }>;
  fileInfo: string;
  /**
   * The error JSON.
   */
  error?: string;
}>;

export type UploadCompleteEvent = Readonly<{
  /**
   * The terminal that completed the SCP.
   */
  terminalId?: Int32;
  /**
   * The SCP callback ID.
   */
  callbackId: string;
  /**
   * The bytes transferred.
   */
  bytesTransferred: Double;
  /**
   * The error JSON.
   */
  error?: string;
}>;

export type DownloadProgressEvent = Readonly<{
  /**
   * The terminal that reported the SCP progress.
   */
  terminalId?: Int32;
  /**
   * The SCP callback ID.
   */
  callbackId: string;
  /**
   * The bytes transferred.
   */
  bytesTransferred: Double;
}>;

export type UploadProgressEvent = Readonly<{
  /**
   * The terminal that reported the SCP progress.
   */
  terminalId?: Int32;
  /**
   * The SCP callback ID.
   */
  callbackId: string;
  /**
   * The total bytes to transfer.
   */
  totalBytes: Double;
  /**
   * The bytes transferred.
   */
  bytesTransferred: Double;
}>;

export type CommandExecutedEvent = Readonly<{
  /**
   * The terminal that executed the command.
   */
  terminalId?: Int32;
  /**
   * The SSH callback ID.
   */
  callbackId: string;
  /**
   * The command output.
   */
  data?: string;
  /**
   * The error JSON.
   */
  error?: string;
}>;

// TODO: Implement callback and interactive authentication
// export type InteractiveAuthRequestEvent = Readonly<{
//   prompt: string;
// }>;

export type SizeChangedEvent = Readonly<{
  /**
   * The terminal that changed its size.
   */
  terminalId: Int32;
  /**
   * The new width.
   */
  newCols: Int32;
  /**
   * The new height.
   */
  newRows: Int32;
}>;

export type HostCurrentDirectoryUpdateEvent = Readonly<{
  /**
   * The terminal that changed its current directory.
   */
  terminalId: Int32;
  /**
   * The new current directory.
   */
  directory: string;
}>;

export type ScrollEvent = Readonly<{
  /**
   * The terminal that scrolled.
   */
  terminalId: Int32;
  /**
   * The new scroll position.
   */
  position: Double;
}>;

export type RequestOpenLinkEvent = {
  /**
   * The terminal that requested the link.
   */
  terminalId: Int32;
  /**
   * The link that was requested.
   */
  link: string;
  /**
   * The link parameters.
   */
  params: string;
};

export type BellEvent = Readonly<{
  /**
   * The terminal that beeped.
   */
  terminalId: Int32;
}>;

export type ClipboardCopyEvent = Readonly<{
  /**
   * The terminal that copied to the clipboard.
   */
  terminalId: Int32;
  /**
   * The content that was copied to the clipboard.
   */
  content: string;
}>;

export type ITermContentEvent = Readonly<{
  /**
   * The terminal that received the content.
   */
  terminalId: Int32;
  /**
   * The content.
   */
  content: string;
}>;

export type RangeChangedEvent = Readonly<{
  /**
   * The terminal that changed its selection.
   */
  terminalId: Int32;
  /**
   * The start of the selection.
   */
  startY: Int32;
  /**
   * The end of the selection.
   */
  endY: Int32;
}>;

export interface NativeProps extends ViewProps {
  /**
   * Prints connection debug output to terminal.
   */
  debug?: WithDefault<boolean, false>;

  /**
   * Enables or disables input.
   * TODO: Support inputEnabled prop
   */
  // inputEnabled?: WithDefault<boolean, true>;

  /**
   * SSH connection established automatically when true and
   * hostConfig/authConfig are provided.
   */
  autoConnect?: WithDefault<boolean, true>;

  /**
   * SSH host configuration
   */
  hostConfig: Readonly<HostConfiguration>;

  /**
   * SSH authentication configuration
   */
  authConfig: Readonly<AuthConfiguration>;

  /**
   * Initial text to be displayed in the terminal.
   */
  initialText?: WithDefault<
    string,
    'rtn-dev-console - connecting to my localhost\\r\\n\\n'
  >;

  /**
   * OSC handler codes to be registered.
   */
  oscHandlerCodes?: Int32[];

  /**
   * Callback invoked when a terminal log event occurs.
   */
  onTerminalLog?: DirectEventHandler<TerminalLogEvent>;

  /**
   * Callback invoked when a terminal SSH connection opens.
   */
  onConnect?: DirectEventHandler<ConnectEvent>;

  /**
   * Callback invoked when a terminal SSH connection closes.
   */
  onClosed?: DirectEventHandler<ClosedEvent>;

  /**
   * Callback invoked when the terminal receives an OSC command.
   */
  onOSC?: DirectEventHandler<OSCEvent>;

  /**
   * Callback invoked when the terminal completes an SCP read transfer.
   */
  onDownloadComplete?: DirectEventHandler<DownloadCompleteEvent>;

  /**
   * Callback invoked when the terminal completes an SCP write transfer.
   */
  onUploadComplete?: DirectEventHandler<UploadCompleteEvent>;

  /**
   * Callback invoked when the terminal reports SCP read progress.
   */
  onDownloadProgress?: DirectEventHandler<DownloadProgressEvent>;

  /**
   * Callback invoked when the terminal reports SCP write progress.
   */
  onUploadProgress?: DirectEventHandler<UploadProgressEvent>;

  /**
   * Callback invoked when the terminal completes an SSH command invoked by executeCommand().
   */
  onCommandExecuted?: DirectEventHandler<CommandExecutedEvent>;

  // TODO: Implement callback and interactive authentication
  // onInteractiveAuthentication?: DirectEventHandler<InteractiveAuthRequestEvent>;

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
}

export interface NativeCommands {
  // rtn-dev-console methods
  connect: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => Promise<boolean>;
  close: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => Promise<boolean>;
  executeCommand: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    callbackId: string,
    command: string
  ) => void;
  writeCommand: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    command: string
  ) => void;
  // testCallback: (
  //   viewRef: React.ElementRef<HostComponent<NativeProps>>,
  //   callbackId: string,
  //   value: string
  // ) => void;
  download: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    callbackId: string,
    from: string,
    to: string
  ) => Promise<boolean>;
  upload: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    callbackId: string,
    from: string,
    to: string
  ) => Promise<boolean>;
  // TODO: Support callback and interactive authentication
  // sendInteractiveAuthentication: (
  //   viewRef: React.ElementRef<HostComponent<NativeProps>>,
  //   prompt: string
  // ) => void;
  // Terminal methods
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
  getBufferAsString: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>
  ) => Promise<string>;
  // getText: (
  //   viewRef: React.ElementRef<HostComponent<NativeProps>>
  // ) => Promise<string>;
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
  resize: (
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
    // rtn-dev-console methods
    'connect',
    'close',
    'executeCommand',
    'writeCommand',
    'download',
    'upload',
    // TODO: Support callback and interactive authentication
    // 'sendInteractiveAuthentication',
    // Terminal methods
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
    'getBufferAsString',
    // 'getText',
    'getTopVisibleRow',
    // **
    // 'getCharData',
    // 'getCharacter',
    // 'getCursorLocation',
    // 'getDims',
    // 'getLine',
    // 'getScrollInvariantLine',
    // 'getScrollInvariantUpdateRange',
    // 'getUpdateRange',
    // **
    'hideCursor',
    'showCursor',
    'installColors',
    'refresh',
    'resetToInitialState',
    'resize',
    'scroll',
    // 'setCursorStyle',
    'setIconTitle',
    'setTitle',
    'softReset',
    'updateFullScreen',
  ],
});

export default codegenNativeComponent<NativeProps>('RtnSshTerminalView');
