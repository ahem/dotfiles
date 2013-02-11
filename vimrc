set nocompatible
set laststatus=2

" set leader to comma, which is more accessible
let mapleader = ","

" Vundle {{{

filetype off " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle, required!
Bundle 'gmarik/vundle'

" Other bundles goes here:
Bundle 'Syntastic'
let g:syntastic_auto_loc_list=1

Bundle 'The-NERD-Commenter'
Bundle 'glsl.vim'

" Bundle Powerline {{{
Bundle 'Lokaltog/powerline'
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
let g:Powerline_symbols = 'fancy'
let g:Powerline_cache_enabled = 1
let g:Powerline_colorscheme = 'badwolf'

if has("gui_running")
"Install Menlo from https://github.com/Lokaltog/powerline-fonts if
"Powerline looks weird
set guifont=Menlo\ Regular\ for\ Powerline:h12
endif
"}}}

" Bundle Vimpanel {{{
Bundle 'mihaifm/vimpanel'
let g:NERDTreeWinPos='left'
let g:NERDTreeWinSize=40
let g:VimpanelStorage=expand('$HOME') . '/' . '.vim/vimpanel' 
cabbrev vp Vimpanel
cabbrev vl VimpanelLoad
cabbrev vc VimpanelCreate
cabbrev ve VimpanelEdit
cabbrev vr VimpanelRemove
cabbrev vss VimpanelSessionMake
cabbrev vsl VimpanelSessionLoad
" }}}

" Bundle FuzzyFinder {{{
"L9 is required by FuzzyFinder
Bundle 'L9'
Bundle 'FuzzyFinder'

" FufFindByVimPanel function {{{
function! FufFindByVimPanel()
    let dirlist = []

    "save the original view
    let origIgnore = &eventignore
    let [origbuf, origview] = [bufnr("%"), winsaveview()]
    let origFoldenable = &foldenable
    set nofoldenable

    " disable autocommands
    set eventignore=all
    try
        bfirst
        let startbuf = bufnr('%')
        while 1
            if &ft == 'vimpanel'
                "catch output of g/^\/ (lines starting with /) into the matches variable
                redir => matches
                g/^\/
                redir END
                call extend(dirlist, split(matches, '\n'))
            endif

            bnext
            if bufnr('%') == startbuf
                break
            end
        endwhile

    finally
        "restore the original view
        exec "buffer " . origbuf
        let &foldenable = origFoldenable
        call winrestview(origview)

        "enable autocommands again
        exec 'set eventignore=' . origIgnore
    endtry

    if len(dirlist) > 0
        call fuf#setOneTimeVariables(['g:fuf_coveragefile_globPatterns', map(dirlist, 'v:val . "**/*"')])
                \ | FufCoverageFile
    else
        FufFile
    endif

endfunction
" }}}
nnoremap <leader>b :FufBuffer<cr>
nnoremap <leader>f :call FufFindByVimPanel()<cr>
" }}}

"Bundle 'minibufexpl.vim'
"let g:miniBufExplorerMoreThanOne=1
"let g:miniBufExplMapCTabSwitchBufs = 1 

filetype plugin indent on " required!

 "
 " Brief help
 " :BundleList          - list configured bundles
 " :BundleInstall(!)    - install(update) bundles
 " :BundleSearch(!) foo - search(or refresh cache first) for foo
 " :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
 "
 " see :h vundle for more details or wiki for FAQ
 " NOTE: comments after Bundle command are not allowed..


" }}}

colorscheme darkblue

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50  " keep 50 lines of command line history
set ruler       " show the cursor position all the time
set showcmd     " display incomplete commands
set incsearch   " do incremental searching

set guioptions-=T "remove toolbar
set guioptions-=t "remove tearoff menus
set encoding=utf-8
set visualbell
set autoindent

" nice tabstobs
set shiftwidth=4
set tabstop=4
set smarttab
set softtabstop=4
set shiftround
set expandtab

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" if the terminal has colors
if &t_Co > 2 || has("gui_running") 
    syntax on
    set hlsearch
endif
    


" Win32 specific {{{

