#!/bin/bash
# run.sh - Root wrapper for grub-rotate.sh
# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2025 Jason

# Check root
if [ "$EUID" -ne 0 ]; then
    echo "Error: run.sh must be run as root (sudo $0)" >&2
    exit 1
fi

# Find rotate.sh owner (username) and switch user
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
ROTATE_SH="$SCRIPT_DIR/rotate.sh"
OWNER=$(stat -c '%U' "$ROTATE_SH")

if [ ! -f "$ROTATE_SH" ]; then
    echo "Error: rotate.sh not found in $SCRIPT_DIR" >&2
    exit 1
fi

# Run rotate.sh and check its return value
if su - "$OWNER" -c "cd '$SCRIPT_DIR' && ./rotate.sh '$1'"; then
    echo "✓ Conversion phase completed successfully"
    
    # Root phase: only proceed if conversion succeeded
    echo "Root phase: Applying GRUB changes..."
    GRUBBG_DIR="/home/$OWNER/.grub-bg"
    GRUB_BACKGROUND="/boot/grub/background.png"

    IMAGES=( $(ls "$GRUBBG_DIR"/*_grub.png 2>/dev/null | grep -E '\.png$' | \
               xargs -I {} file {} | \
               grep -v "RGBA\|transparency" | \
               sed 's/:.*//' | sort) )

    if [ ${#IMAGES[@]} -gt 0 ]; then
        SEED=$(head -c 32 /dev/urandom | tr -dc '0-9' | head -c 10 || echo $$)
        RANDOM=$SEED
        RND=$(( RANDOM % ${#IMAGES[@]} ))
        SELECTED="${IMAGES[$RND]}"
        echo "Selecting: $SELECTED"
        
        if cp "$SELECTED" "$GRUB_BACKGROUND"; then
            echo "SUCCESS: Copied to $GRUB_BACKGROUND"
            echo "Running update-grub..."
            if update-grub; then
                echo "✓ update-grub completed"
            else
                echo "✗ update-grub failed, but background updated" >&2
            fi
        else
            echo "ERROR: Copy failed!" >&2
            exit 1
        fi
    else
        echo "No GRUB-compatible images found in $GRUBBG_DIR" >&2
        exit 1
    fi
else
    echo "✗ Conversion phase failed - aborting GRUB update" >&2
    exit 1
fi

