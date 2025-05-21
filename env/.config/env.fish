#!/usr/bin/env fish

#~~~ -{PATHS}- ~~~#
set SCRIPTS "$HOME/.local/bin"
set DOTFILES "$HOME/dotfiles"
set TRASH "$HOME/.local/share/Trash"
set -xa PATH "$HOME/.local/bin:$HOME/.cargo/bin:$HOME/Next/google-cloud-sdk/bin:$HOME/Android/Sdk/emulator:$HOME/Android/Sdk/cmdline-tools/latest/bin"

#~~~ -{DEFAULT APPLICATIONS}- ~~~#
set EMACS_DAEMONS "personal work default"
set BROWSER "zen-browser"
set TERMINAL "alacritty"
set EDITOR "vim"
set FONT_NAME "Jetbrains Mono"
set VISUAL "$SCRIPTS/em"
