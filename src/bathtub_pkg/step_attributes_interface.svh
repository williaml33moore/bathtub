/*
MIT License

Copyright (c) 2023 Everactive

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

`ifndef __STEP_ATTRIBUTES_INTERFACE_SVH
`define __STEP_ATTRIBUTES_INTERFACE_SVH

import uvm_pkg::*;

typedef interface class test_sequence_interface;
typedef interface class feature_sequence_interface;
typedef interface class rule_sequence_interface;
typedef interface class scenario_sequence_interface;

(* doc$markdown = "\
\ Interface for the step's run-time attributes object.\n\
\ \n\
\ When Bathtub runs the user's step definition, Bathtub provisions the step with a run-time step attributes object.\n\
\ The attributes object implements the methods in this `step_attributes_interface` interface class.\n\
\ The step definition can use these methods to access the step attributes through the attributes object.\n\
\ However, all these methods are more conveniently accessed through the step definition's own `step_definition_interface` methods.\n\
\ The default `step_definition_interface` implementation delegates to the respective methods here in the step attributes object.\n\
\ \n\
\ The run-time attributes are in contrast to the static step attributes, which are accessed through a different interface.\n\
\ "*)
interface class step_attributes_interface;
    // ===================================

    (* doc$markdown = "\
    \ Gets a reference to the Gherkin step object.\n\
    \ \n\
    \ Returns a reference to a `gherkin_pkg::step` object which contains the step text and any arguments parsed from the Gherkin feature file.\n\
    \ "*)
    pure virtual function gherkin_pkg::step get_step();
        // --------------------------------------------

    (* doc$markdown = "\
    \ Gets a reference to the current scenario context sequence.\n\
    \ \n\
    \ Returns a reference to the scenario-level context sequence, whose life spans the duration of the currently running Gherkin scenario.\n\
    \ The scenario-level context holds a reference to the `gherkin_pkg::scenario` object representing the current scenario.\n\
    \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
    \ If the scenario is part of a rule, the rule-level sequence is the scenario-level sequence's parent sequence.\n\
    \ If there is no rule, the feature-level sequence is the scenario-level sequence's parent sequence.\n\
    \ The scenario-level sequence is the parent of the step definition sequence.\n\
    \ "*)
    pure virtual function scenario_sequence_interface get_current_scenario_sequence();
        // ---------------------------------------------------------------------------

    (* doc$markdown = "\
    \ Gets a reference to the current rule context sequence.\n\
    \ \n\
    \ Returns a reference to the rule-level context sequence, whose life spans the duration of the currently running Gherkin rule.\n\
    \ If there is no rule, `get_current_rule_sequence()` returns null.\n\
    \ The rule-level context holds a reference to the `gherkin_pkg::rule` object representing the current rule.\n\
    \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
    \ The rule-level context has the third highest scope.\n\
    \ The feature-level sequence is the rule-level sequence's parent sequence.\n\
    \ "*)
    pure virtual function rule_sequence_interface get_current_rule_sequence();
        // -------------------------------------------------------------------

    (* doc$markdown = "\
    \ Gets a reference to the current feature context sequence.\n\
    \ \n\
    \ Returns a reference to the feature-level context sequence, whose life spans the duration of the currently running Gherkin feature.\n\
    \ The feature-level context holds a reference to the `gherkin_pkg::feature` object representing the current feature file.\n\
    \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
    \ The feature-level context has the second highest scope.\n\
    \ The test-level sequence is the feature-level sequence's parent sequence.\n\
    \ "*)
    pure virtual function feature_sequence_interface get_current_feature_sequence();
        // -------------------------------------------------------------------------

    (* doc$markdown = "\
    \ Gets a reference to the test context sequence.\n\
    \ \n\
    \ Returns a reference to the test-level context sequence, whose life spans the duration of the Bathtub test run.\n\
    \ The test-level context holds a reference to the Bathtub object.\n\
    \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
    \ The test-level context has the highest scope.\n\
    \ "*)
    pure virtual function test_sequence_interface get_current_test_sequence();
        // -------------------------------------------------------------------

    (* doc$markdown = "\
    \ Prints the values of the attributes object.\n\
    \ \n\
    \ Prints the values of the attributes object with the given `verbosity`.\n\
    \ Prints with the default UVM report object, not Bathtub's dedicated report object.\n\
    \ "*)
    pure virtual function void print_attributes(uvm_verbosity verbosity);
        // --------------------------------------------------------------
endclass : step_attributes_interface

`ifndef __TEST_SEQUENCE_INTERFACE_SVH
`include "bathtub_pkg/test_sequence_interface.svh"
`endif // __TEST_SEQUENCE_INTERFACE_SVH

`ifndef __FEATURE_SEQUENCE_INTERFACE_SVH
`include "bathtub_pkg/feature_sequence_interface.svh"
`endif // __FEATURE_SEQUENCE_INTERFACE_SVH

`ifndef __RULE_SEQUENCE_INTERFACE_SVH
`include "bathtub_pkg/rule_sequence_interface.svh"
`endif // __RULE_SEQUENCE_INTERFACE_SVH

`ifndef __SCENARIO_SEQUENCE_INTERFACE_SVH
`include "bathtub_pkg/scenario_sequence_interface.svh"
`endif // __SCENARIO_SEQUENCE_INTERFACE_SVH

`endif // __STEP_ATTRIBUTES_INTERFACE_SVH
