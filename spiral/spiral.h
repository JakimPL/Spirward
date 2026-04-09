#ifndef SPIRAL_H
#define SPIRAL_H

#include <stdbool.h>
#include "video.h"

#define M_PI 3.14159265358979323846

#define SCREEN_WIDTH 160
#define SCREEN_HEIGHT 100

extern short color;
extern unsigned short array_index;
extern unsigned char image[REAL_SCREEN_WIDTH * REAL_SCREEN_HEIGHT];

extern void draw();
extern void video_set_pixel(int x, int y, unsigned char color);
extern void video_clear_screen(unsigned char color);

void draw_pixel();

#endif
