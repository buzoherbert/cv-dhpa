{
  description = "Tectonic LaTeX environment";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: 
    let
      # Set this once to match your machine
      system = "x86_64-linux"; 
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.tectonic ];
      };
    };
}