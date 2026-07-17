exec("padarray.sci",-1);

function J = integralImage3(I)

  if (argn(2) <> 1)
    error("integralImage3: incorrect number of arguments");
  end

  if (~isimage(I))
    error("integralImage3: I should be an image");
  end

  if (ndims(I) > 3)
    error("integralImage3: I should be a 3-dimensional image");
  end

  if (typeof(I) <> "constant") then
    if (islogical(I)) then
      I = bool2s(I);
    else
      I = double(I);
    end
  end

  //  ---------------------------------------- 
// this block handles the 2d and 3d matrices and assign correct input to cumsum().
  sz = size(I);
  if (length(sz) < 3) then
    sz = [sz, 1];
  end
  rows   = sz(1);
  cols   = sz(2);
  frames = sz(3);


  if (ndims(I) < 3) then
    I_3d = zeros(rows, cols, frames);
    I_3d(:, :, 1) = I;
    I = I_3d;
  end
// ---------------------------------------------------

  J = cumsum(I, 1);
  J = cumsum(J, 2);
  J = cumsum(J, 3);


  J = padarray (J, [1 1 1],0, "pre");
endfunction


// ---------- helper functions ----------
function result = isimage(x)
    result = isnumeric(x) | islogical(x);
endfunction

function result = islogical(x)
    result = (type(x) == 4);
endfunction

function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction

// padarray function.

