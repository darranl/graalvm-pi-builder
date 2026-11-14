FROM --platform=linux/arm64 debian:bookworm

# No defaults: the versions live in graalvm.env and are passed in as build args by the Makefile
# and the publish workflow. Use `make build-dev` rather than a bare `podman build`.
ARG GRAALVM_VERSION
ARG GRAALVM_JDK_VERSION

RUN if [ -z "${GRAALVM_VERSION}" ] || [ -z "${GRAALVM_JDK_VERSION}" ]; then \
      echo "GRAALVM_VERSION and GRAALVM_JDK_VERSION build args are required; build with 'make build-dev' (see graalvm.env)" >&2; \
      exit 1; \
    fi

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget ca-certificates \
    gcc libc-dev zlib1g-dev \
    libi2c-dev \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q \
  "https://github.com/graalvm/graalvm-ce-builds/releases/download/graal-${GRAALVM_VERSION}/graalvm-community-jdk-${GRAALVM_JDK_VERSION}_linux-aarch64_bin.tar.gz" \
  -O /tmp/graalvm.tar.gz \
  && mkdir -p /opt/graalvm \
  && tar -xzf /tmp/graalvm.tar.gz -C /opt/graalvm --strip-components=1 \
  && rm /tmp/graalvm.tar.gz

ENV JAVA_HOME=/opt/graalvm
ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /build
