vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.laststatus = 3
vim.opt.wrap = false
vim.opt.showmode = false

vim.cmd [[ autocmd VimLeave * set guicursor=n:ver10 ]]
