function retval = __spatial_filtering__(I, domain, method, dummy, nbins)

    
    if (method ~= "entropy") then
        error("__spatial_filtering__: only ''entropy'' method supported");
    end
    
    [padded_rows, padded_cols] = size(I);
    [drows, dcols] = size(domain);
    
    orig_rows = padded_rows - drows + 1;
    orig_cols = padded_cols - dcols + 1;
    
    if (orig_rows < 1 | orig_cols < 1) then
        error("__spatial_filtering__: domain is larger than the image");
    end
    
    retval = zeros(orig_rows, orig_cols);
    
    for r = 1:orig_rows
        for c = 1:orig_cols
            nhood = I(r:r+drows-1, c:c+dcols-1);
            nhood = nhood(domain);
            retval(r, c) = entropy_nhood(nhood, nbins);
        end
    end
endfunction



// ENTROPY_NHOOD 


function e = entropy_nhood(nhood, nbins)
    // Compute entropy of a neighborhood 
    
    // Flatten to column vector
    nhood = nhood(:);
    n = length(nhood);
    
  
    if (n == 0) then
        e = 0;
        return;
    end
    
   
    if (islogical(nhood)) then
        // Boolean: count true and false
        p1 = sum(nhood) / n;  
        if (p1 <= 0 | p1 >= 1) then
            e = 0;
            return;
        end
        p0 = 1 - p1;           
        P = [p0; p1];
        P = P(P > 0);  // Remove zeros
    else
        // For uint8: bins are 0:255
        if (nbins == 256) then
            counts = zeros(256, 1);
            for k = 1:n
                v = double(nhood(k)) + 1;  
                if (v >= 1 & v <= 256) then
                    counts(v) = counts(v) + 1;
                end
            end
            P = counts(counts > 0);  // Remove zero bins
            if (isempty(P)) then
                e = 0;
                return;
            end
            P = P ./ sum(P);          
        else
            
            min_val = min(double(nhood));
            max_val = max(double(nhood));
            if (min_val == max_val) then
                e = 0;
                return;
            end
            counts = zeros(nbins, 1);
            for k = 1:n
              
                v = double(nhood(k));
                bin = min(nbins, max(1, floor((v - min_val) / (max_val - min_val) * nbins) + 1));
                counts(bin) = counts(bin) + 1;
            end
            P = counts(counts > 0);
            if (isempty(P)) then
                e = 0;
                return;
            end
            P = P ./ sum(P);
        end
    end
    
    // Compute entropy: -sum(P .* log2(P))
    e = -sum(P .* log2(P));
endfunction
