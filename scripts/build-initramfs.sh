#!/bin/sh
set -eu

BUILD_DIR="build"
ROOT="$BUILD_DIR/initramfs"
BUSYBOX="${BUSYBOX:-result/bin/busybox}"

echo "[*] Limpando a initramfs antiga..."
rm -rf "$ROOT"
mkdir -p "$BUILD_DIR"

echo "[*] Criando estrutura da initramfs..."
mkdir -p \
    "$ROOT/bin" \
    "$ROOT/dev" \
    "$ROOT/etc" \
    "$ROOT/proc" \
    "$ROOT/sys"

echo "[*] Copiando init..."
cp initramfs/init "$ROOT/init"
chmod +x "$ROOT/init"

if [ -d initramfs/etc ]; then
    echo "[*] Copiando /etc..."
    cp -r initramfs/etc/* "$ROOT/etc/" 2>/dev/null || true
fi

echo "[*] Copiando BusyBox..."
cp "$BUSYBOX" "$ROOT/bin/busybox"
chmod +x "$ROOT/bin/busybox"

echo "[*] Criando symlinks do BusyBox..."
cd "$ROOT/bin"

for applet in $(./busybox --list); do
    ln -sf busybox "$applet"
done

cd ..

echo "[*] Gerando initramfs..."
find . | cpio -o -H newc | gzip > ../initramfs.cpio.gz

cd ../..

echo "[✓] Initramfs criada em $BUILD_DIR/initramfs.cpio.gz"
