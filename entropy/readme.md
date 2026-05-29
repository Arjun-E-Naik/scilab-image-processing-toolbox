# entropy() — Shannon Entropy Computation 

## Overview

`entropy()` computes the **Shannon entropy** of an image.

Entropy is a measure of randomness, uncertainty, or information content in an image.

Images with highly varying intensity values contain larger entropy, while constant or smooth images contain smaller entropy.

This function supports:

- Global image entropy
- Joint entropy between two images
- User-defined logarithm base
- Automatic datatype conversion

Entropy is widely used in:

- Information theory
- Texture analysis
- Image registration
- Feature extraction
- Image fusion
- Pattern recognition


---

# Syntax

```scilab
e = entropy(I)

e = entropy(I,base)

e = entropy(I1,I2)

e = entropy(I1,I2,base)

```
# Parameters

- I  --> Input image
- I1,I2 --> Images for joints entropy
- base  --> Logarithms base
- e     --> Entropy Value

- default log base is 2

# Mathematical Formulations

Entropy:

    H(x) = - summation_i{ p(i)*log[base](p(i))}

        where,
        H(x) -- entropy
        p(i) -- probablity of gray level i

* Probablity is computed from Image Histogram:
```
p(i) = histogram(i)/tol_pixels
```

# Joint Entropy

 - It measures information shared by two images

 - Formula:
    ```
    H(x,y) = - summation_x{summation_y{ p(x,y)* log[base](p(x,y))}}
    ```
   

# Working RoadMap

- Entropy

```
Input image
      |
Validate image
      |
Convert image to uint8
      |
Compute histogram
      |
Normalize histogram
      |
Remove zero probabilities
      |
Apply entropy formula
      |
Return entropy
```

- For Joint Entropy

```
Image1
      |

Image2
      |

Joint histogram
      |

Joint probabilities
      |

Entropy computation
```


# Feature introduced 

- custum log base

- Joint Entropy calculation

- Automatic Datatype Conversion

- Fast Histogram implementation

# Example

- Basic Entropy
```
I=imread("cameraman.tif");

e=entropy(I)

disp(e)
```

- Natural Algo
```
e=entropy(I,%e)
```

- Base changing
```
e=entropy(I,10)

output -- hartleys
```

- Joint Entropy

```
I1=imread("img1.png");

I2=imread("img2.png");

e=entropy(I1,I2)
```

# Complexity Analysis

- Single Image Entropy:
```
Time : O(n)

Space : O(256)

```

- Jpint Image Entropy:
```
Time : O(n)

Space : O(256^2)

```