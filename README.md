# Daniel Heriberto Palencia Arreola's CV repository

This is where I keep an updated version of my CV and Resume with [LaTeX](https://en.wikipedia.org/wiki/LaTeX).

You can see and download [my CV here](https://github.com/buzoherbert/cv-dhpa/blob/master/docs/Daniel_Palencia_CV.pdf) and [my Resume here](https://github.com/buzoherbert/cv-dhpa/blob/master/docs/Daniel_Palencia_Resume.pdf).

# Development

This repository is set up to use a [Nix flake](https://wiki.nixos.org/wiki/Flakes). Nix handles the installation of dependencies to make sure builds are reproducible and maintainable.

## Prerequisites

Install Nix using the [official installation script](https://nixos.org/download/).

## Building the CV and Resume

Use the built-in Nix apps to build or watch the PDFs:

```sh
nix run .#build              # Build all PDFs defined in Tectonic.toml
nix run .#watch              # Rebuild automatically on file changes
```

They replace the direct invocation of `tectonic -X build` and `tectonic -X watch` since there was an inconsistency with the way Tectonic builds outputs synchronously, making builds not reproducible.
The `nix` commands above build the output PDF files asynchronously to make builds reproducible.

Alternatively, you can enter the development shell directly with all tools available:

```sh
nix develop
```

The built PDFs are output to `build/<target>/<target>.pdf`. Copies are committed to the `docs/` folder — keep these in sync by committing the updated PDFs after changes. The commited copies are the ones available for download in this repository.

## Formatting

A formatter is included for shell, Nix and TeX files:

```sh
nix fmt
```

This runs `shfmt` on `.sh` files, `nixfmt` on `.nix` files and `tex-fmt` on `.tex` files.

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
| `shfmt` | `shfmt` | Verifies all `.sh` files are formatted |

To add words to the spell-check allowlist, add them to `.spelling.pws`.

You can also run a visual PDF verification locally:

```sh
nix run .#pdf-check
```
This task makes sure that the PDF files built with the code in the repository are exaclty the same ones as the ones commited in the `/docs/` folder.

## Continuous Integration

GitHub Actions runs on every push to `master` and on pull requests. The pipeline:

1. Runs `nix flake check` (spellcheck, formatting).
2. Runs `nix run .#pdf-check` to build the targets and verify the built PDFs match the committed PDFs in `docs/` via visual comparison using `pdftoppm`.
3. If the PDFs differ visually or in page count, the pipeline fails — you must commit the updated PDFs before merging. This is meant to catch unintentional changes to the generated PDF files and to make releasing a new version of the document an intentional action.