#!/bin/bash

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if command exists
check_cmd() {
    command -v "$1" >/dev/null 2>&1 || { echo -e "${RED}Error: $1 is not installed${NC}"; return 1; }
}

# Music Control
music() {
    check_cmd playerctl || return 1
    case $1 in
        play|pause|next|prev)
            playerctl $1 && echo -e "${GREEN}Music: $1 executed${NC}"
            ;;
        volume)
            pactl set-sink-volume @DEFAULT_SINK@ "${2:-50}%" && echo "Volume set to ${2:-50}%"
            ;;
        status)
            playerctl status
            ;;
        info)
            playerctl metadata --format "Now playing: {{artist}} - {{title}} ({{album}})"
            ;;
        spotify)
            check_cmd spotify || { echo "Please install Spotify first"; return 1; }
            xdg-open "spotify:$2" >/dev/null 2>&1 && echo "Opening Spotify: $2"
            ;;
        mute)
            pactl set-sink-mute @DEFAULT_SINK@ toggle && echo "Audio muted/unmuted"
            ;;
        *)
            echo "MUSIC_CMD: play/pause/next/prev/volume/status/info/spotify/mute"
            ;;
    esac
}

# Development Commands
code() {
    cd ~/Workspace/ &&
    case $1 in
        create-dir)
            mkdir "$2"
            echo "created folder $2"
            ;;
        create-file)
            touch "$2"
            echo "created $2"
            ;;
        open)
            check_cmd code || { echo "Install VSCode first"; return 1; }
            code "$2" >/dev/null 2>&1 && echo "Opening $2 in VSCode"
            ;;
    esac
}

# System Control
brightness() {
    check_cmd brightnessctl || return 1
    sudo brightnessctl set "${1:-50}%" && echo "Brightness set to ${1:-50}%"
}

volume() {
    pactl set-sink-volume @DEFAULT_SINK@ "${1:-50}%" && echo "Volume set to ${1:-50}%"
}

# Package Management
pkg() {
    check_cmd apt || return 1
    case $1 in
        install)
            sudo apt install -y "$2" && echo -e "${GREEN}Installed $2${NC}"
            ;;
        remove)
            sudo apt remove -y "$2" && sudo apt autoremove -y && echo "Removed $2"
            ;;
        update)
            sudo apt update && sudo apt upgrade -y && echo "System updated"
            ;;
        search)
            apt search "$2" | less
            ;;
        list)
            dpkg -l | grep "$2"
            ;;
        *)
            echo "PKG_CMD: install/remove/update/search/list"
            ;;
    esac
}

# Clipboard Management
clipboard() {
    check_cmd xclip || return 1
    case $1 in
        copy)
            echo -n "$2" | xclip -selection clipboard && echo -e "${GREEN}Copied to clipboard${NC}"
            ;;
        paste)
            xclip -selection clipboard -o
            ;;
        clear)
            echo -n "" | xclip -selection clipboard && echo "Clipboard cleared"
            ;;
        *)
            echo "CLIPBOARD_CMD: copy/paste/clear"
            ;;
    esac
}

# Open Browser
browser() {
    check_cmd xdg-open || return 1
    case $1 in
        google)
            #search $2 in google in new tab
            ;;
        *)
            echo ".."
            ;;
    esac
}

# File Operations
file() {
    case $1 in
        find)
            find . -name "*$2*" 2>/dev/null
            ;;
        backup)
            cp "$2" "${2}.bak" && echo "Created backup: ${2}.bak"
            ;;
        size)
            du -sh "$2" | cut -f1
            ;;
        *)
            echo "FILE_CMD: find/backup/size"
            ;;
    esac
}

# System Info
sys() {
    case $1 in
        cpu)
            lscpu | grep "Model name"
            ;;
        memory)
            free -h | grep "Mem:"
            ;;
        disk)
            df -h | grep "/dev/"
            ;;
        temp)
            sensors 2>/dev/null | grep "temp"
            ;;
        *)
            echo "SYS_CMD: cpu/memory/disk/temp"
            ;;
    esac
}

# Main Command Router
case $1 in
    music) shift; music "$@" ;;
    code) shift; code "$@" ;;
    brightness) shift; brightness "$@" ;;
    volume) shift; volume "$@" ;;
    pkg) shift; pkg "$@" ;;
    clipboard) shift; clipboard "$@" ;;
    browser) shift; browser "$@" ;;
    file) shift; file "$@" ;;
    sys) shift; sys "$@" ;;
    help)
        echo "Available commands: music code brightness volume pkg clipboard browser file sys help"
        ;;
    *)
        echo -e "${RED}UNKNOWN_CMD: $1${NC}"
        echo "Try 'help' for available commands"
        ;;
esac

#./tools.sh music status
#./tools.sh brightness 50
#./tools.sh clipboard copy "test"
#./tools.sh sys cpu