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

-- NERDTree
vim.g.NERDTreeWinPos = 'left'
vim.g.NERDTreeShowHidden = 1
vim.g.NERDTreeIgnore = {'.git$'}
vim.keymap.set('', '<leader>nn', ':NERDTreeToggle<cr>', {desc = 'toggel NERD Tree'})

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
  'preservim/nerdtree',
  -- 'nvim-tree/nvim-web-devicons',
  'Xuyuanp/nerdtree-git-plugin',
  'preservim/tagbar', -- need to install ctags `sudo apt-get -y install exuberant-ctags`
  'vim-airline/vim-airline',
  'airblade/vim-gitgutter',
  'tpope/vim-fugitive',
  'jiangmiao/auto-pairs',
  'tpope/vim-surround',
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate" -- :MasonUpdate updates registry contents
  },
  'williamboman/mason-lspconfig.nvim',
  'neovim/nvim-lspconfig',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/nvim-cmp',
  'nvim-lua/plenary.nvim',
  'petertriho/cmp-git',
  'onsails/lspkind.nvim',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
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
  -- 'overcache/NeoSolarized',
  'folke/tokyonight.nvim',
  'tpope/vim-commentary',
  'christoomey/vim-tmux-navigator',
  'kien/ctrlp.vim',
})

vim.cmd[[colorscheme tokyonight-storm]]

local on_attach = function(client, bufnr)
end
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup()
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
