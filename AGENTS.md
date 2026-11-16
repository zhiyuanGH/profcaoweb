# Maintaining Prof. Cao's website

**For a shared publication, book, award or patent, edit the catalog and open one PR in [imcl-website](https://github.com/zhiyuanGH/imcl-website/tree/main/data/shared).** The IMCL Actions workflow updates this repository's three managed HTML fragments and `shared-catalog.rev` automatically. The lab publication Sheet is read-only.

The IMCL [agent guide](https://github.com/zhiyuanGH/imcl-website/blob/main/AGENTS.md) explains how to select an annual list, the homepage or Recently Accepted. Leave the existing HTML markers around historical entries and the slots for new entries in place. From this checkout, `python _tools/check_shared.py --imcl-root ../IMCL-Website` verifies a deployment against its pinned source revision.

For a personal-site layout or an independent teaching, grants, group, service, biography or demo update, make a personal-site PR. Keep the existing fragment names, jQuery tabs, styles and website URLs.

The `webjcao` account pulls its own `main` every five minutes once the timer is installed. The owner's permission-preserving helper applies updates. See [DEPLOYMENT.md](DEPLOYMENT.md) for first setup and deployment logs.
