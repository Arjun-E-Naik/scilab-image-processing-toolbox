

function rgb = wavelength2rgb(wavelength, out_class, gamma)
    [lhs, rhs] = argn(0);


    if rhs < 2 then out_class = "double"; end
    if rhs < 3 then gamma = 0.8; end


    if (rhs < 1 | rhs > 3) then
        error("wavelength2rgb: usage: rgb = wavelength2rgb(wavelength [, out_class [, gamma]])");
    elseif (~isnumeric(wavelength) | or(wavelength <= 0)) then
        error("wavelength2rgb: wavelength must be a positive numeric");
    elseif (type(out_class) <> 10 | and(convstr(out_class, "l") <> ["single", "double", "uint8", "uint16", "int16"])) then
        error(msprintf("wavelength2rgb: unsupported class `%s`", out_class));
    elseif (~isnumeric(gamma) | length(gamma) <> 1 | gamma > 1 | gamma < 0) then
        error("wavelength2rgb: gamma must be a numeric scalar between 1 and 0");
    end


    // Initialize independent channels 

    R = zeros(wavelength);
    G = zeros(wavelength);
    B = zeros(wavelength);


    // Wavelength Group Calculations

    
    // 380-440 nm
    mask = (wavelength >= 380 & wavelength < 440);
    if or(mask) then
        R(mask) = -(wavelength(mask) - 440) / 60; // 60 comes from 440-380
        B(mask) = 1;
    end

    // 440-490 nm
    mask = (wavelength >= 440 & wavelength < 490);
    if or(mask) then
        G(mask) = (wavelength(mask) - 440) / 50; // 50 comes from 490-440
        B(mask) = 1;
    end

    // 490-510 nm
    mask = (wavelength >= 490 & wavelength < 510);
    if or(mask) then
        G(mask) = 1;
        B(mask) = -(wavelength(mask) - 510) / 20; // 20 comes from 510-490
    end

    // 510-580 nm
    mask = (wavelength >= 510 & wavelength < 580);
    if or(mask) then
        R(mask) = (wavelength(mask) - 510) / 70; // 70 comes from 580-510
        G(mask) = 1;
    end

    // 580-645 nm
    mask = (wavelength >= 580 & wavelength < 645);
    if or(mask) then
        R(mask) = 1;
        G(mask) = -(wavelength(mask) - 645) / 65; // 65 comes from 645-580
    end

    // 645-780 nm
    mask = (wavelength >= 645 & wavelength <= 780);
    if or(mask) then
        R(mask) = 1;
    end


    // Intensity Falloff (Vision Limits)

    factor = zeros(wavelength);
    
    mask = (wavelength >= 380 & wavelength < 420);
    if or(mask) then 
        factor(mask) = 0.3 + 0.7 * (wavelength(mask) - 380) / 40; // 40 = 420 - 380
    end
    
    mask = (wavelength >= 420 & wavelength <= 700);
    if or(mask) then 
        factor(mask) = 1; 
    end
    
    mask = (wavelength > 700 & wavelength <= 780);
    if or(mask) then 
        factor(mask) = 0.3 + 0.7 * (780 - wavelength(mask)) / 80; // 80 = 780 - 700
    end

    // Apply factor and gamma correction directly to channels
    R = (R .* factor) .^ gamma;
    G = (G .* factor) .^ gamma;
    B = (B .* factor) .^ gamma;


    // Concatenate into final RGB Array

    if length(wavelength) == 1 then
        rgb = [R, G, B];
    else

        sz = size(wavelength);
        rgb = matrix([R(:); G(:); B(:)], [sz, 3]);
    end


    select convstr(out_class, "l")
        case "single" then 
            rgb = im2single(rgb);
        case "double" then 
            // do nothing, already class double natively
        case "uint8" then 
            rgb = im2uint8(rgb);
        case "uint16" then 
            rgb = im2uint16(rgb);
        case "int16" then 
            rgb = im2int16(rgb);
    end
endfunction


function res = isnumeric(x)
    res = or(type(x) == [1, 5, 8]);
endfunction

function result = is_string_scalar(s)
    result = (type(s) == 10) & (size(s, "*") == 1);
endfunction

function result = isscalar(x)
    result = (size(x, "*") == 1);
endfunction

function n = ndims(x)
    sz = size(x);
    n = length(sz);
    while n > 2 & sz(n) == 1 then
        n = n - 1;
    end
endfunction


function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction

// im2uint16
// IM2UINT8 FUNCTION


function imout = im2uint16(img, varargin)
    [lhs, rhs] = argn();

    if (rhs < 1 || rhs > 2) then
        error("im2uint16: usage: im2uint16 (img) or im2uint16 (img, ""indexed"")");
    end

    if (rhs == 2) then
        param = varargin(1);
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("im2uint16: second input argument must be the string ""indexed""");
        end
    end

    imout = imcast(img, "uint16", varargin(:));
endfunction

function imout = im2uint8(img, varargin)
    [lhs, rhs] = argn();

    if (rhs < 1 || rhs > 2) then
        error("im2uint8: usage: im2uint8 (img) or im2uint8 (img, ""indexed"")");
    end

    if (rhs == 2) then
        param = varargin(1);
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("im2uint8: second input argument must be the string ""indexed""");
        end
    end

    imout = imcast(img, "uint8", varargin(:));
