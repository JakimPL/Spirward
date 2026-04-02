    global clear_buffers
    global draw_spiral
    global do_u_step
    global do_v_step
    global increment_offset
    global calculate_uv_values
    global calculate_initial_point
    global increment_point
    global update_image

    global focal_length
    global attenuation
    global checkerboard_dark
    global checkerboard_size
    global two_pi
    global half_spiral_screen_width
    global half_spiral_screen_height
    global color
    global light
    global depth
    global px
    global py
    global u
    global v
    global v_step
    global offset
    global i
    global array_index
    global depth_buffer

    SCREEN_WIDTH equ 160
    SCREEN_HEIGHT equ 100
    HALF_SCREEN_WIDTH equ SCREEN_WIDTH / 2
    HALF_SCREEN_HEIGHT equ SCREEN_HEIGHT / 2

    U_STEPS equ SCREEN_HEIGHT * 2
    BUFFER_SIZE equ SCREEN_WIDTH * SCREEN_HEIGHT

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
    ret

draw_spiral:
    mov word [i], 0x01
.loop_start:
    cmp word [i], U_STEPS
    jg .loop_end
    call do_u_step
    inc word [i]
    jmp .loop_start
.loop_end:
    ret

do_u_step:
    pusha
calculate_uv_values:
.v:
    fldz
    fstp dword [v]
.v_step:                     ; v_step ← 2π / i
    fld dword [two_pi]
    fidiv word [i]
    fst dword [v_step]
.u:                          ; u ← v_step × focal_length
    fmul dword [focal_length]
    fst dword [u]
.depth:                      ; depth ← u * u
    fld st0
    fmul st0
.check_depth:
    ficom word [max_depth]
    fstsw ax
    sahf
    jae update_image.exit_pop
.save_depth:
    fistp word [depth]
.calculate_light:
    fmul dword [attenuation]
    fld1
    faddp
    fld dword [w255]
    fdivr
    fstp dword [light]
calculate_initial_point:
    fld dword [u]
    fadd dword [offset]
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
    call update_image
    call increment_point
    popa
    ret

update_image:
    pusha
.get_index:
    fld dword [px]
    frndint
    fistp word [px_int]
    fld dword [py]
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
.check_depth:
; %ifdef DOS
; xor bx, bx
; %endif
; %ifdef LINUX
; xor ebx, ebx
; %endif
; mov bx, [array_index]
; %ifdef DOS
; shl bx, 1
; %endif
; fld dword [depth]
; %ifdef DOS
; ficom word [depth_buffer + bx]
; %endif
; %ifdef LINUX
; ficom word [depth_buffer + 2 * ebx]
; %endif
; fstsw ax
; sahf
; jae .exit_pop
; %ifdef DOS
; fistp dword [depth_buffer + bx]
; %endif
; %ifdef LINUX
; fistp dword [depth_buffer + 2 * ebx]
; %endif
.calculate_color:
.load_uv:
    fld dword [u]
    fdiv dword [checkerboard_size]
    fistp word [u_int]
    fld dword [v]
    fdiv dword [checkerboard_size]
    fistp word [v_int]
.apply_pattern:
    xor cx, cx
    mov cx, [u_int]
    xor cx, [v_int]
    and cx, 0x01
    mov [color], cx
.apply_lighting:
    fild word [color]
    fadd dword [checkerboard_dark]
    fmul dword [light]
    fistp word [color]
.draw_pixel:
    call draw_pixel
    jmp .exit
.exit_pop:
    fstp st0
.exit:
    popa
    ret

increment_offset:
    fld1
    fdiv dword [focal_length]
    fadd dword [offset]
    fst dword [offset]
    ret

increment_point:
    fld dword [px]
    fld dword [py]
    fld dword [v]
.increment_v:
    fadd dword [v_step]
    fst dword [v]
    fadd dword [offset]
.increment_px_py:
    fsincos
    fsubp st3, st0           ; px - cos(v)
    fsubp                    ; py - sin(v)
    fstp dword [py]
    fstp dword [px]
    ret

    %include "core/consts.asm"
    %include "core/vars.asm"
