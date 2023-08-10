#!/usr/bin/env bash

sync-system () {
  cd $HOME/.config/dister
  git pull origin main
}

build-system () {
  dister gen current build
}
