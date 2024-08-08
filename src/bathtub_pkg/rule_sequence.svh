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

`ifndef __RULE_SEQUENCE_SVH
`define __RULE_SEQUENCE_SVH

`include "bathtub_pkg/rule_sequence_interface.svh"

typedef class context_sequence;
`include "bathtub_pkg/context_sequence.svh"

typedef class gherkin_document_runner;
`ifndef __GHERKIN_DOCUMENT_RUNNER_SVH
// Prevent `include recursion
`include "bathtub_pkg/gherkin_document_runner/gherkin_document_runner.svh"
`endif // __GHERKIN_DOCUMENT_RUNNER_SVH

class rule_sequence extends context_sequence implements rule_sequence_interface;
	gherkin_pkg::rule rule;
	gherkin_document_runner runner;

	function new(string name="rule_sequence");
		super.new(name);
		rule = null;
		runner = null;
	endfunction : new

	`uvm_object_utils(rule_sequence)

	virtual function void configure(gherkin_pkg::rule rule, gherkin_document_runner runner);
		this.rule = rule;
		this.runner = runner;
	endfunction : configure

	virtual task body();
		gherkin_pkg::background rule_background;
		gherkin_pkg::scenario_definition only_scenarios[$];
		
		// Separate background from scenario definitions
		only_scenarios.delete();
		foreach (rule.scenario_definitions[i]) begin
			if ($cast(rule_background, rule.scenario_definitions[i])) begin
				assert_only_one_background : assert (runner.rule_background == null) else
					`uvm_fatal_context_begin(get_name(), "Found more than one background definition", runner.report_object)
					`uvm_message_add_string(runner.rule_background.get_scenario_definition_name(), "Existing background")
					`uvm_message_add_string(rule_background.get_scenario_definition_name(), "Conflicting background")
					`uvm_fatal_context_end
				runner.rule_background = rule_background;
			end
			else begin
				only_scenarios.push_back(rule.scenario_definitions[i]);
			end
		end
			
		foreach(only_scenarios[i]) begin
			only_scenarios[i].accept(runner);
		end
	endtask : body
	
endclass : rule_sequence

`endif // __RULE_SEQUENCE_SVH
