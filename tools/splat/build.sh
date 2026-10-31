#!/usr/bin/env bash
# Rebuilds assets/splats/rustaveli.sog (the scan on the last slide) from the gsplat PLY.
#   tools/splat/build.sh [point_cloud_N.ply]      KEEP=2500000 tools/splat/build.sh ...
# Needs Node 18+; splat-transform is fetched by npx at the pinned version.
set -euo pipefail
SRC="${1:-F:/BASE/SCANS/SCA-102_RUSTAVELI_WIDE_SITE/SPLAT/gsplat_full/ply/point_cloud_6999.ply}"
KEEP="${KEEP:-2000000}"                 # splats left after decimation (2M ≈ 23 MB)
ST="npx -y @playcanvas/splat-transform@3.10.3"
OUT="$(cd "$(dirname "$0")/../.." && pwd)/assets/splats/rustaveli.sog"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# -N: drop NaN splats  -H 0: colour only, no view-dependent SH bands
# -S: drop the few stray splats millions of units out (keeps hills and sky, radius 1000)
# -V: drop near-invisible splats  --decimate-adaptive: merge the rest down to KEEP, finest where it matters
$ST -q -w "$SRC" -N -H 0 -S 0,0,0,1000 -V opacity,gt,0.005 --decimate-adaptive "$KEEP" "$TMP/pruned.ply"
# -m: Morton order (better compression and streaming locality), then SOG
$ST -q -w "$TMP/pruned.ply" -m "$OUT"
ls -l "$OUT"
