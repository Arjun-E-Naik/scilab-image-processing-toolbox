# bweuler.sci — Binary Image Euler Number

---

## Overview

The **Euler number** (also called the Euler characteristic or Euler–Poincaré number) is a fundamental topological property of a binary image. For a 2-D image it is defined as:

```
E = C − H
```

where **C** is the number of connected foreground components (objects) and **H** is the total number of enclosed holes across all objects. Background regions that touch the image border are **not** counted as holes.



| Image topology | Euler number |
|---|---|
| Empty image (all background) | 0 |
| Single solid object, no holes | +1 |
| Object with one hole (ring) | 0 |
| Object with k holes | 1 − k |
| k separate objects, no holes | k |
| k objects, h total holes | k − h |


---



## Callable Sequences

### `bweuler()`

```
eul = bweuler(BW)
eul = bweuler(BW, n)
```

Computes the **Euler number** of a 2-D binary image.

#### Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `BW` | 2-D real, logical, or integer array | — | Input binary image. Non-zero pixels are foreground; zero pixels are background. |
| `n` | integer scalar (`4` or `8`) | `8` | Connectivity model for defining foreground objects and counting components. |

#### Return Value

| Variable | Type | Range | Description |
|---|---|---|---|
| `eul` | scalar double | any integer | Euler number E = C − H. Positive when objects outnumber holes; negative when holes outnumber objects. |

#### Remarks

- `BW` is cast to boolean internally via `BW <> 0`; any non-zero pixel, regardless of magnitude or integer type, is treated as foreground.
- `n` must be exactly `4` or `8`; any other value raises an error.
- The result is mathematically guaranteed to be an integer but is returned as `double` for Octave/MATLAB compatibility.

---

## Variable Reference

| Variable | Scope | Type | Description |
|---|---|---|---|
| `BW` | input | double / boolean / integer (2-D) | Input binary image, any numeric type. |
| `n` | input / local | integer scalar | Foreground connectivity (`4` or `8`). Default `8`. |
| `eul` | output | scalar double | Computed Euler number. |
| `lhs`, `rhs` | local | integers | Left/right argument counts obtained via `argn(0)`. |
| `lut` | local | 16×1 double column vector | Quad-contribution lookup table. Content depends on chosen `n`. |
| `r`, `c` | local | integers | Row and column dimensions of `BW` from `size(BW)`. |
| `BWaux` | local | boolean, (r+1) × (c+1) | Zero-padded copy of `BW`. Top row and left column are `%f`; `BW` occupies `BWaux(2:end, 2:end)`. |

---

**Complexity:** O(r × c) — a single pass over the (r+1) × (c+1) padded image with O(1) work per window.

---

## Mathematical Foundation

### Euler Characteristic

For a 2-D binary image, the **Euler number** is the topological invariant:

```
E = C − H
```

| Symbol | Meaning |
|---|---|
| E | Euler number (Euler characteristic) |
| C | Number of connected foreground components |
| H | Total number of holes (enclosed background regions not touching the image border) |



### 2×2 Quad Decomposition

The Euler number is expressed as a sum of local contributions from all overlapping 2×2 windows:

```
       1
E  = ─────  ×  Σ  w(Q_k)
       4       k
```

where Q_k is the k-th 2×2 window and w(Q_k) ∈ {−2, −1, 0, +1, +2} is its contribution weight from the lookup table. Defining:

| Symbol | Meaning |
|---|---|
| Q₁ | Count of 2×2 windows containing exactly 1 foreground pixel |
| Q₃ | Count of 2×2 windows containing exactly 3 foreground pixels |
| Q_D | Count of 2×2 windows containing a diagonal pair (2 foreground pixels in non-adjacent corners) |

the formulas reduce to:

```
4-connectivity:   4E =  Q₁  −  Q₃  +  2 Q_D
8-connectivity:   4E =  Q₁  −  Q₃  −  2 Q_D
```

All other window types (empty, two adjacent pixels, full quad) contribute zero.


## Test Cases with Expected Outputs

### Test 1 — Empty Image

```scilab
BW = zeros(5, 5);
E = bweuler(BW);
disp(E)
```

No foreground pixels: C = 0, H = 0.

**Expected output:** `0.`

---

### Test 2 — Single Pixel

