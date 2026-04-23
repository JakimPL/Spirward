#ifndef VIDEO_H
#define VIDEO_H

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

#ifndef DOS
#define SDL_SCALER 4
#define BUFFER_SIZE 65536

extern short color;
extern unsigned char image[BUFFER_SIZE];
extern void draw();
#endif

int video_init(void);
void video_update_from_buffer(unsigned char *buffer);
void video_present(void);
void video_handle_resize(void);
void video_toggle_fullscreen(void);
int video_is_fullscreen(void);
void video_cleanup(void);

#endif
