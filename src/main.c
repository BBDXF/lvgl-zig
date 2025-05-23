#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>

#include "lvgl.h"
#include "lv_demo_widgets.h"

/**
 * Initialize the SDL display driver
 *
 * @return the LVGL display
 */
static lv_display_t *init_sdl(void)
{
    lv_display_t *disp;

    disp = lv_sdl_window_create(800,600);

    if (disp == NULL) {
        return NULL;
    }

    return disp;
}

/**
 * The run loop of the SDL driver
 */
static void run_loop_sdl(void)
{
    uint32_t idle_time;

    /* Handle LVGL tasks */
    while (true) {
        /* Returns the time to the next timer execution */
        idle_time = lv_timer_handler();
        usleep(idle_time * 1000);
    }
}

int main(int argc, char **argv)
{
    /* Initialize LVGL. */
    lv_init();

    /* Initialize the configured backend */
    init_sdl();

    /*Create a Demo*/
    lv_demo_widgets();
    lv_demo_widgets_start_slideshow();

    
    run_loop_sdl();

    return 0;
}