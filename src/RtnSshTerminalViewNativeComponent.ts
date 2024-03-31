import codegenNativeCommands from 'react-native/Libraries/Utilities/codegenNativeCommands';
import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { HostComponent, ViewProps } from 'react-native';
import type {
  Double,
  // Float,
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
    'rtn-dev-console - initializing terminal...'
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

  fontColor?: string;
  fontSize?: Int32;
  fontFamily?: string;
  backgroundColor?: string;
  cursorColor?: string;
  scrollbackLines?: WithDefault<Int32, 500>;

  /**
   * Enable or disable input to the terminal. Useful if the terminal is used only for display purposes.
   */
  inputEnabled?: boolean;

  // onConnectionChange?: DirectEventHandler<TerminalEvent>;

  /**
   * Callback invoked when data is received from the terminal.
   */
  // TODO: Determine comm method.
  // onDataReceived?: DirectEventHandler<DataEvent>;

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
  hideCursor: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
  showCursor: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['hideCursor', 'showCursor'],
});

export default codegenNativeComponent<NativeProps>('RtnSshTerminalView');
