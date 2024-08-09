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

`ifndef __SCENARIO_SEQUENCE_SVH
`define __SCENARIO_SEQUENCE_SVH

`include "bathtub_pkg/scenario_sequence_interface.svh"

typedef class gherkin_document_runner;
`ifndef __GHERKIN_DOCUMENT_RUNNER_SVH
// Prevent `include recursion
`include "bathtub_pkg/gherkin_document_runner/gherkin_document_runner.svh"
`endif // __GHERKIN_DOCUMENT_RUNNER_SVH

typedef class context_sequence;
`include "bathtub_pkg/context_sequence.svh"

class scenario_sequence extends context_sequence implements scenario_sequence_interface;
	gherkin_pkg::scenario scenario;
	gherkin_document_runner runner;
	feature_sequence_interface current_feature_seq;

	function new(string name="scenario_sequence");
		super.new(name);
		scenario = null;
		runner = null;
		current_feature_seq = null;
	endfunction : new

	`uvm_object_utils(scenario_sequence)

	virtual function void configure(gherkin_pkg::scenario scenario, gherkin_document_runner runner, feature_sequence_interface current_feature_seq);
		this.scenario = scenario;
		this.runner = runner;
		this.current_feature_seq = current_feature_seq;
	endfunction : configure

	virtual function void set_current_feature_sequence(feature_sequence_interface seq);
		this.current_feature_seq = seq;
	endfunction : set_current_feature_sequence

	virtual function feature_sequence_interface get_current_feature_sequence();
		return this.current_feature_seq;
	endfunction : get_current_feature_sequence

	virtual task body();
		if (scenario != null) begin

			if (runner.feature_background != null) begin
				runner.feature_background.accept(runner); // runner.visit_feature_background(runner.feature_background)
			end

			if (runner.rule_background != null) begin
				runner.rule_background.accept(runner); // runner.visit_feature_background(runner.rule_background)
			end

			for (int i = 0; i < scenario.get_steps().size(); i++) begin
				scenario.get_steps().get(i).accept(runner); // runner.visit_step(scenario.get_steps().get(i))
			end

		end
	endtask : body

endclass : scenario_sequence

`endif // __SCENARIO_SEQUENCE_SVH
