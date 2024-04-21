// TODO: Add comments

export type DesiredState =
  | 'open'
  | 'closed'
  | 'pending-open'
  | 'pending-closed'
  | null;

export type DisconnectReason = 'user' | 'error' | 'timeout' | null;

export interface ConnectionStatus {
  connected: boolean;
  isConnecting: boolean;
  desiredState: DesiredState;
  disconnectReason: DisconnectReason;
}
