function varargout = otsuthresh(hist)

  if nargin <> 1 then
    error("otsuthresh: wrong number of input arguments");
  end

  if ~isvector(hist) | ~isnumeric(hist) | ~isreal(hist) ...
      | or(isinf(hist)) | or(isnan(hist)) | or(hist < 0) ...
      | or(hist <> fix(hist)) then
    error("otsuthresh: HIST must be a vector of non-negative integers");
  end

  hist = double(hist);
  [varargout(1:nargout)] = graythresh(hist(:).', "otsu");
endfunction




function varargout = graythresh(img, algo, varargin)

  if nargin < 1 | nargin > 3 then
    error("graythresh: wrong number of input arguments");
  elseif nargin > 2 & ~any(strcmpi(algo, ["percentile"]) == 0) then
    error(msprintf("graythresh: algorithm ''%s'' does not accept any options.", algo));
  else
    hist_in = %f;
    if ~isnumeric(img) then
      error("graythresh: IMG must be numeric");
    elseif size(img, 3) == 3 then
      img = rgb2gray(img);
    elseif isfloat(img) & isvector(img) & ~issparse(img) ...
            & isreal(img) & and(img >= 0) then
      hist_in = %t;
      ihist = img;
    end
  end

  if convstr(algo, "l") == "mean" then
    varargout(1) = mean(im2double(img)(:));
    return
  end

  if ~hist_in then
    if typeof(img) == "uint16" | typeof(img) == "uint8" then
      // do nothing
    elseif typeof(img) == "int16" then
      img = im2uint16(img);
    else
      img = im2uint8(img);
    end
    ihist = histc(img(:), 0:intmax(typeof(img)));
  end

  select convstr(algo, "l")
    case "concavity" then      thresh = concavity(ihist);
    case "intermeans" then     thresh = intermeans(ihist, floor(mean(img(:))));
    case "intermodes" then     thresh = intermodes(ihist);
    case "maxentropy" then     thresh = maxentropy(ihist);
    case "maxlikelihood" then  thresh = maxlikelihood(ihist);
    case "minerror" then      thresh = minerror_iter(ihist, floor(mean(img(:))));
    case "minimum" then        thresh = minimum(ihist);
    case "moments" then       thresh = moments(ihist);
    case "otsu" then          thresh = otsu(ihist, nargout > 1);
    case "percentile" then    thresh = percentile(ihist, varargin(:));
    else error("graythresh: unknown method ''%s''", algo);
  end

  if size(ihist,"*") > 1 then
    thresh(1) = double(thresh(1)) / (size(ihist,"*") - 1);
  end

  for i = 1:size(thresh,"*")
    varargout(i) = thresh(i);
  end
endfunction

function thresh = otsu(ihist, compute_good)

  if size(ihist,"*") == 1 | sum(ihist) == 0 then
    thresh(1) = 0;
    thresh(2) = 0;
    return;
  end

  bins = 0:(size(ihist,"*") - 1);
  total = sum(ihist);
  b_totals = cumsum([0 ihist(1:$-1)]);
  b_weights = b_totals / total;
  b_means = [0 cumsum(bins(1:$-1) .* ihist(1:$-1))] ./ b_totals;

  w_totals = total - b_totals;
  w_weights = w_totals / total;
  w_means = (cumsum(bins($:-1:1) .* ihist($:-1:1)) ./ w_totals($:-1:1))($:-1:1);

  bcv = b_weights .* w_weights .* (b_means - w_means).^2;

  max_bcv = max(bcv);
  if isnan(max_bcv) then
    thresh(1) = 0;
    thresh(2) = 0;
  else
    thresh(1) = (mean(find(bcv == max_bcv))) - 2;

    if compute_good then
      norm_hist = ihist / total;
      total_mean = sum(bins .* norm_hist);
      total_variance = sum(((bins - total_mean).^2) .* norm_hist);
      thresh(2) = max(bcv) / total_variance;
    end
  end
endfunction

function level = moments(y)
  n = size(y,"*") - 1;

  sumY = sum(y);
  Avec = cumsum(y) / sumY;

  sumB = partial_sumB(y, n);
  sumC = partial_sumC(y, n);
  sumD = partial_sumD(y, n);

  x2 = (sumB*sumC - sumY*sumD) / (sumY*sumC - sumB^2);
  x1 = (sumB*sumD - sumC^2) / (sumY*sumC - sumB^2);
  x0 = .5 - (sumY/sumY + x2/2) / sqrt(x2^2 - 4*x1);

  [tmp, ind] = min(abs(Avec-x0));
  level(1) = ind-1;
endfunction

function T = maxentropy(y)
  n = size(y,"*") - 1;

  sumY = sum(y);
  negY = negativeE(y, n);
  for j = 0:n
    sumA = partial_sumA(y, j);
    negE = negativeE(y, j);
    sum_diff = sumY - sumA;
    vec(j+1) = negE/sumA - log10(sumA) + (negY-negE)/(sum_diff) - log10(sum_diff);
  end

  [tmp, ind] = min(vec);
  T(1) = ind-1;
endfunction

function T = intermodes(y)
  n = size(y,"*") - 1;

  iter = 0;
  while ~bimodtest(y)
    h = ones(1,3)/3;
    y = convol(y, h);
    iter = iter+1;
    if iter > 10000 then
      T(1) = 0;
      return
    end
  end

  ind = 0;
  for k = 2:n
    if y(k-1) < y(k) & y(k+1) < y(k)
      ind = ind+1;
      TT(ind) = k-1;
    end
  end
  T(1) = floor(mean(TT));
endfunction

function T = percentile(y, p)
  if ~exists("p", "local") then
    p = 0.5;
  end
  Avec = cumsum(y) / sum(y);
  [tmp, ind] = min(abs(Avec - p));
  T(1) = ind - 1;
endfunction

function T = minimum(y)
  n = size(y,"*") - 1;

  iter = 0;
  while ~bimodtest(y)
    h = ones(1,3)/3;
    y = convol(y, h);
    iter = iter+1;
    if iter > 10000 then
      T(1) = 0;
      return
    end
  end

  peakfound = %f;
  for k = 2:n
    if y(k-1) < y(k) & y(k+1) < y(k)
      peakfound = %t;
    end
    if peakfound & y(k-1) >= y(k) & y(k+1) >= y(k)
      T(1) = k-1;
      return
    end
  end
endfunction

function Tout = minerror_iter(y, T)
  n = size(y,"*") - 1;

  Tprev = %nan;

  sumA = partial_sumA(y, n);
  sumB = partial_sumB(y, n);
  sumC = partial_sumC(y, n);
  while T <> Tprev
    sumAT = partial_sumA(y, T);
    sumBT = partial_sumB(y, T);
    sumCT = partial_sumC(y, T);
    sumAdiff = sumA - sumAT;

    mu = sumBT/sumAT;
    nu = (sumB-sumBT)/(sumAdiff);
    p = sumAT/sumA;
    q = (sumAdiff) / sumA;
    sigma2 = sumCT/sumAT-mu^2;
    tau2 = (sumC-sumCT) / (sumAdiff) - nu^2;

    w0 = 1/sigma2-1/tau2;
    w1 = mu/sigma2-nu/tau2;
    w2 = mu^2/sigma2 - nu^2/tau2 + log10((sigma2*q^2)/(tau2*p^2));

    sqterm = w1^2-w0*w2;
    if sqterm < 0 then
      warning("th_minerror_iter did not converge.")
      break
    end

    Tprev = T;
    T = floor((w1+sqrt(sqterm))/w0);

    if isnan(T) then
      warning("th_minerror_iter did not converge.")
      T = Tprev;
    end
  end
  Tout(1) = T;
endfunction

function Tout = maxlikelihood(y)

  n = size(y,"*") - 1;

  T = minimum(y)(1);

  sumY = sum(y);

  sumB = partial_sumB(y, n);
  sumC = partial_sumC(y, n);

  sumAT = partial_sumA(y, T);
  sumBT = partial_sumB(y, T);
  sumCT = partial_sumC(y, T);

  mu = sumBT / sumAT;
  nu = (sumB - sumBT) / (sumY - sumAT);
  p = sumAT / sumY;
  q = (sumY - sumAT) / sumY;
  sigma2 = sumCT / sumAT - mu^2;
  tau2 = (sumC - sumCT) / (sumY - sumAT) - nu^2;

  if sigma2 == 0 | tau2 == 0 then
    Tout(1) = T;
    return
  end

  while %t
    mu_prev = mu;
    nu_prev = nu;
    p_prev = p;
    q_prev = q;
    sigma2_prev = sigma2;
    tau2_prev = tau2;

    for i = 0:n
      phi(i+1) = p/sqrt((sigma2)) * exp(-((i-mu)^2) / (2*sigma2)) / ...
                (p/sqrt(sigma2) * exp(-((i-mu)^2) / (2*sigma2)) + ...
                (q/sqrt(tau2)) * exp(-((i-nu)^2) / (2*tau2)));
    end
    ind = 0:n;
    gamma = 1-phi;
    F = phi*y';
    G = gamma*y';

    mu = ind.*phi*y'/F;
    nu = ind.*gamma*y'/G;
    p = F / sumY;
    q = G / sumY;
    sigma2 = ind.^2.*phi*y'/F - mu^2;
    tau2 = ind.^2.*gamma*y'/G - nu^2;

    if abs(mu - mu_prev) <= %eps | abs(nu - nu_prev) <= %eps | ...
       abs(p - p_prev) <= %eps | abs(q - q_prev) <= %eps | ...
       abs(sigma2 - sigma2_prev) <= %eps | abs(tau2 - tau2_prev) <= %eps then
      break;
    end
  end

  w0 = 1/sigma2-1/tau2;
  w1 = mu/sigma2-nu/tau2;
  w2 = mu^2/sigma2 - nu^2/tau2 + log10((sigma2*q^2)/(tau2*p^2));

  sqterm = w1^2-w0*w2;
  if sqterm < 0 then
    Tout(1) = 0;
    return
  end

  Tout(1) = floor((w1+sqrt(sqterm))/w0);
endfunction

function Tout = intermeans(y, T)
  n = size(y) - 1;

  Tprev = %nan;

  sumY = sum(y);
  sumB = partial_sumB(y, n);
  while T <> Tprev
    sumAT = partial_sumA(y, T);
    sumBT = partial_sumB(y, T);

    mu = sumBT/sumAT;
    nu = (sumB-sumBT)/(sumY-sumAT);
    Tprev = T;
    T = floor((mu+nu)/2);
  end
  Tout(1) = T;
endfunction

function T = concavity(h)
  n = size(h,"*") - 1;
  H = hconvhull(h);

  lmax = flocmax(H-h);

  for k = 0:n
    E(k+1) = hbalance(h,k);
  end

  E = E.*lmax;
  [dummy, ind] = max(E);
  T(1) = ind-1;
endfunction

function x = partial_sumA(y, j)
  x = sum(y(1:j+1));
endfunction

function x = partial_sumB(y, j)
  ind = 0:j;
  x = ind*y(1:j+1)';
endfunction

function x = partial_sumC(y, j)
  ind = 0:j;
  x = ind.^2*y(1:j+1)';
endfunction

function x = partial_sumD(y, j)
  ind = 0:j;
  x = ind.^3*y(1:j+1)';
endfunction

function b = bimodtest(y)
  len = length(y);
  b = %f;
  modes = 0;

  for k = 2:len-1
    if y(k-1) < y(k) & y(k+1) < y(k)
      modes = modes+1;
      if modes > 2 then
        return
      end
    end
  end

  if modes == 2 then
    b = %t;
  end
endfunction

function y = flocmax(x)
  len = length(x);
  y = zeros(1,len);

  for k = 2:len-1
    [dummy, ind] = max(x(k-1:k+1));
    if ind == 2 then
      y(k) = 1;
    end
  end
endfunction

function E = hbalance(y, ind)
  n = length(y)-1;
  E = partial_sumA(y,ind)*(partial_sumA(y,n)-partial_sumA(y,ind));
endfunction

function H = hconvhull(h)
  len = length(h);
  K(1) = 1;
  k = 1;

  while K(k) <> len
    theta = zeros(1,len-K(k));
    for i = K(k)+1:len
      x = i-K(k);
      y = h(i)-h(K(k));
      theta(i-K(k)) = atan(y, x);
    end

    maximum = max(theta);
    maxloc = find(theta==maximum);
    k = k+1;
    K(k) = maxloc($)+K(k-1);
  end

  H = zeros(1,len);
  for i = 2:length(K)
    H(K(i-1):K(i)) = h(K(i-1))+(h(K(i))-h(K(i-1)))/(K(i)-K(i-1))*(0:K(i)-K(i-1));
  end
endfunction

function x = negativeE(y, j)
  y = y(1:j+1);
  y = y(y<>0);
  x = sum(y.*log10(y));
endfunction




function result = islogical(x)
    result = (type(x) == 4);
endfunction

function result = isinteger(x)
    result = (type(x) == 8);
endfunction

function result = isfloat(x)
    result = (type(x) == 1);
endfunction

function result = isscalar(x)
    result = (size(x, 1) == 1 & size(x, 2) == 1);
endfunction

function result = isnumeric(x)
    result = or(type(x) == [1, 5, 8]);
endfunction

function result = issparse(x)
    result = (type(x) == 5);
endfunction
