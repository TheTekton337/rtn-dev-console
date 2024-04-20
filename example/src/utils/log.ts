/**
 * LogLevel
 */
export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
}

// TODO: Allow setting current log level via app config.
const currentLevel: LogLevel = LogLevel.INFO;

/**
 * Logs to console if level is equal or above current log level
 * @param level The log level
 * @param source The log event source
 * @param message The log message
 * @param args Additional args
 */
export const log = (
  level: LogLevel,
  source: string,
  message: string,
  ...args: any[]
): void => {
  if (level < currentLevel) {
    return;
  }

  let logMethod: (message?: any, ...optionalParams: any[]) => void =
    console.log;

  switch (level) {
    case LogLevel.DEBUG:
    case LogLevel.INFO:
      logMethod = console.log;
      break;
    case LogLevel.WARN:
      logMethod = console.warn;
      break;
    case LogLevel.ERROR:
      logMethod = console.error;
      break;
  }

  logMethod(`[${LogLevel[level]}] (${source}): ${message}`, ...args);
};

/**
 * Logs to console if level is equal or above current log level.
 * Prefixes the log message with a timestamp.
 * @param level The log level
 * @param source The log event source
 * @param message The log message
 * @param args Additional args
 */
export const logWithTime = (
  level: LogLevel,
  source: string,
  message: string,
  ...args: any[]
): void => {
  logWithCallback(level, source, message, undefined, ...args);
};

/**
 * Logs to console if level is equal or above current log level with callback.
 * Accepts a callback to modify the message, defaults to adding a timestamp.
 * @param level
 * @param source
 * @param message
 * @param callback
 * @param args
 */
export const logWithCallback = (
  level: LogLevel,
  source: string,
  message: string,
  callback: (msg: string) => string = defaultTimestampPrefix,
  ...args: any[]
): void => {
  message = callback(message);
  log(level, source, message, ...args);
};

// Default callback function to add a timestamp
/**
 * Logs to console if level is equal or above current log level with callback.
 * @param message The log message
 * @returns message prefixed with timestamp
 */
export const defaultTimestampPrefix = (message: string): string => {
  return `${new Date().toISOString()} ${message}`;
};
