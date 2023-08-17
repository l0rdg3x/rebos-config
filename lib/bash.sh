#!/usr/bin/env bash

build-system () {
  dister gen current build
}

sync-system () {
  cd $HOME/.config/dister
  git pull origin maini

  cd $HOME

  dister gen commit "SYNC"

  build-system
}
