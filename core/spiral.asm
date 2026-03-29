    global increment_offset
    global calculate_uv_values
    global calculate_initial_point
    global increment_point

    global focal_length
    global attenuation
    global checkerboard_dark
    global checkerboard_size
    global two_pi
    global half_spiral_screen_width
    global half_spiral_screen_height
    global checkerboard_value
    global light
    global depth
    global px
    global py
    global u
    global v
    global v_step
    global offset
    global i

    U_STEPS equ 200
    BUFFER_SIZE equ U_STEPS * 4

    section .text

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
    fld1
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

    dd 0.25
checkerboard_dark:

    dd 0.2
checkerboard_size:

    dd 0.785398185253143311

two_pi:

    dd 6.28318530717958647692
half_spiral_screen_width:

    dw 80
half_spiral_screen_height:

    dw 50

    section .bss
checkerboard_value:
    resd 1
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
