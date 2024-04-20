import { useContext } from 'react';
import { TerminalContext } from '../providers/TerminalProvider';

// TODO: Add comments

export const useTerminal = () => {
  const context = useContext(TerminalContext);

  if (!context) {
    throw new Error('useTerminal must be used within a TerminalProvider');
  }

  return context;
};
