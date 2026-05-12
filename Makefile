.RECIPEPREFIX := >

PROJECT ?= LunairOS
VERSION ?= 0.1.0
CODENAME ?= Mirage
KERNEL_VERSION ?= 6.9.12

BUILD ?= $(CURDIR)/build
JOBS ?= $(shell nproc 2>/dev/null || echo 1)

BUSYBOX ?= $(shell if [ -x "$(CURDIR)/result/bin/busybox" ]; then printf "%s" "$(CURDIR)/result/bin/busybox"; elif [ -x /bin/busybox ]; then printf "%s" "/bin/busybox"; else printf "%s" "busybox"; fi)
KERNEL_IMAGE ?= $(BUILD)/kernel/bzImage
INITRAMFS_IMAGE ?= $(BUILD)/initramfs.cpio.gz
ISO_IMAGE ?= $(BUILD)/$(PROJECT)-$(CODENAME)-$(VERSION).iso

QEMU ?= qemu-system-x86_64
QEMU_FLAGS ?= -machine pc -cpu qemu64 -m 512M -serial stdio -no-reboot

export

.PHONY: all world buildkernel buildworld release kernel initramfs iso run qemu check install-deps-debian clean cleankernel cleaninitramfs cleaniso distclean help

all: release

world: clean buildkernel buildworld release
buildkernel: kernel

buildworld: buildbusybox
>BUSYBOX="$(CURDIR)/build/busybox/busybox" $(MAKE) -C initramfs TOP="$(CURDIR)" all

release: iso

kernel:
>$(MAKE) -C kernel TOP="$(CURDIR)" all

initramfs:
>$(MAKE) -C initramfs TOP="$(CURDIR)" all

iso: kernel initramfs
>$(MAKE) -C iso TOP="$(CURDIR)" all

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
>sudo apt install -y build-essential wget xz-utils bc bison flex libssl-dev libelf-dev dwarves cpio gzip busybox-static xorriso mtools grub-common grub-pc-bin grub-efi-amd64-bin qemu-system-x86 file

clean: cleaninitramfs cleaniso

cleankernel:
>$(MAKE) -C kernel TOP="$(CURDIR)" clean

cleaninitramfs:
>$(MAKE) -C initramfs TOP="$(CURDIR)" clean

cleaniso:
>$(MAKE) -C iso TOP="$(CURDIR)" clean

distclean:
>rm -rf "$(BUILD)"

buildbusybox:
>$(MAKE) -C busybox TOP="$(CURDIR)" all
