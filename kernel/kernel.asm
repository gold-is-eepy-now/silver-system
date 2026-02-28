org 0x8000
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    call set_video_mode
    call draw_desktop

main_loop:
    call read_key
    cmp al, 'd'
    je .desktop
    cmp al, 'D'
    je .desktop
    cmp al, 't'
    je .terminal
    cmp al, 'T'
    je .terminal
    cmp al, 'm'
    je .tasks
    cmp al, 'M'
    je .tasks
    cmp al, 'n'
    je .notes
    cmp al, 'N'
    je .notes
    cmp al, 27
    je reboot_system
    jmp main_loop

.desktop:
    call draw_desktop
    jmp main_loop

.terminal:
    call app_terminal
    jmp main_loop

.tasks:
    call app_task_manager
    jmp main_loop

.notes:
    call app_notes
    jmp main_loop

; -------------------------------------------------
; Desktop renderer
; -------------------------------------------------

draw_desktop:
    ; Starry-ish gradient wallpaper
    xor cx, cx
.yloop:
    cmp cx, 200
    jae .wall_done
    mov bx, 0
.xloop:
    cmp bx, 320
    jae .next_row
    mov ax, cx
    shr ax, 2
    add al, 1
    mov dx, cx
    add dx, bx
    and dl, 0x03
    cmp dl, 0
    jne .pix
    add al, 8
.pix:
    mov dx, cx
    push cx
    mov cx, bx
    call put_pixel
    pop cx
    inc bx
    jmp .xloop
.next_row:
    inc cx
    jmp .yloop
.wall_done:

    ; Left icon rail background
    mov bx, 4
    mov cx, 6
    mov dx, 60
    mov si, 186
    mov al, 1
    call fill_rect

    ; Task bar (bottom)
    mov bx, 0
    mov cx, 186
    mov dx, 320
    mov si, 14
    mov al, 17
    call fill_rect

    ; Start button
    mov bx, 4
    mov cx, 188
    mov dx, 34
    mov si, 10
    mov al, 10
    call fill_rect

    ; Fake clock tray
    mov bx, 270
    mov cx, 188
    mov dx, 46
    mov si, 10
    mov al, 8
    call fill_rect

    ; Draw icon blocks in left column
    mov bx, 14
    mov cx, 14
    mov al, 12
    call draw_icon
    mov cx, 40
    mov al, 14
    call draw_icon
    mov cx, 66
    mov al, 11
    call draw_icon
    mov cx, 92
    mov al, 9
    call draw_icon
    mov cx, 118
    mov al, 13
    call draw_icon
    mov cx, 144
    mov al, 10
    call draw_icon

    ; Main control-panel style window
    mov bx, 72
    mov cx, 34
    mov dx, 220
    mov si, 138
    mov al, 7
    call fill_rect

    ; Title bar
    mov bx, 72
    mov cx, 34
    mov dx, 220
    mov si, 12
    mov al, 1
    call fill_rect

    ; Window inner section
    mov bx, 76
    mov cx, 50
    mov dx, 212
    mov si, 118
    mov al, 15
    call fill_rect

    ; App tiles
    mov bx, 88
    mov cx, 64
    mov al, 3
    call app_tile
    mov bx, 128
    mov cx, 64
    mov al, 2
    call app_tile
    mov bx, 168
    mov cx, 64
    mov al, 4
    call app_tile
    mov bx, 208
    mov cx, 64
    mov al, 6
    call app_tile

    mov bx, 88
    mov cx, 102
    mov al, 5
    call app_tile
    mov bx, 128
    mov cx, 102
    mov al, 9
    call app_tile
    mov bx, 168
    mov cx, 102
    mov al, 10
    call app_tile
    mov bx, 208
    mov cx, 102
    mov al, 11
    call app_tile

    ; Text labels
    mov dh, 4
    mov dl, 11
    mov si, title_text
    call print_at

    mov dh, 7
    mov dl, 11
    mov si, cfg_text
    call print_at

    mov dh, 8
    mov dl, 12
    mov si, tile_1
    call print_at
    mov dh, 8
    mov dl, 17
    mov si, tile_2
    call print_at
    mov dh, 8
    mov dl, 22
    mov si, tile_3
    call print_at
    mov dh, 8
    mov dl, 27
    mov si, tile_4
    call print_at

    mov dh, 13
    mov dl, 12
    mov si, tile_5
    call print_at
    mov dh, 13
    mov dl, 17
    mov si, tile_6
    call print_at
    mov dh, 13
    mov dl, 22
    mov si, tile_7
    call print_at
    mov dh, 13
    mov dl, 27
    mov si, tile_8
    call print_at

    mov dh, 23
    mov dl, 1
    mov si, start_text
    call print_at

    mov dh, 23
    mov dl, 33
    mov si, clock_text
    call print_at

    mov dh, 24
    mov dl, 1
    mov si, hint_text
    call print_at
    ret

