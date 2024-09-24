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

`ifndef __BATHTUB_SEQUENCE_SVH
`define __BATHTUB_SEQUENCE_SVH

`include "uvm_macros.svh"

import uvm_pkg::*;

typedef class bathtub;

class bathtub_sequence extends uvm_sequence;
    protected bathtub bt;
	protected bit sequence_call_pre_post;
    protected uvm_phase phase;

	function new (string name="bathtub_sequence");
		super.new(name);
        this.bt = null;
	    this.sequence_call_pre_post = 1'b0;
	endfunction : new

	`uvm_object_utils(bathtub_sequence)

	virtual function void configure (bathtub bt);
		this.bt = bt;
	endfunction : configure

    
`ifndef UVM_VERSION_1_0

virtual task pre_start ();
        super.pre_start();
    
`ifdef UVM_VERSION_1_1
        phase = starting_phase;
`elsif UVM_POST_VERSION_1_1
        phase = get_starting_phase();
`else
        phase = get_starting_phase();
`endif

        if (phase == null) return;

        phase.raise_objection(this);
    endtask : pre_start

`endif // UVM_VERSION_1_0

    virtual task pre_body ();

`ifdef UVM_VERSION_1_0

        phase = starting_phase;
        if (phase != null) begin
            phase.raise_objection(this);
        end

`endif // UVM_VERSION_1_0

        super.pre_body();
        sequence_call_pre_post = 1'b1;

    endtask : pre_body

	virtual task body ();

        precondition_bt_not_null : assert (bt != null) else
            `uvm_fatal("NULL_VAR", "bt is null")

        bt.configure(
			get_sequencer(),
			this,
			get_priority(),
			sequence_call_pre_post
		);

		bt.run_test(phase);
	endtask : body

`ifdef UVM_VERSION_1_0

    virtual task post_body ();
        if (phase == null) return;

        phase.drop_objection(this);
    endtask : post_body

`else // UVM_VERSION_1_0

    virtual task post_start ();
        if (phase == null) return;

        phase.drop_objection(this);
    endtask : post_start

`endif // UVM_VERSION_1_0

	virtual function bathtub get_bathtub_object ();
		return this.bt;
	endfunction : get_bathtub_object

endclass : bathtub_sequence

`ifndef __BATHTUB_SVH
`include "bathtub_pkg/bathtub.svh"
`endif // __BATHTUB_SVH

`endif // __BATHTUB_SEQUENCE_SVH
