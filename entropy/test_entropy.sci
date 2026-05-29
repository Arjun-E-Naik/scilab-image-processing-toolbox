clc;
clear;
exec('entropy.sci', -1);


// TEST 1 : Constant image
// Entropy should be 0


disp("TEST 1");

I=uint8(ones(25,25)*32);

e=entropy(I);

disp(e);

assert_checkequal(round(e*1000)/1000,0);

disp("PASS");



// TEST 2 : Binary image
// p=[0.5,0.5]
// entropy=1 bit


disp("TEST 2");

I=zeros(100,100);

I(:,1:50)=0;

I(:,51:100)=255;

I=uint8(I);

e=entropy(I);

disp(e);

assert_checkalmostequal(e,1,0.01);

disp("PASS");




// TEST 3 : Uniform random image
// entropy should be near 8


disp("TEST 3");

I=uint8(round(rand(500,500)*255));

e=entropy(I);

disp(e);

if e<7 | e>8.2 then
    error("Unexpected entropy");
end

disp("PASS");




// TEST 4 : Double image support


disp("TEST 4");

I=rand(200,200);

e=entropy(I);

disp(e);

disp("PASS");




// TEST 5 : Natural logarithm base


disp("TEST 5");

I=uint8(round(rand(100,100)*255));

e=entropy(I,%e);

disp(e);

disp("PASS");




// TEST 6 : Base 10


disp("TEST 6");

e=entropy(I,10);

disp(e);

disp("PASS");




// TEST 7 : Joint entropy


disp("TEST 7");

I1=uint8(round(rand(100,100)*255));

I2=uint8(round(rand(100,100)*255));

e=entropy(I1,I2);

disp(e);

disp("PASS");




// TEST 8
// Joint entropy identical images
//
// H(X,X)=H(X)


disp("TEST 8");

I=uint8(round(rand(100,100)*255));

e1=entropy(I);

e2=entropy(I,I);

disp(e1);
disp(e2);

assert_checkalmostequal(e1,e2,0.1);

disp("PASS");




// TEST 9
// Joint entropy independent images
//
// H(X,Y)=H(X)+H(Y)


disp("TEST 9");

I1=uint8(round(rand(500,500)*255));

I2=uint8(round(rand(500,500)*255));

hx=entropy(I1);

hy=entropy(I2);

hxy=entropy(I1,I2);

disp(hx);
disp(hy);
disp(hxy);

assert_checkalmostequal(...
hxy,...
hx+hy,...
0.5);

disp("PASS");





// TEST 10
// single pixel image


disp("TEST 10");

I=uint8(55);

e=entropy(I);

disp(e);

assert_checkequal(e,0);

disp("PASS");





// TEST 11
// uint16 support


disp("TEST 11");

I=uint16(round(rand(100,100)*65535));

e=entropy(I);

disp(e);

disp("PASS");





// TEST 12
// int16 support


disp("TEST 12");

I=int16(round(rand(100,100)*1000));

e=entropy(I);

disp(e);

disp("PASS");





// TEST 13
// all gray levels equally present

// Expected entropy=8


disp("TEST 13");

I=zeros(256,256);

for i=1:256

    I(i,:)=i-1;

end

I=uint8(I);

e=entropy(I);

disp(e);

assert_checkalmostequal(e,8,0.01);

disp("PASS");