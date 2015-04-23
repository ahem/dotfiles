## Installation

 1. Clone repository into ~/.vim
 2. `git update submodule -i`
 3. Link `~/.vim/vimrc` to `~/.vimrc`
 4. Link `~/.vim/jshintrc` to `~/.jshintrc` for jshint support
 5. Run vim, and type :PlugInstall [unless vim-plug does it for you :-)]
 6. Happy happy, joy joy

### Windows

 1. Clone and update submodules as above
 2. delete C:\Program Files (x86)\Vim\vimfiles (make sure to backup any scripts in it)
 3. mklink /D "C:\Program Files (x86)\Vim\vimfiles" %HOME%\.vim
 4. mklink %HOME%\.vimrc %HOME%\.vim\vimrc
 5. mklink %HOME%\.jshintrc %HOME%\.vim\jshintrc
 6. run vim, bundleinstall and so on, as above.
 7. add this to %HOME%\.vim\.git\hooks\post-checkout:
 ```
#!/bin/sh
rm ~/.vimrc
ln vimrc ~/.vimrc
 ```

## NeoVim

To fix <c-h> link `xterm-256color.ti` into `~/xterm-256color.ti`. See https://github.com/neovim/neovim/issues/2048#issuecomment-78045837

## Ideas

Completion:
- Tagbar for better ctags support: http://majutsushi.github.com/tagbar/
- ...or maybe something else for CTags support?? http://andrew-stewart.ca/2012/10/31/vim-ctags
- Objective C completion: http://appventure.me/2013/01/use-vim-as-xcode-alternative-ios-mac-cocoa.html

SublimeText features:
- Mark multiple?? https://github.com/adinapoli/vim-markmultiple/
- ...or: https://github.com/hlissner/vim-multiedit (looks better)

Stuff:
- Gundo looks cool: http://sjl.bitbucket.org/gundo.vim/
- vimscript unit testing: https://code.google.com/p/lh-vim/wiki/UT

# TODO
- actually start using Fugitive - installing it is not enough!!!

