function retval = stdfilt(I, varargin)
    // stdfilt 
    [lhs, rhs] = argn(0);

    if rhs == 0 then
        error("stdfilt: not enough input arguments");
    end

    // Default parameters
    domain = ones(3,3) == 1;
    padding = "replicate";   

    if rhs >= 2 then
        domain = varargin(1);
    end
    if rhs >= 3 then
        padding = varargin(2);
    end

    if type(domain) <> 1 & type(domain) <> 4 & type(domain) <> 8 then
        error("stdfilt: domain must be a logical matrix");
    end
    
    //cast to boolean
    if type(domain) <> 4 then
        domain = (domain <> 0);
    end

    // Convert input to double 
    I = double(I); 
    orig_size = size(I);

    
    pad = floor(size(domain) / 2);

    
    if padding == "replicate" then
        
        r_idx = [ones(1, pad(1)), 1:orig_size(1), orig_size(1)*ones(1, pad(1))];
        c_idx = [ones(1, pad(2)), 1:orig_size(2), orig_size(2)*ones(1, pad(2))];
        I_padded = I(r_idx, c_idx);
    elseif padding == "symmetric" then
        
        r_left = (pad(1)+1):-1:2;         
        r_right = (orig_size(1)-1):-1:(orig_size(1)-pad(1));
        r_idx = [r_left, 1:orig_size(1), r_right];
        c_left = (pad(2)+1):-1:2;
        c_right = (orig_size(2)-1):-1:(orig_size(2)-pad(2));
        c_idx = [c_left, 1:orig_size(2), c_right];
        I_padded = I(r_idx, c_idx);
    else 
        // Zero padding 
        I_padded = zeros(orig_size(1) + 2*pad(1), orig_size(2) + 2*pad(2));
        I_padded(pad(1)+1:$-pad(1), pad(2)+1:$-pad(2)) = I;
    end

    
    even = (round(size(domain) / 2) == size(domain) / 2);
    idx1 = (even(1) + 1) : size(I_padded, 1);
    idx2 = (even(2) + 1) : size(I_padded, 2);
    I_padded = I_padded(idx1, idx2); 

    
    domain_double = double(domain);
    domain_flipped = domain_double($:-1:1, $:-1:1);
    
    N = sum(domain_double);

    
    if N <= 1 then
        retval = zeros(orig_size(1), orig_size(2));
        return;
    end

    
    sum_X  = conv2(I_padded, domain_flipped, "valid");
    sum_X2 = conv2(I_padded.^2, domain_flipped, "valid");

    // Compute unbiased variance
    variance = (sum_X2 - (sum_X.^2) / N) / (N - 1);
    
    
    variance = variance .* bool2s(variance > 0);
    
    
    retval = sqrt(variance);
endfunction
