# Agent Skills (Custom)

This repository hosts a minimal set of skills for AI coding agents.

## Upstream

This repository is standalone and does not track an upstream source.

## Available Skills

- `h5p-type-scaffold` — scaffold a modern H5P content type (library) from curated boilerplates (default: SNORDIAN).

## Install with `skills`

```bash
npx skills add <owner>/<repo>
```

## H5P Notes

This skill defaults to the SNORDIAN boilerplate for linting and i18n scaffolding, supports the official `h5p/h5p-boilerplate` layout, and can scaffold editor widgets (`H5PEditor.*`). It assumes vanilla JS for maximum compatibility, but you can adapt the output for framework-based boilerplates if needed.

## Testing

Run all skill smoke tests:

```bash
bash scripts/run-skill-tests.sh
```

CI runs the same script on every PR and push to `main` via `.github/workflows/skill-tests.yml`.
