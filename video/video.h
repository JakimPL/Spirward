#ifndef VIDEO_H
#define VIDEO_H

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

int video_init(void);
void video_set_pixel(int x, int y, unsigned char color);
void video_present(void);
void video_cleanup(void);

#endif
