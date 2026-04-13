
    section .bss
px:
    resw 1
py:
    resw 1
u:
    resw 1
v:
    resw 1
i:
    resd 1
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
