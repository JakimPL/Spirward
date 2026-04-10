#ifndef SPIRAL_H
#define SPIRAL_H

#include <stdbool.h>
#include "video.h"

#define SCREEN_WIDTH 160
#define SCREEN_HEIGHT 100
#define BUFFER_SIZE 65536

extern short color;
extern unsigned short array_index;
extern unsigned char image[BUFFER_SIZE];

extern void draw();
extern void video_set_pixel(int x, int y, unsigned char color);
extern void video_clear_screen(unsigned char color);

#endif
