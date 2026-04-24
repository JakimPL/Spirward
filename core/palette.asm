    %ifndef CORE_PALETTE_ASM
    %define CORE_PALETTE_ASM

palette_loop:
    mov al, bl
    PALETTE_OUT                        ; R
    add al, 0x08
    cmp al, MAX_COLOR
    jbe .palette_ok
    mov al, MAX_COLOR
.palette_ok:
    PALETTE_OUT                        ; G
    PALETTE_OUT                        ; B
    inc bx
    loop palette_loop

    %endif
