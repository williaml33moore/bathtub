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

`ifndef __PLUSARG_BATHTUB_INCLUDE_EXCLUDE_TEST_SVH
`define __PLUSARG_BATHTUB_INCLUDE_EXCLUDE_TEST_SVH

typedef class plusargs_env;
`include "plusargs_env.svh"

class plusarg_bathtub_include_exclude_test extends uvm_test;
    `uvm_component_utils(plusarg_bathtub_include_exclude_test)
    plusargs_env my_plusargs_env; // uvm_env containing the virtual sequencer
    bathtub_pkg::bathtub bathtub;

    function new(string name = "plusarg_bathtub_include_exclude_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bathtub = bathtub_pkg::bathtub::type_id::create("bathtub");
        super.build_phase(phase);
        my_plusargs_env = plusargs_env::type_id::create("my_plusargs_env", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        string step_text_sb[$]; // Simple scoreboard
        string expected_step_string;
        string expected_steps[$];
        string plusargs[$];

        bathtub.configure(my_plusargs_env.mock_seqr);

        fork
            begin : catch_items
                uvm_sequence_item item;
                mock_object_sequence_item obj_item;
                bathtub_pkg::step_definition_interface actual_step_def;
                string step_text;
                int unsigned exp_step_index;

                step_text_sb.delete();

                forever begin
                    my_plusargs_env.mock_seqr.get_next_item(item);
                    my_plusargs_env.mock_seqr.item_done();

                    `uvm_info(get_name(), "Got one!", UVM_NONE)
                    assert ($cast(obj_item, item));
                    assert ($cast(actual_step_def, obj_item.get_payload()));
                    step_text = actual_step_def.get_step_attributes().get_step().get_text();
                    `uvm_info(get_name(), step_text, UVM_MEDIUM)
                    step_text_sb.push_back(step_text);
                end
            end
        join_none

        phase.raise_objection(this);

        bathtub.run_test(phase); // Run Bathtub!
        #1s; // Give ample time for sequences to complete
        disable fork;

        assert(uvm_cmdline_processor::get_inst().get_arg_value("+expected=", expected_step_string)) else begin
            `uvm_error(get_name(), "Missing '+expected=' plusarg")
        end
        uvm_split_string(expected_step_string, ",", expected_steps);

        uvm_cmdline_processor::get_inst().get_plusargs(plusargs);
        `uvm_info(get_name(), $sformatf("Plusargs:\n%p", plusargs), UVM_MEDIUM)
        `uvm_info(get_name(), $sformatf("Expected steps:\n%p", expected_steps), UVM_MEDIUM)
        `uvm_info(get_name(), $sformatf("Actual steps:\n%p", step_text_sb), UVM_MEDIUM)

        // Use an associative array to compare the two queues.
        begin : compare_queues
            int set[string];
            string a[$], b[$];
            string element;

            a = step_text_sb;
            b = expected_steps;
            // Add members of queue A to the set.
            foreach (a[i]) begin
                if (set.exists(a[i])) set[a[i]]++;
                else set[a[i]] = 1;
            end
            // Subtract members of queue B from the set.
            foreach (b[i]) begin
                if (set.exists(b[i])) set[b[i]]--;
                else set[b[i]] = -1;
            end
            // If queues are equal, set should be "empty" in that all element counts should be exactly zero.
            if (set.first(element))
                do
                    check_element : assert(set[element] == 0) else
                        `uvm_error(get_name(), $sformatf("Mismatch on step '%s'", element))
                while (set.next(element));
        end

        phase.drop_objection(this);
    endtask : run_phase

endclass : plusarg_bathtub_include_exclude_test

`endif // __PLUSARG_BATHTUB_INCLUDE_EXCLUDE_TEST_SVH
  