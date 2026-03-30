#!/usr/bin/env bash
set -euo pipefail

kind create cluster --name local --config "$(dirname "$0")/kind.yaml"
