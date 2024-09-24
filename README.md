# Rebos Configuration

This config is structured weirdly. This is so I can store all my distro configs in one repo.

Please note that this is my own personal configuration, so I recommend forking it.
I am not accepting pull requests unless it is to improve my configuration.

### Assuming you cloned the repo as `~/.config/rebos-cfgs`:

- Here is how you choose a config: `$ ln -s $HOME/.config/rebos-cfgs/configs/<insert OS name> $HOME/.config/rebos` (DON'T DO IT LIKE THIS)
- You can also run the choosing script: `~/.config/rebos-cfgs/choose-config.sh` (RECOMMENDED METHOD)
- You should also add this to your .bashrc so you can sync the system with `sync-system`: `source ~/.config/rebos-cfgs/lib/bash.sh`
