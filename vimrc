set nocompatible
set laststatus=2

" set leader to comma, which is more accessible
let mapleader = ","

" function HasPythonVersion {{{
function! HasPythonVersion(version)
    if !has('python')
        return 0
    endif

    python << ENDPYTHON
import sys, vim
bits = [int(x) for x in vim.eval('a:version').split('.')]
if sys.version_info.major > bits[0] \
    or (sys.version_info.major == bits[0] and sys.version_info.minor > bits[1]) \
    or (sys.version_info.major == bits[0] and sys.version_info.minor == bits[1] and sys.version_info.micro >= bits[2]):
    vim.command("let result = 1")
else:
    vim.command("let result = 0")
ENDPYTHON
    return result
endfunction
" }}}

" Vundle {{{

filetype off " required!

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'tpope/vim-fugitive.git'
Bundle 'The-NERD-Commenter'
Bundle 'matchit.zip'

if (HasPythonVersion('2.7.5'))
    Bundle 'marijnh/tern_for_vim'
    let g:tern_show_argument_hints = 'on_move'
endif

if HasPythonVersion('2.5.0') && (v:version > 703 || (v:version == 703 && has('patch584')))
    Bundle 'Valloric/YouCompleteMe'
endif

Bundle 'Syntastic'
let g:syntastic_auto_loc_list=1

" syntax highlighting
Bundle 'glsl.vim'
Bundle 'Handlebars'
Bundle 'groenewege/vim-less.git'
Bundle 'JSON.vim'
Bundle 'ingydotnet/yaml-vim'

" colorschemes
Bundle 'sjl/badwolf'
Bundle 'Lokaltog/vim-distinguished'

" Bundle AirLine {{{
if has('python')
    Bundle 'bling/vim-airline'
    set noshowmode
    if has("gui_running")
        let g:airline_powerline_fonts = 1
        set guifont=Meslo\ LG\ M\ Regular\ for\ Powerline:h11

        " TODO: for windows, use Consolas_for_Powerline
    endif
endif
" }}}

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
let g:fuf_maxMenuWidth = 150
let g:fuf_dataDir = '~/.vim/fuf-data'
let g:fuf_coveragefile_exclude = '\v' .
    \ '\.(o|exe|dll|bak|orig|swp|dll|idx|png|jpg|jpeg|pdb)$' .
    \ '|(^|[/\\])' . '\.hg|\.git|\.bzr|node_modules' . '($|[/\\])'

" FufFindByVimPanel function {{{
function! FufFindByVimPanel()
    let dirlist = []

    "save original view + disable autocommands
    let [origbuf, origview, origIgnore] = [bufnr("%"), winsaveview(), &eventignore]
    set eventignore=all

    try
        bufdo if &ft == 'vimpanel'
            \| let filename = g:VimpanelStorage . '/' .  substitute(expand('%'), '\v^vimpanel-', '', '')
            \| let dirlist = dirlist + readfile(filename)
        \| endif
    catch
        " nothing
    finally
        "restore original view + enable autocommands
        exec "buffer " . origbuf
        call winrestview(origview)
        exec 'set eventignore=' . origIgnore
    endtry

    if len(dirlist) > 0
        call fuf#setOneTimeVariables(['g:fuf_coveragefile_globPatterns', map(dirlist, 'v:val . "**/*"')])
        FufCoverageFile
    else
        FufFile
    endif

endfunction
" }}}

nnoremap <leader>b :FufBuffer<cr>
nnoremap <leader>f :call FufFindByVimPanel()<cr>
" }}}

filetype plugin indent on " required!

" }}}

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

if has('gui_running')
    colorscheme badwolf
else
    colorscheme distinguished
endif

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
    if filereadable("$VIMRUNTIME/mswin.vim")
        source $VIMRUNTIME/mswin.vim
    endif
    if &guifont !~? "powerline"
        set guifont=Lucida_Console:h9
    endif
endif

" }}}

" Backups {{{

set backup

