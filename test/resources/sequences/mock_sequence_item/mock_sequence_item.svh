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

`ifndef __MOCK_SEQUENCE_ITEM_SVH
`define __MOCK_SEQUENCE_ITEM_SVH

import uvm_pkg::*;

class mock_base_sequence_item extends uvm_sequence_item;

    `uvm_object_utils(mock_base_sequence_item)

    function new (string name = "mock_base_sequence_item");
        super.new(name);
    endfunction : new

endclass : mock_base_sequence_item


class mock_param_sequence_item#(type T=uvm_object, string type_name="uvm_object") extends mock_base_sequence_item;

    local T payload;

    `uvm_object_param_utils(mock_param_sequence_item#(T, type_name))

    function new (string name={"mock_param_sequence_item#(", type_name, ")"});
        super.new(name);
    endfunction : new

    function void set_payload(T payload);
        this.payload = payload;
    endfunction : set_payload

    function T get_payload();
        return this.payload;
    endfunction : get_payload
endclass : mock_param_sequence_item


class mock_int_sequence_item extends mock_param_sequence_item#(int, "int");

    `uvm_object_utils(mock_int_sequence_item)

    function new (string name = "mock_int_sequence_item");
        super.new(name);
    endfunction : new
endclass : mock_int_sequence_item


class mock_real_sequence_item extends mock_param_sequence_item#(real, "real");

    `uvm_object_utils(mock_real_sequence_item)

    function new (string name = "mock_real_sequence_item");
        super.new(name);
    endfunction : new
endclass : mock_real_sequence_item


class mock_string_sequence_item extends mock_param_sequence_item#(string, "string");

    `uvm_object_utils(mock_string_sequence_item)

    function new (string name = "mock_string_sequence_item");
        super.new(name);
    endfunction : new
endclass : mock_string_sequence_item

`endif // __MOCK_SEQUENCE_ITEM_SVH
