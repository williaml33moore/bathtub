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

`ifndef __TEST_SEQUENCE_SVH
`define __TEST_SEQUENCE_SVH

`include "bathtub_pkg/test_sequence_interface.svh"

typedef class context_sequence;
`include "bathtub_pkg/context_sequence.svh"

typedef class gherkin_document_runner;
`ifndef __GHERKIN_DOCUMENT_RUNNER_SVH
// Prevent `include recursion
`include "bathtub_pkg/gherkin_document_runner/gherkin_document_runner.svh"
`endif // __GHERKIN_DOCUMENT_RUNNER_SVH

typedef class bathtub;
`ifndef __BATHTUB_SVH
// Prevent `include recursion
`include "bathtub_pkg/bathtub.svh"
`endif // __BATHTUB_SVH

class test_sequence extends context_sequence implements test_sequence_interface;
    bathtub bt;
	gherkin_document_runner runner;
    uvm_phase phase;

	function new(string name="test_sequence");
		super.new(name);
        bt = null;
        phase = null;
		runner = null;
	endfunction : new

	`uvm_object_utils(test_sequence)

	virtual function void configure(bathtub bt, uvm_phase phase);
		this.bt = bt;
        this.phase = phase;
	endfunction : configure

	virtual task body();
		gherkin_doc_bundle gherkin_doc_bundle;
		gherkin_parser parser;
		gherkin_document_printer printer;
		gherkin_document_runner runner;
		strings_t feature_files;
		strings_t include_tags;
		strings_t exclude_tags;
		string include_tags_q[$];
		string exclude_tags_q[$];

		include_tags = bt.get_include_tags();
		for (int i = 0; i < include_tags.size(); i++) include_tags_q.push_back(include_tags.get(i));
		exclude_tags = bt.get_exclude_tags();
		for (int i = 0; i < exclude_tags.size(); i++) exclude_tags_q.push_back(exclude_tags.get(i));
		feature_files = bt.get_feature_files();
		for (int i = 0; i < feature_files.size(); i++) begin : iterate_over_feature_files
			gherkin_pkg::step undefined_steps[$];
			
			`uvm_info_context(`BATHTUB__GET_SCOPE_NAME(-2), {"Feature file: ", feature_files.get(i)}, UVM_HIGH, bt.get_report_object())

			parser = gherkin_parser::type_id::create("parser").configure(bt.get_report_object());

			parser.parse_feature_file(feature_files.get(i), gherkin_doc_bundle);

			assert_gherkin_doc_is_not_null : assert (gherkin_doc_bundle.document);

			if (bt.get_report_object().get_report_verbosity_level() >= UVM_HIGH) begin
				printer = gherkin_document_printer::create_new("printer", gherkin_doc_bundle.document);
				printer.print();
			end

			runner = gherkin_document_runner::create_new("runner", gherkin_doc_bundle.document);
			runner.configure(bt.get_sequencer(), this, bt.get_sequence_priority(), bt.get_sequence_call_pre_post(),
				phase, bt.get_dry_run(), bt.get_starting_scenario_number(), bt.get_stopping_scenario_number(),
				include_tags_q, exclude_tags_q, bt.get_report_object());
			runner.run();

			runner.get_undefined_steps(undefined_steps);
			bt.concat_undefined_steps(undefined_steps);
			
`ifdef BATHTUB_VERBOSITY_TEST
			parser.test_verbosity();
			runner.test_verbosity();
`endif // BATHTUB_VERBOSITY_TEST
		end
	endtask : body

endclass : test_sequence

`endif // __TEST_SEQUENCE_SVH
