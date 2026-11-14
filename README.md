# graalvm-pi-builder

A general-purpose aarch64 GraalVM build environment matched to Raspberry Pi OS 12 (Debian bookworm).

## What this image is

`ghcr.io/lofthouse-dev/graalvm-pi-builder` is a container image built for `linux/arm64` on top of
`debian:bookworm` — the same glibc base as Raspberry Pi OS 12. It bundles:

- **GraalVM Community Edition** (Java 25) with `native-image`
- **gcc, libc-dev, zlib1g-dev** — native toolchain required by `native-image` to link binaries
- **libi2c-dev** — I2C headers for compiling FFM bindings against Pi hardware (required by Pi4J SMBusContext)

The image is intended as a build tool, not a runtime base. System library versions follow Debian
bookworm and will change between builds as security patches land.

## Use cases

- Capturing FFM reachability metadata with the `native-image-agent`
- Generating CAP caches (`-H:+NewCAPCache`) for GraalVM native-image builds
- Building GraalVM native binaries targeting aarch64 / Pi OS 12

## Image tags

| Tag | Type | Meaning |
|---|---|---|
| `bookworm-graal25` | Mutable | Latest build of GraalVM 25.x on Debian bookworm; updated on each publish |
| `bookworm-25.5.5.0.3` | Rolling | GraalVM version pinned; apt packages reflect the latest bookworm at publish time |
| `bookworm-25.5.5.0.3-YYYYMMDD` | Snapshot | Exact build date — use this tag when you need a fully reproducible reference |

Use the mutable tag to track updates. Pin to a snapshot tag when you need reproducibility.

## Pulling the image

This is an `linux/arm64`-only image. On x86_64 hosts you must specify the platform explicitly:

```bash
# Latest GraalVM 25 on bookworm
podman pull --platform linux/arm64 ghcr.io/lofthouse-dev/graalvm-pi-builder:bookworm-graal25
docker pull --platform linux/arm64 ghcr.io/lofthouse-dev/graalvm-pi-builder:bookworm-graal25

# Pinned to a specific GraalVM version
podman pull --platform linux/arm64 ghcr.io/lofthouse-dev/graalvm-pi-builder:bookworm-25.5.5.0.3

# Reproducible snapshot
podman pull --platform linux/arm64 ghcr.io/lofthouse-dev/graalvm-pi-builder:bookworm-25.5.5.0.3-20260120
```

On native arm64 hosts (e.g. Raspberry Pi, Apple Silicon) the `--platform` flag is not needed.

## Using the image

As a base image in a Containerfile or Dockerfile:

```dockerfile
FROM ghcr.io/lofthouse-dev/graalvm-pi-builder:bookworm-graal25
```

Running a native-image build directly (add `--platform linux/arm64` on x86_64 hosts):

```bash
podman run --rm --platform linux/arm64 -v $(pwd):/build:z \
  ghcr.io/lofthouse-dev/graalvm-pi-builder:bookworm-graal25 \
  native-image -jar myapp.jar
```

## Building locally

### Prerequisites

- [Podman](https://podman.io/)
- On x86_64 hosts: QEMU aarch64 binfmt support (`make setup-podman` — Arch Linux only; see
  your distro docs for other systems)

### Makefile targets

```bash
# One-time QEMU setup (Arch Linux x86_64 hosts only)
make setup-podman

# Dev iteration — builds tagged :latest
make build-dev

# Named mutable release tag (:bookworm-graal25)
make build

# All three tags: mutable, version-pinned, and timestamped snapshot
make build-release
```

`build-dev` is the iteration target during development. `build-release` mirrors what the publish
workflow pushes to GHCR.

The GraalVM version is defined once, in [`graalvm.env`](graalvm.env). The Makefile reads it and
passes it to the build as `--build-arg GRAALVM_VERSION=...` and `--build-arg
GRAALVM_JDK_VERSION=...`, and derives the image tags from it. The `Containerfile` has no default
versions, so **build with `make`, not a bare `podman build`** — without the build args the
`Containerfile` stops immediately with an error saying they are required. To build by hand,
source the file and pass the args yourself:

```bash
. ./graalvm.env
podman build --platform linux/arm64 \
  --build-arg GRAALVM_VERSION="$GRAALVM_VERSION" \
  --build-arg GRAALVM_JDK_VERSION="$GRAALVM_JDK_VERSION" \
  -t graalvm-pi-builder:test .
```

### Verifying the GraalVM version in an image

Check which GraalVM an image contains by running the tools in it (add `--platform linux/arm64`
on x86_64 hosts; use any tag, e.g. `:latest` for a `make build-dev` image or
`:bookworm-graal25` for a pulled one):

```bash
IMG=ghcr.io/lofthouse-dev/graalvm-pi-builder:latest
podman run --rm --platform linux/arm64 $IMG native-image --version
podman run --rm --platform linux/arm64 $IMG java -version
```

Both should report the version in [`graalvm.env`](graalvm.env). For example, with
`GRAALVM_VERSION=25.5.5.0.3` the output includes `GraalVM CE 25.5.5.0.3` and the JDK version
`25.0.5.0.3`.

## Publishing via GitHub Actions

Images are published to GHCR manually via a `workflow_dispatch` workflow. To trigger a publish:

1. Go to the [Actions tab](../../actions/workflows/publish.yml) in the repository
2. Select **Publish container image**
3. Click **Run workflow**
4. Leave the `graalvm_version` and `graalvm_jdk_version` inputs empty to build the versions pinned
   in `graalvm.env`, or fill them in to override them for this run
5. Click **Run workflow**

The workflow reads the GraalVM versions from `graalvm.env` (the single source of truth, shared
with the Makefile) unless an input overrides them, and fails if it cannot determine both. It
builds the `linux/arm64` image using QEMU on a standard GitHub-hosted runner and pushes all three
tags (`bookworm-graalN`, `bookworm-X.Y.Z`, `bookworm-X.Y.Z-YYYYMMDD`) in a
single build.

## Updating GraalVM

When a new GraalVM CE release is available:

1. Change `GRAALVM_VERSION` and `GRAALVM_JDK_VERSION` in [`graalvm.env`](graalvm.env) —
   note that since the 25i3 release line, GraalVM's release/tag version (e.g. `25.5.5.0.3`) and the
   JDK version baked into the download filename (e.g. `25i5-25.0.5.0.3`) can differ; check the
   [release page](https://github.com/graalvm/graalvm-ce-builds/releases) for both values
2. Push to the repository
3. Trigger the publish workflow via the Actions tab (it reads `graalvm.env`, so neither the
   `Containerfile`, the `Makefile` nor `.github/workflows/publish.yml` needs editing)

## License

Apache License 2.0 — see [LICENSE](LICENSE).
