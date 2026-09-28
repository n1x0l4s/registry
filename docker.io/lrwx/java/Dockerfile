ARG BASE_TAG="latest" JAVA_MAJOR="21"
# Stage 1: Builder stage using official Eclipse Temurin JDK image
FROM eclipse-temurin:${JAVA_MAJOR}-jdk AS builder

ARG JLINK_ARGS="--strip-debug --no-man-pages --no-header-files --compress 2"
ARG JAVA_FLAVOUR JAVA_MODULES
RUN <<-EOF
set -eu
if [ "${JAVA_FLAVOUR}" = "jdk" ]; then
    echo "JAVA_FLAVOUR=jdk: Copying unstripped full JDK..."
    cp -a "${JAVA_HOME}" /opt/java/home
else
    echo "JAVA_FLAVOUR=jre: Building custom minimal JRE via jlink..."
    ${JAVA_HOME}/bin/jlink --add-modules "${JAVA_MODULES}" ${JLINK_ARGS} --output /opt/java/home
fi
EOF

# Stage 2: Final runtime strictly built on lrwx/debian base image
FROM lrwx/debian:${BASE_TAG} AS final

COPY --from=builder /opt/java/home /opt/java/home

ENV JAVA_HOME="/opt/java/home"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

ARG RUN_USER
RUN <<-EOF
set -eu
if [ "${RUN_USER}" != "root" ]; then
    groupadd -g 1000 "${RUN_USER}"
    useradd -u 1000 -g "${RUN_USER}" -d "${JAVA_HOME}" "${RUN_USER}"
    chown -R "${RUN_USER}:${RUN_USER}" "${JAVA_HOME}"
fi
EOF

USER ${RUN_USER}
