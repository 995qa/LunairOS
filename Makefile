.RECIPEPREFIX := >

TOP := $(CURDIR)

PROJECT ?= LunairOS
VERSION ?= 0.1.0
CODENAME ?= Mirage
KERNEL_VERSION ?= 6.9.12

BUILD ?= $(TOP)/build
JOBS ?= $(shell nproc 2>/dev/null || echo 1)

USERLAND_DEST ?= $(BUILD)/userland

BUSYBOX ?= $(shell if [ -x "$(BUILD)/busybox/busybox" ]; then printf "%s" "$(BUILD)/busybox/busybox"; elif [ -x "$(TOP)/result/bin/busybox" ]; then printf "%s" "$(TOP)/result/bin/busybox"; elif [ -x /bin/busybox ]; then printf "%s" "/bin/busybox"; else printf "%s" "busybox"; fi)

KERNEL_IMAGE ?= $(BUILD)/kernel/bzImage
INITRAMFS_IMAGE ?= $(BUILD)/initramfs.cpio.gz
ISO_IMAGE ?= $(BUILD)/$(PROJECT)-$(CODENAME)-$(VERSION).iso

QEMU ?= qemu-system-x86_64
QEMU_FLAGS ?= -machine pc -cpu qemu64 -m 512M -serial stdio -no-reboot

export

.PHONY: all world buildkernel buildbusybox builduserland buildworld release kernel initramfs iso run qemu check install-deps-debian clean cleanuserland cleankernel cleaninitramfs cleaniso distclean help

all: release

world: clean release

release: iso

buildkernel: kernel

buildbusybox:
>$(MAKE) -C busybox TOP="$(TOP)" all

builduserland:
>$(MAKE) -C userland TOP="$(TOP)" DESTDIR="$(USERLAND_DEST)" all install

buildworld: initramfs

kernel:
>$(MAKE) -C kernel TOP="$(TOP)" all

initramfs: builduserland
>$(MAKE) -C initramfs TOP="$(TOP)" USERLAND_DEST="$(USERLAND_DEST)" BUSYBOX="$(BUSYBOX)" all

iso: kernel initramfs
>$(MAKE) -C iso TOP="$(TOP)" all

run qemu: release
>$(QEMU) $(QEMU_FLAGS) -cdrom "$(ISO_IMAGE)"

check:
>@missing=""; \
>for cmd in make gcc wget tar xz bc bison flex cpio gzip grub-mkrescue xorriso file; do \
>    command -v $$cmd >/dev/null 2>&1 || missing="$$missing $$cmd"; \
>done; \
>if [ -n "$$missing" ]; then \
>    echo "[!] Faltando ferramentas:$$missing"; \
>    echo "    Rode: make install-deps-debian"; \
>    exit 1; \
>fi; \
>echo "[✓] Ferramentas principais encontradas"

install-deps-debian:
>sudo apt update
>sudo apt install -y build-essential wget xz-utils bc bison flex libssl-dev libelf-dev dwarves cpio gzip busybox-static xorriso mtools grub-common grub-pc-bin grub-efi-amd64-bin qemu-system-x86 file musl-tools

cleanuserland:
>$(MAKE) -C userland TOP="$(TOP)" DESTDIR="$(USERLAND_DEST)" clean || true
>rm -rf "$(USERLAND_DEST)"

clean: cleanuserland cleaninitramfs cleaniso

cleankernel:
>$(MAKE) -C kernel TOP="$(TOP)" clean

cleaninitramfs:
>$(MAKE) -C initramfs TOP="$(TOP)" clean

cleaniso:
>$(MAKE) -C iso TOP="$(TOP)" clean

distclean:
>rm -rf "$(BUILD)"

help:
>@echo "Comandos:"
>@echo "  make builduserland  - compila programas do userland"
>@echo "  make buildworld     - monta initramfs"
>@echo "  make release        - compila kernel/initramfs e monta ISO"
>@echo "  make run            - testa no QEMU"
>@echo "  make clean          - limpa userland/initramfs/iso"
>@echo "  make distclean      - apaga build/"
