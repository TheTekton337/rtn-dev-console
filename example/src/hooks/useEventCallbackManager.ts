import { useCallback, useState } from 'react';
import { type NativeSyntheticEvent } from 'react-native';

interface EventCallbacks {
  [eventName: string]: (data: any) => void;
}

export const useEventCallbackManager = () => {
  const [callbacksMap, setCallbacksMap] = useState<Map<string, EventCallbacks>>(
    new Map()
  );

  const registerCallback = useCallback(
    <T>(id: string, eventName: string, callback: (data: T) => void) => {
      setCallbacksMap((prev) => {
        const existing = prev.get(id) ?? {};
        existing[eventName] = callback;
        return new Map(prev).set(id, existing);
      });
    },
    []
  );

  const getHandler = useCallback(
    (eventName: string) => {
      return <T extends { callbackId: string }>(
        event: NativeSyntheticEvent<T>
      ) => {
        const { callbackId, ...data } = event.nativeEvent;
        const callbacks = callbacksMap.get(callbackId) ?? {};
        callbacks[eventName]?.(data);
      };
    },
    [callbacksMap]
  );

  return { registerCallback, getHandler };
};
