function retval = __spatial_filtering__(I, domain, method, dummy, nbins)
    // I is the PADDED image
    
    
    if (method ~= "entropy") then
        error("__spatial_filtering__: only ''entropy'' method supported");
    end
    
    [padded_rows, padded_cols] = size(I);
    [drows, dcols] = size(domain);
    
    // Original image size
    pad_r = floor(drows / 2);
    pad_c = floor(dcols / 2);
    orig_rows = padded_rows - 2 * pad_r;
    orig_cols = padded_cols - 2 * pad_c;
    
    // Domain center
    center_r = floor(drows / 2) + 1;
    center_c = floor(dcols / 2) + 1;
    
    // Output: original image size
    retval = zeros(orig_rows, orig_cols);
    
    // Process each pixel of original image
    for r = 1:orig_rows
        for c = 1:orig_cols
            // Position in padded image
            pr = r + pad_r;
            pc = c + pad_c;
            
            // Extract neighborhood
            r1 = pr - center_r + 1;
            r2 = pr - center_r + drows;
            c1 = pc - center_c + 1;
            c2 = pc - center_c + dcols;
            
            nhood = I(r1:r2, c1:c2);
            
            // Apply domain mask
            nhood = nhood(domain);
            
            // Compute entropy
            retval(r, c) = entropy_nhood(nhood, nbins);
        end
    end
endfunction


function e = entropy_nhood(nhood, nbins)
    // Compute entropy of neighborhood values
    
    nhood = nhood(:);
    n = length(nhood);
    
    if (n == 0) then
        e = 0;
        return;
    end
    
    // Logical/boolean input
    if (type(nhood) == 4) then
        n_true = sum(nhood);
        p1 = n_true / n;
        if (p1 <= 0 | p1 >= 1) then
            e = 0;
        else
            p0 = 1 - p1;
            e = -(p0 * log2(p0) + p1 * log2(p1));
        end
        return;
    end
    
endfunction


function e = entropy_nhood(nhood, nbins)
    // Compute entropy of a neighborhood (1D vector of values)
    // Fast version without calling full entropy() function
    
    // Flatten to column vector
    nhood = nhood(:);
    
    // Compute histogram
    if (islogical(nhood)) then
        // Boolean: count true and false
        p1 = sum(nhood) / length(nhood);  // fraction of true
        p0 = 1 - p1;                       // fraction of false
        P = [p0; p1];
        P = P(P > 0);  // Remove zeros
    else
        // For uint8: bins are 0:255
        if (nbins == 256) then
            // Fast path for uint8
            counts = zeros(256, 1);
            for k = 1:length(nhood)
                v = double(nhood(k)) + 1;  // 1-based index
                if (v >= 1 & v <= 256) then
                    counts(v) = counts(v) + 1;
                end
            end
            P = counts(counts > 0);  // Remove zero bins
            P = P ./ sum(P);          // Normalize
        else
            
            min_val = min(double(nhood));
            max_val = max(double(nhood));
            if (min_val == max_val) then
                e = 0;
                return;
            end
            edges = linspace(min_val, max_val, nbins + 1);
            edges = edges(1:$-1);  // N bins, N edges (left edges)
            counts = zeros(nbins, 1);
            for k = 1:length(nhood)
                // Find bin
                v = double(nhood(k));
                bin = min(nbins, max(1, floor((v - min_val) / (max_val - min_val) * nbins) + 1));
                counts(bin) = counts(bin) + 1;
            end
            P = counts(counts > 0);
            P = P ./ sum(P);
        end
    end
    
    // Compute entropy: -sum(P .* log2(P))
    if (isempty(P)) then
        e = 0;
    else
        e = -sum(P .* log2(P));
    end
endfunction
