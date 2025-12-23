#!/bin/bash
# rotate.sh - Non-root image conversion only
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Jason

GRUB_WIDTH=1920
GRUB_HEIGHT=1080
GRUB_COLORS=256
GRUBBG_DIR="$HOME/.grub-bg"

show_help() {
    cat << EOF
Usage: $0 INTAKE_DIR

Converts raw images from INTAKE_DIR to GRUB format in $GRUBBG_DIR/.
Run with: sudo ./run.sh INTAKE_DIR
EOF
}

case "$1" in
    -h|--help|-help|"") show_help; exit 0 ;;
    *) INTAKE_DIR="$1" ;;
esac

# Check dependencies + directories (non-root safe)
command -v convert >/dev/null 2>&1 || { echo "Install imagemagick"; exit 1; }
command -v file >/dev/null 2>&1 || { echo "Install file"; exit 1; }

mkdir -p "$GRUBBG_DIR"

if [ ! -d "$INTAKE_DIR" ]; then
    echo "Warning: $INTAKE_DIR missing"
    exit 0
fi

# Convert new images (non-root)
echo "Converting images from $INTAKE_DIR..."
for img in "$INTAKE_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
    [ -f "$img" ] || continue
    base=$(basename "$img" | sed 's/\.[^.]*$//')
    grub_version="$GRUBBG_DIR/${base}_grub.png"
    
    [ -f "$grub_version" ] && { echo "Skip: $img"; continue; }
    
    echo "Converting: $img → $grub_version"
    convert "$img" \
        -resize ${GRUB_WIDTH}x${GRUB_HEIGHT}^ \
        -gravity center -extent ${GRUB_WIDTH}x${GRUB_HEIGHT} \
        -strip -colors $GRUB_COLORS \
        "$grub_version" && echo "  ✓ Done"
done

echo "Converted images ready in $GRUBBG_DIR"

