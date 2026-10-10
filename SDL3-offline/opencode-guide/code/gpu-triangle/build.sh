#!/usr/bin/env bash
# Offline build for the GPU triangle. Needs: g++, glslc, SDL3 (all present).
set -euo pipefail
cd "$(dirname "$0")"

echo "==> compiling shaders (GLSL -> SPIR-V)"
glslc -fshader-stage=vert shaders/triangle.vert -o shaders/triangle.vert.spv
glslc -fshader-stage=frag shaders/triangle.frag -o shaders/triangle.frag.spv
if command -v spirv-val >/dev/null; then
  for spv in shaders/*.spv; do spirv-val "$spv" && echo "spirv-val OK: $spv"; done
fi

echo "==> compiling app"
g++ -Wall -Wextra -std=c++17 $(pkg-config --cflags sdl3) -o gpu-triangle triangle.cpp $(pkg-config --libs sdl3)

echo "==> done. Run from THIS dir (shaders load via relative path): ./gpu-triangle"
