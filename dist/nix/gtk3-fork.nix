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
# GTK3 loads im-wayland.so via absolute paths from immodules.cache. The
# tarball ships a cache with baked /usr/lib paths; the installPhase rewrites
# the prefix to $out with sed (pure text, no execution).
stdenv.mkDerivation rec {
  pname = "gtk3-fork";
  version = "0.0.0-unset";

  src = fetchurl {
    url = "https://github.com/WantenMN/gtk/releases/download/fork-linux-x86_64/gtk3-linux-x86_64.tar.gz";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  # Tarball has multiple top-level entries (bin/ lib/ share/); unpack in place.
  sourceRoot = ".";

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

    cache="lib/gtk-3.0/3.0.0/immodules.cache"
    test -f "$cache"
    mkdir -p "$out/lib/gtk-3.0/3.0.0"
    sed "s|/usr/lib|$out/lib|g" "$cache" > "$out/lib/gtk-3.0/3.0.0/immodules.cache"
    grep -q "$out/lib" "$out/lib/gtk-3.0/3.0.0/immodules.cache"

    runHook postInstall
  '';

  meta = {
    description = "GTK 3.24.52 fork (prebuilt tarball)";
    homepage = "https://github.com/WantenMN/gtk";
    license = lib.licenses.lgpl21Plus;
    platforms = [ "x86_64-linux" ];
  };
}
