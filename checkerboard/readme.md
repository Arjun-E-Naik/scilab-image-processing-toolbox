# checkerboard.sci — N-Dimensional Checkerboard Image Generator




## Overview

`checkerboard.sci` generates a synthetic **checkerboard test pattern** — a tiled black/white image commonly used as a calibration target, registration reference, or alignment test for image-processing pipelines. Each tile is divided into 2ⁿ unit squares (where *n* is the number of dimensions), alternating between `0` (black) and `1` (white). As a visual orientation aid, the **second half of the image is darkened**: every white (`1`) square in that half is rescaled to `0.7` (mid-gray), while black (`0`) squares are left untouched.




---

## Calling Sequence

### `checkerboard()`

```
board = checkerboard()
board = checkerboard(side)
board = checkerboard(side, M)
board = checkerboard(side, [M N ...])
board = checkerboard(side, M, N, P, ...)
```

**Generates an N-dimensional checkerboard test image.**

#### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `side` | non-negative integer scalar | `10` | Pixel width of one square (half the width of one tile). Validated only when supplied (`rhs > 0`); the implicit default of `10` used when called with zero arguments is **not** passed through validation. |
| `M, N, P, ...` | positive integer scalars, *or* a single numeric vector `[M N P ...]` | `[4 4]` | Number of tiles along each dimension. May be given as one scalar (square `M × M` layout), one size vector (arbitrary N-D layout), or as separate scalar arguments (one per dimension, also arbitrary N-D). |

#### Return Value

| Variable | Type | Description |
|---|---|---|
| `board` | double array, 2-D or N-D | The generated checkerboard. Contains exactly three distinct values: **`0`** (black square, in either half), **`1`** (white square, unshaded half), and **`0.7`** (white square, shaded half — black squares are unaffected by shading since `0 × 0.7 = 0`). |

#### Validation Rules

| Condition | Error raised |
|---|---|
| `side` is not a non-negative integer scalar | `"checkerboard: SIDE must be a non-negative integer"` |
| Any `M, N, P, ...` argument is non-numeric | `"checkerboard: SIZE or MxNx... list must be numeric"` |
| Any separately-passed `M, N, P, ...` argument is not a scalar | `"checkerboard: M, N, P, ... must be numeric scalars"` |
| Resulting tile-layout vector contains a negative or non-integer value | `"checkerboard: SIZE or MxNx... list must be non-negative integer"` |

---


**Complexity:** O(P) where P is the total pixel count of the output, dominated by the `repmat` tiling step and the shading assignment.

---



---

## Test Cases with Expected Outputs

All outputs below were captured from an actual Scilab run of the function (`scilab-cli`, Scilab 2024.0.0) using `test_checkerboard.sci`.

### Test 1 — Basic Board (4×4 matrix)

```scilab
disp(checkerboard(1, 2))
```

**Expected output:**

```
0.   1.   0.    0.7
1.   0.   0.7   0.
0.   1.   0.    0.7
1.   0.   0.7   0.
```


---

### Test 2 — Rectangular Layout (8×12 matrix)

```scilab
disp(checkerboard(2, 2, 3))
```


**Expected output:**

```
0.   0.   1.   1.   0.   0.   0.7   0.7   0.    0.    0.7   0.7
0.   0.   1.   1.   0.   0.   0.7   0.7   0.    0.    0.7   0.7
1.   1.   0.   0.   1.   1.   0.    0.    0.7   0.7   0.    0.
1.   1.   0.   0.   1.   1.   0.    0.    0.7   0.7   0.    0.
0.   0.   1.   1.   0.   0.   0.7   0.7   0.    0.    0.7   0.7
0.   0.   1.   1.   0.   0.   0.7   0.7   0.    0.    0.7   0.7
1.   1.   0.   0.   1.   1.   0.    0.    0.7   0.7   0.    0.
1.   1.   0.   0.   1.   1.   0.    0.    0.7   0.7   0.    0.
```

---

### Test 3 — 3D Matrix Quirk

```scilab
disp(size(checkerboard(1, 1, 1, 2)))
```


**Expected output:** `2.   2.   4.`


---

### Test 4 — Vector Sizing

```scilab
disp(size(checkerboard(1, [3, 2])))
```


**Expected output:** `6.   4.`

---

### Test 5 — Side = 0 (Empty Matrix)

```scilab
disp(size(checkerboard(0, 3, 3)))
```


**Expected output:** `0.   0.`

---

### Test 6 — Dimension = 0 (Engine Limits)

```scilab
disp(size(checkerboard(2, 0, 3)))
```


**Expected output:** `0.   0.`


---


