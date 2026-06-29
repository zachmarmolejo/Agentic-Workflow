#!/usr/bin/env bash
#
# Install standalone CLI binaries (Kun Chen's agentic toolchain) via their
# official installers. Binaries land in ~/.local/bin (already on PATH).
# Safe to re-run.
#
set -euo pipefail

echo "==> no-mistakes (AI validation gate: push -> review/test/lint/docs -> clean PR)"
curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh | sh

# (treehouse and other curl-installed binaries get added here as we go)
