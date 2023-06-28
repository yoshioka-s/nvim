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
vim.opt.rtp = vim.opt.rtp + '/bin/fzf'

vim.g.mapleader = ','

vim.keymap.set('n', '<leader>sv', '<cmd>source $MYVIMRC<cr>', {desc = 'reload nvim config'})
vim.keymap.set('n', '<leader>w', '<cmd>write<cr>', {desc = 'write file'})
vim.keymap.set({'n', 'x'}, 'cy', '"+y', {desc = 'yank to clipboard'})
vim.keymap.set({'n', 'x'}, 'cp', '"+p', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<leader>a', ':keepjumps normal! ggVG<cr>', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<space>', '/', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-space>', '?', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-j>', '<C-W>j', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-k>', '<C-W>k', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-h>', '<C-W>h', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<C-l>', '<C-W>l', {desc = 'paste from clipboard'})
vim.keymap.set('n', '<leader>bd', ':bp<bar>sp<bar>bn<bar>bd<cr>', {desc = 'paste from clipboard'})

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
require('lazy').setup({
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require('telescope').setup()
      require('telescope').load_extension 'file_browser'
      vim.api.nvim_set_keymap(
        "n",
        "<leader>fb",
        ":Telescope file_browser<cr>",
        { noremap = true }
      )
      -- open file_browser with the path of the current buffer
      vim.api.nvim_set_keymap(
        "n",
        "<space>fb",
        ":Telescope file_browser path=%:p:h select_buffer=true",
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
      require('gitsigns').setup()
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
  'folke/tokyonight.nvim',
  'christoomey/vim-tmux-navigator',
  'kien/ctrlp.vim',
})

vim.cmd[[colorscheme tokyonight-storm]]


