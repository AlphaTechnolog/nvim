(local check-theme-diffs? false)
(local enable-terminal-adaptation? true)
(local main-terminal :kitty) ; supports alacritty, kitty, ghostty (though ghostty's config file parsing is TODO)

(set vim.o.number true)
(set vim.o.relativenumber true)
(set vim.o.wrap false)
(set vim.o.tabstop 4)
(set vim.o.shiftwidth 4)
(set vim.o.expandtab true)
(set vim.o.autoindent true)
(set vim.o.swapfile false)
(set vim.g.mapleader " ")
(set vim.o.clipboard "unnamedplus")

(vim.keymap.set "n" ";" ":" {:desc "Open the cmdline easily"})
(vim.keymap.set "n" "<Tab>" "<cmd>bn!<cr>" {:desc "Move afterwards through buffers list"})
(vim.keymap.set "n" "<S-Tab>" "<cmd>bp!<cr>" {:desc "Move backwards through buffers list"})
(vim.keymap.set "n" "<leader>x" "<cmd>bd!<cr>" {:desc "Close buffers"})
(vim.keymap.set "n" "<C-d>" "<C-d>zz" {:desc "Move down vertically while centering"})

(each [i k (ipairs ["jk" "kj" "jj" "kk"])]
  (vim.keymap.set "i" k "<esc>" {:desc (.. "Go back to normal mode (" (tostring i) ")")}))

(let [movement-keys ["h" "j" "k" "l"]]
  (each [_ k (ipairs movement-keys)]
    (let [shortcut (.. "<C-" k ">")
	  action (.. "<C-w>" k)
	  desc (.. "Move to pane with <C-w>" k " (im lazy)")]
      (vim.keymap.set "n" shortcut action {:desc desc}))))

(let [indent-opts [{:language "javascript" :indent {:tabstop 2 :shiftwidth 2}}
		           {:language "typescript" :indent {:tabstop 2 :shiftwidth 2}}
		           {:language "lua" :indent {:tabstop 2 :shiftwidth 2}}
                   {:language "dart" :indent {:tabstop 2 :shiftwidth 2}}]]
  (each [_ entry (ipairs indent-opts)]
    (var cmd (.. "autocmd FileType " entry.language " setlocal"))
    (each [key value (pairs entry.indent)]
      (set cmd (string.format "%s %s=%s" cmd key (tostring value))))
    (vim.cmd cmd)))

(let [plugins ["AlphaTechnolog/neovim-ayu"
               "stevearc/oil.nvim"
               "j-hui/fidget.nvim"
               "nvim-lua/plenary.nvim"
               "nvim-telescope/telescope.nvim"
               "neovim/nvim-lspconfig"
               "nvim-treesitter/nvim-treesitter"
               "rafamadriz/friendly-snippets"
               "folke/lazydev.nvim"
               "saghen/blink.cmp"
               "sindrets/diffview.nvim"]]
  (vim.pack.add (icollect [_ v (ipairs plugins)]
		  (let [real-src (.. "https://github.com/" v)]
		    {:src real-src}))))

(lambda split [s ?delimiter] (let [delim (or ?delimiter " ")] (icollect [entry (s:gmatch (.. "[^" delim "]+"))] entry)))
(lambda trim [s] (: (s:gsub "^%s+" "") :gsub "%s+$" ""))

; adapt to terminal colors
(fn parse-kitty-config []
  (let [filename (.. (os.getenv :HOME) "/.config/kitty/current-theme.conf")]
    (with-open [f (io.open filename)]
      (collect [line (f:lines)]
        (if (and (not= (string.sub line 1 1) :#) (not= (length line) 0))
            (let [[key value] (split line " ")] (values key value)))))))

(fn parse-alacritty-config []
  (let [filename (.. (os.getenv :HOME) "/.config/alacritty/alacritty.toml")
        toml (require :toml)]
    (with-open [f (io.open filename)]
      (toml.parse (f:read "*a")))))

; TODO
(fn parse-ghostty-config [] {})

(lambda get-theme [method]
  (lambda variant [kitty alacritty]
    (case method
      :alacritty alacritty
      :kitty kitty))
  (let [kitty (parse-kitty-config)
        alacritty (parse-alacritty-config)]
    {:background (variant kitty.background alacritty.colors.primary.background)
     :foreground (variant kitty.foreground alacritty.colors.primary.foreground)
     :black (variant kitty.color0 alacritty.colors.normal.black)
     :bright-black (variant kitty.color8 alacritty.colors.bright.black)
     :red (variant kitty.color1 alacritty.colors.normal.red)
     :bright-red (variant kitty.color9 alacritty.colors.bright.red)
     :green (variant kitty.color2 alacritty.colors.normal.green)
     :bright-green (variant kitty.color10 alacritty.colors.bright.green)
     :yellow (variant kitty.color3 alacritty.colors.normal.yellow)
     :bright-yellow (variant kitty.color11 alacritty.colors.bright.yellow)
     :blue (variant kitty.color4 alacritty.colors.normal.blue)
     :bright-blue (variant kitty.color12 alacritty.colors.bright.blue)
     :magenta (variant kitty.color5 alacritty.colors.normal.magenta)
     :bright-magenta (variant kitty.color13 alacritty.colors.bright.magenta)
     :cyan (variant kitty.color6 alacritty.colors.normal.cyan)
     :bright-cyan (variant kitty.color14 alacritty.colors.bright.cyan)
     :white (variant kitty.color7 alacritty.colors.normal.white)
     :bright-white (variant kitty.color15 alacritty.colors.bright.white)}))

; mostly 4 debugging
(fn compare-themes []
  (let [alacritty-theme (get-theme :alacritty) kitty-theme (get-theme :kitty)]
    (collect [key value (pairs kitty-theme)]
      (let [alacritty-value (. alacritty-theme key)]
        (if (not= alacritty-value value)
            (values key {:kitty value :alacritty alacritty-value}))))))

(if check-theme-diffs?
    (let [diffs (compare-themes) keys-n (length (icollect [k _ (pairs diffs)] k))]
      (if (> keys-n 0)
          (let [inspect (require :inspect)] (error (.. "terminal themes diffs:\n" (inspect diffs)))))))

; given a bg and a fg, this will highlight the desired
; group, bg and fg are passed in the way of a function
; which will receive the theme from the selected terminal and return
; the hex string of the color, it could be used to choose
; colors from the active alacritty theme.
;
; example:
; (let [bg (fn [x] x.background)] (hi :EndOfBuffer bg bg))
(lambda hi [group ?bg ?fg]
  (let [theme (get-theme main-terminal)]
    (var str group)
    (if (not= ?bg nil)
        (let [value (.. "guibg=" (?bg theme))]
          (set str (.. str " " value))))
    (if (not= ?fg nil)
        (let [value (.. "guifg=" (?fg theme))]
          (set str (.. str " " value))))
    (vim.cmd (.. "hi! " str))))

; ==gruvbox material==
; (set vim.g.gruvbox_material_better_performance 1)
; (set vim.g.gruvbox_material_background :hard)
; (set vim.g.gruvbox_material_foreground :material)
; (vim.cmd.colorscheme :gruvbox-material)

; ==everforest==
; (set vim.g.everforest_better_performance 1)
; (set vim.g.everforest_background :hard)
; (vim.cmd.colorscheme :everforest)

; == ayu mirage ==
(fn ayu [{: enable-mirage : enable-custom-mayukai} cnf]
  (fn mayukai-palette [] {:accent "#ffd580"
                          :bg "#1b1c24"
                          :black "#282a36"
                          :comment "#3c4052"
                          :constant "#cfbafa"
                          :entity "#95e6cb"
                          :error "#ed8274"
                          :fg "#cbccc6"
                          :fg_idle "#343747"
                          :func "#ffd580"
                          :guide_active "#343747"
                          :guide_normal "#282a36"
                          :gutter_active "#c7c7c7"
                          :gutter_normal "#343747"
                          :keyword "#ed8274"
                          :line "#282a36"
                          :lsp_inlay_hint "#c7c7c7"
                          :lsp_parameter "#d4bfff"
                          :markup "#f28779"
                          :operator "#f28779"
                          :panel_bg "#282a36"
                          :panel_border "#1b1c24"
                          :panel_shadow "#1b1c24"
                          :regexp "#95e6cb"
                          :selection_bg "#343747"
                          :selection_border "#343747"
                          :selection_inactive "#282a36"
                          :special "#555a74"
                          :string "#a6cc70"
                          :tag "#95e6cb"
                          :ui "#c7c7c7"
                          :vcs_added "#bae67e"
                          :vcs_added_bg "#282a36"
                          :vcs_modified "#95e6cb"
                          :vcs_removed "#f28779"
                          :vcs_removed_bg "#343747"
                          :warning "#fad07b"
                          :white "#ffffff"})
  (let [is-mayukai (or enable-custom-mayukai false)
        is-mirage (if is-mayukai true (or enable-mirage true))
        palette (if is-mayukai (mayukai-palette) {})
        ayu (require :ayu)]
    (ayu.setup {:mirage is-mirage :terminal false :palette palette})
    (vim.cmd.colorscheme :ayu)))

(ayu {:enable-mirage true :enable-custom-mayukai true})

; ==catppuccin==
; (let [catppuccin (require :catppuccin)]
;   (catppuccin.setup {})
;   (vim.cmd.colorscheme :catppuccin))

; ==tokyonight theme==
; (vim.cmd.colorscheme :tokyonight)

; ==vague theme==
; (let [vague (require :vague)]
;   (vague.setup {:transparent true})
;   (vim.cmd.colorscheme :vague))

; ==maple theme==
; (vim.cmd.colorscheme :mapledark)

(fn adapt-to-terminal []
  (if enable-terminal-adaptation?
      (do (let [bg     (fn [x] x.background)
                fg     (fn [x] x.foreground)
                black  (fn [x] x.black)
                black2 (fn [x] x.bright-black)]
            (hi :Normal bg fg)
            (hi :EndOfBuffer bg bg)
            (hi :WinSeparator nil black)
            (hi :VertSplit bg black)
            (hi :VertSplitNC bg black)
            (hi :StatusLine black fg)
            (hi :StatusLineNC bg black2)
            (hi :LineNr bg black2)
            (hi :TelescopeNormal bg fg)
            (hi :TelescopeBorder bg black)
            (hi :TelescopeSelection black fg)))))

(adapt-to-terminal)

; fuzzy finder
(let [telescope (require "telescope.builtin")]
  (vim.keymap.set "n" "<leader>ff" telescope.find_files {:desc "Fuzzy find files via telescope"})
  (vim.keymap.set "n" "<leader>fg" telescope.live_grep {:desc "Live grep on files using ripgrep via telescope"})
  (vim.keymap.set "n" "<leader>fb" telescope.buffers {:desc "Fuzz through opened neovim buffers using telescope"})
  (vim.keymap.set "n" "<leader>fh" telescope.help_tags {:desc "U really need help"}))

; file explorer
(let [oil (require :oil)]
  (oil.setup)
  (vim.keymap.set "n" "-" "<cmd>Oil<cr>" {:desc "Open file explorer"}))

; lsp
(let [servers ["lua_ls" "clangd" "zls" "ts_ls" "gopls" "omnisharp" "dartls"]]
  (vim.lsp.enable servers)
  (vim.keymap.set "n" "K" vim.lsp.buf.hover {:desc "Hover the symbol under the cursor (lsp)"})
  (vim.keymap.set "n" "<leader>lf" vim.lsp.buf.format {:desc "Format file via (lsp)"})
  (vim.keymap.set "n" "<leader>rn" vim.lsp.buf.rename {:desc "Rename variable under cursor (lsp)"})
  (vim.keymap.set "n" "<leader>ca" vim.lsp.buf.code_action {:desc "Open code actions for symbol under the cursor (lsp)"})
  (vim.keymap.set "n" "<leader>s" vim.diagnostic.open_float {:desc "Show diagnostics for the current line (lsp)"}))

; lsp completion
(let [blink (require "blink.cmp")]
  (blink.setup {:keymap {:preset "default"}
                :cmdline {:enabled true}
                :fuzzy {:implementation "lua"}
                :appearance {:use_nvim_cmp_as_default true
                             :nerd_font_variant "normal"}
                :completion {:accept {:auto_brackets {:enabled true}}
                             :ghost_text {:enabled false}
                             :documentation {:auto_show true
                                             :auto_show_delay_ms 500}}
                :sources {:providers {:lazydev {:name "LazyDev"
                                                :module "lazydev.integrations.blink"
                                                :score_offset 10}}
                          :default ["lazydev" "lsp" "path" "snippets" "buffer"]}}))

; nvim treesitter
(let [tsitter (require :nvim-treesitter)
      servers ["lua" "zig" "html" "css" "fennel"
               "typescript" "tsx" "javascript"
               "python" "rust" "c" "cpp" "go" "c_sharp"]]
  (tsitter.setup {:install_dir (.. (vim.fn.stdpath :data) "/site")})
  (tsitter.install servers))

(fn setup-treesitter []
  (let [servers ["lua" "zig" "html" "css" "fennel"
                 "typescript" "tsx" "javascript"
                 "python" "rust" "c" "cpp" "go" "c_sharp"]
        tsitter (require :nvim-treesitter)]
    (tsitter.setup {:install_dir (.. (vim.fn.stdpath :data) "/site")})
    (tsitter.install servers)
    (fn start-ts [] (if (not= vim.bo.filetype "")
                        (pcall vim.treesitter.start)))
    (vim.api.nvim_create_autocmd :BufEnter {:pattern "*" :callback start-ts})))

(setup-treesitter)

; fidget
(let [fidget (require :fidget)] (fidget.setup))
