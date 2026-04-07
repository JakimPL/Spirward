    U_STEPS equ 0xC8
    VIDEO_MODE_13H equ 0x13
    TEXT_MODE_3H equ 0x03
    BIOS_VIDEO_INTERRUPT equ 0x10
    KEYBOARD_INTERRUPT equ 0x16
    VIDEO_MEMORY_SEGMENT equ 0xA000
    PALETTE_INDEX_PORT equ 0x03C8

    section .text
draw_pixel:
    mov bx, [array_index]
    mov cl, [color]
    mov [es:bx], cl
; mov [es:bx-1], cl
; mov [es:bx+1], cl
; mov [es:bx+REAL_SCREEN_WIDTH-1], cl
; mov [es:bx+REAL_SCREEN_WIDTH], cl
; mov [es:bx+REAL_SCREEN_WIDTH+1], cl
    ret

wait_for_retrace:
    mov dx, 0x3DA            ; VGA Input Status Register 1
.wait_end:
    in al, dx
    test al, 0x08            ; Bit 3 = vertical retrace status
    jnz .wait_end            ; Wait for any current retrace to end
.wait_start:
    in al, dx
    test al, 0x08
    jz .wait_start           ; Wait for next retrace to begin
    ret
