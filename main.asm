    org 100h

    %include "core/data.asm"
    %include "core/consts.asm"
    %include "core/vars.asm"

    section .text
start:
.set_video_mode:
    mov ax, VIDEO_MODE_13H
    int BIOS_VIDEO_INTERRUPT

palette:
    %include "core/palette.asm"

    section .text
main_loop:
    push VIDEO_MEMORY_SEGMENT
    pop es

wait_for_retrace:
    mov dx, VGA_INPUT_STATUS_REGISTER
.wait_start:
    in al, dx
    test al, VERTICAL_RETRACE_STATUS_BIT
    jz .wait_start

    fninit
frame:
    %include "core/spiral.asm"

check_input:
    mov ah, 0x01
    int KEYBOARD_INTERRUPT
    jz main_loop

.return_to_dos:
; mov ax, TEXT_MODE_3H
    int BIOS_VIDEO_INTERRUPT

    %include "core/pixel.asm"
