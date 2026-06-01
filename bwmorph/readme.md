# `bwmorph.sci` — Binary Image Morphological Operations

---

## Overview

**Binary morphological operations** reshape binary (black-and-white) images by applying
neighbourhood rules to every pixel. Each operation slides a small window over the image,
examines the pixel pattern inside, and decides what the center pixel should become.


### How to use

```scilab
exec("bwmorph.sci")            // load all functions

out = bwmorph(img, "dilate")          // run once
out = bwmorph(img, "thin", %inf)      // run until stable
out = bwmorph(img, "erode", 3)        // run exactly 3 times
```

---



### `bwmorph(bw, operation [], n)`

```scilab
bw2 = bwmorph(bw, operation)
bw2 = bwmorph(bw, operation, n)
```

Performs the named morphological operation on binary image `bw`, repeated `n` times.

#### Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `bw` | numeric or boolean matrix | Input binary image.  |
| `operation` | string | Name of the operation to apply .  |
| `n` | scalar (optional) | Number of iterations. |

#### Output

| Parameter | Type | Description |
|-----------|------|-------------|
| `bw2` | boolean matrix | Result image, same size as `bw`. |

---

### Helper functions 

| Function | Signature | What it does |
|----------|-----------|--------------|
| `bw_dilate` | `R = bw_dilate(A, se)` | Dilate `A` with structuring element `se` |
| `bw_erode` | `R = bw_erode(A, se)` | Erode `A` with structuring element `se` |
| `bw_open` | `R = bw_open(A, se)` | Erode then dilate |
| `bw_close` | `R = bw_close(A, se)` | Dilate then erode |
| `bw_tophat` | `R = bw_tophat(A, se)` | `A AND NOT open(A)` |
| `bw_bothat` | `R = bw_bothat(A, se)` | `close(A) AND NOT A` |
| `bw_padarray` | `P = bw_padarray(A, pad)` | Pad `A` with `pad` rows/columns of zeros on all four sides |
| `local_applylut` | `B = local_applylut(A, lut)` | Apply a 512-entry boolean LUT to every pixel using its 3×3 neighbourhood |

---

## Variables

### Main function variables

| Variable | Description |
|----------|-------------|
| `bw` | Primary input binary image. Converted to boolean at the start of `bwmorph`. |
| `operation` | String name of the morphological operation to run. |
| `n` | Number of iterations. Default 1. `%inf` means run until stable. |
| `op` | Lowercase copy of `operation` (from `convstr`), used for case-insensitive dispatch. |
| `se3` | 3×3 all-ones structuring element used by dilate, erode, open, close, tophat, bothat. |
| `loop_once` | Boolean flag. Set to `%t` for idempotent operations — applying them more than once gives the same result, so `n` is clamped to 1. |
| `morph_tag` | String tag that tells the iteration loop which code path to execute. Possible values: `"dilate"`, `"erode"`, `"open"`, `"close"`, `"tophat"`, `"bothat"`, `"lut1"`, `"lut1_and"`, `"lut12"`, `"conv_gt"`, `"conv_ge"`, `"done"`. |
| `v`, `v1`, `v2` | Temporary integer column vectors (512×1) holding raw LUT data (0s and 1s). Converted to boolean with `(v ~= 0)`. |
| `lut1`, `lut2` | Boolean column vectors (512×1). The lookup tables used by LUT-based operations. |
| `post_bridge` | Boolean flag. Set to `%t` for `skel` and `skel-pratt`, which run a bridge pass after each thinning iteration to reconnect broken skeleton segments. |
| `K` | Convolution kernel matrix for operations that use `conv_gt` or `conv_ge`. |
| `thresh` | Numeric threshold for convolution-based operations. |
| `bw2_tmp` | Temporary result matrix holding the output of the current iteration. Becomes `bw2` at the end. |
| `pad` | Border padding width used by the `thicken` operation. Computed as `2 * min([max(size(bw)), n])`. |
| `i` | Loop counter for the iteration while-loop. |
| `acc` | Accumulator boolean matrix used by `skel-lantuejoul` to collect results across erosion levels. |
| `iter` | Inner iteration counter inside `skel-lantuejoul`. |
| `ebw` | Eroded version of the current image inside `skel-lantuejoul`. |

### `local_applylut` variables

| Variable | Description |
|----------|-------------|
| `A` | Input boolean image to which the LUT is applied. |
| `lut` | 512×1 boolean column vector; the lookup table. |
| `W` | Pre-flipped 3×3 weight matrix `[128 64 32; 16 256 8; 4 2 1]` passed to `conv2`. After `conv2` flips it internally, the weights land on the correct neighbours. |
| `idx` | Integer matrix (same size as `A`) containing the 1-based LUT index for each pixel. |
| `B` | Output boolean matrix (same size as `A`). |

