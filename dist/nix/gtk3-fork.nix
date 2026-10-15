{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, glib
, cairo
, pango
, gdk-pixbuf
, at-spi2-core
, fribidi
, libxkbcommon
, libepoxy
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXfixes
, libXi
, libXrandr
, libXrender
, libXinerama
, libICE
, libSM
, wayland
, cups
, tinysparql
, gsettings-desktop-schemas
}:

# GTK 3.24.52 fork (traditional tarball from GitHub Release).
# Generated + verified by CI (.github/workflows/fork-tarball.yml on branch
# gtk-3.24.52-fork): version/url/hash are filled in by CI on every push and
# uploaded as release asset `gtk3-fork.nix`. This file in dotfiles is a copy
# fetched by pkgs/update-fork-tarballs.sh — do not edit hash by hand.
#
# GTK3 loads im-wayland.so via absolute paths from immodules.cache, so the
# cache is regenerated in postFixup (after patchelf, when the just-installed
# gtk-query-immodules-3.0 can run). Never ship the /usr-path cache from the
# tarball.
stdenv.mkDerivation rec {
  pname = "gtk3-fork";
  version = "0.0.0-unset";

  src = fetchurl {
    url = "https://github.com/WantenMN/gtk/releases/download/fork-linux-x86_64/gtk3-linux-x86_64.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    glib
    cairo
    pango
    gdk-pixbuf
    at-spi2-core
    fribidi
    libxkbcommon
    libepoxy
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXfixes
    libXi
    libXrandr
    libXrender
    libXinerama
    libICE
    libSM
    wayland
    cups
    tinysparql
    gsettings-desktop-schemas
    stdenv.cc.cc.lib
  ];

  # Tarball top level is bin/ lib/ share/ (contents of stage/usr).
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    for d in bin lib share; do
      [ -e "$d" ] && cp -r "$d" "$out/"
    done

    # Drop the shipped cache (absolute /usr paths); regenerated below.
    rm -f $out/lib/gtk-3.0/3.0.0/immodules.cache \
      $out/lib/x86_64-linux-gnu/gtk-3.0/3.0.0/immodules.cache

    runHook postInstall
  '';

  # Runs after autoPatchelf: the query tool is now nix-linked and executable
  # inside the sandbox. Mirrors nixpkgs gtk3 postInstall.
  postFixup = ''
    if [ -x "$out/bin/gtk-query-immodules-3.0" ]; then
      echo "regenerating gtk3 immodules.cache"
      GTK_PATH="$out/lib/gtk-3.0/3.0.0" \
        "$out/bin/gtk-query-immodules-3.0" > "$out/lib/gtk-3.0/3.0.0/immodules.cache"
    fi
  '';

  meta = {
    description = "GTK 3.24.52 fork (prebuilt tarball)";
    homepage = "https://github.com/WantenMN/gtk";
    license = lib.licenses.lgpl21Plus;
    platforms = [ "x86_64-linux" ];
  };
}
