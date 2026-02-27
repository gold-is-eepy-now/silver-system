# Silver System OS – Modules

## Graphical Desktop
Sets VGA 320x200 mode, draws window and prints title.

## FAT12 File Reading
Stub: calls BIOS to read sector. For real FAT logic, see [OSDev FAT](https://wiki.osdev.org/FAT).

## Multitasking (Cooperative)
Simple stub; for preemptive multitasking expand with PIC/Timer interrupts.

## How to Build

Assemble each `.asm` with NASM, combine for bootable disk.

```
nasm -f bin bootloader/boot.asm -o bootloader/boot.bin
nasm -f bin kernel/kernel.asm -o kernel/kernel.bin
nasm -f bin desktop/desktop.asm -o desktop/desktop.bin
nasm -f bin drivers/disk.asm -o drivers/disk.bin
nasm -f bin kernel/multitask.asm -o kernel/multitask.bin
```