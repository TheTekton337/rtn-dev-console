import type { UIManagerStatic, ViewProps } from 'react-native';

type DevConsoleCommands = 'hideCursor' | 'showCursor';

interface RNCDevConsoleUIManager<Commands extends string>
  extends UIManagerStatic {
  getViewManagerConfig: (name: string) => {
    Commands: { [key in Commands]: number };
  };
}

export type RNCDevConsoleUIManagerIOS =
  RNCDevConsoleUIManager<DevConsoleCommands>;

export interface IOSDevConsoleProps extends DevConsoleSharedProps {}

export interface DevConsoleSharedProps extends ViewProps {}

export interface DevConsoleMethods {
  hideCursor: () => void;
  showCursor: () => void;
}
