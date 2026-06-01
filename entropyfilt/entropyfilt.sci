
/*
entropyfilt function
nbins- No. of histogram bins used for calculation (2 for logical/boolean images, 256 for all other types).
I_u8 -  double matrix representing the input image scaled to uint8-equivalent values,range [0, 255].
orig_size -  original dimensions of the input image before any padding is applied, stored as [R, C].
pad - The row and column padding half-sizes, stored as [pr, pc].
I_padded - The working image array after it has been padded and potentially trimmed for even-sized domains.
even - A 1×2 boolean flag that returns true for any domain dimension (row or column) that has an even size.
r_start, c_start - The starting row and column indices (typically 1 or 2) adjusted after the even-domain trim.
E - The final output matrix where the computed entropy values are stored.
dom_r, dom_c - The specific row and column indices of the active (non-zero/true) pixels within your domain mask.
neigh - column vector containing the exact pixel values present in the current spatial neighbourhood.
counts - Calculates  histogram of the current neighbourhood values (1 × nbins).
P - The discrete probability vector 

*/

function retval = entropyfilt(I, varargin)

    [lhs, rhs] = argn(0);

    // 1. Check input
    if (rhs == 0) then
        error("entropyfilt: not enough input arguments");
    end

    if (type(I) <> 1 & type(I) <> 4 & type(I) <> 8) then
        error("entropyfilt: I must be numeric");
    end

    // Parse domain
    if (rhs >= 2) then
        domain = varargin(1);
    else
        domain = ones(9, 9) == 1; // Equivalent to Octave's true(9)
    end

    if (type(domain) <> 1 & type(domain) <> 4 & type(domain) <> 8) then
        error("entropyfilt: DOMAIN must be a logical matrix");
    end
    domain = (domain <> 0); // Convert to boolean

    // Parse padding
    if (rhs >= 3) then
        padding = varargin(2);
    else
        padding = "symmetric";
    end

    // 2. Get number of histogram bins
    if (type(I) == 4) then
        nbins = 2;
    else
        nbins = 256;
    end

    // Convert to 8 or 16 bit integers if needed
    //Mimics Octave's im2uint8 
    T = typeof(I);
    select T
        case "constant" then 
            I = uint8(round(I * 255));
        case "uint16" then
            I = uint8(double(I) / 257);
        case "boolean" then
            
        case "uint8" then
            
        case "int8" then
            // Do nothing
        else
            error("entropyfilt: cannot handle images of class " + T);
    end

    // Store original dimensions before padding
    orig_size = size(I);
    
    // 4. Pad image
    pad = floor(size(domain) / 2);

    // Inline optimized symmetric padding ,this equal to padarray
    if padding == "symmetric" then
        r_idx = [pad(1):-1:1, 1:orig_size(1), orig_size(1):-1:orig_size(1)-pad(1)+1];
        c_idx = [pad(2):-1:1, 1:orig_size(2), orig_size(2):-1:orig_size(2)-pad(2)+1];
        I = I(r_idx, c_idx);
    else
        // otherwise zero padding if not symmetric
        I_temp = zeros(orig_size(1) + 2*pad(1), orig_size(2) + 2*pad(2));
        I_temp(pad(1)+1:$-pad(1), pad(2)+1:$-pad(2)) = I;
        I = I_temp;
    end

    
    even = (round(size(domain) / 2) == size(domain) / 2);
    idx = list();
    for k = 1:ndims(I)
        idx($+1) = (even(k) + 1) : size(I, k);
    end
    I = I(idx(1), idx(2)); // Apply dimension offset

    //  Spatial Filtering 
    retval = zeros(orig_size(1), orig_size(2));
    [dr, dc] = size(domain);

    for i = 1:orig_size(1)
        for j = 1:orig_size(2)
            // Extract local neighbourhood based on domain size
            window = I(i : i + dr - 1, j : j + dc - 1);
            
            // Mask the window with the boolean domain
            elements = double(window(domain)); 

            if length(elements) > 0 then
                // Calculate discrete probabilities 
                freq = tabul(elements); 
                P = freq(:, 2) / sum(freq(:, 2)); 

                // Compute Entropy: E = -sum(P .* log2(P))
                retval(i, j) = -sum(P .* log2(P));
            end
        end
    end
endfunction