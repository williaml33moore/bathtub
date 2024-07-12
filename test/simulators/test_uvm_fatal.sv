`timescale 1s/1ms

`include "uvm_macros.svh"

program test_uvm_fatal();

import uvm_pkg::*;

typedef class severity_system_task_cb;
`include "severity_system_task_cb.svh"

function void main();
    static severity_system_task_cb cb = severity_system_task_cb::instantiate("cb").add();
    static string magic_string = "test_uvm_fatal_55572";
    `uvm_fatal("", magic_string);
endfunction : main

initial main();
endprogram : test_uvm_fatal
