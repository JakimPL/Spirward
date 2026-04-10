    VIDEO_MODE_13H equ 0x13
    TEXT_MODE_3H equ 0x03
    BIOS_VIDEO_INTERRUPT equ 0x10
    KEYBOARD_INTERRUPT equ 0x16
    VIDEO_MEMORY_SEGMENT equ 0xA000
    PALETTE_INDEX_PORT equ 0x03C9
    VGA_INPUT_STATUS_REGISTER equ 0x3DA
    VERTICAL_RETRACE_STATUS_BIT equ 0x08

    org 100h

start:
.set_video_mode:
    mov ax, VIDEO_MODE_13H
    int BIOS_VIDEO_INTERRUPT

set_palette:
    mov dx, PALETTE_INDEX_PORT
    mov cl, 0x40                       ; 64 colors
.palette_loop:
    mov al, bl
    out dx, al                         ; R
    add al, 0x08
    cmp al, MAX_COLOR
    jbe .palette_ok
    mov al, MAX_COLOR
.palette_ok:
    out dx, al                         ; G
    out dx, al                         ; B
    inc bx
    loop .palette_loop

main_loop:
    push VIDEO_MEMORY_SEGMENT
    pop es

wait_for_retrace:
    mov dx, VGA_INPUT_STATUS_REGISTER
.wait_start:
    in al, dx
    test al, VERTICAL_RETRACE_STATUS_BIT
    jz .wait_start

frame:
    call draw

check_input:
    mov ah, 0x01
    int KEYBOARD_INTERRUPT
    jz main_loop

.return_to_dos:
    ; mov ax, TEXT_MODE_3H
    int BIOS_VIDEO_INTERRUPT

    %include "core/spiral.asm"
