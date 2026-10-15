#!/usr/bin/env bash
# Build GTK4 inside archlinux:base-devel (invoked via `docker run` from
# .github/workflows/fork-tarball.yml).
#
# Why a container: gtk 4.22 needs glib >= 2.84 and pango >= 1.56, newer than
# ubuntu-24.04's frozen set (glib 2.80 / pango 1.52); Arch rolling has them.
# The tarball only carries gtk's own files (bin/ lib/ share/); all dev libs
# stay in the container. glibc note: binaries link the container's glibc,
# but autoPatchelf rewrites them to nixpkgs glibc on consumption; the CI
# verify step additionally fails if the lib needs GLIBC symbols newer than
# what nixpkgs provides.
#
# Env in: SRC_DIR (mounted repo root), ROLL_VERSION, TARBALL name.
set -euo pipefail

pacman -Syu --noconfirm
pacman -S --noconfirm --needed \
  base-devel meson ninja pkgconf sassc git cmake \
  glib2 glib2-devel cairo pango gdk-pixbuf2 graphene libepoxy \
  wayland wayland-protocols libxkbcommon cups vulkan-headers \
  fribidi harfbuzz \
  libjpeg-turbo libpng libtiff libdrm vulkan-icd-loader shaderc \
  libx11 libxi libxrandr libxcursor libxext libxfixes libxdamage \
  libxcomposite libxinerama libice libsm \
  gobject-introspection

cd "$SRC_DIR"
rm -rf _build stage
meson setup _build --prefix=/usr --libdir=lib \
  -Ddocumentation=false \
  -Dbuild-tests=false \
  -Dbuild-examples=false \
  -Dbuild-demos=false \
  -Dmedia-gstreamer=disabled \
  -Dintrospection=disabled
meson compile -C _build -j"$(nproc)"
DESTDIR="$SRC_DIR/stage" meson install -C _build
printf 'version=%s\ncommit=%s\nbuilder=archlinux:base-devel\n' \
  "$ROLL_VERSION" "${GITHUB_SHA:-unknown}" > stage/usr/BUILD-INFO.txt
tar -czf "$TARBALL" -C stage/usr .
ls -lh "$TARBALL"
