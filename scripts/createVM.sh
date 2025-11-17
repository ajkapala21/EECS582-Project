#!/usr/bin/env bash
# ============================================
# create_vm.sh — Create Debian 13 QEMU VM
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

VM_DIR="$PROJECT_ROOT/vm"
IMG="${VM_DIR}/ubuntu2510.img"
ISO="${VM_DIR}/ubuntu-25.10-desktop-amd64.iso"
# this link doesn't work, you need to download the iso yourself and move it into the vm folder
ISO_URL="https://cdimage.ubuntu.com/releases/questing/release/ubuntu-25.10-desktop-amd64.iso"


mkdir -p "$VM_DIR"
cd "$VM_DIR"

if [ -f "$IMG" ]; then
    echo "[!] VM image already exists at $IMG"
    echo "    Remove it manually if you want to recreate it."
    exit 1
fi

# 1. Create disk image
echo "[+] Creating 60G QCOW2 disk image..."
qemu-img create -f qcow2 "$IMG" 60G

# 2. Download Debian ISO
if [ ! -f "$ISO" ]; then
    echo "[+] Downloading Ubuntu 25.10 ISO..."
    wget "$ISO_URL"
fi

# 3. Launch installer
echo "[+] Starting Ubuntu installer..."
qemu-system-x86_64 \
    -enable-kvm \
    -cpu host \
    -m 8192 \
    -smp 4 \
    -cdrom "$ISO" \
    -drive file="$IMG",format=qcow2 \
    -boot d \
    -display gtk \
    -nic user,model=virtio-net-pci \
    -vga virtio \
    -name "Ubuntu2510 Installer"

echo "[+] Installation complete. Boot later with run_vm.sh."