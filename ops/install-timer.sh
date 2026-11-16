#!/bin/sh
set -eu
umask 077

if [ "$(id -un)" != webjcao ]; then
    echo "Install this timer from the webjcao account on the website host." >&2
    exit 1
fi
login_home=/home/webjcao
stable=/webhome/webjcao/.local/lib/profcaoweb-deploy
ops=$(CDPATH= cd "$(dirname "$0")" && pwd)
units="$login_home/.config/systemd/user"

# PAM mounts CIFS over the local home for interactive sessions. A lingering
# user manager reads this same path on the local filesystem at cold boot.
if [ "$#" -eq 1 ] && [ "$1" = --boot-home ]; then
    sessions=$(loginctl show-user webjcao --property=Sessions --value)
    if [ -n "$sessions" ] || mountpoint -q "$login_home" ||
       [ ! -d "$login_home" ] || [ -L "$login_home" ] ||
       [ "$(stat -c %u "$login_home")" != "$(id -u)" ]; then
        echo "Boot home unavailable. Log out of all sessions and schedule this step again." >&2
        exit 1
    fi
elif [ "$#" -eq 0 ]; then
    if [ "$(findmnt -n -o FSTYPE -T "$login_home")" != cifs ]; then
        echo "Install from a webjcao login session with its CIFS home mounted." >&2
        exit 1
    fi
    install -d -m700 "$stable"
    if [ "$ops" != "$stable" ]; then
        install -m700 "$ops/deploy-main.sh" "$ops/install-timer.sh" "$stable/"
        install -m600 "$ops/profcaoweb-deploy.service" "$ops/profcaoweb-deploy.timer" \
            "$ops/profcaoweb-deploy.conf" "$stable/"
    fi
else
    echo "Usage: install-timer.sh [--boot-home]" >&2
    exit 2
fi

install -Dm600 "$stable/profcaoweb-deploy.service" "$units/profcaoweb-deploy.service"
install -Dm600 "$stable/profcaoweb-deploy.timer" "$units/profcaoweb-deploy.timer"
install -Dm600 "$stable/profcaoweb-deploy.conf" "$units/timers.target.d/profcaoweb-deploy.conf"
systemctl --user daemon-reload
systemctl --user start profcaoweb-deploy.timer
systemctl --user start profcaoweb-deploy.service
systemctl --user list-timers profcaoweb-deploy.timer
if [ "${1:-}" = --boot-home ]; then
    date -u '+%Y-%m-%dT%H:%M:%SZ' > "$stable/boot-home-installed"
fi
