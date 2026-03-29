    org 100h

start:
; Set video mode 13h (320x200, 256 colors)
    mov ax, VIDEO_MODE_13H
    int BIOS_VIDEO_INTERRUPT

; Setup grayscale palette (compact!)
    mov dx, PALETTE_INDEX_PORT
    xor al, al
    out dx, al               ; start at color 0
    inc dx                   ; 0x3C9 - palette data port
    xor bx, bx               ; BX = color index
    mov cx, 0x0100           ; 256 colors

palette_loop:
    mov al, bl
    shr al, 0x02             ; scale to 0-63
    out dx, al               ; R
    out dx, al               ; G
    out dx, al               ; B
    inc bx
    loop palette_loop

    push VIDEO_MEMORY_SEGMENT
    pop es

.calculate_uv_values:
    call calculate_uv_values

main_loop:
.reset_video_memory:
    xor di, di

.clear_buffer:
    xor ax, ax
    mov cx, 0x7D00
    rep stosw

.check_input:
    mov ah, 0x01
    int KEYBOARD_INTERRUPT
    jz main_loop

    xor ax, ax
    int KEYBOARD_INTERRUPT

.return_to_dos:
    mov ax, TEXT_MODE_3H
    int BIOS_VIDEO_INTERRUPT
    ret

    U_STEPS equ 0xC8
    VIDEO_MODE_13H equ 0x13
    TEXT_MODE_3H equ 0x03
    BIOS_VIDEO_INTERRUPT equ 0x10
    KEYBOARD_INTERRUPT equ 0x16
    VIDEO_MEMORY_SEGMENT equ 0xA000
    PALETTE_INDEX_PORT equ 0x03C8

    section .data
two_pi::
    dq 6.28318530717958647692
half::
    dd 0.5
two::
    db 2
focal_length::
    db 85
circumference_constant::
    dd 534.07073974609375
v_checkerboard_size::
    dd 0.785398185253143311
dark_reciprocal::
    db 5

    section .bss
light:
    resd 1
depth:
    resd 1
x:
    resd 1
y:
    resd 1
z:
    resd 1
px:
    resb 1
py:
    resb 1
u:
    resd 1
v:
    resd 1
u_offset:
    resd 1
v_offset:
    resd 1

u_values:
    resd U_STEPS
v_steps:
    resd U_STEPS
