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

`ifndef __GHERKIN_PARSER_RULES_TEST_SVH
`define __GHERKIN_PARSER_RULES_TEST_SVH

typedef class gherkin_parser_env;
`include "gherkin_parser_env.svh"

class gherkin_parser_rules_test extends uvm_test;
    `uvm_component_utils(gherkin_parser_rules_test)
    gherkin_parser_env env; // uvm_env containing the virtual sequencer
    bathtub_pkg::bathtub bathtub;
    string step_sb[$]; // Simple scoreboard for steps

    function new(string name = "gherkin_parser_rules_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        bathtub = bathtub_pkg::bathtub::type_id::create("bathtub", this);
        super.build_phase(phase);
        env = gherkin_parser_env::type_id::create("env", this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        bathtub.configure(env.mock_seqr);
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

                for (int i = 0; i < 7; i++) begin
                    exp_step_index = i;
                    phase.raise_objection(this);
                    env.mock_seqr.get_next_item(item);
                    env.mock_seqr.item_done();

                    `uvm_info(get_name(), "Got one!", UVM_NONE)
                    assert ($cast(obj_item, item));
                    assert ($cast(actual_step_def, obj_item.get_payload()));
                    step_text = actual_step_def.get_step_attributes().get_step().get_text();
                    `uvm_info(get_name(), step_text, UVM_MEDIUM)
                    step_sb.push_back(step_text);
                    phase.drop_objection(this);
                end
            end
        join
    endtask : run_phase

    virtual function void check_phase(uvm_phase phase);
        string exp_steps[$];
        int indexes[$];

        exp_steps = '{
            "Step 0", "Step 1", "Step 2",
            "Step 0", "Step 3",
            "Step 0", "Step 4"
            };

        `uvm_info(get_name(), $sformatf("Exp step strings '%p'", exp_steps), UVM_MEDIUM)
        `uvm_info(get_name(), $sformatf("Act step strings '%p'", step_sb), UVM_MEDIUM)
        
        foreach (exp_steps[i]) begin
            // Find and remove expected steps from scoreboard
            indexes = step_sb.find_first_index() with (item == exp_steps[i]);
            if (indexes.size() >= 1)
                step_sb.delete(indexes[0]);
            else
                `uvm_error(get_name(), $sformatf("Scoreboard does not contain expected step string '%s'", exp_steps[i]))
        end
        check_sb_empty : assert (step_sb.size() == 0) else
            `uvm_error(get_name(), $sformatf("Scoreboard contains unexpected step strings '%p'", step_sb))
        
    endfunction : check_phase

endclass : gherkin_parser_rules_test

`endif // __GHERKIN_PARSER_RULES_TEST_SVH
  