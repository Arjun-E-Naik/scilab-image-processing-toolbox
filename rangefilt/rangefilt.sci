
function retval = rangefilt(I, domain, padding)
    [lhs, rhs] = argn(0);
    
    // Check Input
    if rhs == 0 then
        error("rangefilt: not enough input arguments");
    end
    
    
    if rhs < 2 then
        domain = ones(3, 3); 
    end
    if rhs < 3 then
        padding = "symmetric";
    end

    if type(I) ~= 1 & type(I) ~= 4 & type(I) ~= 8 then
        error("rangefilt: I must be a numeric or logical array");
    end
    
    
    if type(domain) == 1 | type(domain) == 8 then
        domain = (domain <> 0);
    elseif type(domain) <> 4 then
        error("rangefilt: DOMAIN must be a numeric or logical array");
    end
    
    //  Pad image 
    sz_domain = size(domain);
    pad = floor(sz_domain / 2);
    
    I = padarray(double(I), pad, padding);
    
    // Adjust indices for even-sized domains
    even = (round(sz_domain / 2) == sz_domain / 2);
    r_start = 1; if even(1) then r_start = 2; end
    c_start = 1; if even(2) then c_start = 2; end
    
    I = I(r_start:$, c_start:$);
    
    // Execute spatial filtering 
    retval = __spatial_filtering_range__(I, domain);
endfunction



// Helper: __spatial_filtering_range__


function retval = __spatial_filtering_range__(I, domain)
    [rows, cols] = size(I);
    [dRows, dCols] = size(domain);
    
    out_rows = rows - dRows + 1;
    out_cols = cols - dCols + 1;
    
    initialized = %f;
    max_I = zeros(out_rows, out_cols);
    min_I = zeros(out_rows, out_cols);
    
    for r = 1:dRows
        for c = 1:dCols
            if domain(r, c) then
                // Extract current spatial window
                window = I(r : r + out_rows - 1, c : c + out_cols - 1);
                
                if ~initialized then
                    // Initialize with the first valid window
                    max_I = window;
                    min_I = window;
                    initialized = %t;
                else                   
                    
                    mask_max = bool2s(window > max_I);
                    max_I = (max_I .* (1 - mask_max)) + (window .* mask_max);
                    
                    
                    mask_min = bool2s(window < min_I);
                    min_I = (min_I .* (1 - mask_min)) + (window .* mask_min);
                end
            end
        end
    end
    
    if ~initialized then
        retval = zeros(out_rows, out_cols);
    else
        retval = max_I - min_I;
    end
endfunction



// Helper: padarray

function out = padarray(I, pad_sz, method)
    [r, c] = size(I);
    pr = pad_sz(1);
    pc = pad_sz(2);
    out = zeros(r + 2*pr, c + 2*pc);
    
    // Center the original image
    out(pr+1 : pr+r, pc+1 : pc+c) = I;
    
    if method == "symmetric" then
        if pr > 0 then
            out(1:pr, pc+1:pc+c) = I(pr:-1:1, :);
            out(pr+r+1:r+2*pr, pc+1:pc+c) = I(r:-1:r-pr+1, :);
        end
        if pc > 0 then
            out(:, 1:pc) = out(:, 2*pc:-1:pc+1);
            out(:, pc+c+1:c+2*pc) = out(:, pc+c:-1:c+1);
        end
    end
endfunction