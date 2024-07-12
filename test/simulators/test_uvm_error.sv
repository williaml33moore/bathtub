`timescale 1s/1ms

`include "uvm_macros.svh"

program test_uvm_error();

import uvm_pkg::*;

typedef class severity_system_task_cb;
`include "severity_system_task_cb.svh"

function void main();
    static severity_system_task_cb cb = severity_system_task_cb::instantiate("cb").add();
    static string magic_string = "test_uvm_error_12321";
    
    `uvm_error("", magic_string)
endfunction : main

initial main();
endprogram : test_uvm_error
