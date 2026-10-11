{
  description = "GTK3 fork: nixpkgs gtk3 recipe built from this tree + dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      # Fork package: nixpkgs gtk3 recipe (3.24.52, same as this tree),
      # source replaced with the flake tree. Built and pushed to Cachix by CI.
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          gtk3-fork = pkgs.gtk3.overrideAttrs (old: {
            version = "3.24.52";
            src = self;
          });
        in
        {
          inherit gtk3-fork;
          default = gtk3-fork;
        });

      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            # Inherit exact deps from the nixpkgs gtk3 recipe.
            inputsFrom = [ pkgs.gtk3 ];

            packages = with pkgs; [
              ccache
              gdb
              clang-tools
              valgrind
              direnv
            ];

            shellHook = ''
              export CCACHE_DIR="''${CCACHE_DIR:-$HOME/.cache/ccache-gtk3}"
              mkdir -p "$CCACHE_DIR"

              if [ -z "''${IN_NIX_GTK_SHELL_NOTICE:-}" ]; then
                export IN_NIX_GTK_SHELL_NOTICE=1
                echo "GTK3 fork shell (nix develop, no nix-store rebuild)."
                echo "Keep _build/ on a writable FS; do not use --wipe on re-entry."
              fi
            '';
          };
        });
    };
}
