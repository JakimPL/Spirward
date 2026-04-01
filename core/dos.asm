    U_STEPS equ 0xC8
    VIDEO_MODE_13H equ 0x13
    TEXT_MODE_3H equ 0x03
    BIOS_VIDEO_INTERRUPT equ 0x10
    KEYBOARD_INTERRUPT equ 0x16
    VIDEO_MEMORY_SEGMENT equ 0xA000
    PALETTE_INDEX_PORT equ 0x03C8

    section .text
draw_pixel:
    pusha
    push VIDEO_MEMORY_SEGMENT
    pop es

    mov cl, [color]          ; Save color once

; dy loop: -4 to 4
    mov si, -1
.dy_loop:
; dx loop: -4 to 4
    mov di, -1
.dx_loop:
; px = px_int * 2 + dx
    mov ax, [px_int]
    shl ax, 1
    add ax, di
; Bounds check: 0 <= px < 320
    test ax, ax
    js .next_dx              ; Skip if negative
    cmp ax, 320
    jge .next_dx
    mov bx, ax               ; Save px

; py = py_int * 2 + dy
    mov ax, [py_int]
    shl ax, 1
    add ax, si
; Bounds check: 0 <= py < 200
    test ax, ax
    js .next_dx
    cmp ax, 200
    jge .next_dx

; offset = py * 320 + px = py * (256 + 64) + px
    mov dx, ax
    shl ax, 8                ; ax = py * 256
    shl dx, 6                ; dx = py * 64
    add ax, dx               ; ax = py * 320
    add ax, bx               ; ax = offset

    mov bx, ax
    mov [es:bx], cl

.next_dx:
    inc di
    cmp di, 1
    jl .dx_loop

    inc si
    cmp si, 1
    jl .dy_loop

    popa
    ret

wait_for_retrace:
    mov dx, 0x3DA            ; VGA Input Status Register 1
.wait_end:
    in al, dx
    test al, 0x08            ; Bit 3 = vertical retrace status
    jnz .wait_end            ; Wait for any current retrace to end
.wait_start:
    in al, dx
    test al, 0x08
    jz .wait_start           ; Wait for next retrace to begin
    ret