### Helper function variables

| Variable | Description |
|----------|-------------|
| `se` | Structuring element passed to helper functions (typically `se3 = ones(3,3)`). |
| `full` | `sum(se(:))` — the maximum possible conv2 result, used as the erosion threshold. |
| `r`, `c` | Row and column count of the padded image inside `bw_padarray`. |
| `P` | Output padded matrix in `bw_padarray`. |

---

## Supported Operations

| Operation | Idempotent | Description |
|-----------|-----------|-------------|
| `bothat` | yes | `close(bw) AND NOT bw` — highlights dark spots smaller than the SE |
| `bridge` | yes | Sets a 0-pixel to 1 when it bridges two disconnected 1-pixel regions |
| `clean` | yes | Removes isolated 1-pixels whose all 8 neighbours are 0 |
| `close` | yes | Dilate then erode — fills small holes and gaps |
| `diag` | no | Diagonal fill — prevents diagonal gaps between foreground regions |
| `dilate` | no | Grows every foreground region outward by one pixel |
| `endpoints` | — | Finds branch tips in a skeleton (pixels with exactly one neighbour) |
| `erode` | no | Shrinks every foreground region inward by one pixel |
| `fill` | yes | Sets a 0-pixel to 1 if all four 4-connected neighbours are 1 |
| `hbreak` | yes | Breaks H-shaped junctions in skeletons |
| `majority` | no | Sets a pixel to 1 if 5 or more of the 9 pixels in its 3×3 window are 1 |
| `open` | yes | Erode then dilate — removes small protrusions |
| `remove` | yes | Removes interior pixels (all four 4-connected neighbours are 1) |
| `shrink` | no | Shrinks objects to single pixels (no holes) or rings (with holes) |
| `skel` | no | Skeletonization using Pratt's algorithm (medial-axis skeleton) |
| `skel-lantuejoul` | no | Skeletonization using Lantuejoul's method (union of tophat levels) |
| `spur` | no | Removes dead-end (spur) pixels from a skeleton |
| `thin` | no | Thins objects to 1-pixel-wide strokes |
| `thin-pratt` | no | Thinning using Pratt's algorithm |
| `thicken` | no | Grows objects without letting them merge |
| `tophat` | yes | `bw AND NOT open(bw)` — highlights small bright features |

---

## Algorithm Explanation

### Convolution-based operations

Dilation, erosion, clean, fill, remove, and majority all use `conv2` internally.

```
bw_dilate:   conv2(bw, ones(3,3)) > 0
             Any pixel with at least one white neighbour becomes white.

bw_erode:    conv2(bw, ones(3,3)) >= 9
             A pixel stays white only when all 9 neighbourhood pixels are white.

clean:       conv2(bw, K) > 8   where K = ones(3,3) with center = 8
             conv = 8 means center=1 but all neighbours are 0  → remove
             conv > 8 means center=1 and at least one neighbour is 1  → keep

fill:        conv2(bw, K) >= 4  where K = cross with center = 4
             conv >= 4 means center=1 (stays) OR center=0 with all 4 direct neighbours=1

remove:      conv2(bw, K) > 0   where K = [0 -1 0; -1 4 -1; 0 -1 0]
             center=1, all 4 direct nbrs=1  → 4-4=0  not > 0  → remove
             center=1, any direct nbr=0     → 4-k > 0         → keep

majority:    conv2(bw, ones(3,3)) >= 4.5
             Sum >= 4.5 means 5 or more of the 9 pixels are 1.
```

### LUT-based operations

Bridge, diag, endpoints, hbreak, spur, shrink, skel, thin, and thin-pratt all use
look-up tables. Each pixel's 3×3 neighbourhood is encoded as a 9-bit integer
(the LUT index), and the table entry tells us what the center pixel should become.

**Neighbourhood bit layout:**

```
   X3  X2  X1
   X4   X  X0
   X5  X6  X7

index = 1 + X0*1 + X1*2 + X2*4 + X3*8 + X4*16
            + X5*32 + X6*64 + X7*128 + Xcenter*256
```

With 9 binary pixels there are 2^9 = 512 possible patterns, so each LUT has
exactly 512 entries. The LUT is stored as a 512×1 boolean column vector.

**Why the weight matrix is `[128 64 32; 16 256 8; 4 2 1]`:**

`conv2` performs correlation, which flips the kernel before sliding it over the
image. i  write the weights *pre-flipped* so that after `conv2`'s internal flip
each weight lands on the correct neighbour position, producing the exact index
formula.

