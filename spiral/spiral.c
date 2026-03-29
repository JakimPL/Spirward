#include <math.h>
#include <stdio.h>

#include "spiral.h"

void clear_buffers() {
    for (int array_index = 0; array_index < SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT; array_index++) {
        image[array_index] = 0;
        depth_buffer[array_index] = 1e30f;
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
