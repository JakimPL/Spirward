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

    %include "core/spiral.asm"

    extern draw_pixel
    extern clear_screen
