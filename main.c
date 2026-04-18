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
            if (x >= 0 && x < SCREEN_WIDTH && y >= 0 && y < SCREEN_HEIGHT) {
                video_set_pixel(x, y, color);
            }
        }
    }
}

void frame() {
    draw();
    video_update_from_buffer(image);
    video_present();
}

#ifndef __DJGPP__
void redraw_current_frame() {
    video_handle_resize();
    video_update_from_buffer(image);
    video_present();
}

int handle_escape_key() {
    if (video_is_fullscreen()) {
        video_toggle_fullscreen();
        return 1;
    }
    return 0;
}

void handle_fullscreen_toggle_key(SDL_Keycode key) {
    if (key == SDLK_F11 || key == SDLK_f) {
        video_toggle_fullscreen();
    }
}

void handle_window_resize_event() {
    redraw_current_frame();
}

void handle_window_maximize_event() {
    if (!video_is_fullscreen()) {
        video_toggle_fullscreen();
    }
}

void handle_window_event(SDL_WindowEvent *window_event) {
    if (window_event->event == SDL_WINDOWEVENT_SIZE_CHANGED ||
        window_event->event == SDL_WINDOWEVENT_EXPOSED) {
        handle_window_resize_event();
    } else if (window_event->event == SDL_WINDOWEVENT_MAXIMIZED) {
        handle_window_maximize_event();
    }
}

int process_event(SDL_Event *event) {
    if (event->type == SDL_QUIT) {
        return 0;
    }
    if (event->type == SDL_KEYDOWN) {
        if (event->key.keysym.sym == SDLK_ESCAPE) {
            return handle_escape_key();
        }
        handle_fullscreen_toggle_key(event->key.keysym.sym);
    }
    if (event->type == SDL_WINDOWEVENT) {
        handle_window_event(&event->window);
    }
    return 1;
}
#endif

int main(int, char **) {
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
            running = process_event(&event);
        }

        frame();
        SDL_Delay(16);
    }
#endif

    video_cleanup();
    return 0;
}
