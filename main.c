#include "framework/runtime/runtime.h"
#include "framework/video/video.h"

void frame() {
    draw();
    video_update_from_buffer(image);
    video_present();
}

int main(int, char **) {
    if (video_init() != 0) {
        return 1;
    }

    run(frame);

    video_cleanup();
    return 0;
}
