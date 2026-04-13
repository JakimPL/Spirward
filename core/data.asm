%ifndef _DATA_ASM_
%define _DATA_ASM_

    section .data
focal_length:
    dw FOCAL_LENGTH
frame_count:
    dw 1
checkerboard_size:
    dd 1.2732395447351628              ; 4 / π

%endif
