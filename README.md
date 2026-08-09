# Container Image Registry

Optimized, lightweight multi-architecture base Docker images published.

---

## Images

### 1. `lrwx/debian`

Base OS image built on official Debian.

#### Features

- **Multi-Architecture**: Built for `linux/amd64` and `linux/arm64`.
- **Configurable Timezone & Locale**: Default locale `C.UTF-8` with configurable timezone (default: `Asia/Shanghai`).
- **Optimized APT Configuration**: Non-interactive defaults, HTTPS package sources, enabled components (`main`, `contrib`, `non-free`, `non-free-firmware`).
- **Essential Tools Included**: `ca-certificates`, `nvi`, `file`, `iproute2`, `curl`.

#### Quick Start

```bash
docker pull lrwx/debian:latest
docker run --rm -it lrwx/debian:latest
```

---

### 2. `lrwx/java`

Custom Temurin JRE / JDK images built on top of `lrwx/debian:${BASE_TAG}`.

#### Features

- **Strict Base OS Harmony**: Built directly on `lrwx/debian:${BASE_TAG}` and inherits its default `CMD` for interactive shell (`docker run -it`).
- **Standardized Path & Non-Root Execution**: `JAVA_HOME` set to `/opt/java/home`. Default JRE runs as non-root `java` user.
- **Flexible Bundle Target (`JAVA_TYPE`)**:
  - `jre`: Uses `jlink` to assemble a minimal runtime containing core modules (`java.base`, `java.sql`, etc.) under non-root `java` user.
  - `jdk`: Bypasses `jlink` stripping completely and copies the **full unstripped JDK** (with `javac`, `javap`, `jdb`, headers, and man pages).

#### Quick Start

```bash
docker pull lrwx/java:jre
docker run --rm -it lrwx/java:jre

docker pull lrwx/java:jdk
docker run --rm -it lrwx/java:jdk
```

---

## Build Arguments

### `lrwx/debian`

| Argument           | Default            | Description                 |
| :----------------- | :----------------- | :-------------------------- |
| `DEBIAN_RELEASE` | `latest`         | Upstream Debian release tag |
| `TZ`             | `Asia/Shanghai`  | System timezone setting     |
| `APT_MIRROR`     | `deb.debian.org` | Custom APT mirror hostname  |

### `lrwx/java`

| Argument         | Default                             | Description                                                       |
| :--------------- | :---------------------------------- | :---------------------------------------------------------------- |
| `BASE_TAG`     | `latest`                          | Target tag for`lrwx/debian:${BASE_TAG}` base image              |
| `JAVA_MAJOR`   | `21`                              | Temurin JDK major version for`builder` stage                    |
| `JAVA_TYPE`    | `jre`                             | Bundle type:`jre` (uses `jlink`) or `jdk` (unstripped copy) |
| `JAVA_MODULES` | Dynamic                             | Comma-separated Java modules for`jlink` (`jre` mode)          |
| `RUN_USER`     | `java`                            | Runtime user (`java` for JRE, `root` or custom)               |
| `JLINK_ARGS`   | `--strip-debug --no-man-pages...` | Additional arguments passed to`jlink`                           |

---

## Local Build

Build `lrwx/debian`:

```bash
docker build -f docker.io/lrwx/debian/Dockerfile -t lrwx/debian:latest .
```

Build `lrwx/java` (JRE):

```bash
docker build -f docker.io/lrwx/java/Dockerfile \
  --build-arg BASE_TAG=latest \
  --build-arg JAVA_MAJOR=21 \
  --build-arg JAVA_TYPE=jre \
  --build-arg RUN_USER=java \
  -t lrwx/java:jre .
```

Build `lrwx/java` (Full JDK):

```bash
docker build -f docker.io/lrwx/java/Dockerfile \
  --build-arg BASE_TAG=latest \
  --build-arg JAVA_MAJOR=21 \
  --build-arg JAVA_TYPE=jdk \
  --build-arg RUN_USER=root \
  -t lrwx/java:jdk .
```

---

## CI/CD Workflows

Automated via GitHub Actions in [`.github/workflows/`](.github/workflows/):

- [**`docker-io-lrwx-debian.yml`**](.github/workflows/docker-io-lrwx-debian.yml): Builds and pushes `lrwx/debian` base OS image.
- [**`docker-io-lrwx-java.yml`**](.github/workflows/docker-io-lrwx-java.yml): Builds and pushes `lrwx/java` images (`jre` / `jdk`) with Adoptium API integration.

---

## License

This project is licensed under the **GNU Affero General Public License v3.0** (AGPL-3.0). See the [LICENSE](LICENSE) file for details.

