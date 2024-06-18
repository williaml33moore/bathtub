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

`ifndef __MOCK_SEQUENCER_SVH
`define __MOCK_SEQUENCER_SVH

typedef class mock_base_sequencer;
typedef class mock_param_sequencer;
typedef class mock_int_sequencer;
typedef class mock_real_sequencer;
typedef class mock_string_sequencer;
typedef class mock_object_sequencer;


import uvm_pkg::*;

class mock_base_sequencer extends uvm_sequencer;

    `uvm_component_utils(mock_base_sequencer)

    function new (string name = "mock_base_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : mock_base_sequencer


class mock_param_sequencer#(type T=uvm_object, string type_name="uvm_object") extends mock_base_sequencer;

    local T payload;

    `uvm_component_param_utils(mock_param_sequencer)

    function new (string name={"mock_param_sequence_item#(", type_name, ")"}, uvm_component parent);
        super.new(name, parent);
    endfunction : new
endclass : mock_param_sequencer


class mock_int_sequencer extends mock_param_sequencer#(int, "int");

    `uvm_component_param_utils(mock_int_sequencer)

    function new (string name = "mock_int_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new
endclass : mock_int_sequencer


class mock_real_sequencer extends mock_param_sequencer#(real, "real");

    `uvm_component_param_utils(mock_real_sequencer)

    function new (string name = "mock_real_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new
endclass : mock_real_sequencer


class mock_string_sequencer extends mock_param_sequencer#(string, "string");

    `uvm_component_param_utils(mock_string_sequencer)

    function new (string name = "mock_string_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new
endclass : mock_string_sequencer


class mock_object_sequencer extends mock_param_sequencer#(uvm_object, "uvm_object");

    `uvm_component_param_utils(mock_object_sequencer)

    function new (string name = "mock_object_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction : new
endclass : mock_object_sequencer

`endif // __MOCK_SEQUENCER_SVH
