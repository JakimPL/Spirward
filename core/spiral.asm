    section .text
draw:

clear_buffers:
.clear_video_buffer:
    %ifdef DOS
    push VIDEO_MEMORY_SEGMENT
    pop es

    xor di, di
    xor ax, ax
    mov cx, VIDEO_BUFFER_SIZE
    rep stosw
    %endif
    %ifdef LINUX
    mov edi, image
    xor eax, eax
    mov ecx, BUFFER_SIZE
    rep stosb
    %endif

draw_spiral:
    pusha
.increment_offset:
    fld1
    fidiv word [focal_length]          ; offset_delta ← 1 / focal_length
    %ifdef DOS
    mov si, offset
    fadd dword [si]
    fst dword [si]                     ; offset ← offset + offset_delta
    %endif
    %ifdef LINUX
    mov esi, offset
    fadd dword [esi]
    fst dword [esi]                    ; offset ← offset + offset_delta
    %endif
.loop_init:
    mov al, U_MIN

; for u = U_MIN to U_MAX
u_loop_start:
    mov [i], ax

u_loop:
    pusha
calculate_uv_values:
.v:
    %ifdef DOS
    mov di, f_v
    fst dword [di]                     ; v ← offset
    %endif
    %ifdef LINUX
    mov edi, f_v
    fst dword [edi]                    ; v ← offset
    %endif
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
; frndint                            ; snap to integer for a cylindrical effect
.u_int:
    fist word [u_int]                  ; checkerboard_u ← ⌊u⌋
.depth:
    fld st0
    fmul st0, st0                      ; depth ← u²

.calculate_light:
    fiadd word [attenuation_a]
    fidivr word [attenuation_b]
    fistp word [light]                 ; light ← b / (a + depth)

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
    mov cl, al

v_loop:
.increment_v:
    fld st2
    %ifdef DOS
    fadd dword [di]
    fst dword [di]                     ; v ← v + 2 v_step
    %endif
    %ifdef LINUX
    fadd dword [edi]
    fst dword [edi]                    ; v ← v + 2 v_step
    %endif
.checkerboard_v:
    fld st0
    fdiv dword [checkerboard_size]
    fistp word [v_int]                 ; checkerboard_v ← ⌊v / checkerboard_size⌋
.increment_px_py:                      ; double v rotation
    %ifdef DOS
    fadd dword [si]
    %endif
    %ifdef LINUX
    fadd dword [esi]
    %endif
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
; cmp ax, REAL_SCREEN_HEIGHT ; remove?
; jae .exit
    imul ax, REAL_SCREEN_WIDTH
    add ax, [px_int]
; cmp bl, REAL_SCREEN_WIDTH
; jae .exit
    add ax, CENTER_OFFSET
    mov bx, ax
    %ifdef LINUX
    mov [array_index], ax
    %endif
.apply_pattern:
    mov al, [u_int]
    xor al, [v_int]
    and al, 0x01
    shl al, 2
    inc al           ; color ← 4 (checkerboard_u ⊕ checkerboard_v) + 1
.apply_lighting:
    mul word [light]
    %ifdef DOS
    mov ah, al
    mov [es:bx], ax
    %endif
    %ifdef LINUX
    mov [color], ax
.draw_pixel:
    push cx
    call draw_pixel
    pop cx
    %endif

    loop v_loop
v_loop_exit:
    popa
    fstp st0
    fstp st0
    fstp st0
; end for v

u_loop_exit:
    inc al
    cmp al, U_MAX + 1
    jb u_loop_start
; end for u

draw_exit:
    fstp st0
    popa
    ret

    %include "core/consts.asm"
    %include "core/vars.asm"
