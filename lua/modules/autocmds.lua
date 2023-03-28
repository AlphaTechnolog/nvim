local tbl = require "helpers.tbl"

local _autocmds = { mt = {} }

function _autocmds:underline_cursor_at_exit()
  vim.cmd [[ autocmd VimLeave * set guicursor=n:hor10 ]]
end

function _autocmds:beam_cursor_at_exit()
  vim.cmd [[ autocmd VimLeave * set guicursor=n:ver10 ]]
end

function _autocmds:setup()
  self:underline_cursor_at_exit()
  -- self:beam_cursor_at_exit()
end

local function new()
  local ret = {}
  tbl.crush(ret, _autocmds)

  return ret
end

function _autocmds.mt:__call()
  return new()
end

return setmetatable(_autocmds, _autocmds.mt)
