#include "video.h"
#include "spiral.h"

#ifdef __DJGPP__
#include <conio.h>
#else
#include <SDL2/SDL.h>
#endif

void render() {
    for (int y = 0; y < REAL_SCREEN_HEIGHT; y++) {
        for (int x = 0; x < REAL_SCREEN_WIDTH; x++) {
            video_set_pixel(x, y, image[y * REAL_SCREEN_WIDTH + x]);
            image[y * REAL_SCREEN_WIDTH + x] = 0; /* Clear after rendering */
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
