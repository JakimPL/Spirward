#include <math.h>
#include <stdio.h>

#include "spiral.h"

const float one = 1.0f;
const float two = 2.0f;
const float pi = M_PI;
const float two_pi = two * pi;
const float y_camera = 1.424f;
const float y_step = (float)SPIRAL_SCREEN_HEIGHT / (float)U_STEPS;

const float v_checkerboard_size = two_pi / CHECKERBOARD_V_SIZE;
const float u_checkerboard_size = v_checkerboard_size;

const float checkerboard_dark = 0.2f;
const float checkerboard_light = 0.9f;
const float focal_length = 85.0f;
const float circumference_constant = two_pi * focal_length;
const float attenuation = 0.1f;

float u_offset = 0.0f;
float v_offset = 0.0f;

float uv[2];
float xyz[3];
float point[3];
int xy[2];

float depth;
float light;
float checkerboard_value;

float image[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];
float depth_buffer[SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT];
float u_values[U_STEPS];
int v_steps[U_STEPS];

void calculate_uv_values()
{
    float y = one;
    for (int i = 0; i < U_STEPS; i++)
    {
        const float u = circumference_constant / y;
        u_values[i] = u;
        v_steps[i] = (int)y;
        y += 1;
    }
}

void calculate_light()
{
    light = one / (one + attenuation * depth);
}

void checkerboard_color(float u, float v)
{
    const int u_index = (int)(u / u_checkerboard_size);
    const int v_index = (int)(v / v_checkerboard_size);
    const bool pattern = (u_index + v_index) % 2 == 0;
    checkerboard_value = pattern ? checkerboard_light : checkerboard_dark;
}

int get_index(int px, int py)
{
    return py * SPIRAL_SCREEN_WIDTH + px;
}

void update_depth_buffer(float u, float v, int px, int py, float depth)
{
    const int index = get_index(px, py);
    if (depth < depth_buffer[index])
    {
        calculate_light();
        checkerboard_color(u, v);
        depth_buffer[index] = depth;
        image[index] = light * checkerboard_value;
    }
}

void clear_buffers()
{
    for (int i = 0; i < SPIRAL_SCREEN_WIDTH * SPIRAL_SCREEN_HEIGHT; i++)
    {
        image[i] = 0.0f;
        depth_buffer[i] = 1e30f;
    }
}

void loop()
{
    for (int i = 1; i <= U_STEPS; ++i)
    {
        const float v_step = two_pi / i;
        const float u = v_step * focal_length;
        float v = 0.0f;

        const float u_angle = u + u_offset;
        depth = u * u; //  + sinf(u_angle + v);

        const float cos_u = cosf(u_angle);
        const float sin_u = sinf(u_angle);
        float x = 2.0f * sin_u;
        float y = 2.0f * cos_u;
        float px = HALF_SPIRAL_SCREEN_WIDTH + x / v_step;
        float py = HALF_SPIRAL_SCREEN_HEIGHT + y / v_step;

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
}

void draw()
{
    clear_buffers();
    loop();
}