; -------------------------------------------------
; Apps
; -------------------------------------------------

app_terminal:
    call draw_desktop
    call draw_window_frame
    mov dh, 7
    mov dl, 12
    mov si, term_title
    call print_at
    mov dh, 9
    mov dl, 12
    mov si, term_help
    call print_at

.term_loop:
    mov dh, 11
    mov dl, 12
    mov si, prompt
    call print_at

    mov dh, 11
    mov dl, 20
    call set_cursor
    mov di, command_buffer
    call read_line

    mov si, command_buffer
    mov di, cmd_help
    call strcmp
    jc .do_help

    mov si, command_buffer
    mov di, cmd_tasks
    call strcmp
    jc .do_tasks

    mov si, command_buffer
    mov di, cmd_desktop
    call strcmp
    jc .do_desktop

    mov si, command_buffer
    mov di, cmd_reboot
    call strcmp
    jc reboot_system

    mov si, command_buffer
    mov di, cmd_echo
    call starts_with
    jc .do_echo

    mov dh, 13
    mov dl, 12
    mov si, bad_cmd
    call print_at
    jmp .term_loop

.do_help:
    mov dh, 13
    mov dl, 12
    mov si, help_line_1
    call print_at
    mov dh, 14
    mov dl, 12
    mov si, help_line_2
    call print_at
    mov dh, 15
    mov dl, 12
    mov si, help_line_3
    call print_at
    jmp .term_loop

.do_tasks:
    call app_task_manager
    call draw_desktop
    call draw_window_frame
    mov dh, 7
    mov dl, 12
    mov si, term_title
    call print_at
    mov dh, 9
    mov dl, 12
    mov si, term_help
    call print_at
    jmp .term_loop

.do_desktop:
    call draw_desktop
    ret

.do_echo:
    mov dh, 13
    mov dl, 12
    mov si, command_buffer + 5
    call print_at
    jmp .term_loop

app_task_manager:
    call draw_desktop
    call draw_window_frame
    mov dh, 7
    mov dl, 12
    mov si, task_title
    call print_at
    mov dh, 9
    mov dl, 12
    mov si, task_line_1
    call print_at
    mov dh, 10
    mov dl, 12
    mov si, task_line_2
    call print_at
    mov dh, 11
    mov dl, 12
    mov si, task_line_3
    call print_at
    mov dh, 13
    mov dl, 12
    mov si, task_hint
    call print_at
    call read_key
    ret

app_notes:
    call draw_desktop
    call draw_window_frame
    mov dh, 7
    mov dl, 12
    mov si, notes_title
    call print_at
    mov dh, 9
    mov dl, 12
    mov si, notes_hint
    call print_at

    mov dh, 11
    mov dl, 12
    call set_cursor
.note_loop:
    call read_key
    cmp al, 27
    je .done
    cmp al, 13
    jne .print
    call newline
    jmp .note_loop
.print:
    call putc
    jmp .note_loop
.done:
    ret

reboot_system:
    int 0x19
    hlt

; -------------------------------------------------
; Drawing primitives
; -------------------------------------------------

set_video_mode:
    mov ax, 0x0013
    int 0x10
    ret

put_pixel:
    ; in: CX=x, DX=y, AL=color
    push bx
    push di
    push es
    mov bx, 0xA000
    mov es, bx

    mov bx, dx
    shl dx, 8
    shl bx, 6
    add dx, bx
    add dx, cx
    mov di, dx
    stosb

    pop es
    pop di
    pop bx
    ret

fill_rect:
    ; in: BX=x, CX=y, DX=width, SI=height, AL=color
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push bp
    push es

    mov bp, si
    mov si, cx
    mov ah, al

