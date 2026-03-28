global calculate_uv_values
global calculate_initial_spiral_point

U_STEPS equ 200
BUFFER_SIZE equ U_STEPS * 4

section .text

calculate_uv_values:
; v_steps ← 2π / i
; v_step ← 2π / i
; u ← v_step × focal_length
; depth ← u * u
    fld dword [two_pi]
    fild word [i]
.v_step:
    fdiv
    fst dword [v_step]
.u:    
    fmul dword [focal_length]
    fst dword [u]
.depth: 
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


calculate_initial_spiral_point:
    fld dword [u]
.sincos:
    fsincos
.py:
    fadd st0, st0
    fdiv dword [v_step]
    fiadd word [half_spiral_screen_height]
    fst dword [py]
.px:
    fxch
    fadd st0, st0
    fdiv dword [v_step]
    fiadd word [half_spiral_screen_width]
    fst dword [px]
    ret

extern focal_length
extern attenuation
extern checkerboard_dark

extern light
extern depth

extern i
extern u
extern v
extern px
extern py

extern v_step

extern two_pi
extern half_spiral_screen_width
extern half_spiral_screen_height

