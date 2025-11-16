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

echo "[+] Enabling BPF, BTF, and sched_ext..."
#cat ../../scripts/bpf.config >> .config
scripts/config --disable CONFIG_DEBUG_INFO_NONE
scripts/config --enable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT


scripts/config --enable CONFIG_BPF
scripts/config --enable CONFIG_BPF_SYSCALL
scripts/config --enable CONFIG_BPF_JIT
scripts/config --enable CONFIG_DEBUG_INFO_BTF
scripts/config --enable CONFIG_SCHED_CLASS_EXT
scripts/config --enable CONFIG_BPF_JIT_ALWAYS_ON
scripts/config --enable CONFIG_BPF_JIT_DEFAULT_ON
scripts/config --enable CONFIG_PAHOLE_HAS_SPLIT_BTF
scripts/config --enable CONFIG_PAHOLE_HAS_BTF_TAG




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
