local function map(mode, key, cmd)
  vim.api.nvim_set_keymap(mode, key, cmd, { noremap = true, silent = true })
end

local keys = {"jk", "kj", "jj", "kk"}
for _, key in ipairs(keys) do
  map('i', key, "<esc>")
end

local navkeys = {"h", "j", "k", "l"}
for _, key in ipairs(navkeys) do
  map('n', '<C-' .. key .. '>', '<C-w>' .. key)
end

map('n', '<Tab>', '<cmd>bn!<cr>')
map('n', '<S-Tab>', '<cmd>bp!<cr>')
map('n', '<C-b>', '<cmd>bd!<cr>')
map('n', '<space>x', '<cmd>bd!<cr>')

map('n', '<C-s>', '<cmd>w!<cr>')
map('n', '<C-q>', '<cmd>wq!<cr>')
