palette_loop:
    mov al, bl
    PALETTE_OUT 0                      ; R
    add al, 0x08
    cmp al, MAX_COLOR
    jbe .palette_ok
    mov al, MAX_COLOR
.palette_ok:
    PALETTE_OUT 1                      ; G
    PALETTE_OUT 2                      ; B
    inc bx
    loop palette_loop
