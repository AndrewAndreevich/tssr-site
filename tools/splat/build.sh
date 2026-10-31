#!/usr/bin/env bash
# Rebuilds assets/splats/rustaveli.sog (the scan on the last slide) from the Brush/gsplat PLY.
#   tools/splat/build.sh [splat.ply]      KEEP=2500000 tools/splat/build.sh ...
# Needs Node 18+; splat-transform is fetched by npx at the pinned version.
set -euo pipefail
SRC="${1:-F:/BASE/SCANS/SCA-102_RUSTAVELI_WIDE_SITE/SPLAT/EXPORT_brush_15k/rustaveli_splat_brush_15k.ply}"
KEEP="${KEEP:-3000000}"                 # splats left after decimation (3M ≈ 38 MB)
ST="npx -y @playcanvas/splat-transform@3.10.3"
OUT="$(cd "$(dirname "$0")/../.." && pwd)/assets/splats/rustaveli.sog"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# -N: drop NaN splats  -H 0: colour only, no view-dependent SH bands
# -V: drop near-invisible splats  --decimate-adaptive: merge the rest down to KEEP, finest where it matters
$ST -q -w "$SRC" -N -H 0 -V opacity,gt,0.005 --decimate-adaptive "$KEEP" "$TMP/pruned.ply"
# -m: Morton order (better compression and streaming locality), then SOG
$ST -q -w "$TMP/pruned.ply" -m "$OUT"
ls -l "$OUT"