" Make Vim able to edit crontab files again.
set backupskip=/tmp/*,/private/tmp/*"

set backupdir=~/.vim/tmp/backup// " backups
set directory=~/.vim/tmp/swap//   " swap files

" Make those folders automatically if they don't already exist.
if !isdirectory(expand(&backupdir))
    call mkdir(expand(&backupdir), "p")
endif
if !isdirectory(expand(&directory))
    call mkdir(expand(&directory), "p")
endif

if has('persistent_undo')
    set undofile
    set undodir=~/.vim/tmp/undo//     " undo files
    if !isdirectory(expand(&undodir))
        call mkdir(expand(&undodir), "p")
    endif
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

" MSBuild {{{

"defines a the MSBuild command. Also defines autocompletion for targets
"
" Usage:
"
"   :MSBuild <target> [[property1=value1] [property2=value2]...]
"
" Examples:
"
"   :MSBuild BeforeBuild
"   :MSBuild BeforeBuild Configuration=Release
"   :MSBuild BuildCSS CSSVersion=005 Configuration=Debug
"
function! FindInParentDir(startdir, pattern)
    let dir = a:startdir
    let safe = 100
    while 1 && safe > 0
        let matches = split(globpath(dir, a:pattern), '\n')
        let safe = safe - 1

        if len(matches) > 0
            return matches[0]
        endif
        let nextdir = fnamemodify(dir, ":h")
        if dir == nextdir
            throw "not found"
        endif
        let dir = nextdir
    endwhile
endfunction

function! MSBuild(target, ...)
    let msbuild = split(globpath("c:\\Windows\\Microsoft.NET\\Framework", "*\\MSBuild.exe"), '\n')[-1]
    let csproj = FindInParentDir(glob("%:p:h"), "*.csproj")
    let sln = FindInParentDir(glob("%:p:h"), "*.sln")
    let cmd = join([
        \ msbuild,
        \ csproj,
        \ "/property:ProjectDir=".  fnamemodify(csproj, ":p:h") . "\\",
        \ "/property:SolutionDir=" . fnamemodify(sln, ":p:h") . "\\",
        \ "/target:" . a:target,
        \ join(map(copy(a:000), '"/property:" . v:val'), ' ')
        \ ], ' ')
    execute "!".cmd
endfunction

function! MSBuildCompletion(ArgLead, CmdLine, CursorPos)
    "only completes targets - for properties you must type them yourself
    let csproj = FindInParentDir(glob("%:p:h"), "*.csproj")
    let lines = filter(readfile(csproj), 'v:val =~ "<Target Name=\"' . a:ArgLead . '"')
    let targets = map(lines, 'substitute(v:val, ".*<Target Name=\"\\(\\w\\+\\)\".*", "\\1", "")')
    return targets
endfunction

command! -complete=customlist,MSBuildCompletion -nargs=+ MSBuild :call MSBuild( <f-args> )

" }}}


if has("autocmd")

    autocmd FileType text setlocal textwidth=78

    " When editing a file, always jump to the last known cursor position.
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

    " store folds on quit, restore them on load
    au BufWinLeave .* if &modifiable | silent mkview | endif
    au BufWinEnter .* if &modifiable | silent loadview | endif

    augroup set_filetypes
        au!
        au BufRead,BufNewFile *.vm setfiletype velocity
        au BufRead,BufNewFile *.brail setfiletype html
        au BufRead,BufNewFile *.drxml setfiletype xml
        au BufRead,BufNewFile *.md setfiletype Markdown
        au BufRead,BufNewFile *.emberhbs setfiletype handlebars
        au BufRead,BufNewFile *.{frag,vert,fp,vp,glsl} setfiletype glsl

        au Filetype perl compiler perl
        au Filetype perl nmap <buffer> <F5> :make<cr>
        au Filetype perl nmap <buffer> <C-F5> :!perl -I "%:p:h" "%:p"<cr>
    augroup END

    augroup vimrcEx
        au!
        au bufreadpost {.,_}vimrc setlocal foldmethod=marker
        au bufwritepost {.,_}vimrc source $MYVIMRC
    augroup END

    augroup ternSettings
        au!
        au Filetype javascript nmap <buffer> <C-]> :TernDef<CR>
        au Filetype javascript nmap <buffer> <leader>th :TernDoc<cr>
        au Filetype javascript nmap <buffer> <leader>tt :TernType<cr>
    augroup END

endif

" map F1 to something sensible instead of help
nmap <f1> :nohlsearch<cr>
imap <f1> <esc>

" make buffers work better
set hidden

" ctags are cool. Let's make vim's support for them even more cool!
set tags=./tags; "look for 'tags' file in parent directories

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

