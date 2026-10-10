# SDL3 in C++ for the Unreal developer — an opencode guide

Written for you: fluent in Unreal C++ (UObjects, Tick, RHI concepts, cooking),
shaky in plain C++ and new to SDL3. Goal: full SDL3 with a GPU focus, readable
fully offline in the car. Every code file here was compiled, shader-validated,
and run on this machine (SDL 3.4.18, g++, NVIDIA Vulkan).

## Read order

| File | What | UE anchor |
|---|---|---|
| `01-setup-cpp.md` | Toolchain, pkg-config vs CMake, first build | Build.cs / UBT → Make+CMake |
| `02-lifecycle-raii.md` | Init, metadata, main vs callbacks, RAII wrappers | Engine init, GC → manual lifetime |
| `03-window-input.md` | Windows, events, keyboard/mouse/gamepad | Enhanced Input, PlayerController |
| `04-renderer-2d.md` | The 2D renderer fast path | Canvas/UMG-adjacent drawing |
| `05-gpu-core.md` | Device, swapchain, frames, first triangle | RHI device, swapchain, RHICmdList |
| `06-gpu-pipelines-shaders.md` | Pipelines, shaders, buffers, uniforms, textures | PSO, USF, vertex factory, textures |
| `07-audio-systems-checklist.md` | Audio streams, files, threads, satellite libs, trip checklist | Audio mixer, pak/files, FRunnable |
| `code/cpp-starter/` | Runnable RAII hello-window (C++) | — |
| `code/gpu-triangle/` | Runnable GPU triangle + precompiled SPIR-V | Hello-triangle RHI sample |

Offline references (same bundle, one folder up): `../SDL3-CHEATSHEET.md`,
`../docs/` (wiki + man pages), `../SDL-src/examples/` (39 official samples).

## The one-page UE → SDL dictionary

| Unreal | SDL3 | Notes |
|---|---|---|
| Engine init/startup | `SDL_Init()` + `SDL_SetAppMetadata()` | You pick subsystems (`SDL_INIT_VIDEO`, `..._AUDIO`, `..._GAMEPAD`) |
| `UWorld` + viewport | `SDL_Window` (+ GPU device or renderer) | No world, no level: just a window you draw into |
| `AActor::Tick` | Your `while(running)` loop / `SDL_AppIterate` | You own the loop; no latent/timer manager unless you build one |
| GC + `UPROPERTY()` | **Nothing. Manual lifetime.** `unique_ptr` + deleters | Forgetting `SDL_DestroyX` = leak. Order matters (reverse of creation) |
| `TSharedPtr` | `std::shared_ptr` with custom deleter | Same idea, works fine |
| Delegates / dispatchers | Poll loop (`SDL_PollEvent`) or `SDL_AppEvent` callback | Events are structs, not multicast delegates |
| Enhanced Input mapping | Raw keycodes (`event.key.key`) + gamepad buttons | No mapping contexts; build your own thin layer (§03) |
| RHI (`FRHI*`, PSO) | SDL GPU (`SDL_GPUDevice`, pipeline structs) | Explicit like RHI, but C-style (§05–06) |
| `.usf` shaders + cooking | GLSL/HLSL + compile to SPIR-V **before shipping** | `glslc` here; shadercross cross-platform (§06) |
| `UE_LOG` | `SDL_Log("...%s", ...)` | Categories: `SDL_LogInfo/SDL_LogError/...` |
| `check()` / `ensure()` | `SDL_assert()` | Stays on in debug, compiled out in release like `check` |
| Pak/mounted files | `SDL_GetBasePath()` + `SDL_GetPrefPath()` (+ Storage API) | No cooker: ship files next to the binary (§07) |
| Audio mixer / cues | Audio streams (`SDL_OpenAudioDeviceStream`) | Push PCM, no asset graph (§07) |

## Conventions in this guide

- All host code is C++17, `-Wall -Wextra` clean. SDL is a C API: this guide
  wraps it (RAII, helpers) instead of fighting it.
- `man -M ~/Projects/SDL3-offline/docs/man <SDL_Function>` documents every call.
- "Verified" means compiled/run here. "Pattern" means standard API shown for
  study — check the man page if a signature surprises you.
