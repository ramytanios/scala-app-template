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

      version = "0.0.5"; # reset the hash when you change the version!

      pname = "dummy-app";

      mkApp =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        with pkgs;
        stdenv.mkDerivation {
          inherit version;
          inherit pname;
          buildInputs = [ jdk ];
          src = fetchzip {
            url = "${url}/releases/download/v${version}/${pname}-${system}.zip";
            hash = "sha256-7AYDr2k/NaFA9ByxjgELoTox2kvAX0biMvUyVd44tFc=";
          };
          installPhase = ''
            mkdir -p $out/bin
            cp $pname $out/bin
          '';
        };

    in
    {
      overlays.default = _: prev: {
        ${pname} = mkApp _ prev.system;
      };

      packages = forEachSystem (system: {
        devenv-up = self.devShells.${system}.default.config.procfileScript;
        devenv-test = self.devShells.${system}.default.config.test;

        ${pname} = mkApp system;
      });

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
