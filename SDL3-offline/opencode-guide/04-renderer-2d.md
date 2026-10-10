# 04 — The 2D renderer (learn it, then know when to leave it)

`SDL_Renderer` is the immediate-mode 2D path: set color, clear, draw
rects/lines/textures, present. `code/cpp-starter/main.cpp` is the whole
technique. New primitives vs SDL2: `SDL_RenderFillRect`, `SDL_RenderLine`,
`SDL_RenderTexture(renderer, tex, srcrect, dstrect)`.

```cpp
SDL_SetRenderDrawColorFloat(ren, r, g, b, SDL_ALPHA_OPAQUE_FLOAT);
SDL_RenderClear(ren);      // fill with draw color
SDL_RenderPresent(ren);    // present: the ONLY call that shows anything
```

Textures from files need a satellite lib (`SDL_image`, §07); from memory:
`SDL_CreateTextureFromSurface`. Text: `SDL_ttf` (`TTF_OpenFont`,
`TTF_RenderText_*` → surface → texture). Both are one Herrera-step each and
have man pages in this bundle.

## UE mapping + the honest tradeoff

The 2D renderer is UMG-canvas-level convenience: great for menus, debug HUDs,
prototypes, 2D games. It is **not** the RHI: no custom shaders, no explicit
passes, driver-dependent batching. The moment you want your own shaders,
post-processing, or 3D, you move to SDL GPU (§05–06) — which is why this guide
spends most of its pages there. Keep the renderer in your toolbox for debug
overlays even in GPU apps (a second window, or debug-text via
`SDL_RenderDebugText`, see `examples/renderer/18-debug-text/`).
