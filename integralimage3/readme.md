
---


# `integralImage3` — 3-D Integral Image (Summed-Area Table)

---

## Overview

`integralImage3` calculates the **3-D integral image** (also known as the *summed-area table*) of an input image or volume. Each output element holds the cumulative sum of all input pixels above, to the left, and in front of it (inclusive).

The output is always of type `double` and is padded with a leading row, column, and depth-slice of zeros so that box-sum queries never need boundary checks.

Two input shapes are supported:

| Input Shape | Output Shape | Description |
|-------------|--------------|-------------|
| **2-D matrix** | 2-D padded matrix | Grayscale image; padding adds one leading row and one leading column. |
| **3-D hypermatrix** | 3-D padded hypermatrix | Multi-channel image or volume; padding adds one leading row, one leading column, and one leading depth-slice. |

---

## Calling Sequence

```scilab
J = integralImage3(I)
```

---

## Input Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `I` | numeric or logical matrix / hypermatrix | — | Input image. Any numeric Scilab type is accepted; it is cast to `double` internally. Logical matrices are converted via `bool2s`. 2-D and 3-D inputs are supported. |

---

## Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `J` | double matrix / hypermatrix | Integral image padded with leading zeros. For 2-D input, a row and column of zeros are prepended. For 3-D input, a row, column, and depth-slice of zeros are prepended. |

---

## Complexity

| Stage | Complexity |
|-------|-----------|
| 2-D (R × C) | O(R · C) |
| 3-D (R × C × F) | O(R · C · F) |

---

## Display Helper

> **Note on Scilab `disp` behaviour:**  
> When displaying a hypermatrix, Scilab's built-in `disp` may suppress all-zero layers or omit slice headers (`(:,:,k)`) when the array has only two depth layers. To guarantee that **every** layer is printed with its index header — including zero-padded layers — use the helper below.

### `disp_all_layers` — Explicit layer-by-layer display

Place this function in your workspace or at the bottom of `integralImage3.sci`:

```scilab
function disp_all_layers(J)
    // Get dimensions and number of dimensions
    sz = size(J);
    nd = length(sz);

    // 2-D case: print directly
    if (nd <= 2) then
        disp(J);
        return;
    end

    // 3-D case: print each layer with its (:,:,:) header
    layers = sz(3);
    for k = 1:layers
        printf("(:,:,%d)\n\n", k);
        disp(J(:,:,k));
    end
endfunction
```

**Usage in test scripts:**

```scilab
J = integralImage3(I);
disp_all_layers(J);
```

---

## Test Cases with Expected Outputs

---

### Test 1 — Basic 2×2 Grayscale Image

```scilab
I1 = [1 2; 3 4];
disp("Test 1: Basic 2x2 grayscale");
disp(integralImage3(I1));
```

**Expected output:**

```
   0.   0.   0. 
   0.   1.   3. 
   0.   4.   10.
```

**Explanation:**  
- (1,1) → 1  
- (1,2) → 1+2 = 3  
- (2,1) → 1+3 = 4  
- (2,2) → 1+2+3+4 = 10  

---

### Test 2 — 3-D RGB-like Image (2×2×3)

```scilab
I2 = zeros(2,2,3);
I2(:,:,1) = [1 2; 3 4];
I2(:,:,2) = [5 6; 7 8];
I2(:,:,3) = [9 10; 11 12];
disp("Test 2: 3D RGB-like 2x2x3");
disp(integralImage3(I2));
```

**Expected output:**

```
(:,:,1)

   0.   0.   0.
   0.   0.   0.
   0.   0.   0.

(:,:,2)

   0.   0.   0. 
   0.   1.   3. 
   0.   4.   10.

(:,:,3)

   0.   0.    0. 
   0.   6.    14.
   0.   16.   36.

(:,:,4)

   0.   0.    0. 
   0.   15.   33.
   0.   36.   78.
```

**Explanation:**  
Layer 1 is the zero-padded pre-slice. Each subsequent layer holds the cumulative sum of all pixels up to that depth. Layer 2 = raw first slice, Layer 3 = first+second slice, Layer 4 = first+second+third slice.

---

### Test 3 — Single Pixel Image

```scilab
I3 = [42];
disp("Test 3: Single pixel");
disp(integralImage3(I3));
```

**Expected output:**

```
   0.   0. 
   0.   42.
```

**Explanation:** A 1×1 input becomes a 2×2 padded integral image. The only non-zero sum is the single input pixel itself.

---

### Test 4 — Row Vector (1×4)

