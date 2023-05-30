local present, treesitter = pcall(require, "nvim-treesitter.configs")

if not present then
  return
end

require "nvim-treesitter.install".compilers = {
  "gcc", "g++"
}

treesitter.setup {
  ensure_installed = {
    "c",
    "cpp",
    "vim",
    "lua",
    "javascript",
    "typescript",
    "tsx",
    "python",
    "java",
    "php",
    "html",
    "css",
    "bash",
    "nix"
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = true,
  }
}
