    org 100h

    section .text
start:
.set_video_mode:
    mov ax, VIDEO_MODE_13H
    int BIOS_VIDEO_INTERRUPT

; mov dx, PALETTE_INDEX_PORT
; int BIOS_VIDEO_INTERRUPT

    %include "core/dos.asm"

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
