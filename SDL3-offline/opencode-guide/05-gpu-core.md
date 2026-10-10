# 05 — SDL GPU core: device, swapchain, and the frame (READ THIS TWICE)

This is your RHI. Same explicitness you're used to (`FRHICommandList`,
render passes, PSOs), C-style, no hidden state. The verified reference is
`code/gpu-triangle/triangle.cpp` — every call below appears there.

## Startup sequence (like choosing the RHI + creating the device)

```cpp
SDL_GPUDevice* dev = SDL_CreateGPUDevice(SDL_GPU_SHADERFORMAT_SPIRV, true, nullptr);
//                                        ^ Vulkan bytecode   ^ debug layers
SDL_ClaimWindowForGPUDevice(dev, window);          // bind window <-> device
SDL_SetGPUSwapchainParameters(dev, window,         // vsync + SDR, set once
    SDL_GPU_SWAPCHAINCOMPOSITION_SDR, SDL_GPU_PRESENTMODE_VSYNC);
```

Format note: `SPIRV` runs Vulkan (this laptop, the car). Other backends need
their own bytecode (`DXBC/DXIL` for D3D, `MSL` for Metal) — compiled from the
*same* sources with `shadercross` (§06). `SDL_GetGPUSwapchainTextureFormat`
tells you the backbuffer format; build color targets to match it.

## The frame (one iteration = one Tick + one RHI frame)

```cpp
SDL_GPUCommandBuffer* cmd = SDL_AcquireGPUCommandBuffer(dev);
SDL_GPUTexture *swap = nullptr; Uint32 w, h;
SDL_AcquireGPUSwapchainTexture(cmd, window, &swap, &w, &h); // auto-resized!
if (!swap) { SDL_CancelGPUCommandBuffer(cmd); continue; }   // minimized: skip

SDL_GPUColorTargetInfo target{};                 // ~= render pass descriptor
target.texture = swap;
target.load_op = SDL_GPU_LOADOP_CLEAR;           // or LOAD to preserve
target.store_op = SDL_GPU_STOREOP_STORE;
target.clear_color = {0.06f, 0.07f, 0.10f, 1.0f};

SDL_GPURenderPass* pass = SDL_BeginGPURenderPass(cmd, &target, 1, nullptr);
SDL_BindGPUGraphicsPipeline(pass, pipeline);     // ~= SetGraphicsPSO
SDL_DrawGPUPrimitives(pass, 3, 1, 0, 0);         // verts, instances, firsts
SDL_EndGPURenderPass(pass);
SDL_SubmitGPUCommandBuffer(cmd);                 // ~= submit; GPU runs async
```

Memorize the ownership: command buffer → acquire swapchain → begin pass →
bind → draw → end pass → submit. `Cancel` (not submit) when there's nothing
to draw. Submits are cheap; the driver batches.

## Teardown order (mirrors RHI shutdown)

```cpp
SDL_ReleaseGPUGraphicsPipeline(dev, pipeline); // resources first…
SDL_ReleaseWindowFromGPUDevice(dev, window);   // …then unclaim…
SDL_DestroyGPUDevice(dev);                     // …then the device (like RHI exit)
```

Run it now: `cd code/gpu-triangle && ./build.sh && timeout -s TERM 6 ./gpu-triangle`.
You just ran a real Vulkan app you can read end-to-end in ~230 lines.