endfunction

function imout = im2int16(img, varargin)
    [lhs, rhs] = argn();

    if (rhs < 1 || rhs > 2) then
        error("im2int16: usage: im2int16 (img) or im2int16 (img, ""indexed"")");
    end

    if (rhs == 2) then
        param = varargin(1);
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("im2int16: second input argument must be the string ""indexed""");
        end
    end

    imout = imcast(img, "int16", varargin(:));
endfunction

function imout = im2single(img, varargin)
    
    [lhs, rhs] = argn();
    if (rhs < 1 || rhs > 2) then
        error("im2single: wrong number of input arguments.");
    end

    if (rhs == 2) then
        param = varargin(1);
        
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("im2single: second input argument must be the string ""indexed""");
        end
        
        imout = imcast(img, "single", "indexed");
    else
        imout = imcast(img, "single");
    end

endfunction
// IMCAST FUNCTION


function imout = imcast(img, outcls, varargin)
    [lhs, rhs] = argn();

    if (rhs < 2 || rhs > 3) then
        error("imcast: wrong number of arguments.");
    end
    
    is_indexed_mode = %f;
    if (rhs == 3) then
        param = varargin(1);
        if typeof(param) <> "string" || convstr(param, "l") <> "indexed" then
            error("imcast: third argument must be the string ""indexed""");
        end
        is_indexed_mode = %t;
    end

    outcls = convstr(outcls, "l");

    incls_type = type(img);
    incls_str = "";
    
    if incls_type == 1 then
        incls_str = "double"; 
    elseif incls_type == 4 then
        incls_str = "logical"; 
    elseif incls_type == 8 then
        select inttype(img)
        case 11 then incls_str = "uint8";
        case 12 then incls_str = "uint16";
        case 2 then incls_str = "int16";
        else
            error("imcast: unsupported integer input class.");
        end
    else
        error("imcast: unknown image class type.");
    end

    if is_indexed_mode then
        if ~isind(img) then
            error("imcast: input should have been an indexed image but it is not.");
        end

        if (outcls == "single" || outcls == "double") then
            if incls_type == 8 then
                imout = double(img) + 1; 
            else
                imout = double(img);
            end
        else
            select outcls
            case "uint8" then target_max = 255;
            case "uint16" then target_max = 65535;
            case "int16" then target_max = 32767;
            else
                error("imcast: unsupported integer type " + outcls);
            end

            if incls_type == 8 then
                if max(double(img)) > target_max then
                    error(msprintf("imcast: IMG has too many colours %d for the range of values in %s", max(double(img)), outcls));
                end
            elseif incls_type == 1 then
                imax = max(img) - 1;
                if imax > target_max then
                    error(msprintf("imcast: IMG has too many colours %d for the range of values in %s", imax, outcls));
                end
                img = img - 1; 
            end
            
            select outcls
            case "uint8" then imout = uint8(img);
            case "uint16" then imout = uint16(img);
            case "int16" then imout = int16(img);
            end
        end

    else
        problem = %f;
        
        select incls_str
        case "double" then
            select outcls
            case "uint8" then 
                img_clamped = max(0, min(1, img));
                imout = uint8(round(img_clamped * 255));
            case "uint16" then 
                img_clamped = max(0, min(1, img));
                imout = uint16(round(img_clamped * 65535));
            case "int16" then 
                img_clamped = max(0, min(1, img));
                imout = int16(round(img_clamped * 65535 - 32768));
            case "double" then imout = double(img);
            case "single" then imout = double(img); 
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "uint8" then
            select outcls
            case "double" then imout = double(img) / 255;
            case "uint8" then imout = img; 
            case "single" then imout = double(img) / 255;
            case "uint16" then imout = uint16(img) * 257; 
            case "int16" then imout = int16(double(img) * 257 - 32768);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "uint16" then
            select outcls
            case "double" then imout = double(img) / 65535;
            case "single" then imout = double(img) / 65535;
            // FIX: Proper uint16 to uint8 conversion
            case "uint8" then imout = uint8(double(img) / 257);
            case "int16" then imout = int16(double(img) - 32768);
            case "logical" then imout = (img <> 0);
            else problem = %t;
            end

        case "logical" then
            select outcls
            case "double" then imout = double(img);
            case "single" then imout = double(img);
            case "uint8" then 
                imout = zeros(img); 
                imout(img) = 255;
                imout = uint8(imout);
            case "uint16" then 
                imout = zeros(img); 
                imout(img) = 65535;
                imout = uint16(imout);
            case "int16" then 
                imout = ones(img) * -32768; 
                imout(img) = 32767;
                imout = int16(imout);
            case "logical" then imout = img; 
            else problem = %t;
            end

        case "int16" then
            select outcls
            case "double" then imout = (double(img) + 32768) / 65535;
            case "single" then imout = (double(img) + 32768) / 65535;
            case "uint8" then imout = uint8((double(img) + 32768) / 257);
            case "uint16" then imout = uint16(double(img) + 32768);
            case "logical" then imout = (img <> 0);
            case "int16" then imout = img;
            else problem = %t;
            end
        end
        
        if (problem) then
            error("imcast: unsupported TYPE """ + outcls + """");
        end
    end
endfunction