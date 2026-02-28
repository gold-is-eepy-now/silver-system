OUT_DIR := out
BOOT_SRC := bootloader/boot.asm
KERNEL_SRC := kernel/kernel.asm
BOOT_BIN := $(OUT_DIR)/boot.bin
KERNEL_BIN := $(OUT_DIR)/kernel.bin
IMG := $(OUT_DIR)/silver.img

.PHONY: all build run clean

all: build

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(BOOT_BIN): $(BOOT_SRC) | $(OUT_DIR)
	nasm -f bin $(BOOT_SRC) -o $(BOOT_BIN)

$(KERNEL_BIN): $(KERNEL_SRC) | $(OUT_DIR)
	nasm -f bin $(KERNEL_SRC) -o $(KERNEL_BIN)

$(IMG): $(BOOT_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$(IMG) bs=512 count=2880 status=none
	dd if=$(BOOT_BIN) of=$(IMG) conv=notrunc status=none
	dd if=$(KERNEL_BIN) of=$(IMG) bs=512 seek=1 conv=notrunc status=none

build: $(IMG)

run: $(IMG)
	qemu-system-i386 -drive format=raw,file=$(IMG)

clean:
	rm -rf $(OUT_DIR)
