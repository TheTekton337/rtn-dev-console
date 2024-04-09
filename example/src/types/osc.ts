/**
 * Command types
 */
export enum Command {
  notification = 'notification',
  // Add other commands as needed
}

/**
 * Defines the structure for notification payloads.
 * @typedef {Object} NotificationPayload
 * @property {string} title - The notification title.
 * @property {string} body - The main content of the notification.
 * @property {string} [sound] - Notification sound.
 * @property {number} [badge] - Badge number for the app icon.
 * @property {string} [type] - Type of notification.
 * @property {string} [thread] - Thread identifier for grouping notifications.
 */
export interface NotificationPayload {
  title: string;
  body: string;
  sound?: string;
  badge?: number;
  type?: string;
  thread?: string;
}

/**
 * Type definition for command handlers.
 * @callback CommandHandler
 * @param {NotificationPayload} payload - The payload for the notification.
 */
export type CommandHandler = (payload: NotificationPayload) => void;
