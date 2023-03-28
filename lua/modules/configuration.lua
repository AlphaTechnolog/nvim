local tbl = require("helpers.tbl")

local _configuration = { mt = {}, _private = {} }

function _configuration:specific_languages()
  Vim.cmd [[ autocmd FileType go setlocal tabstop=4 shiftwidth=4 expandtab ]]
  Vim.cmd [[ autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab ]]
  Vim.cmd [[ autocmd FileType php setlocal tabstop=4 shiftwidth=4 expandtab nosmartindent ]]
  Vim.cmd [[ autocmd FileType nix setlocal nosmartindent ]]
end

function _configuration:setup()
  self:specific_languages()
	for k, v in pairs(self._private.options) do
		Opt[k] = v
	end
end

local function new()
	local ret = {}
	tbl.crush(ret, _configuration)

	ret._private.options = {
		number = true,
		relativenumber = true,
		cursorline = false,
		tabstop = 2,
		shiftwidth = 2,
		expandtab = true,
		smartindent = true,
		autoindent = true,
		laststatus = 0,
    cmdheight = 1,
    showmode = false,
    wrap = false,
		guifont = "monospace:h14",
    clipboard = 'unnamedplus',
    mouse = 'a',
    guicursor = "i:hor10"
	}

	return ret
end

function _configuration.mt:__call()
	return new()
end

return setmetatable(_configuration, _configuration.mt)
