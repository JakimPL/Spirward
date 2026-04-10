#include "video.h"
#include <stddef.h>
#include <dos.h>
#include <sys/nearptr.h>
#include <string.h>
#include <pc.h>

/* Mode 13h framebuffer address */
#define VIDEO_MEMORY 0xA0000

static unsigned char *vga_memory = NULL;

static void set_graphics_mode(int mode) {
    union REGS regs;
    regs.w.ax = mode;
    int86(0x10, &regs, &regs);
}

static void set_grayscale_palette(void) {
    int i;
    for (i = 0; i < 256; i++) {
        /* VGA DAC uses 6-bit values (0-63) */
        int intensity = (i * 63) / 255;
        outportb(0x3C8, i);         /* Select palette index */
        outportb(0x3C9, intensity); /* Red */
        outportb(0x3C9, intensity); /* Green */
        outportb(0x3C9, intensity); /* Blue */
    }
}

int video_init(void) {
    set_graphics_mode(0x0013);
    set_grayscale_palette();

    /* Enable near pointers for direct VGA access */
    if (__djgpp_nearptr_enable() == 0) {
        return -1;
    }

    vga_memory = (unsigned char *) (VIDEO_MEMORY + __djgpp_conventional_base);
    memset(vga_memory, 0, REAL_SCREEN_WIDTH * REAL_SCREEN_HEIGHT);

    return 0;
}

void video_set_pixel(int x, int y, unsigned char color) {
    if (x >= 0 && x < REAL_SCREEN_WIDTH && y >= 0 && y < REAL_SCREEN_HEIGHT) {
        vga_memory[y * REAL_SCREEN_WIDTH + x] = color;
    }
}

void video_present(void) {
}

void video_cleanup(void) {
    __djgpp_nearptr_disable();
    set_graphics_mode(0x0003);
}
