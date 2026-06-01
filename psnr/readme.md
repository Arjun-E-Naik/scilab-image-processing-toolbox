# `psnr.sci` — Peak Signal-to-Noise Ratio 



---

## Overview

**Peak Signal-to-Noise Ratio (PSNR)** is the most widely used objective metric
for measuring the quality of a reconstructed or compressed image relative to a
lossless reference. It is expressed in **decibels (dB)** — the higher the value,
the more faithful the reconstruction.

Typical PSNR ranges for lossy image compression (8-bit images):

| Quality | PSNR range |
|---------|-----------|
| Excellent | > 40 dB |
| Good | 30 – 40 dB |
| Acceptable | 20 – 30 dB |
| Poor | < 20 dB |

---


### `psnr(A, ref[, peak])`

```scilab
peaksnr          = psnr(A, ref)
peaksnr          = psnr(A, ref, peak)
[peaksnr, snr]   = psnr(A, ref)
[peaksnr, snr]   = psnr(A, ref, peak)
```

Computes the Peak Signal-to-Noise Ratio of image `A` with respect to the
reference image `ref`.

#### Inputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `A` | numeric matrix | Degraded / test image. May be `uint8`, `uint16`, `int8`, `int16`, `int32`, `uint32`, or `double`. |
| `ref` | numeric matrix | Reference (original) image. Must be the **same size and class** as `A`. |
| `peak` | scalar (optional) | Maximum possible signal value. Defaults to the upper bound of the class range (e.g. 255 for `uint8`, 1.0 for `double`). |

#### Outputs

| Parameter | Type | Description |
|-----------|------|-------------|
| `peaksnr` | double scalar | PSNR value in dB. Returns `+Inf` when `A == ref` exactly (MSE = 0). |
| `snr` | double scalar | Plain signal-to-noise ratio in dB (only computed when explicitly requested). |

---

### `immse(A, ref)`

```scilab
mse = immse(A, ref)
```

Computes the **Mean Squared Error** between two arrays of the same size.

```
MSE = (1/N) · Σ (A_i − ref_i)²
```

Both inputs are promoted to `double` internally to avoid integer overflow.

---

### `getrangefromclass(A)`

```scilab
[lo, hi] = getrangefromclass(A)
```

Returns the theoretical minimum and maximum value of the numeric type of `A`:

| Scilab type | `lo` | `hi` |
|-------------|------|------|
| `uint8` | 0 | 255 |
| `uint16` | 0 | 65 535 |
| `uint32` | 0 | 4 294 967 295 |
| `int8` | −128 | 127 |
| `int16` | −32 768 | 32 767 |
| `int32` | −2 147 483 648 | 2 147 483 647 |
| `double` / `single` | 0 | 1 |

---

## Variable Glossary

| Variable | Scope | Description |
|----------|-------|-------------|
| `A` | input | Test/degraded image matrix |
| `ref` | input | Reference/ground-truth image matrix |
| `peak` | input / derived | Maximum representable pixel value for the image class |
| `mse` | local | Mean Squared Error between `A` and `ref` |
| `diff` | local (inside `immse`) | Element-wise difference `A − ref` |
| `peaksnr` | output | Peak Signal-to-Noise Ratio in dB |
| `snr` | output (optional) | Signal-to-Noise Ratio in dB |
| `signal_pwr` | local | Average signal power: `sum(A²) / N` |
| `A_vec` | local | Flattened column vector of `A` used for SNR computation |
| `rhs` | local | Number of right-hand-side (input) arguments (`argn(2)`) |
| `lhs` | local | Number of left-hand-side (output) arguments (`argn(1)`) |
| `lo`, `hi` | local (in helper) | Class-range lower and upper bounds |
| `it` | local (in helper) | Integer sub-type code returned by `inttype()` |

---

## Mathematical Definations

### Mean Squared Error (MSE)

Given two images **A** and **ref**, each with *N* pixels:

$$\text{MSE} = \frac{1}{N} \sum_{i=1}^{N} \bigl(A_i - \text{ref}_i\bigr)^2$$

MSE measures the average squared difference between corresponding pixels.
A value of 0 means the images are identical.

### Peak Signal-to-Noise Ratio (PSNR)

$$\text{PSNR} = 10 \cdot \log_{10} \!\left(\frac{\text{peak}^2}{\text{MSE}}\right) \quad [\text{dB}]$$

where **peak** is the maximum possible pixel value for the image data type
(e.g. 255 for 8-bit unsigned integers, 1.0 for normalised floating-point).

Because a **larger** MSE corresponds to a **lower** PSNR, the metric correctly
penalises degraded images.

Special case: if `MSE = 0` (identical images), PSNR → +∞.

### Signal-to-Noise Ratio (SNR)

The plain SNR uses the average power of the **signal** (the reference image `A`)
rather than a fixed peak:

$$\text{SNR} = 10 \cdot \log_{10} \!\left(\frac{P_{\text{signal}}}{\text{MSE}}\right)$$

where the average signal power is:

$$P_{\text{signal}} = \frac{1}{N} \sum_{i=1}^{N} A_i^2$$

---

