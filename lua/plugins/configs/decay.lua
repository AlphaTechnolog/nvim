local present, decay = pcall(require, "decay")

if not present then
    return
end

-- in the refactor branch, default is the newer palette for decayce
local STYLE = "default"
local colors = require("decay.core").get_colors(STYLE)

colors.contrast = "#0c0d11"

decay.setup {
    style = STYLE,
    italics = {
        comments = true,
        code = true,
    },
    cmp = {
        block_kind = false,
    },
    nvim_tree = {
        contrast = true
    },
    palette_overrides = {
        contrast = colors.contrast,
    },
    override = {
        ["NvimTreeWinSeparator"] = { fg = colors.contrast, bg = colors.contrast }
    },
}
