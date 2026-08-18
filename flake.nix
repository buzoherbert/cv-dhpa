{
  description = "Tectonic LaTeX environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      hunspellWithDicts = pkgs.hunspell.withDicts (d: [
        d.en_US
        d.es_ES
      ]);
      runBuild = "${pkgs.bash}/bin/bash ${./scripts/build.sh}";
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [
          pkgs.tectonic
          hunspellWithDicts
        ];
      };

      apps.${system} = {
        build = {
          type = "app";
          program = "${pkgs.writeShellScript "build" ''
            export PATH="${pkgs.tectonic}/bin:$PATH"
            ${runBuild} "$@"
          ''}";
        };

        watch = {
          type = "app";
          program = "${pkgs.writeShellScript "watch" ''
            export PATH="${pkgs.tectonic}/bin:${pkgs.inotify-tools}/bin:$PATH"
            build() { ${runBuild}; }
            build
            while true; do
              inotifywait -qq -r -e modify,create,delete src/ Tectonic.toml 2>/dev/null || sleep 2
              clear
              echo "Change detected, rebuilding..."
              build
            done
          ''}";
        };

        pdf-check = {
          type = "app";
          program = "${pkgs.writeShellScript "pdf-check" ''
            export PATH="${pkgs.tectonic}/bin:${pkgs.poppler-utils}/bin:${pkgs.imagemagick}/bin:${pkgs.coreutils}/bin:${pkgs.gawk}/bin:$PATH"
            export RUN_BUILD="${runBuild}"
            ${pkgs.bash}/bin/bash ${./scripts/pdf-check.sh} .
          ''}";
        };
      };

      formatter.${system} = pkgs.writeShellScriptBin "fmt" ''
        export PATH="${pkgs.nixfmt}/bin:${pkgs.tex-fmt}/bin:${pkgs.shfmt}/bin:$PATH"
        ${pkgs.bash}/bin/bash ${./scripts/fmt.sh}
      '';

      checks.${system} = {
        spellcheck =
          pkgs.runCommand "spellcheck"
            {
              buildInputs = [
                hunspellWithDicts
                pkgs.glibcLocales
              ];
              LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
              LANG = "en_US.UTF-8";
              LC_ALL = "en_US.UTF-8";
              src = ./.;
            }
            ''
              ${pkgs.bash}/bin/bash ${./scripts/spellcheck.sh} "$src"
            '';

        nixfmt =
          pkgs.runCommand "nixfmt"
            {
              buildInputs = [ pkgs.nixfmt ];
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
