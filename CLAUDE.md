# CLAUDE.md — graalvm-pi-builder

See [README.md](README.md) for image purpose, tags, pull/usage examples, and the publishing
workflow.

## Current versions

Defined once in `graalvm.env` (`GRAALVM_VERSION`, `GRAALVM_JDK_VERSION`); a bump edits that file
and nothing else. The `Containerfile` has no default versions, so build with `make`, which passes
them as build args.

| Tool | Version |
|---|---|
| GraalVM CE | 25.5.5.0.3 (JDK 25i5-25.0.5.0.3) |

## Build commands (quick reference)

```bash
make build-dev      # build :latest — dev iteration
make build          # build :bookworm-graal25
make build-release  # build all three tags (mutable, version-pinned, snapshot)
make setup-podman   # install QEMU aarch64 binfmt (Arch Linux only)
```

## Publish workflow

`.github/workflows/publish.yml` — `workflow_dispatch`, manual trigger via GitHub Actions UI.
Reads the GraalVM versions from `graalvm.env` (the single source of truth, also included by the
`Makefile`), so a version bump never edits this file. The
optional `graalvm_version` (release/tag version) and `graalvm_jdk_version` (JDK/filename version)
inputs override them for one run when non-empty — GraalVM's release tag and download filename
versions diverged starting with the 25i3 release line. Pushes three tags:
`bookworm-graalN`, `bookworm-X.Y.Z`, `bookworm-X.Y.Z-YYYYMMDD`.

The Claude GitHub App cannot modify files under `.github/workflows`; keep version values out of
workflow files so routine bumps stay within what the bot can edit.

## Future work

- GitHub Actions PR workflow: build test (no push) on pull requests
