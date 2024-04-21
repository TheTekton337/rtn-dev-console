import type { SshTerminalMethods } from 'rtn-dev-console';

import type { ConnectionStatus } from './SshConnection';

// TODO: Add comments

export type NativeTerminal = SshTerminalMethods;

export interface TerminalContextType {
  sessionId: string;
  terminalId: string;
  connectionStatus: ConnectionStatus;
  terminal: NativeTerminal | null;
  setTerminal: (ref: NativeTerminal) => void;
}
