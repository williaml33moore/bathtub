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

`ifndef __MOCK_BASE_VSEQ_SVH
`define __MOCK_BASE_VSEQ_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

typedef class mock_int_sequence_item;
`include "mock_sequence_item.svh"

typedef class mock_vsequencer;
`include "mock_vsequencer.svh"

class mock_base_vseq extends uvm_sequence#(mock_int_sequence_item);

    `uvm_object_utils(mock_base_vseq)
    `uvm_declare_p_sequencer(mock_vsequencer)
    
    function new (string name="mock_base_vseq");
        super.new(name);
    endfunction : new
endclass : mock_base_vseq

`endif // __MOCK_BASE_VSEQ_SVH
