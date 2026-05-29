function J = entropyfilt(I, varargin)

    [lhs, rhs] = argn(0);

    if rhs < 1

        error("At least one argument (I) required.");

    end

    nhood = ones(9,9) == 1;

    padding = "zero";

    showProgress = %f;

    if rhs >= 2

        nhood = varargin(1);

        nhood = nhood ~= 0;   
    end

    if rhs >= 3

        padding = varargin(2);

        if ~(padding == "zero" | padding == "replicate" | padding == "symmetric")

            error("Padding must be zero, replicate or symmetric.");

        end

    end

    if rhs >= 4

        showProgress = varargin(3);

        if showProgress ~= %t

            showProgress = %f;

        end

    end

    if isreal(I) == 0

        error("I must be a real matrix.");

    end

    if type(I) == 1   
        
        I = max(0, min(1, I));

        I = uint8(round(I * 255));

    elseif type(I) == 8   
        
        minVal = double(min(I));

        maxVal = double(max(I));

        if maxVal == minVal

            J = zeros(size(I));

            return

        end

        I = uint8(round((double(I) - minVal) / (maxVal - minVal) * 255));

    else

        error("Unsupported image type. Use uint8 or double in [0,1].");

    end

    [rows, cols] = size(I);

    nhoodRows = size(nhood, 1);

    nhoodCols = size(nhood, 2);

    rCenter = floor((nhoodRows+1)/2);

    cCenter = floor((nhoodCols+1)/2);

    padRowsTop = rCenter - 1;

    padRowsBottom = nhoodRows - rCenter;

    padColsLeft = cCenter - 1;

    padColsRight = nhoodCols - cCenter;

    select padding

    case "zero"

        padded = zeros(rows + padRowsTop + padRowsBottom, ...

                       cols + padColsLeft + padColsRight, "uint8");

        padded(padRowsTop+1 : padRowsTop+rows, ...

               padColsLeft+1 : padColsLeft+cols) = I;

    case "replicate"

        padded = replicate_pad(I, padRowsTop, padRowsBottom, ...

                                    padColsLeft, padColsRight);

    case "symmetric"

        padded = symmetric_pad(I, padRowsTop, padRowsBottom, ...

                                    padColsLeft, padColsRight);

    end

    if is_rectangular(nhood)

        J = entropyfilt_rect(padded, nhoodRows, nhoodCols, rows, cols, showProgress);

    else

        J = entropyfilt_arbitrary(padded, nhood, rows, cols, rCenter, cCenter, showProgress);

    end

endfunction

function flag = is_rectangular(nhood)

    flag = sum(nhood(:)) == length(nhood(:));

endfunction

function J = entropyfilt_rect(padded, winH, winW, rows, cols, showProgress)

    [pRows, pCols] = size(padded);

    J = zeros(rows, cols);

    totalPix = winH * winW;

    log2total = log2(totalPix);

    sum_count_log = zeros(rows, cols);

    if showProgress

        printf("Processing bins 0..255 (integral histogram)\n");

    end

    for bin = 0:255

        binary = (padded == uint8(bin));

        integral = zeros(pRows+1, pCols+1);

        integral(2:$,2:$) = cumsum(cumsum(double(binary), 1), 2);

        for i = 1:rows

            r1 = i;

            r2 = i + winH - 1;

            for j = 1:cols

                c1 = j;

                c2 = j + winW - 1;

                cnt = integral(r2+1,c2+1) - integral(r1,c2+1) - integral(r2+1,c1) + integral(r1,c1);

                if cnt > 0

                    sum_count_log(i,j) = sum_count_log(i,j) + cnt * log2(cnt);

                end

            end

            if showProgress & (bin == 255) & (modulo(i, ceil(rows/20)) == 0)

                printf("  Row %d / %d\n", i, rows);

            end

        end

        if showProgress & (modulo(bin+1, 64) == 0)

            printf("  Bin %d done\n", bin);

        end

    end

    J = log2total - sum_count_log / totalPix;

    J(isnan(J)) = 0;

endfunction

function J = entropyfilt_arbitrary(padded, nhood, rows, cols, rCenter, cCenter, showProgress)

    [nhoodRows, nhoodCols] = size(nhood);

    [offsR, offsC] = find(nhood);

    offsR = offsR - rCenter;

    offsC = offsC - cCenter;

    numOffsets = length(offsR);

    totalPix = numOffsets;

    log2total = log2(totalPix);

    J = zeros(rows, cols);

    if showProgress

        printf("Arbitrary neighbourhood: %d active pixels\n", totalPix);

    end

    vals = zeros(1, numOffsets, "uint8");

    for i = 1:rows

        for j = 1:cols

            for k = 1:numOffsets

                r = i + offsR(k);

                c = j + offsC(k);

                vals(k) = padded(r, c);

            end

            hist = zeros(1,256);

            for k = 1:numOffsets

                hist(vals(k)+1) = hist(vals(k)+1) + 1;

            end

            ent = 0;

            for bin = 1:256

                if hist(bin) > 0

                    p = hist(bin) / totalPix;

                    ent = ent - p * log2(p);

                end

            end

            J(i,j) = ent;

        end

        if showProgress & (modulo(i, ceil(rows/20)) == 0)

            printf("  Row %d / %d\n", i, rows);

        end

    end

endfunction

function out = replicate_pad(I, t, b, l, r)

    [rows, cols] = size(I);

    outRows = rows + t + b;

    outCols = cols + l + r;

    out = zeros(outRows, outCols, typeof(I));

    out(t+1 : t+rows, l+1 : l+cols) = I;

    for i = 1:t

        out(i, l+1 : l+cols) = I(1, :);

    end

    for i = 1:b

        out(t+rows+i, l+1 : l+cols) = I(rows, :);

    end

    for j = 1:l

        out(:, j) = out(:, l+1);

    end

    for j = 1:r

        out(:, outCols-j+1) = out(:, outCols-r);

    end

endfunction

function out = symmetric_pad(I, t, b, l, r)

    [rows, cols] = size(I);

    outRows = rows + t + b;

    outCols = cols + l + r;

    out = zeros(outRows, outCols, typeof(I));

    out(t+1 : t+rows, l+1 : l+cols) = I;

    for i = 1:t

        out(t+1-i, l+1 : l+cols) = I(i, :);

    end

    for i = 1:b

        out(t+rows+i, l+1 : l+cols) = I(rows-i+1, :);

    end

    for j = 1:l

        out(:, l+1-j) = out(:, l+j);

    end

    for j = 1:r

        out(:, outCols-j+1) = out(:, outCols-r+j-1);

    end

endfunction