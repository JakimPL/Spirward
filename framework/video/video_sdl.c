#include <SDL2/SDL.h>
#include <stdlib.h>
#include <string.h>
#include "video.h"

extern void set_palette(void);
extern unsigned char palette_data[768];

static SDL_Window *window = NULL;
static SDL_Renderer *renderer = NULL;
static SDL_Texture *texture = NULL;
static Uint32 *pixels = NULL;

void get_color(unsigned char color, unsigned char rgb[3]) {
    rgb[0] = palette_data[color * 3 + 0] << 2;
    rgb[1] = palette_data[color * 3 + 1] << 2;
    rgb[2] = palette_data[color * 3 + 2] << 2;
}

int video_init(void) {
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        return -1;
    }

    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest");
    SDL_SetHint(SDL_HINT_RENDER_DRIVER, "opengl");

    window = SDL_CreateWindow(
        "Spirward",
        SDL_WINDOWPOS_CENTERED,
        SDL_WINDOWPOS_CENTERED,
        SCREEN_WIDTH * SDL_SCALER,
        SCREEN_HEIGHT * SDL_SCALER,
        SDL_WINDOW_SHOWN | SDL_WINDOW_RESIZABLE
    );

    if (!window) {
        SDL_Quit();
        return -1;
    }

    renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!renderer) {
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    SDL_RenderSetLogicalSize(renderer, SCREEN_WIDTH, SCREEN_HEIGHT);

    texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, SCREEN_WIDTH, SCREEN_HEIGHT);
    if (!texture) {
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    pixels = (Uint32 *) malloc(SCREEN_WIDTH * SCREEN_HEIGHT * sizeof(Uint32));
    if (!pixels) {
        SDL_DestroyTexture(texture);
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    set_palette();
    memset(pixels, 0, SCREEN_WIDTH * SCREEN_HEIGHT * sizeof(Uint32));

    return 0;
}

void video_update_from_buffer(unsigned char *buffer) {
    for (unsigned int i = 0; i < SCREEN_WIDTH * SCREEN_HEIGHT; i++) {
        unsigned char rgb[3];
        get_color(buffer[i], rgb);
        pixels[i] = 0xFF000000 | (rgb[0] << 16) | (rgb[1] << 8) | rgb[2];
    }
}

void video_present(void) {
    unsigned char rgb[3];
    SDL_UpdateTexture(texture, NULL, pixels, SCREEN_WIDTH * sizeof(Uint32));
    get_color(0, rgb);
    SDL_SetRenderDrawColor(renderer, rgb[0], rgb[1], rgb[2], 255);
    SDL_RenderClear(renderer);
    SDL_RenderCopy(renderer, texture, NULL, NULL);
    SDL_RenderPresent(renderer);
}

void video_handle_resize(void) {
    SDL_RenderSetLogicalSize(renderer, SCREEN_WIDTH, SCREEN_HEIGHT);
}

void video_toggle_fullscreen(void) {
    if (video_is_fullscreen()) {
        SDL_SetWindowFullscreen(window, 0);
    } else {
        SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN_DESKTOP);
    }
}

int video_is_fullscreen(void) {
    Uint32 flags = SDL_GetWindowFlags(window);
    return (flags & SDL_WINDOW_FULLSCREEN_DESKTOP) != 0;
}

void video_cleanup(void) {
    if (pixels) {
        free(pixels);
    }
    if (texture) {
        SDL_DestroyTexture(texture);
    }
    if (renderer) {
        SDL_DestroyRenderer(renderer);
    }
    if (window) {
        SDL_DestroyWindow(window);
    }
    SDL_Quit();
}
