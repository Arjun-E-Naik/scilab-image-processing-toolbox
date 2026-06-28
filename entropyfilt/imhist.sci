
// IMHIST FUNCTION


function [varargout] = imhist(img, b)

    indexed = %f;

    [lhs, rhs] = argn();

    if (rhs < 1 | rhs > 2) then
        error("imhist: wrong number of arguments.");
    elseif (rhs == 1) then
        if (islogical(img)) then
            b = 2;
        else
            b = 256;
        end
    elseif (rhs == 2) then
        if (iscolormap(b)) then
            if (~isind(img)) then
                error("imhist: second argument is a colormap but first argument is not an indexed image.");
            end
            indexed = %t;

            if ((isfloat(img) & max(double(img(:))) > size(b, 1)) | ..
                (isinteger(img) & max(double(img(:))) > size(b, 1) - 1)) then
                warning("imhist: largest index in image exceeds length of colormap.");
            end
        elseif (isnumeric(b) & isscalar(b) & fix(b) == b & b > 0) then
            if (islogical(img) & b ~= 2) then
                error("imhist: there can only be 2 bins when input image is binary")
            end
        else
            error("imhist: second argument must be a positive integer scalar or a colormap");
        end
    end

    if (indexed) then
        if (isinteger(img)) then
            bins = 0:size(b, 1) - 1;
        else
            bins = 1:size(b, 1);
        end
    else
        if (isinteger(img)) then
            bins = linspace(intmin(class(img)), intmax(class(img)), b);
        elseif (islogical(img)) then
            bins = 0:1;
        else
            bins = linspace(0, 1, b);
        end

        if (~islogical(img)) then
            bins_adjustment = ((bins(2) - bins(1)) / 2);
            bins = bins - bins_adjustment;
        end

        bins = bins';

        if (isfloat(img) & min(double(img(:))) < 0) then
            img(img < 0) = 0;
        end

        if (max(double(img(:))) > bins($)) then
            if (fix(bins($)) ~= bins($)) then
                img = double(img);
            end
            img(img > bins($)) = bins($);
        end
    end

    [nn] = histc_compat(double(img(:)), bins);

    if (~indexed & ~islogical(img)) then
        bins = bins + bins_adjustment;
    end

    if (lhs ~= 0) then
        varargout(1) = nn;
        varargout(2) = bins;
    else
        stem(bins, nn);
        e = gce();
        if (typeof(e) == "Compound") then
            e.children(1).mark_mode = "off";
        end

        a = gca();
        a.data_bounds = [bins(1), 0; bins($), max(nn) * 1.1];

        a.box = "off";

        ylimit = round(median(nn) * 10);
        if (a.data_bounds(2, 2) > ylimit & ylimit ~= 0) then
            a.data_bounds(2, 2) = ylimit;
        end

        if (indexed) then
            colormap(b);
        else
            colormap(graycolormap(b));
        end

        call_colorbar()
    end
endfunction


function call_colorbar()
    colorbar();
endfunction


// HISTC_COMPAT 


function nn = histc_compat(data, edges)
    n_edges = length(edges);
    nn = zeros(n_edges, 1);

    if (n_edges == 0) then
        return;
    end

    if (n_edges == 1) then
        nn(1) = sum(data == edges(1));
        return;
    end

    for i = 1:(n_edges - 1)
        nn(i) = sum(data >= edges(i) & data < edges(i + 1));
    end

    nn(n_edges) = sum(data == edges(n_edges));
endfunction
