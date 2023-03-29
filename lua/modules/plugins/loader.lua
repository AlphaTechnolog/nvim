local tbl = require("helpers.tbl")

local _loader = { mt = {}, _private = {} }

function _loader:install_lazy()
	local lazypath = Vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	local lazyurl = "https://github.com/folke/lazy.nvim.git"

	if not Vim.loop.fs_stat(lazypath) then
		print("Installing lazy")

		Fn.system({
			"git",
			"clone",
			"--filter=blob:none",
			lazyurl,
			"--branch=stable", -- latest stable release
			lazypath,
		})
	end

	Opt.rtp:prepend(lazypath)
end

local function has_words_before()
  unpack = unpack or table.unpack
  local line, col = unpack(Vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and Vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
end

function _loader:load_plugins()
	G.mapleader = " "

	if not tbl.contain_key(self._private, "lazy") then
		self._private.lazy = require("lazy")
	end

	self._private.lazy.setup({
    {
      "jose-elias-alvarez/null-ls.nvim",
      after = "mason.nvim",
      config = function ()
        -- what an awesome plugin!
        local null_ls = require("null-ls")

        -- applying sources
        null_ls.setup {
          sources = {
            null_ls.builtins.formatting.stylua,
            null_ls.builtins.formatting.prettier,
            null_ls.builtins.completion.spell
          }
        }

        -- setting up formatting
        Vim.cmd [[
          augroup FormatAutogroup
            autocmd!
            autocmd BufWritePost * lua vim.lsp.buf.format()
          augroup END
        ]]
      end
    },
    {
      "williamboman/mason.nvim",
			event = { "BufCreate", "BufAdd", "BufCreate", "BufRead" },
      config = function ()
        require("mason").setup()
      end,
      dependencies = {
        {
          "williamboman/mason-lspconfig.nvim",
          config = function ()
            local mason_lspconfig = require("mason-lspconfig")

            mason_lspconfig.setup()

            mason_lspconfig.setup_handlers({
              function (server_name)
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                require("lspconfig")[server_name].setup({
                  capabilities = capabilities
                })
              end
            })
          end,
          dependencies = {
            {
              "glepnir/lspsaga.nvim",
              event = "BufRead",
              dependencies = {
                "nvim-tree/nvim-web-devicons",
                "nvim-treesitter/nvim-treesitter"
              },
              config = function ()
                require("lspsaga").setup({
                  symbol_in_winbar = {
                    enable = false
                  }
                })

                local keymap = vim.keymap.set

                keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")
                keymap({"n","v"}, "<leader>ca", "<cmd>Lspsaga code_action<CR>")
                keymap("n", "gr", "<cmd>Lspsaga rename<CR>")
                keymap("n", "gr", "<cmd>Lspsaga rename ++project<CR>")
                keymap("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
                keymap("n","gd", "<cmd>Lspsaga goto_definition<CR>")
                keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>")
                keymap("n","gt", "<cmd>Lspsaga goto_type_definition<CR>")
                keymap("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>")
                keymap("n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>")
                keymap("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>")
                keymap("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
                keymap("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>")
                keymap("n", "[E", function()
                  require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
                end)
                keymap("n", "]E", function()
                  require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
                end)
                keymap("n","<leader>o", "<cmd>Lspsaga outline<CR>")
                keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")
                keymap("n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>")
                keymap("n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>")
                keymap("n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>")

                -- not lsp saga really related but display gutter lsp icons
                local signs = {
                  Error = "",
                  Warn = "",
                  Hint = "",
                  Info = "",
                }

                for type, icon in pairs(signs) do
                  local hl = "DiagnosticSign" .. type
                  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
                end
              end,
            },
            {
              "neovim/nvim-lspconfig",
              config = function ()
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                require("lspconfig").lua_ls.setup {
                  capabilities = capabilities,
                }
              end,
              dependencies = {
                {
                  "hrsh7th/nvim-cmp",
                  config = function ()
                    local cmp = require("cmp")
                    local lspkind = require("lspkind")
                    local luasnip = require("luasnip")

                    cmp.setup({
                      experimental = {
                        ghost_text = true,
                      },
                      formatting = {
                        format = lspkind.cmp_format({
                          mode = "symbol_text",
                          menu = ({
                            buffer = "[Buffer]",
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            nvim_lua = "[Lua]",
                            latex_symbols = "[Latex]",
                            copilot = "[Copilot]",
                          }),
                          symbol_map = {
                            Copilot = '',
                            Text = "",
                            Method = "",
                            Function = "",
                            Constructor = "",
                            Field = "ﰠ",
                            Variable = "",
                            Class = "ﴯ",
                            Interface = "",
                            Module = "",
                            Property = "ﰠ",
                            Unit = "塞",
                            Value = "",
                            Enum = "",
                            Keyword = "",
                            Snippet = "",
                            Color = "",
                            File = "",
                            Reference = "",
                            Folder = "",
                            EnumMember = "",
                            Constant = "",
                            Struct = "פּ",
                            Event = "",
                            Operator = "",
                            TypeParameter = ""
                          },
                        })
                      },
                      snippet = {
                        expand = function (args)
                          require("luasnip").lsp_expand(args.body)
                        end
                      },
                      window = {
                        completion = cmp.config.window.bordered(),
                        documentation = cmp.config.window.bordered(),
                      },
                      mapping = cmp.mapping.preset.insert({
                        ["<C-Space>"] = cmp.mapping.complete(),
                        ["<C-e>"] = cmp.mapping.close(),
                        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                        ["<C-f>"] = cmp.mapping.scroll_docs(4),
                        ["<C-p>"] = cmp.mapping.select_prev_item(),
                        ["<C-n>"] = cmp.mapping.select_next_item(),
                        ["<CR>"] = cmp.mapping.confirm({
                          behavior = cmp.ConfirmBehavior.Replace,
                          select = false,
                        }),
                        ["<Tab>"] = cmp.mapping(function(fallback)
                          if cmp.visible() then
                            cmp.select_next_item()
                          elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                          elseif has_words_before() then
                            cmp.complete()
                          else
                            fallback()
                          end
                        end, {"i", "s"}),
                        ["<S-Tab>"] = cmp.mapping(function(fallback)
                          if cmp.visible() then
                            cmp.select_prev_item()
                          elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                          else
                            fallback()
                          end
                        end, {"i", "s"}),
                      }),
                      sources = cmp.config.sources({
                        { name = "copilot", group_index = 2 },
                        { name = "nvim_lsp", group_index = 2 },
                        { name = "path", group_index = 2 },
                        { name = "luasnip", group_index = 2 },
                      }, {
                        { name = "buffer" },
                      })
                    })

                    cmp.setup.cmdline({ '/', '?' }, {
                      mapping = cmp.mapping.preset.cmdline(),
                      sources = {
                        { name = "buffer" }
                      }
                    })

                    cmp.setup.cmdline(':', {
                      mapping = cmp.mapping.preset.cmdline(),
                      sources = cmp.config.sources({
                        { name = "path" }
                      }, {
                        { name = "cmdline" }
                      })
                    })

                    vim.cmd [[ highlight link CmpItemMenu Copilot ]]
                  end,
                  dependencies = {
                    "onsails/lspkind.nvim",
                    "hrsh7th/cmp-nvim-lsp",
                    "hrsh7th/cmp-buffer",
                    "hrsh7th/cmp-path",
                    "hrsh7th/cmp-cmdline",
                    "saadparwaiz1/cmp_luasnip",
                    "L3MON4D3/LuaSnip",
                    {
                      "zbirenbaum/copilot.lua",
                      cmd = "Copilot",
                      config = function ()
                        require("copilot").setup({
                          suggestion = { enabled = false },
                          panel = { enabled = false }
                        })
                      end,
                      dependencies = {
                        {
                          "zbirenbaum/copilot-cmp",
                          config = function ()
                            require("copilot_cmp").setup()
                          end
                        }
                      }
                    }
                  }
                },
              }
            }
          }
        }
      }
    },
    {
      "norcalli/nvim-colorizer.lua",
			event = { "BufCreate", "BufAdd", "BufCreate", "BufRead" },
      config = function ()
        require("colorizer").setup()
      end
    },
    {
      "akinsho/bufferline.nvim",
      event = { "BufCreate", "BufAdd", "BufCreate", "BufRead" },
      config = function ()
        require("bufferline").setup {
          options = {
            color_icons = true,
            hover = {
              enabled = true,
              delay = 300,
              reveal = {'close'}
            },
            offsets = {
              {
                filetype = "NvimTree",
                text = '',
                text_align = 'center',
                separator = true,
              }
            }
          }
        }
      end
    },
		{
			"decaycs/decay.nvim",
			priority = 1000,
			lazy = false,
      enabled = true,
			config = function()
				require("decay").setup({
					style = "cosmic",
					italics = {
						code = false,
						comments = true,
					},
					nvim_tree = {
						contrast = true,
					},
				})
			end,
		},
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      enabled = false,
      lazy = false,
      config = function ()
        require("catppuccin").setup({
          flavour = "macchiato",
          styles = {
            comments = { "italic" },
            conditionals = { "italic" },
            functions = { "italic" },
          },
          integrations = {
            cmp = true,
            nvimtree = true,
            telescope = true,
            mini = true,
            notify = true,
          }
        })

        vim.cmd [[ colorscheme catppuccin ]]
      end
    },
    {
      "xiyaowong/nvim-transparent",
      lazy = false,
      enabled = true,
      config = function ()
        require("transparent").setup({
          extra_groups = {
            "Normal",
            "EndOfBuffer",
            "NvimTreeEndOfBuffer",
            "NvimTreeNormal",
            "NvimTreeNormalNC",
            "NvimTreeVertSplit",
            "NvimTreeCursorLine",
            "NvimTreeCursorLineNC",
            "BufferLineFill",
            "BufferLineTab",
            "FloatBorder",
            "Pmenu",
            "CursorLine",
            "CursorLineNC",
            "VertSplit",
            "TelescopeNormal",
            "TelescopeBorder",
            "StatusLine",
            "StatusLineNC",
            "MsgArea",
            "NoiceMini",
            "LspInfoTitle",
            "LspInfoBorder",
            "LspSagaDiagnosticInfo",
            "LspSagaSignatureHelpBorder",
            "LspTroubleNormal"
          }
        })
      end
    },
		{
			"windwp/nvim-autopairs",
			event = { "BufCreate", "BufAdd", "BufCreate", "BufRead" },
			config = function()
				require("nvim-autopairs").setup()
			end,
		},
		{
			"nvim-tree/nvim-tree.lua",
			cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile", "NvimTreeCollapse" },
			dependencies = {
				"nvim-tree/nvim-web-devicons",
			},
			config = function()
				require("nvim-tree").setup({})
			end,
		},
		{
			"nvim-telescope/telescope.nvim",
			lazy = true,
			cmd = "Telescope",
			dependencies = {
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
			},
		},
    {
      "nvim-lualine/lualine.nvim",
      dependencies = {
        "nvim-tree/nvim-web-devicons"
      },
      lazy = false,
      config = function()
        local decay = require("lualine.themes.decay")
        local colors = require("decay.core").get_colors(G.decay_style)

        ---@diagnostic disable-next-line: unused-local,unused-function
        local function transparent_decay()
          for mode, secs in pairs(decay) do
            for sec, his in pairs(secs) do
              if his.bg == colors.statusline_bg then
                decay[mode][sec].bg = "NONE"
              end
            end
          end

          return decay
        end

        require('lualine').setup({
          options = {
            theme = transparent_decay(),
            section_separators = { left = '', right = '' },
            component_separators = { left = '', right = '' },
            globalstatus = true,
          },
          inactive_sections = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
          },
          sections = {
            lualine_a = {
              {
                'mode',
                fmt = function (str)
                  return string.upper(str:sub(1, 1)) .. string.lower(str:sub(2, -1))
                end,
                separator = { right = '' }
              },
              {
                'filetype',
                color = { bg = colors.lighter, fg = colors.foreground },
                separator = { right = '' }
              },
              {
                'branch',
                color = { bg = colors.statusline_bg, fg = colors.accent },
                separator = { right = '' }
              }
            },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {
              {
                'encoding',
                color = { bg = colors.statusline_bg, fg = colors.foreground },
                separator = { left = '' }
              },
              {
                'fileformat',
                color = { bg = colors.lighter, fg = colors.foreground },
                separator = { left = '' }
              }
            },
            lualine_z = {
              {
                'progress',
                separator = { left = '' }
              }
            },
          },
        })
      end
    },
		{
			"nvim-treesitter/nvim-treesitter",
			event = { "BufCreate", "BufAdd", "BufCreate", "BufRead" },
			config = function()
				require("nvim-treesitter.configs").setup({
					ensure_installed = {
						"javascript",
						"typescript",
						"tsx",
						"bash",
						"python",
						"lua",
						"json",
						"yaml",
						"html",
						"css",
						"scss",
						"go",
						"rust",
						"toml",
						"c",
						"cpp",
						"php",
						"vim",
						"svelte",
						"vue",
            "nix",
            "markdown",
            "markdown_inline"
					},
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = true,
					},
					indent = {
						enable = true,
					},
				})
			end,
		},
    {
      "folke/noice.nvim",
      enabled = false,
      config = function ()
        require("noice").setup({
          lsp = {
            progress = {
              enabled = false,
            },
            override = {
              ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
              ["vim.lsp.util.stylize_markdown"] = true,
              ["cmp.entry.get_documentation"] = true,
            }
          },
          presets = {
            bottom_search = true,
            command_palette = true,
            long_message_to_split = true,
            lsp_doc_border = true,
          }
        })
      end,
      dependencies = {
        "munifTanjim/nui.nvim",
        {
          "rcarriga/nvim-notify",
          config = function ()
            require("notify").setup({
              background_colour = "#000000"
            })
          end
        }
      }
    },
    {
      "folke/trouble.nvim",
      cmd = {"Trouble", "TroubleClose", "TroubleToggle", "TroubleRefresh"},
      dependencies = {
        "nvim-tree/nvim-web-devicons"
      },
      config = function ()
        require("trouble").setup({
          position = "bottom",
          height = 10,
          width = 50,
          icons = true,
          mode = "workspace_diagnostics",
          indent_lines = true,
          use_diagnostic_signs = false
        })
      end
    }
	}, {
    lockfile = Fn.stdpath "cache" .. "/lazy-lock.json",
    git = { timeout = 10000 }
  })
end

function _loader:setup()
	self:install_lazy()
	self:load_plugins()
end

function _loader.mt:__call()
	local ret = {}
	tbl.crush(ret, _loader)

	return ret
end

return setmetatable(_loader, _loader.mt)
