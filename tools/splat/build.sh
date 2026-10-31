#!/usr/bin/env bash
# Rebuilds the scan on the last slide from the Brush/gsplat PLY:
#   assets/splats/rustaveli.sog          3M splats (~38 MB), for computers (drawn with level of detail)
#   assets/splats/rustaveli_mobile.sog   1.5M splats (~19 MB), for phones (iOS Safari runs out of memory on the big one)
#   assets/splats/rustaveli_heights.bin  roof-height grid the page keeps its camera above
#   tools/splat/build.sh [splat.ply]      KEEP=4000000 KEEP_MOBILE=2000000 tools/splat/build.sh ...
# Needs Node 18+ (splat-transform is fetched by npx at the pinned version) and Python 3 + numpy.
set -euo pipefail
SRC="${1:-F:/BASE/SCANS/SCA-102_RUSTAVELI_WIDE_SITE/SPLAT/EXPORT_brush_15k/rustaveli_splat_brush_15k.ply}"
KEEP="${KEEP:-3000000}"
KEEP_MOBILE="${KEEP_MOBILE:-1500000}"
ST="npx -y @playcanvas/splat-transform@3.10.3"
DIR="$(cd "$(dirname "$0")/../.." && pwd)/assets/splats"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

build() {   # build <splats to keep> <out.sog>
  # -N: drop NaN splats  -H 0: colour only, no view-dependent SH bands
  # -V: drop near-invisible splats  --decimate-adaptive: merge the rest down, finest where it matters
  $ST -q -w "$SRC" -N -H 0 -V opacity,gt,0.005 --decimate-adaptive "$1" "$TMP/pruned.ply"
  # -m: Morton order (better compression and streaming locality), then SOG
  $ST -q -w "$TMP/pruned.ply" -m "$2"
}

build "$KEEP_MOBILE" "$DIR/rustaveli_mobile.sog"
build "$KEEP" "$DIR/rustaveli.sog"
python "$(dirname "$0")/heights.py" "$TMP/pruned.ply" "$DIR/rustaveli_heights.bin"
ls -l "$DIR"
echo "New files: bump SCAN_VERSION in index.html so visitors drop their cached copy."
