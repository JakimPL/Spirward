#ifndef SPIRAL_H
#define SPIRAL_H

#include <stdbool.h>

#define M_PI 3.14159265358979323846

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200
#define HALF_SCREEN_WIDTH (SCREEN_WIDTH / 2)
#define HALF_SCREEN_HEIGHT (SCREEN_HEIGHT / 2)

#define V_STEPS 1024
#define U_STEPS (SCREEN_HEIGHT * 4)

#define CHECKERBOARD_V_SIZE 8
#define CHECKERBOARD_ASPECT_RATIO 1.0f

extern const float spiral_minor_radius;
extern const float spiral_major_radius;
extern const float v_step;
extern const float y_step;

extern const float v_checkerboard_size;
extern const float u_checkerboard_size;
extern const float checkerboard_dark;
extern const float checkerboard_light;

extern const float focal_length;
extern float camera_position[3];

extern float u_offset;
extern float v_offset;

extern float uv[2];
extern float xyz[3];
extern int xy[2];
extern float depth;
extern float image[SCREEN_WIDTH * SCREEN_HEIGHT];
extern float depth_buffer[SCREEN_WIDTH * SCREEN_HEIGHT];
extern float us[U_STEPS];
extern float v_steps[U_STEPS];

void calculate_uv_values();
void project_to_screen();
float calculate_light();
bool checkerboard_pattern();
bool is_within_bounds();
void update_depth_buffer();
void clear_buffers();
void compute_spiral_point(float u, float v);
void draw_spiral();
void draw();

#endif
