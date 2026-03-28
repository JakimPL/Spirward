global calculate_uv_values
global calculate_initial_point
global increment_point

U_STEPS equ 200
BUFFER_SIZE equ U_STEPS * 4

section .text

calculate_uv_values:
    fld dword [two_pi]
    fild word [i]
.v_step: ; v_step ← 2π / i
    fdiv
    fst dword [v_step]
.u:    ; u ← v_step × focal_length
    fmul dword [focal_length]
    fst dword [u]
.depth: ; depth ← u * u
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
.increment_px_py:
    fsincos
    fsubp st3, st0 ; px - cos(v)
    fsubp  ; py - sin(v)
    fstp dword [py]
    fstp dword [px]
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

