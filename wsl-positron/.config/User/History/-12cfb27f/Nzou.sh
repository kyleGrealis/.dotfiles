#!/usr/bin/env bash

# Run command: `./data_copy.sh`

# This file will copy all necessary data objects from the ctn0094modeling repo here. The current repo *must* be in the same level as ctn0094modeling for correct pathing to work.

# Test & relaunch script with bash if attempted to run with another shell.
if [ -z "$BASH_VERSION" ]; then
  exec bash "$0" "$@"
fi

# Copy function with output
safe_cp() {
  local src="$1"
  local dest="$2"

  if ! cp -r "$src" "$dest"; then
    echo "Failed to copy '$src' --> '$dest'" >&2
    return 1
  fi
}

# Set directories
ORIG_MAIN_DIR="../ml_paper_2022"
ORIG_EXT_DIR="$ORIG_MAIN_DIR/ext"
DEST_EXT_DIR="ext"

# Make the destination directory
mkdir -p "$DEST_EXT_DIR"

# Copy main supplement Quarto file
safe_cp "$ORIG_MAIN_DIR/supplement.qmd" .
safe_cp "$ORIG_MAIN_DIR/the-new-england-journal-of-medicine.csl" .

# Copy data objects (everything inside ext)
safe_cp "$ORIG_EXT_DIR/data" "$DEST_EXT_DIR"
safe_cp "$ORIG_EXT_DIR/modeling" "$DEST_EXT_DIR"
safe_cp "$ORIG_EXT_DIR/tree.drawio" "$DEST_EXT_DIR"
safe_cp "$ORIG_EXT_DIR/tree.png" "$DEST_EXT_DIR"
safe_cp "$ORIG_EXT_DIR/tree.svg" "$DEST_EXT_DIR"
