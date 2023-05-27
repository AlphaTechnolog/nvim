vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("nvim-tree").setup({
  view = {
    cursorline = false,
    width = 40,
  },
  renderer = {
    root_folder_label = false
  }
})
