# machine-default

The default Crucible machine image resource project.

## Background

There is no machine builder yet, so the `build/` directory is assembled manually
before packaging. This is a temporary process until the machine build pipeline
is implemented.

## Base image

This baseline uses the official Ubuntu 24.04 LTS (Noble Numbat) cloud images,
pinned to an immutable release build so the artifact is reproducible:

- https://cloud-images.ubuntu.com/releases/noble/release-20250610/

## Required staged files

Place the following files in `build/` before packing:

- `build/crucible.yaml`
- `build/aarch64.qcow2`
- `build/x86_64.qcow2`

The qcow2 filenames must match the local backend's expected architecture names.

## Checksums

The expected SHA256 values for the images live in `SHA256SUMS`. Staging
verifies them automatically, but they can also be checked manually:

```sh
./scripts/verify.sh
```

This fails if the staged images do not match the pinned release.

## Manual workflow

```sh
./scripts/stage.sh   # download, stage, and verify
crux pack            # pack
crux push            # publish
```
