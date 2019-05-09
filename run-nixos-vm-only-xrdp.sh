#!/usr/bin/env bash
set -euf -o pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
echo "script_dir=\"$script_dir\""

$script_dir/run-nixos-vm.sh "vm_only_xrdp.nix"
