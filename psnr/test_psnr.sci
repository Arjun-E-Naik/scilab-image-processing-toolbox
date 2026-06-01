// =============================================================================
// test_psnr.sci  –  Test suite for psnr.sci (Scilab port of Octave psnr.m)
// =============================================================================
// Run this file inside Scilab with:
//     exec('psnr.sci', -1);   // load helpers + psnr
//     exec('test_psnr.sci');  // run tests
// =============================================================================

exec('psnr.sci', -1);   // load psnr, immse, getrangefromclass

passed = 0;
failed = 0;

function report(name, ok, got, expected)
    if ok then
        mprintf("  [PASS]  %s\n", name);
    else
        mprintf("  [FAIL]  %s  |  got = %g  |  expected ≈ %g\n", name, got, expected);
    end
endfunction

mprintf("\n=============================================================\n");
mprintf(" PSNR Test Suite\n");
mprintf("=============================================================\n\n");

// ─────────────────────────────────────────────────────────────────────────────
// TEST 1 – Identical images → PSNR = +Inf
// ─────────────────────────────────────────────────────────────────────────────
mprintf("Test 1 : Identical uint8 images → PSNR = +Inf\n");
A   = uint8([100 150 200; 50 75 25]);
ref = uint8([100 150 200; 50 75 25]);
p   = psnr(A, ref);
ok  = isinf(p) & p > 0;
report("psnr(identical uint8)", ok, p, %inf);
if ok then passed = passed+1; else failed = failed+1; end

// ─────────────────────────────────────────────────────────────────────────────
// TEST 2 – Known uint8 result
//   A   = [0 0; 0 0]   (black)
//   ref = [255 255; 255 255]  (white)
//   MSE = 255^2 = 65025
//   PSNR = 10*log10(255^2 / 65025) = 10*log10(1) = 0 dB
// ─────────────────────────────────────────────────────────────────────────────
mprintf("\nTest 2 : Black vs. white uint8 image → PSNR = 0 dB\n");
A   = uint8(zeros(2,2));
ref = uint8(255 * ones(2,2));
p   = psnr(A, ref);
expected = 0;
ok  = abs(p - expected) < 1e-6;
report("psnr(black, white, uint8)", ok, p, expected);
if ok then passed = passed+1; else failed = failed+1; end

// ─────────────────────────────────────────────────────────────────────────────
// TEST 3 – Floating-point [0,1] images with known MSE
//   A   = [0 0; 0 0]
//   ref = [1 1; 1 1]
//   peak = 1 (default for double)
//   MSE  = 1
//   PSNR = 10*log10(1/1) = 0 dB
// ─────────────────────────────────────────────────────────────────────────────
mprintf("\nTest 3 : Double [0,1] all-zeros vs. all-ones → PSNR = 0 dB\n");
A   = zeros(2,2);
ref = ones(2,2);
p   = psnr(A, ref);
expected = 0;
ok  = abs(p - expected) < 1e-9;
report("psnr(zeros, ones, double)", ok, p, expected);
if ok then passed = passed+1; else failed = failed+1; end

// ─────────────────────────────────────────────────────────────────────────────
// TEST 4 – Custom peak value
//   A   = [0], ref = [128]
//   peak = 256
//   MSE  = 128^2 = 16384
//   PSNR = 10*log10(256^2 / 16384) = 10*log10(65536/16384) = 10*log10(4)
//        ≈ 6.0206 dB
// ─────────────────────────────────────────────────────────────────────────────
mprintf("\nTest 4 : Custom peak=256, scalar inputs\n");
A   = [0];
ref = [128];
p   = psnr(A, ref, 256);
expected = 10 * log10(4);   // ≈ 6.0206
ok  = abs(p - expected) < 1e-6;
mprintf("         Expected ≈ %.6f dB\n", expected);
report("psnr(0, 128, peak=256)", ok, p, expected);
if ok then passed = passed+1; else failed = failed+1; end

// ─────────────────────────────────────────────────────────────────────────────
// TEST 5 – Both outputs (peaksnr and snr)
//   A = [10 20; 30 40]  ref = [12 18; 32 38]  (peak = 1, double)
//   diff = [-2 2; -2 2]
//   MSE  = (4+4+4+4)/4 = 4
//   signal_power = (100+400+900+1600)/4 = 750
//   peak = 1  →  PSNR = 10*log10(1/4)     ≈ -6.0206 dB
//              SNR  = 10*log10(750/4)   ≈  22.7300 dB
// ─────────────────────────────────────────────────────────────────────────────
mprintf("\nTest 5 : Two outputs (peaksnr & snr), double arrays\n");
A   = [10 20; 30 40];
ref = [12 18; 32 38];
[p, s] = psnr(A, ref);
exp_p = 10 * log10(1/4);
exp_s = 10 * log10(750/4);
ok_p  = abs(p - exp_p) < 1e-6;
ok_s  = abs(s - exp_s) < 1e-6;
mprintf("         Expected peaksnr ≈ %.6f dB\n", exp_p);
mprintf("         Expected snr     ≈ %.6f dB\n", exp_s);
report("peaksnr output", ok_p, p, exp_p);
report("snr output    ", ok_s, s, exp_s);
if ok_p & ok_s then passed = passed+1; else failed = failed+1; end

// ─────────────────────────────────────────────────────────────────────────────
// TEST 6 – uint16 image, peak = 65535 (auto)
//   A = [0], ref = [32768]
//   MSE  = 32768^2 = 1073741824
//   PSNR = 10*log10(65535^2 / 32768^2)
//        = 10*log10((65535/32768)^2)
//        ≈ 10 * 2 * log10(1.999969...) ≈ 6.0204 dB
// ─────────────────────────────────────────────────────────────────────────────
mprintf("\nTest 6 : uint16 image, auto peak = 65535\n");
A   = uint16([0]);
ref = uint16([32768]);
p   = psnr(A, ref);
expected = 10 * log10((65535 / 32768)^2);   // ≈ 6.0204
ok  = abs(p - expected) < 1e-4;
mprintf("         Expected ≈ %.6f dB\n", expected);
report("psnr(uint16, auto peak)", ok, p, expected);
if ok then passed = passed+1; else failed = failed+1; end

// ─────────────────────────────────────────────────────────────────────────────
// Error-handling tests  (expected to throw)
// ─────────────────────────────────────────────────────────────────────────────
mprintf("\n--- Error-handling checks ---\n");

// Mismatched size
err_caught = %f;
try
    psnr(uint8([1 2 3]), uint8([1 2]));
catch
    err_caught = %t;
end
ok = err_caught;
report("size mismatch → error", ok, 0, 0);
if ok then passed = passed+1; else failed = failed+1; end

// Mismatched type
err_caught = %f;
try
    psnr(uint8([1 2]), double([1 2]));
catch
    err_caught = %t;
end
ok = err_caught;
report("type mismatch → error", ok, 0, 0);
if ok then passed = passed+1; else failed = failed+1; end

// Non-scalar peak
err_caught = %f;
try
    psnr(double([1 2]), double([1 2]), [255 255]);
catch
    err_caught = %t;
end
ok = err_caught;
report("non-scalar peak → error", ok, 0, 0);
if ok then passed = passed+1; else failed = failed+1; end

// ─────────────────────────────────────────────────────────────────────────────
// Summary
// ─────────────────────────────────────────────────────────────────────────────
mprintf("\n=============================================================\n");
mprintf(" Results : %d passed,  %d failed  (total %d)\n", passed, failed, passed+failed);
mprintf("=============================================================\n\n");
