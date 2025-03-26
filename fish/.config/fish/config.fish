### MY STUFF ###

source "$HOME/.config/env.fish"

set -x MANPAGER "bat -l man --style full"
set TERM "xterm-256color"
set -x TEXMFCNF "~/.config:"
set fish_cursor_insert block

set -x LD_LIBRARY_PATH "$LD_LIBRARY_PATH:/usr/lib/"
# set -p PATH ~/.cargo/bin
# set -p PATH ~/Next/google-cloud-sdk/bin


# keychain --quiet --eval --agents ssh id_ed25519

abbr dc "docker-compose"
abbr warp-enable "sudo systemctl enable --now warp-svc.service"
abbr warp-disable "warp disconnect && sudo systemctl disable --now warp-svc.service"
abbr comp-suspend "qdbus org.kde.KWin /Compositor suspend"
abbr comp-resume "qdbus org.kde.KWin /Compositor resume"
abbr ec "emacsclient -c"
abbr yt "youtube-dl"
abbr alac-theme "alacritty-colorscheme -c $HOME/.config/alacritty/alacritty.yml -C $HOME/.config/alacritty/themes"
abbr battery "echo (cat /sys/class/power_supply/BAT1/capacity)%"
abbr source-fish "source $HOME/.config/fish/config.fish"
abbr opt-man "prime-offload &> /dev/null && optimus-manager"
abbr enable-monitor "xrandr --output "eDP-1" --off --output "HDMI-1-0" --primary --mode 1920x1080 --rate 144"
abbr cds "cd $HOME/scripts/scripts"
abbr cdn "cd $HOME/notes"
abbr cdd "cd $HOME/dotfiles"
abbr cdp "cd $HOME/Packt/"
abbr cdr "cd $HOME/repos"
abbr s 'nvim $HOME/scripts/scripts/scratchpad'
abbr ydl-music "youtube-dl -wc -o /mnt/HDD/MUSIC/'%(uploader)s/%(title)s.%(ext)s' --write-description --embed-thumbnail -x --audio-format 'mp3'"
abbr ydl-clips "youtube-dl -wc -o /mnt/HDD/MOVIES-SERIES/clips/'%(title)s.%(ext)s' --embed-thumbnail -f best"
abbr emr "emacsclient -e '(kill-emacs)' && emacs --daemon"

alias paru="paru --bottomup"
alias doom="$HOME/.emacs.d/bin/doom"
alias lf="lfrun"


### ~~~~~~~~~~~~~~~~~~~~~ ###
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"

## Export variable need for qt-theme
if type "qtile" >> /dev/null 2>&1
   set -x QT_QPA_PLATFORMTHEME "qt5ct"
end

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low


## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
  source ~/.fish_profile
end

## Starship prompt
if status --is-interactive
	source ("/usr/bin/starship" init fish --print-full-init | psub)
end

## Advanced command-not-found hook
# source /usr/share/doc/find-the-command/ftc.fish

# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

function activate
	set DIR "$HOME/.virtualenvs"
	set ACCENT "$(tput setaf 3)"
	set BOLD "$(tput bold)"
	set NORM "$(tput sgr0)"

	set env $(find "$DIR" -maxdepth 1 -printf "%f\n" \
	| tail -n +2 \
	| while read l;
		printf "%s $ACCENT$BOLD(🐍 v%s)$NORM\n" "$l" "$($DIR/$l/bin/python --version | awk '{print $2}')";
	end | fzf --reverse \
		--ansi \
		--min-height=7 --height=7% \
		--cycle -m --marker="*" \
		--bind 'tab:down' --bind 'btab:up' \
		--bind 'shift-down:toggle+down' --bind 'shift-up:toggle+up' \
	| awk '{print $1}')

	[ -n "$env" ] && source "$DIR/$env/bin/activate.fish"
end

## Useful aliases
# Replace ls with exa
alias ls='exa -al --color=always --group-directories-first --icons' # preferred listing
alias la='exa -a --color=always --group-directories-first --icons'  # all files and dirs
alias ll='exa -l --color=always --group-directories-first --icons'  # long format
alias lt='exa -aT --color=always --group-directories-first --icons' # tree listing
alias l.="exa -a | egrep '^\.'"                                     # show only dotfiles

# Replace some more things with better alternatives
alias cat='bat --style header --style snip --style changes --style header'

# Common use
alias grubup="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias rmpkg="sudo pacman -Rdd"
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias upd='/usr/bin/update'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
# alias grep='rg --color auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias hw='hwinfo --short'                                   # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl"              # Sort installed packages according to size in MB
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l'      # List amount of -git packages

# Get fastest mirrors
alias mirror="sudo reflector -f 30 -l 30 --number 10 --verbose --save /etc/pacman.d/mirrorlist"
alias mirrord="sudo reflector --latest 50 --number 20 --sort delay --save /etc/pacman.d/mirrorlist"
alias mirrors="sudo reflector --latest 50 --number 20 --sort score --save /etc/pacman.d/mirrorlist"
alias mirrora="sudo reflector --latest 50 --number 20 --sort age --save /etc/pacman.d/mirrorlist"

# Help people new to Arch
alias apt='man pacman'
alias apt-get='man pacman'
alias please='sudo'
alias tb='nc termbin.com 9999'

# Cleanup orphaned packages
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"

# Recent installed packages
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"

## Run paleofetch if session is interactive
# if status --is-interactive
#    neofetch
# end
