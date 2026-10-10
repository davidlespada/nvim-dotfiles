-- Keymaps (mostly base Neovim; Telescope pickers need telescope.nvim).
-- All <leader> mappings have a `desc` so which-key shows them.
-- Groups themselves (file, buffer, ...) are declared in
-- lua/plugins/init.lua via which-key `opts.spec` (lazy-safe).

local map = vim.keymap.set

-- File (Spacemacs-style: <leader>f ...)
map("n", "<leader>fs", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>fS", "<cmd>wa<cr>", { desc = "Save all files" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })
map("n", "<leader>fe", ":e ", { desc = "Open file (:e)" })
map("n", "<leader>fR", "<cmd>e!<cr>", { desc = "Reload file from disk" })
map("n", "<leader>fY", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
  vim.notify("Copied: " .. vim.fn.expand("%:p"), vim.log.levels.INFO)
end, { desc = "Copy full path" })
map("n", "<leader>fc", "<cmd>e $MYVIMRC<cr>", { desc = "Edit config (init.lua)" })
map("n", "<leader>fk", function()
  vim.cmd("e " .. vim.fn.stdpath("config") .. "/lua/config/keymaps.lua")
end, { desc = "Edit keymaps" })
map("n", "<leader>fr", "<cmd>source $MYVIMRC<cr>", { desc = "Reload config" })
map("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files (telescope)" })
map("n", "<leader>fo", function()
  require("telescope.builtin").oldfiles()
end, { desc = "Recent files (telescope)" })

-- Explorer (neo-tree.nvim, files only - buffers via Telescope <leader>bl)
-- Only 3 to remember:
--   <leader>ee / <C-n> : toggle file tree
--   <C-e>             : jump tree <-> code
--   <leader>ef        : focus tree + reveal current file
-- Inside tree: ? help, a create, d delete, r rename, y copy, x cut, p paste,
--   R refresh, H hidden toggle, S pick window, s/vsplit, o open, <CR> open, q close.
local function neotree_focus_code()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft ~= "neo-tree" and ft ~= "neo-tree-popup" and ft ~= "notify" then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.cmd("wincmd p")
end

local function neotree_toggle_focus()
  local ft = vim.bo.filetype
  if ft == "neo-tree" or ft == "neo-tree-popup" then
    neotree_focus_code()
  else
    vim.cmd("Neotree focus source=filesystem position=left reveal=true")
  end
end

map("n", "<leader>ee", "<cmd>Neotree toggle source=filesystem position=left reveal=true<cr>", { desc = "Explorer toggle" })
map("n", "<leader>ef", "<cmd>Neotree focus source=filesystem position=left reveal=true<cr>", { desc = "Focus explorer" })
map("n", "<leader>ew", neotree_focus_code, { desc = "Focus code" })
map("n", "<leader>ec", "<cmd>Neotree close<cr>", { desc = "Explorer close" })
map("n", "<C-n>", "<cmd>Neotree toggle source=filesystem position=left reveal=true<cr>", { desc = "Explorer toggle" })
map("n", "<C-e>", neotree_toggle_focus, { desc = "Explorer jump tree<->code" })

-- Buffers
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Switch to alternate" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprev<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete buffer (force)" })
map("n", "<leader>bl", function()
  require("telescope.builtin").buffers()
end, { desc = "Buffers (telescope)" })
map("n", "<leader>bf", "<cmd>bfirst<cr>", { desc = "First buffer" })
map("n", "<leader>bL", "<cmd>blast<cr>", { desc = "Last buffer" })
map("n", "<leader>bo", "<cmd>%bd|e#|bd#<cr>", { desc = "Close other buffers" })

-- Windows / splits (no plugin needed for open; picker for jump)
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<leader>ww", function()
  local picked = require("window-picker").pick_window()
  if picked then
    vim.api.nvim_set_current_win(picked)
  end
end, { desc = "Pick window" })
map("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Close other windows" })
map("n", "<leader>we", "<C-w>=", { desc = "Equalize windows" })
map("n", "<leader>wh", "<C-w>h", { desc = "Go left" })
map("n", "<leader>wj", "<C-w>j", { desc = "Go down" })
map("n", "<leader>wk", "<C-w>k", { desc = "Go up" })
map("n", "<leader>wl", "<C-w>l", { desc = "Go right" })
map("n", "<leader>wH", "<C-w>H", { desc = "Move window left" })
map("n", "<leader>wJ", "<C-w>J", { desc = "Move window down" })
map("n", "<leader>wK", "<C-w>K", { desc = "Move window up" })
map("n", "<leader>wL", "<C-w>L", { desc = "Move window right" })
map("n", "<leader>w+", "<C-w>+", { desc = "Increase height" })
map("n", "<leader>w-", "<C-w>-", { desc = "Decrease height" })
map("n", "<leader>w<lt>", "<C-w><lt>", { desc = "Decrease width" })
map("n", "<leader>w>", "<C-w>>", { desc = "Increase width" })
map("n", "<C-Up>", "<C-w>+", { desc = "Increase height" })
map("n", "<C-Down>", "<C-w>-", { desc = "Decrease height" })
map("n", "<C-Left>", "<C-w><lt>", { desc = "Decrease width" })
map("n", "<C-Right>", "<C-w>>", { desc = "Increase width" })

