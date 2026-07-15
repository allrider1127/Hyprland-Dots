-- ========================================================================== --
--  MINIMAL HIGH-PERFORMANCE NEOCONFIG (BLAZING FAST & ULTRA-STABLE)
-- ========================================================================== --

-- 1. Core UI Settings & Clipboard Sync
vim.opt.termguicolors = true
vim.opt.number = true             -- Show line numbers
vim.opt.clipboard = "unnamedplus" -- Shared system clipboard
vim.opt.swapfile = false          -- Disable swap files (prevents annoying W325 warning prompts)

-- 2. Prevent Treesitter Errors for Missing Parsers (Bulletproof Wrapper)
-- In some systems/versions, opening a file triggers Treesitter before its
-- parser is downloaded/installed, causing a blocking startup error.
-- We wrap vim.treesitter.start to silently fall back to standard Vim highlighting
-- until the compiler finishes building the parser.
local ts_start = vim.treesitter.start
vim.treesitter.start = function(bufnr, lang)
  bufnr = bufnr or 0
  lang = lang or vim.bo[bufnr].filetype

  if not lang or lang == "" then
    return
  end

  -- Safely check if a parser is available
  local ok, _ = pcall(vim.treesitter.get_parser, bufnr, lang)
  if ok then
    return ts_start(bufnr, lang)
  else
    -- Fallback to standard Vim regex syntax highlighting
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("syntax on")
    end)
  end
end

-- 3. Bootstrap lazy.nvim (Plugin manager framework)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 4. Configure & Load Plugins
require("lazy").setup({
  -- High-performance Treesitter syntax engine
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- Pin to the stable master branch for compatibility with Neovim 0.10
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        -- Pre-install parsers for your core languages & document/config formats
        ensure_installed = { 
          "c", "cpp", "lua", "bash", "python", "rust", "c_sharp", "vim", "vimdoc",
          "latex", "markdown", "markdown_inline", "yaml", "json", "html", "css", "make", "dockerfile", "query"
        },
        sync_install = false, -- install asynchronously in background
        auto_install = true,  -- automatically install missing parsers on file open!
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      })
    end,
  },
})

-- 5. Safe Global Fallback: Force C++ styling on extensionless files (like OpenFOAM U, p, etc.)
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*",
  callback = function()
    -- Skip special buffers (like terminals, help, quickfix, etc.)
    if vim.bo.buftype ~= "" then
      return
    end

    -- Get file path and extension
    local path = vim.fn.expand("%:p")
    local ext = vim.fn.expand("%:e")
    
    -- Skip directories
    if vim.fn.isdirectory(path) == 1 then
      return
    end
    
    -- If the file has NO extension, and is plain/empty filetype, set to C++
    if ext == "" and (vim.bo.filetype == "" or vim.bo.filetype == "text") then
      vim.bo.filetype = "cpp"
    end
  end,
})

-- 6. Lock the Industry Theme permanently
vim.cmd.colorscheme("industry")
