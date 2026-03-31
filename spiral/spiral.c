#include <math.h>
#include <stdio.h>

#include "spiral.h"

void draw_pixel() {
    unsigned char _x = (unsigned char) (array_index % SCREEN_WIDTH);
    unsigned char _y = (unsigned char) (array_index / SCREEN_WIDTH);
    image[2 * (_y * REAL_SCREEN_WIDTH + _x)] = (unsigned char) (color);
}

void clear_screen() {
    video_clear_screen(0);
}

void draw() {
    clear_buffers();
    draw_spiral();
}
