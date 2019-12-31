#!/bin/bash

# Script to generate a qemu binary for an arm64 target

#set -euo pipefail

# Set the target platform
#TARGET="arm"
TARGET="arm64"

# Get the destination
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DEST="$SCRIPT_DIR/qemu-bin/"

# Empty out the destination
[ -d "$DEST" ] && rm -r "$DEST" || true
mkdir "$DEST"

# Clone the resin patcher
echo -e "\nClone the resin patcher"
cd "$(mktemp -d)"
git clone --depth 1 https://github.com/balena-io-library/armv7hf-debian-qemu.git
cd armv7hf-debian-qemu

# Clean out the stuff we're about to build, then copy over the rest
echo -e "\nClean out the stuff we're about to build, then copy over the rest"
rm bin/qemu-arm-static
command -v md5 >/dev/null 2>&1
[ $? -eq 0 ] && md5 bin/resin-xbuild
command -v md5sum >/dev/null 2>&1
[ $? -eq 0 ] && md5sum bin/resin-xbuild
rm bin/resin-xbuild
cp -a bin/ "$DEST"

# Build the binary and copy it over
# TBH, I don't know why we need to rebuild this binary... After a lot of experimentation,
# I found out that the binary shipped with the git repo (as of Apr 11 2018, Latest commit d4a214f on Jul 2, 2017)
# doesn't work in an aarch64 host. ?????
echo -e "\nBuild the binary and copy it over"
GOOS=linux GOARCH=amd64 ./build.sh || {
	echo -e "\nFailed!"
	exit 1
}
cp resin-xbuild "$DEST"

# Get qemu
echo -e "\nGet qemu"
case "$TARGET" in
    "arm64")
        curl -L https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz | tar xzf -
        ;;
    "arm")
        curl -L https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz | tar xzf -
        ;;
    *)
        echo "Unknown target $TARGET"
        exit 1
        ;;
esac

# Copy qemu
echo -e "\nCopy qemu"
cp qemu*/* "$DEST"

echo -e "\n\n"
echo "================================"
echo "Successfully built for $TARGET!"
echo "================================"
