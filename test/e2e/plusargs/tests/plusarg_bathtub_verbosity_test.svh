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

`ifndef __PLUSARG_BATHTUB_VERBOSITY_TEST_SVH
`define __PLUSARG_BATHTUB_VERBOSITY_TEST_SVH

typedef class plusargs_env;
`include "plusargs_env.svh"

class plusarg_bathtub_verbosity_test extends uvm_test;
    `uvm_component_utils(plusarg_bathtub_verbosity_test)
    plusargs_env my_plusargs_env; // uvm_env containing the mock step sequencer
    bathtub_pkg::bathtub bathtub;

    function new(string name = "plusarg_bathtub_verbosity_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bathtub = bathtub_pkg::bathtub::type_id::create("bathtub");
        super.build_phase(phase);
        my_plusargs_env = plusargs_env::type_id::create("my_plusargs_env", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);

        bathtub.configure(my_plusargs_env.mock_seqr);

        `uvm_info("uvm_verbosity_test", $sformatf("UVM_NONE,%0d", UVM_NONE), UVM_NONE)
        `uvm_info("uvm_verbosity_test", $sformatf("UVM_LOW,%0d", UVM_LOW), UVM_LOW)
        `uvm_info("uvm_verbosity_test", $sformatf("UVM_MEDIUM,%0d", UVM_MEDIUM), UVM_MEDIUM)
        `uvm_info("uvm_verbosity_test", $sformatf("UVM_HIGH,%0d", UVM_HIGH), UVM_HIGH)
        `uvm_info("uvm_verbosity_test", $sformatf("UVM_FULL,%0d", UVM_FULL), UVM_FULL)

        fork
            begin
                phase.raise_objection(this);
                bathtub.run_test(phase); // Run Bathtub!
                phase.drop_objection(this);
            end
            
            begin
                uvm_sequence_item item;
                mock_object_sequence_item obj_item;
                bathtub_pkg::step_definition_interface actual_step_def;
                string step_text;

                forever begin
                    phase.raise_objection(this);
                    my_plusargs_env.mock_seqr.get_next_item(item);
                    my_plusargs_env.mock_seqr.item_done();

                    `uvm_info(get_name(), "Got one!", UVM_NONE)
                    assert ($cast(obj_item, item));
                    assert ($cast(actual_step_def, obj_item.get_payload()));
                    step_text = actual_step_def.get_step_attributes().get_step().get_text();
                    phase.drop_objection(this);
                    break;
                end
            end
        join
    endtask : run_phase

endclass : plusarg_bathtub_verbosity_test

`endif // __PLUSARG_BATHTUB_VERBOSITY_TEST_SVH
  