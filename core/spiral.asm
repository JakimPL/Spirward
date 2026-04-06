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
    mov ax, U_MIN
.loop_start:
    cmp al, U_MAX
    ja increment_offset
    mov word [i], ax
    call do_u_step
    inc al
    jmp .loop_start
increment_offset:
    fld1
    fdiv dword [focal_length]
    fadd dword [offset]
    fstp dword [offset]
    popa
    ret

do_u_step:
    pusha
calculate_uv_values:
.v:
    fldz
    fstp dword [f_v]
.v_step:                     ; v_step ← 2π / i
    fld dword [two_pi]       ; fldpi?
    fidiv word [i]
    fstp dword [f_v_step]
.u:                          ; u ← v_step × focal_length
    fld dword [f_v_step]
    fmul dword [focal_length] ; TODO: reduce precision
; frndint
    fst dword [f_u]
    fld st0
    fld st0
    fdiv dword [checkerboard_size]
    fistp word [u_int]
.depth:                      ; depth ← u * u
    fmul st0, st0
    fistp word [depth]

.calculate_light:
    mov ax, [depth]
    shr ax, 2
    add ax, 3
    mov bx, 1024
    xchg ax, bx
    xor dx, dx
    div bx
    mov word [light], ax

calculate_initial_point:
    fadd dword [offset]
.sincos:
    fsincos
.py:
    fadd st0, st0            ; optimize 2x
    fdiv dword [f_v_step]
    fstp dword [f_py]
.px:
    fadd st0, st0
    fdiv dword [f_v_step]
    fstp dword [f_px]
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
    fadd dword [offset]
.checkerboard_v:
    fld st0
    fdiv dword [checkerboard_size]
    fistp word [v_int]
.increment_px_py:
    fsincos
    fsubp st3, st0           ; px - cos(v)
    fsubp                    ; py - sin(v)
    fst dword [f_py]
    fistp word [py_int]
    fst dword [f_px]
    fistp word [px_int]
update_image:
    %ifdef DOS
.map_to_screen:
    mov ax, [py_int]
    add ax, SCREEN_HEIGHT
; cmp ax, REAL_SCREEN_HEIGHT ; remove?
; jae .exit
    imul ax, SCREEN_WIDTH
    mov bx, [px_int]
    add bx, HALF_SCREEN_WIDTH
; cmp bl, SCREEN_WIDTH
; jae .exit
    add ax, bx
    shl ax, 1
    mov [array_index], ax
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
    xor ax, ax
    mov al, [u_int]
    xor al, [v_int]
    and al, 0x01
    mov [color], ax
.apply_lighting:
    mov bx, word [light]
    mul bx
    mov word [color], ax
.draw_pixel:
    call draw_pixel
.exit:
    popa
    ret

    %include "core/consts.asm"
    %include "core/vars.asm"
