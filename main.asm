
    org 0x0100

    %include "core/consts.asm"

    section .text
start:
.set_video_mode:
    mov al, VIDEO_MODE_13H
    int BIOS_VIDEO_INTERRUPT

palette:
    %include "core/palette.asm"

    section .text
main_loop:
    push VIDEO_MEMORY_SEGMENT
    pop es

    %ifndef NO_VSYNC
wait_for_retrace:
    mov dx, VGA_INPUT_STATUS_REGISTER
.wait_start:
    in al, dx
    test al, VERTICAL_RETRACE_STATUS_BIT
    jz .wait_start
    %endif

frame:
    %include "core/spiral.asm"

check_input:
    in al, KEYBOARD_DATA_PORT
    dec ax
    jnz main_loop

    %ifdef RETURN_TO_DOS
    mov ax, TEXT_MODE_3H
    int BIOS_VIDEO_INTERRUPT
    ret
    %endif

    %include "core/pixel.asm"
    %include "core/data.asm"
    %include "core/vars.asm"
