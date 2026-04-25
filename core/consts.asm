    I_MIN equ 1
    I_MAX equ 200                      ; COLOR_MAX = 5 * (I_MAX >> 4) < MAX_COLOR
    FOCAL_LENGTH equ 96                ; U_MIN = FOCAL_LENGTH * pi / I_MAX - 0.5 is almost an integer
    OVERLAY_RIGHT_SHIFT equ 3
