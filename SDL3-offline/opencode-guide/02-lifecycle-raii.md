# 02 — Lifecycle: init, metadata, and beating the GC habit

## Init: subsystems, not the whole engine

```cpp
SDL_SetAppMetadata("MyGame", "1.0", "com.example.mygame"); // shows in OS task UI
if (!SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO | SDL_INIT_GAMEPAD)) {
    // SDL3 returns bool. On false, SDL_GetError() has the reason. Read it HERE:
    throw std::runtime_error(std::string("SDL_Init: ") + SDL_GetError());
}
// ... at the very end, once:
SDL_Quit();
```

UE starts everything; SDL starts what you flag. Headless server? Skip `VIDEO`.
No audio? Skip `AUDIO`. Fewer subsystems = fewer failure modes in the car.

## Two program shapes (pick classic `main`)

**A. Classic `main()`** — used by `code/cpp-starter/main.cpp` and
`code/gpu-triangle/triangle.cpp`. You own `while (running)`. This is the guide's
default: transparent, debuggable, maps 1:1 to "game thread loop".

**B. Callbacks** (`SDL_AppInit` / `SDL_AppEvent` / `SDL_AppIterate` /
`SDL_AppQuit` with `#define SDL_MAIN_USE_CALLBACKS 1`) — used by SDL's official
examples so they also compile to Web. Same four phases as (A), just inverted.
Read `SDL-src/docs/README-main-functions.md` once, then forget it until you
need Emscripten.

## RAII: your replacement for GC (the most important habit in this guide)

There is no `UPROPERTY()`. Every `SDL_Create*` needs its destroy, in reverse
order — exactly like releasing RHI resources before destroying the device:

```cpp
// From code/cpp-starter/main.cpp (verified):
struct WindowDeleter {
    void operator()(SDL_Window* w) const noexcept { if (w) SDL_DestroyWindow(w); }
};
struct RendererDeleter {
    void operator()(SDL_Renderer* r) const noexcept { if (r) SDL_DestroyRenderer(r); }
};
using WindowPtr = std::unique_ptr<SDL_Window, WindowDeleter>;
using RendererPtr = std::unique_ptr<SDL_Renderer, RendererDeleter>;
```

GPU resources need the device to destroy them, so they get capturing deleters
or explicit ordered teardown (see `triangle.cpp`: pipeline → unclaim window →
device → window → `SDL_Quit()`). Rule of thumb: **declare members in creation
order; `unique_ptr` then destroys in reverse automatically.**

## Error handling without exceptions from the library

SDL never throws. The pattern, everywhere:

```cpp
[[noreturn]] void sdl_fail(const std::string& what) {
    throw std::runtime_error(what + ": " + SDL_GetError()); // read error AT site
}
WindowPtr w{SDL_CreateWindow(...)}; if (!w) sdl_fail("SDL_CreateWindow");
```

`SDL_assert(x)` is your `check(x)` (kept in debug, stripped in release).
`SDL_Log("score=%d", s)` is your `UE_LOG` (see `SDL_LogPriority` for levels).
