#!/usr/bin/env bash

NOTIF_TITLE="Rebos"

nify-user () {
    extra_flags=""

    [[ "$2" != "" ]] && extra_flags="$2"

    notify-send "$NOTIF_TITLE" "$1" -i distributor-logo-gentoo $extra_flags
}

nify-user-error () {
    nify-user "$1" "-u critical $2"
}

die () {
    echo -e "\033[0;31m[ \033[1;91mFATAL\033[0;31m ]:\033[0m $1" >&2

    nify-user-error "$1"

    exit 1
}

if time sudo emerge -avuDNUg --with-bdeps=y @world; then
    nify-user 'Portage upgrade successful!'
else
    die 'Portage upgrade failed!'
fi
