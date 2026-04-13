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
            unsigned short array_index = y * REAL_SCREEN_WIDTH + x;
            unsigned char color = image[array_index];
            if (x >= 0 && x < REAL_SCREEN_WIDTH && y >= 0 && y < REAL_SCREEN_HEIGHT) {
                video_set_pixel(x, y, color);
            }
        }
    }
}

void frame() {
    draw();
    render();
    video_present();
}

int main(int, char**) {
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
    offset = 0.0f;
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
