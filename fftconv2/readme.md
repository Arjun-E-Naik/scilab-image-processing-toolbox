# `fftconv2.sci`

---

## Overview

`fftconv2` performs **2-D convolution** using the Fast Fourier Transform (FFT). The convolution is computed in the frequency domain, which is significantly faster than spatial convolution for large kernels.

The function supports:

- **Standard convolution** of two 2‑D arrays (`a` and `b`).
- **Separable convolution** using two vectors (`v1`, `v2`) and an image `a` – equivalent to convolving with the outer product `v1 * v2`.
- Different output shapes: `"full"` (default), `"same"`, and `"valid"`.

This is a building block for filtering, edge detection, and other image processing tasks where large kernels are involved.

---

## Calling Sequence

```scilab
X = fftconv2(a, b)
X = fftconv2(a, b, shape)
X = fftconv2(v1, v2, a)
X = fftconv2(v1, v2, a, shape)
```

---

## Input Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `a`, `b` | numeric or logical matrices | — | The two matrices to convolve. |
| `v1`, `v2` | numeric vectors | — | For separable convolution: `v1` is a column vector, `v2` is a row vector. The convolution is performed with the matrix `a` and the outer product `v1 * v2`. |
| `shape` | string | `"full"` | Output size: `"full"` (full convolution), `"same"` (same size as `a`), `"valid"` (only pixels where kernels fully overlap). |



---

## Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `X` | double matrix | The convolution result. The size depends on `shape` and the input dimensions. |

---

## Complexity

| Stage | Complexity |
|-------|------------|
| FFT of padded arrays | O(R·C·log(R·C)) |
| Element‑wise multiplication | O(R·C) |
| Inverse FFT | O(R·C·log(R·C)) |
| **Total** | O(R·C·log(R·C)) |

where `R` and `C` are the padded dimensions: `R = ra + rb - 1`, `C = ca + cb - 1`.

For large kernels, this is much faster than the O(R·C·K) of spatial convolution (K = kernel size).

---

## Dependencies

- **`fft2`, `ifft2`** – 2‑D FFT and inverse FFT (implemented using 1‑D FFT along rows and columns).
- **`padarray`** – supports zero padding with `"post"` mode (only constant padding is used in this function). The implementation also includes other padding methods (`symmetric`, `replicate`, `circular`).
- **`vec`** – reshapes a matrix into a column vector .
- Helper functions: `isnumeric`, `islogical`, `isscalar`, `convstr`.

---

## Test Cases with Expected Outputs

The following test cases verify the correctness of `fftconv2`. Each test prints the resulting size and matrix.

### Test 1 – 2×2 with 2×2, `"full"`

```scilab
a = [1 2; 3 4];
b = [1 0; 0 1];
result = fftconv2(a, b, "full");
disp(result);
```
*Output size:* `3x3`
```
   1.   2.   0.
   3.   5.   2.
   0.   3.   4.
```
---

### Test 2 – 2×3 with 3×2, `"full"`

```scilab
a = [1 2 3; 4 5 6];
b = [1 1; 1 1; 1 1];
result = fftconv2(a, b, "full");
disp(result);
```
*Output size:* `4x4`
```
   1.   3.    5.    3.
   5.   12.   16.   9.
   5.   12.   16.   9.
   4.   9.    11.   6.
```
---

### Test 3 – 3×3 identity with 3×3 all‑ones, `"same"`

```scilab
a = eye(3,3);
b = ones(3,3);
result = fftconv2(a, b, "same");
disp(result);
```
*Output size:* `3x3`
```
   2.   2.   1.
   2.   3.   2.
   1.   2.   2.
  
```
---

### Test 4 – 3×3 with 2×2, `"valid"`

```scilab
a = [1 2 3; 4 5 6; 7 8 9];
b = [1 0; 0 1];
result = fftconv2(a, b, "valid");
disp(result);
```
*Output size:* `2x2`
```
   6.    8.
   12.   14.
```
---

### Test 5 – 2×2 with 2×2, `"same"`

```scilab
a = [2 3; 4 5];
b = [1 2; 3 4];
result = fftconv2(a, b, "same");
disp(result);
```
*Output size:* `2x2`
```
   30.   22.
   31.   20.
```
---

### Test 6 – 1×4 row with 4×1 column, `"full"`

```scilab
a = [1 2 3 4];
b = [1; 2; 3; 4];
result = fftconv2(a, b, "full");
disp(result);
```
*Output size:* `4x4`
```
   1.   2.   3.    4. 
   2.   4.   6.    8. 
   3.   6.   9.    12.
   4.   8.   12.   16.
```
---

### Test 7 – 4×1 column with 1×4 row, `"full"`

```scilab
a = [1; 2; 3; 4];
b = [1 2 3 4];
result = fftconv2(a, b, "full");
disp(result);
```
*Output size:* `4x4`
```
   1.   2.   3.    4. 
   2.   4.   6.    8. 
   3.   6.   9.    12.
   4.   8.   12.   16.
```
---

### Test 8 – 2×3 with 2×3, `"valid"`

```scilab
a = [1 2 3; 4 5 6];
b = [1 0 1; 0 1 0];
result = fftconv2(a, b, "valid");
disp(result);
```
*Output size:* `1x1`
```
12
```
---

### Test 9 – 1×1 with 3×3, `"full"`

```scilab
a = [5];
b = [1 2 3; 4 5 6; 7 8 9];
result = fftconv2(a, b, "full");
disp(result);
```
*Output size:* `3x3`
```
   5.    10.   15.
   20.   25.   30.
   35.   40.   45.
```
---



### Test 10 – 3×3 with 1×1, `"same"`

```scilab
a = [1 2 3; 4 5 6; 7 8 9];
b = [3];
result = fftconv2(a, b, "same");
disp(result);
```
*Output :* 
```
    3.    6.    9. 
   12.   15.   18.
   21.   24.   27.
```

---
### Test 11 – Error detection

```scilab
disp("Error Test 1: Less than 2 input arguments");
try
    result_err = fftconv2([1, 2]);
    disp("ERROR: Should have thrown an error!");
catch
    disp("Caught expected error: " + lasterror());
end
```
*Output :* 
```
"Error Test 1: Less than 2 input arguments"
  "Caught expected error: fftconv2: usage: fftconv2(a, b[, shape]) or fftconv2(v1, v2, a[, shape])"

```

---
### Test 12 – Error detection

```scilab
disp("Error Test 2: Invalid shape parameter");
try
    a = ones(5, 5);
    b = ones(3, 3);
    result_err = fftconv2(a, b, "invalid_shape");
    disp("ERROR: Should have thrown an error!");
catch
    disp("Caught expected error: " + lasterror());
end
```
*Output :* 
```
  "Error Test 2: Invalid shape parameter"
  "Caught expected error: fftconv2: unknown convolution SHAPE invalid_shape"

```

---
### Test 12 – Error detection

```scilab
disp("Error Test 3: Non-numeric third argument in 3-argument form");
try
    x = 1:4;
    y = 4:-1:1;
    a = "not_a_matrix";
    result_err = fftconv2(x, y, a);
    disp("ERROR: Should have thrown an error!");
catch
    disp("Caught expected error: " + lasterror());
end
```
*Output :* 
```
  "Error Test 3: Non-numeric third argument in 3-argument form"
  "Caught expected error: fftw: Wrong values for input argument #3: Elements must be greater than 1."

```

---