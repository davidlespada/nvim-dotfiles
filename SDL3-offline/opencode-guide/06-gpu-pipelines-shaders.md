# 06 — Pipelines, shaders, buffers, uniforms, textures (the PSO chapter)

## UE mapping first

| Unreal | SDL GPU | Notes |
|---|---|---|
| Graphics PSO descriptor | `SDL_GPUGraphicsPipelineCreateInfo` | One struct: shaders + vertex layout + rasterizer + targets (§05 shows one) |
| `.usf` + cooker | GLSL/HLSL sources + **offline compile to `.spv`** | Commit bytecode like cooked data |
| Vertex factory / streams | `SDL_GPUBuffer` + vertex descriptions | You describe layout explicitly (below) |
| Uniform buffers / parameters | `SDL_PushGPUVertex/FragmentUniformData` | Push small constants per draw, no descriptor wrangling for the basics |
| `UTexture2D` + sampler | `SDL_GPUTexture` + `SDL_GPUSampler` | Create, upload via copy pass, bind (§below) |
| Render target | Any texture with `SDL_GPU_TEXTUREUSAGE_COLOR_TARGET` | Same creation path as sampled textures |

## Shader workflow for the car (do this ordering!)

1. **Write once** in GLSL (`shaders/*.vert|*.frag` — see `code/gpu-triangle/`).
   Entrypoint must be `main` (matches `.entrypoint = "main"` in the loader).
2. **Compile now, while online-ish tools exist** (all present on this machine):
   ```bash
   glslc -fshader-stage=vert shaders/triangle.vert -o shaders/triangle.vert.spv
   glslc -fshader-stage=frag shaders/triangle.frag -o shaders/triangle.frag.spv
   spirv-val shaders/triangle.vert.spv   # validate; catches real bugs
   ```
   `code/gpu-triangle/build.sh` does exactly this. The committed `.spv` files
   mean the car needs **zero** shader tooling.
3. **Cross-platform later**: `shadercross` (build from
   `libsdl-org/SDL_shadercross` before a Windows/Metal trip) compiles the same
   HLSL sources to DXIL/MSL. For Linux+Vulkan, `glslc` is the whole pipeline.
4. **Load** with `SDL_CreateGPUShader` (`format = SDL_GPU_SHADERFORMAT_SPIRV`,
   `stage = VERTEX/FRAGMENT`, sampler/storage/uniform counts declared up front).
   Release shaders after pipeline creation — the PSO holds what it needs.

## Growing past the triangle: vertex buffers

```cpp
// 1. describe layout (like a vertex factory declaration):
SDL_GPUVertexBufferDescription desc{};
desc.slot = 0; desc.pitch = sizeof(Vertex); desc.input_rate = SDL_GPU_VERTEXINPUTRATE_VERTEX;
SDL_GPUVertexAttribute attrs[2]{};
attrs[0] = {.location = 0, .buffer_slot = 0, .format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3, .offset = 0};
attrs[1] = {.location = 1, .buffer_slot = 0, .format = SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2, .offset = 12};
// attach both to pipeline_info.vertex_input_state, set num_* = 1 and 2.
// 2. create + upload (UPLOAD flag + copy pass, then it is GPU-private):
SDL_GPUBuffer* vb = SDL_CreateGPUBuffer(dev, &(SDL_GPUBufferCreateInfo){
    .usage = SDL_GPU_BUFFERUSAGE_VERTEX, .size = bytes});
SDL_UploadToGPUBuffer(copyPass, &(SDL_GPUTransferBufferLocation){...}, ...); // in a copy pass
// 3. per frame: SDL_BindGPUVertexBuffers(pass, 0, &binding, 1);
```

Copy passes (`SDL_BeginGPUCopyPass` / `SDL_EndGPUCopyPass`) are how *all* CPU→GPU
uploads happen — buffers and textures alike. Think "resource cook step at
runtime, once at load".

## Per-draw constants and textures

```cpp
struct FrameUBO { float mvp[16]; float tint[4]; };
SDL_PushGPUVertexUniformData(cmd, 0, &ubo, sizeof(ubo)); // slot must match shader layout
// textures:
SDL_GPUTexture* tex = SDL_CreateGPUTexture(dev, &(SDL_GPUTextureCreateInfo){
    .type = SDL_GPU_TEXTURETYPE_2D, .format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
    .usage = SDL_GPU_TEXTUREUSAGE_SAMPLER, .width = w, .height = h,
    .layer_count_or_depth = 1, .num_levels = 1, ...});   // upload pixels via copy pass
SDL_GPUSampler* samp = SDL_CreateGPUSampler(dev, &(SDL_GPUSamplerCreateInfo){
    .min_filter = SDL_GPU_FILTER_LINEAR, .mag_filter = SDL_GPU_FILTER_LINEAR, ...});
SDL_BindGPUFragmentSamplers(pass, 0, &(SDL_GPUTextureSamplerBinding){.texture = tex, .sampler = samp}, 1);
```

Declare `num_samplers = 1` / `num_uniform_buffers = 1` in the shader create-info
or binding fails — the counts are the contract, same strictness as UE shader
parameter structs. Full signatures: `man SDL_CreateGPUTexture`,
`man SDL_PushGPUVertexUniformData`.
