
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

## Dependencies
## padarray()



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
  "Test 1: Basic 2x2 grayscale"
(:,:,1)

   0.   0.   0.
   0.   0.   0.
   0.   0.   0.
(:,:,2)

   0.   0.   0. 
   0.   1.   3. 
   0.   4.   10.
```

  

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



---

### Test 3 — Single Pixel Image

```scilab
I3 = [42];
disp("Test 3: Single pixel");
disp(integralImage3(I3));
```

**Expected output:**

```
(:,:,1)

   0.   0.
   0.   0.
(:,:,2)

   0.   0. 
   0.   42.
```



---

### Test 4 —zero matrix

```scilab
I4 = zeros(2, 2, 2);
disp("Test 4: All-zero 3D matrix (2x2x2)");
disp(integralImage3(I4));
```

**Expected output:**

```
(:,:,1)

   0.   0.   0.
   0.   0.   0.
   0.   0.   0.
(:,:,2)

   0.   0.   0.
   0.   0.   0.
   0.   0.   0.
(:,:,3)

   0.   0.   0.
   0.   0.   0.
   0.   0.   0.
```

---

### Test 5 — Column Vector (4×1)

```scilab
I5 = [1; 2; 3; 4];
disp("Test 5: Column vector 4x1");
disp(integralImage3(I5));
```

**Expected output:**

```
(:,:,1)

   0.   0.
   0.   0.
   0.   0.
   0.   0.
   0.   0.
(:,:,2)

   0.   0. 
   0.   1. 
   0.   3. 
   0.   6. 
   0.   10.
```


---

### Test 6 — 3×3 with Zeros and Negatives

```scilab
I6 = [0 -1 2; 3 0 -4; 5 6 0];
disp("Test 6: 3x3 with zeros and negatives");
disp(integralImage3(I6));
```

**Expected output:**

```
(:,:,1)

   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
(:,:,2)

   0.   0.   0.    0. 
   0.   0.  -1.    1. 
   0.   3.   2.    0. 
   0.   8.   13.   11.
```

---

### Test 7 — Logical 3×3 Input

```scilab
I7 = [%T %F %T; %F %T %F; %T %T %T];
disp("Test 7: Logical 3x3 input");
disp(integralImage3(I7));
```

**Expected output:**

```
(:,:,1)

   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
(:,:,2)

   0.   0.   0.   0.
   0.   1.   1.   2.
   0.   1.   2.   3.
   0.   2.   4.   6.
```


---

### Test 8 — Integer Input (`int8`)

```scilab
I8 = int8([1 2 3; 4 5 6]);
disp("Test 8: int8 2x3 input");
disp(integralImage3(I8));
```

**Expected output:**

```
  "Test 8: int8 2x3 input"
(:,:,1)

   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
(:,:,2)

   0.   0.   0.    0. 
   0.   1.   3.    6. 
   0.   5.   12.   21.
```


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


---

### Test 10 — Larger 2-D Floating Point

```scilab
I10 = [0.5 1.5 2.5; 3.5 4.5 5.5; 6.5 7.5 8.5; 9.5 10.5 11.5];
disp("Test 10: 4x3 floating point");
disp(integralImage3(I10));
```

**Expected output:**

```
(:,:,1)

   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
   0.   0.   0.   0.
(:,:,2)

   0.   0.     0.    0.  
   0.   0.5    2.    4.5 
   0.   4.     10.   18. 
   0.   10.5   24.   40.5
   0.   20.    44.   72.
```


---

## Error Handling

| Error Condition | Trigger | Message |
|-----------------|---------|---------|
| Argument count | `integralImage3()` | `integralImage3: incorrect number of arguments` |
| Non-image input | `integralImage3("text")` | `integralImage3: I should be an image` |
| >3 dimensions | `integralImage3(rand(2,2,2,2))` | `integralImage3: I should be a 3-dimensional image` |

---


