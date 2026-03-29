; global do_u_step
; global do_v_step
    global increment_offset
    global calculate_uv_values
    global calculate_initial_point
    global increment_point
    global update_image

    global focal_length
    global attenuation
    global checkerboard_dark
    global checkerboard_size
    global two_pi
    global half_spiral_screen_width
    global half_spiral_screen_height
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
    HALF_SCREEN_WIDTH equ SCREEN_WIDTH / 2
    HALF_SCREEN_HEIGHT equ SCREEN_HEIGHT / 2

    U_STEPS equ SCREEN_HEIGHT * 2
    BUFFER_SIZE equ SCREEN_WIDTH * SCREEN_HEIGHT

    section .text

loop:
    mov word [i], 0x01
.loop_start:
    cmp word [i], U_STEPS
    jg .loop_end
    call do_u_step
    inc word [i]
    jmp .loop_start
.loop_end:
    ret

do_u_step:
    call calculate_uv_values
    call calculate_initial_point
    mov cl, byte [i]
.v_loop:
    call do_v_step
    loop .v_loop
.v_loop_end:
    ret

do_v_step:
; call update_depth_buffer
; call increment_point
    ret

update_image:
    pusha
.get_index:
    fld dword [px]
    frndint
    fld dword [py]
    frndint
    fimul word [screen_width]
    faddp
    fistp word [array_index]
.check_depth:
    xor ebx, ebx
    mov bx, [array_index]
    fld dword [depth]
    fcomp dword [depth_buffer + 4 * ebx]
    fstsw ax
    sahf
    jae .exit
.calculate_color:
.load_uv:
    fld dword [u]
    fdiv dword [checkerboard_size]
    fistp word [u_int]
    fld dword [v]
    fdiv dword [checkerboard_size]
    fistp word [v_int]
.apply_pattern:
    xor cx, cx
    mov cx, [u_int]
    xor cx, [v_int]
    and cx, 0x01
    mov [color], cx
.apply_lighting:
    fild word [color]
    fadd dword [checkerboard_dark]
    fmul dword [light]
    fistp word [color]
    mov cl, [color]
    mov [image + ebx], cl
.exit:
    popa
    ret

increment_offset:
    fld1
    fdiv dword [focal_length]
    fadd dword [offset]
    fst dword [offset]
    ret

calculate_uv_values:
.v:
    fldz
    fstp dword [v]
.v_step:                     ; v_step ← 2π / i
    fld dword [two_pi]
    fild word [i]
    fdiv
    fst dword [v_step]
.u:                          ; u ← v_step × focal_length
    fmul dword [focal_length]
    fst dword [u]
.depth:                      ; depth ← u * u
    fld st0
    fmul st0
    fstp dword [depth]
.calculate_light:
    fmul dword [attenuation]
    fld1
    faddp
    fld dword [w255]
    fdivr
    fstp dword [light]
    ret

calculate_initial_point:
    fld dword [u]
    fadd dword [offset]
.sincos:
    fsincos
.py:
    fadd st0, st0
    fdiv dword [v_step]
    fiadd word [half_spiral_screen_height]
    fstp dword [py]
.px:
    fadd st0, st0
    fdiv dword [v_step]
    fiadd word [half_spiral_screen_width]
    fstp dword [px]
    ret

increment_point:
    fld dword [px]
    fld dword [py]
    fld dword [v]
.increment_v:
    fadd dword [v_step]
    fst dword [v]
    fadd dword [offset]
.increment_px_py:
    fsincos
    fsubp st3, st0           ; px - cos(v)
    fsubp                    ; py - sin(v)
    fstp dword [py]
    fstp dword [px]
    ret

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
two_pi:
    dd 6.28318530717958647692
screen_width:
    dw SCREEN_WIDTH
half_spiral_screen_width:
    dw HALF_SCREEN_WIDTH
half_spiral_screen_height:
    dw HALF_SCREEN_HEIGHT

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
