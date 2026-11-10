#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "usage: $0 <path to a cruxd checkout>" >&2
  exit 2
fi
CRUXD_DIR="$(cd "$1" && pwd)"

cd "$(dirname "$0")/.."
BUILD_DIR="$(pwd)/build"

RELEASE_URL="https://cloud-images.ubuntu.com/releases/noble/release-20261017"

mkdir -p "$BUILD_DIR"
cp crucible.yaml "$BUILD_DIR/crucible.yaml"
curl --proto '=https' --tlsv1.2 -fL "$RELEASE_URL/ubuntu-24.04-server-cloudimg-arm64.img" -o "$BUILD_DIR/aarch64.qcow2"
curl --proto '=https' --tlsv1.2 -fL "$RELEASE_URL/ubuntu-24.04-server-cloudimg-amd64.img" -o "$BUILD_DIR/x86_64.qcow2"

./scripts/verify.sh

# cruxd ships with the machine; file names use the same architecture names as
# the disk images so the local backend can pick the one matching the VM.
TAG="$(git -C "$CRUXD_DIR" describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || true)"
COMMIT="$(git -C "$CRUXD_DIR" rev-parse --short HEAD)"
PKG="github.com/cruciblehq/cruxd/cmd/cruxd/internal"
LDFLAGS="-X $PKG.version=$TAG -X $PKG.gitCommit=$COMMIT -X $PKG.stage=machine"

for pair in aarch64:arm64 x86_64:amd64; do
  arch="${pair%%:*}"
  goarch="${pair##*:}"
  (cd "$CRUXD_DIR" && CGO_ENABLED=0 GOOS=linux GOARCH="$goarch" go build -ldflags "$LDFLAGS" -o "$BUILD_DIR/cruxd-$arch" ./cmd/cruxd)
done
