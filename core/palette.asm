    %ifndef COM
    %include "core/consts.asm"
    %endif

    %ifdef DOS
    %macro PALETTE_OUT 1
    out dx, al
    %endmacro
    %else
    %macro PALETTE_OUT 1
    mov [palette_data + edi], al
    inc edi
    %endmacro

    section .data
    global palette_data
    palette_data: times 768 db 0       ; 256 colors * 3 RGB components
    %endif

    section .text
    global set_palette

set_palette:
    %ifdef DOS
    %ifndef COM
    pusha
    xor bx, bx
    mov dx, PALETTE_INDEX_PORT
    int BIOS_VIDEO_INTERRUPT
    %endif

    mov dx, PALETTE_DATA_PORT
    mov cl, 0xFF
    %else
    push ebx
    push edi
    xor ebx, ebx
    xor edi, edi
    mov ecx, 0x100
    %endif

.palette_loop:
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
    loop .palette_loop

    %ifdef DOS
    %ifndef COM
    popa
    ret
    %endif
    %else
    pop edi
    pop ebx
    ret
    %endif
