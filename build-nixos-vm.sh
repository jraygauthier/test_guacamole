#!/usr/bin/env bash
set -euf -o pipefail

default_config="./vm.nix"
config="${1:-$default_config}"
echo "config=\"$config\""

default_repo_dir="$HOME/dev/nixpkgs_root"
repo_dir="${2:-$default_repo_dir}"
echo "repo_dir=\"$repo_dir\""

config_args="-I nixos-config=$config"
repo_args="-I nixpkgs=$repo_dir"

nixos-rebuild $repo_args $config_args build-vm
