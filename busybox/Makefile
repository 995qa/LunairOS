.RECIPEPREFIX := >

TOP ?= $(abspath ..)
BUSYBOX_VERSION ?= 1.36.1
BUSYBOX_CC ?= musl-gcc
JOBS ?= $(shell nproc)

DL_DIR := $(TOP)/build/distfiles
SRC_DIR := $(TOP)/build/busybox-$(BUSYBOX_VERSION)
OUT_DIR := $(TOP)/build/busybox
TARBALL := $(DL_DIR)/busybox-$(BUSYBOX_VERSION).tar.bz2
FRAGMENT := $(TOP)/configs/busybox-minimal.fragment
OUT := $(OUT_DIR)/busybox

.PHONY: all fetch extract config menuconfig build install clean distclean list check

all: $(OUT)

fetch:
>mkdir -p "$(DL_DIR)"
>test -f "$(TARBALL)" || wget -O "$(TARBALL)" "https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2"

extract: fetch
>test -d "$(SRC_DIR)" || tar -xf "$(TARBALL)" -C "$(TOP)/build"

config: extract
>cd "$(SRC_DIR)" && KCONFIG_ALLCONFIG="$(FRAGMENT)" make allnoconfig
>cd "$(SRC_DIR)" && yes "" | make oldconfig
>cp "$(SRC_DIR)/.config" "$(TOP)/configs/busybox.config"

menuconfig: config
>cd "$(SRC_DIR)" && make menuconfig
>cp "$(SRC_DIR)/.config" "$(TOP)/configs/busybox.config"

build: config
>cd "$(SRC_DIR)" && make -j$(JOBS) CC="$(BUSYBOX_CC)"

$(OUT): build
>mkdir -p "$(OUT_DIR)"
>cp "$(SRC_DIR)/busybox" "$(OUT)"
>chmod +x "$(OUT)"
>file "$(OUT)"
>"$(OUT)" --list

install: $(OUT)

list: $(OUT)
>"$(OUT)" --list

check: $(OUT)
>file "$(OUT)"
>"$(OUT)" --list | wc -l

clean:
>test ! -d "$(SRC_DIR)" || $(MAKE) -C "$(SRC_DIR)" clean
>rm -rf "$(OUT_DIR)"

distclean:
>rm -rf "$(SRC_DIR)" "$(OUT_DIR)"
