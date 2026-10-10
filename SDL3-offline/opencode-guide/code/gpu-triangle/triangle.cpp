// SDL GPU hello-triangle in C++: no vertex buffers, SPIR-V shaders from disk.
// UE mental model: this file is a minimal RHI. GPUDevice ~= FRHI device,
// pipeline ~= graphics PSO, command buffer + render pass ~= RHICmdList scope.
//
// Build:  ./build.sh            (compiles shaders with glslc, then the app)
// Run:    ./gpu-triangle        (needs Vulkan + a display; shaders load from shaders/)
//
// The .spv files next to the sources were compiled here and are committed, so
// this runs in the car with zero shader tooling.
#include <SDL3/SDL.h>

#include <cstdint>
#include <fstream>
#include <iostream>
#include <memory>
#include <string>
#include <vector>

namespace {

struct WindowDeleter {
    void operator()(SDL_Window* w) const noexcept {
        if (w) SDL_DestroyWindow(w);
    }
};
using WindowPtr = std::unique_ptr<SDL_Window, WindowDeleter>;

bool sdl_check(bool ok, const char* what) {
    if (!ok) {
        std::cerr << what << " failed: " << SDL_GetError() << "\n";
    }
    return ok;
}

std::vector<std::uint8_t> load_file(const std::string& path) {
    std::ifstream f(path, std::ios::binary | std::ios::ate);
    if (!f) {
        return {};
    }
    const auto size = static_cast<std::size_t>(f.tellg());
    f.seekg(0);
    std::vector<std::uint8_t> bytes(size);
    f.read(reinterpret_cast<char*>(bytes.data()), static_cast<std::streamsize>(size));
    return bytes;
}

SDL_GPUShader* load_spirv_shader(SDL_GPUDevice* device, const std::string& path,
                                 SDL_GPUShaderStage stage) {
    const std::vector<std::uint8_t> code = load_file(path);
    if (code.empty()) {
        std::cerr << "missing shader file: " << path << "\n";
        return nullptr;
    }
    const SDL_GPUShaderCreateInfo info = {
        .code_size = code.size(),
        .code = code.data(),
        .entrypoint = "main",  // must match the shader entry point
        .format = SDL_GPU_SHADERFORMAT_SPIRV,
        .stage = stage,
        .num_samplers = 0,
        .num_storage_textures = 0,
        .num_storage_buffers = 0,
        .num_uniform_buffers = 0,
        .props = 0,
    };
    SDL_GPUShader* shader = SDL_CreateGPUShader(device, &info);
    if (!shader) {
        std::cerr << "SDL_CreateGPUShader(" << path << "): " << SDL_GetError() << "\n";
    }
    return shader;
}

}  // namespace

