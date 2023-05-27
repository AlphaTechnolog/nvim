local _loader = { mt = {} }

function _loader:install_lazy()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end

  vim.opt.rtp:prepend(lazypath)
end

function _loader:configure_lazy()
  require("lazy").setup(require("plugins.register"), {
    git = {
      timeout = 9999,
    }
  })
end

local function new()
  local self = vim.tbl_extend("force", {}, _loader)

  return self
end

function _loader.mt:__call()
  return new()
end

return setmetatable(_loader, _loader.mt)
