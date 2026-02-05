# H5P Type Scaffolder

This skill scaffolds a modern H5P content type using proven boilerplates and vanilla JavaScript. It generates the minimal files needed to build, test, and package a new library.

## What it generates

- `library.json` and `semantics.json`
- `src/entries`, `src/scripts`, `src/styles`
- `README.md` (templates)
- `webpack.config.js`, `.babelrc`
- build scripts in `package.json`

## Quick start

```bash
bash /mnt/skills/user/h5p-type-scaffold/scripts/scaffold.sh \
  --title "My Content Type" \
  --machine "H5P.MyContentType" \
  --kind "content" \
  --version "1.0.0" \
  --description "Short description" \
  --author "Your Name" \
  --license "MIT" \
  --template "snordian" \
  --out /path/to/output
```

Editor widget example:

```bash
bash /mnt/skills/user/h5p-type-scaffold/scripts/scaffold.sh \
  --title "My Editor Widget" \
  --machine "H5PEditor.MyWidget" \
  --kind "editor" \
  --out /path/to/output
```

## Build & package

```bash
npm install
npm run build
h5p core
h5p setup <library>
h5p server
h5p pack <library> [my.h5p]
```

## Notes

- Default template is `snordian` (linting + i18n scaffolding).
- Use `vanilla` for the simplest official baseline.
- Use `editor` with `--kind editor` to scaffold H5P editor widgets.
- Other options to consider: `otacke/h5p-editor-boilerplate` (editor widgets) and `tarmoj/h5p-react-boilerplate` (React, but stale).
- See `references/CONCEPTS.md`, `references/CONTENT-TYPE-AUTHORING.md`, and `references/H5P-CLI.md` for deeper guidance.
