#include "runtime.h"

#ifdef __DJGPP__
#include <conio.h>
#include <time.h>
#else
#include <SDL2/SDL.h>
#include "../video/video.h"
#endif

#ifndef __DJGPP__
static void redraw_current_frame(void (*frame_fn)(void)) {
    video_handle_resize();
    frame_fn();
}

static int handle_escape_key(void) {
    if (video_is_fullscreen()) {
        video_toggle_fullscreen();
        return 1;
    }
    return 0;
}

static void handle_fullscreen_toggle_key(SDL_Keycode key) {
    if (key == SDLK_F11 || key == SDLK_f) {
        video_toggle_fullscreen();
    }
}

static void handle_window_event(SDL_WindowEvent *window_event, void (*frame_fn)(void)) {
    if (window_event->event == SDL_WINDOWEVENT_SIZE_CHANGED || window_event->event == SDL_WINDOWEVENT_EXPOSED) {
        redraw_current_frame(frame_fn);
    }
}

static int process_event(SDL_Event *event, void (*frame_fn)(void)) {
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
        handle_window_event(&event->window, frame_fn);
    }
    return 1;
}
#endif

void run(void (*frame_fn)(void)) {
#ifdef __DJGPP__
    uclock_t frame_start, frame_time;
    const uclock_t frame_delay = UCLOCKS_PER_SEC / 60;

    while (!kbhit()) {
        frame_start = uclock();
        frame_fn();
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
            running = process_event(&event, frame_fn);
        }

        frame_fn();
        SDL_Delay(16);
    }
#endif
}