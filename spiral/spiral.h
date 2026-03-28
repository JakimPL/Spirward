#ifndef SPIRAL_H
#define SPIRAL_H

#include <stdbool.h>

#define M_PI 3.14159265358979323846

#define SPIRAL_SCREEN_WIDTH 160
#define SPIRAL_SCREEN_HEIGHT 100
#define HALF_SPIRAL_SCREEN_WIDTH (SPIRAL_SCREEN_WIDTH / 2)
#define HALF_SPIRAL_SCREEN_HEIGHT (SPIRAL_SCREEN_HEIGHT / 2)
#define U_STEPS (SPIRAL_SCREEN_HEIGHT * 2)
#define CHECKERBOARD_V_SIZE 8

extern const float focal_length;
extern const float circumference_constant;
extern const float attenuation;
extern float u_offset;
extern float v_offset;

extern float depth;
extern float light;
extern float checkerboard_value;

extern float image[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];
extern float depth_buffer[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];

extern void calculate_uv_values();
extern void calculate_initial_point();
extern void increment_point();

void checkerboard_color(float u, float v);
void update_depth_buffer(float u, float v, int px, int py, float depth);
void clear_buffers();
void draw();

#endif
