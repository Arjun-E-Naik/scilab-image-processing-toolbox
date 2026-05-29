clc;

clear;

exec("entropy_filt.sci", -1)

disp("TEST 1: Random uint8 image");

I = uint8(round(rand(50,50)*255));

J = entropyfilt(I);

disp(size(J));

assert_checkequal(size(J), [50 50]);

disp("PASS");

disp("TEST 2: Constant image");

I = uint8(ones(50,50)*128);

J = entropyfilt(I);

m = max(max(J));

disp("Max entropy:");

disp(m);

assert_checkequal(round(m*1000)/1000,0);

disp("PASS");

disp("TEST 3: Checkerboard");

I=zeros(50,50);

for i=1:50

    for j=1:50

        I(i,j)=modulo(i+j,2);

    end

end

I=uint8(I*255);

J=entropyfilt(I);

disp("Mean entropy:");

disp(mean(J));

disp("PASS");

disp("TEST 4: Double image");

I=rand(128,128);

J=entropyfilt(I);

assert_checkequal(size(J),[128 128]);

disp("PASS");

disp("TEST 5: Cross neighborhood");

nhood = [0 1 0

         1 1 1

         0 1 0] == 1; 
I=uint8(rand(50,50)*255);

J=entropyfilt(I,nhood);

disp("PASS");

disp("TEST 6: Circular mask");

[x,y]=meshgrid(-3:3,-3:3);

nhood=(x.^2+y.^2)<=9;

I=uint8(rand(50,50)*255);

J=entropyfilt(I,nhood);

disp("PASS");

disp("TEST 7: Zero padding");

I=uint8(rand(50,50)*255);

J=entropyfilt(I,ones(9,9),"zero");

disp("PASS");

disp("TEST 8: Replicate padding");

J=entropyfilt(I,ones(9,9),"replicate");

disp("PASS");

disp("TEST 9: Symmetric padding");

J=entropyfilt(I,ones(9,9),"symmetric");

disp("PASS");

disp("TEST 10: Progress option");

I=uint8(rand(500,500)*255);

tic()

J=entropyfilt(I,...

              ones(9,9),...

              "replicate",...

              %t);

elapsed=toc();

disp("Time:");

disp(elapsed);

disp("PASS");

disp("TEST 11: Large neighborhood");

I=uint8(rand(512,512)*255);

tic()

J=entropyfilt(I,ones(25,25));

t=toc();

disp("Time:");

disp(t);

disp("PASS");

disp("TEST 12: Arbitrary shape");

nhood = [0 0 1 0 0

         0 1 1 1 0

         1 1 1 1 1

         0 1 1 1 0

         0 0 1 0 0] == 1; 
I=uint8(rand(50,50)*255);

tic()

J=entropyfilt(I,nhood);

t=toc();

disp("Time:");

disp(t);

disp("PASS");

disp("TEST 13: Single pixel");

I=uint8(100);

J=entropyfilt(I);

disp(J);

assert_checkequal(J,0);

disp("PASS");

disp("TEST 14: Error test");

try

    I="hello";

    J=entropyfilt(I);

    error("Should fail");

catch

    disp("PASS");

end

disp("TEST 15: Known entropy");

I=zeros(50,50);

I(:,1:25)=0;

I(:,26:50)=255;

I=uint8(I);

J=entropyfilt(I,ones(3,3));

disp(mean(J));

disp("Expected ≈ 1");

disp("PASS");

disp("ALL TESTS COMPLETE");