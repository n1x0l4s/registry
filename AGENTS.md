# AGENTS.md

Context and operational guidelines for AI coding agents working on the Container Image Registry repository.

## Project Overview

This repository publishes optimized, multi-architecture (`linux/amd64`, `linux/arm64`) OCI container base images to DockerHub:

- **`lrwx/debian`**: Lightweight base OS image built on official Debian with configurable timezone, UTF-8 locale, non-interactive APT config, HTTPS mirrors, and essential utility tools (`ca-certificates`, `nvi`, `file`, `iproute2`, `curl`).
- **`lrwx/java`**: Custom Eclipse Temurin Java runtime images built directly on top of `lrwx/debian`. Supports `jre` (minimal runtime stripped via `jlink`, running as non-root `java` user) and `jdk` (full unstripped JDK).

## Setup & Local Build Commands

### Build `lrwx/debian`

```bash
docker build -f docker.io/lrwx/debian/Dockerfile \
  --build-arg DEBIAN_RELEASE=latest \
  --build-arg TZ=Asia/Shanghai \
  --build-arg APT_MIRROR=deb.debian.org \
  -t lrwx/debian:latest .
```

### Build `lrwx/java` (JRE / JDK)

```bash
# Make helper scripts executable before building/testing
chmod +x ./docker.io/lrwx/java/*.sh

# JRE (minimal runtime assembled via jlink, non-root `java` user)
docker build -f docker.io/lrwx/java/Dockerfile \
  --build-arg BASE_TAG=latest \
  --build-arg JAVA_MAJOR=21 \
  --build-arg JAVA_TYPE=jre \
  --build-arg RUN_USER=java \
  -t lrwx/java:jre .

# JDK (full unstripped JDK, root user)
docker build -f docker.io/lrwx/java/Dockerfile \
  --build-arg BASE_TAG=latest \
  --build-arg JAVA_MAJOR=21 \
  --build-arg JAVA_TYPE=jdk \
  --build-arg RUN_USER=root \
  -t lrwx/java:jdk .
```

### Script Execution & Testing

- **Resolve latest LTS version**: `./docker.io/lrwx/java/resolve-version.sh lts`
- **Resolve Java modules**: `./docker.io/lrwx/java/resolve-modules.sh 21 jre ""`
- **Container Verification**:
  ```bash
  docker run --rm -it lrwx/debian:latest
  docker run --rm -it lrwx/java:jre java -version
  ```

## Repository Structure

```
.
├── .github/workflows/
│   ├── docker-io-lrwx-debian.yml  # Daily schedule & path-triggered workflow for debian image
│   └── docker-io-lrwx-java.yml    # Daily schedule & path-triggered workflow for java image
├── docker.io/lrwx/
│   ├── debian/
│   │   └── Dockerfile             # Multi-stage Debian base Dockerfile
│   └── java/
│       ├── Dockerfile             # Multi-stage Eclipse Temurin JRE/JDK Dockerfile
│       ├── resolve-modules.sh     # Adoptium module validation & resolution script
│       └── resolve-version.sh     # Adoptium API version resolution script
├── AGENTS.md                      # Operational context for coding agents (this file)
├── README.md                      # Human-facing documentation
└── LICENSE.md                     # AGPL-3.0 License
```

## Code Style & Conventions

### Dockerfile Practices

- **Stage Naming**: Use clear multi-stage aliases (`AS base`, `AS builder`, `AS final`).
- **Error Handling**: Use `set -eu` at the beginning of shell `RUN` blocks.
- **APT Cleanliness**: Set `DEBIAN_FRONTEND=noninteractive`, disable package recommends/suggests, and remove `/var/lib/apt/lists/*` at the end of APT steps.
- **Least Privilege**: JRE runtimes MUST run as non-root `java` user (`UID 1000`).

### Shell Script Practices

- Use POSIX shell hashbang: `#!/usr/bin/env sh`.
- Enforce strict error handling: `set -eu`.
- Ensure output variables append to `${GITHUB_OUTPUT}` when executing in GitHub Actions CI environments.

## Maintenance Protocol

Whenever files or requirements are updated, ensure the following files are updated in sync:

1. `AGENTS.md` (this file)
2. `README.md`
3. `.github/workflows/*`
