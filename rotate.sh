#!/bin/bash
# grub-intake-rotate.sh - GRUB background rotator with intake processing
# SPDX-License-Identifier: MIT

# GRUB Compatibility Settings
# - 1920x1080: Common safe resolution (most modern displays)
# - 256 colors: 8-bit palette (GRUB reliable, no alpha channel issues)
# - PNG output: GRUB's preferred format (fastest loading)
GRUB_WIDTH=1920
GRUB_HEIGHT=1080
GRUB_COLORS=256

# the target image
GRUB_BACKGROUND="/boot/grub/background.png"

# changeme to your image directories
INTAKE_DIR="/home/user/intake"
GRUBBG_DIR="/home/user/grubbg"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Must run as root (use sudo)" >&2
    exit 1
fi

# Check dependencies
if ! command -v convert >/dev/null 2>&1; then
    echo "Error: ImageMagick (convert) not installed. Install with: sudo apt install imagemagick" >&2
    exit 1
fi
if ! command -v file >/dev/null 2>&1; then
    echo "Error: file utility not installed. Install with: sudo apt install file" >&2
    exit 1
fi

# Check GRUBBG directory (required)
if [ ! -d "$GRUBBG_DIR" ]; then
    echo "Error: Directory $GRUBBG_DIR does not exist" >&2
    exit 1
fi

# Warn if intake directory missing (optional)
if [ ! -d "$INTAKE_DIR" ]; then
    echo "Warning: Intake directory $INTAKE_DIR missing - skipping new conversions (add it to enable auto-processing)"
else
    # Process new images from intake → grubbg (skip if already converted)
    echo "Processing new images from $INTAKE_DIR..."
    for img in "$INTAKE_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG}; do
        [ -f "$img" ] || continue
        
        base=$(basename "$img" | sed 's/\.[^.]*$//')
        grub_version="$GRUBBG_DIR/${base}_grub.png"
        
        # Skip if already converted (same size)
        if [ -f "$grub_version" ] && [ "$(stat -c%s "$img")" -eq "$(stat -c%s "$grub_version")" ]; then
            echo "  Skip: $img (already converted)"
            continue
        fi
        
        echo "  Converting: $img → $grub_version"
        if convert "$img" \
            -resize ${GRUB_WIDTH}x${GRUB_HEIGHT}^ \
            -gravity center \
            -extent ${GRUB_WIDTH}x${GRUB_HEIGHT} \
            -strip \
            -colors $GRUB_COLORS \
            "$grub_version"; then
            echo "    ✓ Conversion successful"
        else
            echo "    ✗ Conversion failed, skipping" >&2
            continue
        fi
    done
fi

# Rotation logic
echo "Scanning $GRUBBG_DIR for GRUB-compatible images..."
IMAGES=( $(ls "$GRUBBG_DIR"/*_grub.png 2>/dev/null | grep -E '\.png$' | \
           xargs -I {} file {} | \
           grep -v "RGBA\|transparency" | \
           sed 's/:.*//' | sort) )

echo "Found images:"
for img in "${IMAGES[@]}"; do
    echo "  - $img"
done
echo "Total GRUB-compatible images: ${#IMAGES[@]}"

if [ ${#IMAGES[@]} -gt 0 ]; then
    SEED=$(head -c 32 /dev/urandom | tr -dc '0-9' | head -c 10 || echo $$)
    RANDOM=$SEED
    RND=$(( RANDOM % ${#IMAGES[@]} ))
    SELECTED="${IMAGES[$RND]}"
    echo "Selecting: $SELECTED"
    
    if cp "$SELECTED" "$GRUB_BACKGROUND"; then
        echo "SUCCESS: Copied $SELECTED to $GRUB_BACKGROUND"
    else
        echo "ERROR: Copy failed!" >&2
        exit 1
    fi
else
    echo "No GRUB-compatible images found in $GRUBBG_DIR" >&2
    exit 1
fi

