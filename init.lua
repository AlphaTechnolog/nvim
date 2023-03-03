local Core = require("core")
local core = Core()

-- defining some globals

---@diagnostic disable-next-line: undefined-global
Vim = vim
Api = Vim.api
Cmd = Vim.cmd
Fn = Vim.fn
G = Vim.g
Opt = Vim.opt
Bo = Vim.bo
Wo = Vim.wo

for _, mod in ipairs(core:modules()) do
	core:load_mod(mod)
end
