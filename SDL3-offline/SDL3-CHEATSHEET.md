# SDL3 offline cheatsheet (classic `main()` style)

New to SDL3? Learn in this order. Every function below has a man page
(`man -M ~/Projects/SDL3-offline/docs/man <name>`) and a wiki page
(`docs/sdlwiki/sdlwiki/SDL3/<name>.html`).

## 1. Program skeleton

```c
#include <SDL3/SDL.h>
int main(int argc, char *argv[]) {
    SDL_Init(SDL_INIT_VIDEO);                          // init subsystem(s)
    SDL_Window *win = SDL_CreateWindow("t", 800, 600, 0);
    SDL_Renderer *ren = SDL_CreateRenderer(win, NULL); // SDL3: only 2 args!
    bool running = true;
    while (running) {
        SDL_Event e;
        while (SDL_PollEvent(&e)) {                    // drain events each frame
            if (e.type == SDL_EVENT_QUIT) running = false;
        }
        SDL_SetRenderDrawColor(ren, 20, 20, 30, 255);  // draw...
        SDL_RenderClear(ren);
        SDL_RenderPresent(ren);                        // ...then show
    }
    SDL_DestroyRenderer(ren);                          // cleanup reverse order
    SDL_DestroyWindow(win);
    SDL_Quit();
}
```

Full runnable version: `starter/main.c` (ESC or window-X quits, animated bg).

## 2. Init / shutdown

| call | notes |
|---|---|
| `SDL_Init(SDL_INIT_VIDEO)` | also `SDL_INIT_AUDIO`, `SDL_INIT_GAMEPAD`, or `SDL_INIT_VIDEO\|SDL_INIT_AUDIO`. Returns bool in SDL3 (not int). |
| `SDL_Quit()` | call once at end. `man SDL_Quit` |
| `SDL_GetError()` | human-readable string after any failure. `man SDL_GetError` |

## 3. Window (`man SDL_CreateWindow`)

```c
SDL_Window *w = SDL_CreateWindow("title", 800, 600, SDL_WINDOW_RESIZABLE);
```
Useful flags: `SDL_WINDOW_RESIZABLE`, `SDL_WINDOW_FULLSCREEN`, `SDL_WINDOW_HIGH_PIXEL_DENSITY`.
Related: `SDL_DestroyWindow`, `SDL_GetWindowSize`, `SDL_SetWindowTitle`.

## 4. Renderer (`man SDL_CreateRenderer`)

```c
SDL_Renderer *r = SDL_CreateRenderer(window, NULL); // SDL3 changed: no driver index, no flags
```
Draw calls: `SDL_SetRenderDrawColor` / `SDL_SetRenderDrawColorFloat`,
`SDL_RenderClear`, `SDL_RenderPresent`, `SDL_RenderFillRect`,
`SDL_RenderTexture` (needs a texture — see `SDL_CreateTextureFromSurface`).
Related: `SDL_DestroyRenderer`.

## 5. Events (`man SDL_PollEvent`, `man SDL_Event`)

```c
SDL_Event e;
while (SDL_PollEvent(&e)) {
    if (e.type == SDL_EVENT_QUIT) { /* ... */ }
    if (e.type == SDL_EVENT_KEY_DOWN && e.key.key == SDLK_ESCAPE) { /* ... */ }
    if (e.type == SDL_EVENT_MOUSE_BUTTON_DOWN) { /* e.button.x, e.button.y */ }
}
```
SDL3 renames: `SDL_QUIT` → `SDL_EVENT_QUIT`, `SDL_KEYDOWN` → `SDL_EVENT_KEY_DOWN`,
key code field is `e.key.key` (e.g. `SDLK_ESCAPE`, `SDLK_SPACE`).

## 6. Timing

`SDL_GetTicks()` → ms since init (`man SDL_GetTicks`).
Frame cap: `SDL_Delay(16)` ≈ 60 fps (`man SDL_Delay`).

## 7. The other style: callbacks (official examples use this)

SDL3 examples (`SDL-src/examples/`) use `SDL_MAIN_USE_CALLBACKS` with four
functions instead of `main()`: `SDL_AppInit`, `SDL_AppEvent`, `SDL_AppIterate`
(per-frame), `SDL_AppQuit`. Read `SDL-src/docs/README-main-functions.md`
offline for the full explanation. You do NOT need this style — classic
`main()` (like `starter/main.c`) is fine.

## 8. Build offline

```bash
# quick (pkg-config, no cmake):
gcc -Wall -std=c11 $(pkg-config --cflags sdl3) -o game main.c $(pkg-config --libs sdl3)
# or:
make -C ~/Projects/SDL3-offline/starter
# or cmake:
mkdir build && cd build && cmake .. && cmake --build .
```

## 9. SDL3 vs SDL2 gotchas (you'll see SDL2 tutorials in the wild)

- `SDL_CreateRenderer(window, NULL)` — 2 args, not 3.
- Event constants have `SDL_EVENT_` prefix.
- Functions return `bool` (`true`/`false`), check `if (!fn()) SDL_Log("%s", SDL_GetError())`.
- Migration guide offline: `docs/sdlwiki/sdlwiki/SDL3/README-migration.html`.

## 10. Where to look things up (all offline)

- `man -M ~/Projects/SDL3-offline/docs/man SDL_<name>` — 1,922 API pages.
- `docs/sdlwiki/sdlwiki/SDL3/FrontPage.html` — wiki home, open in browser.
- `docs/sdlwiki/sdlwiki/SDL3/APIByCategory.html` — browse API by subsystem.
- `SDL-src/examples/` — 39 copy-pasteable public-domain `.c` files. Start with `renderer/01-clear/clear.c` (69 lines).
- `/usr/include/SDL3/SDL_*.h` — headers with doc comments; `grep -rn "SDL_Create" /usr/include/SDL3/ | head`.
