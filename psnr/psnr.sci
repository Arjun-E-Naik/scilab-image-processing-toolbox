/*
PSNR function
A - the primary input image
ref - second input image , ground truth to compare against a
peak - (optional) scaler input that represent max possible pixel value
peaksnr - variable taht contain Peak Signal-to-Noise Ratio. If MSE = 0, then it set to infinity.

lhs & rhs - this variables recives the peak and snr values.
dummy - placeholder variable used when calling getrangefromclass(A), dummy used to catch and discard the lower bound,which not needed for PSNR calculations.
A_vec - 1D column vector (input array) Calculated only when SNR requested.
signal_pwr - Calculated signal power of A. 
*/

// getrangefromclass
// Returns the lower and upper bounds based on Scilab data types.

function [lo, hi] = getrangefromclass(A)
    t = type(A);
    
    if t == 8 then 
        it = inttype(A);
        select it
            case 11 then lo = 0; hi = 255;          // uint8
            case 12 then lo = 0; hi = 65535;        // uint16
            case 14 then lo = 0; hi = 4294967295;   // uint32
            case 1  then lo = -128; hi = 127;       // int8
            case 2  then lo = -32768; hi = 32767;   // int16
            case 4  then lo = -2147483648; hi = 2147483647; // int32
            else error("getrangefromclass: Unsupported integer type");
        end
    elseif t == 1 then 
        lo = 0; hi = 1;
    else
        error("getrangefromclass: Unsupported data type");
    end
endfunction


// immse
// Calculates the Mean Squared Error

function mse = immse(A, ref)
    // Cast to double to prevent integer overflow during subtraction
    diff_val = double(A) - double(ref);
    mse = sum(diff_val .* diff_val) / length(diff_val);
endfunction



// Calculates Peak Signal-to-Noise Ratio.

function [peaksnr, snr] = psnr(A, ref, peak)
    [lhs, rhs] = argn(0); 

    // Input validation
    if rhs < 2 | rhs > 3 then
        error("psnr: requires 2 or 3 input arguments: psnr(A, ref [, peak])");
    end

    if ~isequal(size(A), size(ref)) then
        error("psnr: A and REF must be of same size");
    end

    if type(A) ~= type(ref) then
        error("psnr: A and REF must have same class");
    end
    
    // Check integer subtypes if applicable
    if type(A) == 8 & inttype(A) ~= inttype(ref) then
        error("psnr: A and REF must have same integer sub-type");
    end

    // Determine peak value
    if rhs < 3 then
        [dummy, peak] = getrangefromclass(A); 
    else
        if length(peak) ~= 1 then 
            error("psnr: PEAK must be a scalar value");
        end
    end

   
    if type(A) == 8 then
        A = double(A);
        ref = double(ref);
    end

    mse = immse(A, ref);
    
    // Handle identical images
    if mse == 0 then
        peaksnr = %inf;
        snr = %inf;
        return;
    end

    // Calculate PSNR
    peaksnr = 10 * log10((peak ^ 2) / mse);

    // Calculate standard SNR if requested
    if lhs > 1 then
        A_vec = A(:); 
        signal_pwr = (A_vec' * A_vec) / length(A); 
        snr = 10 * log10(signal_pwr / mse);
    end
endfunction