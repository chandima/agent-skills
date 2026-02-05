# __TITLE__

Scaffolded H5P editor widget library: __MACHINE__ v__VERSION__.

## Editor widget essentials
- Entry: `src/scripts/h5peditor-__SLUG__.js` implements editor lifecycle methods like `appendTo`, `validate`, and `remove`.
- Styles: `src/styles/h5peditor-__SLUG__.scss` (built into `dist/`).
- Metadata: `library.json` declares the editor library and preloaded assets (`runnable: 0`).

## Build

```bash
npm install
npm run build
```

## Local dev (h5p-cli)

```bash
h5p core
h5p setup <library>
h5p server
```

The widget is available in the H5P editor when installed and referenced by a content type.

## Packaging

```bash
h5p pack <library> [<library2>...] [my.h5p]
```

## References
- https://h5p.org/creating-editor-widgets
- https://h5p.org/technical-overview
- https://github.com/h5p/h5p-cli
- https://h5p.org/h5p-cli-guide
