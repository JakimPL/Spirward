    section .text
draw_pixel:
    %ifndef COM
    movzx ebx, bx
    %endif
    mov ah, al
    mov MEM(REG(bx)), ax               ; write two pixels for a thicker spiral
    mov MEM(REG(bx) + REAL_SCREEN_WIDTH), ax
    ret
