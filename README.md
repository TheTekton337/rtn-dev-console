# rtn-dev-console

Cross-platform terminal Fabric component for React Native, leveraging SwiftSH/SwiftTerm for iOS, with plans for Termux integration on Android. This initial release introduces a powerful tool for integrating SSH terminal functionality into React Native applications.

**Note**: This component currently supports the new React Native architecture. Support for the legacy architecture may be added based on community requests.

## Features

- **iOS Support**: Employs SwiftSH/SwiftTerm for comprehensive SSH connectivity and terminal emulation.
- **Android Support**: Android support with feature parity planned for upcoming release.
- **Flexible Configuration**: Customize terminal appearance, behavior, and functionality with props.
- **Event Handling**: Receive terminal events to handle terminal events, state changes, command output, and more.
- **Command Execution**: Execute commands programmatically within the terminal, or via the command line.

## Installation

To add rtn-dev-console to your React Native project, use the following npm command:

```sh
npm install rtn-dev-console
```

yarn:

```sh
yarn add rtn-dev-console
```

Note: To use the example app, use `./build.sh` in the `rtn-dev-console` project root first to pack and install the local `rtn-dev-console` package.

## Usage

Add the `SshTerminal` component to your react native application, configuring it with appropriate props for establishing an SSH connection and handling events:

```js
import React from 'react';
import { SshTerminal } from 'rtn-dev-console';

const initialText = 'Welcome to RNApp Terminal';

function App() {
  return (
    <SshTerminal
      hostConfig={{
        host: '192.168.1.1',
        port: 22,
        terminal: 'xterm',
      }}
      authConfig={{
        authType: 'password',
        username: 'your_username',
        password: 'your_password',
      }}
      initialText={initialText}
      oscHandlerCodes={[1234]}
      onOSC={
        ({ nativeEvent: { code, data } }: OSCEvent) =>
          console.log(`onOSC: ${code} | ${data}`)
      }
      onBell={() => console.log('onBell')}
      onClosed={
        ({ nativeEvent: { reason } }: ClosedEvent) =>
          console.log(`onClosed: ${reason}`)
      }
      onConnect={() => console.log('onConnect')}
      onTerminalLog={
        ({ nativeEvent: { logType, message } }: TerminalLogEvent) =>
          console.log(`onTerminalLog: ${logType}: ${message}`)
      }
      style={{ flex: 1 }}
    />
  );
}
```

This snippet demonstrates the basic setup required to initiate an SSH session with event handling. The `initialText` prop is used to set the initial text to display in the terminal upon connection.

## Props and Events

The `SshTerminal` component offers a variety of props and event handlers for customizing the SSH session and terminal interface. These include connection details (`hostConfig`, `authConfig`), debug options, and callbacks for significant terminal events (`onConnect`, `onClose`, `onSizeChanged`, etc.).

## Caveats

- Basic functionality has been verified through the example app. However, as this is an early-stage project, terminal methods may exhibit instability.
- Created for the new React Native architecture; legacy architecture support will be implemented upon request or as community contributions are made.

## Special Thanks

Acknowledgments to those whose contributions have made this project possible:

- **Miguel de Icaza** for SwiftTerm and the SwiftSH fork. These foundational libraries are crucial for SSH communication and terminal emulation on iOS.
- **Tommaso Madonia** for SwiftSH and invaluable build script examples, enhancing the project's build process and capabilities.
- **Andrew Madsen** for his work on building OpenSSL for ARM/Apple silicon Macs, facilitating secure connections.

Their efforts have significantly contributed to the development and functionality of rtn-dev-console, and we are grateful for their open-source contributions.

## Contributing

We welcome contributions in all forms: bug reports, feature suggestions, and pull requests. Your involvement is key to the continued improvement and success of rtn-dev-console and the react native open source community.
