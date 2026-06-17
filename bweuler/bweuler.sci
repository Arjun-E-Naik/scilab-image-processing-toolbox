exec("applylut.sci",-1);
exec("makelut.sci",-1);

function eul = bweuler(BW, varargin)
    [lhs, rhs] = argn(0);

    // 1. Argument Check
    if (rhs < 1 | rhs > 2) then
        error("bweuler: requires 1 or 2 arguments");
    end

    // 2. Set default connectivity 
    if (rhs == 1) then
        n = 8;
    else
        n = varargin(1);
    end

    // 3. Image Type Validation
    // Type 1: Real, Type 4: Boolean, Type 8: Integer
    if (type(BW) <> 1 & type(BW) <> 4 & type(BW) <> 8) then
        error("bweuler: first argument must be a Black and White image");
    end
    if (ndims(BW) <> 2) then
        error("bweuler: BW must have 2 dimensions");
    end

    // cast to boolean 
    BW = (BW <> 0);

    // 4. Connectivity Check
    if (type(n) <> 1 & type(n) <> 8) | (n <> 4 & n <> 8) | length(n) <> 1 then
        error("bweuler: second argument must either be 4 or 8");
    end

    if (n == 8) then
        lut = [0; 1; 1; 0; 1; 0; -2; -1; 1; -2; 0; -1; 0; -1; -1; 0];
    else // n == 4
        lut = [0; 1; 1; 0; 1; 0; 2; -1; 1; 2; 0; -1; 0; -1; -1; 0];
    end

    // 5. Padding the Image
    [r, c] = size(BW);
    BWaux = zeros(r + 1, c + 1) == 1; 
    BWaux(2:$, 2:$) = BW;             

    // 6. Calculate Euler Number
    eul = sum(applylut(BWaux, lut)) / 4;

endfunction