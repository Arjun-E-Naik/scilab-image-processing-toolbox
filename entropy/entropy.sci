/*
entropy
I - input image
nbins - used to estimate pixel value distribution , 2 bins for logical and 256 bins for numeric types.
lhs and rhs - stores the arguments 
Type - stores datatype of input array
is_logical,is_numeric -  boolean flags to Check
pixels - a flatened 1D vector used to histogram calculation
P - stores probability distribution
E - stores entropy value
*/




function out = im2uint8(I)
    // Check the data type: 1 is for double/float, 8 is for integer types
    if type(I) == 1 then
        out = round(double(I) .* 255);
    else
        // If it's already an integer type (uint8), leave its raw values alone
        out = round(double(I));
    end
    
    // Strictly clamp values to the [0, 255] range
    out(out < 0) = 0;
    out(out > 255) = 255;
endfunction

// Computes histogram 
function counts = imhist(I, nbins)
    I = double(I(:)); 

    if nbins == 2 then
        // count zero vs non-zero pixels
        counts = zeros(2, 1);
        counts(1) = sum(I == 0);
        counts(2) = sum(I <> 0);
    else
        // Map pixel intensities into equally spaced bins
        counts = zeros(nbins, 1);
        bin_width = 255 / (nbins - 1);
        
        for k = 1:nbins
            lo = (k - 1) * bin_width - 0.5;
            hi = k * bin_width - 0.5;
            
            if k == nbins then
                counts(k) = sum(I >= lo & I <= 255);
            else
                counts(k) = sum(I >= lo & I < hi);
            end
        end
    end
endfunction


function E = entropy(I, nbins)
    [lhs, rhs] = argn(0);
    
    if rhs < 1 | rhs > 2 then
        error("entropy: usage: E = entropy(I) or E = entropy(I, nbins)");
    end

    // Input type validation (1: real/complex, 8: integers, 5: sparse, 4: boolean)
    Type = type(I);
    is_numeric = (Type == 1 | Type == 8 | Type == 5);
    is_logical = (Type == 4);

    if ~(is_numeric | is_logical) then
        error("entropy: I must be numeric or logical");
    end
    if is_numeric & ~isreal(I) then
        error("entropy: I must be real (non-complex)");
    end

    if rhs < 2 then
        if is_logical then
            nbins = 2;
        else
            nbins = 256;
        end
    end

    if ~isscalar(nbins) | nbins <= 0 then
        error("entropy: nbins must be a positive scalar");
    end

    
    img_size = size(I);
    if length(img_size) == 3 & img_size(3) == 3 then
        I = 0.2989 * double(I(:,:,1)) + 0.5870 * double(I(:,:,2)) + 0.1140 * double(I(:,:,3));
        is_numeric = %t; 
        is_logical = %f;
    end

    if ~is_logical then
        I = im2uint8(I); 
    else
        I = bool2s(I); 
    end
    pixels = I(:);

   
    P = imhist(pixels, nbins);
    
    P(P == 0) = [];
    P = P ./ sum(P(:));

    // Calculate Shannon entropy
    E = -sum(P .* log2(P));
endfunction
