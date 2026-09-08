## Documentation — Compass

Project documentation follows **Compass** (Common Ontological Model for Prose
Artifacts by Structural Standard). Use the `compass-*` skills rather than
improvising documents:

- `compass-author` — scaffold a new document (Survey/Eval/Plan/Log/Ref/Guide/
  Spec/Arch/Glossary) with correct front-matter and per-genre section shape.
- `compass-review` — judgment-level conformance review before accepting a doc.
- `compass-lookup` — resolve identifiers, decisions, and cross-references.

The skills carry the standard and its reference bundle. Load @Compass.md on
demand only if you need the source text — do not preload it.

Project-specific facts the skills cannot infer:

- Compass namespace: SEED
- Docs directory: doc/                       <!-- flat; grouping via front-matter -->
- Federation index (if any): none yet

Essentials (full rules in Compass.md): every document opens with a §7 YAML
front-matter block; genre and status use the controlled vocabularies; decision
records are ADR-shaped (`D`-records); code references in Log/Plan are
commit-pinned (`path:symbol@revision`), never bare line numbers; documents
authored with LLM help carry `provenance:`.
