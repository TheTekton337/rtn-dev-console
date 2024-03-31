import type { UIManagerStatic, ViewProps } from 'react-native';

type SshTerminalCommands = 'hideCursor' | 'showCursor';

interface RNCSshTerminalUIManager<Commands extends string>
  extends UIManagerStatic {
  getViewManagerConfig: (name: string) => {
    Commands: { [key in Commands]: number };
  };
}

export type RNCSshTerminalUIManagerIOS =
  RNCSshTerminalUIManager<SshTerminalCommands>;

export interface IOSSshTerminalProps extends SshTerminalSharedProps {}

export interface SshTerminalSharedProps extends ViewProps {}

export interface SshTerminalMethods {
  hideCursor: () => void;
  showCursor: () => void;
}
