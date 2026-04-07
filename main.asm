    VIDEO_MODE_13H equ 0x13
    TEXT_MODE_3H equ 0x03
    BIOS_VIDEO_INTERRUPT equ 0x10
    KEYBOARD_INTERRUPT equ 0x16
    VIDEO_MEMORY_SEGMENT equ 0xA000
    PALETTE_INDEX_PORT equ 0x03C8
    VGA_INPUT_STATUS_REGISTER equ 0x3DA
    VERTICAL_RETRACE_STATUS_BIT equ 0x08

    org 100h

start:
.set_video_mode:
    mov ax, VIDEO_MODE_13H
    int BIOS_VIDEO_INTERRUPT

.set_palette:
    mov dx, PALETTE_INDEX_PORT
    xor al, al
    out dx, al               ; start at color 0
    inc dx                   ; 0x3C9 - palette data port
    xor bx, bx               ; BX = color index
    mov cx, 0x0100           ; 256 colors

palette_loop:
    mov al, bl
    shr al, 0x02             ; scale to 0-63
    out dx, al               ; R
    out dx, al               ; G
    out dx, al               ; B
    inc bx
    loop palette_loop

main_loop:
.wait_for_retrace:
    mov dx, VGA_INPUT_STATUS_REGISTER
.wait_end:
    in al, dx
    test al, VERTICAL_RETRACE_STATUS_BIT
    jnz .wait_end
.wait_start:
    in al, dx
    test al, VERTICAL_RETRACE_STATUS_BIT
    jz .wait_start
.draw_spiral:
    call draw
.check_input:
    mov ah, 0x01
    int KEYBOARD_INTERRUPT
    jz main_loop

    xor ax, ax
    int KEYBOARD_INTERRUPT

.return_to_dos:
    mov ax, TEXT_MODE_3H
    int BIOS_VIDEO_INTERRUPT
    ret

    %include "core/spiral.asm"
