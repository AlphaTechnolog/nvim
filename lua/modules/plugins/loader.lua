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
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
end

function _loader:load_plugins()
	G.mapleader = " "

	if not tbl.contain_key(self._private, "lazy") then
		self._private.lazy = require("lazy")
	end

	self._private.lazy.setup({
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
                    local luasnip = require("luasnip")

                    cmp.setup({
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
                  end,
                  dependencies = {
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
			"decaycs/decay.nvim",
			priority = 1000,
			lazy = false,
			config = function()
				require("decay").setup({
					style = "decayce",
					italics = {
						code = true,
						comments = true,
					},
					nvim_tree = {
						contrast = false,
					},
				})
			end,
		},
    {
      "xiyaowong/nvim-transparent",
      lazy = false,
      priority = 1000,
      config = function ()
        require("transparent").setup({
          enable = true,
          extra_groups = {
            "Normal",
            "NvimTreeNormal",
            "NvimTreeNormalNC",
            "NvimTreeVertSplit",
            "NvimTreeCursorLine",
            "NvimTreeCursorLineNC",
            "CursorLine",
            "CursorLineNC",
            "VertSplit",
            "TelescopeNormal",
            "TelescopeBorder",
            "StatusLine",
            "StatusLineNC",
            "MsgArea"
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
        local function theme()
          local decay = require("lualine.themes.decay")
          local colors = require("decay.core").get_colors(G.decay_style)

          -- makes decay backgrounds transparents
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
            theme = theme(),
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
                end
              }
            },
            lualine_b = {},
            lualine_c = {},
            lualine_x = {},
            lualine_y = {},
            lualine_z = {},
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
            "nix"
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
	}, {
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
