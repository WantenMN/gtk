{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, glib
, cairo
, pango
, gdk-pixbuf
, graphene
, libepoxy
, wayland
, vulkan-loader
, gsettings-desktop-schemas
, libxkbcommon
, libpng
, libtiff
, libjpeg_turbo
, libdrm
, fribidi
, harfbuzz
, cups
, libGL
, libX11
, libXi
, libXrandr
, libXrender
, libXcursor
, libXdamage
, libXfixes
, libXcomposite
, libXinerama
, libICE
, libSM
, gst_all_1
, tinysparql
}:

# GTK 4.22.4 fork (traditional tarball from GitHub Release).
# Generated + verified by CI (.github/workflows/fork-tarball.yml on branch
# gtk-4.22.4-fork): version/url/hash are filled in by CI on every push and
# uploaded as release asset `gtk4-fork.nix`. This file in dotfiles is a copy
# fetched by pkgs/update-fork-tarballs.sh — do not edit hash by hand.
stdenv.mkDerivation rec {
  pname = "gtk4-fork";
  version = "0.0.0-unset";

  src = fetchurl {
    url = "https://github.com/WantenMN/gtk/releases/download/fork-linux-x86_64/gtk4-linux-x86_64.tar.gz";
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
    graphene
    libepoxy
    wayland
    vulkan-loader
    gsettings-desktop-schemas
    libxkbcommon
    libpng
    libtiff
    libjpeg_turbo
    libdrm
    fribidi
    harfbuzz
    cups
    libGL
    libX11
    libXi
    libXrandr
    libXrender
    libXcursor
    libXdamage
    libXfixes
    libXcomposite
    libXinerama
    libICE
    libSM
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    tinysparql
    stdenv.cc.cc.lib
  ];

  # Tarball top level is bin/ lib/ share/ (contents of stage/usr).
  installPhase = ''
    runHook preInstall

    mkdir -p $out
    for d in bin lib share; do
      [ -e "$d" ] && cp -r "$d" "$out/"
    done

    runHook postInstall
  '';

  meta = {
    description = "GTK 4.22.4 fork (prebuilt tarball)";
    homepage = "https://github.com/WantenMN/gtk";
    license = lib.licenses.lgpl21Plus;
    platforms = [ "x86_64-linux" ];
  };
}
