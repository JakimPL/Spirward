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
    fadd dword [offset]
    fstp dword [offset]
    popa
    ret

do_u_step:
    pusha
calculate_uv_values:
.v:
    fldz
    fstp dword [f_v]         ; v ← 0
.v_step:
    fldpi
    fadd st0, st0
    fidiv word [i]
    fst dword [f_v_step]     ; v_step ← 2π / i
.u:
    fimul word [focal_length] ; u ← v_step × focal_length
; frndint
; fst dword [f_u]
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
    fsincos
.py:
    fadd st0, st0            ; optimize 2x
    fdiv dword [f_v_step]
    fstp dword [f_py]        ; py ← 2 sin u / v_step
.px:
    fadd st0, st0
    fdiv dword [f_v_step]
    fstp dword [f_px]        ; px ← 2 cos u / v_step
.v:
    mov cl, byte [i]
.v_loop:
    call do_v_step
    loop .v_loop
.exit:
    popa
    ret

do_v_step:
    pusha
increment_point:
    fld dword [f_px]
    fld dword [f_py]
    fld dword [f_v]
.increment_v:
    fadd dword [f_v_step]
    fst dword [f_v]
    fadd dword [offset]      ; v ← v + v_step + offset
.checkerboard_v:
    fld st0
    fdiv dword [checkerboard_size]
    fistp word [v_int]       ; checkerboard_v ← floor(v / checkerboard_size)
.increment_px_py:
    fsincos
    fsubp st3, st0           ; px ← px - cos(v)
    fsubp                    ; py ← py - sin(v)
    fst dword [f_py]
    fistp word [py_int]
    fst dword [f_px]
    fistp word [px_int]

update_image:
    %ifdef DOS
.map_to_screen:
    mov ax, [py_int]
; cmp ax, REAL_SCREEN_HEIGHT ; remove?
; jae .exit
    imul ax, REAL_SCREEN_WIDTH
    add ax, [px_int]
    ; add bx, HALF_SCREEN_WIDTH
; cmp bl, SCREEN_WIDTH
; jae .exit
    ; shl ax, 1
    add ax, 32160
    mov bx, ax
    %endif
    %ifdef LINUX
.map_to_screen:
    mov ax, [py_int]
    add ax, HALF_SCREEN_HEIGHT
    cmp ax, SCREEN_HEIGHT
    jae .exit
    imul ax, SCREEN_WIDTH
    mov bx, [px_int]
    add bx, HALF_SCREEN_WIDTH
    cmp bx, SCREEN_WIDTH
    jae .exit
    add ax, bx
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
