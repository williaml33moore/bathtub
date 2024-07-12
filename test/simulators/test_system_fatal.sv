`timescale 1s/1ms

program test_system_fatal();

function void main();
    static string magic_string = "test_system_fatal_10101";
    $fatal(0, magic_string);
endfunction : main

initial main();
endprogram : test_system_fatal
