# AGENTS.md

Context and operational guidelines for AI coding agents working on the Container Image Registry repository.

## Project Overview

This repository publishes optimized, multi-architecture (`linux/amd64`, `linux/arm64`) OCI container base images to DockerHub:

- **`lrwx/debian`**: Lightweight base OS image built on official Debian with configurable timezone, UTF-8 locale, non-interactive APT config, HTTPS mirrors, and essential utility tools. Supports `FLAVOUR` variants: `runtime` (standard tools), `baremin` (minimal), `develop` (full dev tools).
- **`lrwx/java`**: Custom Eclipse Temurin Java runtime images built directly on top of `lrwx/debian`. Supports `JAVA_FLAVOUR` variants: `jre` (minimal runtime stripped via `jlink`, base: `runtime`) and `jdk` (full unstripped JDK, base: `develop`).
- **`lrwx/uv-nvm`**.
- **`lrwx/tccli`**: Tencent Cloud CLI + uacme ACME client image built on top of `lrwx/python`. Combines TencentCloud CLI (for DNS record changes and hooks) and ndilieto/uacme for certificate automation. Base: `runtime`.
