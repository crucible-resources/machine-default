#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

RELEASE_URL="https://cloud-images.ubuntu.com/releases/noble/release-20250610"

mkdir -p build
cp crucible.yaml build/crucible.yaml
curl --proto '=https' --tlsv1.2 -fL "$RELEASE_URL/ubuntu-24.04-server-cloudimg-arm64.img" -o build/aarch64.qcow2
curl --proto '=https' --tlsv1.2 -fL "$RELEASE_URL/ubuntu-24.04-server-cloudimg-amd64.img" -o build/x86_64.qcow2

./scripts/verify.sh
