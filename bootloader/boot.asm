; Silver System bootloader (512-byte MBR compatible)
; Loads 16 sectors of kernel from disk to 0000:8000 and jumps to it.
org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov [boot_drive], dl

    mov ah, 0x02            ; BIOS read sectors
    mov al, 40              ; number of sectors
    mov ch, 0               ; cylinder
    mov cl, 2               ; start sector (after boot sector)
    mov dh, 0               ; head
    mov dl, [boot_drive]
    mov bx, 0x8000          ; destination offset
    int 0x13
    jc disk_error

    jmp 0x0000:0x8000

disk_error:
    mov si, error_msg
    call print_string
    hlt

print_string:
.next:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bx, 0x0007
    int 0x10
    jmp .next
.done:
    ret

boot_drive db 0
error_msg db 'Boot error',0

times 510-($-$$) db 0
dw 0xAA55
