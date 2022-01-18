let
  f =
    build-or-shell:
    { chan ? "5272327b81ed355bbed5659b8d303cf2979b6953"
    , compiler ? "ghc865"
    , withHoogle ? false
    , doHoogle ? false
    , doHaddock ? false
    , enableLibraryProfiling ? false
    , enableExecutableProfiling ? false
    , strictDeps ? false
    , isJS ? false
    , system ? builtins.currentSystem
    , optimize ? true
    , dev ? true
    }:

    let

      shpadoinkle = builtins.fetchGit {
        url    = https://gitlab.com/platonic/shpadoinkle.git;
        ref    = "master";
        rev    = "a107da66dca476ed5b5ee68981bc235d46107574";
      };


      inherit (import (shpadoinkle + "/nix/util.nix") { inherit compiler isJS pkgs; }) compilerjs doCannibalize gitignore;


      chill = p: (pkgs.haskell.lib.overrideCabal p {
        inherit enableLibraryProfiling enableExecutableProfiling;
      }).overrideAttrs (_: {
        inherit doHoogle doHaddock strictDeps;
      });


      shpadoinkle-overlay =
        import (shpadoinkle + "/nix/overlay.nix")
               { inherit compiler chan isJS enableLibraryProfiling enableExecutableProfiling; };


      haskell-overlay = lib: hself: hsuper:
        {
          "servant-auth-server" = lib.dontCheck hsuper.servant-auth-server;
        };


      proj-overlay = self: super: {
        haskell = super.haskell //
          { packages = super.haskell.packages //
            { ${compilerjs} = super.haskell.packages.${compilerjs}.override (old: {
                overrides = super.lib.composeExtensions (old.overrides or (_: _: {})) (haskell-overlay super.haskell.lib);
              });
            };
          };
        };


      pkgs = import
        (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/${chan}.tar.gz";
        }) {
        inherit system;
        overlays = [
          shpadoinkle-overlay
          proj-overlay
        ];
      };


      ghcTools = with pkgs.haskell.packages.${compiler};
        [ cabal-install
          ghcid
        ];


      proj = pkgs.haskell.lib.dontCheck
        ((pkgs.haskell.packages.${compilerjs}.callCabal2nix "proj" (gitignore [
          "*.md"
          "*.yaml"
          "*.nix"
          "*.sh"
        ] ../.) {}));


    in with pkgs; with lib;

      { build =
          (if isJS && optimize then doCannibalize else x: x) (chill proj);

        shell =
          pkgs.haskell.packages.${compilerjs}.shellFor {
            inherit withHoogle;
            packages    = _: [ proj ];
            COMPILER    = compilerjs;
            buildInputs = ghcTools;
          };
      }.${build-or-shell};
in
  { build = f "build";
    shell = f "shell";
  }
