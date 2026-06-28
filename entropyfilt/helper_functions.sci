
// HELPER FUNCTIONS


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

function result = iscolormap(x)
    [nr, nc] = size(x);
    result = (nc == 3 & nr > 0);
    if (result) then
        result = (min(x) >= 0 & max(x) <= 1);
    end
endfunction

function bool = isind(img)
    bool = %f;
    im_is_valid = (or(type(img) == [1, 5, 8]) | type(img) == 4) & ndims(img) >= 2;
    if (im_is_valid & ndims(img) < 5 & size(img, 3) == 1) then
        if (type(img) == 1) then
            bool = and((img == floor(img)) & (img > 0), "*");
        elseif (or(inttype(img) == [11, 12])) then
            bool = %t;
        end
    end
endfunction

function m = intmin(cls)
    select cls
    case "uint8" then m = 0;
    case "uint16" then m = 0;
    case "int8" then m = -128;
    case "int16" then m = -32768;
    case "int32" then m = -2147483648;
    case "uint32" then m = 0;
    case "int64" then m = -9223372036854775808;
    case "uint64" then m = 0;
    else
        error("intmin: unsupported class " + cls);
    end
endfunction

function m = intmax(cls)
    select cls
    case "uint8" then m = 255;
    case "uint16" then m = 65535;
    case "int8" then m = 127;
    case "int16" then m = 32767;
    case "int32" then m = 2147483647;
    case "uint32" then m = 4294967295;
    case "int64" then m = 9223372036854775807;
    case "uint64" then m = 18446744073709551615;
    else
        error("intmax: unsupported class " + cls);
    end
endfunction

function cls = class(x)
    t = type(x);
    select t
    case 1 then cls = "double";
    case 4 then cls = "logical";
    case 5 then cls = "sparse";
    case 8 then
        it = inttype(x);
        select it
        case 11 then cls = "uint8";
        case 12 then cls = "uint16";
        case 13 then cls = "uint32";
        case 14 then cls = "uint64";
        case 2 then cls = "int16";
        case 4 then cls = "int32";
        case 8 then cls = "int64";
        case 1 then cls = "int8";
        else
            cls = "unknown_integer";
        end
    case 10 then cls = "string";
    else
        cls = "unknown";
    end
endfunction
