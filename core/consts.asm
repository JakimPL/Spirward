    global focal_length
    global attenuation
    global checkerboard_dark
    global checkerboard_size
    global two_pi
    global half_spiral_screen_width
    global half_spiral_screen_height

    SCREEN_WIDTH equ 160
    SCREEN_HEIGHT equ 100
    HALF_SCREEN_WIDTH equ SCREEN_WIDTH / 2
    HALF_SCREEN_HEIGHT equ SCREEN_HEIGHT / 2

    U_STEPS equ SCREEN_HEIGHT * 2
    BUFFER_SIZE equ SCREEN_WIDTH * SCREEN_HEIGHT

    section .data
focal_length:
    dd 85.0
attenuation:
    dd 0.3
checkerboard_dark:
    dd 0.2
checkerboard_size:
    dd 0.785398185253143311

w255:
    dd 255.0
max_depth:
    dw 150
two_pi:
    dd 6.28318530717958647692
screen_width:
    dw SCREEN_WIDTH
screen_height:
    dw SCREEN_HEIGHT
half_spiral_screen_width:
    dw HALF_SCREEN_WIDTH
half_spiral_screen_height:
    dw HALF_SCREEN_HEIGHT
