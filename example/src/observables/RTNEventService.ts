import type { NativeSyntheticEvent } from 'react-native';

import uuid from 'react-native-uuid';
import { Subject } from 'rxjs';

import { log, LogLevel } from '../utils/log';

import type {
  AsyncEvent,
  AsyncEventData,
  AsyncEventKind,
} from '../types/TerminalEvents';

const logModule = 'RTNEventService';

/**
 * Create subject to broadcast asynchronous events
 * NOTE: asynchronous instead of async denotes these are async due to
 * rtn->native->rtn native command pattern, to avoid confusion with js async
 */
const asyncEvents$ = new Subject<AsyncEvent<AsyncEventData>>();

/**
 * RTN asynchronous completion callback store
 */
const callbacks = new Map<
  string,
  (event: AsyncEvent<AsyncEventData>) => void
>();

/**
 * Registers a callback to handle specific types of asynchronous events.
 * Returns a unique callback ID for event association.
 *
 * @param callback The callback function to handle event data.
 * @returns A string representing the unique callback ID.
 */
export function registerAsyncCallback<T extends AsyncEventData>(
  eventName: AsyncEventKind,
  callback: (event: T) => void,
  callbackId?: string
): string {
  const registeredCallbackId = callbackId ? callbackId : uuid.v4().toString();
  callbacks.set(
    `${eventName}_${registeredCallbackId}`,
    callback as (event: AsyncEvent<AsyncEventData>) => void
  );
  return registeredCallbackId;
}

export function unregisterAsyncCallback(callbackId: string) {
  callbacks.delete(callbackId);
  log(LogLevel.DEBUG, logModule, `Unregistered callback [${callbackId}]`);
}

/**
 * Binds an event handler to specific event types within RTN Fabric components.
 * Binding processes incoming native events by invoking the appropriate
 * registered callbacks from `registerAsyncCallback`.
 *
 * @param eventName The name of the event type being bound.
 * @returns A function that processes the event using the provided native event data.
 */
export function bindFabricEvent(
  eventName: AsyncEventKind,
  unregisterImmediately: Boolean = false
) {
  return <
    T extends {
      callbackId?: string;
    },
  >(
    nativeEvent: NativeSyntheticEvent<T>
  ) => {
    const { callbackId: rawCallbackId, ...data } = nativeEvent.nativeEvent;

    const nextEvent: AsyncEvent<AsyncEventData> = {
      ...data,
      callbackId: rawCallbackId,
      type: eventName,
    };

    if (!rawCallbackId) {
      asyncEvents$.next(nextEvent);
      return;
    }

    const callbackId = `${eventName}_${rawCallbackId}`;

    const callback = callbacks.get(callbackId);

    if (callback) {
      callback(nextEvent);
      unregisterImmediately && callbacks.delete(callbackId);
    } else {
      log(
        LogLevel.WARN,
        logModule,
        `No callback found for registered callbackId: ${callbackId}`
      );
      log(
        LogLevel.DEBUG,
        logModule,
        `callbacks: ${JSON.stringify(callbacks.keys())}`
      );
    }

    asyncEvents$.next(nextEvent);
  };
}

/**
 * Provides an observable to allow subscription to all processed events,
 * facilitating reactive responses to event data and updates.
 */
export const asyncEventsObservable = asyncEvents$.asObservable();
