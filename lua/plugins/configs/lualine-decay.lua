local lualine = require "lualine"
local colors = require("decay.core").get_colors "default"
local decay_theme = require "lualine.themes.decay"

colors.contrast = '#0c0d11'

decay_theme.normal.c.bg = colors.contrast

for _, mode in ipairs {'normal', 'insert', 'command', 'visual', 'replace', 'inactive'} do
    decay_theme[mode].b.bg = colors.contrast
end

local function mksections()
    local sections = {}

    for _, i in ipairs({'a', 'b', 'c', 'x', 'y', 'z' }) do
        sections["lualine_" .. i] = {}
    end

    return sections
end

local sections = mksections()

local function ins_left(component)
    table.insert(sections.lualine_c, component)
end

local function ins_right(component)
    table.insert(sections.lualine_x, component)
end

-- left part
ins_left {
    function ()
        return '│'
    end,
    padding = { left = 0, right = 0 },
    color = { fg = colors.lavender }
}

ins_left {
    function ()
        return ''
    end,
    padding = { right = 1, left = 1 },
    color = function ()
        local mode_color = {
            n = colors.teal,
            i = colors.lavender,
            v = colors.magenta,
            [''] = colors.blue,
            V = colors.blue,
            c = colors.green,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [''] = colors.orange,
            ic = colors.yellow,
            R = colors.red,
            Rv = colors.red,
            cv = colors.orange,
            ce = colors.orange,
            r = colors.cyan,
            rm = colors.cyan,
            ['r?'] = colors.cyan,
            ['!'] = colors.red,
            t = colors.teal,
        }

        return { fg = mode_color[vim.fn.mode()] }
    end
}

local function isnt_empty_buffer()
    return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
end

ins_left {
    'filesize',
    cond = isnt_empty_buffer
}

ins_left {
    'filename',
    cond = isnt_empty_buffer,
    color = { fg = colors.lavender, gui = 'italic' }
}

ins_left {
    'progress',
    color = { fg = colors.magenta },
    gui = 'bold'
}

ins_left {
    'diagnostics',
    sources = { 'nvim_diagnostic' },
    symbols = { error = ' ', warn = ' ', info = ' ' },
    diagnostics_color = {
        color_error = { fg = colors.red },
        color_warn = { fg = colors.orange },
        color_info = { fg = colors.teal }
    },
}

-- mid section.
ins_left {
    function ()
        return '%='
    end
}

-- right part
local function capitalize(txt)
    return txt:gsub("^%l", string.upper)
end

ins_right {
    color = { fg = colors.lavender, gui = 'bold' },
    function ()
        local filetype = capitalize(vim.bo.filetype)
        if filetype == '' then
            return "NeoVim"
        end

        return filetype
    end,
}

ins_right {
    'branch',
    icon = '',
    color = { fg = colors.magenta, gui = 'bold' }
}

lualine.setup {
    sections = sections,
    inactive_sections = mksections(),
    options = {
        theme = decay_theme,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
    },
}
