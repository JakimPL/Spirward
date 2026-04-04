    section .text
clear_buffers:
    pusha
.clear_depth_buffer:
    %ifdef DOS
    mov di, depth_buffer
    %endif
    %ifdef LINUX
    mov edi, depth_buffer
    %endif
    mov ax, 0x7FFF
    mov cx, BUFFER_SIZE
    rep stosw
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
.exit:
    popa

draw_spiral:
    xor ax, ax
    mov al, 40
.loop_start:
    cmp al, U_STEPS
    ja .loop_end
    mov word [i], ax
    call do_u_step
    inc al
    jmp .loop_start
.loop_end:

increment_offset:
    fld1
    fdiv dword [focal_length]
    fadd dword [offset]
    fst dword [offset]
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
    fiadd word [half_spiral_screen_height]
    fstp dword [f_py]
.px:
    fadd st0, st0
    fdiv dword [f_v_step]
    fiadd word [half_spiral_screen_width]
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
update_image:
.get_index:
    fld dword [f_px]
    frndint
    fistp word [px_int]
    fld dword [f_py]
    frndint
    fistp word [py_int]
    mov ax, [py_int]
    imul ax, SCREEN_WIDTH
    add ax, [px_int]
    mov [array_index], ax
.check_bounds:
    cmp word [px_int], SCREEN_WIDTH
    jae .exit
    cmp word [py_int], SCREEN_HEIGHT
    jae .exit
.calculate_color:
.load_uv:
    fld dword [f_u]
    fdiv dword [checkerboard_size]
    fistp word [u_int]

    fld dword [f_v]
    fdiv dword [checkerboard_size]
    fistp word [v_int]

.apply_pattern:
    xor ax, ax
    mov ax, [u_int]
    xor ax, [v_int]
    and ax, 0x01
    mov [color], ax
.apply_lighting:
    mov bx, word [light]
    mul bx
    mov word [color], ax
.draw_pixel:
    call draw_pixel
    jmp .exit
.exit:
    popa

increment_point:
    fld dword [f_px]
    fld dword [f_py]
    fld dword [f_v]
.increment_v:
    fadd dword [f_v_step]
    fst dword [f_v]
    fadd dword [offset]
.increment_px_py:
    fsincos
    fsubp st3, st0           ; px - cos(v)
    fsubp                    ; py - sin(v)
    fstp dword [f_py]
    fstp dword [f_px]
    ret

    %include "core/consts.asm"
    %include "core/vars.asm"
