{
  description = "Tectonic LaTeX environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hunspellWithDicts = pkgs.hunspell.withDicts (d: [ d.en_US ]);
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.tectonic
          hunspellWithDicts
        ];
      };

      formatter.${system} = pkgs.writeShellScriptBin "fmt" ''
        echo "Formatting Nix files..."
        find . -name "*.nix" -not -path "*/.*" | while read -r f; do
          ${pkgs.nixfmt-rfc-style}/bin/nixfmt "$f"
        done

        echo "Formatting TeX files..."
        find . -name "*.tex" -not -path "*/.*" | while read -r f; do
          echo "Formatting $f..."
          ${pkgs.tex-fmt}/bin/tex-fmt "$f"
        done
      '';

      checks.${system} = {
        spellcheck =
          pkgs.runCommand "spellcheck"
            {
              buildInputs = [
                hunspellWithDicts
                pkgs.texlivePackages.detex
              ];
              src = ./.;
            }
            ''
              echo "Running spellcheck..."
              cp -r $src/. .
              chmod -R +w .
              touch .failed
              find . -name "*.tex" -not -path "*/.*" | while read -r f; do
                echo "Processing $f..."
              # Redirect stderr (2>/dev/null) to hide the kpathsea configuration warnings
              typos=$(
                grep -v '\\define' "$f" \
                | sed 's/\\[a-zA-Z]*{[a-z][a-z]*}//g' \
                | sed 's/[{}]/ /g' \
                | sed '/\\usepackage/d; /\\RequirePackage/d; /\\documentclass/d; /\\input/d; /\\include/d' \
                | detex 2>/dev/null \
                | sed 's/\([a-z]\)\([A-Z][a-z]\)/\1 \2/g' \
                | sed 's/[^ ]*[0-9][^ ]*//g' \
                | hunspell -l -p ./.spelling.pws -d en_US
              )
              if [ -n "$typos" ]; then
                echo "❌ Spelling errors in $f:"
                echo "$typos" | sort -u | sed 's/^/  - /'
                echo "fail" > .failed
              fi
              done
              if [ -s .failed ]; then
                echo "Spellcheck failed due to typos."
                exit 1
              fi
              touch $out
            '';

        nixfmt =
          pkgs.runCommand "nixfmt"
            {
              buildInputs = [ pkgs.nixfmt-rfc-style ];
              src = ./.;
            }
            ''
              echo "Checking Nix formatting..."
              cp -r $src/. .
              chmod -R +w .
              touch .failed
              find . -name "*.nix" -not -path "*/.*" | while read -r f; do
                echo "Checking $f..."
                if ! nixfmt --check "$f" 2>&1; then
                  echo "❌ $f is not formatted, run 'nix fmt' to fix"
                  echo "fail" > .failed
                fi
              done
              if [ -s .failed ]; then
                echo "Nix formatting check failed."
                exit 1
              fi
              touch $out
            '';

        texfmt =
          pkgs.runCommand "texfmt"
            {
              buildInputs = [ pkgs.tex-fmt ];
              src = ./.;
            }
            ''
              echo "Checking formatting..."
              cp -r $src/. .
              chmod -R +w .
              touch .failed
              find . -name "*.tex" -not -path "*/.*" | while read -r f; do
                echo "Checking $f..."
                if ! tex-fmt --check "$f" 2>&1; then
                  echo "❌ $f is not formatted, run 'fmt' to fix"
                  echo "fail" > .failed
                fi
              done
              if [ -s .failed ]; then
                echo "Formatting check failed."
                exit 1
              fi
              touch $out
            '';
      };
    };
}
