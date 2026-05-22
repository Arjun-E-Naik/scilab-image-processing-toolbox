
exec('psnr.sci', -1);   


//Grayscale uint8 – two different images

A_uint8 = uint8([10 20; 30 40]);
ref_uint8 = uint8([12 22; 28 38]);   // small differences

[psnr_val, mse_val] = psnr(A_uint8, ref_uint8);
disp('Test 1: uint8, different');
disp(['PSNR = ', string(psnr_val), ' dB']);
disp(['MSE  = ', string(mse_val)]);
// Expected: peak = 255, mse  = 4
// PSNR  = 42.1 dB


// 2. Grayscale double 

A_dbl = uint16([0.1 0.2; 0.3 0.4]);
ref_dbl = uint16([0.11 0.21; 0.29 0.39]);

[psnr_val, mse_val] = psnr(A_dbl, ref_dbl);
disp('Test 2: double [0,1], auto peak');
disp(['PSNR = ', string(psnr_val), ' dB']);
// peak=1, mse = 0.0001
// PSNR = 40 dB


// 3. Manual peak override 

A_man = uint8([0 255; 128 64]);
ref_man = A_man;  
[psnr_val, mse_val] = psnr(A_man, ref_man, 100);  
disp('Test 3: manual peak (100) with identical images');
disp(['PSNR = ', string(psnr_val)]);



// 4. Identical images 

A_id = uint8([1 2; 3 4]);
[psnr_val, mse_val] = psnr(A_id, A_id);
disp('Test 4: identical images');
disp(['PSNR = ', string(psnr_val)]);



// 5. RGB image (uint8) – auto peak

rgb_A = uint8(zeros(2,2,3));
rgb_A(:,:,1) = [10 20; 30 40];
rgb_A(:,:,2) = [15 25; 35 45];
rgb_A(:,:,3) = [12 22; 32 42];

rgb_ref = uint8(zeros(2,2,3));
rgb_ref(:,:,1) = [11 21; 31 41];
rgb_ref(:,:,2) = [14 24; 34 44];
rgb_ref(:,:,3) = [13 23; 33 43];

[psnr_val, mse_val] = psnr(rgb_A, rgb_ref);
disp('Test 5: RGB uint8 image');
disp(['PSNR = ', string(psnr_val), ' dB']);
disp(['MSE = ', string(mse_val)]);
// per-channel MSE:=1; similarly for ch2, ch3
// Average MSE = 1, peak=255 , PSNR = 48.13 dB


// 6. Error handling: different sizes

A_small = uint8([1 2; 3 4]);
A_large = uint8([1 2 3; 4 5 6]);
ierr = execstr("[psnr_val, mse_val] = psnr(A_small, A_large);", "errcatch");
if ierr <> 0 then
    disp('Test 6: different sizes – correctly caught error');
    disp(lasterror());
else
    disp('Test 6 FAILED: error should have been thrown');
end


// 7. Unsupported class 

A_int32 = int32([1 2; 3 4]);
ref_int32 = int32([1 2; 3 4]);
ierr = execstr("[psnr_val, mse_val] = psnr(A_int32, ref_int32);", "errcatch");
if ierr <> 0 then
    disp('Test 7: unsupported class – correctly caught error');
    disp(lasterror());
else
    disp('Test 7 FAILED: error should have been thrown');
end

disp('All tests completed.');