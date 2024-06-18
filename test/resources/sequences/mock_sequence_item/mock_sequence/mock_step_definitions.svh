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

`ifndef __MOCK_STEP_DEFINITIONS_SVH
`define __MOCK_STEP_DEFINITIONS_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "bathtub_macros.sv"
import bathtub_pkg::bathtub_pkg_metadata;

typedef class mock_base_vseq;
`include "mock_base_vseq.svh"


class mock_step_def_vseq extends mock_base_vseq implements bathtub_pkg::step_definition_interface;
    `Given("a step")

    `uvm_object_utils(mock_step_def_vseq)
    function new (string name="mock_step_def_vseq");
        super.new(name);
    endfunction : new

    virtual task body();
        assert (1'b0) else `uvm_error(get_name(), "Placeholder")
    endtask : body
endclass : mock_step_def_vseq

`endif // __MOCK_STEP_DEFINITIONS_SVH
