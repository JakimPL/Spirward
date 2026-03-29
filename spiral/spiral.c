#include <math.h>
#include <stdio.h>

#include "spiral.h"

float image[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];
float depth_buffer[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];

int get_index(int px, int py) {
    return py * SPIRAL_SCREEN_WIDTH + px;
}

void update_depth_buffer(float u, float v, int px, int py, float depth) {
    const int index = get_index(px, py);
    if (depth < depth_buffer[index]) {
        calculate_checkerboard_value();
        depth_buffer[index] = depth;
        image[index] = light * checkerboard_value;
    }
}

void clear_buffers() {
    for (int i = 0; i < SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT; i++) {
        image[i] = 0.0f;
        depth_buffer[i] = 1e30f;
    }
}

void line() {
    calculate_uv_values();
    calculate_initial_point();

    for (int k = 0; k < i; ++k) {
        if (px >= 0.0f && px < SPIRAL_SCREEN_WIDTH && py >= 0.0f &&
            py < SPIRAL_SCREEN_HEIGHT) {
            update_depth_buffer(u, v, px, py, depth);
        }

        increment_point();
    }
}

void loop() {
    for (i = 1; i <= U_STEPS; ++i) {
        line();
    }
}

void draw() {
    clear_buffers();
    loop();
}
