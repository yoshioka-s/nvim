vim.opt.number = true
vim.opt.smartcase = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.wildignore = vim.opt.wildignore + '*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store'
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.termguicolors = true
vim.opt.rtp = vim.opt.rtp + '/opt/homebrew/bin/fzf'

vim.g.mapleader = ','

vim.keymap.set('n', '<leader>sv', '<cmd>source $MYVIMRC<cr>', {desc = 'reload nvim config'})
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', {desc = 'write file'})
vim.keymap.set({'n', 'x'}, 'cy', '"+y', {desc = 'yank to clipboard'})
vim.keymap.set({'n', 'x'}, 'cp', '"+p', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>', {desc = 'select all'})
vim.keymap.set('n', '<C-j>', '<C-W>j', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-k>', '<C-W>k', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-h>', '<C-W>h', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-l>', '<C-W>l', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<leader>o', ':Buffers<cr>', {desc = 'open buffers'})
vim.keymap.set('i', 'jj', '<esc>', {desc = 'escape'})
vim.keymap.set('t', 'jj', [[<C-\><C-n>]], {desc = 'escape'})
vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], {desc = 'escape'})

if vim.g.vscode then
else
  vim.keymap.set({'n', 'x'}, '<leader>f', ':%s///g<left><left><left>', {desc = 'search and replace'})
  vim.keymap.set('n', '<leader>bd', ':bp<bar>sp<bar>bn<bar>bd<cr>', {desc = 'delete buffer'})
end
vim.api.nvim_create_user_command('W', 'w !sudo tee % > /dev/null', {desc = 'write file as sudo'})

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

