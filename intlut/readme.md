
---

# intlut.sci

## Overview

**intlut** (Integer Lookup Table) substitutes integer values in an array or image matrix with new values mapped out of a predefined lookup table (`LUT`). This process operates efficiently by treating pixel values directly as positional array indexes.


---

## Syntax

```scilab
B = intlut(A, LUT)

```

**Converts matrix integer values using a lookup table.**

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `A` | `uint8`, `uint16`, or `int16` array (any shape) | The input data array or image matrix containing values to be replaced. |
| `LUT` | vector array of matching type (`A`) | The lookup translation mapping table. Must match the exact required element count for the respective class. |

### Required Table Lengths

| Class Type | Required `LUT` Elements | Coordinate Mapping Range |
| --- | --- | --- |
| `uint8` | **256** | `0` to `255` |
| `uint16` | **65536** | `0` to `65535` |
| `int16` | **65536** | `-32768` to `32767` |

### Return Value

| Variable | Type | Description |
| --- | --- | --- |
| `B` | array matching shape of `A` | Transformed output matrix. Extracted matching elements are of the exact same data class type as `LUT`. |

---



## Test Cases with Expected Outputs

### Test 1 — Basic uint8 Inversion Vector

```scilab
A = uint8([1, 2, 3, 4]);
LUT = uint8(255:-1:0);
B = intlut(A, LUT)

```

**Expected Console Output:**

```text
Output Type: uint8
Output Dimensions: [1 4]
Values:
  254  253  252  251

```

---

### Test 2 — Basic uint16 Inversion Vector

```scilab
A = uint16([1, 2, 3, 4]);
LUT = uint16(65535:-1:0);
B = intlut(A, LUT)

```

**Expected Console Output:**

```text
Output Type: uint16
Output Dimensions: [1 4]
Values:
  65534  65533  65532  65531

```

---

### Test 3 — Basic int16 Negative-to-Positive Vector

```scilab
A = int16([1, 2, 3, 4]);
LUT = int16(32767:-1:-32768);
B = intlut(A, LUT)

```

**Expected Console Output:**

```text
Output Type: int16
Output Dimensions: [1 4]
Values:
  -2  -3  -4  -5

```

---

### Test 4 — 2D Matrix Identity Mapping (uint8)

```scilab
A = uint8([0, 100; 200, 255]);
LUT = uint8(0:255);
B = intlut(A, LUT)

```

**Expected Console Output:**

```text
Output Type: uint8
Output Dimensions: [2 2]
Values:
    0  100
  200  255

```

---

### Test 5 — uint8 Bound Caps Mapping

```scilab
A = uint8([0, 255]);
LUT = uint8(ones(1, 256) * 42);
B = intlut(A, LUT)

```

**Expected Console Output:**

```text
Output Type: uint8
Output Dimensions: [1 2]
Values:
  42  42

```

---

### Test 6 — int16 Extreme Extrema Values Identity Mapping

```scilab
A = int16([-32768, 32767]);
LUT = int16(-32768:32767);
B = intlut(A, LUT)

```

**Expected Console Output:**

```text
Output Type: int16
Output Dimensions: [1 2]
Values:
  -32768  32767

```

---

### Test 7 — 3D Hypermatrix Mapping (uint8)

```scilab
A = uint8(zeros(2, 2, 2));
A(1,1,1) = 0; A(2,2,2) = 255;
LUT = uint8(255:-1:0);
B = intlut(A, LUT)

```

**Expected Console Output:**

```text
Output Type: uint8
Output Dimensions: [2 2 2]
Values:
ans(:,:,1) =

  255  255
  255  255

ans(:,:,2) =

  255  255
  255    0

```

---

### Test 8 — Class Mismatch Error Catching

```scilab
// Attempting to cross-map an input matrix with a mismatched lookup table type
intlut(uint16([1, 2]), uint8(0:255));

```

**Expected Console Output:**

```text
Result: Passed (Caught mismatch error cleanly)

```

---

### Test 9 — Invalid LUT Length Catching

```scilab
// Passing a lookup table that does not contain the required number of indexing bins
intlut(uint8([1, 2]), uint8(0:10));

```

**Expected Console Output:**

```text
Result: Passed (Caught invalid size error cleanly)

```

---

### Test 10 — Non-Vector Dimension Table Check

```scilab
// Passing a square multi-dimensional 2-D matrix instead of a 1-D lookup vector
intlut(uint8(56), uint8(zeros(16, 16)));

```

**Expected Console Output:**

```text
Result: Passed (Caught 2D matrix restriction error cleanly)

```

---

## References

[1] GNU Octave Image Package Source Library Documentation (`intlut`)

[2] MATLAB Image Processing Toolbox Reference Guide (`intlut`)