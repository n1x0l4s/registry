ARG BASE_TAG="runtime"
FROM lrwx/debian:${BASE_TAG}

ENV NVM_DIR=/opt/nvm
ENV UV_INSTALL_DIR=/opt/uv
ENV UV_NO_MODIFY_PATH=1 UV_PYTHON_INSTALL_BIN=1 \
    UV_TOOL_DIR="${UV_INSTALL_DIR}/tools" \
    UV_TOOL_BIN_DIR="${UV_INSTALL_DIR}/bin" \
    UV_PYTHON_INSTALL_DIR="${UV_INSTALL_DIR}/python" \
    UV_PYTHON_BIN_DIR="${UV_INSTALL_DIR}/bin"
ENV PATH="${UV_TOOL_BIN_DIR}:${UV_INSTALL_DIR}:${PATH}"

COPY <<-EOF /etc/profile.d/nvm.sh
{
if [ -s "${NVM_DIR}/nvm.sh" ]; then . "${NVM_DIR}/nvm.sh"; fi
if [ -s "${NVM_DIR}/bash_completion" ]; then . "${NVM_DIR}/bash_completion"; fi
} >/dev/null 2>&1
EOF

RUN <<-EOF
set -eu
git clone https://github.com/nvm-sh/nvm.git "${_NVM_DIR}"
_CHK=$(git tag -l 'v*' --sort=-v:refname | head -n 1)
git checkout "${_CHK}"
. /etc/profile
nvm install --latest-npm --no-progress --default node
npm install --global --allow-scripts=pnpm,yarn pnpm yarn
EOF

RUN <<-EOF
set -eu
curl -LsSf "https://astral.sh/uv/install.sh" | bash
uv python install --upgrade --no-progress --default cpython
EOF
