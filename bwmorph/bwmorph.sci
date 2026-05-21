function bw_out = bwmorph_thin_fast(bw, n)

    // If iteration count not given,
    // continue until image stabilizes
    if argn(2) < 2 then
        n = %inf;
    end

    // Convert input to binary
    bw_out = double(bw > 0);

    // Build lookup tables only once
    [lut1, lut2] = build_luts();

    [rows, cols] = size(bw_out);

    iter = 0;
    changed = %t;

    while changed

        // stop if maximum iterations reached
        if n <> %inf & iter >= n then
            break;
        end

        iter = iter + 1;
        changed = %f;

        
        // PASS 1
        

        del = zeros(rows, cols);

        // Process only interior pixels
        for r = 2:rows-1

            for c = 2:cols-1

                if bw_out(r,c)==1 then

                    
                    // Read neighborhood
                    

                    P2 = bw_out(r-1,c);
                    P3 = bw_out(r-1,c+1);
                    P4 = bw_out(r,c+1);

                    P5 = bw_out(r+1,c+1);
                    P6 = bw_out(r+1,c);
                    P7 = bw_out(r+1,c-1);

                    P8 = bw_out(r,c-1);
                    P9 = bw_out(r-1,c-1);

                    
                    // Convert neighborhood into code
                    

                    code = 0;

                    code = code + P2*1;
                    code = code + P3*2;
                    code = code + P4*4;
                    code = code + P5*8;

                    code = code + P6*16;
                    code = code + P7*32;
                    code = code + P8*64;
                    code = code + P9*128;

                    
                    // Lookup deletion condition
                    

                    if lut1(code+1)==1 then
                        del(r,c)=1;
                    end

                end

            end

        end

        
        // Delete marked pixels
        

        if or(del==1) then

            bw_out(del==1)=0;

            changed=%t;

        end


        
        // PASS 2
        

        del=zeros(rows,cols);

        for r=2:rows-1

            for c=2:cols-1

                if bw_out(r,c)==1 then

                    
                    // Read neighbors
                    

                    P2=bw_out(r-1,c);
                    P3=bw_out(r-1,c+1);
                    P4=bw_out(r,c+1);

                    P5=bw_out(r+1,c+1);
                    P6=bw_out(r+1,c);
                    P7=bw_out(r+1,c-1);

                    P8=bw_out(r,c-1);
                    P9=bw_out(r-1,c-1);

                    
                    // Compute code
                    

                    code=0;

                    code=code+P2*1;
                    code=code+P3*2;
                    code=code+P4*4;
                    code=code+P5*8;

                    code=code+P6*16;
                    code=code+P7*32;
                    code=code+P8*64;
                    code=code+P9*128;

                    
                    // LUT test
                    

                    if lut2(code+1)==1 then
                        del(r,c)=1;
                    end

                end

            end

        end

        
        // delete pass2 pixels
        

        if or(del==1) then

            bw_out(del==1)=0;

            changed=%t;

        end

    end

endfunction


// Build lookup tables for thinning operation
// Based on Zhang-Suen algorithm


function [lut1, lut2] = build_luts()
    
    // Initialize lookup tables with 256 entries (0-255)
    lut1 = zeros(256, 1);
    lut2 = zeros(256, 1);
    
    // Iterate through all possible 8-neighbor configurations
    for i = 0:255
        
        // Extract bits (neighbors)
        P2 = bitget(i, 1);  // bit 0
        P3 = bitget(i, 2);  // bit 1
        P4 = bitget(i, 3);  // bit 2
        P5 = bitget(i, 4);  // bit 3
        P6 = bitget(i, 5);  // bit 4
        P7 = bitget(i, 6);  // bit 5
        P8 = bitget(i, 7);  // bit 6
        P9 = bitget(i, 8);  // bit 7
        
        // Count transitions (connectivity)
        A = P2 + P3 + P4 + P5 + P6 + P7 + P8 + P9;
        
        // Count connectivity
        B = P2*P3*P4 + P3*P4*P5 + P4*P5*P6 + P5*P6*P7 + P6*P7*P8 + P7*P8*P9 + P8*P9*P2 + P9*P2*P3;
        
        // Count transitions in sequence
        T = 0;
        if P2 < P3 then T = T + 1; end
        if P3 < P4 then T = T + 1; end
        if P4 < P5 then T = T + 1; end
        if P5 < P6 then T = T + 1; end
        if P6 < P7 then T = T + 1; end
        if P7 < P8 then T = T + 1; end
        if P8 < P9 then T = T + 1; end
        if P9 < P2 then T = T + 1; end
        
        // Pass 1 condition: 2 <= A <= 6 AND T == 1 AND (P2*P4*P8==0 OR P4*P6*P2==0)
        if (A >= 2 & A <= 6) & (T == 1) & ((P2*P4*P8 == 0) | (P4*P6*P2 == 0)) then
            lut1(i+1) = 1;
        end
        
        // Pass 2 condition: 2 <= A <= 6 AND T == 1 AND (P2*P4*P6==0 OR P2*P6*P8==0)
        if (A >= 2 & A <= 6) & (T == 1) & ((P2*P4*P6 == 0) | (P2*P6*P8 == 0)) then
            lut2(i+1) = 1;
        end
        
    end
    
endfunction