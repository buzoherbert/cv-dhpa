{
  description = "Tectonic LaTeX environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
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

      checks.${system} = {
        spellcheck = pkgs.runCommand "spellcheck" {
          # Adding detex to buildInputs if you keep using the detex approach
          buildInputs = [ hunspellWithDicts pkgs.texlivePackages.detex ];
          src = ./.; 
        } ''
          echo "Running spellcheck..."
          cp -r $src/. .
          chmod -R +w .
          touch .failed
          find . -name "*.tex" -not -path "*/.*" | while read -r f; do
            echo "Processing $f..."
            # Redirect stderr (2>/dev/null) to hide the kpathsea configuration warnings
            typos=$(detex "$f" 2>/dev/null | hunspell -l -p ./.spelling.pws -d en_US)
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
      };
    };
}