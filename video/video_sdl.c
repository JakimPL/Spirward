#include "video.h"
#include <SDL2/SDL.h>
#include <stdlib.h>

extern void set_palette(void);
extern unsigned char palette_data[768];

static SDL_Window *window = NULL;
static SDL_Surface *surface = NULL;

void get_color(unsigned char color, unsigned char rgb[3]) {
    rgb[0] = palette_data[color * 3 + 0] << 2;
    rgb[1] = palette_data[color * 3 + 1] << 2;
    rgb[2] = palette_data[color * 3 + 2] << 2;
}

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

    set_palette();
    SDL_FillRect(surface, NULL, SDL_MapRGB(surface->format, 0, 0, 0));

    return 0;
}

void video_set_pixel(int x, int y, unsigned char color) {
    if (x >= 0 && x < REAL_SCREEN_WIDTH && y >= 0 && y < REAL_SCREEN_HEIGHT) {
        SDL_Rect rect = {x * SDL_SCALER, y * SDL_SCALER, SDL_SCALER, SDL_SCALER};
        unsigned char rgb[3];
        get_color(color, rgb);
        Uint32 pixel = SDL_MapRGB(surface->format, rgb[0], rgb[1], rgb[2]);
        SDL_FillRect(surface, &rect, pixel);
    }
}

void video_clear_screen(unsigned char color) {
    unsigned char rgb[3];
    get_color(color, rgb);
    Uint32 pixel = SDL_MapRGB(surface->format, rgb[0], rgb[1], rgb[2]);
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
