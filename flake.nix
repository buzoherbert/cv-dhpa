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
        export PATH="${pkgs.nixfmt-rfc-style}/bin:${pkgs.tex-fmt}/bin:$PATH"
        ${pkgs.bash}/bin/bash ${./scripts/fmt.sh}
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
              ${pkgs.bash}/bin/bash ${./scripts/spellcheck.sh} "$src"
            '';

        nixfmt =
          pkgs.runCommand "nixfmt"
            {
              buildInputs = [ pkgs.nixfmt-rfc-style ];
              src = ./.;
            }
            ''
              ${pkgs.bash}/bin/bash ${./scripts/nixfmt-check.sh} "$src"
            '';

        texfmt =
          pkgs.runCommand "texfmt"
            {
              buildInputs = [ pkgs.tex-fmt ];
              src = ./.;
            }
            ''
              ${pkgs.bash}/bin/bash ${./scripts/texfmt-check.sh} "$src"
            '';

        shfmt =
          pkgs.runCommand "shfmt"
            {
              buildInputs = [ pkgs.shfmt ];
              src = ./.;
            }
            ''
              ${pkgs.bash}/bin/bash ${./scripts/shfmt-check.sh} "$src"
            '';
      };
    };
}
