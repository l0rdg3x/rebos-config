#!/usr/bin/env bash

sync-system () {
  cd $HOME/.config/rebos
  git pull origin main

  cd $HOME

  rebos gen commit "SYNC"
  rebos gen current build
  echo ""
  rebos gen tidy-up
}
