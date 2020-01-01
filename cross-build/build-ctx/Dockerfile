ARG CF_PYTHON_TRG_ARCH

FROM ${CF_PYTHON_TRG_ARCH}/python:3.6.5-stretch

# Add env
ENV LANG C.UTF-8

# Enable cross-build
ARG CF_QEMU_TRG_ARCH
ADD files/qemu-bin.tgz /usr/bin/
ADD cache/qemu_binary_static/qemu-${CF_QEMU_TRG_ARCH}-static.tgz /usr/bin/


# -------------------------
RUN [ "cross-build-start" ]

# Set the versions
ARG CF_DOCKER_COMPOSE_VER
ENV CF_DOCKER_COMPOSE_VER ${CF_DOCKER_COMPOSE_VER}

# docker-compose requires pyinstaller 3.5 (check github.com/docker/compose/requirements-build.txt)
# If this changes, you may need to modify the version of "six" below
ENV PYINSTALLER_VER 3.5
# "six" is needed for PyInstaller. v1.13.0 is the latest as of PyInstaller 3.5
ENV SIX_VER 1.13.0

# Install dependencies
# RUN apt-get update && apt-get install -y
RUN pip install --upgrade pip
RUN pip install six==$SIX_VER

# Compile the pyinstaller "bootloader"
# https://pyinstaller.readthedocs.io/en/stable/bootloader-building.html
WORKDIR /build/pyinstallerbootloader

RUN \
	curl -fsSL \
			https://github.com/pyinstaller/pyinstaller/releases/download/v$PYINSTALLER_VER/PyInstaller-$PYINSTALLER_VER.tar.gz | \
		tar xz >/dev/null \
	&& cd PyInstaller*/bootloader \
	&& python3 ./waf all

# Clone docker-compose
WORKDIR /build/dockercompose

RUN \
	git clone https://github.com/docker/compose.git . \
	&& git checkout ${CF_DOCKER_COMPOSE_VER}

# Run the build steps (taken from github.com/docker/compose/script/build/linux-entrypoint)
RUN \
	mkdir ./dist \
	&& pip install -r requirements.txt -r requirements-build.txt \
	&& ./script/build/write-git-sha > compose/GITSHA \
	&& pyinstaller --exclude-module pycrypto --exclude-module PyInstaller docker-compose.spec

ARG CF_CPUARCH_DEB_TRG_DIST

RUN \
	mv dist/docker-compose docker-compose-linux-${CF_CPUARCH_DEB_TRG_DIST}-${CF_DOCKER_COMPOSE_VER} \
	&& chmod a+x docker-compose-linux-${CF_CPUARCH_DEB_TRG_DIST}-${CF_DOCKER_COMPOSE_VER} \
	&& tar czf \
			docker-compose-linux-${CF_CPUARCH_DEB_TRG_DIST}-${CF_DOCKER_COMPOSE_VER}.tgz \
			docker-compose-linux-${CF_CPUARCH_DEB_TRG_DIST}-${CF_DOCKER_COMPOSE_VER} \
	&& md5sum *.tgz > docker-compose-linux-${CF_CPUARCH_DEB_TRG_DIST}-${CF_DOCKER_COMPOSE_VER}.tgz.md5 \
	&& rm docker-compose-linux-${CF_CPUARCH_DEB_TRG_DIST}-${CF_DOCKER_COMPOSE_VER}

# Disable cross-build for aarch64
# Note: don't disable this, since we want to run this container on x86_64, not aarch64
# RUN [ "cross-build-end" ]

# Copy out the generated binary
VOLUME /dist
CMD cp docker-compose-*.tgz* /dist
