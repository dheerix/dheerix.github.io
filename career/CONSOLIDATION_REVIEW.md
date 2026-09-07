# Career Consolidation Review

The legacy repository contained many parallel career surfaces. This migration now distinguishes **valuable content** from **true placeholders**.

## Preserved and moved

- `coverletters/` → `career/communication/cover-letters/`
- `interviews/` → `career/interviews/library/`
- substantive LinkedIn material → `career/profile/linkedin/`
- `master-profile/` → `career/profile/master/`
- `master-resume/` → `career/resume/master-source/`
- `resumes/` → `career/resume/variants/`
- substantive Openlane stories → `career/stories/openlane/`

The migration preserves the original Git blobs/subtrees rather than regenerating the content.

## Removed as redundant scaffolding

- `career-assets/` — mostly tiny placeholder files pointing at concepts represented elsewhere
- `experience-bank/` — empty `.gitkeep` category scaffold
- `story-bank/` — empty `.gitkeep` category scaffold
- `promotion/` — placeholder-only files; the substantive SDE3 roadmap already lives under `career/`
- `leadership/` — placeholder README only
- tiny duplicate placeholder files in old roots are not promoted as canonical artifacts

## Rule going forward

Do not rebuild the deleted folder taxonomy inside `career/`. First improve and deduplicate the preserved material, then choose canonical artifacts. Deletion should follow content review, not precede it.
