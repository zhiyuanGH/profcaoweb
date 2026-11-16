# Personal website deployment

The `webjcao` account on Apollo publishes the personal website from
`/webhome/webjcao/public_html`. Its systemd user timer checks this repository's
`main` every five minutes. Each run fetches `origin/main` using the checkout's
existing read-only GitHub access. If the commit matches the installed version,
the run ends before scanning the website files.

## Install or refresh the timer

Log in as `webjcao` on Apollo. The checkout must use the personal repository as
`origin` and have its local `main` branch checked out. Its Git credentials must
work without a prompt while logged out. Apollo's checkout uses HTTPS. The
service sets `HOME=/webhome/webjcao` so Git can run independently of the
login home. Git, Bash, Python 3 and a systemd user manager are required.

To run after logout and reboot, check `loginctl show-user webjcao -p Linger`.
If it reports `Linger=no`, run `loginctl enable-linger webjcao`. A host
administrator must enable lingering if local policy denies this request.

A login mounts CIFS over `/home/webjcao`. After the last logout, and at boot,
systemd reads its units from the local home underneath that mount. The two
installation steps below put the same unit files in both places. The service
script and its copy of the units live in the private NFS directory
`/webhome/webjcao/.local/lib/profcaoweb-deploy`, accessible in either state.

From an approved copy of `ops/`, run `sh ops/install-timer.sh` as
`webjcao`. This installs the units in the login home and runs one deployment
check immediately. To get the approved files from personal-site `main`:

```bash
cd /webhome/webjcao/public_html
(
  set -euo pipefail
  git fetch --no-tags origin refs/heads/main:refs/remotes/origin/main
  install_from=$(mktemp -d)
  trap 'rm -rf "$install_from"' EXIT
  git archive origin/main -- ops | tar -x -C "$install_from"
  sh "$install_from/ops/install-timer.sh"
)
```

Schedule the second installation, log out of **all** `webjcao` sessions
within 90 seconds and stay logged out until a scheduled five-minute check
has passed:

```sh
systemd-run --user --collect --unit=profcaoweb-install-boot-home \
  --on-active=90s --timer-property=RemainAfterElapse=no \
  /bin/sh /webhome/webjcao/.local/lib/profcaoweb-deploy/install-timer.sh --boot-home
```

The one-time installer checks for zero login sessions, an unmounted home and
ownership by `webjcao` before writing to the local home. Each home has a
regular `timers.target.d/profcaoweb-deploy.conf` drop-in that starts the
timer. A successful boot-home installation records its UTC time in
`boot-home-installed` after the service check. If a login overlapped the
installer, schedule it again and repeat the logout. When `ops/` changes,
repeat both installation steps.

## Check, run and stop

```bash
cat /webhome/webjcao/.local/lib/profcaoweb-deploy/boot-home-installed
systemctl --user show profcaoweb-deploy.timer -p ActiveState -p LastTriggerUSec -p NextElapseUSecRealtime
systemctl --user show profcaoweb-deploy.service -p Result -p ExecMainStatus -p ExecMainExitTimestamp
```

On the next login, look for a new installation timestamp, an active timer
and a trigger after installation and before that login. The corresponding
service should report `Result=success` and `ExecMainStatus=0`. These checks
work even when the user account cannot read the system journal.

Use `systemctl --user start profcaoweb-deploy.service` for an immediate check.
The timer and manual check use the same service, which systemd runs once at a
time. A private pause file prevents deployments in either login state,
including after a reboot:

```bash
touch /webhome/webjcao/.local/lib/profcaoweb-deploy/paused
# To resume on the next timer tick:
rm -f /webhome/webjcao/.local/lib/profcaoweb-deploy/paused
```

When an update is available, the service checks for local edits to tracked
files (including staged changes) and a
fast-forward path before running the repository's `gitpull.sh`. That helper
pulls `origin main` and restores the POSIX modes of existing regular files
and directories, including after a failed pull. It skips symlinks and Git
metadata. New files take their Git executable bit and the deployment umask.
The helper updates the checkout in place. Ownership, ACLs and extended
attributes are outside its permission snapshot. The helper sets
`core.fileMode=false` locally to ignore server-specific executable bits.

For a content rollback, revert the release in the owning repository through
its normal PR process. Once that revert reaches personal-site `main`, the
next timer run can fast-forward to it.
