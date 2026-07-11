
# `integralImage` — Integral Image (Summed-Area Table) 

---

## Overview

`integralImage` calculates the **integral image** (also known as the *summed-area table*) of an input image. This is a fundamental building block for fast box filtering, Haar-like feature extraction, and object detection (e.g. Viola–Jones).

Two orientations are supported:

| Orientation | Description |
|-------------|-------------|
| **Upright** *(default)* | Standard summed-area table: each pixel holds the sum of all pixels above and to the left, inclusive. |
| **Rotated** *(RSAT)* | 45° rotated summed-area table used for tilted Haar features. |

The output is always of type `double` and is padded with a leading row and column of zeros so that rectangular sum queries never need boundary checks.

---

## Calling Sequence

```scilab
J = integralImage(I)
J = integralImage(I, orientation)
```

---

## Input Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `I` | numeric or logical matrix / hypermatrix | — | Input image. Any numeric Scilab type is accepted; it is cast to `double` internally. RGB or multi-channel images are treated plane-by-plane. |
| `orientation` | string | `"upright"` | Orientation of the integral image. Must be `"upright"` or `"rotated"`. |

---

## Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `J` | double matrix / hypermatrix | Integral image padded with a leading zero row and column (upright) or leading zero row and two extra columns (rotated). |

---



## Complexity

| Stage | Complexity |
|-------|-----------|
| Upright (2-D) | O(R · C) |
| Upright (N-D, P planes) | O(P · R · C) |
| Rotated (2-D) | O(R · C) |
| Rotated (N-D, P planes) | O(P · R · C) |

---

## Test Cases with Expected Outputs

### Test 1 — Scalar Value (Upright)

```scilab
I1 = 10;
J = integralImage(I1);
```

**Expected output:**
```
    0    0
    0   10
```

**Explanation:** A 1×1 input becomes a 2×2 padded integral image. The only non-zero sum is the single input pixel itself.

---

### Test 2 — Scalar Value (Rotated)

```scilab
I1 = 10;
J = integralImage(I1, "rotated");
```

**Expected output:**
```
    0    0    0
    0   10    0
```

**Explanation:** Rotated RSAT for a single pixel produces a 2×3 padded matrix with the pixel value at the centre of the second row.

---

### Test 3 — 2×2 Matrix (Upright)

```scilab
I3 = [1, 2; 3, 4];
J = integralImage(I3, "upright");
```

**Expected output:**
```
    0    0    0
    0    1    3
    0    4   10
```

**Explanation:**  
- (1,1) → 1  
- (1,2) → 1+2 = 3  
- (2,1) → 1+3 = 4  
- (2,2) → 1+2+3+4 = 10

---

### Test 4 — 2×2 Matrix (Rotated)

```scilab
I3 = [1, 2; 3, 4];
J = integralImage(I3, "rotated");
```

**Expected output:**
```
   0   0   0   0
   0   1   2   0
   1   6   7   2
```

**Explanation:** The 45° RSAT accumulates diamond-shaped neighbourhoods. The bottom-right corner aggregates the full 2×2 block plus padding reflections.

---

### Test 5 — Default Orientation Parameter Omission

```scilab
I5 = [5, 5; 5, 5];
J = integralImage(I5);
```

**Expected output:**
```
    0    0    0
    0    5   10
    0   10   20
```

**Explanation:** When the second argument is omitted, the function defaults to `"upright"`. A uniform 5-image yields cumulative sums 5, 10, 10, 20.

---

### Test 6 — Type Casting from `uint8` Matrix

```scilab
I6 = uint8([10, 20; 30, 40]);
disp(typeof(I6));   // → uint8
J = integralImage(I6);
disp(typeof(J));    // → double
```

**Expected output:**
```
     0     0     0
     0    10    30
     0    40   100
```

**Explanation:** Input is automatically promoted to `double` before accumulation, preventing overflow of 8-bit unsigned integers.

---

### Test 7 — 3D Hypermatrix Channel Stack (Upright)

```scilab
I7 = zeros(2, 2, 2);
I7(:,:,1) = [1, 2; 3, 4];
I7(:,:,2) = [5, 6; 7, 8];
J = integralImage(I7, "upright");
```

**Expected output — Layer 1:**
```
    0    0    0
    0    1    3
    0    4   10
```

**Expected output — Layer 2:**
```
    0    0    0
    0    5   11
    0   12   26
```

**Explanation:** Each 2-D plane is processed independently. The hypermatrix shape is preserved in the output.

---

### Test 8 — 3D Hypermatrix Channel Stack (Rotated)

```scilab
J = integralImage(I7, "rotated");
```

**Expected output — Layer 1:**
```
   0   0   0   0
   0   1   2   0
   1   6   7   2
```

**Expected output — Layer 2:**
```
    0    0    0    0
    0    5    6    0
    5   18   19    6
```

**Explanation:** Rotated RSAT is applied plane-by-plane. The third dimension (channels) is never mixed.

---

### Test 9 — Error Handling (Argument Count Mismatch)

```scilab
try
    integralImage();
catch
    disp("Caught Expected Error: Empty inputs triggered error handler successfully.");
end
```

**Expected console output:**
```
Caught Expected Error: Empty inputs triggered error handler successfully.
```

**Explanation:** The function requires at least one input. Calling it with zero arguments raises a usage error.

---

### Test 10 — Error Handling (Image Matrix Validation)

```scilab
try
    integralImage("InvalidStringImageInput");
catch
    disp("Caught Expected Error: Non-numeric string matrix safely blocked.");
end
```

**Expected console output:**
```
Caught Expected Error: Non-numeric string matrix safely blocked.
```

**Explanation:** String inputs are rejected by the `isimage` guard, ensuring only numeric or logical arrays are processed.

---
