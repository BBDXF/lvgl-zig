#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>

#include "lv_demo_widgets.h"
#include "lvgl.h"

#include "src/drivers/sdl/lv_sdl_mouse.h"
#include "src/drivers/sdl/lv_sdl_mousewheel.h"
#include "src/drivers/sdl/lv_sdl_keyboard.h"

static lv_display_t *lvDisplay;
static lv_indev_t *lvMouse;
static lv_indev_t *lvMouseWheel;
static lv_indev_t *lvKeyboard;

#if LV_USE_LOG != 0
static void lv_log_print_g_cb(lv_log_level_t level, const char * buf)
{
    LV_UNUSED(level);
    LV_UNUSED(buf);
}
#endif

int main(int argc, char **argv) {
    /* initialize lvgl */
    lv_init();

    // Workaround for sdl2 `-m32` crash
    // https://bugs.launchpad.net/ubuntu/+source/libsdl2/+bug/1775067/comments/7
    #ifndef WIN32
        setenv("DBUS_FATAL_WARNINGS", "0", 1);
    #endif

    /* Register the log print callback */
    #if LV_USE_LOG != 0
    lv_log_register_print_cb(lv_log_print_g_cb);
    #endif

    /* Add a display
    * Use the 'monitor' driver which creates window on PC's monitor to simulate a display*/

    lvDisplay = lv_sdl_window_create(800, 600);
    lvMouse = lv_sdl_mouse_create();
    lvMouseWheel = lv_sdl_mousewheel_create();
    lvKeyboard = lv_sdl_keyboard_create();

    /* create Widgets on the screen */
    lv_demo_widgets();


    Uint32 lastTick = SDL_GetTicks();
    while(1) {
        SDL_Delay(5);
        Uint32 current = SDL_GetTicks();
        lv_tick_inc(current - lastTick); // Update the tick timer. Tick is new for LVGL 9
        lastTick = current;
        lv_timer_handler(); // Update the UI-
    }

    return 0;
}