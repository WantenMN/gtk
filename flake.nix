{
  description = "GTK4 incremental dev shell (live checkout + meson/ninja, not nix build)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      # Fork package: nixpkgs gtk4 recipe, source replaced with this tree
      # (i.e. 4.22.4 + local fixes). Built and pushed to Cachix by CI.
      packages = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
          gtk4-fork = pkgs.gtk4.overrideAttrs (old: {
            version = "4.22.4";
            src = self;
          });
        in
        {
          inherit gtk4-fork;
          default = gtk4-fork;
        });

      devShells = forEachSystem (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            # Inherit exact deps from pkgs/by-name/gt/gtk4/package.nix:
            # meson/ninja/pkg-config/sassc/glslc/wayland-scanner,
            # glib/cairo/pango/gdk-pixbuf/graphene/epoxy/wayland/...
            inputsFrom = [ pkgs.gtk4 ];

            # Dev-only extras, not needed for packaging.
            packages = with pkgs; [
              ccache
              gdb
              clang-tools
              valgrind
              direnv
            ];

            shellHook = ''
              # Keep ccache outside /nix/store so it survives shell restarts.
              export CCACHE_DIR="''${CCACHE_DIR:-$HOME/.cache/ccache-gtk4}"
              mkdir -p "$CCACHE_DIR"

              if [ -z "''${IN_NIX_GTK_SHELL_NOTICE:-}" ]; then
                export IN_NIX_GTK_SHELL_NOTICE=1
                echo "GTK incremental shell (nix develop, no nix-store rebuild)."
                echo "  meson setup _build --prefix=\$PWD/_prefix -Ddocumentation=false -Dbuild-tests=true"
                echo "  meson compile -C _build        # incremental (ninja)"
                echo "  meson devenv -C _build <cmd>   # run without install"
                echo "Keep _build/ on a writable FS; do not use --wipe on re-entry."
              fi
            '';
          };
        });
    };
}
