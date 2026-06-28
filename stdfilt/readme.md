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

**Expected output:** 
```
   0   0   0   0   0
   0   0   0   0   0
   0   0   0   0   0
   0   0   0   0   0
   0   0   0   0   0
```

**Explanation:** Every neighbourhood contains only one distinct value. All deviations from the mean are zero, so standard deviation = 0 everywhere.

---

### Test 2 — All-Zeros Image

```scilab
A = zeros(4, 4);
S = stdfilt(A);
```

**Expected output:** 
```
   0   0   0   0
   0   0   0   0
   0   0   0   0
   0   0   0   0
```

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
   6.0438   9.7568   8.7433   5.8973   3.2059
   8.8318   8.5065   7.4907   6.6039   4.4190
   7.4963   6.5192   6.1237   6.5192   7.4963
   4.4190   6.6039   7.4907   8.5065   8.8318
   3.2059   5.8973   8.7433   9.7568   6.0438
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

**Expected:**
```
   5.0249   5.0744   5.0744   5.0744   5.0249
   8.6747   7.9757   6.7966   4.8477   4.7958
   7.1434   7.1589   6.7165   5.4772   5.9114
   7.1239   7.4012   6.9422   5.4544   5.5902
   4.8505   5.0498   5.3877   6.0208   6.3399
```

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
0.5774   1.0000   1.0000   1.0000   0.5774
```

**Explanation:**  
For a 1×3 window on a linear ramp, interior pixels see three consecutive integers whose std dev is exactly 1. Border pixels (with replicated padding) see only two distinct values → lower std dev of ≈ 0.707.

---

### Test 6 — Degenerate Domain (N ≤ 1)

```scilab
I = uint8([1 2 3; 4 5 6; 7 8 9]);
S = stdfilt(I, [0 0 0; 0 1 0; 0 0 0]);  // single active pixel
```

**Expected output:** 
```
0 0 0
0 0 0
0 0 0
```

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
```
    8.1211   12.3153   14.8404   12.3153    8.1211
    8.8237   12.7895   15.2362   12.7895    8.8237
    8.8237   12.7895   15.2362   12.7895    8.8237
    8.8237   12.7895   15.2362   12.7895    8.8237
    8.1211   12.3153   14.8404   12.3153    8.1211
```
**Explanation:**  
Verifies correct handling of non-square neighbourhood masks. The 3×5 domain (N = 15) spans a wider horizontal range; the strictly increasing image has moderate, consistent std dev across the output.

---

### Test 8 — Padding Mode Comparison

```scilab
I8 = double([1 2 3; 4 5 6; 7 8 9]);
S_rep = stdfilt(I8, ones(3,3), "replicate");
```

**Expected:**  
```
   1.5811   1.7321   1.5811
   2.6458   2.7386   2.6458
   1.5811   1.7321   1.5811
```


---

### Test 9 — Double-Precision Floating-Point Input

```scilab
H = [5.0 2.0 8.0; 1.0 -3.0 1.0; 5.0 1.0 0.0];
S = stdfilt(H, ones(3,3));
```

**Expected:** 3×3 double matrix with values ≥ 0.
```
   2.7437   3.5978   4.1667
   2.7889   3.2702   3.6742
   2.8284   2.4889   1.2693
```
---

### Test 10 — Large Flat Region with Isolated Spike

```scilab
I10 = zeros(7, 7);
I10(4, 4) = 100;
S10 = stdfilt(I10, ones(3,3));
```

**Expected:** `S10` is zero everywhere except in the 3×3 neighbourhood centred on (4,4).

```
         0         0         0         0         0         0         0
         0         0         0         0         0         0         0
         0         0   33.3333   33.3333   33.3333         0         0
         0         0   33.3333   33.3333   33.3333         0         0
         0         0   33.3333   33.3333   33.3333         0         0
         0         0         0         0         0         0         0
         0         0         0         0         0         0         0
```

---
