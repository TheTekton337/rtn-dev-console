import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ViewProps } from 'react-native';
import type {
  // Float,
  Int32,
  WithDefault,
  // DirectEventHandler,
  BubblingEventHandler,
} from 'react-native/Libraries/Types/CodegenTypes';

type DataEvent = Readonly<{
  data: string;
}>;

// type TerminalEvent = Readonly<{
//   command: string;
// }>;

interface NativeProps extends ViewProps {
  color?: string;
  /**
   * Initial text to be displayed in the terminal.
   */
  initialText?: string;

  /**
   * Callback invoked when data is received from the terminal.
   */
  onDataReceived?: BubblingEventHandler<DataEvent>;

  /**
   * Callback invoked when the terminal size changes, for example, after a device rotation.
   */
  onSizeChanged?: BubblingEventHandler<Readonly<{ cols: Int32; rows: Int32 }>>;

  // onConnectionChange?: DirectEventHandler<TerminalEvent>;

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
}

export default codegenNativeComponent<NativeProps>('RtnDevConsoleView');
