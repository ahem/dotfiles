set nocompatible
set laststatus=2

" set leader to comma, which is more accessible
let mapleader = ","

" platform specific initialisation {{{
if has('nvim')
    " neovim
    runtime! python setup.vim
    let $VIMHOME = $HOME.'/.nvim'
    silent! mkdir(expand($VIMHOME), "p")
else
    if has('win32') || has ('win64')
        " Windows
        let $VIMHOME = $VIM.'/vimfiles'

        if filereadable("$VIMRUNTIME/mswin.vim")
            source $VIMRUNTIME/mswin.vim
        endif
        if &guifont !~? "powerline"
            set guifont=Lucida_Console:h9
        endif
    else
        " Unix / OSX
        let $VIMHOME = $HOME.'/.vim'
    endif
endif
" }}}

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

" Plugins {{{

" attempt to download the plugin manager, if it is missing
if empty(glob($VIMHOME.'/autoload/plug.vim'))
    silent! call mkdir($VIMHOME."/autoload", "p")
    silent! execute "!curl -fLo ".$VIMHOME."/autoload/plug.vim https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
    autocmd VimEnter * PlugInstall
endif

call plug#begin($VIMHOME.'/plugged')

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'matchit.zip'
Plug 'repeat.vim'
Plug 'surround.vim'
Plug 'unimpaired.vim'
Plug 'jewes/Conque-Shell'

Plug 'justinmk/vim-sneak'
vnoremap ,s s

Plug 'moll/vim-bbye'
nmap <leader>q :Bdelete<CR>

if (HasPythonVersion('2.7.2'))
   Plug 'marijnh/tern_for_vim', { 'do': 'npm install' }
    let g:tern_show_argument_hints = 'on_move'
endif

if HasPythonVersion('2.5.0') && (v:version > 703 || (v:version == 703 && has('patch584')))
    Plug 'Valloric/YouCompleteMe', { 'do': './install.sh --clang-completer --omnisharp-completer' }
endif

Plug 'Syntastic'
let g:syntastic_auto_loc_list=1

Plug 'christoomey/vim-tmux-navigator'

" syntax highlighting
Plug 'glsl.vim', { 'for': 'glsl' }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'JSON.vim', { 'for': 'json' }
Plug 'ingydotnet/yaml-vim', { 'for': 'yaml' }
Plug 'mustache/vim-mustache-handlebars', { 'for': ['mustache', 'handlebars', 'html.handlebars'] }

" colorschemes
set t_Co=256
Plug 'sjl/badwolf'
Plug 'Lokaltog/vim-distinguished'
Plug 'Solarized'

" Plug AirLine {{{
if has('python')
    Plug 'bling/vim-airline'
    set noshowmode
    if has("gui_running")
        let g:airline_powerline_fonts = 1
        set guifont=Meslo\ LG\ M\ Regular\ for\ Powerline:h11

        " TODO: for windows, use Consolas_for_Powerline
    endif
endif
" }}}

" Plug Vimpanel {{{
Plug 'mihaifm/vimpanel'
let g:NERDTreeWinPos='left'
let g:NERDTreeWinSize=40
let g:VimpanelStorage=$VIMHOME.'/vimpanel'
cabbrev vp Vimpanel
cabbrev vl VimpanelLoad
cabbrev vc VimpanelCreate
cabbrev ve VimpanelEdit
cabbrev vr VimpanelRemove
cabbrev vss VimpanelSessionMake
cabbrev vsl VimpanelSessionLoad
" }}}

" Plug FuzzyFinder {{{
"L9 is required by FuzzyFinder
Plug 'L9'
Plug 'FuzzyFinder'
let g:fuf_maxMenuWidth = 150
let g:fuf_dataDir = $VIMHOME.'/fuf-data'
let g:fuf_coveragefile_exclude = '\v' .
    \ '\.(o|exe|dll|bak|orig|swp|dll|idx|png|jpg|jpeg|pdb|pyc)$' .
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


call plug#end()

" }}}

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=50   " keep 50 lines of command line history
set ruler        " show the cursor position all the time
set showcmd      " display incomplete commands
set incsearch    " do incremental searching
set noignorecase " do casesensitive searching (\c anywhere in pattern for insensitive)

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
    colorscheme solarized
    set background=light
else
    set mouse=a          "enable mouse in console
    colorscheme badwolf
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

" Backups {{{

set backup

