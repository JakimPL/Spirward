global calculate_uv_values

U_STEPS equ 200

calculate_uv_values:
    mov ecx, U_STEPS
    fld dword [circumference_constant]
    fld1
.step:
    fdiv st1, st0
    fst dword [u_values + ecx*4 - 4]
    fld1
    faddp
    loop .step
    fstp st0
    ret

extern circumference_constant
extern u_values
