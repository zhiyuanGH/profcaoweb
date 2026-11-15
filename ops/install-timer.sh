#!/bin/sh
set -eu

if [ "$(id -un)" != webjcao ]; then
    echo "Install this timer from the webjcao account on the website host." >&2
    exit 1
fi
ops=$(CDPATH= cd "$(dirname "$0")" && pwd)
units="$HOME/.config/systemd/user"
install -Dm700 "$ops/deploy-main.sh" "$HOME/.local/lib/profcaoweb-deploy/deploy-main.sh"
install -Dm600 "$ops/profcaoweb-deploy.service" "$units/profcaoweb-deploy.service"
install -Dm600 "$ops/profcaoweb-deploy.timer" "$units/profcaoweb-deploy.timer"
install -Dm600 "$ops/profcaoweb-deploy.conf" "$units/timers.target.d/profcaoweb-deploy.conf"
systemctl --user daemon-reload
systemctl --user start profcaoweb-deploy.timer
systemctl --user start profcaoweb-deploy.service
systemctl --user list-timers profcaoweb-deploy.timer
