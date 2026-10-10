# 01 — Setup for C++ (this machine is already ready)

## What you have (verified 2026-10-10)

- `g++ 16`, `cmake`, `ninja`, `pkg-config`
- SDL `3.4.18`: headers `/usr/include/SDL3/`, lib via `pkg-config --libs sdl3` → `-lSDL3`
- `glslc` + `spirv-val` (shader compile/validate), Vulkan + NVIDIA RTX 5070
  (GPU programs RUN here, not just compile)
- Missing: `shadercross` (SDL's cross-platform shader compiler). Only matters
  for DirectX/Metal targets — for this Linux+Vulkan trip, `glslc` covers you.

## UE mapping

Unreal hides the toolchain behind UBT/Build.cs. Here there are two honest ways:

```bash
# A) pkg-config: fastest iteration, like a one-file Unreal console test
g++ -Wall -Wextra -std=c++17 $(pkg-config --cflags sdl3) -o game main.cpp $(pkg-config --libs sdl3)

# B) CMake: what you'd graduate to (UE-module-like structure later)
find_package(SDL3 REQUIRED)            # in CMakeLists.txt
target_link_libraries(game PRIVATE SDL3::SDL3)
```

## Prove it right now (offline, ~5 seconds)

```bash
cd ~/Projects/SDL3-offline/opencode-guide/code/cpp-starter
make && timeout -s TERM 4 ./cpp-starter   # animated window, killed by timeout
cd ../gpu-triangle
./build.sh && timeout -s TERM 6 ./gpu-triangle  # real GPU triangle on NVIDIA
```

Both exit `124` = "still running fine when the timeout killed them". If you
see a window + color, your loop works. If `gpu-triangle` prints
`SDL_CreateGPUDevice ... failed`, your Vulkan driver didn't load — check
`vulkaninfo --summary` (needs no internet).

## Project layout I recommend (mirrors a UE module)

```
mygame/
  CMakeLists.txt        # find_package(SDL3), one target per tool/game
  src/main.cpp          # platform shell: init, window, loop (§02)
  src/game/…            # your gameplay code (owns no SDL types directly)
  src/rhi/…             # your thin GPU wrapper (§05–06)
  shaders/*.vert|*.frag # sources…
  shaders/*.spv         # …plus compiled bytecode, committed like cooked data
```

Rule from §02 onward: gameplay code never calls `SDL_` directly — it talks to
your shell. That seam is what makes the code testable and portable, same
reason gameplay never touches RHI directly in UE.
