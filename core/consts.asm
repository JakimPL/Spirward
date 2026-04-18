    global focal_length
    global checkerboard_dark
    global checkerboard_size
    global two_pi
    global half_spiral_screen_width
    global half_spiral_screen_height

    SCREEN_WIDTH equ 320
    SCREEN_HEIGHT equ 200
    VIDEO_BUFFER_SIZE equ SCREEN_WIDTH * SCREEN_HEIGHT

    MAX_COLOR equ 0x3F
    CENTER_OFFSET equ 0x83E0           ; shifted down to avoid overflow
    BUFFER_SIZE equ 0x10000

    I_MIN equ 1
    I_MAX equ 196                      ; COLOR_MAX = 5 × (I_MAX >> 4) < MAX_COLOR
    FOCAL_LENGTH equ 96                ; U_MIN = FOCAL_LENGTH × π / I_MAX - 0.5 is almost an integer

    OVERLAY_RIGHT_SHIFT equ 3

    %ifdef DOS
    VIDEO_MODE_13H equ 0x13
    TEXT_MODE_3H equ 0x03
    BIOS_VIDEO_INTERRUPT equ 0x10
    VIDEO_MEMORY_SEGMENT equ 0xA000
    PALETTE_INDEX_PORT equ 0x03C8
    PALETTE_DATA_PORT equ 0x03C9

    VGA_INPUT_STATUS_REGISTER equ 0x3DA
    VERTICAL_RETRACE_STATUS_BIT equ 0x08

    KEYBOARD_DATA_PORT equ 0x60

    %endif
