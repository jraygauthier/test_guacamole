#!/usr/bin/env bash
set -euf -o pipefail
nix-shell -p freerdp --run "xfreerdp /u:myuser /p:pw /v:localhost:33389"
