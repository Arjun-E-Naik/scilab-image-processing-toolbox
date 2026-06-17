
# bwarea.sci — Area of Objects in Binary Image for Scilab
 
---

 
## Overview
 
**bwarea** estimates the area of the foreground (on/true) pixels in a binary image. Unlike a simple pixel count (`sum(bw)`), it uses a more accurate method based on **2×2 bit-quad patterns** in the image. This approach accounts for different local configurations of pixels (isolated, adjacent, diagonal, etc.) and assigns fractional area contributions to them.
 

 
`bwarea.sci` works by:
 
1. Validating the input (must be 2-D, numeric or logical).  
2. Converting non-boolean inputs to logical (`non-zero → true`).  
3. Using 2-D convolutions with 2×2 kernels to count specific bit-quad patterns.  
4. Applying weighted contributions for each pattern type (Q1, Q2, Q3, Q4, QD) to compute the total area.
 
---
 

 
## Quick Start
 
```scilab
// Load the function
exec('bwarea.sci', -1)
 
// Compute area of a binary image matrix
bw = [0 1 0; 1 1 1; 0 1 0];
A = bwarea(bw)
// A = 4.75  (example)

exec('test_bwarea.sci', -1)  // runs the provided test suite
```
 
---
 
 
### `bwarea()`
 
```
total = bwarea(bw)
```
 
**Estimates the area of foreground objects in a binary image using bit-quad patterns.**
 
#### Parameters
 
| Parameter | Type | Description |
|-----------|------|-------------|
| `bw` | 2-D real numeric, integer, or logical array | The input binary image. Non-zero values are treated as foreground (`true`). Must be exactly 2-dimensional. |
 
#### Return Value
 
| Variable | Type | Description |
|----------|------|-------------|
| `total` | scalar double | Estimated area of all foreground pixels. |
 
 
---
 
## Variable Reference
 
The following variables appear inside `bwarea()`:
 
| Variable | Scope | Type | Description |
|----------|-------|------|-------------|
| `bw` | input | 2-D array | Input image (numeric or logical). |
| `total` | output | scalar double | Final computed area. |
| `fours`, `twos` | local | 2-D double | Convolution results with 2×2 all-ones and diagonal kernels. |
| `nQ1`, `nQ3`, `nQ4` | local | integer | Counts of specific 2×2 patterns. |
| `nQD`, `nQ2` | local | integer | Counts of diagonal and adjacent two-pixel patterns. |
| `lhs`, `rhs` | local | integers | Argument counts from `argn(0)`. |
| `T` | local | integer | Type code of the input (`type(bw)`). |
 
---
 
## Algorithm Explanation
 
```
Input image bw (2-D)
      │
      ▼
┌─────────────────────────────────────────────────────┐
│  1. Validate inputs                                  │
│     – Exactly 1 argument                             │
│     – Must be 2-D                                    │
│     – Numeric or logical                             │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  2. Convert to logical                               │
│     if not boolean: bw = (bw <> 0)                   │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  3. Define 2×2 kernels                               │
│     four = all-ones(2,2)                             │
│     two  = diagonal ones                             │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  4. Convolution                                      │
│     fours = conv2(bool2s(bw), four)                  │
│     twos  = conv2(bool2s(bw), two)                   │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  5. Count bit-quad patterns                          │
│     nQ1 = # of 2×2 blocks with sum=1                 │
│     nQ3 = # of 2×2 blocks with sum=3                 │
│     nQ4 = # of 2×2 blocks with sum=4                 │
│     nQD = # of 2×2 blocks with sum=2 (diagonal)      │
│     nQ2 = # of 2×2 blocks with sum=2 (adjacent)      │
└────────────────────┬────────────────────────────────┘
                     │
                     
┌─────────────────────────────────────────────────────┐
│  6. Compute weighted area                            │
│     total = 0.25*nQ1 + 0.5*nQ2 + 0.875*nQ3          │
│               + 1.0*nQ4 + 0.75*nQD                   │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
                  Return total
```
 
**Complexity:** O(M×N) where M×N is the image size (dominated by the two `conv2` operations).
 
---
 
## Mathematical Foundation
 
### Bit-Quad Area Estimation
 
The algorithm examines every 2×2 neighbourhood (bit-quad) in the image and assigns an area contribution based on the number and configuration of on pixels:
 
- **1 on-pixel** (Q1): area = **0.25**
- **2 adjacent on-pixels** (Q2, horizontal/vertical): area = **0.5**
- **2 diagonal on-pixels** (QD): area = **0.75**
- **3 on-pixels** (Q3): area = **0.875**
- **4 on-pixels** (Q4): area = **1.0**
 
These weights come from geometric considerations of how each local pattern contributes to the overall object area (as implemented in MATLAB’s `bwarea`).
 
The total area is the sum of contributions from all overlapping 2×2 neighbourhoods.
 
### Comparison to Simple Sum
 
| Image Type | Simple Count (`sum(bw)`) | `bwarea` Estimate |
|------------|---------------------------|-------------------|
| Single isolated pixel | 1 | **0.25** |
| 2×2 solid square | 4 | **4** (or very close) |
| Straight line (horizontal) | N | ≈ N−0.5 (boundary effects) |
| Diagonal line | N | Higher than simple count due to diagonal weighting |
 
---
 
## Test Cases with Expected Outputs
 
The provided test suite covers a wide range of cases. Here are selected examples with explanations:
 
### Test 1 — Empty Image (All zeros)
 
```scilab
bw = zeros(3,3);
A = bwarea(bw)
```
 
**Expected output:** `A = 0`
 
---
 
### Test 2 — Single Pixel
 
```scilab
bw = zeros(3,3); bw(2,2) = 1;
A = bwarea(bw)
```
 
**Pattern:** One Q1 quad → **Expected:** `A = 0.25`
 
---
 
### Test 3 — 2×2 Solid Square
 
```scilab
bw = zeros(4,4); bw(2:3, 2:3) = 1;
A = bwarea(bw)
```
 
**Expected:** `A = 4` (full pixel area recovered)
 
---
 
### Test 5 — 3×3 Solid Square
 
```scilab
bw = ones(3,3);
A = bwarea(bw)
```
 
**Expected:** `A = 9`
 
---
 
### Test 6 — 2×2 Diagonal (Identity)
 
```scilab
bw = eye(2,2);
A = bwarea(bw)
```
 
**Two diagonal pixels** → **Expected:** `A = 1.5` (0.75 × 2)
 
---
 
### Test 7 — Numeric Input Handling
 
```scilab
bw = [0 5 0; 0 -2 0; 0 0 0];
A = bwarea(bw)
```
 
Non-zero values are treated as foreground. **Expected:** Same as single-pixel case (`0.25`).
 
---
 
### Test 9 — 2×3 Rectangle
 
```scilab
bw = ones(2,3);
A = bwarea(bw)
```
 
**Expected:** `A = 6`
 

 
---
 
## References
 
- MATLAB Documentation: [`bwarea`](https://www.mathworks.com/help/images/ref/bwarea.html)
- Image Processing literature on bit-quad / local pattern area estimation
 
---
