    %ifdef COM
    %define REG(x) x
    %define MEM(offset) [es:offset]
    %else
    %define REG(x) e%+x
    %define MEM(offset) [image + offset]
    %endif

    %define PX (REG(si))
    %define PY (REG(si) + 2)
    %define U (REG(si) + 4)
    %define V (REG(si) + 6)

    %define I (REG(di))
    %define F_V (REG(di) + 4)
    %define OFFSET (REG(di) + 8)

    section .text
draw:
    %ifndef COM
    pusha
    %endif
clear_buffers:
.clear_video_buffer:
    %ifdef COM
    xor ax, ax
    xor di, di
    mov cx, VIDEO_BUFFER_SIZE
    rep stosw
    %else
    xor ebx, ebx
    xor eax, eax
    mov edi, image
    mov ecx, BUFFER_SIZE / 4
    rep stosd
    %endif

draw_spiral:
    mov REG(si), px
    mov REG(di), i
    mov REG(bp), focal_length
.increment_offset:
    fild word [REG(bp)]
    fld1
    fdiv st0, st1                      ; offset_delta ← 1 / focal_length

    fadd dword [OFFSET]
    fst dword [OFFSET]                 ; offset ← offset + offset_delta
; fmul st0, st0
; fsin

.loop_init:
    mov bl, I_MIN

; for i = I_MIN to I_MAX
u_loop_start:
    pusha
    mov [I], bx

u_loop:
calculate_uv_values:
.v:
    fst dword [F_V]                    ; v ← offset
.v_step:
    fldpi
    fidiv word [I]                     ; v_step ← π / i
.v_step_2x:
    fld st0
    fadd st0, st0                      ; 2 v_step ← 2π / i
    fxch
.u:
    fld st0
    fmul st0, st4                      ; u ← v_step × focal_length
    fist word [U]                      ; u_int ← ⌊u⌋

.skip_cylindrical_effect:
    cmp byte [REG(bp) + 3], 0
    jz calculate_initial_point

cylindrical_effect:
.u_int:
    fild word [U]

.u_combined:
    fsub st0, st1
    fld st4
    fsin
    fabs
    fmulp st1, st0
    faddp st1, st0                     ; u ← u + (⌊u⌋ - u) × |sin(offset)|

calculate_initial_point:
    fadd st0, st3                      ; u ← u + offset
.u_sincos:
    fsincos
.py:
    fdiv st2                           ; py ← sin u / v_step
.px:
    fxch st2
    fdivp st1                          ; px ← cos u / v_step
    fxch

; for v = 0 to i - 1
v_loop_start:
    mov cx, bx

v_loop:
    pusha
.increment_v:
    fld st2
    fadd dword [F_V]
    fst dword [F_V]                    ; v ← v + 2 v_step
.checkerboard_v:
    fld st0
    fmul dword [REG(bp) + 4]           ; checkerboard_v ← v / checkerboard_size
    fistp word [V]                     ; v_int ← ⌊v / checkerboard_size⌋
.increment_px_py:
    fadd dword [OFFSET]                ; double v rotation
    fsincos
    fsubp st3, st0                     ; py ← py - cos(v + offset)
    fsubp st1, st0                     ; px ← px - sin(v + offset)
.save_px_py:
    fist word [PX]                     ; px_int ← ⌊px × checkerboard_size⌋
    fxch
    fist word [PY]                     ; py_int ← ⌊py × checkerboard_size⌋
    fxch

update_image:
    mov dl, bl
.apply_pattern:
    mov al, [U]
    xor al, [V]
    and al, 0x01
    shl al, 2
    inc al                             ; pattern ← 4 × (u_int ⊕ v_int) + 1  [1 or 5]
.apply_lighting:
    sub dl, I_MIN
    shr dl, 4                          ; light ← (i - I_MIN) / 16     [0...12 range]
    mul dl                             ; color = pattern × light      [0...60 range]
.map_to_screen:
    mov bx, [PY]
    imul bx, REAL_SCREEN_WIDTH
    add bx, [PX]
    add bx, CENTER_OFFSET

    call draw_pixel
overlay:
    mov cl, I_MAX + 20
    sub cl, [i]
    shr cl, 6
    jz v_loop_end

    shr al, OVERLAY_RIGHT_SHIFT
.multi_draw:
    shl bx, 1
    neg bx

    add al, MEM(REG(bx))
    and al, MAX_COLOR

.draw_overlay_pixel:
    call draw_pixel

    shr al, 2
    loop .multi_draw

v_loop_end:
    popa
    dec cl
    jnz v_loop
v_loop_exit:
    popa
    fstp st0
    fstp st0
    fstp st0
; end for v

u_loop_exit:
    inc bl
    cmp bl, [REG(bp) + 2]              ; bl > frame_count
    ja draw_exit
    cmp bl, I_MAX + 1
    jb u_loop_start
; end for u

draw_exit:
    inc word [REG(bp) + 2]             ; frame_count++

    %ifndef COM
    ; fstp st0                           ; ignore unbalanced FPU stack?
    popa
    ret

    %include "core/data.asm"
    %include "core/consts.asm"
    %include "core/vars.asm"
    %include "core/pixel.asm"
    %endif
