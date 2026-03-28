#define M_PI 3.14159265358979323846

#define SPIRAL_SCREEN_WIDTH 160
#define SPIRAL_SCREEN_HEIGHT 100
#define U_STEPS (SPIRAL_SCREEN_HEIGHT * 2)

const float focal_length = 85.0f;
const float circumference_constant = 2.0f * M_PI * focal_length;

float u_values[U_STEPS];
float v_steps[U_STEPS];

extern void calculate_uv_values(void);

int main(void)
{
    calculate_uv_values();
    return 0;
}
