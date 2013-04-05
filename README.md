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
 7. add this to %HOME%\.vim\.git\hooks\post-checkout:
 ```
#!/bin/sh
rm ~/.vimrc
ln vimrc ~/.vimrc
 ```

### Powerline and windows


Powerline is being ccrappy and opening cmd.exe windows all over the place, when
you edit files in git repositories. To fix it you must install pygit2, which
can be irritating. First, try unzipping the binary distribution from the pygit2
dir, and copy the files from `site_packages` into your own python distribtion.

If it works (`python -c "import pygit2"` doesn't throw errors) your are all done.

If it fails you can try building it from source, which is very difficult...


**Building from source**

First build and install libgit2:

 1. install cmake from here, if it isn't installed: http://www.cmake.org/cmake/resources/software.html (32bit is okay)
 2. `git clone git@github.com:libgit2/libgit2.git`
 3. open the Visual Studio Command Prompt as admin (start -> programs -> visual studio -> visual studio tools)
 4. cd into the libgit2 source directory
 5. `mkdir build && cd build`
 6. `cmake .. -DSTDCALL=OFF -G "Visual Studio 10 Win64"`
 7. `cmake --build . --config release`
 8. `ctest -V`
 7. `cmake --build . --config release --target install`

Okay, libgit is installed now. Now for pygit2 (http://www.pygit2.org/install.html#building-on-windows)

 1. python and distutils should be installed.
 2. `git clone git://github.com/libgit2/pygit2.git`
 3. open the Visual Studio Command Prompt as admin (start -> programs -> visual studio -> visual studio tools)
 4. cd into the pygit2 source directory
 5. `set LIBGIT2=c:\Program Files\libgit2`
 6. `python setup.py build  -c msvc` (I did this twice in a row. First time
    failed with a weird "failed to load and parse the manifest" error. Second
    time apparently worked.)
 7. `copy build\lib.win-amd64-2.7\git2.dll build\lib.win-amd64-2.7\libgit2.dll`
 8. `python setup.py install`

Install still complains about the missing (or misnamed libgit.dll) but it still
seems to copy it correctly. If it doesn't then just copy git2.dll into
site\_packages. No file named libgit2.dll apears to be required, except to make
install sleightly happyer.


# Ideas

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

