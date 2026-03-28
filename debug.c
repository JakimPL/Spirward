#include <math.h>
#include <stdio.h>

#define M_PI 3.14159265358979323846

#define SPIRAL_SCREEN_WIDTH 160
#define SPIRAL_SCREEN_HEIGHT 100
#define HALF_SPIRAL_SCREEN_WIDTH (SPIRAL_SCREEN_WIDTH / 2)
#define HALF_SPIRAL_SCREEN_HEIGHT (SPIRAL_SCREEN_HEIGHT / 2)
#define U_STEPS (SPIRAL_SCREEN_HEIGHT * 2)

const int half_spiral_screen_width = HALF_SPIRAL_SCREEN_WIDTH;
const int half_spiral_screen_height = HALF_SPIRAL_SCREEN_HEIGHT;

const float two_pi = 2.0f * M_PI;

const float y_camera = 1.424f;
const float focal_length = 85.0f;
const float circumference_constant = two_pi * focal_length;
const float attenuation = 0.01f;

const float checkerboard_value = 1.0f;
const float checkerboard_dark = 0.2f;

float v_step;
int i;

float u;
float v;
float px;
float py;

float u_offset = 0.0f;
float v_offset = 0.0f;

float light;
float depth;

float image[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];
float depth_buffer[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];
float u_values[U_STEPS];
int v_steps[U_STEPS];

extern void calculate_uv_values();
extern void calculate_initial_spiral_point();

int get_index(int px, int py)
{
    return py * SPIRAL_SCREEN_WIDTH + px;
}

void update_depth_buffer(float u, float v, int px, int py, float depth)
{
    const int index = get_index(px, py);
    if (depth < depth_buffer[index])
    {
        depth_buffer[index] = depth;
        image[index] = light * checkerboard_value;
    }
}

int main()
{
    for (i = 1; i <= U_STEPS; ++i)
    {
        calculate_uv_values();
        calculate_initial_spiral_point();
        printf("u: %f, v_step: %f\n", u, v_step);
        v_step = two_pi / i;
        u = v_step * focal_length;
        printf("u: %f, v_step: %f\n", u, v_step);
        printf("px: %f, py: %f\n", px, py);
        v = 0.0f;
        const float u_angle = u + u_offset;
        const float cos_u = cosf(u_angle);
        const float sin_u = sinf(u_angle);
        float x = 2.0f * sin_u;
        float y = 2.0f * cos_u;
        float px = HALF_SPIRAL_SCREEN_WIDTH + x / v_step;
        float py = HALF_SPIRAL_SCREEN_HEIGHT + y / v_step;

        printf("px: %f, py: %f\n", px, py);
        for (int v_step_index = 0; v_step_index < i; ++v_step_index)
        {
            const float v_angle = v + v_offset;
            const float cos_v = cosf(v_angle);
            const float sin_v = sinf(v_angle);

            px -= cos_v;
            py -= sin_v;
            // depth = x * x + y * y + u * u;

            if (px >= 0 && px < SPIRAL_SCREEN_WIDTH && py >= 0 && py < SPIRAL_SCREEN_HEIGHT)
            {
                update_depth_buffer(u, v, px, py, depth);
            }
            v += v_step;
        }
    }

    return 0;
}
