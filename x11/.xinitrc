#!/bin/sh

setxkbmap -option caps:escape
xset s off -dpms # turn of [s]creen-saver control and Energy Star (DPMS) features
prime-offload &> /dev/null
eval "$SCRIPTS/xconf reload" &	# reload xrandr configuration
eval "$SCRIPTS/em startup" &  	# emacs servers
				# compositor for transparency
picom -b --config ~/.config/picom/$(hostname).conf
nm-applet &			# nmcli widget
flameshot &			# screenshot software - takes up too much memory but copy-to-clipboard functionality doesn't work otherwise
dunst &				# notification daemon
/usr/bin/easystroke &           # mouse gestures on browser
nitrogen --restore &		# wallpaper
# qtile start
exec i3 
eval "$SCRIPTS/em purge"
