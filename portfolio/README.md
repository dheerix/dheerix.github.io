# Portfolio

## Working records

- [Engineering-depth alignment](engineering-depth-alignment.md)

Minimal, story-driven portfolio site for public engineering positioning.

## Purpose

The portfolio should render stories from `../stories/` rather than duplicating them.

## Current Scope

- Home and navigation
- Project listing
- Markdown-based story rendering
- Guardlane story page
- AI Upload story page

## Local Preview

Serve the repository root or the `portfolio/` directory with a static server, then open `portfolio/index.html`.

Example:

```bash
python3 -m http.server 8000
```

## Source of Truth

- Story content lives in `../stories/`
- The portfolio is a presentation layer over the story library