-- Tabs + terminal (combined to avoid <leader>t conflicts)
map("n", "<leader>ta", "<cmd>tabnew<cr>", { desc = "New tab" })
map("n", "<leader>tx", "<cmd>tabclose<cr>", { desc = "Close tab" })
map("n", "<leader>to", "<cmd>tabonly<cr>", { desc = "Close other tabs" })
map("n", "<leader>tn", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "<leader>tp", "<cmd>tabprev<cr>", { desc = "Previous tab" })
map("n", "<leader>tf", "<cmd>tabfirst<cr>", { desc = "First tab" })
map("n", "<leader>tl", "<cmd>tablast<cr>", { desc = "Last tab" })
map("n", "<leader>te", "<cmd>terminal<cr><cmd>startinsert<cr>", { desc = "Terminal here" })
map("n", "<leader>tv", "<cmd>vsplit | terminal<cr><cmd>startinsert<cr>", { desc = "Terminal vertical" })
map("n", "<leader>th", "<cmd>split | terminal<cr><cmd>startinsert<cr>", { desc = "Terminal horizontal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Quit / session
map("n", "<leader>qq", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>qQ", "<cmd>q!<cr>", { desc = "Quit (force)" })
map("n", "<leader>qa", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>qA", "<cmd>qa!<cr>", { desc = "Quit all (force)" })
map("n", "<leader>qw", "<cmd>wq<cr>", { desc = "Save and quit" })
map("n", "<leader>qW", "<cmd>wqa<cr>", { desc = "Save all and quit" })
map("n", "<leader>qs", "<cmd>mksession! Session.vim<cr>", { desc = "Save session" })
map("n", "<leader>ql", "<cmd>source Session.vim<cr>", { desc = "Load session" })

-- Search / replace (telescope pickers need telescope.nvim)
map("n", "<leader>sh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
map("n", "<leader>ss", ":%s/\\v//g<Left><Left><Left>", { desc = "Substitute in file" })
map("n", "<leader>sw", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>", { desc = "Substitute word under cursor" })
map("v", "<leader>ss", ":s/\\v//g<Left><Left><Left>", { desc = "Substitute in selection" })
map("n", "<leader>sg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Live grep (telescope)" })
map("n", "<leader>sG", function()
  require("telescope.builtin").grep_string()
end, { desc = "Grep word under cursor (telescope)" })
map("n", "<leader>sb", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { desc = "Fuzzy find in buffer (telescope)" })
map("n", "<leader>sr", function()
  require("telescope.builtin").resume()
end, { desc = "Resume last picker (telescope)" })
map("n", "<leader>sc", function()
  require("telescope.builtin").commands()
end, { desc = "Commands (telescope)" })

-- History
map("n", "<leader>sH", "<cmd>LocalHistoryToggle<cr>", {desc = "Show file history"})

-- Quickfix / location list
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix open" })
map("n", "<leader>xc", "<cmd>cclose<cr>", { desc = "Quickfix close" })
map("n", "<leader>xn", "<cmd>cnext<cr>", { desc = "Quickfix next" })
map("n", "<leader>xp", "<cmd>cprev<cr>", { desc = "Quickfix prev" })
map("n", "<leader>xQ", "<cmd>lopen<cr>", { desc = "Location open" })
map("n", "<leader>xC", "<cmd>lclose<cr>", { desc = "Location close" })
map("n", "<leader>xN", "<cmd>lnext<cr>", { desc = "Location next" })
map("n", "<leader>xP", "<cmd>lprev<cr>", { desc = "Location prev" })

-- Toggles (base :set options)
map("n", "<leader>on", "<cmd>set number!<cr>", { desc = "Toggle line numbers" })
map("n", "<leader>or", "<cmd>set relativenumber!<cr>", { desc = "Toggle relative numbers" })
map("n", "<leader>ow", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
map("n", "<leader>os", "<cmd>set spell!<cr>", { desc = "Toggle spell" })
map("n", "<leader>oc", "<cmd>set cursorline!<cr>", { desc = "Toggle cursorline" })
map("n", "<leader>oh", "<cmd>set hlsearch!<cr>", { desc = "Toggle search highlight" })
map("n", "<leader>ot", "<cmd>set list!<cr>", { desc = "Toggle whitespace (list)" })
map("n", "<leader>ob", function()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
  vim.notify("background=" .. vim.o.background, vim.log.levels.INFO)
end, { desc = "Toggle background" })

-- Clipboard / yank (system clipboard via + register)
map({ "n", "v" }, "<leader>yy", '"+y', { desc = "Copy to system" })
map("n", "<leader>yY", '"+Y', { desc = "Copy line to system" })
map({ "n", "v" }, "<leader>yp", '"+p', { desc = "Paste from system" })
map("n", "<leader>yP", '"+P', { desc = "Paste before from system" })
map({ "n", "v" }, "<leader>yd", '"_d', { desc = "Delete without yanking" })

-- Diagnostics (works now, required once you add LSP)
map("n", "<leader>df", vim.diagnostic.open_float, { desc = "Line diagnostics (float)" })
map("n", "<leader>dn", function()
  vim.diagnostic.jump({ count = 1 })
end, { desc = "Next diagnostic" })
map("n", "<leader>dp", function()
  vim.diagnostic.jump({ count = -1 })
end, { desc = "Prev diagnostic" })
map("n", "<leader>dl", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })
map("n", "<leader>dq", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
map("n", "<leader>dd", function()
  require("telescope.builtin").diagnostics()
end, { desc = "Diagnostics picker (telescope)" })

-- Navigate / jump (yes, a bunch is possible -- these are the base builtins
-- worth making discoverable; single-key motions like gg/G/H/M/L/%/f/t
-- stay as-is and are covered by which-key presets)
map("n", "<leader>ng", function()
  vim.ui.input({ prompt = "Go to line: " }, function(input)
    local n = tonumber(input or "")
    if n then
      vim.cmd("normal! " .. n .. "Gzz")
    end
  end)
end, { desc = "Go to line number ..." })
map("n", "<leader>nf", "gg", { desc = "First line" })
map("n", "<leader>nl", "Gzz", { desc = "Last line" })
map("n", "<leader>nj", "<C-o>", { desc = "Jump back" })
map("n", "<leader>nk", "<C-i>", { desc = "Jump forward" })
map("n", "<leader>nc", "g;", { desc = "Older change" })
map("n", "<leader>nC", "g,", { desc = "Newer change" })
map("n", "<leader>nd", "<C-]>", { desc = "Go to definition (tag)" })
map("n", "<leader>no", "gf", { desc = "Open file under cursor" })
map("n", "<leader>nv", "<C-w>f", { desc = "Open file (vsplit)" })
map("n", "<leader>nt", "<C-w>gf", { desc = "Open file (new tab)" })
map("n", "<leader>nm", "<cmd>marks<cr>", { desc = "List marks" })
-- HopWord on direct key: overrides builtin H (top of screen)
map("n", "H", "<cmd>HopWord<cr>", { desc = "Hop word" })
map("n", "<leader>nw", "<cmd>HopWord<cr>", { desc = "Hop word" })
map("n", "<leader>ns", "<cmd>HopLineStart<cr>", { desc = "Hop line start" })
map("n", "<leader>nn", "<cmd>HopNodes<cr>", { desc = "Hop nodes (treesitter)" })

-- Help / info (base discovery)
map("n", "<leader>hh", ":help ", { desc = "Help (:help)" })
map("n", "<leader>hk", function()
  require("telescope.builtin").keymaps()
end, { desc = "Keymaps (telescope)" })
map("n", "<leader>ht", function()
  require("telescope.builtin").help_tags()
end, { desc = "Help tags (telescope)" })
map("n", "<leader>hm", "<cmd>messages<cr>", { desc = "Messages" })
map("n", "<leader>hc", "<cmd>checkhealth<cr>", { desc = "Checkhealth" })
map("n", "<leader>ho", ":set ", { desc = "Option (:set)" })
map("n", "<leader>hO", "<cmd>set all<cr>", { desc = "All options" })
map("n", "<leader>hv", "<cmd>version<cr>", { desc = "Version" })
map("n", "<leader>hl", "<cmd>Lazy<cr>", { desc = "Lazy UI" })

-- Small quality-of-life improvements (non-leader, still documented)
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>w<cr>a", { desc = "Save file" })
map("v", "<C-s>", "<Esc><cmd>w<cr>", { desc = "Save file" })
map("v", "<", "<gv", { desc = "Indent left (stay visual)" })
map("v", ">", ">gv", { desc = "Indent right (stay visual)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up (centered)" })
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })
