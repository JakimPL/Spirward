    global color
    global light
    global depth
    global px
    global py
    global u
    global v
    global v_step
    global offset
    global i
    global array_index
    global depth_buffer
    global image

    SCREEN_WIDTH equ 160
    SCREEN_HEIGHT equ 100
    BUFFER_SIZE equ SCREEN_WIDTH * SCREEN_HEIGHT

    section .bss
color:
    resw 1
light:
    resd 1
depth:
    resd 1
px:
    resd 1
py:
    resd 1
u:
    resd 1
v:
    resd 1
v_step:
    resd 1
offset:
    resd 1
i:
    resw 1
array_index:
    resw 1
u_int:
    resw 1
v_int:
    resw 1

depth_buffer:
    resd BUFFER_SIZE
image:
    resb BUFFER_SIZE
