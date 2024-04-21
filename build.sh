#!/bin/zsh

clean=false
while test x$1 != x; do
    case $1 in
	--clean)
	    clean=true
	    ;;
	--help)
	    echo "--clean             To clean codegen artifacts"
	    exit 0
    esac
    shift
done

# Identify the most recent tgz file and extract the version number
latest_tgz=$(ls rtn-dev-console-0.0.0-local.*.tgz 2> /dev/null | sort -V | tail -n1)

# Check if latest_tgz file exists and extract version, else default previous_version to 0
if [[ -n "$latest_tgz" ]]; then
    previous_version=$(echo $latest_tgz | grep -o -E 'local\.([0-9]+)' | cut -d. -f2)
else
    echo "No .tgz files found. Defaulting previous_version to 0."
    previous_version=0
fi

# Increment the version number
next_version=$((previous_version + 1))

# Check if clean variable is set to true and execute yarn clean
if [[ "$clean" == "true" ]]; then
    yarn clean
fi

# Generate codegen artifacts
yarn prepare

# Pack the current package using yarn
yarn pack

# Rename the packed tgz to the next version
mv package.tgz rtn-dev-console-0.0.0-local.$next_version.tgz

# Navigate to the example directory
cd example

# Remove the previous version pack and add the new one
yarn remove ../rtn-dev-console-0.0.0-local.$previous_version.tgz

if [[ "$clean" == "true" ]]; then
    rm yarn.lock
    rm ios/Podfile.lock
    yarn
fi

yarn add ../rtn-dev-console-0.0.0-local.$next_version.tgz

# Install pods
yarn pod-install

# If previous version exists, remove it
if [ $previous_version -ne 0 ]; then
    cd ..
    rm rtn-dev-console-0.0.0-local.$previous_version.tgz
fi