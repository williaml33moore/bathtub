`timescale 1s/1ms

program test_assert_failure();

function void main();
    assert(0);
endfunction : main

initial main();
endprogram : test_assert_failure