## Algorithm Explanation

```
psnr(A, ref, peak)
│
├─ 1. Validate inputs
│      • 2 or 3 arguments required
│      • size(A) == size(ref)
│      • type(A) == type(ref)  [and same integer sub-type if applicable]
│      • peak must be scalar if supplied
│
├─ 2. Determine peak
│      • If not supplied → getrangefromclass(A) returns [lo, hi];
│        use hi (upper bound) as peak.
│      • Otherwise use user-supplied scalar.
│
├─ 3. Promote integer arrays to double
│      • Prevents integer overflow during subtraction in immse().
│      • Floating-point arrays pass through unchanged (preserves single
│        precision if inputs were single).
│
├─ 4. Compute MSE via immse(A, ref)
│      diff = A − ref          (element-wise, double)
│      MSE  = sum(diff.²) / N
│
├─ 5. Compute PSNR
│      peaksnr = 10 · log₁₀(peak² / MSE)
│      (Scilab's log10() is used directly)
│
└─ 6. Optionally compute SNR (only when lhs > 1)
       A_vec      = A(:)            ← flatten to column vector
       signal_pwr = (A_vecᵀ · A_vec) / N
       snr        = 10 · log₁₀(signal_pwr / MSE)
```

The conditional computation of SNR (`argn(1) > 1`) mirrors Octave's
`nargout > 1` pattern and avoids unnecessary computation when only `peaksnr`
is needed.

---

## Test Cases 

### Test 1 — Identical images → PSNR = +∞

```scilab
A   = uint8([100 150 200; 50 75 25]);
ref = uint8([100 150 200; 50 75 25]);
p   = psnr(A, ref);
// MSE = 0  →  PSNR = +Inf
```

**Expected output:**
```
peaksnr = +Inf
```

---

### Test 2 — Black vs. white uint8 image → PSNR = 0 dB

```scilab
A   = uint8(zeros(2,2));      // all zeros
ref = uint8(255 * ones(2,2)); // all 255
p   = psnr(A, ref);
```

**Derivation:**
```
MSE  = (255 − 0)² = 65 025
peak = 255  (auto, uint8)
PSNR = 10 · log₁₀(255² / 65 025)
     = 10 · log₁₀(65 025 / 65 025)
     = 10 · log₁₀(1)
     = 0 dB
```

**Expected output:**
```
peaksnr = 0.000000 dB
```

---

### Test 3 — Double [0,1] all-zeros vs. all-ones → PSNR = 0 dB

```scilab
A   = zeros(2,2);
ref = ones(2,2);
p   = psnr(A, ref);
```

**Derivation:**
```
MSE  = (0 − 1)² = 1
peak = 1  (auto, double)
PSNR = 10 · log₁₀(1 / 1) = 0 dB
```

**Expected output:**
```
peaksnr = 0.000000 dB
```

---

### Test 4 — Custom peak value

```scilab
A   = [0];
ref = [128];
p   = psnr(A, ref, 256);
```

**Derivation:**
```
MSE  = (0 − 128)² = 16 384
peak = 256  (user-supplied)
PSNR = 10 · log₁₀(256² / 16 384)
     = 10 · log₁₀(65 536 / 16 384)
     = 10 · log₁₀(4)
     ≈ 6.020600 dB
```

**Expected output:**
```
peaksnr ≈ 6.020600 dB
```

---

### Test 5 — Both outputs: `peaksnr` and `snr`

```scilab
A   = [10 20; 30 40];
ref = [12 18; 32 38];
[p, s] = psnr(A, ref);
```

**Derivation:**
```
diff  = [−2  2; −2  2]
MSE   = (4+4+4+4) / 4 = 4
peak  = 1   (auto, double)

PSNR  = 10 · log₁₀(1² / 4)
      = 10 · log₁₀(0.25)
      ≈ −6.020600 dB

signal_power = (10²+20²+30²+40²) / 4
             = (100+400+900+1600) / 4
             = 750

SNR   = 10 · log₁₀(750 / 4)
      = 10 · log₁₀(187.5)
      ≈ 22.730013 dB
```

**Expected output:**
```
peaksnr ≈ −6.020600 dB
snr     ≈  22.730013 dB
```

---

### Test 6 — uint16 image, automatic peak = 65535

```scilab
A   = uint16([0]);
ref = uint16([32768]);
p   = psnr(A, ref);
```

**Derivation:**
```
MSE  = (0 − 32 768)² = 1 073 741 824
peak = 65 535  (auto, uint16)
PSNR = 10 · log₁₀(65 535² / 32 768²)
     = 10 · log₁₀((65 535 / 32 768)²)
     = 20 · log₁₀(65 535 / 32 768)
     ≈ 6.020452 dB
```

*(Slightly less than 6.0206 dB because 65535 ≠ 2 × 32768 exactly.)*

**Expected output:**
```
peaksnr ≈ 6.020452 dB
```

---

## Running the Tests

Open Scilab, navigate to the folder containing the files, then:

```scilab
exec('psnr.sci', -1);    // load helpers + psnr (suppress echo)
exec('test_psnr.sci');   // run all tests
```



---