```scilab
BW = zeros(5, 5);
BW(3, 3) = 1;
E = bweuler(BW);
disp(E)
```

One isolated foreground pixel with no enclosed background: C = 1, H = 0.

**Expected output:** `1.`

---

### Test 3 — Solid 5×5 Rectangle

```scilab
BW = ones(5, 5);
E = bweuler(BW);
disp(E)
```

One solid, simply-connected region with no enclosed holes: C = 1, H = 0.

**Expected output:** `1.`

---

### Test 4 — Two Separate Objects

```scilab
BW = zeros(6, 6);
BW(2, 2) = 1;
BW(5, 5) = 1;
E = bweuler(BW);
disp(E)
```

Two isolated foreground pixels far apart; no shared edge or diagonal under either connectivity: C = 2, H = 0.

**Expected output:** `2.`

---

### Test 5 — Ring (One Hole)

```scilab
BW = [1 1 1; 1 0 1; 1 1 1];
E = bweuler(BW);
disp(E)
```

```
1 1 1
1 0 1
1 1 1
```

One object enclosing one background pixel that cannot reach the image border: C = 1, H = 1.

**Expected output:** `0.`

---

### Test 6 — Two Rings

```scilab
BW = [1 1 1 0 1 1 1
      1 0 1 0 1 0 1
      1 1 1 0 1 1 1];
E = bweuler(BW);
disp(E)
```

```
1 1 1 0 1 1 1
1 0 1 0 1 0 1
1 1 1 0 1 1 1
```

Two separate ring-shaped objects (separated by a column of zeros), each enclosing exactly one hole: C = 2, H = 2.

**Calculation:** E = 2 − 2 = 0

**Expected output:** `0.`

---

### Test 7 — Non-Binary Integer Input

```scilab
BW = [0 0 0; 0 5 0; 0 0 0];
E = bweuler(BW);
disp(E)
```

After boolean cast (`BW <> 0`): one `%t` pixel at the centre, all others `%f`. Topologically identical to Test 2.

**Expected output:** `1.`

---

### Test 8 — Connectivity Difference (Diagonal Pair)

```scilab
BW = [1 0; 0 1];
e4 = bweuler(BW, 4);
e8 = bweuler(BW, 8);
disp(e4)
disp(e8)
```

```
1 0
0 1
```

Under **4-connectivity** the two pixels share no common edge and are separate components: C = 2, H = 0.

Under **8-connectivity** the pixels share a diagonal neighbour and form one component: C = 1, H = 0.

**Expected output:**

```
2.       // e4
1.       // e8
```

---

### Test 9 — Large Ring

```scilab
BW = [1 1 1 1 1
      1 0 0 0 1
      1 0 0 0 1
      1 0 0 0 1
      1 1 1 1 1];
E = bweuler(BW);
disp(E)
```

```
1 1 1 1 1
1 0 0 0 1
1 0 0 0 1
1 0 0 0 1
1 1 1 1 1
```

One foreground ring enclosing a 3×3 region of background: C = 1, H = 1.

**Expected output:** `0.`

---

### Test 10 — One Object, Two Holes

```scilab
BW = [1 1 1 1 1 1 1
      1 0 1 1 1 0 1
      1 1 1 1 1 1 1];
E = bweuler(BW);
disp(E)
```

```
1 1 1 1 1 1 1
1 0 1 1 1 0 1
1 1 1 1 1 1 1
```

The foreground forms one connected object (the 1s in row 2, column 3–5 link the left and right halves). The two isolated interior zeros at positions (2,2) and (2,6) are fully enclosed: C = 1, H = 2.

**Calculation:** E = 1 − 2 = −1

**Expected output:** `-1.`

---


## References

- Serra, J. (1982). *Image Analysis and Mathematical Morphology*. Academic Press.
- Pratt, W. K. (2007). *Digital Image Processing* (4th ed.). Wiley-Interscience.
- Gonzalez, R. C., & Woods, R. E. (2018). *Digital Image Processing* (4th ed.). Pearson.
- Rosenfeld, A., & Kak, A. C. (1982). *Digital Picture Processing* (2nd ed.). Academic Press.
- GNU Octave Image Package — `bweuler` function source:
  https://octave.sourceforge.io/image/function/bweuler.html
- MathWorks — `bweuler` function documentation:
  https://www.mathworks.com/help/images/ref/bweuler.html
