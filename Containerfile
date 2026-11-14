FROM --platform=linux/arm64 debian:bookworm

ARG GRAALVM_VERSION=25.5.5.0.3
ARG GRAALVM_JDK_VERSION=25i5-25.0.5.0.3

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
