#include "video.h"
#include "spiral.h"

#ifdef __DJGPP__
#include <conio.h>
#else
#include <SDL2/SDL.h>
#endif

void render() {
    for (int y = 0; y < SCREEN_HEIGHT; y++) {
        for (int x = 0; x < SCREEN_WIDTH; x++) {
            unsigned short array_index = y * SCREEN_WIDTH + x;
            unsigned char color = image[array_index];
            for (int dx = -1; dx <= 1; dx++) {
                for (int dy = -1; dy <= 1; dy++) {
                    int px = 2 * x + dx;
                    int py = 2 * y + dy;
                    if (px >= 0 && px < REAL_SCREEN_WIDTH && py >= 0 && py < REAL_SCREEN_HEIGHT) {
                        video_set_pixel(px, py, color);
                    }
                }
            }
            image[array_index] = 0;
        }
    }
}

void frame() {
    draw();
    render();
    video_present();
    increment_offset();
}

int main(void) {
    if (video_init() != 0) {
        return 1;
    }

#ifdef __DJGPP__
    while (!kbhit()) {
        frame();
    }
    getch();
#else
    SDL_Event event;
    int running = 1;
    while (running) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT ||
                (event.type == SDL_KEYDOWN && event.key.keysym.sym == SDLK_ESCAPE)) {
                running = 0;
            }
        }

        frame();
        SDL_Delay(16); /* ~60 FPS */
    }
#endif

    video_cleanup();
    return 0;
}
