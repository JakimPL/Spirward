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
    call wait_for_retrace
.draw_spiral:
    call clear_buffers
    call draw_spiral
    call increment_offset
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

    %include "core/dos.asm"
    %include "core/spiral.asm"
