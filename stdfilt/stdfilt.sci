
function retval = stdfilt(I, varargin)
    [lhs, rhs] = argn(0);

    if (rhs == 0) then
        error("stdfilt: not enough input arguments");
    end

    if (~isimage(I)) then
        error("stdfilt: first input must be a matrix");
    end

    // 1. Process Domain
    if (rhs >= 2) then
        domain = varargin(1);
    else
        domain = ones(3, 3) == 1;
    end

    if (~islogical(domain) & ~isnumeric(domain)) then
        error("stdfilt: second input argument must be a logical matrix");
    end

    // Cast domain to boolean
    if (type(domain) <> 4) then
        domain = (domain <> 0);
    end

    pad_sz = floor(size(domain) / 2);

  
    if (rhs >= 3) then
        padding = varargin(2);
    else
        padding = "symmetric"; 
    end

    
    if (rhs >= 4) then
        I_padded = padarray(I, pad_sz, padding, varargin(3));
    else
        I_padded = padarray(I, pad_sz, padding);
    end

   
    even = (round(size(domain) / 2) == size(domain) / 2);
    idx1 = (even(1) + 1) : size(I_padded, 1);
    idx2 = (even(2) + 1) : size(I_padded, 2);
    I_padded = I_padded(idx1, idx2); 


    retval = __spatial_filtering__(I_padded, domain, "std", zeros(size(domain)), 0);
endfunction




function retval = __spatial_filtering__(I, domain, method, dummy, nbins)
    if (method ~= "std") then
        error("__spatial_filtering__: unsupported method ''" + method + "''");
    end
    
    orig_size = size(I);
    domain_double = double(domain);
    domain_flipped = domain_double($:-1:1, $:-1:1);
    
    N = sum(domain_double);
    
    if (N <= 1) then
        pad_r = size(domain, 1) - 1;
        pad_c = size(domain, 2) - 1;
        retval = zeros(orig_size(1) - pad_r, orig_size(2) - pad_c);
        return;
    end
    
    I_double = double(I);
    
    
    sum_X  = conv2(I_double, domain_flipped, "valid");
    sum_X2 = conv2(I_double.^2, domain_flipped, "valid");
    

    variance = (sum_X2 - (sum_X.^2) / N) / (N - 1);
    
    variance = variance .* bool2s(variance > 0);
    
    retval = sqrt(variance);
endfunction


function B = padarray(A, padsize, padval, varargin)
    [lhs, rhs] = argn();
    
    if (rhs < 2) then
        error("padarray: not enough input arguments");
    end
    if (rhs < 3) then
        padval = 0;
    end
    
    orig_size = size(A);
    pr = padsize(1);
    pc = padsize(2);
    
    if (type(padval) == 10) then
        method = convstr(padval, "l");
        
        select method
        case "replicate" then
            r_idx = [ones(1, pr), 1:orig_size(1), orig_size(1)*ones(1, pr)];
            c_idx = [ones(1, pc), 1:orig_size(2), orig_size(2)*ones(1, pc)];
            B = A(r_idx, c_idx);
            
        case "symmetric" then
            r_left = (pr+1):-1:2;         
            r_right = (orig_size(1)-1):-1:(orig_size(1)-pr);
            r_idx = [r_left, 1:orig_size(1), r_right];
            
            c_left = (pc+1):-1:2;
            c_right = (orig_size(2)-1):-1:(orig_size(2)-pc);
            c_idx = [c_left, 1:orig_size(2), c_right];
            
            B = A(r_idx, c_idx);
            
        else
            error("padarray: unknown padding method: " + method);
        end
    else
        // Constant / Zero padding
        B = padval * ones(orig_size(1) + 2*pr, orig_size(2) + 2*pc);
        B(pr+1:$-pr, pc+1:$-pc) = A;
    end
endfunction



function result = isimage(x)
    result = isnumeric(x) | islogical(x);
endfunction

function result = islogical(x)
    result = (type(x) == 4);
endfunction

function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction
