/*
MIT License

Copyright (c) 2024 William L. Moore

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/  

`ifndef __BASIC_SEQUENCE_TEST_SVH
`define __BASIC_SEQUENCE_TEST_SVH

typedef class basic_env;

class basic_sequence_test extends uvm_test;
    `uvm_component_utils(basic_sequence_test)
    basic_env env; // uvm_env containing the virtual sequencer
    bathtub_pkg::bathtub bathtub;

    function new(string name = "basic_sequence_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bathtub = bathtub_pkg::bathtub::type_id::create("bathtub", this);
        super.build_phase(phase);
        env = basic_env::type_id::create("env", this);
        
        uvm_config_db#(uvm_sequence_base)::set(this, "env.seqr.run_phase",
            "default_sequence", bathtub.as_sequence());
    endfunction : build_phase

endclass : basic_sequence_test

`include "basic_env.svh"

`endif // __BASIC_SEQUENCE_TEST_SVH
  