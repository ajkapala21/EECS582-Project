#!/usr/bin/env bash
# ============================================
# create_vm.sh — Create Debian 13 QEMU VM
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

VM_DIR="$PROJECT_ROOT/vm"
IMG="${VM_DIR}/debian13.img"
ISO="${VM_DIR}/debian-13.1.0-amd64-netinst.iso"
ISO_URL="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.1.0-amd64-netinst.iso"


mkdir -p "$VM_DIR"
cd "$VM_DIR"

if [ -f "$IMG" ]; then
    echo "[!] VM image already exists at $IMG"
    echo "    Remove it manually if you want to recreate it."
    exit 1
fi

# 1. Create disk image
echo "[+] Creating 10G QCOW2 disk image..."
qemu-img create -f qcow2 "$IMG" 20G

# 2. Download Debian ISO
if [ ! -f "$ISO" ]; then
    echo "[+] Downloading Debian 13 ISO..."
    wget "$ISO_URL"
fi

# 3. Launch installer
echo "[+] Starting Debian installer..."
qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 \
    -cdrom "$ISO" \
    -hda "$IMG" \
    -boot d \
    -display gtk \
    -name "Debian13 Installer"

echo "[+] Installation complete. Boot later with run_vm.sh."