```scilab
I4 = [1 2 3 4];
disp("Test 4: Row vector 1x4");
disp(integralImage3(I4));
```

**Expected output:**

```
   0.   0.   0.   0.    0. 
   0.   1.   4.   10.   20.
```

**Explanation:** Cumulative sums along the row: 1, 1+2=3, 1+2+3=6, 1+2+3+4=10. With the leading zero column: 0, 1, 4, 10, 20.

---

### Test 5 — Column Vector (4×1)

```scilab
I5 = [1; 2; 3; 4];
disp("Test 5: Column vector 4x1");
disp(integralImage3(I5));
```

**Expected output:**

```
   0.   0. 
   0.   1. 
   0.   3. 
   0.   6. 
   0.   10.
```

**Explanation:** Cumulative sums down the column: 1, 3, 6, 10. With the leading zero row prepended.

---

### Test 6 — 3×3 with Zeros and Negatives

```scilab
I6 = [0 -1 2; 3 0 -4; 5 6 0];
disp("Test 6: 3x3 with zeros and negatives");
disp(integralImage3(I6));
```

**Expected output:**

```
   0.   0.   0.    0. 
   0.   0.  -1.    1. 
   0.   3.   2.    0. 
   0.   8.   13.   11.
```

**Explanation:** Verifies correct handling of signed values and zero entries in the cumulative sum.

---

### Test 7 — Logical 3×3 Input

```scilab
I7 = [%T %F %T; %F %T %F; %T %T %T];
disp("Test 7: Logical 3x3 input");
disp(integralImage3(I7));
```

**Expected output:**

```
   0.   0.   0.   0.
   0.   1.   1.   2.
   0.   1.   2.   3.
   0.   2.   4.   6.
```

**Explanation:** Logical `%T` is converted to `1.0` and `%F` to `0.0` before accumulation. The bottom-right corner sums all six `true` pixels.

---

### Test 8 — Integer Input (`int8`)

```scilab
I8 = int8([1 2 3; 4 5 6]);
disp("Test 8: int8 2x3 input");
disp(integralImage3(I8));
```

**Expected output:**

```
   0.   0.   0.    0. 
   0.   1.   3.    6. 
   0.   5.   12.   21.
```

**Explanation:** Input is automatically promoted to `double` before accumulation, preventing `int8` overflow. The bottom-right value is the sum of all six integers: 21.

---

### Test 9 — Multi-Frame 3-D (2×3×4)

```scilab
I9 = matrix(1:24, 2, 3, 4);
disp("Test 9: Multi-frame 2x3x4");
disp(integralImage3(I9));
```

**Expected output:**

```
(:,:,1)

   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.

(:,:,2)

   0.   0.   0.    0. 
   0.   1.   4.    9. 
   0.   3.   10.   21.

(:,:,3)

   0.   0.    0.    0. 
   0.   8.    20.   36.
   0.   18.   44.   78.

(:,:,4)

   0.   0.    0.     0.  
   0.   21.   48.    81. 
   0.   45.   102.   171.

(:,:,5)

   0.   0.    0.     0.  
   0.   40.   88.    144.
   0.   84.   184.   300.
```

**Explanation:** Four 2×3 frames are stacked in depth. The output has five depth slices: one zero-padded pre-slice followed by the cumulative integral images across all four frames.

---

### Test 10 — Larger 2-D Floating Point

```scilab
I10 = [0.5 1.5 2.5; 3.5 4.5 5.5; 6.5 7.5 8.5; 9.5 10.5 11.5];
disp("Test 10: 4x3 floating point");
disp(integralImage3(I10));
```

**Expected output:**

```
   0.   0.     0.    0.  
   0.   0.5    2.    4.5 
   0.   4.     10.   18. 
   0.   10.5   24.   40.5
   0.   20.    44.   72. 
```

**Explanation:** Verifies floating-point precision on a 4×3 matrix. The bottom-right corner is the sum of all twelve elements: 72.0.

---

## Error Handling

| Error Condition | Trigger | Message |
|-----------------|---------|---------|
| Argument count | `integralImage3()` | `integralImage3: incorrect number of arguments` |
| Non-image input | `integralImage3("text")` | `integralImage3: I should be an image` |
| >3 dimensions | `integralImage3(rand(2,2,2,2))` | `integralImage3: I should be a 3-dimensional image` |

---



---

### How to use the display helper

If you want **every** layer explicitly labeled (especially useful when Scilab suppresses headers on small hypermatrices), replace:

```scilab
disp(integralImage3(I));
```

with:

```scilab
disp_all_layers(integralImage3(I));
```

