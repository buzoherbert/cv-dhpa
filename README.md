# Daniel Heriberto Palencia's CV repository

This is where I keep an upated version of my CV with [LaTeX](https://en.wikipedia.org/wiki/LaTeX).

# Development

This repository is setup to use [Nix flake](https://wiki.nixos.org/wiki/Flakes). Nix handles the installation of depenndencies to make sure builds are reproducible and maintainable.

To create the PDF for my CV:
* Install Nix with the [installation script](https://nixos.org/download/)
* Run `nix develop` - This should make all the tools you need available.
