#!/bin/bash

#
# by TS, Apr 2019
#

VAR_MYNAME="$(basename "$0")"

# ----------------------------------------------------------

# Outputs CPU architecture string
#
# @param string $1 debian_rootfs|debian_dist
#
# @return int EXITCODE
function _getCpuArch() {
	case "$(uname -m)" in
		x86_64*)
			echo -n "amd64"
			;;
		i686*)
			if [ "$1" = "s6_overlay" -o "$1" = "alpine_dist" ]; then
				echo -n "x86"
			else
				echo -n "i386"
			fi
			;;
		aarch64*)
			if [ "$1" = "debian_rootfs" ]; then
				echo -n "arm64v8"
			elif [ "$1" = "debian_dist" ]; then
				echo -n "arm64"
			else
				echo "$VAR_MYNAME: Error: invalid arg '$1'" >/dev/stderr
				return 1
			fi
			;;
		armv7*)
			if [ "$1" = "debian_rootfs" ]; then
				echo -n "arm32v7"
			elif [ "$1" = "debian_dist" ]; then
				echo -n "armhf"
			else
				echo "$VAR_MYNAME: Error: invalid arg '$1'" >/dev/stderr
				return 1
			fi
			;;
		*)
			echo "$VAR_MYNAME: Error: Unknown CPU architecture '$(uname -m)'" >/dev/stderr
			return 1
			;;
	esac
	return 0
}

_getCpuArch debian_dist >/dev/null || exit 1

# ----------------------------------------------------------

cd build-ctx || exit 1

# ----------------------------------------------------------

LVAR_DEBIAN_DIST="$(_getCpuArch debian_dist)"

LVAR_CPUARCH_PYTH=""
case "$LVAR_DEBIAN_DIST" in
	amd64)
		LVAR_CPUARCH_PYTH="amd64"
		;;
	i386)
		LVAR_CPUARCH_PYTH="i386"
		;;
	arm64)
		LVAR_CPUARCH_PYTH="arm64v8"
		;;
	armhf)
		LVAR_CPUARCH_PYTH="arm32v7"
		;;
	*)
		echo -e "$VAR_MYNAME: Error: Unsupported CPU architecture '$LVAR_DEBIAN_DIST'. Aborting.\n" >/dev/stderr
		printUsageAndExit
		;;
esac

LVAR_DOCKER_COMPOSE_VER="1.25.0"

LVAR_IMAGE_NAME="docker-compose-builder-native-${LVAR_DEBIAN_DIST}"
LVAR_IMAGE_VER="$LVAR_DOCKER_COMPOSE_VER"

echo -e "$VAR_MYNAME: Building Docker Image '${LVAR_IMAGE_NAME}:${LVAR_IMAGE_VER}'...\n"
docker build \
		--build-arg CF_DOCKER_COMPOSE_VER="$LVAR_DOCKER_COMPOSE_VER" \
		--build-arg CF_PYTHON_ARCH="$LVAR_CPUARCH_PYTH" \
		--build-arg CF_CPUARCH_DEB_DIST="$LVAR_DEBIAN_DIST" \
		-t "$LVAR_IMAGE_NAME":"$LVAR_IMAGE_VER" \
		. || exit 1

cd ..
docker run --rm -v "$(pwd)/dist":/dist "$LVAR_IMAGE_NAME":"$LVAR_IMAGE_VER" || exit 1

echo -e "\n$VAR_MYNAME: File has been created in ./dist/"
