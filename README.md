# rtn-dev-console

Cross platform terminal Fabric component for react-native using SwiftSH/SwiftTerm (WIP) for iOS and Termux (TODO) for android.

## Installation

```sh
npm install rtn-dev-console
```

## Usage

```js
import { SshTerminal } from 'rtn-dev-console';

// ...

<SshTerminal
  ref={ref}
  host="192.168.0.1"
  port={22}
  username="username"
  password="password"
  onBell={handleBell}
  onClosed={handleClose}
  style={styles.box}
/>;
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
