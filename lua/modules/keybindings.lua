local tbl = require("helpers.tbl")

local _keybindings = { mt = {}, _private = {} }

function _keybindings:populate_gotonormal()
	for _, key in ipairs(self._private.control_keys) do
		Api.nvim_set_keymap("i", key, "<esc>", { noremap = true, silent = true })
	end
end

function _keybindings:populate_buffnavigation()
	for _, key in ipairs(self._private.navkeys) do
		Api.nvim_set_keymap("n", "<C-" .. key .. ">", "<C-W>" .. key, { noremap = true, silent = true })
	end

  Api.nvim_set_keymap('n', '<Tab>', '<cmd>bn!<cr>', { noremap = true, silent = true })
  Api.nvim_set_keymap('n', '<S-Tab>', '<cmd>bp!<cr>', { noremap = true, silent = true })
end

function _keybindings:global_maps()
  Api.nvim_set_keymap('n', '<C-s>', '<cmd>w!<cr>', { noremap = true, silent = true })
  Api.nvim_set_keymap('n', '<C-q>', '<cmd>qa!<cr>', { noremap = true, silent = true })
  Api.nvim_set_keymap('n', '<C-b>', '<cmd>bd!<cr>', { noremap = true, silent = true })
  Api.nvim_set_keymap('n', '<space>x', '<cmd>bd!<cr>', { noremap = true, silent = true })
end

function _keybindings:telescope_maps()
	Api.nvim_set_keymap("n", "<C-p>", "<cmd>Telescope find_files<cr>", { silent = true, noremap = true })
	Api.nvim_set_keymap("n", "<space>ff", "<C-p>", { silent = true, noremap = true })
end

function _keybindings:tree_maps()
  Api.nvim_set_keymap('n', '<C-n>', '<cmd>NvimTreeToggle<cr>', { silent = true, noremap = true })
end

function _keybindings:trouble_maps()
  Api.nvim_set_keymap('n', '<space>xx', '<cmd>TroubleToggle<cr>', { silent = true, noremap = true })
end

function _keybindings:setup()
	self:populate_gotonormal()
	self:populate_buffnavigation()
  self:global_maps()
	self:telescope_maps()
  self:tree_maps()
  self:trouble_maps()
end

local function new()
	local ret = {}
	tbl.crush(ret, _keybindings)

	ret._private.control_keys = { "jj", "kk", "jk", "kj" }
	ret._private.navkeys = { "h", "j", "k", "l" }

	return ret
end

function _keybindings.mt:__call()
	return new()
end

return setmetatable(_keybindings, _keybindings.mt)
