
    section .bss
px_int:
    resw 1
py_int:
    resw 1
u_int:
    resw 1
v_int:
    resw 1
light:
    resw 1
i:
    resw 1
f_v:
    resd 1
offset:
    resd 1

    %ifndef COM
array_index:
    resw 1
image:
    resb BUFFER_SIZE
    %endif
