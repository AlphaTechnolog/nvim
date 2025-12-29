---@diagnostic disable-next-line: undefined-global
local vim = vim
require("fennel").install().dofile(vim.fn.stdpath("config") .. "/fnl/main.fnl")
