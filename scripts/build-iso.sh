#!/bin/sh
set -eu

VERSION="0.1.0"
CODENAME="Mirage"

KERNEL="${KERNEL:-}"

BUILD_DIR="build"
ISO_ROOT="$BUILD_DIR/iso"

ISO_NAME="LunairOS-${CODENAME}-${VERSION}.iso"
OUT="$BUILD_DIR/$ISO_NAME"

echo "[*] Construindo LunairOS $VERSION \"$CODENAME\""

if [ -z "$KERNEL" ]; then
    echo "[!] Erro: defina KERNEL=/caminho/para/bzImage"
    exit 1
fi

if [ ! -f "$KERNEL" ]; then
    echo "[!] Kernel nao encontrado: $KERNEL"
    exit 1
fi

if [ ! -f "$BUILD_DIR/initramfs.cpio.gz" ]; then
    echo "[!] Rode ./scripts/build-initramfs.sh primeiro"
    exit 1
fi

if ! command -v grub-mkrescue >/dev/null 2>&1; then
    echo "[!] grub-mkrescue nao encontrado"
    exit 1
fi

echo "[*] Limpando ISO antiga..."
rm -rf "$ISO_ROOT"

echo "[*] Criando estrutura da ISO..."
mkdir -p "$ISO_ROOT/boot/grub"

echo "[*] Copiando kernel..."
cp "$KERNEL" "$ISO_ROOT/boot/bzImage"

echo "[*] Copiando initramfs..."
cp "$BUILD_DIR/initramfs.cpio.gz" \
   "$ISO_ROOT/boot/initramfs.cpio.gz"

echo "[*] Copiando configuracao do GRUB..."
cp iso/boot/grub/grub.cfg \
   "$ISO_ROOT/boot/grub/grub.cfg"

echo "[*] Gerando ISO..."
grub-mkrescue -o "$OUT" "$ISO_ROOT"

echo
echo "[✓] ISO criada:"
echo "    $OUT"
