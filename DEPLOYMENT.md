# Server deployment

Run deployments as the account that owns the website files, with Git, Bash,
and Python 3 available. The checkout is `/webhome/webjcao/public_html`.

## First deployment with permission preservation

After these changes have been committed and pushed, run this on the server.
Fetching the new helper before pulling protects the first update too:

```bash
cd /webhome/webjcao/public_html
(
  set -eu
  git config --local core.fileMode false
  git fetch origin main
  deploy_script=$(mktemp)
  trap 'rm -f "$deploy_script"' EXIT
  git show origin/main:gitpull.sh > "$deploy_script"
  bash "$deploy_script"
)
```

For subsequent deployments:

```bash
cd /webhome/webjcao/public_html
bash gitpull.sh
```

`gitpull.sh` runs `git pull --ff-only origin main` and restores the numeric
POSIX permissions of existing regular files and directories, even when Git
fails. It skips `.git` and symbolic links. New files and directories use Git's
recorded executable bit and the server process's umask. Deleted paths are not
recreated; renamed paths count as new paths. The helper does not preserve file
ownership, ACLs, or extended attributes, and is not an atomic deployment:
permissions are restored after Git finishes. Do not run concurrent deployments
or permission changes. Local changes that conflict with the update, or diverged
history, cause deployment to stop rather than discard server changes.

The GitHub Actions workflow uses the same helper, including on its first run.
It no longer resets the checkout or applies recursive `chmod` commands.

## Git permission settings

`gitpush.sh` sets `core.fileMode=false` for the local clone before staging.
For clones where you run Git commands directly, configure this once:

```bash
git config --local core.fileMode false
```

This setting is local to each clone and is not transferred by push or pull.
It ignores executable-bit differences when checking/staging existing files;
it does not remove modes already recorded in Git, undo staged mode changes,
or preserve arbitrary server permissions during a plain `git pull`.
Most existing website files are recorded as executable, so a plain pull can
recreate an updated file as executable even when this setting is false.
Use the helper above when existing server permissions must be retained.
`git push` itself transfers commits and does not change server checkout files;
an enabled deployment workflow runs separately after the push.

Reference: [Git core.fileMode documentation](https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefileMode).
