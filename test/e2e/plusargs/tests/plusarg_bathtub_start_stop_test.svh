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

`ifndef __PLUSARG_BATHTUB_START_STOP_TEST_SVH
`define __PLUSARG_BATHTUB_START_STOP_TEST_SVH

`include "bathtub_macros.sv"

typedef class plusargs_env;
`include "plusargs_env.svh"

class plusarg_bathtub_start_stop_test extends uvm_test;
    `uvm_component_utils(plusarg_bathtub_start_stop_test)
    plusargs_env my_plusargs_env; // uvm_env containing the virtual sequencer
    bathtub_pkg::bathtub bathtub;

    function new(string name = "plusarg_bathtub_start_stop_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bathtub = bathtub_pkg::bathtub::type_id::create("bathtub");
        super.build_phase(phase);
        my_plusargs_env = plusargs_env::type_id::create("my_plusargs_env", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        int unsigned num_scenarios;

        // The number of scenarios in the feature file
        num_scenarios = 5; // Default
        void'($value$plusargs("num_scenarios=%d", num_scenarios));

        bathtub.configure(my_plusargs_env.mock_seqr);
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
                int act_step_index;
                int unsigned exp_step_index;
                int plusarg_start;
                int plusarg_stop;
                int start_index;
                int stop_index;

                plusarg_start = bathtub.get_plusarg_opts().has_bathtub_start ? bathtub.get_plusarg_opts().bathtub_start : 0;
                plusarg_stop = bathtub.get_plusarg_opts().has_bathtub_stop ? bathtub.get_plusarg_opts().bathtub_stop : 0;

                start_index = plusarg_start;
                while (start_index < 0) start_index += num_scenarios;
                stop_index = plusarg_stop;
                while (stop_index <= 0) stop_index += num_scenarios;
                if (start_index > num_scenarios) start_index = num_scenarios;
                if (stop_index > num_scenarios) stop_index = num_scenarios;

                `uvm_info_begin(get_name(), "", UVM_MEDIUM)
                `uvm_message_add_int(plusarg_start, UVM_DEC)
                `uvm_message_add_int(plusarg_stop, UVM_DEC)
                `uvm_message_add_int(start_index, UVM_DEC)
                `uvm_message_add_int(stop_index, UVM_DEC)
                `uvm_info_end

                for (int i = start_index; i < stop_index; i++) begin
                    forever begin
                        exp_step_index = i;
                        phase.raise_objection(this);
                        my_plusargs_env.mock_seqr.get_next_item(item);
                        my_plusargs_env.mock_seqr.item_done();

                        `uvm_info(get_name(), "Got one!", UVM_NONE)
                        assert ($cast(obj_item, item));
                        assert ($cast(actual_step_def, obj_item.get_payload()));
                        step_text = actual_step_def.get_step_attributes().get_text();
                        if (step_text == "background") begin
                            phase.drop_objection(this);
                            continue; // Ignore background steps
                        end
                        act_step_index = step_text.atoi();
                        check_step_index : assert (act_step_index == exp_step_index * 10);
                        exp_step_index++;
                        phase.drop_objection(this);
                        break;
                    end
                end
            end
        join
    endtask : run_phase

endclass : plusarg_bathtub_start_stop_test

`endif // __PLUSARG_BATHTUB_START_STOP_TEST_SVH
  