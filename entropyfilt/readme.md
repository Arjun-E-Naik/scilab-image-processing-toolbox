# entropyfilt() - Local Entropy Filter for Scilab 

## Overview

`entropyfilt()` computes local entropy **local entropy** of graysclae image.

Entropy mesures randomness or texture complexity within a local neighborhood around each pixel.

Pixels are located inside highly textured regiones produce larger entropy values, while uniform region produce lower entropy values.

this function usefull in:
 - Texture analysis
 - Edge detection
 - Object segmentation
 - Feature Extraction


---

# Syntax
```scilab

J = entropyfilt(I)
J = entropyfilt(I,nhood)
J = entropyfilt(I,nhood,padding)
J = entropyfilt(I,nhood,padding,showProgress)

```

# Parameters

- I --> Input grayscale image
- nhood --> Logical neighborhood mask
- padding -->Boundary padding mode
- showProgress --> Ehable Progess display
- J --> Local entropy image

---

# Input Types

 - unit8
 - int8
 - uint16
 - int16
 - double


# Default Values

```scilab

nhood = ones(9,9)

padding = "zero"

showProgress = %f

```

# Math Definations

Entropy:

H = -summation{p(i) * log(p(i))}

where :
- p(i) probablity of gray level i
- i = histogram bin

For each pixel:
1. Exact neighborhood
2. Build Histogram
3. Normalise Histogram
4. Compute Entropy



# Working Pipeline
```
Input Image
      |
Input validation
      |
Convert image to uint8
      |
Apply padding
      |
Check neighborhood type
      |

  Rectangular ? 
        |
        │
 Yes    │ No
        │
Integral Histogram
        │
Direct neighborhood scan
        │
Entropy calculation
        │
Output image
```




# Algorithm Selection

## Algo 1 : Rectangular neighborhood

```scilab

ones(9,9)

```

- Independent of window size 
- Optimisation : Integral Histogram


# complexity

```
O(rows * cols)
```

## Algo 2 : Arbitary Neighborhood

Cross:

```
0 1 0
1 1 1
0 1 0
```

Circular:

```scilab
[x,y] = meshgrid(-5:5,-5:5)

nhood = (x**2 + y**2 ) <= 25
```
Method :

    Direct scan over active pixels only.

    Complexity:
    ```
    O(N* nnz(nhood))
    ```
    whre:
    nnz = number of active neighborhood pixels

# Padding Modes

## Zero Padding

    Outside pixels:
    0
    Example:
    ```scilab
    J = entropyfilt(I,ones(9,9),"zero")
    ```

## Replicate Padding

    Border Values copied

        Example:
    ```scilab
    J = entropyfilt(I,ones(9,9),"replicate")
    ```
## Replicate Padding

    Mirror reflection.

    ```
    1 2 3

    becomes

    2 1 2 3 2
    ```

    Example:

    ```scilab
    J = entropyfilt(I,ones(9,9),"replicate")
    ```


# Some Implementations over Octave method

1. Intefral Histogram Optimisation

Traditional Method:
```
    For each pixel:
        compute histogram
```

Complexity:
    ```
    O(rows * cols * WindowSize^2)
    ```

- New implementation
    ``` 
    Build cumilative histogram
    ```

    Complexity:
    ```
    O(rows*cols)
    ```

# Examples
Basic 

```scilab
I=imread("cameraman.tif");

J=entropyfilt(I);

imshow(J,[])
```

Custom neighborhood

```scilab
nhood=[0 1 0
       1 1 1
       0 1 0];

J=entropyfilt(I,nhood);

imshow(J,[])
```
Cirular neighborhood

```scilab
[x,y]=meshgrid(-5:5,-5:5);

nhood=(x.^2+y.^2)<=25;

J=entropyfilt(I,nhood);

imshow(J,[])
```
Enable progress display

```scilab
J=entropyfilt(I,...
              ones(25,25),...
              "replicate",...
              %t);
```