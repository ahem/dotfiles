set nocompatible
set laststatus=2
set splitright
set splitbelow

" set leader to space, which is more accessible
let mapleader = " "

" platform specific initialisation {{{
if has('nvim')
    " neovim
    runtime! python setup.vim
    let $VIMHOME = $XDG_CONFIG_HOME.'/nvim'
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
Plug 'jimsei/winresizer'
Plug 'reedes/vim-pencil'

Plug 'justinmk/vim-sneak'
vnoremap ,s s

Plug 'moll/vim-bbye'
nmap <leader>q :Bdelete<CR>

if (HasPythonVersion('2.7.2'))
   Plug 'marijnh/tern_for_vim', { 'do': 'npm install; npm update' }
    " let g:tern_show_argument_hints = 'on_move'
    let g:tern_show_argument_hints = 0
endif

if HasPythonVersion('2.5.0') && (v:version > 703 || (v:version == 703 && has('patch584')))
    Plug 'Valloric/YouCompleteMe', { 'do': './install.sh --clang-completer --omnisharp-completer' }
endif

" Plug 'Syntastic'
" let g:syntastic_auto_loc_list=1

Plug 'benekastah/neomake'
Plug 'benjie/neomake-local-eslint.vim'

let g:neomake_javascript_enabled_makers = ['eslint']


" syntax highlighting
Plug 'glsl.vim', { 'for': 'glsl' }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'JSON.vim', { 'for': 'json' }
Plug 'ingydotnet/yaml-vim', { 'for': 'yaml' }
Plug 'mustache/vim-mustache-handlebars', { 'for': ['mustache', 'handlebars', 'html.handlebars'] }
Plug 'othree/yajs.vim', { 'for': ['javascript'] }

" colorschemes
set t_Co=256
Plug 'sjl/badwolf'
Plug 'Lokaltog/vim-distinguished'
if has('nvim')
    set termguicolors
    Plug 'frankier/neovim-colors-solarized-truecolor-only'
else
    Plug 'Solarized'
endif

" " Plug AirLine {{{
" if has('python')
"     Plug 'bling/vim-airline'
"     set noshowmode
"     if has("gui_running")
"         let g:airline_powerline_fonts = 1
"         set guifont=Meslo\ LG\ M\ Regular\ for\ Powerline:h11
" 
"         " TODO: for windows, use Consolas_for_Powerline
"     endif
" endif
" " }}}

" Plug NERDTree {{{

Plug 'scrooloose/nerdtree'
let NERDTreeBookmarksSort = 0
let NERDTreeShowBookmarks = 1
let NERDTreeMinimalUI = 1

nmap <leader>nt :NERDTreeToggle<cr>
nmap <leader>nf :NERDTreeFind<cr>
nmap <leader>nb :NERDTreeFromBookmark<space>
" }}}

" Plug FZF {{{
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }

" List of buffers
function! s:buflist()
    redir => l:ls
    silent ls
    redir END
    return split(l:ls, '\n')
endfunction

function! s:bufopen(e)
    execute 'buffer' matchstr(a:e, '^[ 0-9]*')
endfunction

nnoremap <silent> <Leader>b :call fzf#run({'source': reverse(<sid>buflist()), 'sink': function('<sid>bufopen'), 'down': len(<sid>buflist()) + 2 })<cr>

function! s:vimpanelDirList()
    let l:dirlist = []

    " save original view + disable autocommands
    let [origbuf, origview, origIgnore] = [bufnr("%"), winsaveview(), &eventignore]
    set eventignore=all

    try
        bufdo if &ft == 'vimpanel'
                    \| let l:filename = g:VimpanelStorage . '/' .  substitute(expand('%'), '\v^vimpanel-', '', '')
                    \| let l:dirlist = l:dirlist + readfile(l:filename)
                \| endif
    catch
        let l:dirlist = []
    finally
        " restore original view + enable autocommands
        exec "buffer " . origbuf
        call winrestview(origview)
        exec 'set eventignore=' . origIgnore
    endtry

    return l:dirlist
endfunction

function! s:vimpanelSearch()
    let l:dirlist = copy(s:vimpanelDirList())
    let l:source = 'ag -l -g "" ' . '"' . join(l:dirlist, '" "') . '"'
    if len(l:dirlist) > 0
        call fzf#run({'source': l:source, 'sink': 'e', 'options': '+m' })
    else
        exec ":FZF"
    endif
endfunction

function! s:nerdTreeSearch()
    let l:list = map(copy(g:NERDTreeBookmark.Bookmarks()), 'v:val.path.str()')
    call map(l:list, 'substitute(v:val, "\\c^' . getcwd() . '/", "", "")')
    let l:source = 'ag -l -g "" "' . join(l:list, '" "') . '"'
    call fzf#run({'source': l:source, 'sink': 'e'})
endfunction

nnoremap <silent> <Leader>x :call <sid>nerdTreeSearch()<cr>
nnoremap <silent> <Leader>f :call <sid>vimpanelSearch()<cr>
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
if &encoding != 'utf-8'
    set encoding=utf-8
endif
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
    autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen guibg=lightgreen
    colorscheme solarized
    set background=light
else
    set ttyfast          " make terminal refreshing fast, instead refresh character for character.
    set mouse=a          "enable mouse in console
    if !has('nvim')
        set ttyscroll=3      " Prefer redraw to scrolling for more than 3 lines, prevent glitches when you're scrolling.
        set ttymouse=xterm2 " this aparently doesn't work in neovim anymore??
    endif
    autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
    set background=dark
    colorscheme solarized
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

