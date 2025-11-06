function kchain
    export SHELL=fish
    set key (eza --color=never --oneline --icons=never --only-files --ignore-glob="*.pub|known_hosts*|environment" "$HOME/.ssh" | fzf \
	--reverse \
	--ansi \
	--min-height=7 --height=7%)
    eval (keychain --quiet --eval "$HOME/.ssh/$key")
    export SHELL=dash
end
