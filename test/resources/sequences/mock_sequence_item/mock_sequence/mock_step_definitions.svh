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
    `Given("a step definition with parameters %d, %f, and %s")

    `uvm_object_utils(mock_step_def_vseq)
    function new (string name="mock_step_def_vseq");
        super.new(name);
    endfunction : new

    virtual task body();
        int d;
        real f;
        string s;
        mock_int_sequence_item d_item;
        mock_real_sequence_item f_item;
        mock_string_sequence_item s_item;

        `step_parameter_get_args_begin()
        d = `step_parameter_get_next_arg_as(int);
        f = `step_parameter_get_next_arg_as(real);
        s = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end

        `uvm_create_on(d_item, p_sequencer.mock_int_sqr)
        d_item.set_payload(d);
        `uvm_send(d_item)

        `uvm_create_on(f_item, p_sequencer.mock_real_sqr)
        f_item.set_payload(f);
        `uvm_send(f_item)

        `uvm_create_on(s_item, p_sequencer.mock_string_sqr)
        s_item.set_payload(s);
        `uvm_send(s_item)
    endtask : body
endclass : mock_step_def_vseq

`endif // __MOCK_STEP_DEFINITIONS_SVH
