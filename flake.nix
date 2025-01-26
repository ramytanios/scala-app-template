{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
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
      appVersion = "0.0.2";
    in
    {
      packages = forEachSystem (
        system:

        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          devenv-up = self.devShells.${system}.default.config.procfileScript;
          devenv-test = self.devShells.${system}.default.config.test;

          dummy-app = pkgs.stdenv.mkDerivation {
            pname = "dummy-app";
            version = appVersion;
            src = pkgs.fetchUrl {
              url = "https://github.com/ramytanios/scala-cli-app-template/releases/download/v${appVersion}/dummy-app-linux.zip";
              hash = "";
            };
          };
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
                  compile-watch.exec = ''
                    sbt '~compile'
                  '';
                  update-workflow.exec = ''
                    sbt githubWorkflowGenerate
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
