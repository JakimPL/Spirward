#include <math.h>
#include <stdio.h>

#include "spiral.h"

float image[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];
float depth_buffer[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];

void update_depth_buffer() {
    if (!(px >= 0.0f && px < SPIRAL_SCREEN_WIDTH && py >= 0.0f &&
          py < SPIRAL_SCREEN_HEIGHT)) {
        return;
    }

    get_index();
    if (depth < depth_buffer[array_index]) {
        calculate_checkerboard_value();
        depth_buffer[array_index] = depth;
        image[array_index] = light * checkerboard_value;
    }
}

void clear_buffers() {
    for (int array_index = 0; array_index < SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT; array_index++) {
        image[array_index] = 0.0f;
        depth_buffer[array_index] = 1e30f;
    }
}

void do_v_step() {
    update_depth_buffer();
    increment_point();
}

void do_u_step() {
    calculate_uv_values();
    calculate_initial_point();

    for (int k = 0; k < i; ++k) {
        do_v_step();
    }
}

void loop() {
    for (i = 1; i <= U_STEPS; ++i) {
        do_u_step();
    }
}

void draw() {
    clear_buffers();
    loop();
}
