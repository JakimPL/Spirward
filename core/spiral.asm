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
    mov al, U_MIN
    xor ah, ah
.loop_start:
    mov [i], ax
    call do_u_step
    inc al
    cmp al, U_MAX + 1
    jb .loop_start
increment_offset:
    fld1
    fidiv word [focal_length]
    mov edi, offset
    fadd dword [edi]
    fstp dword [edi]
    popa
    ret

do_u_step:
    pusha
calculate_uv_values:
.v:
    fld dword [offset]       ; v ← offset
    fstp dword [f_v]         ; v ← 0
.v_step:
    fldpi
    fidiv word [i]
    fst dword [f_v_step]     ; v_step ← π / i
.u:
    fimul word [focal_length] ; u ← v_step × focal_length
; frndint ; snap to integer for a cylindrical effect
.u_int:
    fld st0
    fdiv dword [checkerboard_size]
    fistp word [u_int]       ; checkerboard_u ← floor(u / checkerboard_size)
.depth:
    fld st0
    fmul st0, st0            ; depth ← u * u

.calculate_light:
    fiadd word [attenuation_a]
    fidivr word [attenuation_b]
    fistp word [light]       ; light ← b / (a + u * u)

calculate_initial_point:
    fadd dword [offset]      ; u ← u + offset
.sincos:
    mov edi, f_v_step
    fsincos
.py:
    fdiv dword [edi]         ; py ← sin u / v_step
.px:
    fxch st0, st1
    fdiv dword [edi]         ; px ← cos u / v_step
    fxch st0, st1
.v:
    mov cl, byte [i]
.v_loop:
    call do_v_step
    loop .v_loop
.exit:
    popa
    fstp st0
    fstp st0
    ret

do_v_step:
    pusha
.increment_v:
    fld dword [f_v_step]
    fadd st0, st0
    fadd dword [f_v]
    fst dword [f_v]          ; v ← v + 2 * v_step
.checkerboard_v:
    fld st0
    fdiv dword [checkerboard_size]
    fistp word [v_int]       ; checkerboard_v ← floor(v / checkerboard_size)
.increment_px_py:
    fsincos
    fsubp st3, st0           ; py ← py - sin(v)
    fsubp                    ; px ← px - cos(v)
    fist word [px_int]
    fxch st0, st1
    fist word [py_int]
    fxch st0, st1

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
.apply_lighting:
    mul word [light]
    %ifdef DOS
    mov ah, al
    mov [es:bx], ax
    %endif
    %ifdef LINUX
    mov [color], ax
.draw_pixel:
    call draw_pixel
    %endif
.exit:
    popa
    ret

    %include "core/consts.asm"
    %include "core/vars.asm"
