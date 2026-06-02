
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

    // 1. Check input arguments
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
        domain = ones(9, 9) == 1; 
    end

    if (type(domain) <> 1 & type(domain) <> 4 & type(domain) <> 8) then
        error("entropyfilt: DOMAIN must be a logical matrix");
    end
    domain = (domain <> 0); 

    // Parse padding
    if (rhs >= 3) then
        padding = varargin(2);
    else
        padding = "symmetric";
    end

    // 2. Type conversion perfectly mirroring Octave's im2uint8
    T = typeof(I);
    select T
        case "constant" then 
            // Clip to [0,1], then scale by 255
            I = uint8(round(min(max(I, 0), 1) * 255));
        case "uint16" then
            I = uint8(double(I) / 257);
        case "boolean" then
            // Leave as boolean
        case "uint8" then
            // Do nothing
        case "int8" then
            I = uint8(max(I, 0)); 
        else
            error("entropyfilt: cannot handle images of class " + T);
    end

    orig_size = size(I);
    
    // 3. Pad image
    pad = floor(size(domain) / 2);

    select padding
        case "symmetric" then
            r_idx = [pad(1):-1:1, 1:orig_size(1), orig_size(1):-1:orig_size(1)-pad(1)+1];
            c_idx = [pad(2):-1:1, 1:orig_size(2), orig_size(2):-1:orig_size(2)-pad(2)+1];
            I = I(r_idx, c_idx);
        case "replicate" then
            r_idx = [ones(1, pad(1)), 1:orig_size(1), orig_size(1)*ones(1, pad(1))];
            c_idx = [ones(1, pad(2)), 1:orig_size(2), orig_size(2)*ones(1, pad(2))];
            I = I(r_idx, c_idx);
        else 
            // Zero padding fallback
            I_temp = zeros(orig_size(1) + 2*pad(1), orig_size(2) + 2*pad(2));
            I_temp(pad(1)+1:$-pad(1), pad(2)+1:$-pad(2)) = double(I);
            I = uint8(I_temp);
    end

    // Handle even-sized domains
    even = (round(size(domain) / 2) == size(domain) / 2);
    idx1 = (even(1) + 1) : size(I, 1);
    idx2 = (even(2) + 1) : size(I, 2);
    I = I(idx1, idx2); 

    // 4. Spatial Filtering Calculation
    retval = zeros(orig_size(1), orig_size(2));
    [dr, dc] = size(domain);

    for i = 1:orig_size(1)
        for j = 1:orig_size(2)
            
            window = I(i : i + dr - 1, j : j + dc - 1);
            elements = double(window(domain)); 

            if length(elements) > 0 then
                u_vals = unique(elements);
                n_vals = length(u_vals);
                P = zeros(n_vals, 1);
                
                for k = 1:n_vals
                    P(k) = sum(elements == u_vals(k));
                end
                
                P = P / sum(P); 
                retval(i, j) = -sum(P .* log2(P));
            end
        end
    end
endfunction
