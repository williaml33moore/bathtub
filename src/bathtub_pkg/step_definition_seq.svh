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

`ifndef __STEP_DEFINITION_SEQ_SVH
`define __STEP_DEFINITION_SEQ_SVH

import uvm_pkg::*;

`include "bathtub_macros.sv"

typedef class step_nature;
`include "bathtub_pkg/step_nature.svh"

typedef class step_parameters;
`include "bathtub_pkg/step_parameters.svh"

// Interface for step parameters
`include "bathtub_pkg/step_parameters_interface.svh"

// Interface for step definitions
`include "bathtub_pkg/step_definition_interface.svh"

virtual class step_definition_seq extends uvm_sequence implements step_definition_interface;
    static step_static_attributes_interface __step_static_attributes = step_nature::register_step(\* , "abstract step definition class", null, 1'b0);

    step_attributes_interface __step_attributes;

    virtual function step_static_attributes_interface get_step_static_attributes();
        return null;
    endfunction : get_step_static_attributes

    virtual function step_attributes_interface get_step_attributes();
        return null;
    endfunction : get_step_attributes

    virtual function void set_step_attributes(step_attributes_interface step_attributes);
    endfunction : set_step_attributes

    virtual function test_sequence_interface get_current_test_sequence();
        return null;
    endfunction : get_current_test_sequence

    virtual function void set_current_test_sequence(test_sequence_interface seq);
    endfunction : set_current_test_sequence

    virtual function rule_sequence_interface get_current_rule_sequence();
        return null;
    endfunction : get_current_rule_sequence

    virtual function void set_current_rule_sequence(rule_sequence_interface seq);
    endfunction : set_current_rule_sequence

    virtual function feature_sequence_interface get_current_feature_sequence();
        return null;
    endfunction : get_current_feature_sequence

    virtual function void set_current_feature_sequence(feature_sequence_interface seq);
    endfunction : set_current_feature_sequence

    virtual function scenario_sequence_interface get_current_scenario_sequence();
        return null;
    endfunction : get_current_scenario_sequence

    virtual function void set_current_scenario_sequence(scenario_sequence_interface seq);
    endfunction : set_current_scenario_sequence

    // Declare the correct virtual sequencer type here
    `uvm_declare_p_sequencer(uvm_sequencer)

    function new (string name="step_definition_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_error("PENDING", "** Write code that performs this step's actions here **")
    endtask : body
endclass : step_definition_seq

`endif // __STEP_DEFINITION_SEQ_SVH
