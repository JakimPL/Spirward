    %ifdef COM
    %define REG(x) x
    %define MEM(offset) [es:offset]
    %else
    %define REG(x) e%+x
    %define MEM(offset) [image + offset]
    %endif
    %define MEM_REG(offset) MEM(REG(offset))

    section .text
draw:
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
    %ifndef COM
    pusha
    %endif

    mov REG(si), px_int
    mov REG(di), offset
    mov REG(bp), focal_length
.increment_offset:
    fild word [REG(bp)]
    fld1
    fdiv st0, st1

    fadd dword [REG(di) + 4]           ; offset ← offset + offset_delta
    fst dword [REG(di) + 4]            ; offset ← offset + offset_delta

.loop_init:
    mov bl, I_MIN

; for i = I_MIN to I_MAX
u_loop_start:
    pusha
    shl bx, 1
    mov [i], bx

u_loop:
calculate_uv_values:
.v:
    fst dword [REG(di)]                ; v ← offset
.v_step:
    fldpi
    fidiv word [REG(si) + 10]          ; v_step ← π / i
.v_step_2x:
    fld st0
    fadd st0, st0                      ; 2 v_step ← 2π / i
    fxch
.u:
    fld st0
    fmul st0, st4                      ; u ← v_step × focal_length
    fist word [REG(si) + 4]            ; u_int ← ⌊u⌋

.skip_cylindrical_effect:
    cmp word [REG(bp) + 4], CYLINDRICAL_EFFECT_DELAY ; frame_count < CYLINDRICAL_EFFECT_DELAY
    jb .calculate_light

.u_int:
    fld st0
    frndint                            ; snap to integer for a cylindrical effect

.u_combined:
    fsub st0, st1
    fld st4
    fsin
    fabs
    fmulp st1, st0
    faddp st1, st0                     ; u ← u + (⌊u⌋ - u) × |sin(offset)|

.calculate_light:
    fld st0
    fmul st0                           ; depth ← u²
    fidivr word [REG(bp) + 2]
    fistp word [REG(si) + 8]           ; light ← attenuation_factor / depth

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
    mov dx, bx

v_loop:
    push dx
.increment_v:
    fld st2
    fadd dword [REG(di)]
    fst dword [REG(di)]                ; v ← v + 2 v_step
.checkerboard_v:
    fld st0
    fmul dword [REG(bp) + 6]           ; checkerboard_v ← v / checkerboard_size
    fistp word [REG(si) + 6]           ; v_int ← ⌊v / checkerboard_size⌋
.increment_px_py:
    fadd dword [REG(di) + 4]           ; double v rotation
    fsincos
    fsubp st3, st0                     ; py ← py - cos(v + offset)
    fsubp st1, st0                     ; px ← px - sin(v + offset)
.save_px_py:
    fist word [REG(si)]                ; px' ← ⌊px × checkerboard_size⌋
    fxch
    fist word [REG(si) + 2]            ; py' ← ⌊py × checkerboard_size⌋
    fxch

update_image:
.map_to_screen:
    mov ax, [REG(si) + 2]
    imul ax, REAL_SCREEN_WIDTH
    add ax, [REG(si)]
    add ax, CENTER_OFFSET
    mov bx, ax
.apply_pattern:
    mov al, [REG(si) + 4]
    xor al, [REG(si) + 6]
    and al, 0x01
    shl al, 2
    inc al                             ; color ← 4 (checkerboard_u ⊕ checkerboard_v) + 1
.apply_lighting:
    mul word [REG(si) + 8]             ; color ← color × light

.draw_pixel:
    call draw_pixel

; overlay:
; mov cl, 160
; shl cx, 1
; sub cx, word [i]
; shr cx, 6
; jz v_loop_end

; shr al, OVERLAY_RIGHT_SHIFT
; .multi_draw:
; shl bx, 1
; add bx, MAGIC_NUMBER
; neg bx

; add al, MEM(REG(bx))
; and al, MAX_COLOR

; .draw_overlay_pixel:
; call draw_pixel

; shr al, 2
; loop .multi_draw

v_loop_end:
    pop dx
    dec dx
    jnz v_loop
v_loop_exit:
    popa
    fstp st0
    fstp st0
    fstp st0
; end for v

u_loop_exit:
    inc bl
; cmp bl, [frame_count]
; ja draw_exit
    cmp bl, I_MAX + 1
    jb u_loop_start
; end for u

draw_exit:
; fstp st0                           ; ignore unbalanced FPU stack?
    %ifndef COM
    popa
    %endif
    inc word [REG(bp) + 4]             ; frame_count
    ret

draw_pixel:
    %ifndef COM
    movzx ebx, bx
    %endif
    mov ah, al
    mov MEM(REG(bx)), ax               ; write two pixels for a thicker spiral
    mov MEM(REG(bx) + REAL_SCREEN_WIDTH), ax
    ret

    %include "core/data.asm"
    %include "core/consts.asm"
    %include "core/vars.asm"
