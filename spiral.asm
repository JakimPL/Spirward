org 100h

start:
    ; Set video mode 13h (320x200, 256 colors)
    mov ax, 0x13
    int 0x10
    
    ; Setup grayscale palette (compact!)
    mov dx, 0x03C8      ; palette index port
    xor al, al
    out dx, al          ; start at color 0
    inc dx              ; 0x3C9 - palette data port
    xor bx, bx          ; BX = color index
    mov cx, 0x0100      ; 256 colors

palette_loop:
    mov al, bl
    shr al, 0x02        ; scale to 0-63
    out dx, al          ; R
    out dx, al          ; G
    out dx, al          ; B
    inc bx
    loop palette_loop
    
    ; Set ES to video memory segment
    push 0xA000
    pop es

main_loop:
.reset_video_memory:
    xor di, di

.fill:
    mov ax, 0x4040
    mov cx, 0x7D00
    rep stosw 

.check_input:
    mov ah, 0x01
    int 0x16
    jz main_loop

    xor ax, ax
    int 0x16
    
.return_to_dos:
    mov ax, 0x03
    int 0x10
    ret
