import { BehaviorSubject } from 'rxjs';
import { map } from 'rxjs/operators';
import type { LogEntry } from '../types/Log';

const logEntriesSubject = new BehaviorSubject<LogEntry[]>([]);

/**
 * Adds a log entry for a specified source.
 * @param sourceId The source id to attribute the log message to.
 * @param message The log message to be added.
 */
export function addLogEntry(sourceId: string, message: string) {
  const currentEntries = logEntriesSubject.getValue();
  const newEntry: LogEntry = {
    sourceId,
    message,
    // TODO: add timestamp field
    // timestamp: new Date().toISOString(),
  };
  logEntriesSubject.next([...currentEntries, newEntry]);
}

/**
 * Clears all log entries for a specified source.
 * @param sourceId The source id whose logs should be cleared.
 */
export function clearLogEntries(sourceId: string) {
  const filteredEntries = logEntriesSubject
    .getValue()
    .filter((entry) => entry.sourceId !== sourceId);
  logEntriesSubject.next(filteredEntries);
}

/**
 * Retrieves an observable that emits log entries, optionally filtered by source id.
 * @param sourceId Optional source id to filter log entries by.
 * @returns An observable emitting log entries.
 */
export function getLogEntries(sourceId?: string) {
  return logEntriesSubject
    .asObservable()
    .pipe(
      map((entries) =>
        sourceId
          ? entries.filter((entry) => entry.sourceId === sourceId)
          : entries
      )
    );
}

export const logEntriesObservable = logEntriesSubject.asObservable();
