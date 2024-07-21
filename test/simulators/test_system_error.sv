`timescale 1s/1ms

program test_system_error();

function void main();
    static string magic_string = "test_system_error_97531";
    $error(magic_string);
endfunction : main

initial main();
endprogram : test_system_error
