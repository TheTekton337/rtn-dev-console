# rtn-dev-console

Cross-platform terminal Fabric component for react-native using SwiftSH/SwiftTerm (WIP) for iOS and Termux (TODO) for Android.

This component is in its early stages of development. It is not recommended for production use. Issues and pull requests are welcome.

- [x] SwiftSH/SwiftTerm wrapper component for iOS
  - [x] Basic props, events, and methods.
- [ ] Termux wrapper component for android
  - [ ] Basic props, events, and methods.
- [ ] Common interface between iOS and android

## Installation

```sh
npm install rtn-dev-console
```

## Usage

Import and use the `SshTerminal` component in your React Native application to integrate a cross-platform SSH terminal. Configure the terminal by setting its props, such as `host`, `port`, `username`, and `password`. (TODO: pubkey and interactive auth.) Listen to various terminal events through callback props to handle terminal interactions effectivly.

This example demonstrates how to instantiate the `SshTerminal` component with basic connection properties.

```js
import React from 'react';
import { SshTerminal } from 'rtn-dev-console';

function App() {
  return (
    <SshTerminal
      host="192.168.1.1"
      port={22}
      username="your_username"
      password="your_password"
      onConnected={() => console.log('Connected')}
      onClosed={() => console.log('Connection closed')}
      style={{ flex: 1 }}
    />
  );
}
```

## Props

The `SshTerminal` component accepts several props to configure the SSH connection, terminal appearance, and functionality:

- `debug`: Enables connection debug output in the terminal.
- `initialText`: Initial text displayed in the terminal upon loading.
- `host`, `port`, `username`, `password`: SSH server connection details.

## Events

`SshTerminal` provides event props to notify your application about various terminal activities:

- `onSizeChanged`: Fired when the terminal's size changes, providing new columns and rows.
- `onHostCurrentDirectoryUpdate`: Indicates the current directory has changed (OSC command 7).
- `onScrolled`: Notifies when the terminal has been scrolled.
- `onRequestOpenLink`: Invoked when a link is opened from the terminal.
- `onBell`: Triggered when the terminal host beeps.
- `onClipboardCopy`: Occurs when OSC 52 puts data on the clipboard.
- `onITermContent`: Fired for unhandled OSC 1337 iTerm2 content.
- `onRangeChanged`, `onTerminalLoad`, `onConnect`, `onClosed`, `onSshError`, `onSshConnectionError`: Various connection and state change events.

## Commands

The `SshTerminal` component exposes several commands that allow you to interact programmatically with the terminal instance. (NOTE: This early release has not had comprehensive testing, so caveat empor. Issues and PRs are welcome.)

These commands are accessible by calling them directly on the component's ref.

**Note:** Some commands are designed to work asynchronously and return a promise. Ensure to handle these promises correctly in your code to manage asynchronous operations.

Here are some examples:

### sendMotionWithButtonFlags

Sends a mouse event to the terminal.

```js
ref.current.sendMotionWithButtonFlags(buttonFlags, x, y, pixelX, pixelY);
```

### encodeButtonWithButton

Encodes mouse button events, potentially useful for custom mouse interactions.

```js
ref.current
  .encodeButtonWithButton(button, release, shift, meta, control)
  .then((encodedValue) => {
    console.log(encodedValue);
  });
```

### sendEventWithButtonFlags

Sends an event to the terminal with specified button flags.

```js
ref.current.sendEventWithButtonFlags(buttonFlags, x, y);
```

### sendEventWithButtonFlagsPixel

Similar to `sendEventWithButtonFlags` but includes pixel dimensions for more precise interaction.

```js
ref.current.sendEventWithButtonFlagsPixel(buttonFlags, x, y, pixelX, pixelY);
```

### feedText

Feeds text directly into the terminal.

```js
ref.current.feedText('Hello, world!');
```

### sendResponseText

Sends a response text back to the terminal. Useful for automated scripts or commands.

```js
ref.current.sendResponseText('Command output or response');
```

### changedLines

Retrieves the set of line indices that have changed.

```js
ref.current.changedLines().then((changedLineIndices) => {
  console.log(changedLineIndices);
});
```

### clearUpdateRange

Clears the terminal's update range.

```js
ref.current.clearUpdateRange();
```

### emitLineFeed

Terminal - Emits a line feed in the terminal.

```js
ref.current.emitLineFeed();
```

### installColors

TerminalView - Installs the new colors as the default colors and recomputes the current and ansi palette. This installs both the colors into the terminal engine and updates the UI accordingly. TODO: Implement onTerminalLoaded event for this.

**Note:**
Colors argument should be an array of 16 values that correspond to the 16 ANSI colors, if the array does not contain 16 elements, it will not do anything.

```js
ref.current.installColors(JSON.stringify(['#000000', '#FFFFFF']));
```

This method expects a JSON-encoded string representing an array of colors. Ensure the string is correctly formatted to avoid parsing errors.

### Additional Commands

Other commands like `resetToInitialState`, `resizeTerminal`, `scroll`, `setIconTitle`, `setTitle`, `softReset`, and `updateFullScreen` provide further control over the terminal's state and appearance. Their usage is straightforward and follows the pattern of invoking methods on the component's ref with appropriate parameters.

### Additional Documentation

[https://migueldeicaza.github.io/SwiftTermDocs/documentation/swiftterm](https://migueldeicaza.github.io/SwiftTermDocs/documentation/swiftterm)

### Credits

The development and capabilities of rtn-dev-console are made possible through the hard work and dedication of the authors and contributors of several key projects.

#### iOS

**Special Thanks**

- Miguel de Icaza for building SwiftTerm and forking SwiftSH. [https://github.com/migueldeicaza/SwiftTerm](https://github.com/migueldeicaza/SwiftTerm) | [https://github.com/migueldeicaza/SwiftSH](https://github.com/migueldeicaza/SwiftSH)
- Andrew Madsen for building OpenSSL for ARM/Apple silicon Macs [https://blog.andrewmadsen.com/2020/06/22/building-openssl-for.html](https://blog.andrewmadsen.com/2020/06/22/building-openssl-for.html)
- Tommaso Madonia for SwiftSH and build script sample. [https://github.com/Frugghi/iSSH2](https://github.com/Frugghi/iSSH2) | [https://github.com/Frugghi/iSSH2](https://github.com/Frugghi/iSSH2)

These are the foundational libraries that enable SSH communication with a native terminal on Apple platforms. These projects allow rtn-dev-console to offer a seamless and robust terminal experience on iOS devices. Their open-source contributions to the community are invaluable, and I highly recommend checking out their work.
