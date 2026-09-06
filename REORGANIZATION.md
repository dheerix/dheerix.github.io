# Repository Reorganization — 2026-09

## Why

The repository accumulated many top-level folders for career preparation, learning, evidence, and presentation. The next phase prioritizes engineering depth, so the taxonomy is being simplified before adding substantial new material.

## Stable top-level model

- `engineering/` — learning, investigation, architectural reasoning
- `evidence/` — demonstrated engineering capability
- `career/` — resumes, interviews, promotion, professional identity, stories
- `projects/` — summaries of substantial independent projects; source code may live elsewhere
- `portfolio/` — curated public presentation
- `resources/` — templates, cheatsheets, research/support material
- `website/` — site implementation

## Migration map

Existing material should be consolidated gradually and deliberately:

| Existing area | Destination |
|---|---|
| `architecture/` | `engineering/architecture/` |
| `grind75/` | `engineering/dsa/grind75/` |
| AI/ML study material currently scattered elsewhere | `engineering/ai/` |
| `career-assets/` | `career/` by artifact type |
| `coverletters/` | `career/communication/cover-letters/` |
| `linkedin/` | `career/profile/linkedin/` |
| `master-profile/` | `career/profile/` |
| `master-resume/`, `resumes/` | `career/resume/` |
| `promotion/` | `career/promotion/` |
| `interviews/` | `career/interviews/` |
| `stories/`, `story-bank/`, `experience-bank/` | `career/stories/` |
| `leadership/` | `career/leadership/` or `evidence/leadership/` depending on content |
| `templates/`, `cheatsheets/`, `research/` | `resources/` |

## Important migration rule

Do not bulk-move files merely to make the tree look clean. Review duplicates and placeholders first, preserve useful history, and update website/build references before deleting old paths.

New material should follow the new taxonomy immediately. Old material can be migrated in controlled cleanup PRs.

## 12-month technical focus

1. Production AI architecture
2. Distributed-systems and architecture depth through real-system studies and ADRs
3. PlanForge as an agentic engineering workflow
4. Production ML depth
5. DSA as interview maintenance

New major technical projects should normally replace or materially advance one of these rather than simply being added.
