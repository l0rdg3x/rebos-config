#!/usr/bin/env bash

sync-system () {
  path_cache_path="$HOME/.cache/rebos_cfgs_path"
  default_path="$HOME/.config/rebos-cfgs"

  final_path=""

  if [[ -f "$path_cache_path" ]]; then
    final_path="$(cat "$path_cache_path")"
  else
    echo "Enter the full path to Rebos configs Git repo on system..."
    read -p "[Default: $default_path]: " input_path
    echo ""

    final_path="$input_path"

    if [[ "$input_path" == "" ]]; then
      final_path="$default_path"
    fi
  fi

  if [[ -d "$final_path" ]]; then
    [[ -f "$path_cache_path" ]] || echo "$final_path" > "$path_cache_path"

    cd "$final_path"
    git pull origin main

    cd "$HOME"

    rebos gen commit "SYNC"
    rebos gen current build
    echo ""
    rebos gen tidy-up
  else
    echo "Path does not exist! Try again!"
    echo ""

    sync-system
  fi
}
