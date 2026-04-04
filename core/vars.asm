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
    %ifdef LINUX
    global image
    %endif

    SCREEN_WIDTH equ 160
    SCREEN_HEIGHT equ 100
    BUFFER_SIZE equ SCREEN_WIDTH * SCREEN_HEIGHT

    REAL_SCREEN_WIDTH equ 320
    REAL_SCREEN_HEIGHT equ 200
    %ifdef DOS
    VIDEO_BUFFER_SIZE equ REAL_SCREEN_WIDTH * REAL_SCREEN_HEIGHT / 2
    %endif
    %ifdef LINUX
    VIDEO_BUFFER_SIZE equ REAL_SCREEN_WIDTH * REAL_SCREEN_HEIGHT
    %endif

    CHECKERBOARD_SIZE equ 8

    section .bss
color:
    resw 1
f_light:
    resd 1
light:
    resw 1
f_depth:
    resd 1
depth:
    resw 1
f_px:
    resd 1
px:
    resw 1
f_py:
    resd 1
py:
    resw 1
f_u:
    resd 1
u:
    resw 1
f_v:
    resd 1
v:
    resw 1
f_v_step:
    resd 1
v_step:
    resd 1
offset:
    resd 1
i:
    resw 1
array_index:
    resw 1

px_int:
    resw 1
py_int:
    resw 1
u_int:
    resw 1
v_int:
    resw 1

depth_buffer:
    resw BUFFER_SIZE
    %ifdef LINUX
image:
    resw BUFFER_SIZE
    %endif
