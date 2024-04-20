import { BehaviorSubject } from 'rxjs';
import { map } from 'rxjs/operators';

import type { LogEntry } from '../types/Log';

// TODO: Improve comments
// TODO: Refactor functional or OO for these services, but pick one (functional)
class LogDataService {
  private logEntriesSubject = new BehaviorSubject<LogEntry[]>([]);

  /**
   * Adds a log entry from the specified source
   * @param sourceId The source id
   * @param message The log message
   */
  public addLogEntry(sourceId: string, message: string) {
    const currentEntries = this.logEntriesSubject.getValue();
    const newEntry: LogEntry = { sourceId, message };
    this.logEntriesSubject.next([...currentEntries, newEntry]);
  }

  /**
   * Clears log entries for the specified source
   * @param sourceId The source id
   */
  public clearLogEntries(sourceId: string) {
    const filteredEntries = this.logEntriesSubject
      .getValue()
      .filter((entry) => entry.sourceId !== sourceId);
    this.logEntriesSubject.next(filteredEntries);
  }

  /**
   * Returns all log entries, optionally filtered by source id
   * @param sourceId The optional source id
   * @returns Array of log entries
   */
  public getLogEntries(sourceId?: string) {
    return this.logEntriesSubject
      .asObservable()
      .pipe(
        map((entries) =>
          sourceId
            ? entries.filter((entry) => entry.sourceId === sourceId)
            : entries
        )
      );
  }
}

export const logDataService = new LogDataService();
