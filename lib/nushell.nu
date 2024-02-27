def sync-system [] {
  cd ~/.config/rebos
  git pull origin main

  cd ~

  rebos gen commit "SYNC"
  rebos gen current build
  echo ""
  rebos gen tidy-up
}
