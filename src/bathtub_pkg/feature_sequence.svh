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

`ifndef __FEATURE_SEQUENCE_SVH
`define __FEATURE_SEQUENCE_SVH

`include "bathtub_pkg/feature_sequence_interface.svh"

typedef class context_sequence;
`include "bathtub_pkg/context_sequence.svh"

typedef class gherkin_document_runner;
`ifndef __GHERKIN_DOCUMENT_RUNNER_SVH
// Prevent `include recursion
`include "bathtub_pkg/gherkin_document_runner/gherkin_document_runner.svh"
`endif // __GHERKIN_DOCUMENT_RUNNER_SVH

class feature_sequence extends context_sequence implements feature_sequence_interface;
	protected gherkin_pkg::feature feature;
	protected gherkin_document_runner runner;

	function new(string name="feature_sequence");
		super.new(name);
		feature = null;
		runner = null;
	endfunction : new

	`uvm_object_utils(feature_sequence)

	virtual function void configure(gherkin_pkg::feature feature, gherkin_document_runner runner);
		this.feature = feature;
		this.runner = runner;
	endfunction : configure

	virtual task body();
		if (feature != null) begin
			feature.accept(runner); // runner.visit_feature(feature)
		end
	endtask : body

	virtual function gherkin_pkg::feature get_feature();
		return this.feature;
	endfunction : get_feature
	
endclass : feature_sequence

`endif // __FEATURE_SEQUENCE_SVH
