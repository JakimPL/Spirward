    global focal_length
    global checkerboard_dark
    global checkerboard_size
    global two_pi
    global half_spiral_screen_width
    global half_spiral_screen_height

    REAL_SCREEN_WIDTH equ 320
    REAL_SCREEN_HEIGHT equ 200
    VIDEO_BUFFER_SIZE equ REAL_SCREEN_WIDTH * REAL_SCREEN_HEIGHT
    CENTER_OFFSET equ 0x7DA0

    SCREEN_WIDTH equ 160
    SCREEN_HEIGHT equ 100
    HALF_SCREEN_WIDTH equ SCREEN_WIDTH / 2
    HALF_SCREEN_HEIGHT equ SCREEN_HEIGHT / 2

    I_MIN equ 40
    I_MAX equ 200

    section .data
focal_length:
    dw 180
checkerboard_size:
    dd 0.785398185253143311

; to optimize
attenuation_a:
    dd -2.6
attenuation_b:
    dd 11.5
