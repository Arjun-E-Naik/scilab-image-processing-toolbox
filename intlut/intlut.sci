
function B = intlut(A, LUT)


    if argn(2) ~= 2 then
        error("intlut: wrong number of input arguments");
    end

    cls = typeof(A);
    if cls ~= typeof(LUT) then
        error("intlut: A and LUT must be of same class");
    end

    lut_dims = size(LUT);
    if size(lut_dims, '*') > 2 | (lut_dims(1) > 1 & lut_dims(2) > 1) then
        error("intlut: LUT must be a vector");
    end

    if cls == "uint8" then
        if size(LUT, '*') ~= 256 then
            error("intlut: LUT must have 256 elements for class " + cls);
        end
        B = uint8(LUT(double(A) + 1));
    elseif cls == "uint16" then
        if size(LUT, '*') ~= 65536 then
            error("intlut: LUT must have 65536 elements for class " + cls);
        end
        B = uint16(LUT(double(A) + 1));
    elseif cls == "int16" then
        if size(LUT, '*') ~= 65536 then
            error("intlut: LUT must have 65536 elements for class " + cls);
        end
        B = int16(LUT(32769 + double(A)));
    else
        error("intlut: A must be of class uint8, uint16, or int16");
    end

endfunction

