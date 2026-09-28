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
BCK_SRC="/etc/apt/sources.list.d/backports.list"
COMP="main contrib non-free non-free-firmware"
[ -s "${APT_SRC}" ] || APT_SRC="/etc/apt/sources.list"
[ -n "${APT_MIRROR:-}" ] && sed -i "s|deb.debian.org|${APT_MIRROR}|g" "${APT_SRC}"
apt-get update; apt-get install ca-certificates
sed -i "s|http://|https://|g;s| main| ${COMP}|g" "${APT_SRC}"
DEB_URL="https://${APT_MIRROR:-deb.debian.org}/debian"
echo "deb ${DEB_URL} ${VERSION_CODENAME}-backports ${COMP}" > "${BCK_SRC}"
apt-get update
[ -n "${EXTRA_PKG:-}" ] && apt-get install ${EXTRA_PKG}
apt-get full-upgrade; apt-get clean; rm -rf /var/lib/apt/lists/*
EOF
