#!/usr/bin/env bash

dest_path="$HOME/.config/rebos"
base_path="$(echo $0 | sed "s/\/$(basename $0)\$//g")"
cfgs_path="${base_path}/configs"

if [[ -d "$dest_path" ]]; then
  echo "There is already a configuration present on the system!"
  echo "Aborting..."

  exit 1
fi

fzf_installed='0'

if command -v fzf > /dev/null 2>&1; then
  fzf_installed='1'
fi

non_fzf_choose () {
  echo "Configurations:"

  ls "$cfgs_path" | xargs -I {} echo "  -> {}"

  read -p "Type in config name: " chosen_cfg

  full_path="${cfgs_path}/${chosen_cfg}"

  if [[ "$full_path" == "./"* ]]; then
    full_path="$(pwd)/$(echo "$full_path" | sed 's/^.\///')"
  fi

  if [[ -d "$full_path" ]]; then
    echo ""
    echo "Chosen Configuration: $chosen_cfg"

    ln -s "$full_path" "$dest_path"
  else
    echo ""
    echo "Invalid, please try again."
    echo ""

    non_fzf_choose
  fi
}

if [[ "$fzf_installed" == '1' ]]; then
  chosen_cfg=$(ls "$cfgs_path" | fzf --height=~15% --border=double)

  echo "Chosen Configuration: $chosen_cfg"

  full_path="${cfgs_path}/${chosen_cfg}"

  if [[ "$full_path" == "./"* ]]; then
    full_path="$(pwd)/$(echo "$full_path" | sed 's/^.\///')"
  fi

  ln -s "$full_path" "$dest_path"
else
  non_fzf_choose
fi

echo ""
echo "To remove the config, you can simply unlink the config with the following command:"
echo -e "\033[1;36m\$ \033[1;35munlink $dest_path\033[0m"
