-- imports
local theme = require "lualine.themes.decay"
local colors = require "decay.core" .get_colors("default")

-- overriding decay's invisibility for center modules into a right color
theme.normal.c.fg = colors.teal
theme.normal.c.bg = colors.statusline_bg

---@diagnostic disable-next-line: undefined-global
local capi = { vim = vim }

-- ==helpers
local function init_secs()
  local secs = {}
  local keys = {'a', 'b', 'c', 'x', 'y', 'z'}
  for _, key in ipairs(keys) do
    secs['lualine_' .. key] = {}
  end

  return secs
end

local sections = init_secs()

local function ins(opts)
  table.insert(sections['lualine_' .. opts.where], opts.what)
end

-- left components

-- * mode
ins {
  where = 'a',
  what = {
    'mode',
    separator = { right = '', left = '' },
    fmt = function (txt)
      return ' ' .. txt:sub(1, 1):gsub("^%l", string.upper) .. string.lower(txt:sub(2))
    end
  }
}

-- * file-related
ins {
  where = 'b',
  what = {
    'filetype',
    colored = true,
    icon_only = true,
    separator = { left = '', right = '' },
    color = { fg = colors.background, bg = colors.lighter },
    icon = { align = 'left' },
  }
}

ins {
  where = 'b',
  what = {
    'filename',
    file_status = false,
    new_file_status = false,
    path = 0,
    color = { fg = colors.foreground, bg = colors.lighter },
    separator = { right = '', left = '' },
    symbols = {
      modified = ' ',
      readonly = ' ',
      unnamed = ' Empty',
      newfile = ' '
    }
  }
}

-- * diagnostics
ins {
  where = 'b',
  what = {
    'diagnostics',
    sources = { 'nvim_diagnostic' },
    symbols = { error = ' ', warn = ' ', info = ' ' },
    separator = { left = '', right = '' },
    color = { bg = colors.statusline_bg },
    diagnostics_color = {
      color_error = { fg = colors.red },
      color_warn = { fg = colors.orange },
      color_info = { fg = colors.teal },
    },
  }
}

-- center components

-- * lsp
ins {
  where = 'c',
  what = {
    separator = { left = '', right = '' },
    function ()
      return '%='
    end
  }
}

ins {
  where = 'c',
  what = {
    icon = '  LSP:',
    separator = { left = '', right = '' },
    function ()
      -- thanks to the evil lualine example
      local msg = 'No Active Lsp'
      local buf_ft = capi.vim.api.nvim_buf_get_option(0, 'filetype')
      local clients = capi.vim.lsp.get_active_clients()
      if next(clients) == nil then
        return msg
      end
      for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and capi.vim.fn.index(filetypes, buf_ft) ~= -1 then
          return client.name
        end
      end
      return msg
    end
  }
}

-- right components

-- * hostname
ins {
  where = 'y',
  what = {
    function ()
      return ''
    end,
    color = { bg = colors.magenta, fg = colors.background },
    separator = { left = '', right = '' },
  }
}

ins {
  where = 'y',
  what = {
    'hostname',
    color = { bg = colors.statusline_bg, fg = colors.foreground }
  }
}

-- * location
ins {
  where = 'z',
  what = {
    function ()
      return ''
    end,
    color = { bg = colors.green, fg = colors.background },
    separator = { left = '', right = '' }
  }
}

ins {
  where = 'z',
  what = {
    'location',
    color = { bg = colors.statusline_bg, fg = colors.foreground }
  }
}

-- == applying config
require "lualine".setup {
  options = { theme = theme },
  sections = sections,
  inactive_sections = init_secs()
}
