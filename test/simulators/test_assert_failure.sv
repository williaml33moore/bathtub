`timescale 1s/1ms

program test_assert_failure();

function void main();
    test_assert_failure_24680 : assert(0);
endfunction : main

initial main();
endprogram : test_assert_failure
