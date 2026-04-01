#include <math.h>
#include <stdio.h>

#include "spiral.h"

void draw_pixel() {
    image[array_index] = (unsigned char) (color);
}

void clear_screen() {
    video_clear_screen(0);
}

void draw() {
    clear_buffers();
    draw_spiral();
}
