    %ifdef DOS
    %include "core/consts.asm"

    section .text
set_palette:
    %ifndef COM
    pusha
    xor bx, bx
    mov dx, PALETTE_INDEX_PORT
    int BIOS_VIDEO_INTERRUPT
    %endif

    mov dx, PALETTE_DATA_PORT
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

    %endif
    %ifndef COM
    popa
    ret

    global set_palette
    extern offset
    %endif
