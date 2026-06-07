{
  description = "Haskell TDD exercise environment";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs =
    { nixpkgs, ... }:
    let
      systems = nixpkgs.lib.platforms.unix;
      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = { };
              overlays = [ ];
            }
          )
        );
    in
    {
      devShells = eachSystem (
        pkgs:
        let
          devShell =
            allFeatures:
            pkgs.mkShell {
              buildInputs =
                with pkgs.haskell.packages.ghc967;
                (
                  [
                    # GHC pre-bundled with the test deps. These come from
                    # cache.nixos.org as pre-compiled binaries, so the student
                    # never waits for tasty et al. to build.
                    (ghcWithPackages (
                      ps: with ps; [
                        tasty
                        tasty-hunit
                        tasty-quickcheck
                        QuickCheck
                      ]
                    ))
                    haskell-language-server
                  ]
                  ++ (pkgs.lib.optionals allFeatures [
                    hlint
                    ghcid
                    ormolu
                    hoogle
                  ])
                );
            };
          full = devShell true;
          minimal = devShell false;
        in
        {
          inherit full minimal;
          default = full;
        }
      );
    };
}
