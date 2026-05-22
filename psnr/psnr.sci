function [peaksnr,mse] = psnr(A,ref,peak)
    if ~isequal(size(A),size(ref)) then
        error("psnr:A and REF must have the same dimensions.");
    end

    dims = size(A);
    isRGB = (length(dims) == 3) && (dims(3) == 3);

    if argn(2) < 3 then
        select typeof(A) 
        case "uint8" then
            peak = 255;
        case "uint16" then
            peak = 65535;
        case "double" then
            peak = 1;
        else
            error("psnr:Unsupported image class")
        end
    elseif ~isscalar(peak) then
        error("psnr:Peak must be a scalar value.") 
    end

    A = double(A);
    ref = double(ref);

    if isRGB then
        mse_ch = zeros(1,3);
        for c = 1:3
            diff = double(A(:,:,c)) - double(ref(:,:,c));
            mse_ch(c) = mean(diff(:).^2);
        end
        mse = mean(mse_ch);
    else
        diff = A - ref;
        mse = mean(diff(:).^2);
    end 

    if mse == 0 then
        peaksnr = %inf;
        warning("psnr: Images are identical.PSNR is infinite");
    else
        peaksnr = 10 * log10(peak^2/mse);
    end
endfunction