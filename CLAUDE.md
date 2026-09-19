# CLAUDE.md — graalvm-pi-builder

See [README.md](README.md) for image purpose, tags, pull/usage examples, and the publishing
workflow.

## Current versions

| Tool | Version |
|---|---|
| GraalVM CE | 25.3.4.1 (JDK 25i3-25.0.4.1) |

## Build commands (quick reference)

```bash
make build-dev      # build :latest — dev iteration
make build          # build :bookworm-graal25
make build-release  # build all three tags (mutable, version-pinned, snapshot)
make setup-podman   # install QEMU aarch64 binfmt (Arch Linux only)
```

## Publish workflow

`.github/workflows/publish.yml` — `workflow_dispatch`, manual trigger via GitHub Actions UI.
Accepts `graalvm_version` (release/tag version, default `25.3.4.1`) and `graalvm_jdk_version`
(JDK/filename version, default `25i3-25.0.4.1`) inputs — GraalVM's release tag and download
filename versions diverged starting with the 25i3 release line. Pushes three tags:
`bookworm-graalN`, `bookworm-X.Y.Z`, `bookworm-X.Y.Z-YYYYMMDD`.

## Future work

- GitHub Actions PR workflow: build test (no push) on pull requests
