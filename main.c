#include "video.h"
#include "spiral.h"

#ifdef __DJGPP__
#include <conio.h>
#else
#include <SDL2/SDL.h>
#endif

void render() {
    for (int x = 0; x < SPIRAL_SCREEN_WIDTH; x++) {
        for (int y = 0; y < SPIRAL_SCREEN_HEIGHT; y++) {
            const int index = y * SPIRAL_SCREEN_WIDTH + x;
            const unsigned char color = image[index];
            video_set_pixel(2 * x, 2 * y, color);
            video_set_pixel(2 * x + 1, 2 * y, color);
            video_set_pixel(2 * x, 2 * y + 1, color);
            video_set_pixel(2 * x + 1, 2 * y + 1, color);
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

    frame();

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