int main(int /*argc*/, char* /*argv*/[]) {
    if (!sdl_check(SDL_Init(SDL_INIT_VIDEO), "SDL_Init")) {
        return 1;
    }

    WindowPtr window{SDL_CreateWindow("SDL GPU triangle (opencode guide)", 800, 600,
                                      SDL_WINDOW_RESIZABLE)};
    if (!window) {
        std::cerr << "SDL_CreateWindow: " << SDL_GetError() << "\n";
        SDL_Quit();
        return 1;
    }

    // UE mental model: like selecting the RHI (D3D12/Vulkan) at startup.
    // SPIRV = the Vulkan bytecode format. `true` = enable debug layers.
    SDL_GPUDevice* device =
        SDL_CreateGPUDevice(SDL_GPU_SHADERFORMAT_SPIRV, true, nullptr);
    if (!sdl_check(device != nullptr, "SDL_CreateGPUDevice (Vulkan available?)")) {
        SDL_Quit();
        return 1;
    }

    if (!sdl_check(SDL_ClaimWindowForGPUDevice(device, window.get()),
                   "SDL_ClaimWindowForGPUDevice")) {
        SDL_DestroyGPUDevice(device);
        SDL_Quit();
        return 1;
    }
    // No manual swapchain rebuild on resize in SDL3: the swapchain is
    // re-created for you. Just pick composition + present mode once.
    SDL_SetGPUSwapchainParameters(device, window.get(),
                                  SDL_GPU_SWAPCHAINCOMPOSITION_SDR,
                                  SDL_GPU_PRESENTMODE_VSYNC);

    SDL_GPUShader* vert =
        load_spirv_shader(device, "shaders/triangle.vert.spv", SDL_GPU_SHADERSTAGE_VERTEX);
    SDL_GPUShader* frag =
        load_spirv_shader(device, "shaders/triangle.frag.spv", SDL_GPU_SHADERSTAGE_FRAGMENT);
    if (!vert || !frag) {
        SDL_ReleaseWindowFromGPUDevice(device, window.get());
        SDL_DestroyGPUDevice(device);
        SDL_Quit();
        return 1;
    }

    // UE mental model: this whole struct ~= one graphics PSO.
    // Zero-init first ({}), then set fields: no -Wall noise, no garbage.
    SDL_GPUColorTargetBlendState blend_off{};
    blend_off.src_color_blendfactor = SDL_GPU_BLENDFACTOR_ONE;
    blend_off.dst_color_blendfactor = SDL_GPU_BLENDFACTOR_ZERO;
    blend_off.color_blend_op = SDL_GPU_BLENDOP_ADD;
    blend_off.src_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ONE;
    blend_off.dst_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ZERO;
    blend_off.alpha_blend_op = SDL_GPU_BLENDOP_ADD;
    blend_off.color_write_mask = 0xF;
    blend_off.enable_blend = false;
    blend_off.enable_color_write_mask = true;

    SDL_GPUColorTargetDescription color_target{};
    color_target.format = SDL_GetGPUSwapchainTextureFormat(device, window.get());
    color_target.blend_state = blend_off;

    SDL_GPUGraphicsPipelineCreateInfo pipeline_info{};
    pipeline_info.vertex_shader = vert;
    pipeline_info.fragment_shader = frag;
    // No vertex buffers: positions come from gl_VertexIndex.
    pipeline_info.primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST;
    pipeline_info.rasterizer_state.fill_mode = SDL_GPU_FILLMODE_FILL;
    pipeline_info.rasterizer_state.cull_mode = SDL_GPU_CULLMODE_NONE;
    pipeline_info.rasterizer_state.front_face = SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE;
    pipeline_info.multisample_state.sample_count = SDL_GPU_SAMPLECOUNT_1;
    // No depth buffer attached: keep depth/stencil fully off.
    pipeline_info.depth_stencil_state.compare_op = SDL_GPU_COMPAREOP_ALWAYS;
    pipeline_info.target_info.color_target_descriptions = &color_target;
    pipeline_info.target_info.num_color_targets = 1;
    SDL_GPUGraphicsPipeline* pipeline = SDL_CreateGPUGraphicsPipeline(device, &pipeline_info);
    // Shaders can be released right after pipeline creation (like compiled
    // shader bytecode after PSO creation in UE): the pipeline holds its own.
    SDL_ReleaseGPUShader(device, vert);
    SDL_ReleaseGPUShader(device, frag);
    if (!sdl_check(pipeline != nullptr, "SDL_CreateGPUGraphicsPipeline")) {
        SDL_ReleaseWindowFromGPUDevice(device, window.get());
        SDL_DestroyGPUDevice(device);
        SDL_Quit();
        return 1;
    }

    bool running = true;
    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_EVENT_QUIT) {
                running = false;
            } else if (event.type == SDL_EVENT_KEY_DOWN &&
                       event.key.key == SDLK_ESCAPE) {
                running = false;
            }
        }

        // UE mental model: one loop iteration ~= one Tick + one RHI frame.
        SDL_GPUCommandBuffer* cmd = SDL_AcquireGPUCommandBuffer(device);
        if (!cmd) {
            std::cerr << "AcquireGPUCommandBuffer: " << SDL_GetError() << "\n";
            break;
        }
        SDL_GPUTexture* swapchain = nullptr;
        std::uint32_t w = 0, h = 0;
        if (!SDL_AcquireGPUSwapchainTexture(cmd, window.get(), &swapchain, &w, &h)) {
            std::cerr << "AcquireGPUSwapchainTexture: " << SDL_GetError() << "\n";
            SDL_CancelGPUCommandBuffer(cmd);
            break;
        }
        if (!swapchain) {
            // Minimized / size-zero: nothing to draw into this frame.
            SDL_CancelGPUCommandBuffer(cmd);
            continue;
        }

        SDL_GPUColorTargetInfo target{};
        target.texture = swapchain;
        target.clear_color = {0.06f, 0.07f, 0.10f, 1.0f};
        target.load_op = SDL_GPU_LOADOP_CLEAR;
        target.store_op = SDL_GPU_STOREOP_STORE;
        SDL_GPURenderPass* pass = SDL_BeginGPURenderPass(cmd, &target, 1, nullptr);
        SDL_BindGPUGraphicsPipeline(pass, pipeline);
        SDL_DrawGPUPrimitives(pass, 3, 1, 0, 0);  // 3 verts, 1 instance
        SDL_EndGPURenderPass(pass);
        SDL_SubmitGPUCommandBuffer(cmd);
    }

    // UE mental model: RHI resource teardown before device destruction,
    // reverse order of creation (window is a unique_ptr, dies after this).
    SDL_ReleaseGPUGraphicsPipeline(device, pipeline);
    SDL_ReleaseWindowFromGPUDevice(device, window.get());
    SDL_DestroyGPUDevice(device);
    window.reset();
    SDL_Quit();
    return 0;
}