**Two-LUT operations (shrink, skel, thin-pratt):**

```
Step 1:  mid  = lut1(bw)       mark candidates for deletion
Step 2:  keep = lut2(mid)      veto deletions that break topology
Step 3:  bw2  = bw AND keep    apply only safe deletions (never add pixels)
```

**thin** uses the same two-LUT approach but without the final AND with the
original, which is what allows it to produce strokes rather than single points.

### Iteration loop

```
if loop_once then clamp n to 1   // skip redundant iterations
bw2_tmp = bw                     // initialise result

while i <= n:
    apply the selected morph_tag code path
    if image unchanged: break early   // convergence
    bw = bw2_tmp
    i++

if post_bridge: bwmorph(bw2_tmp, "bridge")   // skel only
bw2 = bw2_tmp
```

### skel-lantuejoul algorithm

```
acc = all-zeros image

for i = 1 to n:
    if bw is all-zeros: stop
    ebw     = erode(bw)
    top_hat = bw AND NOT dilate(ebw)   // pixels lost at this erosion level
    acc     = acc OR top_hat           // accumulate skeleton
    bw      = ebw                      // next level

return acc
```

### thicken algorithm

```
pad the image with zeros
thin the BACKGROUND (inverted image) using thin-pratt
apply diagonal fill pass (diag)
remove padding
invert back
```

---

## Test Cases

### Test 1 — `clean`: remove isolated pixel, keep neighboured pixel

```scilab
in  = ([0 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "clean");
// pixel at (2,1) has no white neighbours → removed
// pixel at (2,3) touches (3,3) → kept
// Expected:
// 0  0  0
// 0  0  1
// 0  0  1
```

### Test 2 — `bridge`: connect two diagonal regions

```scilab
in  = ([1 0 0; 1 0 1; 0 0 1] ~= 0);
out = bwmorph(in, "bridge");
// The gap pixel at (1,2) and (2,2) bridge the two disconnected regions
// Expected:
// 1  1  0
// 1  1  1
// 0  1  1
```

### Test 3 — `dilate`: single pixel expands to 3×3

```scilab
in  = ([0 0 0; 0 1 0; 0 0 0] ~= 0);
out = bwmorph(in, "dilate");
// Every pixel within the 3x3 window of the center becomes 1
// Expected: ones(3,3)
```

### Test 4 — `erode`: solid 3×3 shrinks to single center pixel

```scilab
in  = ones(3,3) ~= 0;
out = bwmorph(in, "erode");
// Only the center pixel has all 9 neighbours as 1
// Expected:
// 0  0  0
// 0  1  0
// 0  0  0
```

### Test 5 — `remove`: hollow out a filled region

```scilab
in  = ([0 1 0 0 0; 1 0 0 1 0; 1 0 1 0 0; 1 1 1 1 1; 1 1 1 1 1] ~= 0);
out = bwmorph(in, "remove");
// Position (4,3): all 4 direct neighbours are 1 → removed
// Expected:
// 0  1  0  0  0
// 1  0  0  1  0
// 1  0  1  0  0
// 1  1  0  1  1
// 1  1  1  1  1
```

### Test 6 — `endpoints`: tips of skeleton branches

```scilab
in  = ([0 0 0 0 0; 0 0 1 0 0; 0 1 1 1 0; 0 0 1 0 0; 0 0 0 0 0] ~= 0);
out = bwmorph(in, "endpoints");
// The center pixel has 4 neighbours → not an endpoint
// Each arm tip has 1 neighbour → endpoint
// Expected:
// 0  0  0  0  0
// 0  0  1  0  0
// 0  1  0  1  0
// 0  0  1  0  0
// 0  0  0  0  0
```

### Test 7 — `skel-lantuejoul`: progressive skeleton

```scilab
// 12x7 irregular blob from Gonzalez & Woods fig 8.39
slBW = ([0 0 0 0 0 0 0; 0 1 0 0 0 0 0; 0 0 1 1 0 0 0; 0 0 1 1 0 0 0; ...
         0 0 1 1 1 0 0; 0 0 1 1 1 0 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; ...
         0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 1 1 1 1 1 0; 0 0 0 0 0 0 0] ~= 0);

out_n1  = bwmorph(slBW, "skel-lantuejoul", 1);    // first level only
out_n3  = bwmorph(slBW, "skel-lantuejoul", 3);    // three levels
out_inf = bwmorph(slBW, "skel-lantuejoul", %inf); // full skeleton
```

---



## Running the Tests

```scilab
exec("bwmorph.sci")       // load all functions
exec("test_bwmorph.sci")  // run all assertions, prints PASS/FAIL for each
```
