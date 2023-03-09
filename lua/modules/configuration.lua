local tbl = require("helpers.tbl")

local _configuration = { mt = {}, _private = {} }

function _configuration:setup()
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
    cmdheight = 0,
    showmode = false,
    wrap = false,
		guifont = "monospace:h13",
    clipboard = 'unnamedplus',
    mouse = 'a',
	}

	return ret
end

function _configuration.mt:__call()
	return new()
end

return setmetatable(_configuration, _configuration.mt)
