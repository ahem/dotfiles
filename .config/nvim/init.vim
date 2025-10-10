set hidden
set tabstop=4
set shiftwidth=4
set expandtab
set termguicolors
set splitbelow
set splitright
set completeopt=menu,menuone,noinsert,fuzzy,popup
set exrc "read .nvim.lua or .nvimrc from projet dir (must explitcly be trusted)

" ===============================================================================
"  A font that makes icons work is CodeNewRoman from https://www.nerdfonts.com 
"
"  In iTerm settings I select "CodeNewRoman Nerd Font", "Regular", 14, 100, 90
" ===============================================================================

if filereadable('/usr/local/bin/python')
    let g:python3_host_prog='/usr/local/bin/python'
endif
if filereadable('/opt/homebrew/bin/python3')
    let g:python3_host_prog='/opt/homebrew/bin/python3'
endif

call plug#begin('~/.vim/plugged')

Plug 'ctrlpvim/ctrlp.vim'
Plug 'eandrju/cellular-automaton.nvim'
Plug 'junegunn/vim-easy-align'
Plug 'liuchengxu/vista.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'reedes/vim-pencil'
Plug 'rktjmp/lush.nvim'
Plug 'simeji/winresizer'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'j-hui/fidget.nvim'
Plug 'SmiteshP/nvim-navic'

" syntax
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'tikhomirov/vim-glsl'
Plug 'Elzair/ifm-vim'

" colorschemes
Plug 'fxn/vim-monochrome'
Plug 'chrsm/paramount-ng.nvim'
Plug 't184256/vim-boring'


call plug#end()

colorscheme paramount-ng

" configuration for Vista
let g:vista_sidebar_keepalt = 1
let g:vista_disable_statusline = 1
let g:vista_default_executive = 'nvim_lsp'

let mapleader=" "
nnoremap <leader>g <C-^>
nnoremap <leader>c :nohlsearch<cr>
nnoremap <leader>q :bp\|bd #<cr>
nnoremap <leader>f :CtrlP<cr>
nnoremap <leader>b :CtrlPBuffer<cr>
nnoremap <leader>xx :CellularAutomaton make_it_rain<cr>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

lua << END_OF_LUA
require("fidget").setup {
  -- options
}
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
        local navic = require("nvim-navic")

        if not navic.is_available(ev.buf) and client.server_capabilities.documentSymbolProvider then
            navic.attach(client, ev.buf)
        end

		if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
            vim.keymap.set('i', '<C-n>', function()
                if vim.fn.pumvisible() then
                    vim.lsp.completion.get()
                else
                    fallback()
                end
            end)
		end

		if not client:supports_method('textDocument/willSaveWaitUntil') and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				callback = function(ev)
					vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
				end
			})
		end

		-- what is needed for these??
		vim.keymap.set('n', 'gd', vim.lsp.buf.declaration)
		vim.keymap.set('n', 'C-]', vim.lsp.buf.definition)
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action)
	end,
})
vim.lsp.enable({'rust_analyzer'})
vim.diagnostic.config({ virtual_text = { current_line = true } })

function _G.navic_statusline_item()
    local navic = require('nvim-navic')
    if navic.is_available() then
        location = navic.get_location()
        if not (location == '') then
            return '> ' .. location
        end
    end
    return ''
end

vim.o.statusline = "%f %{v:lua.navic_statusline_item()} %= %l:%c      %p%%"

END_OF_LUA


" if the `rg` util is available, configure CtrlP to use it
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
    let g:ctrlp_user_command = 'rg %s --files --color=never --glob ""'
    let g:ctrlp_use_caching = 0
else
    let g:ctrlp_clear_cache_on_exit = 0
endif

if has('persistent_undo')
    silent call system('mkdir -p ' . &undodir)
    set undofile
endif

augroup ifmSettings
    autocmd!
    autocmd FileType ifm setlocal shiftwidth=2 softtabstop=2 expandtab
augroup END

if exists("g:neovide")
    " hack around Neovide bug where window doesn't get focus on open (https://github.com/neovide/neovide/issues/2330)
    autocmd VimEnter * call timer_start(20, {tid -> execute('NeovideFocus')})

    " ensure that Cmd-C and Cmd-V is handled like I want it
    imap <D-v> <C-r><C-o>* 
    vmap <D-c> "*y
endif