if has("win32")
    source $VIMRUNTIME/mswin.vim
    set guifont=Lucida_Console:h9
endif

" }}}

" Backups {{{

set backup                        " enable backups
set noswapfile                    " It's 2012, Vim.

" Make Vim able to edit crontab files again.
set backupskip=/tmp/*,/private/tmp/*"

set undodir=~/.vim/tmp/undo//     " undo files
set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&undodir))
    call mkdir(expand(&undodir), "p")
endif
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif

" }}}

" Diff stuff {{{

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif

set diffexpr=MyDiff()
function! MyDiff()
    let opt = '-a --binary '
    if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
    if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
    let arg1 = v:fname_in
    if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
    let arg2 = v:fname_new
    if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
    let arg3 = v:fname_out
    if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
    let eq = ''
    if $VIMRUNTIME =~ ' '
        if &sh =~ '\<cmd'
            let cmd = '""' . $VIMRUNTIME . '\diff"'
            let eq = '"'
        else
            let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
        endif
    else
        let cmd = $VIMRUNTIME . '\diff'
    endif
    silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

" }}}

if has("autocmd")

    autocmd FileType text setlocal textwidth=78

    " When editing a file, always jump to the last known cursor position.
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

    " store folds on quit, restore them on load
    au BufWinLeave .* if &modifiable | silent mkview | endif 
    au BufWinEnter .* if &modifiable  | silent loadview | endif 

    augroup set_filetypes
        au!
        au BufRead,BufNewFile *.vm setfiletype velocity 
        au BufRead,BufNewFile *.brail setfiletype html
        au BufRead,BufNewFile *.drxml setfiletype xml
        
        au BufRead,BufNewFile *.{frag,vert,fp,vp,glsl} setfiletype glsl

        au Filetype perl compiler perl
        au Filetype perl nmap <buffer> <F5> :make<cr>
        au Filetype perl nmap <buffer> <C-F5> :!perl -I "%:p:h" "%:p"<cr>
    augroup END


    augroup publish_files_at_work
        " mappings for easier publishing of stuff at work
        au!
        au BufNewFile,BufRead c:/code/p3/ektorp/* nmap <buffer> <F6> :!copy % c:\\wamp\\www\\ektorp<cr>
        au BufNewFile,BufRead c:/code/p3/wordpress/wp-content/plugins/* nmap <buffer> <F6> :!copy %:p %:p:s?C:\\code\\p3\\?c:\\wamp\\www\\?<cr>
    augroup END


    augroup vimrcEx
        au!
        au bufreadpost {.,_}vimrc setlocal foldmethod=marker

        " Source the vimrc file after saving it
        au bufwritepost {.,_}vimrc source $MYVIMRC
    augroup END
endif


" stupid danish keyboard, fix goto-mark-key
nmap ½ `

" map F1 to something sensible instead of help
nmap <f1> :nohlsearch<cr>
imap <f1> <esc>

" map ctrl-space to omnicompletion
inoremap <C-space> <C-x><C-o>


command! FixLines :%s/\r//g<cr>

" make buffers work better
set hidden

" ctags are cool. Let's make vim's support for them even more cool!
set tags=./tags; "look for 'tags' file in parent directories
nmap <leader>tt :TlistToggle<cr>
nmap <leader>to :TlistOpen<cr>
nmap <leader>tc :TlistClose<cr>

nnoremap <Leader>g :e#<CR>
nnoremap <Leader>1 :1b<CR>
nnoremap <Leader>2 :2b<CR>
nnoremap <Leader>3 :3b<CR>
nnoremap <Leader>4 :4b<CR>
nnoremap <Leader>5 :5b<CR>
nnoremap <Leader>6 :6b<CR>
nnoremap <Leader>7 :7b<CR>
nnoremap <Leader>8 :8b<CR>
nnoremap <Leader>9 :9b<CR>
nnoremap <Leader>0 :10b<CR>

" {{{ window navigation

nmap <c-j> <c-w>j
nmap <c-k> <c-w>k
nmap <c-h> <c-w>h
nmap <c-l> <c-w>l


" }}}