" Make Vim able to edit crontab files again.
set backupskip=/tmp/*,/private/tmp/*"

let s:myBackupDir = $VIMHOME.'/tmp/backup'
silent! call mkdir(expand(s:myBackupDir), "p")
let &backupdir = s:myBackupDir."//"

let s:mySwapDir = $VIMHOME.'/tmp/swap'
silent! call mkdir(expand(s:mySwapDir), "p")
let &directory = s:mySwapDir."//"

if has('persistent_undo')
    let s:myUndoDir = $VIMHOME.'/tmp/undo'
    silent! call mkdir(expand(s:myUndoDir), "p")
    let &undodir = s:myUndoDir."//"
    set undofile
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

" Highlight Word {{{
"
" This mini-plugin provides a few mappings for highlighting words temporarily.
"
" Sometimes you're looking at a hairy piece of code and would like a certain
" word or two to stand out temporarily.  You can search for it, but that only
" gives you one color of highlighting.  Now you can use <leader>N where N is
" a number from 1-6 to highlight the current word in a specific color.

function! HiInterestingWord(n) " {{{
    " Save our location.
    normal! mz

    " Yank the current word into the z register.
    normal! "zyiw

    " Calculate an arbitrary match ID.  Hopefully nothing else is using it.
    let mid = 86750 + a:n

    " Clear existing matches, but don't worry if they don't exist.
    silent! call matchdelete(mid)

    " Construct a literal pattern that has to match at boundaries.
    let pat = '\V\<' . escape(@z, '\') . '\>'

    " Actually match the words.
    call matchadd("InterestingWord" . a:n, pat, 1, mid)

    " Move back to our original location.
    normal! `z
endfunction " }}}

" Mappings {{{

nnoremap <silent> <leader>1 :call HiInterestingWord(1)<cr>
nnoremap <silent> <leader>2 :call HiInterestingWord(2)<cr>
nnoremap <silent> <leader>3 :call HiInterestingWord(3)<cr>
nnoremap <silent> <leader>4 :call HiInterestingWord(4)<cr>
nnoremap <silent> <leader>5 :call HiInterestingWord(5)<cr>
nnoremap <silent> <leader>6 :call HiInterestingWord(6)<cr>

" }}}
" Default Highlights {{{

hi def InterestingWord1 guifg=#000000 ctermfg=16 guibg=#ffa724 ctermbg=214
hi def InterestingWord2 guifg=#000000 ctermfg=16 guibg=#aeee00 ctermbg=154
hi def InterestingWord3 guifg=#000000 ctermfg=16 guibg=#8cffba ctermbg=121
hi def InterestingWord4 guifg=#000000 ctermfg=16 guibg=#b88853 ctermbg=137
hi def InterestingWord5 guifg=#000000 ctermfg=16 guibg=#ff9eb8 ctermbg=211
hi def InterestingWord6 guifg=#000000 ctermfg=16 guibg=#ff2c4b ctermbg=195

" }}}

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
        au BufRead,BufNewFile *.json setfiletype json

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

    augroup youCompleteMeSettings
        au!
        if exists( "g:loaded_youcompleteme" )
            au Filetype python nmap <buffer> <C-]> :YcmCompleter GoToDefinitionElseDeclaration<CR>
        endif
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

" {{{ window navigation

nmap <c-j> <c-w>j
nmap <c-k> <c-w>k
nmap <c-h> <c-w>h
nmap <c-l> <c-w>l

" }}}


" wrap some text with {% translate %} tags for translation. Auto generates key
" from first six words. Call with motion, fx. AddTranslationTag("it") for
" inner tag or AddTranslationTag("i\"") for inner qoutes.
function! AddTranslationTag(motion)
    "grab tag contents
    exec "normal d".a:motion

    "generate key
    let key = tolower(join(filter(split(@", '\W')[:5], '!empty(v:val)'), '_'))

    "print opening tag
    exec "normal i"."{% translate ".key." %}"

    "put the text back
    normal gp

    "print end tag
    exec "normal i"."{% endtranslate %}"
endfunction 

" wrap some text with {% trans %} tags for translation. Call with motion, fx.
" AddJinjaTranslationTag("it") for inner tag or AddJinjaTranslationTag("i\"")
" for inner qoutes.
function! AddJinjaTranslationTag(motion)
    "grab tag contents
    exec "normal d".a:motion

    "print opening tag
    exec "normal i"."{% trans %}"

    "put the text back
    normal gp

    "print end tag
    exec "normal i"."{% endtrans %}"
endfunction 

