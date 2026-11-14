# GRAALVM_VERSION and GRAALVM_JDK_VERSION come from graalvm.env (the single source of truth)
include graalvm.env

IMAGE     = ghcr.io/lofthouse-dev/graalvm-pi-builder
MAJOR     = $(firstword $(subst ., ,$(GRAALVM_VERSION)))
MUTABLE   = bookworm-graal$(MAJOR)
IMMUTABLE = bookworm-$(GRAALVM_VERSION)
SNAPSHOT  = bookworm-$(GRAALVM_VERSION)-$(shell date +%Y%m%d%H%M)
LOCAL     = latest
BUILD_ARGS = --build-arg GRAALVM_VERSION=$(GRAALVM_VERSION) \
             --build-arg GRAALVM_JDK_VERSION=$(GRAALVM_JDK_VERSION)

.DEFAULT_GOAL := help

.PHONY: help build-dev build build-release setup-podman

help:
	@echo "Targets:"
	@echo "  build-dev      Build tagged $(IMAGE):$(LOCAL) (dev iteration)"
	@echo "  build          Build tagged $(IMAGE):$(MUTABLE)"
	@echo "  build-release  Build and tag as $(IMAGE):$(MUTABLE), $(IMAGE):$(IMMUTABLE),"
	@echo "                 and $(IMAGE):$(SNAPSHOT)"
	@echo "  setup-podman   Install QEMU aarch64 binfmt support (Arch Linux)"

build-dev:
	podman build --platform linux/arm64 $(BUILD_ARGS) -t $(IMAGE):$(LOCAL) .

build:
	podman build --platform linux/arm64 $(BUILD_ARGS) -t $(IMAGE):$(MUTABLE) .

build-release:
	podman build --platform linux/arm64 $(BUILD_ARGS) \
	  -t $(IMAGE):$(MUTABLE) \
	  -t $(IMAGE):$(IMMUTABLE) \
	  -t $(IMAGE):$(SNAPSHOT) \
	  .

setup-podman:
	scripts/setup/setup-podman.sh
