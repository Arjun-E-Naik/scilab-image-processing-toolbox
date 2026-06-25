# entropy.sci 
 
---

 
## Overview
 
**Shannon entropy** measures the amount of information (or randomness/disorder) present in an image. A uniform, single-colour image carries zero entropy; a noisy image with pixel values spread evenly across all intensities carries maximum entropy.
 
`entropy.sci` computes this quantity by:
 
1. Converting the image to an 8-bit (0–255) integer representation.  
2. Building a histogram of pixel intensities.  
3. Normalising the histogram into a probability distribution **P**.  
4. Applying the Shannon entropy formula **E = −Σ P · log₂(P)**.
The result is expressed in **bits**.
 
---
 
 
### `entropy()`
 
```
E = entropy(I)
E = entropy(I, nbins)
```
 
**Computes the Shannon entropy of an image.**
 
#### Parameters
 
| Parameter | Type | Description |
|-----------|------|-------------|
| `I` | real numeric or logical array (any shape) | The input image. May be 2-D (grayscale) or n-D (e.g. RGB as a 3-D array). All elements are pooled into a single flat list of pixel values. |
| `nbins` | positive integer scalar *(optional)* | Number of histogram bins used to estimate the probability distribution. Default: **2** for logical arrays, **256** for all other types. |
 
#### Return Value
 
| Variable | Type | Description |
|----------|------|-------------|
| `E` | scalar double | Shannon entropy in **bits**. Range: `[0, log2(nbins)]`. |
 
 ---
## Dependencies

 
### `im2uint8()` 
 
```
out = im2uint8(I)
```
 
Converts a numeric image array to uint8-equivalent double values (range 0–255), mirroring Octave/Matlab `im2uint8` semantics.
 
| Input value range | Conversion applied |
|-------------------|--------------------|
| `[0.0, 1.0]` (floating-point image) | Scaled: `round(I × 255)` |
| Outside `[0, 255]` (integer-coded) | Clamped to `[0, 255]` then rounded |
 

 
---
 
### `imhist()` 
 
```
counts = imhist_scilab(I, nbins)
```
 
Computes a histogram of pixel values over `nbins` equally-spaced bins, replicating the behaviour of Octave's `imhist()`.
 
| Parameter | Description |
|-----------|-------------|
| `I` | Column vector of pixel values (doubles, range 0–255) |
| `nbins` | Number of bins (`2` for logical, `256` otherwise) |
| **Returns `counts`** | `nbins × 1` vector of integer bin counts |
 
For binary/logical images (`nbins = 2`): bin 1 = value 0, bin 2 = any non-zero value.  
For uint8 images (`nbins = 256`): bins are uniformly spaced over `[0, 255]`.
 
---
 
**Complexity:** O(N) where N is the total number of pixels (for building the histogram). The normalisation and entropy summation are O(nbins) ≤ O(256).
 
---
 

 
## Test Cases with Expected Outputs
 
### Test 1 — Binary double array `[0, 1]`
 
```scilab
E = entropy([0, 1])
```
 
**Distribution:** P = [0.5, 0.5]  
**Calculation:** E = −(0.5 · log₂0.5 + 0.5 · log₂0.5) = −(−0.5 − 0.5) = **1.0 bit**  
**Expected output:** `E = 1.`
 
---
 
### Test 2 — Constant array `[0, 0]`
 
```scilab
E = entropy([0, 0])
```
 
**Distribution:** All pixels identical → only one occupied bin, P = [1.0]  
**Calculation:** E = −(1.0 · log₂1.0) = 0  
**Expected output:** `E = 0.`
 
---
 
### Test 3 — Single element `[1]`
 
```scilab
E = entropy([1])
```
 
**Distribution:** P = [1.0]  
**Calculation:** E = 0 (only one possible value)  
**Expected output:** `E = 0.`
 
---
 
### Test 4 — 3×3 logical array (mixed true/false)
 
```scilab
L = [%f %t %t; %f %t %t; %f %f %t]   // 5 false, 4 true
E = entropy(L)
```
 
**Distribution:** P = [5/9, 4/9]  
**Calculation:**
 
```
E = −(5/9 · log₂(5/9) + 4/9 · log₂(4/9))
  = −(5/9 · (−0.84799) + 4/9 · (−1.16993))
  ≈ 0.9911 bits
```
 
**Expected output:** `E ≈ 0.9910761`
 
---
 
### Test 5 — Uniform 3×3 uint8 matrix (all 128)
 
```scilab
U = 128 .* ones(3, 3)
E = entropy(U)
```
 
**Distribution:** All 9 pixels map to the same bin → P = [1.0]  
**Calculation:** E = 0  
**Expected output:** `E = 0.`
 
---
 
### Test 6 — 3×3 matrix `C = [1 1 1; 2 2 2; 3 3 3]`
 
```scilab
C = [1 1 1; 2 2 2; 3 3 3]
E = entropy(C)
```
 
 
**Expected output:** `E = 0`
 

---
# References

[1] MATLAB Image Processing Toolbox Documentation

[2] GNU Octave Image Package Documentation

---
---
