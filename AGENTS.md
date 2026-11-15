# Maintaining Prof. Cao's website

This repository serves `index.html` and the jQuery-loaded fragments in
`sub_parts/`. Keep the existing filenames, section order, links and styles.

The editable publication, book, patent and award catalog lives in
[zhiyuanGH/imcl-website](https://github.com/zhiyuanGH/imcl-website/tree/main/data/shared).
`shared-catalog.rev` pins the source commit used for this site's reviewed output.
On an IMCL checkout at that commit, the following local check also verifies
that the catalog and renderer are clean. Run from the personal checkout:

```sh
python _tools/check_shared.py --imcl-root ../IMCL-Website
```

Make shared edits on a review branch in the IMCL checkout and render there:

```sh
python _tools/render_shared.py --site both --prof-root ../profcaoweb
python _tools/render_shared.py --site both --prof-root ../profcaoweb --check
```

The annual Papers list, Recently Accepted, homepage papers, Books, Book
Chapters, Patents and the three Awards lists each have their own selection.
An ID in the annual list does not add it to the homepage. Commit the resulting
personal fragments and the reviewed IMCL commit ID in `shared-catalog.rev`
together in a personal-site PR. The lab's publication Google Sheet is read-only.
Grants, teaching, service, biography, group, demos and archived pages remain
locally maintained. See the [cross-site guide](https://github.com/zhiyuanGH/imcl-website/blob/main/docs/joint-site-management.md).

Production uses this repository's `main`, the `webjcao` account and the
existing permission-preserving helper. Branch PRs support review and previews.
Obtain release approval before merging to `main` or dispatching the production
workflow. Deployment details are in [DEPLOYMENT.md](DEPLOYMENT.md).
