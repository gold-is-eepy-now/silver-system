org 0x8000

start:
    call task1
    call task2
    hlt

task1:
    mov ah, 0x0E
    mov al, 'A'
    int 0x10
    ret

task2:
    mov ah, 0x0E
    mov al, 'B'
    int 0x10
    ret
