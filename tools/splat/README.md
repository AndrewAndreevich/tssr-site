# Rustaveli scan (last slide)

`assets/splats/rustaveli.sog` is the drone survey SCA-103 of Rustaveli Square, Tbilisi (it replaced SCA-102 on 2026-11-01). It was trained with Brush for 15k steps on 417 RealityScan cameras and is shown with Spark 2.4.0.

## Rebuild

```bash
tools/splat/build.sh                                   # default: SCA-103 .../SPLAT/EXPORT/SCA-103_RUSTAVELI_WIDE_2_SITE_splat.ply
KEEP=4000000 KEEP_MOBILE=2000000 tools/splat/build.sh ...   # more splats: ~12.7 bytes each
```

The 15k source has 6,000,000 splats with SH degree 3 and weighs 1.4 GB. The build:
- removes the view-dependent SH bands and keeps colour only;
- removes splats with opacity of 0.005 or less;
- decimates adaptively to 3,000,000 splats;
- writes a Morton-ordered SOG of about 38 MB for computers, and the same at 1.5M splats (about 19 MB) for phones — iOS Safari reloads the tab when the big file and its level-of-detail tree do not fit in memory;
- writes `rustaveli_heights.bin`, a roof-height grid the camera stays above (`heights.py`).

It takes about four minutes. After a rebuild, bump `SCAN_VERSION` in `index.html` so visitors drop the copy cached in their browser. One file is under the 100 MB GitHub Pages limit, so Git LFS is not needed.

## Coordinates

The SOG keeps the PLY's raw RealityScan/COLMAP frame of SCA-103: −y up, about 0.94 m per unit.

The page works in a fixed frame inherited from the first scan, SCA-102: gsplat's normalized frame of SCA-102's COLMAP cameras, z up, 1 unit ≈ 98 m. Every view and place was set in it. Two transforms connect the file to it:
- `NORM` in `index.html` (and `heights.py`) maps SCA-103 raw to that frame. It is SCA-102's gsplat normalization (`similarity_from_cameras` → `align_principal_axes` → z-flip) composed with a similarity from SCA-103 raw to SCA-102 raw. That similarity was found by pairing each scan's COLMAP cameras with the DJI photos' GPS (thumbnail match), fitting each scan to local ENU metres (about 0.9 m median residual), composing the two, and refining with trimmed ICP on solid splat centres (0.28 m median).
- After that, the page turns it y-up with a −90° turn about x.

Another export trained on SCA-103's COLMAP model drops in without code changes. A new scan needs a new similarity to SCA-102 raw, found the same way.

The camera views and the places (`OVERVIEW` and `VIEWS`) are in the page frame. They were placed by laying OSM building outlines over a top view of the scan. To place a geographic point:
1. Convert it to east/north metres from the Rustaveli monument.
2. Rotate by 73°.
3. Scale by 1/111.
4. Add the monument's position, (-0.669, -0.165).

## Editing the views

```bash
python tools/scan_editor.py        # then open http://localhost:8772/?edit
```

With `?edit` the scan gets a panel:
- dragging turns the camera round the place without limits, and the wheel moves it closer or further;
- "Move dot" and "Move aim" put the place's dot, or the point the camera turns round, on the first wall or roof under the next click;
- sliders set the lens and the flight into the place: arc height (how high the curve goes over the roofs), swing out (how far the camera backs out of the old view and comes in along the new one) and flight time;
- "Replay flight" flies in again from the place before;
- "Save" writes every place to `assets/splats/scan_views.json`.

The page reads that file on load, and it overrides `OVERVIEW` and `VIEWS` in `index.html` field by field.
