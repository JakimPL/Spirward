    %ifdef COM
    %define REG(x) x
    %define MEM(offset) [es:offset]
    %else
    %define REG(x) e%+x
    %define MEM(offset) [image + offset]
    %endif

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

; .diffusion:
; %ifdef DOS
; xor si, si
; %endif
; %ifdef LINUX
; xor ebx, ebx
; %endif
; .diffuse:
; mov ax, [es:bx]
; mov bx, ax
; shr bx, 1
; and bx, 0x7F7F

; mov dx, [es:bx-2]
; shr dx, 4
; and dx, 0x0F0F
; mov cx, [es:bx+2]
; shr cx, 4
; and cx, 0x0F0F
; add dx, cx
; add bx, dx

; mov dx, [es:bx-REAL_SCREEN_WIDTH*2]
; shr dx, 4
; and dx, 0x0F0F
; mov cx, [es:bx+REAL_SCREEN_WIDTH*2]
; shr cx, 4
; and cx, 0x0F0F
; add dx, cx
; add bx, dx

; mov [es:bx], bx
; add bx, REAL_SCREEN_WIDTH*2 + 2
; cmp bx, VIDEO_BUFFER_SIZE
; jb .diffuse

draw_spiral:
    xor ax, ax
    pusha
.increment_offset:
    fld1
    fidiv word [focal_length]          ; offset_delta ← 1 / focal_length

    mov REG(si), offset
    fadd dword [REG(si)]
    fst dword [REG(si)]                ; offset ← offset + offset_delta

.loop_init:
    mov al, I_MIN

; for u = I_MIN to I_MAX
u_loop_start:
    mov [i], ax

u_loop:
    pusha
calculate_uv_values:
.v:
    mov REG(di), f_v
    fst dword [REG(di)]                ; v ← offset
.v_step:
    fldpi
    fidiv word [i]                     ; v_step ← π / i
.v_step_2x:
    fld st0
    fadd st0, st0                      ; 2 v_step ← 2π / i
    fxch
.u:
    fld st0
    fimul word [focal_length]          ; u ← v_step × focal_length
    fld st0
    frndint                            ; snap to integer for a cylindrical effect
.u_int:
    fist word [u_int]                  ; checkerboard_u ← ⌊u⌋

.u_combined:
    fsub st0, st1
    fld st4
    fsin
    fabs
    fmulp st1, st0
    faddp st1, st0                     ; u ← u + (⌊u⌋ - u) × |sin(offset)|

.calculate_light:
    fld st0
    fadd dword [attenuation_a]
    fdivr dword [attenuation_b]
    fistp word [light]                 ; light ← b / (a + u)

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
    mov dl, al

v_loop:
.increment_v:
    fld st2
    fadd dword [REG(di)]
    fst dword [REG(di)]                ; v ← v + 2 v_step
.checkerboard_v:
    fld st0
    fdiv dword [checkerboard_size]
    fistp word [v_int]                 ; checkerboard_v ← ⌊v / checkerboard_size⌋
.increment_px_py:                      ; double v rotation
    fadd dword [REG(si)]
    fsincos
    fsubp st3, st0                     ; py ← py - cos(v + offset)
    fsubp st1, st0                     ; px ← px - sin(v + offset)
    fist word [px_int]
    fxch
    fist word [py_int]
    fxch

update_image:
.map_to_screen:
    mov ax, [py_int]
    imul ax, REAL_SCREEN_WIDTH
    add ax, [px_int]
    add ax, CENTER_OFFSET
    mov bx, ax
.apply_pattern:
    mov al, [u_int]
    xor al, [v_int]
    and al, 0x01
    shl al, 2
    inc al                             ; color ← 4 (checkerboard_u ⊕ checkerboard_v) + 1
.apply_lighting:
    pusha
    mul word [light]

.draw_pixel:
    mov ah, al
    mov MEM(REG(bx)), ax               ; write two pixels for a thicker spiral

overlay:
    shr al, 3
    mov cl, 2
.multi_draw:
    shl bx, 1
    add bx, 0xFD01
    neg bx

    shr al, 1
    add al, MEM(REG(bx))
    jno .draw_overlay_pixel

    mov al, 0xFF
.draw_overlay_pixel:
    mov ah, al
    mov MEM(REG(bx)), ax
; mov MEM(REG(bx) + REAL_SCREEN_WIDTH), ax
    loop .multi_draw

v_loop_end:
    popa
    dec dl
    jnz v_loop
v_loop_exit:
    popa
    fstp st0
    fstp st0
    fstp st0
; end for v

u_loop_exit:
    inc al
    cmp al, I_MAX + 1
    jb u_loop_start
; end for u

draw_exit:
    fstp st0
    popa
    ret

    %include "core/consts.asm"
    %include "core/vars.asm"
