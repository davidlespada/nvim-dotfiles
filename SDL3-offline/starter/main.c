/* SDL3 starter - classic main() style (beginner friendly).
 * Build offline:  make   OR   mkdir build && cd build && cmake .. && cmake --build .
 * Run: ./sdl3-starter
 *
 * Public domain. Uses only SDL3 core (no image/mixer/ttf needed).
 */
#include <SDL3/SDL.h>

int main(int argc, char *argv[])
{
    (void)argc; (void)argv;

    if (!SDL_Init(SDL_INIT_VIDEO)) {
        SDL_Log("SDL_Init failed: %s", SDL_GetError());
        return 1;
    }

    SDL_Window *window = SDL_CreateWindow("SDL3 starter (offline)", 800, 600, SDL_WINDOW_RESIZABLE);
    if (!window) {
        SDL_Log("SDL_CreateWindow failed: %s", SDL_GetError());
        SDL_Quit();
        return 1;
    }

    SDL_Renderer *renderer = SDL_CreateRenderer(window, NULL);
    if (!renderer) {
        SDL_Log("SDL_CreateRenderer failed: %s", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    bool running = true;
    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT)
                running = false;
            if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE)
                running = false;
        }

        /* animate background color */
        const double now = (double)SDL_GetTicks() / 1000.0;
        const float r = (float)(0.5 + 0.5 * SDL_sin(now));
        const float g = (float)(0.5 + 0.5 * SDL_sin(now + SDL_PI_D * 2 / 3));
        const float b = (float)(0.5 + 0.5 * SDL_sin(now + SDL_PI_D * 4 / 3));
        SDL_SetRenderDrawColorFloat(renderer, r, g, b, SDL_ALPHA_OPAQUE_FLOAT);
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);
    }

    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
