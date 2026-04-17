#include "video.h"
#include <stddef.h>
#include <dos.h>
#include <sys/nearptr.h>
#include <string.h>
#include <pc.h>

#define VIDEO_MEMORY 0xA0000

extern void set_palette(void);
static unsigned char *vga_memory = NULL;

static void set_graphics_mode(int mode) {
    union REGS regs;
    regs.w.ax = mode;
    int86(0x10, &regs, &regs);
}

int video_init(void) {
    set_graphics_mode(0x0013);
    set_palette();

    /* Enable near pointers for direct VGA access */
    if (__djgpp_nearptr_enable() == 0) {
        return -1;
    }

    vga_memory = (unsigned char *) (VIDEO_MEMORY + __djgpp_conventional_base);
    memset(vga_memory, 0, SCREEN_WIDTH * SCREEN_HEIGHT);

    return 0;
}

void video_set_pixel(int x, int y, unsigned char color) {
    if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT) {
        vga_memory[y * SCREEN_WIDTH + x] = color;
    }
}

void video_present(void) {
}

void video_cleanup(void) {
    __djgpp_nearptr_disable();
    set_graphics_mode(0x0003);
}
