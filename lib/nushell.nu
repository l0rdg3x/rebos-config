def build-system [] {
  dister gen current build
}

def sync-system [] {
  cd ~/.config/dister
  git pull origin main

  cd ~

  dister gen commit "SYNC"

  build-system
}
