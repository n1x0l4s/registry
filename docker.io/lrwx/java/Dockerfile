ARG BASE_TAG="latest"
ARG JAVA_MAJOR="21"

# Stage 1: Builder stage using official Eclipse Temurin JDK image
FROM eclipse-temurin:${JAVA_MAJOR}-jdk AS builder

ARG JAVA_TYPE="jre"
ARG JAVA_MODULES="java.base,java.logging,java.sql,java.naming,java.management,java.security.jgss,java.instrument,java.rmi,java.xml,java.net.http,jdk.unsupported,jdk.crypto.ec,jdk.crypto.cryptoki"
ARG JLINK_ARGS="--strip-debug --no-man-pages --no-header-files --compress 2"


RUN set -eu; \
    if [ "${JAVA_TYPE}" = "jdk" ]; then \
    echo "JAVA_TYPE=jdk: Copying unstripped full JDK..."; \
    cp -a "$JAVA_HOME" /opt/java/home; \
    else \
    echo "JAVA_TYPE=jre: Building custom minimal JRE via jlink..."; \
    $JAVA_HOME/bin/jlink \
    --add-modules "${JAVA_MODULES}" \
    ${JLINK_ARGS} \
    --output /opt/java/home; \
    fi

# Stage 2: Final runtime strictly built on lrwx/debian base image
FROM lrwx/debian:${BASE_TAG} AS final

ARG JAVA_TYPE="jre"
ARG RUN_USER="java"

COPY --from=builder /opt/java/home /opt/java/home

ENV JAVA_HOME="/opt/java/home"
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN set -eu; \
    if [ "${RUN_USER}" != "root" ]; then \
    groupadd -g 1000 "${RUN_USER}" || true; \
    useradd -u 1000 -g "${RUN_USER}" -d "${JAVA_HOME}" -s /bin/bash "${RUN_USER}" || true; \
    chown -R "${RUN_USER}:${RUN_USER}" "${JAVA_HOME}"; \
    fi

USER ${RUN_USER}
