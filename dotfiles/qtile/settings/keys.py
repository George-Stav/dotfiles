# Antonio Sarosi
# https://youtube.com/c/antoniosarosi
# https://github.com/antoniosarosi/dotfiles

# Qtile keybindings

from libqtile.config import Key
from libqtile.command import lazy
from libqtile.utils import send_notification
import json


mod = "mod1"
scripts_dir = "/home/george/dev/scripts/scripts/"

# @lazy.function
# def cycle_groups(qtile, key="prev"):
#     if key == "next":
#         group = qtile.current_screen.group.get_next_group()
#     else:
#         group = qtile.current_screen.group.get_previous_group()
#     qtile.current_screen.set_group(group)

# def latest_group(qtile):
#     qtile.current_screen.set_group(qtile.current_screen.previous_group)

@lazy.function
def testing(qtile, obj="Empty"):
    # string = qtile.cmd_windows()
    windows = {w.name:w.group.name for w in qtile.windows_map.values() if w.group is not None}
    # qtile.cmd_spawn(f'rofi -e "{windows}"')
    qtile.cmd_spawn(f'rofi -e "{qtile.window.name}"')

keys = [Key(key[0], key[1], *key[2:]) for key in [
    # ------------ Testing ------------

    ([mod, "control"], "Return", testing),

    # ------------ Group Configs ------------

    # Cycle through groups
    ([mod, "control"], "comma", lazy.screen.prev_group()),
    ([mod, "control"], "period", lazy.screen.next_group()),

    # Toggle between the latest 2 groups
    ([mod], "grave", lazy.screen.toggle_group()),

    # ------------ Window Configs ------------
    ([mod, "shift"], "m", lazy.window.toggle_minimize()),
    ([mod, "shift"], "f", lazy.window.toggle_fullscreen()),

    # Switch between windows in current stack pane
    ([mod], "j", lazy.layout.down()),
    ([mod], "k", lazy.layout.up()),
    ([mod], "h", lazy.layout.left()),
    ([mod], "l", lazy.layout.right()),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    ([mod, "control"], "h", lazy.layout.grow_left()),
    ([mod, "control"], "l", lazy.layout.grow_right()),
    ([mod, "control"], "j", lazy.layout.grow_down()),
    ([mod, "control"], "k", lazy.layout.grow_up()),
    ([mod], "n", lazy.layout.normalize()),

    # Toggle floating
    ([mod, "control"], "f", lazy.window.toggle_floating()),

    # Move windows up or down in current stack
    ([mod, "shift"], "j", lazy.layout.shuffle_down()),
    ([mod, "shift"], "k", lazy.layout.shuffle_up()),
    ([mod, "shift"], "l", lazy.layout.shuffle_right()),
    ([mod, "shift"], "h", lazy.layout.shuffle_left()),

    # Toggle between different layouts as defined below
    ([mod], "Tab", lazy.next_layout()),
    ([mod, "shift"], "Tab", lazy.prev_layout()),

    # Kill window
    ([mod], "q", lazy.window.kill()),

    # Switch focus of monitors
    ([mod], "comma", lazy.next_screen()),
    ([mod], "period", lazy.prev_screen()),

    # Restart Qtile
    ([mod, "control"], "r", lazy.restart()),
    ([mod, "control"], "q", lazy.shutdown()),

    # ------------ App Configs ------------

    # Rofi
    ([mod], "m", lazy.spawn("rofi -show drun")),
    ([mod], "r", lazy.spawn("rofi -show run")),
    ([mod], "w", lazy.spawn("rofi -show window")),

    # Browser
    ([mod], "b", lazy.spawn("firefox")),

    # Emacs
    ([mod], "e", lazy.spawn("emacsclient -c")),
    ([mod, "shift"], "e", lazy.spawn("systemctl --user restart emacs")),
    ([mod], "d", lazy.spawn("emacsclient -c -a 'emacs' --eval '(dired nil)'")),

    # File Explorer
    # ([mod], "e", lazy.spawn("pcmanfm")),

    # Terminal
    ([mod], "Return", lazy.spawn("alacritty")),

    # Redshift
    # ([mod], "r", lazy.spawn("redshift -O 2400")),
    # ([mod, "shift"], "r", lazy.spawn("redshift -x")),

    # Screenshot
    # ([mod], "s", lazy.spawn("scrot")),
    # ([mod, "shift"], "s", lazy.spawn("scrot -s")),
    ([mod, "shift"], "s", lazy.spawn("flameshot gui")),

    # ------------ Utility Configs ------------

    ([mod], "space", lazy.spawn('cycle-kb-layout')),

    # ------------ Hardware Configs ------------

    # Volume
    ([], "XF86AudioLowerVolume", lazy.spawn(
        "change-volume -2%"
    )),
    ([], "XF86AudioRaiseVolume", lazy.spawn(
        "change-volume +2%"
    )),
    ([], "XF86AudioMute", lazy.spawn(
        "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    )),
    ([], "XF86AudioPlay", lazy.spawn(
        "playerctl play-pause"
    )),
    ([], "XF86AudioPrev", lazy.spawn(
        "playerctl previous"
    )),
    ([], "XF86AudioNext", lazy.spawn(
        "playerctl next"
    )),

    # Brightness
    ([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +5%")),
    ([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%-")),
]]
