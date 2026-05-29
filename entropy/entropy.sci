function e = entropy(I, varargin)


    [lhs,rhs]=argn(0);

    base=2;
    joint=%f;

    if rhs<1 then
        error("Image required.");
    end

    
    // Parse arguments
    

    if rhs==2 then

        if size(varargin(1),"*")==1 then
            base=varargin(1);
        else
            I2=varargin(1);
            joint=%t;
        end

    elseif rhs==3 then

        I2=varargin(1);
        base=varargin(2);
        joint=%t;

    end

    if base<=0 then
        error("Base must be >0");
    end

    
    
    

    I=convert_uint8(I);

    
    // Standard entropy
    

    if ~joint then

        hist=imhist_fast(I);

        p=hist/sum(hist);

        idx=find(p>0);

        p=p(idx);

        e=-sum(p.*(log(p)/log(base)));

        return

    end

    
    // Joint entropy
    

    I2=convert_uint8(I2);

    if or(size(I)<>size(I2)) then
        error("Images must have same size.");
    end

    jointHist=zeros(256,256);

    pixels=length(I);

    for k=1:pixels

        a=I(k)+1;
        b=I2(k)+1;

        jointHist(a,b)=jointHist(a,b)+1;

    end

    p=jointHist/sum(jointHist);

    idx=find(p>0);

    p=p(idx);

    e=-sum(p.*(log(p)/log(base)));

endfunction




// Convert image to uint8


function I=convert_uint8(I)

    if isreal(I)==0 then
        error("Image must be real.");
    end

    t=type(I);

    if t==1 then

        I=max(0,min(1,I));

        I=uint8(round(I*255));

    elseif t==8 then

        mn=double(min(I));
        mx=double(max(I));

        if mx==mn then

            I=zeros(I,"uint8");
            return

        end

        I=uint8(round(...
        (double(I)-mn)/(mx-mn)*255));

    else

        error("Unsupported image type");

    end

endfunction




// Fast histogram


function h=imhist_fast(I)

    h=zeros(256,1);

    pixels=length(I);

    for k=1:pixels

        h(I(k)+1)=h(I(k)+1)+1;

    end

endfunction