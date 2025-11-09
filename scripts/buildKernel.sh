#!/usr/bin/env bash
# ============================================
# build_kernel.sh — Build Linux 6.17.7 for QEMU
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

KERNEL_VER=6.17.7
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${KERNEL_VER}.tar.xz"
BUILD_DIR="$PROJECT_ROOT/kernel-build"
SRC_DIR="${BUILD_DIR}/linux-${KERNEL_VER}"

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Download kernel if not already present
if [ ! -f "linux-${KERNEL_VER}.tar.xz" ]; then
    echo "[+] Downloading Linux kernel ${KERNEL_VER}..."
    wget "$KERNEL_URL"
fi

# Extract kernel only if source directory does not exist
if [ ! -d "$SRC_DIR" ]; then
    echo "[+] Extracting kernel..."
    tar -xf "linux-${KERNEL_VER}.tar.xz"
else
    echo "[i] Source directory already exists, skipping extraction."
fi

cd "$SRC_DIR"

# 1️⃣ Create baseline kernel config
echo "[+] Creating default kernel config..."
make defconfig

# 2️⃣ Patch .config to include drivers required for root filesystem
echo "[+] Patching .config for disk and filesystem support..."
sed -i 's/^# CONFIG_SCSI is not set/CONFIG_SCSI=y/' .config
sed -i 's/^# CONFIG_BLK_DEV_SD is not set/CONFIG_BLK_DEV_SD=y/' .config
sed -i 's/^# CONFIG_ATA is not set/CONFIG_ATA=y/' .config
sed -i 's/^# CONFIG_ATA_SATA is not set/CONFIG_ATA_SATA=y/' .config
sed -i 's/^# CONFIG_SATA_AHCI is not set/CONFIG_SATA_AHCI=y/' .config
sed -i 's/^# CONFIG_EXT4_FS is not set/CONFIG_EXT4_FS=y/' .config

# 3️⃣ Update config for any new dependencies automatically
echo "[+] Resolving config dependencies..."
make olddefconfig

# 4️⃣ Build kernel
echo "[+] Building kernel (using $(nproc) threads)..."
make -j"$(nproc)"

# 5️⃣ Install modules
#echo "[+] Installing kernel modules..."
#make modules_install

echo "[+] Kernel build complete!"
echo "    → bzImage: ${SRC_DIR}/arch/x86/boot/bzImage"
