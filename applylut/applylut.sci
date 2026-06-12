
function A = applylut(BW, LUT)
    [lhs, rhs] = argn(0);
    if rhs <> 2 then
        error("Arguments must be Two..");
    end
    nq = log(length(LUT)) / log(2);
    n = sqrt(nq);
    if floor(n) <> n then
        error("applylut: LUT length is not as expected.");
    end
    
   
    // Generate power weights sequence, then force column-major filling by transposing
    // powers = 2 .^ [0:nq-1];
     w = matrix ( 2. ^[ 0 : nq - 1 ], n , n );
    
    // Scilab's filter2/conv2 flips the kernel. We pre-flip 'w' here 
    // so it scans the image neighborhood exactly like Octave's spatial filter.
    w_flipped = w(n:-1:1, n:-1:1);
    
    idx = filter2(w_flipped, bool2s(BW));
    A = matrix(LUT(idx(:)+1), size(idx,1), size(idx,2));
endfunction

function y = filter2(b, x, shape)
    [lhs, rhs] = argn(0);
    if rhs < 2 then
        error("filter2: arguments should not be less than 2");
    end
    if rhs < 3 then
        shape = "same";
    end
    [nr, nc] = size(b);
    
    y = conv2(x, b(nr:-1:1, nc:-1:1), shape);
endfunction


