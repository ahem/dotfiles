# .zshenv is always sourced. It often contains exported variables that should
# be available to other programs. For example, $PATH, $EDITOR, and $PAGER are
# often set in .zshenv. Also, you can set $ZDOTDIR in .zshenv to specify an
# alternative location for the rest of your zsh configuration.
#
# NOTE: Don't set $PATH in this file (see https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2#the-special-macos)
#       basically, PATH must be set in .zshrc because of something called path_helper

export EDITOR=nvim
export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

# allow PyLSP to run fx. mypy from virtual environments
export PYLSP_MYPY_ALLOW_DANGEROUS_CODE_EXECUTION=1

if ! [[ " ${PKG_CONFIG_PATH//:/ } " =~ " ${HOME}/pkg-config " ]]; then
    export PKG_CONFIG_PATH=${HOME}/pkg-config:${PKG_CONFIG_PATH}
fi

export -U DYLD_FALLBACK_FRAMEWORK_PATH="/opt/homebrew/Frameworks:${DYLD_FRAMEWORK_PATH}"

# this is maybe a bad idea, but this makes it so that brew installed libraries can be found more easily
# also, it makes GStreamer plugins like souphttpsrc work.
export -U DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib:${DYLD_FALLBACK_LIBRARY_PATH}"

# path to load vulkan layers from
export VK_LAYER_PATH=/opt/homebrew/opt/vulkan-validationlayers/share/vulkan/explicit_layer.d
export VK_ICD_FILENAMES=$(/opt/homebrew/bin/rg -u -g 'MoltenVK_icd.json' --files /opt/homebrew/Cellar/molten-vk | head -n1)

. "$HOME/.cargo/env"

alias assume=". assume"
