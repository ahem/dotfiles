# Dotfiles

This is my dotfiles. They are managed with GNU Stow. Install the with a package
manager, like, `brew install stow`.

To install checkout this repo, then from inside it do `stow --target=$HOME .`.

Note: `--target=$HOME` is required because Stow's default target is the
parent directory of wherever this repo is checked out, which usually isn't
`$HOME`. Omitting it will create symlinks in the wrong place.
