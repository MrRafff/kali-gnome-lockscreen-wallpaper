#!/bin/bash

TARGET="/usr/share/backgrounds/kali/login-blurred"
BACKUP="/usr/share/backgrounds/kali/login-blurred.bak"

if [ -z "$DISPLAY" ]; then
    echo "Run inside GNOME desktop."
    exit 1
fi

choice=$(zenity --list \
    --title="Kali Login Wallpaper Tool" \
    --column="Option" \
    "Set New Wallpaper" \
    "Reset to Default" \
    "Exit")

[ -z "$choice" ] && exit 0

# -------------------------
# SET WALLPAPER
# -------------------------
if [ "$choice" = "Set New Wallpaper" ]; then

    IMAGE=$(zenity --file-selection --title="Select Image")
    [ -z "$IMAGE" ] && exit 0

    BLUR=$(zenity --scale \
        --title="Blur Level" \
        --text="0 = no blur | 100 = heavy blur" \
        --min-value=0 \
        --max-value=100 \
        --value=20)

    [ -z "$BLUR" ] && exit 0

    BLUR_VALUE=$(echo "$BLUR / 10" | bc)

    convert "$IMAGE" \
        -resize 1920x1080^ \
        -gravity center \
        -extent 1920x1080 \
        -blur 0x$BLUR_VALUE \
        PNG:/tmp/login-blurred

    # Backup original only first time
    if [ ! -f "$BACKUP" ] && [ -f "$TARGET" ]; then
        sudo mv "$TARGET" "$BACKUP"
    fi

    sudo mv -f /tmp/login-blurred "$TARGET"
    sudo chmod 644 "$TARGET"

    zenity --info --text="Wallpaper updated."
fi

# -------------------------
# RESET
# -------------------------
if [ "$choice" = "Reset to Default" ]; then

    if [ -f "$BACKUP" ]; then
        sudo mv -f "$BACKUP" "$TARGET"
        zenity --info --text="Original wallpaper restored."
    else
        sudo rm -f "$TARGET"
        zenity --info --text="No backup found. Custom wallpaper removed."
    fi
fi
