# 07 — Audio, files, threads, libs, and the pre-trip checklist

## Audio: streams, not cues

```cpp
SDL_AudioSpec want{}; want.format = SDL_AUDIO_F32; want.channels = 2; want.freq = 48000;
SDL_AudioStream* stream = SDL_OpenAudioDeviceStream(
    SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK, &want, nullptr, nullptr);
SDL_ResumeAudioStreamDevice(stream);          // paused by default: resume!
float buf[1024]; /* synthesize or decode into buf */
SDL_PutAudioStreamData(stream, buf, sizeof(buf)); // push PCM, mixer pulls
```

UE mapping: no sound cues/graphs — you push float PCM into a stream.
Decode files with `SDL_mixer` (WAV/OGG/MP3); generate bleeps directly for the
car (sine in `buf` is 10 lines). `man SDL_OpenAudioDeviceStream`. Live example:
`SDL-src/examples/audio/`.

## Files: base path + pref path (your replacement for pak mounting)

```cpp
const char* base = SDL_GetBasePath(); // dir of YOUR binary: shaders/, assets/…
const char* pref = SDL_GetPrefPath("mycompany", "mygame"); // writable save dir
SDL_free((void*)pref); // both return malloc'd strings: free them
```

Ship assets next to the binary and resolve via `base` — that's the whole
"cooker". Saves go under `pref` (correct per-OS location automatically).
Deeper needs (title storage, async IO): wiki `SDL3/APIByCategory` → Storage /
AsyncIO, all in this bundle's `docs/`.

## Threads, timers, utilities (FRunnable-era instincts apply)

- `SDL_CreateThread(fn, "name", data)` + `SDL_WaitThread` — same shape as
  `FRunnable`; render only on the thread that owns the window.
- `SDL_AddTimer(ms, callback, data)` — timer-manager-lite for retries/timeouts.
- `SDL_GetTicks()` / `SDL_Delay()` — frame timing + crude frame cap.
- `SDL_GetPerformanceCounter()` — for real frame-time stats (build your
  `stat fps`: EMA of deltas, log every 60 frames).

## Satellite libs (install BEFORE the car — needs sudo + internet)

```bash
sudo pacman -S --needed sdl3_image sdl3_mixer sdl3_net
# sdl3 + sdl3_ttf are already installed. Docs for all four are in docs/sdlwiki/.
```

You don't need them for §01–06. You want them the moment you load PNGs, play
music, or touch sockets.

## Pre-trip checklist (tonight, online)

- [ ] `sudo pacman -S --needed sdl3_image sdl3_mixer sdl3_net`
- [ ] Rebuild both samples: `make` in `code/cpp-starter`, `./build.sh` in `code/gpu-triangle`
- [ ] Skim one example per subsystem in `SDL-src/examples/` (renderer, audio, input)
- [ ] Optional: `git clone https://github.com/libsdl-org/SDL_shadercross` (only for future D3D/Metal trips)
- [ ] Phone tethering OFF test: `timeout -s TERM 6 ./gpu-triangle` still runs (it will — zero network calls)

## Suggested car curriculum (4 sessions)

1. Re-type `cpp-starter` from memory; add WASD square movement (§02–04).
2. Re-type `triangle.cpp` shader-load + frame section; change clear color per keypress (§05).
3. Add a vertex buffer quad + `PushGPUVertexUniformData` tint (§06).
4. Load a texture via copy pass + sampler; spin/zoom it (§06 + image lib).
