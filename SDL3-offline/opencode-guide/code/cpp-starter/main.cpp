// C++ RAII starter: window + 2D renderer, animated background.
// Build:  make  |  or cmake (see CMakeLists.txt)
// Public domain (mine for this guide).
#include <SDL3/SDL.h>

#include <cmath>
#include <cstdint>
#include <memory>
#include <stdexcept>
#include <string>

// UE mental model: there is no GC here. unique_ptr + custom deleter is your
// UPROPERTY + DestroyActor. Every SDL_Create* must pair with its destroy.
struct WindowDeleter {
    void operator()(SDL_Window* w) const noexcept {
        if (w) SDL_DestroyWindow(w);
    }
};
struct RendererDeleter {
    void operator()(SDL_Renderer* r) const noexcept {
        if (r) SDL_DestroyRenderer(r);
    }
};
using WindowPtr = std::unique_ptr<SDL_Window, WindowDeleter>;
using RendererPtr = std::unique_ptr<SDL_Renderer, RendererDeleter>;

[[noreturn]] void sdl_fail(const std::string& what) {
    // UE mental model: like UE_LOG(Error) + check(). SDL errors are strings,
    // not exceptions: always read SDL_GetError() AT the failure site.
    throw std::runtime_error(what + ": " + SDL_GetError());
}

int main(int /*argc*/, char* /*argv*/[]) {
    // UE mental model: SDL_Init ~= starting the Engine (subsystems on demand).
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        sdl_fail("SDL_Init");
    }

    WindowPtr window{SDL_CreateWindow("SDL3 C++ starter (opencode guide)", 800, 600,
                                      SDL_WINDOW_RESIZABLE)};
    if (!window) {
        sdl_fail("SDL_CreateWindow");
    }

    // SDL3 note: 2 args now (SDL2 took driver index + flags).
    RendererPtr renderer{SDL_CreateRenderer(window.get(), nullptr)};
    if (!renderer) {
        sdl_fail("SDL_CreateRenderer");
    }

    bool running = true;
    while (running) {
        // UE mental model: this inner loop ~= draining the message pump before Tick.
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT) {
                running = false;
            } else if (event.type == SDL_EVENT_KEY_DOWN && event.key.key == SDLK_ESCAPE) {
                running = false;
            }
        }

        const double now = static_cast<double>(SDL_GetTicks()) / 1000.0;
        const float r = static_cast<float>(0.5 + 0.5 * std::sin(now));
        const float g = static_cast<float>(0.5 + 0.5 * std::sin(now + M_PI * 2.0 / 3.0));
        const float b = static_cast<float>(0.5 + 0.5 * std::sin(now + M_PI * 4.0 / 3.0));
        SDL_SetRenderDrawColorFloat(renderer.get(), r, g, b, SDL_ALPHA_OPAQUE_FLOAT);
        SDL_RenderClear(renderer.get());
        SDL_RenderPresent(renderer.get());
    }

    // UE mental model: explicit teardown ~= EndPlay on everything, in reverse
    // order. unique_ptrs destroy renderer first (declared second), then window.
    renderer.reset();
    window.reset();
    SDL_Quit();
    return 0;
}
