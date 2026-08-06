ARG DEBIAN_RELEASE=latest
FROM debian:${DEBIAN_RELEASE} AS base

ENV LANG="C.UTF-8" LC_ALL="C.UTF-8" TZ="Asia/Shanghai"
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

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_MIRROR
RUN <<-EOF
set -eu
if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
    APT_SRC="/etc/apt/sources.list.d/debian.sources"
else
    APT_SRC="/etc/apt/sources.list"
fi
if [ -n "${APT_MIRROR:-}" ]; then
    sed -i "s/deb.debian.org/${APT_MIRROR:-}/g" "${APT_SRC}"
fi
apt-get update
apt-get install ca-certificates
sed -i "s/http:/https:/g" "${APT_SRC}"
sed -i "s/main\$/main contrib non-free non-free-firmware/g" "${APT_SRC}"
apt-get update
apt-get install nvi file iproute2 curl
apt-get full-upgrade
apt-get clean
rm -rfv /var/lib/apt/lists/*
EOF
