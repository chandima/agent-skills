# H5P CLI Quick Reference

The official H5P CLI provides a full development workflow: install core libs, set up dependencies, run a local editor server, validate, and pack `.h5p` files.

## Installation

- npm: `npm install -g h5p-cli`
- Then use the `h5p` command.

## Core Workflow

1. Install core libraries: `h5p core`
2. Set up a library and its dependencies: `h5p setup <library|repoUrl> [version] [download]`
3. Run local editor server: `h5p server`
4. Pack a library to `.h5p`: `h5p utils pack <library>`

## Useful Commands

- List available libraries: `h5p list`
- Verify dependency setup: `h5p verify <h5p-repo-name>`
- Import/export content: `h5p import <folder> <h5p_file>` / `h5p export <library> <folder>`
- Help: `h5p help` or `h5p utils help`

## References
- H5P CLI repo: https://github.com/h5p/h5p-cli
- CLI quick start: https://github.com/h5p/h5p-cli#quick-start-guide
- CLI commands: https://github.com/h5p/h5p-cli/blob/master/assets/docs/commands.md