function B = padarray(A, padsize, varargin)

    rhs = argn(2);

    //----------------------------------------------------------
    // Check number of input arguments
    //----------------------------------------------------------
    if rhs < 2 | rhs > 4 then
        error("padarray: invalid number of input arguments.");
    end

    //----------------------------------------------------------
    // Validate PADSIZE
    //----------------------------------------------------------
    if ~isvector(padsize) then
        error("padarray: PADSIZE must be a vector.");
    end

    if ~isreal(padsize) then
        error("padarray: PADSIZE must be numeric.");
    end

    if or(padsize < 0) then
        error("padarray: PADSIZE must contain non-negative integers.");
    end

    if or(padsize <> int(padsize)) then
        error("padarray: PADSIZE must contain integers only.");
    end

    //----------------------------------------------------------
    // Convert padsize to row vector
    //----------------------------------------------------------
    padsize = matrix(padsize,1,-1);

    //----------------------------------------------------------
    // Early exit if no padding needed
    //----------------------------------------------------------
    if sum(padsize)==0 then
        B=A;
        return;
    end

    //----------------------------------------------------------
    // Default values
    //----------------------------------------------------------
    padval=0;
    pattern="";
    direction="both";

    //----------------------------------------------------------
    // Parse optional arguments
    //----------------------------------------------------------
    for k=1:length(varargin)
        arg=varargin(k);
        if type(arg)==10 then
            str=convstr(arg,"l");
            select str
            case "pre" then
                direction="pre";
            case "post" then
                direction="post";
            case "both" then
                direction="both";
            case "circular" then
                pattern="circular";
            case "replicate" then
                pattern="replicate";
            case "reflect" then
                pattern="reflect";
            case "symmetric" then
                pattern="symmetric";
            case "zeros" then
                padval=0;
            else
                error("padarray: unrecognized option.");
            end
        elseif size(arg,"*")==1 then
            padval=arg;
        else
            error("padarray: PADVAL or DIRECTION is invalid.");
        end
    end

    fancy_pad=(pattern<>"");
    pre=(direction=="pre" | direction=="both");
    post=(direction=="post" | direction=="both");

    //----------------------------------------------------------
    // Extract image dimensions (Up to 3D)
    //----------------------------------------------------------
    s = size(A);
    dims = size(s, "*");

    if dims == 2 then
        rows=s(1); cols=s(2); depth=1;
    elseif dims == 3 then
        rows=s(1); cols=s(2); depth=s(3);
    else
        error("padarray: Only up to 3-D arrays are supported.");
    end

    //----------------------------------------------------------
    // Extract padding amounts for each dimension
    //----------------------------------------------------------
    if length(padsize)==1 then
        pr=padsize(1); pc=0; pd=0;
    elseif length(padsize)==2 then
        pr=padsize(1); pc=padsize(2); pd=0;
    else
        pr=padsize(1); pc=padsize(2); pd=padsize(3);
    end

    //----------------------------------------------------------
    // Calculate padding amounts before and after based on direction
    //----------------------------------------------------------
    if pre then
        top=pr; left=pc; front=pd;
    else
        top=0; left=0; front=0;
    end

    if post then
        bottom=pr; right=pc; back=pd;
    else
        bottom=0; right=0; back=0;
    end

    outRows=rows+top+bottom;
    outCols=cols+left+right;
    outDepth=depth+front+back;

    //----------------------------------------------------------
    // Allocate output array and place original data
    // Special case: for post-only padding with zero/fancy modes,
    // allocate zeros and place data at origin for efficiency
    //----------------------------------------------------------
    if post & ~pre & (padval==0 | fancy_pad) then
        B=zeros(outRows,outCols,outDepth);
        B(1:rows,1:cols,1:depth)=A;
    else
        B=padval*ones(outRows,outCols,outDepth);
        B(top+1:top+rows,left+1:left+cols,front+1:front+depth)=A;
    end

    //----------------------------------------------------------
    // Advanced padding modes (circular, replicate, symmetric, reflect)
    //----------------------------------------------------------
    if fancy_pad then
        circular  = %f;
        replicate = %f;
        symmetric = %f;
        reflect   = %f;

        select convstr(pattern, "l")
        case "circular" then circular = %t;
        case "replicate" then replicate = %t;
        case "symmetric" then symmetric = %t;
        case "reflect" then reflect = %t;
        else error("padarray: unknown padding option.");
        end

        //------------------------------------------------------
        // Validate constraints for reflection padding
        //------------------------------------------------------
        if reflect then
            if (rows == 1 & pr > 0) | (cols == 1 & pc > 0) | (depth == 1 & pd > 0) then
                error("padarray: cannot reflect-pad singleton dimensions.");
            end
        end

        //------------------------------------------------------
        // Pre-compute tiling patterns for efficient padding
        // rowComplete/colComplete/depthComplete: # of full copies
        // rowBits/colBits/depthBits: remaining partial copy
        //------------------------------------------------------
        if reflect then
            // For reflection, use rows-1 as base (excludes boundary pixel)
            rowCut = rows - 1;
            rowComplete = floor(pr / rowCut);
            rowBits = modulo(pr, rowCut);
            rowPairSize = 2 * rowCut;
            rowPairComplete = floor(rowComplete / 2);
            rowUnpaired = modulo(rowComplete,2);

            colCut = cols - 1;
            colComplete = floor(pc / colCut);
            colBits = modulo(pc,colCut);
            colPairSize = 2 * colCut;
            colPairComplete = floor(colComplete / 2);
            colUnpaired = modulo(colComplete,2);

            depthCut = depth - 1;
            depthComplete = floor(pd / depthCut);
            depthBits = modulo(pd, depthCut);
            depthPairSize = 2 * depthCut;
            depthPairComplete = floor(depthComplete / 2);
            depthUnpaired = modulo(depthComplete,2);
        else
            // For circular/replicate, use full dimension
            rowComplete = floor(pr / rows);
            rowBits = modulo(pr,rows);

            colComplete = floor(pc / cols);
            colBits = modulo(pc,cols);

            depthComplete = floor(pd / depth);
            depthBits = modulo(pd, depth);

            // For symmetric, pre-compute pair tiling (alternates original and flipped)
            if symmetric then
                rowPairSize = 2 * rows;
                colPairSize = 2 * cols;
                depthPairSize = 2 * depth;

                rowPairComplete = floor(rowComplete / 2);
                colPairComplete = floor(colComplete / 2);
                depthPairComplete = floor(depthComplete / 2);

                rowUnpaired = modulo(rowComplete,2);
                colUnpaired = modulo(colComplete,2);
                depthUnpaired = modulo(depthComplete,2);
            end
        end

        //==========================================================
        // CIRCULAR PADDING: wrap content around edges
        //==========================================================
        if circular then
            //------------------------------------------------------
            // Circular row padding
            //------------------------------------------------------
            if pr > 0 then
                // Fill complete rows with repeated cycles of original data
                if rowComplete > 0 & pre then
                    for k = 1:rowComplete
                        r1 = rowBits + (k-1)*rows + 1;
                        r2 = rowBits + k*rows;
                        B(r1:r2,left+1:left+cols,front+1:front+depth) = A;
                    end
                end
                if rowComplete > 0 & post then
                    for k = 1:rowComplete
                        r1 = top + rows + (k-1)*rows + 1;
                        r2 = top + rows + k*rows;
                        B(r1:r2,left+1:left+cols,front+1:front+depth) = A;
                    end
                end
                // Fill remaining partial row
                if pre & rowBits>0 then
                    B(1:rowBits,left+1:left+cols,front+1:front+depth)=A(rows-rowBits+1:rows,:,:);
                end
                if post & rowBits>0 then
                    B(outRows-rowBits+1:outRows,left+1:left+cols,front+1:front+depth)=A(1:rowBits,:,:);
                end
            end

            //------------------------------------------------------
            // Circular column padding
            //------------------------------------------------------
            if pc>0 then
                if colComplete>0 & pre then
                    for k=1:colComplete
                        c1=colBits+(k-1)*cols+1;
                        c2=colBits+k*cols;
                        B(:,c1:c2,front+1:front+depth)=B(:,left+1:left+cols,front+1:front+depth);
                    end
                end
                if colComplete>0 & post then
                    for k=1:colComplete
                        c1=left+cols+(k-1)*cols+1;
                        c2=left+cols+k*cols;
                        B(:,c1:c2,front+1:front+depth)=B(:,left+1:left+cols,front+1:front+depth);
                    end
                end
                if pre & colBits>0 then
                    B(:,1:colBits,front+1:front+depth)=B(:,left+cols-colBits+1:left+cols,front+1:front+depth);
                end
                if post & colBits>0 then
                    B(:,outCols-colBits+1:outCols,front+1:front+depth)=B(:,left+1:left+colBits,front+1:front+depth);
                end
            end

            //------------------------------------------------------
            // Circular depth padding
            //------------------------------------------------------
            if pd>0 then
                if depthComplete>0 & pre then
                    for k=1:depthComplete
                        d1=depthBits+(k-1)*depth+1;
                        d2=depthBits+k*depth;
                        B(:,:,d1:d2)=B(:,:,front+1:front+depth);
                    end
                end
                if depthComplete>0 & post then
                    for k=1:depthComplete
                        d1=front+depth+(k-1)*depth+1;
                        d2=front+depth+k*depth;
                        B(:,:,d1:d2)=B(:,:,front+1:front+depth);
                    end
                end
                if pre & depthBits>0 then
                    B(:,:,1:depthBits)=B(:,:,front+depth-depthBits+1:front+depth);
                end
                if post & depthBits>0 then
                    B(:,:,outDepth-depthBits+1:outDepth)=B(:,:,front+1:front+depthBits);
                end
            end
        end

        //==========================================================
        // REPLICATE PADDING: extend edge pixels
        //==========================================================
        if replicate then
            // Pre-fill with edge pixel along rows
            if pr > 0 then
                if pre then
                    for i = 1:top
                        B(i, left+1:left+cols, front+1:front+depth) = B(top+1, left+1:left+cols, front+1:front+depth);
                    end
                end
                if post then
                    for i = top+rows+1:outRows
                        B(i, left+1:left+cols, front+1:front+depth) = B(top+rows, left+1:left+cols, front+1:front+depth);
                    end
                end
            end

            // Pre-fill with edge pixel along columns
            if pc > 0 then
                if pre then
                    for j = 1:left
                        B(:, j, front+1:front+depth) = B(:, left+1, front+1:front+depth);
                    end
                end
                if post then
                    for j = left+cols+1:outCols
                        B(:, j, front+1:front+depth) = B(:, left+cols, front+1:front+depth);
                    end
                end
            end

            // Pre-fill with edge pixel along depth
            if pd > 0 then
                if pre then
                    for k = 1:front
                        B(:,:,k) = B(:,:,front+1);
                    end
                end
                if post then
                    for k = front+depth+1:outDepth
                        B(:,:,k) = B(:,:,front+depth);
                    end
                end
            end
        end

        //==========================================================
        // SYMMETRIC PADDING: mirror content (include boundaries)
        //==========================================================
        if symmetric then
            // Symmetric row padding
            if pr > 0 then
                row_source = B(top+1:top+rows, left+1:left+cols, front+1:front+depth);
                row_flipped = flipdim(row_source, 1);

                // Handle partial rows at edges
                if pre & rowBits > 0 then
                    if rowUnpaired then
                        B(1:rowBits, left+1:left+cols, front+1:front+depth) = B(top+rows-rowBits+1:top+rows, left+1:left+cols, front+1:front+depth);
                    else
                        B(1:rowBits, left+1:left+cols, front+1:front+depth) = flipdim(B(top+1:top+rowBits, left+1:left+cols, front+1:front+depth), 1);
                    end
                end
                if post & rowBits > 0 then
                    if rowUnpaired then
                        B(outRows-rowBits+1:outRows, left+1:left+cols, front+1:front+depth) = B(top+1:top+rowBits, left+1:left+cols, front+1:front+depth);
                    else
                        B(outRows-rowBits+1:outRows, left+1:left+cols, front+1:front+depth) = flipdim(B(top+rows-rowBits+1:top+rows, left+1:left+cols, front+1:front+depth), 1);
                    end
                end

                // Tile pairs of (original, flipped) pattern for efficiency
                if rowPairComplete > 0 then
                    if pre then
                        rowBlock = cat(1, row_source, row_flipped);
                        for k = 1:rowPairComplete
                            r1 = rowBits + rows*rowUnpaired + (k-1)*rowPairSize + 1;
                            r2 = rowBits + rows*rowUnpaired + k*rowPairSize;
                            B(r1:r2, left+1:left+cols, front+1:front+depth) = rowBlock;
                        end
                    end
                    if post then
                        rowBlock = cat(1, row_flipped, row_source);
                        for k = 1:rowPairComplete
                            r1 = top+rows + (k-1)*rowPairSize + 1;
                            r2 = top+rows + k*rowPairSize;
                            B(r1:r2, left+1:left+cols, front+1:front+depth) = rowBlock;
                        end
                    end
                end

                // Handle single unpaired copy of flipped rows
                if rowUnpaired then
                    if pre then
                        B(rowBits+1:rowBits+rows, left+1:left+cols, front+1:front+depth) = row_flipped;
                    end
                    if post then
                        B(outRows-rowBits-rows+1:outRows-rowBits, left+1:left+cols, front+1:front+depth) = row_flipped;
                    end
                end
            end

            // Symmetric column padding
            if pc > 0 then
                col_source = B(:, left+1:left+cols, front+1:front+depth);
                col_flipped = flipdim(col_source, 2);

                if pre & colBits > 0 then
                    if colUnpaired then
                        B(:,1:colBits, front+1:front+depth) = B(:,left+cols-colBits+1:left+cols, front+1:front+depth);
                    else
                        B(:,1:colBits, front+1:front+depth) = flipdim(B(:,left+1:left+colBits, front+1:front+depth), 2);
                    end
                end
                if post & colBits > 0 then
                    if colUnpaired then
                        B(:,outCols-colBits+1:outCols, front+1:front+depth) = B(:,left+1:left+colBits, front+1:front+depth);
                    else
                        B(:,outCols-colBits+1:outCols, front+1:front+depth) = flipdim(B(:,left+cols-colBits+1:left+cols, front+1:front+depth), 2);
                    end
                end

                if colPairComplete > 0 then
                    if pre then
                        colBlock = cat(2, col_source, col_flipped);
                        for k = 1:colPairComplete
                            c1 = colBits + cols*colUnpaired + (k-1)*colPairSize + 1;
                            c2 = colBits + cols*colUnpaired + k*colPairSize;
                            B(:, c1:c2, front+1:front+depth) = colBlock;
                        end
                    end
                    if post then
                        colBlock = cat(2, col_flipped, col_source);
                        for k = 1:colPairComplete
                            c1 = left+cols + (k-1)*colPairSize + 1;
                            c2 = left+cols + k*colPairSize;
                            B(:, c1:c2, front+1:front+depth) = colBlock;
                        end
                    end
                end

                if colUnpaired then
                    if pre then
                        B(:, colBits+1:colBits+cols, front+1:front+depth) = col_flipped;
                    end
                    if post then
                        B(:, outCols-colBits-cols+1:outCols-colBits, front+1:front+depth) = col_flipped;
                    end
                end
            end

            // Symmetric depth padding
            if pd > 0 then
                depth_source = B(:,:,front+1:front+depth);
                depth_flipped = flipdim(depth_source, 3);

                if pre & depthBits > 0 then
                    if depthUnpaired then
                        B(:,:,1:depthBits) = B(:,:,front+depth-depthBits+1:front+depth);
                    else
                        B(:,:,1:depthBits) = flipdim(B(:,:,front+1:front+depthBits), 3);
                    end
                end
                if post & depthBits > 0 then
                    if depthUnpaired then
                        B(:,:,outDepth-depthBits+1:outDepth) = B(:,:,front+1:front+depthBits);
                    else
                        B(:,:,outDepth-depthBits+1:outDepth) = flipdim(B(:,:,front+depth-depthBits+1:front+depth), 3);
                    end
                end

                if depthPairComplete > 0 then
                    if pre then
                        depthBlock = cat(3, depth_source, depth_flipped);
                        for k = 1:depthPairComplete
                            d1 = depthBits + depth*depthUnpaired + (k-1)*depthPairSize + 1;
                            d2 = depthBits + depth*depthUnpaired + k*depthPairSize;
                            B(:,:, d1:d2) = depthBlock;
                        end
                    end
                    if post then
                        depthBlock = cat(3, depth_flipped, depth_source);
                        for k = 1:depthPairComplete
                            d1 = front+depth + (k-1)*depthPairSize + 1;
                            d2 = front+depth + k*depthPairSize;
                            B(:,:, d1:d2) = depthBlock;
                        end
                    end
                end

                if depthUnpaired then
                    if pre then
                        B(:,:,depthBits+1:depthBits+depth) = depth_flipped;
                    end
                    if post then
                        B(:,:,outDepth-depthBits-depth+1:outDepth-depthBits) = depth_flipped;
                    end
                end
            end
        end

        //==========================================================
        // REFLECT PADDING: mirror content (exclude boundaries)
        //==========================================================
        if reflect then
            // Reflection row padding
            if pr > 0 then
                row_source = B(top+1:top+rows, left+1:left+cols, front+1:front+depth);
                row_flipped = flipdim(row_source, 1);

                // Handle partial rows at edges
                if pre & rowBits > 0 then
                    if rowUnpaired then
                        B(1:rowBits, left+1:left+cols, front+1:front+depth) = B(top+rows-rowBits:top+rows-1, left+1:left+cols, front+1:front+depth);
                    else
                        B(1:rowBits, left+1:left+cols, front+1:front+depth) = flipdim(B(top+2:top+rowBits+1, left+1:left+cols, front+1:front+depth), 1);
                    end
                end
                if post & rowBits > 0 then
                    if rowUnpaired then
                        B(outRows-rowBits+1:outRows, left+1:left+cols, front+1:front+depth) = B(top+2:top+rowBits+1, left+1:left+cols, front+1:front+depth);
                    else
                        B(outRows-rowBits+1:outRows, left+1:left+cols, front+1:front+depth) = flipdim(B(top+rows-rowBits:top+rows-1, left+1:left+cols, front+1:front+depth), 1);
                    end
                end

                // Tile pairs of (source_part, flipped_part) excluding edge pixels
                if rowPairComplete > 0 then
                    if pre then
                        source_part = B(top+1:top+rows-1, left+1:left+cols, front+1:front+depth);
                        flipped_part = row_flipped(1:rowCut, :, :);
                        rowBlock = cat(1, source_part, flipped_part);
                        for k = 1:rowPairComplete
                            r1 = rowBits + rowCut*rowUnpaired + (k-1)*rowPairSize + 1;
                            r2 = rowBits + rowCut*rowUnpaired + k*rowPairSize;
                            B(r1:r2, left+1:left+cols, front+1:front+depth) = rowBlock;
                        end
                    end
                    if post then
                        source_part = B(top+2:top+rows, left+1:left+cols, front+1:front+depth);
                        flipped_part = row_flipped(2:rows, :, :);
                        rowBlock = cat(1, flipped_part, source_part);
                        for k = 1:rowPairComplete
                            r1 = top+rows + (k-1)*rowPairSize + 1;
                            r2 = top+rows + k*rowPairSize;
                            B(r1:r2, left+1:left+cols, front+1:front+depth) = rowBlock;
                        end
                    end
                end

                // Handle single unpaired copy of reflected rows
                if rowUnpaired then
                    if pre then
                        B(rowBits+1:rowBits+rowCut, left+1:left+cols, front+1:front+depth) = row_flipped(1:rowCut, :, :);
                    end
                    if post then
                        B(outRows-rowBits-rowCut+1:outRows-rowBits, left+1:left+cols, front+1:front+depth) = row_flipped(2:rows, :, :);
                    end
                end
            end

            // Reflection column padding
            if pc > 0 then
                col_source = B(:, left+1:left+cols, front+1:front+depth);
                col_flipped = flipdim(col_source, 2);

                if pre & colBits > 0 then
                    if colUnpaired then
                        B(:,1:colBits, front+1:front+depth) = B(:,left+cols-colBits:left+cols-1, front+1:front+depth);
                    else
                        B(:,1:colBits, front+1:front+depth) = flipdim(B(:,left+2:left+colBits+1, front+1:front+depth), 2);
                    end
                end
                if post & colBits > 0 then
                    if colUnpaired then
                        B(:,outCols-colBits+1:outCols, front+1:front+depth) = B(:,left+2:left+colBits+1, front+1:front+depth);
                    else
                        B(:,outCols-colBits+1:outCols, front+1:front+depth) = flipdim(B(:,left+cols-colBits:left+cols-1, front+1:front+depth), 2);
                    end
                end

                if colPairComplete > 0 then
                    if pre then
                        source_part = B(:, left+1:left+cols-1, front+1:front+depth);
                        flipped_part = col_flipped(:, 1:colCut, :);
                        colBlock = cat(2, source_part, flipped_part);
                        for k = 1:colPairComplete
                            c1 = colBits + colCut*colUnpaired + (k-1)*colPairSize + 1;
                            c2 = colBits + colCut*colUnpaired + k*colPairSize;
                            B(:, c1:c2, front+1:front+depth) = colBlock;
                        end
                    end
                    if post then
                        source_part = B(:, left+2:left+cols, front+1:front+depth);
                        flipped_part = col_flipped(:, 2:cols, :);
                        colBlock = cat(2, flipped_part, source_part);
                        for k = 1:colPairComplete
                            c1 = left+cols + (k-1)*colPairSize + 1;
                            c2 = left+cols + k*colPairSize;
                            B(:, c1:c2, front+1:front+depth) = colBlock;
                        end
                    end
                end

                if colUnpaired then
                    if pre then
                        B(:, colBits+1:colBits+colCut, front+1:front+depth) = col_flipped(:, 1:colCut, :);
                    end
                    if post then
                        B(:, outCols-colBits-colCut+1:outCols-colBits, front+1:front+depth) = col_flipped(:, 2:cols, :);
                    end
                end
            end

            // Reflection depth padding
            if pd > 0 then
                depth_source = B(:,:,front+1:front+depth);
                depth_flipped = flipdim(depth_source, 3);

                if pre & depthBits > 0 then
                    if depthUnpaired then
                        B(:,:,1:depthBits) = B(:,:,front+depth-depthBits:front+depth-1);
                    else
                        B(:,:,1:depthBits) = flipdim(B(:,:,front+2:front+depthBits+1), 3);
                    end
                end
                if post & depthBits > 0 then
                    if depthUnpaired then
                        B(:,:,outDepth-depthBits+1:outDepth) = B(:,:,front+2:front+depthBits+1);
                    else
                        B(:,:,outDepth-depthBits+1:outDepth) = flipdim(B(:,:,front+depth-depthBits:front+depth-1), 3);
                    end
                end

                if depthPairComplete > 0 then
                    if pre then
                        source_part = B(:,:,front+1:front+depth-1);
                        flipped_part = depth_flipped(:,:,1:depthCut);
                        depthBlock = cat(3, source_part, flipped_part);
                        for k = 1:depthPairComplete
                            d1 = depthBits + depthCut*depthUnpaired + (k-1)*depthPairSize + 1;
                            d2 = depthBits + depthCut*depthUnpaired + k*depthPairSize;
                            B(:,:, d1:d2) = depthBlock;
                        end
                    end
                    if post then
                        source_part = B(:,:,front+2:front+depth);
                        flipped_part = depth_flipped(:,:,2:depth);
                        depthBlock = cat(3, flipped_part, source_part);
                        for k = 1:depthPairComplete
                            d1 = front+depth + (k-1)*depthPairSize + 1;
                            d2 = front+depth + k*depthPairSize;
                            B(:,:, d1:d2) = depthBlock;
                        end
                    end
                end

                if depthUnpaired then
                    if pre then
                        B(:,:,depthBits+1:depthBits+depthCut) = depth_flipped(:,:,1:depthCut);
                    end
                    if post then
                        B(:,:,outDepth-depthBits-depthCut+1:outDepth-depthBits) = depth_flipped(:,:,2:depth);
                    end
                end
            end
        end

    end

endfunction
