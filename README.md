# Daniel Heriberto Palencia Arreola's CV repository

This is where I keep an updated version of my CV with [LaTeX](https://en.wikipedia.org/wiki/LaTeX).

# Development

This repository is set up to use a [Nix flake](https://wiki.nixos.org/wiki/Flakes). Nix handles the installation of dependencies to make sure builds are reproducible and maintainable.

## Prerequisites

Install Nix using the [official installation script](https://nixos.org/download/).

## Building the CV

```sh
nix develop                  # Enter the dev shell with all tools available
tectonic -X build            # Build the PDFnumb
tectonic -X watch            # Rebuild automatically on file changes
```

The built PDF is output to `build/Daniel_Palencia_CV/Daniel_Palencia_CV.pdf`. A copy is committed to `docs/Daniel_Palencia_CV.pdf` — keep these in sync by copying the built PDF into the `docs` folder after changes.

## Formatting

A formatter is included for both Nix and TeX files:

```sh
nix fmt
```

This runs `nixfmt` on `.nix` files and `tex-fmt` on `.tex` files.

## Checks

The following checks can be run locally with:

```sh
nix flake check
```

| Check | Tool | What it does |
|-------|------|--------------|
| `spellcheck` | `hunspell` | Spell-checks all `.tex` files against `hunspell` and a custom word list (`.spelling.pws`) |
| `nixfmt` | `nixfmt-rfc-style` | Verifies all `.nix` files are formatted |
| `texfmt` | `tex-fmt` | Verifies all `.tex` files are formatted |

To add words to the spell-check allowlist, add them to `.spelling.pws`.

## Continous Integration

GitHub Actions runs on every push to `master` and on pull requests. The pipeline:

1. Runs `nix flake check` (spellcheck, formatting).
2. Builds the CV with `tectonic -X build`.
3. Verifies the built PDF matches the committed `docs/Daniel_Palencia_CV.pdf` via SHA-256 comparison — if they differ, commit the updated PDF before merging. This is meant to catch unintentional changes to the generated PDF files and to make releasing a new version of the document an intentional action.