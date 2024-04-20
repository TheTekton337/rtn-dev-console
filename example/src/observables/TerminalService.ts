import uuid from 'react-native-uuid';
import { BehaviorSubject, Subject } from 'rxjs';
import type { AsyncEvent, AsyncEventData } from '../types/async_callbacks';
import type { NativeSyntheticEvent } from 'react-native';
import type { SshTerminalMethods } from 'rtn-dev-console';
import { log, LogLevel } from '../utils/log';

const logModule = 'TerminalService';

// TODO: Improve DEBUG logging
// TODO: Improve comments

// Map of callbacks for rtn fabric component events.
const callbacks = new Map<
  string,
  (event: AsyncEvent<AsyncEventData>) => void
>();
const asyncEvents$ = new Subject<AsyncEvent<AsyncEventData>>();

/**
 * Registers a callback for a given rtn fabric component's event.
 * This function generates a unique callback ID and maps the callback for later execution.
 *
 * @param callback The callback function to handle event data.
 * @returns A string representing the unique callback ID.
 */
export const registerCallback = <T extends AsyncEventData>(
  callback: (event: AsyncEvent<T>) => void
): string => {
  const callbackId = uuid.v4().toString();
  callbacks.set(
    callbackId,
    callback as unknown as (event: AsyncEvent<AsyncEventData>) => void
  );
  return callbackId;
};

/**
 * Handles a native event by invoking the registered callback based on the callbackId.
 * It unwraps the NativeSyntheticEvent to get the actual event data.
 *
 * @param nativeEvent A NativeSyntheticEvent containing the wrapped event data and callbackId.
 * @param options Options for event handling:
 *                - broadcast: If true, the event is broadcasted to all subscribers.
 *                - autoCleanup: If true, the callback is removed after execution.
 */
export const handleNativeEvent = (eventName: string) => {
  return <
    T extends {
      callbackId?: string;
      terminalView?: number;
      terminalId?: string;
      sessionId?: string;
    },
  >(
    nativeEvent: NativeSyntheticEvent<T>
  ) => {
    const { callbackId, ...data } = nativeEvent.nativeEvent;

    const nextEvent: AsyncEvent<AsyncEventData> = {
      ...data,
      callbackId,
      type: eventName,
    };

    if (!callbackId) {
      asyncEvents$.next(nextEvent);
      return;
    }

    const callback = callbacks.get(callbackId);

    if (callback) {
      callback({ type: eventName, ...data, callbackId });
      nextEvent.callbackId = callbackId;
      callbacks.delete(callbackId);
    } else if (callbackId) {
      log(
        LogLevel.WARN,
        logModule,
        `No callback found for ${eventName} with ID: ${callbackId}`
      );
    }

    asyncEvents$.next(nextEvent);
  };
};

/**
 * Observable to allow subscription to all asynchronous events processed by this service.
 */
export const asyncEventsObservable = asyncEvents$.asObservable();

// Create a BehaviorSubject to hold the terminal instance
const terminalSubject = new BehaviorSubject<SshTerminalMethods | null>(null);

// Function to update the terminal instance
export const initializeTerminal = (): void => {
  const terminalInstance = getSshTerminalInstance();
  terminalSubject.next(terminalInstance);
};

// Function to clean up the terminal instance
export const destroyTerminal = (): void => {
  terminalSubject.next(null);
};

// Export the observable for components to subscribe
export const terminal$ = terminalSubject.asObservable();

export const getSshTerminalInstance = (): SshTerminalMethods | null => {
  return terminalSubject.value;
};

export const setTerminalInstance = (
  terminalInstance: SshTerminalMethods | null
): void => {
  terminalSubject.next(terminalInstance);
};
