ARG RELEASE=latest
FROM debian:${RELEASE} AS base

ARG TZ
ENV LANG="C.UTF-8" LC_ALL="C.UTF-8" TZ="${TZ}"
RUN <<-EOF
set -eu
if [ -r "/usr/share/zoneinfo/${TZ}" ]; then
    echo "${TZ}" > /etc/timezone
    ln -sf "/usr/share/zoneinfo/${TZ}" /etc/localtime
fi
EOF

COPY <<-EOF /etc/apt/apt.conf.d/00-oci
Acquire::Check-Valid-Until "false";
Acquire::Languages "none";
Acquire::PDiffs "false";
APT::Get::Assume-Yes "true";
APT::Get::AutomaticRemove "true";
APT::Install-Recommends "false";
APT::Install-Suggests "false";
quiet "1";
EOF

ARG DEBIAN_FRONTEND=noninteractive APT_MIRROR EXTRA_PKG
RUN <<-EOF
set -eu
. /etc/os-release
APT_SRC="/etc/apt/sources.list.d/debian.sources"
if [ -f "${APT_SRC}" ]; then
    [ -n "${APT_MIRROR:-}" ] && sed -i "s|deb.debian.org|${APT_MIRROR}|g" "${APT_SRC}"
    apt-get update; apt-get install ca-certificates
    sed -i 's|http://|https://|g' "${APT_SRC}"
    sed -i '/^Components:/ s/$/ contrib non-free non-free-firmware/' "${APT_SRC}"
    sed -i "/^Suites:/ s/$/ ${VERSION_CODENAME}-backports/" "${APT_SRC}"
else
    APT_SRC="/etc/apt/sources.list"
    [ -n "${APT_MIRROR:-}" ] && sed -i "s|deb.debian.org|${APT_MIRROR}|g" "${APT_SRC}"
    apt-get update
    apt-get install -y --no-install-recommends ca-certificates
    sed -i 's|http://|https://|g' "${APT_SRC}"
    sed -i 's/main$/main contrib non-free non-free-firmware/' "${APT_SRC}"
    echo "deb https://${APT_MIRROR}/debian ${VERSION_CODENAME}-backports main contrib non-free non-free-firmware" >> "${APT_SRC}"
fi
apt-get update
if [ -n "${EXTRA_PKG:-}" ]; then
    apt-get install "${EXTRA_PKG}"
fi
apt-get full-upgrade
apt-get clean
rm -rfv /var/lib/apt/lists/*
EOF
