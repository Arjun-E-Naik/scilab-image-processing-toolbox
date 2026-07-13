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

  //  Normalise to 3-D 
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

