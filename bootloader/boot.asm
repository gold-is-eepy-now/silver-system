; 512-byte MBR bootloader, loads kernel sector
org 0x7C00

start:
    mov ah, 0x02             ; BIOS read sector
    mov al, 1                ; Read 1 sector (bootloader loads kernel sector 2)
    mov ch, 0                ; Cylinder 0
    mov cl, 2                ; Sector 2
    mov dh, 0                ; Head 0
    mov dl, 0x80             ; HDD (or 0x00 for floppy)
    mov bx, 0x8000           ; Destination: 0x8000
    int 0x13                 ; BIOS disk read

    jc disk_error            ; Jump if error

    jmp 0x8000               ; Jump to kernel!

disk_error:
    mov ah, 0x0E
    mov al, 'E'
    int 0x10
    hlt

times 510-($-$$) db 0
dw 0xAA55
