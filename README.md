## Installation

 1. Clone repository into ~/.vim
 2. `git update submodule -i`
 3. Link `~/.vim/vimrc` to `~/.vimrc`
 4. Link `~/.vim/jshintrc` to `~/.jshintrc` for jshint support
 5. Run vim, and type :BundleInstall
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

## Tern and YouCompleteMe

After `:MakeBundleInstall`

For tern:
```
cd ~/.vim/bundle/tern_for_vim
npm install
```

For YouCompleteMe:
```
cd ~/.vim/bundle/YouCompleteMe
./install.sh --clang-completer --omnisharp-completer
```

## Ideas

Completion:
- Omnisharp may be interesting for C# highlighting and completion: https://github.com/nosami/Omnisharp
- Tagbar for better ctags support: http://majutsushi.github.com/tagbar/
- ...or maybe something else for CTags support?? http://andrew-stewart.ca/2012/10/31/vim-ctags
- YouCompleteMe is what all the hipsters use for autocompletion. Looks cool too: http://valloric.github.com/YouCompleteMe/
- Objective C completion: http://appventure.me/2013/01/use-vim-as-xcode-alternative-ios-mac-cocoa.html

SublimeText features:
- Mark multiple?? https://github.com/adinapoli/vim-markmultiple/
- ...or: https://github.com/hlissner/vim-multiedit (looks better)

Stuff:
- cool git plugin: https://github.com/tpope/vim-fugitive (screencasts med cool demoer)
- Gundo looks cool: http://sjl.bitbucket.org/gundo.vim/
- vim-surround might be cool: https://github.com/tpope/vim-surround
- try out if this is better than NerdCommenter: https://github.com/tpope/vim-commentary
- vim-repeat for repeating in vim-surrpund and vim-commentary: https://github.com/tpope/vim-repeat
- EasyMotion?? Might take some getting used to: http://www.vim.org/scripts/script.php?script_id=3526
- vimscript unit testing: https://code.google.com/p/lh-vim/wiki/UT


# TODO
- actually start using Fugitive - installing it is not enough!!!

