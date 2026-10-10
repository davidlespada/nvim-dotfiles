# 03 — Windows, events, and input (your PlayerController layer)

## Windows

```cpp
SDL_Window* w = SDL_CreateWindow("title", 800, 600, SDL_WINDOW_RESIZABLE);
// flags you'll actually use: SDL_WINDOW_RESIZABLE, SDL_WINDOW_FULLSCREEN,
// SDL_WINDOW_HIGH_PIXEL_DENSITY. Query: SDL_GetWindowSize(), SDL_GetWindowID()
```

One big SDL3 kindness: with the GPU API there is **no manual swapchain rebuild
on resize** — `SDL_AcquireGPUSwapchainTexture` just hands you the right size
each frame (`triangle.cpp` reads `w/h` back every frame; use them).

## Events: a struct queue, not delegates

```cpp
SDL_Event e;
while (SDL_PollEvent(&e)) {          // drain fully, every frame, before update
    if (e.type == SDL_EVENT_QUIT) running = false;
    else if (e.type == SDL_EVENT_KEY_DOWN && e.key.key == SDLK_ESCAPE) running = false;
    else if (e.type == SDL_EVENT_MOUSE_BUTTON_DOWN) { /* e.button.x, e.button.y */ }
}
```

SDL3 renames to memorize once: `SDL_QUIT`→`SDL_EVENT_QUIT`,
`SDL_KEYDOWN`→`SDL_EVENT_KEY_DOWN`, and the key field is `e.key.key`
(`SDLK_SPACE`, `SDLK_W`, …). Key *repeat* arrives as repeated `KEY_DOWN` with
`e.key.repeat == true` — filter it for "pressed once" actions.

## UE mapping: build your own mini Enhanced Input

There are no mapping contexts or action assets. The standard replacement is a
tiny layer, and writing it teaches the API:

```cpp
// sketch: poll in one place, gameplay reads intents (not SDL types)
struct InputState { bool quit = false, jumpPressed = false; float moveX = 0; };
void PollInput(InputState& in) {
    SDL_Event e;
    while (SDL_PollEvent(&e)) {
        if (e.type == SDL_EVENT_QUIT) in.quit = true;
        if (e.type == SDL_EVENT_KEY_DOWN && !e.key.repeat) {
            if (e.key.key == SDLK_SPACE) in.jumpPressed = true; // edge trigger
        }
    }
    const bool* keys = SDL_GetKeyboardState(nullptr); // polled state, like GetInputAnalogKeyState
    in.moveX = (keys[SDL_SCANCODE_D] ? 1.f : 0.f) - (keys[SDL_SCANCODE_A] ? 1.f : 0.f);
}
```

Two APIs, two uses: **events** for edges (pressed/released/quit), **polled
state** (`SDL_GetKeyboardState`, indexed by `SDL_SCANCODE_*`) for held keys —
exactly the pressed-vs-held split you know from UE input.

## Gamepads (the `GAMEPAD` subsystem you enabled in §02)

```cpp
int count = 0;
SDL_JoystickID* ids = SDL_GetGamepads(&count);   // hotplug-safe list
SDL_Gamepad* pad = count ? SDL_OpenGamepad(ids[0]) : nullptr;
SDL_free(ids);
// in the event loop:
if (e.type == SDL_EVENT_GAMEPAD_BUTTON_DOWN && e.gbutton.button == SDL_GAMEPAD_BUTTON_SOUTH) { /* A/cross */ }
float lx = SDL_GetGamepadAxis(pad, SDL_GAMEPAD_AXIS_LEFTX) / 32767.f;
```

Rumble is one call: `SDL_RumbleGamepad(pad, 0xFFFF, 0xFFFF, 300)`.
Hotplug arrives as `SDL_EVENT_GAMEPAD_ADDED/REMOVED` — handle it and you'll
never crash on cable yank, the classic demo failure.

## Mouse (for the car: trackpad deltas)

`SDL_EVENT_MOUSE_MOTION` gives `e.motion.xrel/yrel` (relative mode via
`SDL_SetWindowRelativeMouseMode(w, true)` for camera-style look — the UE
"ignore look input except…" equivalent is just not reading it).
