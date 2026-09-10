# Portfolio

## Working records

- [Engineering-depth alignment](engineering-depth-alignment.md)

Minimal, story-driven portfolio site for public engineering positioning.

## Purpose

The portfolio should render stories from `../stories/` rather than duplicating them.

## Current Scope

- Home and navigation
- Project listing
- Featured Guardlane summary
- Dedicated Guardlane and PlanForge engineering case studies under
  `dheerix/projects/`
- Compact selected-work summaries

## Local Preview

Serve the repository root or the `portfolio/` directory with a static server, then open `portfolio/index.html`.

Example:

```bash
python3 -m http.server 8000
```

## Source of Truth

- Engineering evidence remains in `../projects/`, `../engineering/`, and
  `../evidence/`.
- The portfolio is a presentation layer over those records; it should summarize
  verified, public-safe claims instead of duplicating source documents.
- Employer-derived details must be generalized before publication.