.row:
    mov ax, 0xA000
    mov es, ax
    mov ax, si
    mov di, ax
    shl ax, 6
    shl di, 8
    add di, ax
    add di, bx
    mov cx, dx
    mov al, ah
    rep stosb
    inc si
    dec bp
    jnz .row

    pop es
    pop bp
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

draw_icon:
    ; in BX=x, CX=y, AL=color
    push dx
    push si
    mov dx, 16
    mov si, 16
    call fill_rect
    pop si
    pop dx
    ret

app_tile:
    ; in BX=x, CX=y, AL=color
    push dx
    push si
    mov dx, 26
    mov si, 22
    call fill_rect
    pop si
    pop dx
    ret

draw_window_frame:
    mov bx, 70
    mov cx, 44
    mov dx, 228
    mov si, 124
    mov al, 8
    call fill_rect

    mov bx, 72
    mov cx, 46
    mov dx, 224
    mov si, 10
    mov al, 1
    call fill_rect

    mov bx, 72
    mov cx, 56
    mov dx, 224
    mov si, 110
    mov al, 15
    call fill_rect
    ret

; -------------------------------------------------
; Text + input helpers
; -------------------------------------------------

set_cursor:
    ; in DH=row DL=col
    push ax
    push bx
    mov ah, 0x02
    mov bh, 0
    int 0x10
    pop bx
    pop ax
    ret

print_at:
    ; in DH=row DL=col SI=str
    call set_cursor
.print:
    lodsb
    cmp al, 0
    je .done
    call putc
    jmp .print
.done:
    ret

putc:
    mov ah, 0x0E
    mov bh, 0
    mov bl, 15
    int 0x10
    ret

newline:
    mov al, 13
    call putc
    mov al, 10
    call putc
    ret

read_key:
    xor ax, ax
    int 0x16
    ret

read_line:
    xor cx, cx
.next:
    call read_key
    cmp al, 13
    je .done
    cmp al, 8
    jne .store
    cmp cx, 0
    je .next
    dec di
    dec cx
    mov al, 8
    call putc
    mov al, ' '
    call putc
    mov al, 8
    call putc
    jmp .next
.store:
    cmp cx, 62
    jae .next
    stosb
    inc cx
    call putc
    jmp .next
.done:
    mov al, 0
    stosb
    call newline
    ret

strcmp:
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .no
    cmp al, 0
    je .yes
    inc si
    inc di
    jmp .loop
.yes:
    stc
    ret
.no:
    clc
    ret

starts_with:
.loop:
    mov al, [di]
    cmp al, 0
    je .yes
    mov bl, [si]
    cmp al, bl
    jne .no
    inc di
    inc si
    jmp .loop
.yes:
    stc
    ret
.no:
    clc
    ret

; -------------------------------------------------
; Data
; -------------------------------------------------

title_text db 'Silver GUI Desktop',0
cfg_text db 'System Panel',0
tile_1 db 'TERM',0
tile_2 db 'TASK',0
tile_3 db 'NOTE',0
tile_4 db 'NET',0
tile_5 db 'FILE',0
tile_6 db 'SET',0
tile_7 db 'PROC',0
tile_8 db 'INFO',0
start_text db 'Menu',0
clock_text db '12:47',0
hint_text db 'Hotkeys: T=Terminal M=Tasks N=Notes D=Desktop ESC=Reboot',0

term_title db 'Terminal',0
term_help db 'commands: help tasks echo TEXT desktop reboot',0
prompt db 'silver> ',0
bad_cmd db 'unknown command',0
help_line_1 db 'help     : show command list',0
help_line_2 db 'tasks    : open task manager window',0
help_line_3 db 'desktop  : return to desktop',0

cmd_help db 'help',0
cmd_tasks db 'tasks',0
cmd_echo db 'echo ',0
cmd_desktop db 'desktop',0
cmd_reboot db 'reboot',0

task_title db 'Task Manager',0
task_line_1 db '001 RUNNING  DesktopShell',0
task_line_2 db '002 SLEEP    InputService',0
task_line_3 db '003 RUNNING  RenderCompositor',0
task_hint db 'Press any key to close...',0

notes_title db 'Notes',0
notes_hint db 'Type text. ESC to close this note window.',0

command_buffer times 64 db 0

times 16384-($-$$) db 0
