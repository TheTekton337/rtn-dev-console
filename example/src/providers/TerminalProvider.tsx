import React, { createContext } from 'react';

import type { ConnectionStatus } from '../types/SshConnection';
import type { NativeTerminal, TerminalContextType } from '../types/Terminal';

// TODO: Add comments

export const TerminalContext = createContext<TerminalContextType | null>(null);

export interface TerminalProviderProps {
  children: React.ReactNode;
  sessionId: string;
  terminalId: string;
  terminal: NativeTerminal | null;
  connectionStatus: ConnectionStatus;
  setTerminal: (ref: NativeTerminal) => void;
}

const TerminalProvider: React.FC<TerminalProviderProps> = ({
  children,
  sessionId,
  terminalId,
  connectionStatus,
  terminal,
  setTerminal,
}) => {
  return (
    <TerminalContext.Provider
      value={{ terminal, setTerminal, sessionId, terminalId, connectionStatus }}
    >
      {children}
    </TerminalContext.Provider>
  );
};

export default TerminalProvider;
