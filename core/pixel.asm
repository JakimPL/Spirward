    %ifndef CORE_PIXEL
    %define CORE_PIXEL

    section .text
draw_pixel:
    %ifndef COM
    movzx ebx, bx
    %endif
    mov ah, al
    mov MEM(REG(bx)), ax               ; write two pixels for a thicker spiral
    %ifndef SCANLINE
    mov MEM(REG(bx) + SCREEN_WIDTH), ax
    %endif
    ret

    %endif
