#include <math.h>
#include <stdio.h>

#include "spiral.h"

const float spiral_minor_radius = 1.0f;
const float spiral_major_radius = 2.0f;
const float y_step = (float)SPIRAL_SCREEN_HEIGHT / (float)U_STEPS;

const float v_checkerboard_size = (2.0f * M_PI) / CHECKERBOARD_V_SIZE;
const float u_checkerboard_size = v_checkerboard_size * CHECKERBOARD_ASPECT_RATIO;
const float checkerboard_dark = 0.2f;
const float checkerboard_light = 0.9f;

const float focal_length = 85.0f;
const float circumference_constant = 2.0f * M_PI * spiral_minor_radius * focal_length;
float camera_position[3] = {0.0f, -M_PI, 0.0f};

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
float v_steps[U_STEPS];

void calculate_uv_values()
{
    for (int i = 0; i < U_STEPS; i++)
    {
        const float y = 1.0f + i * y_step;
        const float u = camera_position[2] - focal_length * camera_position[1] / y;
        u_values[i] = u;
        v_steps[i] = circumference_constant / (u - camera_position[2]);
    }
}

void project_to_screen()
{
    depth = 0.0f;
    for (int i = 0; i < 3; i++)
    {
        point[i] = xyz[i] - camera_position[i];
        depth += point[i] * point[i];
    }

    xy[0] = (int)(HALF_SPIRAL_SCREEN_WIDTH + focal_length * point[0] / point[2]);
    xy[1] = (int)(focal_length * point[1] / point[2]);
}

void calculate_light()
{
    light = 1.0f / (1.0f + 0.02f * depth);
}

bool checkerboard_pattern()
{
    const int u_index = (int)(uv[0] / u_checkerboard_size);
    const int v_index = (int)(uv[1] / v_checkerboard_size);
    return (u_index + v_index) % 2 == 0;
}

void checkerboard_color()
{
    checkerboard_value = checkerboard_pattern() ? checkerboard_light : checkerboard_dark;
}

bool is_within_bounds()
{
    return xy[0] >= 0 && xy[0] < SPIRAL_SCREEN_WIDTH && xy[1] >= 0 && xy[1] < SPIRAL_SCREEN_HEIGHT;
}

int get_index(int x, int y)
{
    return y * SPIRAL_SCREEN_WIDTH + x;
}

void update_depth_buffer()
{
    const int index = get_index(xy[0], xy[1]);
    if (depth < depth_buffer[index])
    {
        calculate_light();
        checkerboard_color();
        depth_buffer[index] = depth;
        for (int dx = -1; dx <= 1; dx++)
        {
            for (int dy = -1; dy <= 1; dy++)
            {
                int neighbor_x = xy[0] + dx;
                int neighbor_y = xy[1] + dy;
                if (neighbor_x >= 0 && neighbor_x < SPIRAL_SCREEN_WIDTH &&
                    neighbor_y >= 0 && neighbor_y < SPIRAL_SCREEN_HEIGHT)
                {
                    image[get_index(neighbor_x, neighbor_y)] += 0.03f * light * checkerboard_value;
                }
            }
        }
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

void compute_spiral_point(float u, float v)
{
    const float v_angle = v + v_offset;
    const float u_angle = u + u_offset;
    const float cos_u = cosf(u_angle);
    const float sin_u = sinf(u_angle);
    const float cos_v = cosf(v_angle);
    const float sin_v = sinf(v_angle);

    xyz[0] = spiral_major_radius * sin_u + spiral_minor_radius * cos_v;
    xyz[1] = spiral_major_radius * cos_u + spiral_minor_radius * sin_v;
    xyz[2] = u;

    uv[0] = u;
    uv[1] = v;
}

void draw_spiral()
{
    for (int u_step_index = 0; u_step_index < U_STEPS; ++u_step_index)
    {
        const int v_steps_for_u = v_steps[u_step_index];
        float v = 0.0f;
        float v_step = 2.0f * M_PI / v_steps_for_u;
        for (int v_step_index = 0; v_step_index < v_steps_for_u; ++v_step_index)
        {
            const float u = u_values[u_step_index];
            v += v_step;
            compute_spiral_point(u, v);
            project_to_screen();
            if (is_within_bounds())
            {
                update_depth_buffer();
            }
        }
    }
}

void draw()
{
    clear_buffers();
    draw_spiral();
}
