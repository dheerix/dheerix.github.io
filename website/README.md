# Dheerix Portfolio Website

The public build contains only the portfolio. The searchable Knowledge library is
excluded from the GitHub Pages artifact and has no public portfolio link.

## Local preview

```bash
DHEERIX_INCLUDE_KNOWLEDGE=1 node website/generate-site.mjs
python3 -m http.server 8000 --directory website/dist
```

Open `http://localhost:8000` for the portfolio and `http://localhost:8000/learn/`
for the local-only Knowledge library.

Running `node website/generate-site.mjs` without the environment flag creates the
same public artifact used by GitHub Actions and does not include `/learn/`.

This prevents the Knowledge library from being published as a website. It is not
authentication: repository files remain subject to the repository's own visibility.
