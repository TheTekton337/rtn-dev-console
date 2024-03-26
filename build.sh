#!/bin/zsh

# Identify the most recent tgz file and extract the version number
latest_tgz=$(ls rtn-dev-console-0.0.0-local.*.tgz | sort -V | tail -n1)
current_version=$(echo $latest_tgz | grep -o -E 'local\.([0-9]+)' | cut -d. -f2)

# Increment the version number
next_version=$((current_version + 1))

# Execute the node command to generate codegen artifacts
node example/node_modules/react-native/scripts/generate-codegen-artifacts.js --path example --outputPath RtnDevConsole/generated/

# Pack the current package using yarn
yarn pack

# Rename the packed tgz to the next version
mv package.tgz rtn-dev-console-0.0.0-local.$next_version.tgz

# Navigate to the example directory
cd example

# Remove the previous version and add the new one
yarn remove ../rtn-dev-console-0.0.0-local.$current_version.tgz
yarn add ../rtn-dev-console-0.0.0-local.$next_version.tgz

# Run yarn pod-install and yarn ios
yarn pod-install
yarn ios

