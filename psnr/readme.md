# PSNR (Peak Signal-to-Noise Ratio) Implementation in Scilab

 **Peak Signal-to-Noise Ratio (PSNR)** for evaluating image quality by comparing an input image against a reference image.

This implementation supports:

- Grayscale and RGB images
- `uint8`, `uint16`, and floating-point images
- Automatic peak-value detection
- Manual peak override
- Mean Squared Error (MSE) output
- Error handling for invalid inputs

---

## Overview

Peak Signal-to-Noise Ratio (**PSNR**) is  used image quality metrics in image processing.

It measures how similar a processed image is to a reference image.

Applications include:

- Image compression evaluation
- Image denoising assessment
- Super-resolution validation
- Image restoration performance
- Medical image quality analysis

A larger PSNR value generally indicates better image quality.

Typical interpretation:

 PSNR (dB) --> Quality 

- more than 50 --> Nearly identical 
- 40–50 --> Excellent 
- 30–40 --> Good 
- 20–30 --> Noticeable degradation 
- <20 --> Poor quality 

---

# Mathematical Background

PSNR is computed using the Mean Squared Error (MSE).

### Step 1: Compute Mean Squared Error

$$
\text{MSE} = \frac{1}{MN} \sum_{i=1}^{M} \sum_{j=1}^{N} (I(i,j) - K(i,j))^2
$$


Where:

- \(I\) = original/reference image
- \(K\) = processed image
- \(M,N\) = image dimensions

For RGB images:

$$
\text{MSE} = \frac{\text{MSE}_R + \text{MSE}_G + \text{MSE}_B}{3}
$$


---

### Step 2: Compute PSNR

\[
PSNR=10\log_{10}\left(\frac{MAX^2}{MSE}\right)
\]

Where:

- \(MAX\) = maximum possible pixel intensity
- For uint8:

\[
MAX=255
\]

For normalized double images:

\[
MAX=1
\]

---

## Special Case

If:

\[
MSE=0
\]

then images are identical:

\[
PSNR=\infty
\]

---

# Algorithm

### Input

- Input image `A`
- Reference image `ref`
- Optional peak value

---

### Step 1

Verify:

- Images have same dimensions
- Datatypes are supported

---

### Step 2

Convert image to floating-point for computation

```scilab
A = double(A)
ref = double(ref)
```

### Step 3

Compute pixel differences

```scilab

err = (A - ref).^2
```
### Step 4

Compute MSE:

For RGB:
    Avg channel wise Mse

For gray scale:
    direct mse computation


### Step 5

Determine peak intensity.

Automatic:
- unit8 --> 255
- unit16 --> 65535
- float --> 1

### Step 6

Compute PSNR

```scilab
    PSNR = 10*log10((peak^2)/mse)
```
