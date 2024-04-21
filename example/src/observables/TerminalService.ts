import { BehaviorSubject } from 'rxjs';

import type { SshTerminalMethods } from 'rtn-dev-console';

import {
  registerAsyncCallback,
  bindFabricEvent,
  asyncEventsObservable,
} from './RTNEventService';

const terminalSubject = new BehaviorSubject<SshTerminalMethods | null>(null);

/**
 * Observable to monitor changes to the terminal instance.
 */
export const terminal$ = terminalSubject.asObservable();

/**
 * Initializes the terminal instance using predefined settings or configurations.
 */
export const initializeTerminal = (): void => {
  const terminalInstance = getSshTerminalInstance();
  terminalSubject.next(terminalInstance);
};

/**
 * Destroys the current terminal instance, cleaning up resources.
 */
export const destroyTerminal = (): void => {
  terminalSubject.next(null);
};

/**
 * Retrieves the current instance of the SSH terminal.
 * @returns {SshTerminalMethods | null} The current terminal instance or null if not instantiated.
 */
export const getSshTerminalInstance = (): SshTerminalMethods | null => {
  return terminalSubject.value;
};

/**
 * Sets or updates the current terminal instance.
 * @param terminalInstance {SshTerminalMethods | null} The terminal instance to set.
 */
export const setTerminalInstance = (
  terminalInstance: SshTerminalMethods | null
): void => {
  terminalSubject.next(terminalInstance);
};

/**
 * Registers a callback function to handle asynchronous events related to the terminal.
 * Delegates to RTNEventService for registration.
 */
export const registerTerminalCallback = registerAsyncCallback;

/**
 * Binds a function to handle specific events emitted by the terminal component.
 * Delegates to RTNEventService for binding event handlers.
 */
export const bindTerminalEvent = bindFabricEvent;

/**
 * Observable to subscribe to all asynchronous terminal events.
 * Allows components to react to terminal updates in real-time.
 */
export const terminalEventsObservable = asyncEventsObservable;
