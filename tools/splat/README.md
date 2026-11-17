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

A place can have a `phone` entry with its own fields, for example `"phone": { "d": 0.15, "fov": 80 }`. Phones use it (touch screens, or windows up to 640 px wide), and computers ignore it. To edit the phone views, open `?edit&phone`: Save then writes only the `phone` entries and leaves the computer views as they were.

## Room after the square (SCA-104)

`assets/splats/room1.sog` is the light web file (`splat/web/*_web.sog`) of scan SCA-104_EXAMPLE_ROOM_1 from
scan.pvf.asia, downloaded as is; `room1/scene_info.json` is its scene info. It is the slide after the last
spot: index.html starts downloading it only once the Rustaveli scan is in (cache version `ROOM_VERSION`).
The file is in RealityScan's raw frame; the page turns it a half turn about x (as the scan site does) and
places it at `ROOM_AT`, scaled by `ROOM_S`. Its view (`ROOM_VIEW`, or "Room" in scan_views.json, editable
with ?edit) has its point in the scan site's frame, the same frame as the views saved there. It is the scan
site's saved view 6: a section on a 10° lens; ROOM_CUT (the plane) and ROOM_BOX (the crop) were worked out as
the site does (section.tsx planeOf over the box of the room's markup, a tenth larger).

The way from the last spot (TSSR) into the room is scrolled through, not stepped (`window.roomT` in the page,
eased into `rt` in the scan module; ?debug gives `dbg.rt(x)` to set it): a level section plane rises through
the square, the page's row of bulbs moves to the right half and multiplies down, the bulbs outside the room's
outline go out, the rest slide onto the lights of the string on its wall (found in the splats: small bright
yellow ones, `readRoom`), and the room appears round them.

The room has three stops, the scan site's saved views 6, 7 and 8 (`ROOM_VIEWS`: camera, the point it looks at,
lens, and the section's yaw and share, as the site stores them). Between them the camera goes round the room
and the section plane glides from one view's to the next's. The bulbs of the way in sit on a lattice fitted to
the string of lights on the wall in view 6 (`BULB_GRID`); the ones that stay are cells of it, clicked in ?edit
on the room and saved to `assets/splats/room_bulbs.json` (until then: the cells with a light of the scan near them).

The second room is scan SCA-106_EXAMPLE_ROOM_2 (`assets/splats/room2.sog`, its light web file; `room2/scene_info.json`).
One stop, the scan site's first saved view of it (`ROOM2_VIEW`, a 117° lens). It has no marked objects, so its box
is made from its own splats as the scan site does (middle 96 % per axis, a third larger). It loads after the first
room, and the way in from the first room's last view is scrolled like the way into the first room
(`window.wipeT[1]`, `rt2`), without bulbs of its own.

The rooms after the first are one list in index.html (`EXTRA`): SCA-106 (`room2.sog`) and SCA-105
(`room3.sog`, `room3/scene_info.json`), three saved views each. Each loads after the one before, is drawn without
level of detail, gets its box from its own splats, and has its own scrubbed way in (`window.wipeT[1..]`). A view
may carry a `shift` (the picture moved across a wide screen, shares of its width and height); the first room's
first view has one, and the bulbs' lattice follows it.