if not vim.g.vscode then
  require('lazy').setup({
    {
      "nvim-telescope/telescope-file-browser.nvim",
      dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-telescope/telescope-live-grep-args.nvim" },
      config = function()
        require('telescope').setup()
        require('telescope').load_extension 'file_browser'
        require('telescope').load_extension 'live_grep_args'
        vim.api.nvim_set_keymap(
          "n",
          "<leader>nn",
          ":Telescope file_browser<cr>",
          { noremap = true }
        )
        -- open file_browser with the path of the current buffer
        vim.api.nvim_set_keymap(
          "n",
          "<space>nn",
          ":Telescope file_browser path=%:p:h select_buffer=true<cr>",
          { noremap = true }
        )
        vim.api.nvim_set_keymap(
          "n",
          "<leader>g",
          ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
          { noremap = true }
        )
      end
    },
    {
      'nvim-tree/nvim-web-devicons',
      event = 'VeryLazy',
    },
    {
      'nvim-lualine/lualine.nvim',
      event = 'VeryLazy',
      config = function()
        require('lualine').setup()
      end
    },
    { "junegunn/fzf", build = ":call fzf#install()", event = "VeryLazy" },
    { "junegunn/fzf.vim", event = "VeryLazy" },
    {
      'preservim/tagbar', -- need to install ctags `sudo apt-get -y install exuberant-ctags`
      event = 'BufRead',
    },
    {
      'lewis6991/gitsigns.nvim',
      event = 'BufRead',
      config = function()
        require('gitsigns').setup({
          on_attach = function(client, bufnr)
            local gitsigns = require('gitsigns')
            local function map(mode, l, r, opts)
              opts = opts or {}
              opts.buffer = bufnr
              vim.keymap.set(mode, l, r, opts)
            end
            map('n', '<leader>hb', function() gitsigns.blame_line{full=true} end)
            map('n', '<leader>tb', gitsigns.toggle_current_line_blame)
          end
        })
      end
    },
    {
      'sindrets/diffview.nvim',
      event = 'VeryLazy',
    },
    {
      'tpope/vim-fugitive',
      event = 'VeryLazy',
    },
    {
      'windwp/nvim-autopairs',
      event = 'InsertEnter',
      opts = {}
    },
    {
      'kylechui/nvim-surround',
      event = 'BufRead',
      config = function()
        require("nvim-surround").setup({
        })
      end
    },
    {
      'numToStr/Comment.nvim',
      event = 'InsertEnter',
      config = function()
        require('Comment').setup()
      end
    },
    {
      "williamboman/mason.nvim",
      build = ":MasonUpdate" -- :MasonUpdate updates registry contents
    },
    {
      'williamboman/mason-lspconfig.nvim',
      config = function()
        require('mason').setup()
        local on_attach = function(client, bufnr)
        end
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        require('mason-lspconfig').setup({
          ensure_installed = {
            'lua_ls',
            'bashls',
            'dockerls',
            'docker_compose_language_service',
            'sqlls',
            'tsserver',
            'jsonls',
            'volar',
            'eslint',
            'prettier',
          },
        })

        require('mason-lspconfig').setup_handlers({
          function(server_name)
            require('lspconfig')[server_name].setup({
              on_attach = on_attach,
              capabilities = capabilities,
            })
          end
        })
      end
    },
    'neovim/nvim-lspconfig',
    {
      'hrsh7th/cmp-nvim-lsp',
      event = 'InsertEnter',
      config = function()
        local lspkind = require('lspkind')
        local cmp = require('cmp')
        cmp.setup({
          snippet = {
            expand = function(args)
              -- vim.fn['vsnip#anonymous'](args.body)
            end,
          },
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'path' },
          }, {
            { name = 'buffer' },
          }),
          mapping = cmp.mapping.preset.insert({
            ['<C-p>'] = cmp.mapping.select_prev_item(),
            ['<C-n>'] = cmp.mapping.select_next_item(),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.abort(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          formatting = {
            format = lspkind.cmp_format({
              mode = 'symbol',
              maxWidth = 50,
              ellipsis_char = '...',
              before = function(entry, vim_item)
                return vim_item
              end
            })
          }
        })
        cmp.setup.filetype('gitcommit', {
          sources = cmp.config.sources({
            { name = 'git' },
          }, {
            { name = 'buffer' },
          })
        })
        cmp.setup.cmdline({ '/', '?' }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = 'buffer' }
          }
        })
        cmp.setup.cmdline(':', {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = 'path' }
          }, {
            { name = 'cmdline' }
          })
        })
      end
    },
    {
      'hrsh7th/cmp-buffer',
      event = 'InsertEnter'
    },
    {
      'hrsh7th/cmp-path',
      event = 'InsertEnter,CmdlineEnter'
    },
    {
      'hrsh7th/cmp-cmdline',
      event = 'CmdlineEnter'
    },
    {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter,CmdlineEnter'
    },
    {
      'petertriho/cmp-git',
      event = 'InsertEnter,CmdlineEnter'
    },
    {
      'onsails/lspkind.nvim',
      event = 'InsertEnter'
    },
    {
      'hrsh7th/cmp-vsnip',
      event = 'InsertEnter'
    },
    {
      'hrsh7th/vim-vsnip',
      event = 'InsertEnter'
    },
    {
      'glepnir/lspsaga.nvim',
      event = 'LspAttach',
      config = function ()
        require('lspsaga').setup({})
      end,
      dependencies = {
        {'nvim-tree/nvim-web-devicons'},
        {'nvim-treesitter/nvim-treesitter'},
      },
    },
    {
      "kdheepak/lazygit.nvim",
      lazy = true,
      cmd = {
          "LazyGit",
          "LazyGitConfig",
          "LazyGitCurrentFile",
          "LazyGitFilter",
          "LazyGitFilterCurrentFile",
      },
      -- optional for floating window border decoration
      dependencies = {
          "nvim-lua/plenary.nvim",
      },
      -- setting the keybinding for LazyGit with 'keys' is recommended in
      -- order to load the plugin when the command is run for the first time
      keys = {
          { "<leader>c", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit" }
      }
    },
    {
      'akinsho/toggleterm.nvim',
      version = "*",
      config = function ()
        require('toggleterm').setup({
          size = function(term)
            if term.direction == "horizontal" then
              return 20
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.3
            end
          end,
          open_mapping = '<leader>tt',
          start_in_insert = true,
          insert_mappings = true,
          persist_size = true,
          direction = 'horizontal',
          close_on_exit = true,
        })
        vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]])
        vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]])
        vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]])
        vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]])
        vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]])
        vim.keymap.set('n', '<leader>T', ':ToggleTerm direction=vertical name=home<cr>', {desc = 'toggle terminal vertically'})
        vim.keymap.set('n', '<leader>tn', ':ToggleTerm name=', {desc = 'toggle terminal with name'})
      end,
    },
    'folke/tokyonight.nvim',
    'christoomey/vim-tmux-navigator',
    'kien/ctrlp.vim',
    'https://github.com/github/copilot.vim.git'
  })
  vim.cmd[[colorscheme tokyonight-storm]]
end
