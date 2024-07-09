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

`ifndef __MOCK_STEP_DEFINITION_SEQS_SVH
`define __MOCK_STEP_DEFINITION_SEQS_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "bathtub_macros.sv"
import bathtub_pkg::bathtub_pkg_metadata;

typedef class mock_base_vseq;
`include "mock_base_vseq.svh"

typedef class mock_base_seq;
`include "mock_base_seq.svh"

typedef class mock_int_sequence_item;
typedef class mock_real_sequence_item;
typedef class mock_string_sequence_item;
typedef class mock_object_sequence_item;
`include "mock_sequence_items.svh"

/*
 * Example of a virtual step definition
 */
virtual class virtual_step_def_seq extends mock_base_seq implements bathtub_pkg::step_definition_interface;
    `virtual_step_definition("Any text goes here")

    function new (string name="virtual_step_def_seq");
        super.new(name);
    endfunction : new

    function void a();
    ;
    endfunction : a
endclass : virtual_step_def_seq


/*
 * Concrete extension of the virtual step definition
 */
class concrete_step_def_seq extends virtual_step_def_seq;
    `Given("AaAaA step text goes here BbBbB")

    `uvm_object_utils(concrete_step_def_seq)
    function new (string name="concrete_step_def_seq");
        super.new(name);
    endfunction : new

    function void b();
        a();
    endfunction : b
endclass : concrete_step_def_seq


/*
 * Driver sequence sends sequence items
 */
class mock_step_def_seq extends mock_base_seq implements bathtub_pkg::step_definition_interface;
    // Catches every step
    `Given("/^.*$/")

    `uvm_object_utils(mock_step_def_seq)
    function new (string name="mock_step_def_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        req = mock_object_sequence_item::type_id::create("req");
        start_item(req);
        // Sends itself as payload to the sequencer
        req.set_payload(this);
        finish_item(req);
    endtask : body
endclass : mock_step_def_seq

`endif // __MOCK_STEP_DEFINITION_SEQS_SVH
