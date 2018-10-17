#!/usr/bin/env bash
set -euf -o pipefail
script_dir="$(cd "$(dirname "$0")" && pwd)"
echo "script_dir=\"$script_dir\""

if ! build_vm_stdout=$(2>&1 "$script_dir/build-nixos-vm.sh" "${1:-}" "${2:-}"); then
  1>&2 echo "Failed to build the VM."
  1>&2 echo "$build_vm_stdout"
  exit 1
fi

echo "build_vm_stdout=\"$build_vm_stdout\""

vm_run_script=$(echo "$build_vm_stdout" | tail -n 1 | grep 'Done.' | sed -E -e 's/Done.[^\/]+(.+)/\1/g')
if test -z "$vm_run_script"; then
  1>&2 echo "Unexpected build vm output."
  exit 1
fi

export QEMU_OPTS="-m 1G -serial mon:stdio"
export QEMU_KERNEL_PARAMS=console=ttyS0
export QEMU_OPTS="-nographic ${QEMU_OPTS}"
export QEMU_OPTS="-vnc :1 ${QEMU_OPTS}"

export QEMU_NET_OPTS="hostfwd=tcp::8080-:8080,hostfwd=tcp::2222-:22,hostfwd=tcp::3389-:3389"
${vm_run_script}

# Stop the vm simply by typing: 'poweroff'.