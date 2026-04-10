#ifndef VIDEO_H
#define VIDEO_H

#define REAL_SCREEN_WIDTH 320
#define REAL_SCREEN_HEIGHT 200

#define SDL_SCALER 4

int video_init(void);
void video_set_pixel(int x, int y, unsigned char color);
void video_clear_screen(unsigned char color);
void video_present(void);
void video_cleanup(void);

#endif
