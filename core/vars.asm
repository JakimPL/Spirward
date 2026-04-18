
    section .bss
u:
    resw 1
v:
    resw 1
px:
    resw 1
py:
    resw 1

f_v:
    resd 1
i:
    resd 1

    %ifndef COM
image:
    resb BUFFER_SIZE
    %endif
