{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      devenv,
      systems,
      ...
    }@inputs:
    let
      forEachSystem = nixpkgs.lib.genAttrs (import systems);

      url = "https://github.com/ramytanios/scala-app-template";
      version = "0.0.2";
      pname = "dummy-app";

      mkApp =
        pkgs:
        with pkgs;
        stdenv.mkDerivation {
          inherit version;
          inherit pname;
          src = fetchzip {
            url = "${url}/releases/download/v${version}/${pname}-linux.zip";
            hash = "sha256-WrTZO1J0H9M5WwdrqYI83A6Y8iPNAjfJ/bH3DrDHP3w=";
          };
          installPhase = ''
            mkdir -p $out/bin
            cp $pname $out/bin
          '';
        };

    in
    {
      overlays.default = final: _: {
        ${pname} = mkApp final;
      };

      packages = forEachSystem (
        system:

        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devenv-up = self.devShells.${system}.default.config.procfileScript;
          devenv-test = self.devShells.${system}.default.config.test;

          ${pname} = mkApp pkgs;
        }
      );

      devShells = forEachSystem (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [
              {
                packages = [ pkgs.hello ];
                languages = {
                  nix.enable = true;
                  java.enable = true;
                  scala.enable = true;
                  scala.sbt.enable = true;
                };
                scripts = {
                  fix.exec = ''
                    sbt 'scalafmtAll;scalafixAll'
                  '';
                  git-clean.exec = ''
                    git clean -Xdf
                  '';
                };

              }
            ];
          };
        }
      );
    };
}
