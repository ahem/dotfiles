# .zshrc is for interactive shells. You set options for the interactive shell
# there with the setopt and unsetopt commands. You can also load shell modules,
# set your history options, change your prompt, set up zle and completion, et
# cetera. You also set any variables that are only used in the interactive
# shell (e.g. $LS_COLORS).
#
# more "global" environment variables go to .zshenv


# remove duplicat entries from $PATH
# zsh uses $path array along with $PATH
typeset -U PATH path

# set PATH in this wacky way to avoid breaking ./gst-env.py - basically just
# inject local modification right before /usr/local/bin, which is probably
# mostly right.
path_extensions="/opt/homebrew/sbin:/opt/homebrew/bin:$(/opt/homebrew/bin/brew --prefix rustup)/bin"

export -U PATH="${HOME}/.local/bin:${HOME}/.dotnet/tools:${PATH/\/usr\/local\/bin:/$path_extensions:/usr/local/bin:}:${HOME}/Library/Python/3.14/bin"



source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

autoload -Uz compinit && compinit

alias ls='ls -G'

# Set up the prompt (with git branch name)
setopt prompt_subst
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats '%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git

vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
PROMPT=$'%n@%m %1~ $(vcs_info_wrapper)%# '

eval $(thefuck --alias hest)


## Random notes
#
# The Gstreamer gi overrides is a bit wonky with homebrew and multiple versions
# of python so I just brute forced it to work with a hammer and some symlinks:
#
# ln -s /opt/homebrew/lib/python3.12/site-packages/gi/overrides/Gst.py /opt/homebrew/lib/python3.11/site-packages/gi/overrides/Gst.py
# ln -s /opt/homebrew/lib/python3.12/site-packages/gi/overrides/GstVideo.py /opt/homebrew/lib/python3.11/site-packages/gi/overrides/GstVideo.py
# ln -s /opt/homebrew/lib/python3.12/site-packages/gi/overrides/GstAudio.py /opt/homebrew/lib/python3.11/site-packages/gi/overrides/GstAudio.py
# ln -s /opt/homebrew/lib/python3.12/site-packages/gi/overrides/GstPbutils.py /opt/homebrew/lib/python3.11/site-packages/gi/overrides/GstPbutils.py
# ln -s /opt/homebrew/lib/python3.12/site-packages/gi/overrides/_gi_gst.cpython-312-darwin.so /opt/homebrew/lib/python3.11/site-packages/gi/overrides/_gi_gst.cpython-311-darwin.so
