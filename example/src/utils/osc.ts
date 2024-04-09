import uuid from 'react-native-uuid';
import { Notifications } from 'react-native-notifications';
import {
  Command,
  type CommandHandler,
  type NotificationPayload,
} from '../types/osc';

const DEBUG = true;

const debugLog = (...args: any[]) => {
  if (DEBUG) {
    console.log(...args);
  }
};

/**
 * OSC codes mapping.
 * @type {Record<string, number>}
 */
export const OSC_CODES = {
  NOTIFICATION: 337, // TODO: Add other OSC codes as needed
};

/**
 * Command handlers mapping.
 * @type {Record<string, CommandHandler>}
 */
const commandHandlers: Record<Command, CommandHandler> = {
  notification: (payload: NotificationPayload) => {
    debugLog('Received notification command');
    Notifications.postLocalNotification({
      identifier: uuid.v4().toString(),
      payload,
      body: payload.body,
      title: payload.title,
      sound: payload.sound || 'default',
      badge: payload.badge || 1,
      type: payload.type || 'default',
      thread: payload.thread || 'default',
    });
  },
  // Future handlers can be added here
};

/**
 * Handles OSC events by executing the corresponding command handler.
 * @param {number} code - The OSC code.
 * @param {string} data - The data associated with the OSC event.
 */
export const handleOSCEvent = (code: number, data: string) => {
  debugLog(`Received OSC event with code: ${code} and data: '${data}'`);

  if (code === OSC_CODES.NOTIFICATION) {
    const [commandString, message = 'No message provided'] = data.split('|', 2);
    const command: Command = commandString as Command;
    debugLog(`Parsed command: '${command}', message: '${message}'`);

    if (!command) {
      console.warn('Command is undefined or empty. Unable to process.');
      return;
    }

    if (!(command in Command)) {
      console.warn(`Unsupported command received: '${commandString}'`);
      return;
    }

    const handler = commandHandlers[command];
    if (!handler) {
      console.warn(
        `No handler found for command: '${command}'. Ensure it's registered in commandHandlers.`
      );
      return;
    }

    try {
      debugLog(
        `Executing handler for command: '${command}' with message: '${message}'`
      );
      handler({
        title: 'Shell Notification',
        body: message,
      });
    } catch (error) {
      console.error(
        `Error executing handler for command: '${command}'. Error: ${error}`
      );
    }
  } else {
    console.warn(`Unhandled OSC code: ${code}.`);
  }
};

// Additional suggested utilities implementation stubs

// TODO: Command authorization example
// const isAuthorizedCommand = (_command: string): boolean => {
//   return true;
// };

// 6. Feedback Mechanism
// Define a way to send feedback to the shell script. This could involve
// sending a message back through an established communication channel.
