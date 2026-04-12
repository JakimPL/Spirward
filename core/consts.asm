    global focal_length
    global checkerboard_dark
    global checkerboard_size
    global two_pi
    global half_spiral_screen_width
    global half_spiral_screen_height

    REAL_SCREEN_WIDTH equ 320
    REAL_SCREEN_HEIGHT equ 200
    VIDEO_BUFFER_SIZE equ REAL_SCREEN_WIDTH * REAL_SCREEN_HEIGHT

    MAX_COLOR equ 0x3F
    CENTER_OFFSET equ 0x7DA0
    MAGIC_NUMBER equ 0x5D01
    BUFFER_SIZE equ 0x10000

    SCREEN_WIDTH equ 160
    SCREEN_HEIGHT equ 100
    HALF_SCREEN_WIDTH equ SCREEN_WIDTH / 2
    HALF_SCREEN_HEIGHT equ SCREEN_HEIGHT / 2

    I_MIN equ 20
    I_MAX equ 220                      ; COLOR_MAX = 5 * ((I_MAX - I_MIN) >> 4) = 60 < MAX_COLOR
    FOCAL_LENGTH equ 176               ; U_MIN = 176π / (2 * I_MAX) - 0.5 ≈ 2.01 is almost an integer

    CYLINDRICAL_EFFECT_DELAY equ 138   ; π × FOCAL_LENGTH / 4
    OVERLAY_RIGHT_SHIFT equ 3

    %ifdef DOS
    VIDEO_MODE_13H equ 0x13
    TEXT_MODE_3H equ 0x03
    BIOS_VIDEO_INTERRUPT equ 0x10
    KEYBOARD_INTERRUPT equ 0x16
    VIDEO_MEMORY_SEGMENT equ 0xA000
    PALETTE_INDEX_PORT equ 0x03C8
    PALETTE_DATA_PORT equ 0x03C9

    VGA_INPUT_STATUS_REGISTER equ 0x3DA
    VERTICAL_RETRACE_STATUS_BIT equ 0x08
    %endif
