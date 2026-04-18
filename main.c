#include "video.h"
#include "spiral.h"

#ifdef __DJGPP__
#include <conio.h>
#include <time.h>
#else
#include <SDL2/SDL.h>
#endif

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

void handle_window_event(SDL_WindowEvent *window_event) {
    if (window_event->event == SDL_WINDOWEVENT_SIZE_CHANGED || window_event->event == SDL_WINDOWEVENT_EXPOSED) {
        redraw_current_frame();
    }
}

int process_event(SDL_Event *event) {
    if (event->type == SDL_QUIT) {
        return 0;
    }
    if (event->type == SDL_KEYDOWN) {
        if (event->key.keysym.sym == SDLK_ESCAPE) {
            return handle_escape_key();
        } else {
            handle_fullscreen_toggle_key(event->key.keysym.sym);
        }
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
    uclock_t frame_start, frame_time;
    const uclock_t frame_delay = UCLOCKS_PER_SEC / 60;

    while (!kbhit()) {
        frame_start = uclock();
        frame();
        frame_time = uclock() - frame_start;
        if (frame_time < frame_delay) {
            uclock_t delay_end = uclock() + (frame_delay - frame_time);
            while (uclock() < delay_end && !kbhit()) {
                /* busy wait */
            }
        }
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
