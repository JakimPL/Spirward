    %ifdef COM
    %define REG(x) x
    %define MEM(offset) [es:offset]
    %else
    %define REG(x) e%+x
    %define MEM(offset) [image + offset]
    %endif

    %define U (REG(si))
    %define V (REG(si) + 2)
    %define PX (REG(si) + 4)
    %define PY (REG(si) + 6)

    %define F_V (REG(di))
    %define I (REG(di) + 4)

    %define FRAME_COUNT (REG(bp))
    %define FOCAL (REG(bp) + 2)

    section .text
frame:
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
.setup_registers:
    mov REG(si), u
    mov REG(di), f_v
    mov REG(bp), frame_count
u_loop_start:
    mov bl, I_MIN
    mov dh, byte [FRAME_COUNT + 1]
    shr dh, 1

; for i = I_MIN to I_MAX
u_loop:
    mov [I], bx

    fninit
.load_offset:
    fild word [FOCAL]
    fild word [FRAME_COUNT]
    fdiv st0, st1                      ; offset ← frame_count / focal_length

calculate_uv_values:
.v:
    fst dword [F_V]                    ; v ← offset
.v_step:
    fldpi
    fidiv word [I]                     ; v_step ← π / i
.u:
    fld st0
    fmul st3                           ; u ← v_step × focal_length
    fist word [U]                      ; u_int ← ⌊u⌋

.skip_cylindrical_effect:
    cmp dh, al
    jbe calculate_initial_point

cylindrical_effect:
.u_int:
    fild word [U]

.u_combined:
    fsub st0, st1
    fld st3
    fcos
    fabs
    fmulp st1, st0
    faddp st1, st0                     ; u ← u + (⌊u⌋ - u) × |sin(offset)|

calculate_initial_point:
    fsubr st0, st2                     ; u ← offset - u (additional reflection)
.u_sincos:
    fsincos
.py:
    fdiv st2                           ; py ← cos u / v_step
.px:
    fxch
    fdiv st2                           ; px ← sin u / v_step

; for v = 0 to i - 1
v_loop_start:
    mov cx, bx

v_loop:
    pusha
.increment_v:
    fld st2
    fadd st0, st0
    fadd dword [F_V]
    fst dword [F_V]                    ; v ← v + 2 v_step
.checkerboard_v:
    fldpi
    fdivr st0, st1
    fadd st0, st0
    fadd st0, st0
    fistp word [V]                     ; v_int ← ⌊4v / π⌋
.increment_px_py:
    fadd st4                           ; double v rotation
    fsincos
    fsubp st2, st0                     ; py ← py - cos(v + offset)
    fsubp st2, st0                     ; px ← px - sin(v + offset)
.save_px_py:
    fist word [PX]                     ; px_int ← ⌊px × checkerboard_size⌋
    fxch
    fist word [PY]                     ; py_int ← ⌊py × checkerboard_size⌋
    fxch

update_image:
.prepare_overlay:
    mov cl, I_MAX
    sub cl, bl
.apply_pattern:
    mov al, [V]
    xor al, [U]
    and al, 0x01
    shl al, 2
    inc ax                             ; pattern ← 4 × (u_int ⊕ v_int) + 1  [1 or 5]
.apply_lighting:
    shr bl, 4                          ; light ← i / 16               [0...12 range]
    mul bl                             ; color = pattern × light      [0...60 range]
.map_to_screen:
    mov bx, [PX]                       ; rotate, looks better
    imul bx, SCREEN_WIDTH
    add bx, [PY]
    add bx, CENTER_OFFSET

.draw_pixel:
    call draw_pixel

overlay:
    shr cl, 6
    shr al, OVERLAY_RIGHT_SHIFT
.overlay_loop:
.skip_overlay:
    cmp dh, cl
    jbe v_loop_end

.apply_transformation:
    shl bx, 1
    neg bx
    add al, MEM(REG(bx))

.draw_overlay_pixel:
    call draw_pixel
    loop .overlay_loop

v_loop_end:
    popa
    loop v_loop
v_loop_exit:
; end for v

u_loop_exit:
    inc bx
    cmp bl, [FRAME_COUNT]              ; bl > frame_count
    ja draw_exit
    cmp bl, I_MAX
    jbe u_loop
; end for u

draw_exit:
    inc word [FRAME_COUNT]             ; frame_count++

    %ifndef COM
    popa
    ret

    %include "core/data.asm"
    %include "core/consts.asm"
    %include "core/vars.asm"
    %include "core/pixel.asm"
    %endif
