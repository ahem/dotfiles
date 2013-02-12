# Installation

 1. Clone repository into ~/.vim
 2. `git update submodule -i`
 3. Link `~/.vim/vimrc` to `~/.vimrc`
 4. Link `~/.vim/jshintrc` to `~/.jshintrc` for jshint support
 5. Run vim, and type :BundleInstall
 6. Happy happy, joy joy

## Windows

 1. Clone and update submodules as above
 2. delete C:\Program Files (x86)\Vim\vimfiles (make sure to backup any scripts in it)
 3. mklink /D "C:\Program Files (x86)\Vim\vimfiles" %HOME%\.vim
 4. mklink %HOME%\.vimrc %HOME%\.vim\vimrc
 5. mklink %HOME%\.jshintrc %HOME%\.vim\jshintrc
 6. run vim, bundleinstall and so on, as above.

# Ideas

- Omnisharp may be interesting for C# highlighting and completion: https://github.com/nosami/Omnisharp
- Get MiniBufExplorer to work again: https://github.com/fholgado/minibufexpl.vi
- Mark multiple?? https://github.com/adinapoli/vim-markmultiple/
- Tagbar for better ctags support: http://majutsushi.github.com/tagbar/
- ...or maybe something else for CTags support?? http://andrew-stewart.ca/2012/10/31/vim-ctags
- sejt git plugin: https://github.com/tpope/vim-fugitive (screencasts med cool demoer)
- Gundo ser cool ud: https://github.com/tpope/vim-fugitive
- vim-surround bliver anbefalet alle mulige steder fra. Måske er det noget værd



