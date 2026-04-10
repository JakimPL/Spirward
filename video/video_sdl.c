#include "video.h"
#include <SDL2/SDL.h>
#include <stdlib.h>

static SDL_Window *window = NULL;
static SDL_Surface *surface = NULL;

int video_init(void) {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        return -1;
    }

    window = SDL_CreateWindow(
        "Spiral Renderer",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        REAL_SCREEN_WIDTH * SDL_SCALER,
        REAL_SCREEN_HEIGHT * SDL_SCALER,
        SDL_WINDOW_SHOWN
    );

    if (!window) {
        SDL_Quit();
        return -1;
    }

    surface = SDL_GetWindowSurface(window);
    if (!surface) {
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    /* Clear to black */
    SDL_FillRect(surface, NULL, SDL_MapRGB(surface->format, 0, 0, 0));

    return 0;
}

void video_set_pixel(int x, int y, unsigned char color) {
    if (x >= 0 && x < REAL_SCREEN_WIDTH && y >= 0 && y < REAL_SCREEN_HEIGHT) {
        SDL_Rect rect = {x * SDL_SCALER, y * SDL_SCALER, SDL_SCALER, SDL_SCALER};
        unsigned char palette_color = 4 * color;
        Uint32 pixel = SDL_MapRGB(surface->format, palette_color, palette_color, palette_color);
        SDL_FillRect(surface, &rect, pixel);
    }
}

void video_clear_screen(unsigned char color) {
    unsigned char palette_color = 4 * color;
    Uint32 pixel = SDL_MapRGB(surface->format, palette_color, palette_color, palette_color);
    SDL_FillRect(surface, NULL, pixel);
}

void video_present(void) {
    SDL_UpdateWindowSurface(window);
}

void video_cleanup(void) {
    if (window) {
        SDL_DestroyWindow(window);
    }
    SDL_Quit();
}
