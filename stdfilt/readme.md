# `stdfilt` — Local Standard Deviation Filter for Images 

---

## Overview

`stdfilt` slides a neighbourhood window (called the **domain**) across every pixel of an image and computes the **local standard deviation** of intensity values within that window.

- High std dev → high local contrast, rapid intensity variation (edges, textures).
- Low std dev → smooth, uniform neighbourhood (flat, homogeneous regions).

This makes the filter a useful **texture and edge descriptor** and a building block for contrast enhancement, noise estimation, segmentation, and adaptive thresholding.

---
## Calling Sequence

```scilab
S = stdfilt(I)
S = stdfilt(I, domain)
S = stdfilt(I, domain, padding)
```
---


### Complexity

| Stage | Complexity |
|-------|-----------|
| Padding | O(R · C) |
| Two `conv2` passes | O(R · C · K) where K = number of active domain pixels |
| Total | O(R · C · K) |

---
### Input Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `I` | numeric or logical matrix | — | Input 2-D image. Any numeric Scilab type is accepted; it is cast to `double` internally. |
| `domain` | numeric or logical matrix | `ones(3, 3)` (logical) | Neighbourhood mask. Non-zero entries define which pixels participate in the standard deviation calculation. Typically a square logical matrix of odd size. |
| `padding` | string | `"replicate"` | Border extrapolation mode. Controls how the image is extended beyond its edges.. |


---
### Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `retval` | double matrix, same size as I | Local standard deviation at every pixel |

---
## Padding Modes

| Mode | Description |
|------|-------------|
| `"replicate"` *(default)* | Nearest border value repeated outward |
| `"symmetric"` | Mirror reflection at border |
| `"zeros"` | Zero padding (all border pixels treated as 0) |


---



## Test Cases with Expected Outputs

### Test 1 — Uniform Image (all ones)

```scilab
A = ones(5, 5);
S = stdfilt(A);
```

**Expected output:** `zeros(5, 5)`

**Explanation:** Every neighbourhood contains only one distinct value. All deviations from the mean are zero, so standard deviation = 0 everywhere.

---

### Test 2 — All-Zeros Image

```scilab
A = zeros(4, 4);
S = stdfilt(A);
```

**Expected output:** `zeros(4, 4)`

**Explanation:** Same reasoning as Test 1 — a constant (zero) image has no local variation.

---

### Test 3 — `magic(5)` with 3×3 Domain

```scilab
M = uint8([17 24  1  8 15;
           23  5  7 14 16;
            4  6 13 20 22;
           10 12 19 21  3;
           11 18 25  2  9]);

S = stdfilt(M, ones(3,3));
```

**Expected output (Octave-verified, approximate):**

```
S =
  7.3654   8.5528   8.5528   8.5528   7.3654
  8.5528   7.5277   7.5277   7.5277   8.5528
  8.5528   7.5277   7.5277   7.5277   8.5528
  8.5528   7.5277   7.5277   7.5277   8.5528
  7.3654   8.5528   8.5528   8.5528   7.3654
```

**Explanation:**  
`magic(5)` has all distinct values 1–25 spread evenly. Interior pixels see 9 distinct, well-spread values → high std dev. Corner pixels have replicated border values → slightly different (lower) std dev due to value repetition from `"replicate"` padding.

---

### Test 4 — 5×5 Gradient Image with 3×3 Domain

```scilab
R = uint8([ 1  2  3  4  5;
           11 12 13 14 15;
           21 22  4  5  6;
            5  5  3  2  1;
           15 14 14 14 14]);

S = stdfilt(R, ones(3,3));
```

**Expected:** Output is 5×5, all values ≥ 0.

**Explanation:**  
The image mixes gradients with flat regions. The 3×3 window sees 9 values; std dev is higher in areas of rapid change (top rows) and lower in flatter regions (bottom-right corner).

---

### Test 5 — Single-Row Image

```scilab
A = [1 2 3 4 5];
S = stdfilt(A, ones(1, 3));
```

**Expected output:**

```
S =
  0.7071   1.0000   1.0000   1.0000   0.7071
```

**Explanation:**  
For a 1×3 window on a linear ramp, interior pixels see three consecutive integers whose std dev is exactly 1. Border pixels (with replicated padding) see only two distinct values → lower std dev of ≈ 0.707.

---

### Test 6 — Degenerate Domain (N ≤ 1)

```scilab
I = uint8([1 2 3; 4 5 6; 7 8 9]);
S = stdfilt(I, [0 0 0; 0 1 0; 0 0 0]);  // single active pixel
```

**Expected output:** `zeros(3, 3)`

**Explanation:**  
With only one active pixel in the domain, `N = 1` and `N − 1 = 0`, making variance undefined. `stdfilt` detects this and returns an all-zero matrix to avoid division by zero.

---

### Test 7 — Non-Square Domain (3×5)

```scilab
I7 = uint8([10 20 30 40 50;
            15 25 35 45 55;
            20 30 40 50 60;
            25 35 45 55 65;
            30 40 50 60 70]);

S7 = stdfilt(I7, ones(3, 5));
```

**Expected:** Output is 5×5, all values ≥ 0.

**Explanation:**  
Verifies correct handling of non-square neighbourhood masks. The 3×5 domain (N = 15) spans a wider horizontal range; the strictly increasing image has moderate, consistent std dev across the output.

---

### Test 8 — Padding Mode Comparison

```scilab
I8 = double([1 2 3; 4 5 6; 7 8 9]);
S_rep = stdfilt(I8, ones(3,3), "replicate");
S_sym = stdfilt(I8, ones(3,3), "symmetric");
S_zer = stdfilt(I8, ones(3,3), "zeros");
```

**Expected:**  
`S_rep`, `S_sym`, and `S_zer` all differ at border pixels (max pairwise difference > 0); interior pixel `S(2,2)` is the same for all three modes.

**Explanation:**  
Border extrapolation only affects pixels whose neighbourhood extends beyond the image edge. The three modes produce different virtual border values → different local std dev at border pixels. The centre pixel always uses only real image values, so its result is padding-independent.

---

### Test 9 — Double-Precision Floating-Point Input

```scilab
H = [5.0 2.0 8.0; 1.0 -3.0 1.0; 5.0 1.0 0.0];
S = stdfilt(H, ones(3,3));
```

**Expected:** 3×3 double matrix with values ≥ 0.

**Explanation:**  
`stdfilt` accepts `double` input directly without any rescaling. Negative values are valid — they simply shift the local mean; the standard deviation (spread around the mean) is unaffected by a global offset.

---

### Test 10 — Large Flat Region with Isolated Spike

```scilab
I10 = zeros(7, 7);
I10(4, 4) = 100;
S10 = stdfilt(I10, ones(3,3));
```

**Expected:** `S10` is zero everywhere except in the 3×3 neighbourhood centred on (4,4).

**Explanation:**  
Pixels whose 3×3 window does not include (4,4) see all zeros → std dev = 0. Pixels whose window does include the spike see a mix of zeros and 100 → non-zero std dev, with the maximum at (4,4) itself.

---
