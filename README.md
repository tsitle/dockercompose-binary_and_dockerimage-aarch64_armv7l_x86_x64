# docker-compose binary packages for AARCH64, ARMv7l, X86 and X64 and Docker Image for creating the packages

This repository provides [docker-compose](https://docs.docker.com/compose/) binary packages for

- AARCH64 (aarch64/arm64v8/arm64)
- ARMv7l (armv7l/arm32v7/armhf)
- X86 (x86/i386/i686/ia32)
- X64 (x64/amd64/x86_64)

as well as the Docker Image used for building the binary packages.  

## Using the pre-built binary
Extract the binary package on the target host:

```
$ sudo tar xf binary/docker-compose-linux-<ARCH>-<VERSION>.tgz -C /usr/local/bin/
$ sudo ln -s /usr/local/bin/docker-compose-linux-<ARCH>-<VERSION> /usr/local/bin/docker-compose
```

Verify that the binary is OK:

```
$ docker-compose version
```

## Building the binary
### Cross-compiling on a X64/AMD64 host
On the X64/AMD64 host, run:

```
$ cd cross-build
For AARCH64:
	$ ./build_binary.sh arm64
For ARMv7l:
	$ ./build_binary.sh armhf
```

(Cross-compiling is currently only available for the AARCH64 and ARMv7l targets)

This will generate the binary package `./dist/docker-compose-linux-<ARCH>-<VERSION>.tgz`.

Follow above instructions for using the pre-built binary.  
You'll just need to replace the path `binary/` with `dist/`.

### Compiling on the target host
On the host machine, run:

```
$ cd native-build
$ ./build_binary.sh
```

This will generate the binary package `./dist/docker-compose-linux-<ARCH>-<VERSION>.tgz`.

Follow above instructions for using the pre-built binary.  
You'll just need to replace the path `binary/` with `dist/`.

---

The Docker Image is based on: [https://github.com/ubiquiti/docker-compose-aarch64](https://github.com/ubiquiti/docker-compose-aarch64)
