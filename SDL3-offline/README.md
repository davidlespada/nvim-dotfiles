# SDL3 offline bundle (car-ready, no internet needed)

Prepared 2026-10-10, SDL 3.4.18. Everything below works with zero network.

## Layout

```
~/Projects/SDL3-offline/
  README.md                <- you are here
  SDL3-CHEATSHEET.md       <- learn SDL3 in 10 min, start here
  starter/                 <- runnable hello-window (main.c + Makefile + CMakeLists.txt)
  docs/
    sdlwiki/sdlwiki/       <- full SDL wiki, 7,614 HTML pages
    man/man3/              <- 1,922 man pages (also installed to ~/.local/share/man)
  SDL-src/
    examples/              <- 39 official public-domain .c examples
    docs/                  <- READMEs (cmake, main-functions, migration, platforms)
    include/               <- SDL headers (same version as /usr/include/SDL3)
```

## Use in the car

1. **Learn**: read `SDL3-CHEATSHEET.md`, run `starter/sdl3-starter` (already built).
2. **Docs**: open `docs/sdlwiki/sdlwiki/SDL3/FrontPage.html` in any browser
   (double-click, or `xdg-open docs/sdlwiki/sdlwiki/SDL3/FrontPage.html`).
   Browse via `.../SDL3/APIByCategory.html` or `.../SDL3/QuickReference.html`.
3. **Man pages** (no browser needed):
   `man -M ~/Projects/SDL3-offline/docs/man SDL_CreateWindow`
   (also plain `man SDL_CreateWindow` via `~/.local/share/man` — if that fails,
   `export MANPATH="$HOME/.local/share/man:$MANPATH"`).
4. **Examples**: `ls SDL-src/examples/renderer/` — each dir has one `.c` file.
   Compile any single file, e.g.:
   `gcc $(pkg-config --cflags sdl3) -o /tmp/ex SDL-src/examples/renderer/01-clear/clear.c $(pkg-config --libs sdl3)`
5. **New project**: copy `starter/` (`cp -r starter mygame`), edit `main.c`, `make`.
6. **Headers**: `grep -rn "SDL_Render" /usr/include/SDL3/ | head`, or open in nvim.

## Before you leave (needs internet, run once)

```bash
# satellite libs (image/mixer/net) — you have sdl3 + sdl3_ttf; these add PNG/JPG, audio mixing, net:
sudo pacman -S --needed sdl3_image sdl3_mixer sdl3_net
# optional: a font lib is already installed (sdl3_ttf). Nerd Font for the devicons in nvim:
sudo pacman -S --needed ttf-jetbrains-mono-nerd
# refresh this bundle afterwards (examples move fast):
cd ~/Projects/SDL3-offline/SDL-src && git pull --depth 1
```

## Verified working offline (2026-10-10)

- `make` in `starter/` → 17 KB binary ✓
- `cmake` build in starter ✓
- `gcc` build of official `examples/renderer/01-clear/clear.c` ✓
- `man -M docs/man SDL_CreateWindow` ✓
- wiki `SDL3/FrontPage.html` present (7,614 pages) ✓

## Notes

- SDL headers/libs on disk: `pkg-config --cflags --libs sdl3` → `-lSDL3`, version 3.4.18.
- Examples are public domain — copy/paste freely into your own code.
- The official examples use the `SDL_AppInit/SDL_AppIterate` callback style;
  `starter/main.c` uses classic `main()` instead. Both link the same way.
  Callback explainer: `SDL-src/docs/README-main-functions.md`.
