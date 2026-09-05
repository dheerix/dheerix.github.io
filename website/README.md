# Dheerix Knowledge Website

Static, searchable presentation layer for the Markdown documents in this repository.

## Local preview

```bash
node website/generate-site.mjs
python3 -m http.server 8000 --directory website/dist
```

Open `http://localhost:8000` for the original portfolio home page and
`http://localhost:8000/learn/` for the knowledge library. GitHub Actions
regenerates the ignored `website/dist` directory from current Markdown on every deployment.
