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
    MAGIC_NUMBER equ 0x5D01
    BUFFER_SIZE equ 0x10000

    SCREEN_WIDTH equ 160
    SCREEN_HEIGHT equ 100
    HALF_SCREEN_WIDTH equ SCREEN_WIDTH / 2
    HALF_SCREEN_HEIGHT equ SCREEN_HEIGHT / 2

    I_MIN equ 20
    I_MAX equ 120
    FOCAL_LENGTH equ 200

    CYLINDRICAL_EFFECT_DELAY equ 628   ; π × FOCAL_LENGTH
    OVERLAY_RIGHT_SHIFT equ 3

    section .data
focal_length:
    dw FOCAL_LENGTH
checkerboard_size:
    dd 0.785398185253143311            ; π / 4

; to optimize
attenuation_a:
    dd -1.43
attenuation_b:
    dd 14.28

frame_count:
    dw 1
