
    section .bss
color:
    resw 1
light:
    resw 1
f_u:
    resd 1
f_v:
    resd 1
f_v_step:
    resd 1
v_step:
    resd 1
offset:
    resd 1
i:
    resw 1

px_int:
    resw 1
py_int:
    resw 1
u_int:
    resw 1
v_int:
    resw 1

    %ifdef LINUX
array_index:
    resw 1
image:
    resb BUFFER_SIZE
    %endif