" NASMKeywordLookup (shift-K for .asm files) {{{
function! NASMKeywordLookup(keyword)

    let l:keyword = match(a:keyword, '\vj\a+') >= 0 ? 'Jcc' : toupper(a:keyword)

    let l:url = 'http://x86.renejeschke.de/' .
        \ system('curl -s http://x86.renejeschke.de/ | grep a\ href.*\\b' . l:keyword .
        \ '\\b | head -1 | sed "s/.*href=\"\(.*\)\".*/\1/"') 
    let l:url = substitute(l:url, '\n\+$', '', '')

    " open buffer
    let l:bufname = "[Assembler Help from x86.renejeschke.de]"
    let l:old_switchbuf = &switchbuf
    try
        "try to select old buffer
        set switchbuf=useopen
        execute 'sbuf' "\\" . l:bufname
        :%d
    catch
        "create a new scratch buffer
        :new
        exec ":file " . l:bufname
        :setlocal buftype=nofile
        :setlocal bufhidden=hide
        :setlocal noswapfile
        :nmap <buffer> K :exec ":call NASMKeywordLookup('" . expand("<cword>") . "')"<CR>
    finally
        let &switchbuf = l:old_switchbuf
    endtry  

    "lookup keyword on x86.renejeschke.de with DuckDuckGo and grep description section of result
    let l:cmd = "curl -s '" . l:url . "' | html2text -nobs -ascii"
    exec "read!". l:cmd

    :1,6d "delete empty lines
    :0
endfunction

command! -nargs=1 NASMKeywordLookup :call NASMKeywordLookup( <f-args> )

augroup nasmKeywordLookup
    autocmd!
    autocmd FileType asm nmap <buffer> K :exec ":silent call NASMKeywordLookup('" . expand("<cword>") . "')"<CR>
augroup END

"}}}


if has("autocmd")

    augroup stuff
        autocmd!
        autocmd FileType text setlocal textwidth=78

        " When editing a file, always jump to the last known cursor position.
        autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

        " store folds on quit, restore them on load
        autocmd BufWinLeave .* if &modifiable | silent mkview | endif
        autocmd BufWinEnter .* if &modifiable | silent loadview | endif
    augroup END

    augroup set_filetypes
        autocmd!
        autocmd BufRead,BufNewFile *.vm setfiletype velocity
        autocmd BufRead,BufNewFile *.brail setfiletype html
        autocmd BufRead,BufNewFile *.drxml setfiletype xml
        autocmd BufRead,BufNewFile *.md setfiletype Markdown
        autocmd BufRead,BufNewFile *.emberhbs setfiletype handlebars
        autocmd BufRead,BufNewFile *.{frag,vert,fp,vp,glsl} setfiletype glsl
        autocmd BufRead,BufNewFile *.json setfiletype json

        autocmd Filetype perl compiler perl
        autocmd Filetype perl nmap <buffer> <F5> :make<cr>
        autocmd Filetype perl nmap <buffer> <C-F5> :!perl -I "%:p:h" "%:p"<cr>

        autocmd BufWritePost *.js Neomake
    augroup END

    augroup vimrcEx
        autocmd!
        autocmd bufreadpost {.,_}vimrc setlocal foldmethod=marker
        autocmd bufreadpost init.vim setlocal foldmethod=marker
        autocmd bufwritepost {.,_}vimrc source $MYVIMRC
        autocmd bufwritepost init.vim source $MYVIMRC
    augroup END

    augroup ternSettings
        autocmd!
        autocmd Filetype javascript nmap <buffer> <C-]> :TernDef<CR>
        autocmd Filetype javascript nmap <buffer> K :TernDoc<cr>
        autocmd Filetype javascript nmap <buffer> <leader>tt :TernType<cr>
        autocmd Filetype javascript nmap <buffer> <leader>td :TernDefPreview<cr>
    augroup END

    augroup youCompleteMeSettings
        autocmd!
        if exists( "g:loaded_youcompleteme" )
            autocmd Filetype python nmap <buffer> <C-]> :YcmCompleter GoToDefinitionElseDeclaration<CR>
        endif
    augroup END

    augroup HighlightingSettings
        autocmd ColorScheme * highlight ExtraWhitespace ctermbg=darkgreen guibg=lightgreen
        autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
        autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
        autocmd InsertLeave * match ExtraWhitespace /\s\+$/
    augroup END

endif

" map F1 to something sensible instead of help
nmap <f1> :nohlsearch<cr>
imap <f1> <esc>

" make buffers work better
set hidden
if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview') && &ft != 'vimpanel' ) | call winrestview(b:winview) | endif
endif

" ctags are cool. Let's make vim's support for them even more cool!
set tags=./tags; "look for 'tags' file in parent directories

nnoremap <Leader>g :e#<CR>

" {{{ window navigation

nmap <c-j> <c-w>j
nmap <c-k> <c-w>k
nmap <c-h> <c-w>h
nmap <c-l> <c-w>l

if has('nvim')
    tnoremap <esc><esc> <c-\><c-n>
    let g:terminal_scrollback_buffer_size = 10000
endif

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

command! -nargs=+ ExecInSplit :vsplit | term "<q-args>"




