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
        SCREEN_WIDTH * 2, /* 2x scaling for visibility */
        SCREEN_HEIGHT * 2,
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
    if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT) {
        SDL_Rect rect = {x * 2, y * 2, 2, 2};
        Uint32 pixel = SDL_MapRGB(surface->format, color, color, color);
        SDL_FillRect(surface, &rect, pixel);
    }
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
