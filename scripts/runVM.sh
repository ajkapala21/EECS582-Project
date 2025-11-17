#!/usr/bin/env bash
# ============================================
# run_vm.sh — Boot VM with custom kernel
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

VM_IMG="$PROJECT_ROOT/vm/ubuntu2510.img"


if [ ! -f "$VM_IMG" ]; then
    echo "[!] Error: VM image not found at $VM_IMG"
    exit 1
fi


echo "[+] Booting Ubuntu 25.10 VM"
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -m 8192 \
    -smp 4 \
    -drive file="$VM_IMG",format=qcow2 \
    -boot c \
    -display gtk \
    -nic user,model=virtio-net-pci \
    -vga virtio \
    -device qemu-xhci \
    -device usb-tablet \
    -name "Ubuntu2510"
