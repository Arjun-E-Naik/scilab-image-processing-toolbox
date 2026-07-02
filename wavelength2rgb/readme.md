# `wavelength2rgb.sci`

---

## Overview

`wavelength2rgb` converts one or more **visible light wavelengths** (measured in nanometers) into their corresponding **RGB colour representation**.

The implementation approximates the human perception of visible light in the wavelength range **380 nm – 780 nm**, including:

- Piecewise linear conversion from wavelength to RGB channels.
- Intensity falloff near the limits of human vision.
- Gamma correction for perceptual brightness.
- Multiple output data types (`double`, `single`, `uint8`, `uint16`, `int16`).
- Support for scalars, vectors, matrices, and N-dimensional arrays.

Wavelengths outside the visible spectrum are mapped to **black**.

---

## Calling Sequence

```scilab
rgb = wavelength2rgb(wavelength)
rgb = wavelength2rgb(wavelength, out_class)
rgb = wavelength2rgb(wavelength, out_class, gamma)
```

---

## Input Parameters

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `wavelength` | Numeric array | — | Wavelength(s) in nanometers. Values must be positive. Any array dimension is supported. |
| `out_class` | String | `"double"` | Output datatype. Supported values are `"double"`, `"single"`, `"uint8"`, `"uint16"`, and `"int16"`. |
| `gamma` | Scalar numeric | `0.8` | Gamma correction factor. Must satisfy `0 ≤ gamma ≤ 1`. |

---

## Return Value

| Variable | Type | Description |
|----------|------|-------------|
| `rgb` | Numeric array | RGB representation of the input wavelengths. The output preserves the input dimensions with an additional third dimension of size 3 corresponding to Red, Green, and Blue channels. |

---

## Output Shape

| Input | Output |
|-------|--------|
| Scalar | `1 × 3` RGB vector |
| Vector | `1 × N × 3` hypermatrix |
| Matrix | `M × N × 3` hypermatrix |
| N-dimensional array | Same dimensions with an additional RGB dimension |

---

## Supported Output Classes

| Class | Description |
|-------|-------------|
| `double` | Floating-point RGB values in `[0,1]` |
| `single` | Single precision floating-point values |
| `uint8` | Integer RGB values in `[0,255]` |
| `uint16` | Integer RGB values in `[0,65535]` |
| `int16` | Signed 16-bit RGB values |



---

## Dependencies

- `im2single`
- `im2uint8`
- `im2uint16`
- `im2int16`
- `imcast`

---

## Complexity

Let **N** be the number of wavelength values.

| Stage | Complexity |
|-------|------------|
| Piecewise colour computation | O(N) |
| Intensity adjustment | O(N) |
| Gamma correction | O(N) |
| Output conversion | O(N) |
| **Total** | **O(N)** |

---

# Test Cases with Expected Outputs

---

## Test 1 — Standard 1D Array

```scilab
rgb = wavelength2rgb([400,410]);
disp(rgb);
```

**Expected output**

```
(:,:,1)

   0.5122214   0.4924239
(:,:,2)

   0.   0.
(:,:,3)

   0.708485   0.8573599
```

---

## Test 2 — Scalar Wavelength (Default Arguments)

```scilab
rgb = wavelength2rgb(400);
disp(rgb);
```

**Expected output**

```
   0.5122214   0.   0.708485
```

---

## Test 3 — Wavelength Outside Visible Range

```scilab
rgb = wavelength2rgb(300);
disp(rgb);
```

**Expected output**

```
0.   0.   0.
```

(Black)

---

## Test 4 — Matrix Input

```scilab
rgb = wavelength2rgb([400 450;
                      500 550]);
disp(rgb);
```

**Expected output**

```
(:,:,1)

   0.5122214   0.       
   0.          0.6391011
(:,:,2)

   0.   0.2759459
   1.   1.       
(:,:,3)

   0.708485    1.
   0.5743492   0.
```
---

## Test 5 — Upper Visible Limit

```scilab
rgb = wavelength2rgb(750);
disp(rgb);
```

**Expected output**

```
   0.6310998   0.   0.
```

---

## Test 6 — Output Class `uint8`

```scilab
rgb = wavelength2rgb(400,"uint8");
disp(rgb);
```

**Expected output**

```
  131  0  181
```

---

## Test 7 — Output Class `uint16`

```scilab
rgb = wavelength2rgb(500,"uint16");
disp(rgb);
```

**Expected output**

```
  0  65535  37640
```

---

## Test 8 — Output Class `single`

```scilab
rgb = wavelength2rgb(600,"single");
disp(rgb);
```

**Expected output**

```
 1.   0.7451425   0.
```

---

## Test 9 — Custom Gamma

```scilab
rgb = wavelength2rgb(450,"double",0.5);
disp(rgb);
```

**Expected output**

```
   0.   0.4472136   1.
```

---

## Test 10 — Vector with Custom Class and Gamma

```scilab
rgb = wavelength2rgb([380 500 700],"int16",1.0);
disp(rgb);
```

**Expected output**

```
(:,:,1)

 -13108 -32768  32767
(:,:,2)

 -32768  32767 -32768
(:,:,3)

 -13108 -1 -32768
```

---

# Error Handling Tests

---

## Error Test 1 — Negative Wavelength

```scilab
wavelength2rgb([-400,500])
```

**Expected**

```
wavelength2rgb: wavelength must be a positive numeric
```

---

## Error Test 2 — Unsupported Output Class

```scilab
wavelength2rgb(450,"float64")
```

**Expected**

```
wavelength2rgb: unsupported class `float64`
```

---

## Error Test 3 — Invalid Gamma

```scilab
wavelength2rgb(500,"double",1.5)
```

**Expected**

```
wavelength2rgb: gamma must be a numeric scalar between 1 and 0
```

---



---
