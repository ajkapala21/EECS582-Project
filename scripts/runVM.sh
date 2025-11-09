#!/usr/bin/env bash
# ============================================
# run_vm.sh — Boot VM with custom kernel
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

KERNEL_DIR="$PROJECT_ROOT/kernel-build/linux-6.17.7"
BZIMAGE="${KERNEL_DIR}/arch/x86/boot/bzImage"
VM_IMG="$PROJECT_ROOT/vm/debian13.img"

if [ ! -f "$BZIMAGE" ]; then
    echo "[!] Error: Kernel bzImage not found at $BZIMAGE"
    exit 1
fi

if [ ! -f "$VM_IMG" ]; then
    echo "[!] Error: VM image not found at $VM_IMG"
    exit 1
fi

# Determine root device dynamically
# Prefer VirtIO if available; fallback to /dev/sda1
ROOT_DEV="/dev/vda1"
if ! qemu-system-x86_64 -m 64 -hda "$VM_IMG" -nographic -boot c -kernel /dev/null 2>/dev/null; then
    echo "[i] Using fallback root device /dev/sda1"
    ROOT_DEV="/dev/sda1"
fi

echo "[+] Booting Debian 13 VM with custom kernel..."
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 \
    -kernel "$BZIMAGE" \
    -append "root=${ROOT_DEV} console=ttyS0 rw" \
    -hda "$VM_IMG" \
    -usb -device usb-tablet -serial mon:stdio
