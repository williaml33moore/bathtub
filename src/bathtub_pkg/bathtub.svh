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

`ifndef __BATHTUB_SVH
`define __BATHTUB_SVH

import uvm_pkg::*;

typedef class gherkin_parser;
`include "bathtub_pkg/gherkin_parser/gherkin_parser.svh"

typedef class gherkin_document_printer;
`include "bathtub_pkg/gherkin_document_printer/gherkin_document_printer.svh"

typedef class gherkin_document_runner;
`ifndef __GHERKIN_DOCUMENT_RUNNER_SVH
// Prevent `include recursion
`include "bathtub_pkg/gherkin_document_runner/gherkin_document_runner.svh"
`endif // __GHERKIN_DOCUMENT_RUNNER_SVH

typedef class gherkin_doc_bundle;
`include "bathtub_pkg/gherkin_doc_bundle.svh"

typedef class plusarg_options;
`include "bathtub_pkg/plusarg_options.svh"

typedef class test_sequence;
`ifndef __TEST_SEQUENCE_SVH
// Prevent `include recursion
`include "bathtub_pkg/test_sequence.svh"
`endif // __TEST_SEQUENCE_SVH

`include "bathtub_macros.sv"

class bathtub extends uvm_report_object;

	string feature_files[$];

	gherkin_doc_bundle gherkin_docs[$];
	uvm_sequencer_base sequencer;
	uvm_sequence_base parent_sequence;
	int sequence_priority;
	bit sequence_call_pre_post;
	bit dry_run;
	int starting_scenario_number;
	int stopping_scenario_number;
	uvm_verbosity bathtub_verbosity;
	uvm_report_object report_object;
	string include_tags[$];
	string exclude_tags[$];
	test_sequence current_test_seq;
	
	static plusarg_options plusarg_opts = plusarg_options::create().populate();

	`uvm_object_utils_begin(bathtub)
		`uvm_field_queue_string(feature_files, UVM_ALL_ON)
		`uvm_field_int(dry_run, UVM_ALL_ON)
		`uvm_field_int(starting_scenario_number, UVM_ALL_ON)
		`uvm_field_int(stopping_scenario_number, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "bathtub");
		super.new(name);

		feature_files.delete();
		sequencer = null;
		parent_sequence = null;
		sequence_priority = 100;
		sequence_call_pre_post = 1;
		dry_run = 0;
		starting_scenario_number = 0;
		stopping_scenario_number = 0;
		bathtub_verbosity = UVM_MEDIUM;
		include_tags.delete();
		exclude_tags.delete();
		report_object = null;
		current_test_seq = null;
	endfunction : new


	virtual function void configure(
			uvm_sequencer_base sequencer,
			uvm_sequence_base parent_sequence = null,
			int sequence_priority = 100,
			bit sequence_call_pre_post = 1,
			uvm_report_object report_object = null
		);
		this.sequencer = sequencer;
		this.parent_sequence = parent_sequence;
		this.sequence_priority = sequence_priority;
		this.sequence_call_pre_post = sequence_call_pre_post;
		this.report_object = report_object;
	endfunction : configure


	virtual task run_test(uvm_phase phase);

		// Process plusarg overrides
		if (plusarg_opts.num_bathtub_features) feature_files = {feature_files, plusarg_opts.bathtub_features}; // Append
		if (plusarg_opts.has_bathtub_dryrun) dry_run = plusarg_opts.bathtub_dryrun;
		if (plusarg_opts.has_bathtub_start) starting_scenario_number = plusarg_opts.bathtub_start;
		if (plusarg_opts.has_bathtub_stop) stopping_scenario_number = plusarg_opts.bathtub_stop;
		if (plusarg_opts.has_bathtub_verbosity) bathtub_verbosity = plusarg_opts.bathtub_verbosity;
		if (plusarg_opts.num_bathtub_include) include_tags = {include_tags, plusarg_opts.bathtub_include}; // Append
		if (plusarg_opts.num_bathtub_exclude) exclude_tags = {exclude_tags, plusarg_opts.bathtub_exclude}; // Append

		if (report_object == null) report_object = this;
		set_report_verbosity_level(bathtub_verbosity);

		current_test_seq = test_sequence::type_id::create("current_test_seq");
		current_test_seq.set_parent_sequence(parent_sequence);
		current_test_seq.set_sequencer(sequencer);
`ifdef UVM_VERSION_1_0
`elsif UVM_VERSION_1_1
`else
		current_test_seq.set_starting_phase(phase);
`endif
		current_test_seq.set_priority(sequence_priority);

		current_test_seq.configure(this, phase);
		current_test_seq.start(current_test_seq.get_sequencer());
			
`ifdef BATHTUB_VERBOSITY_TEST
		`BATHTUB___TEST_VERBOSITY("bathtub_verbosity_test")
`endif // BATHTUB_VERBOSITY_TEST

	endtask : run_test


	function plusarg_options get_plusarg_opts();
		return plusarg_opts;
	endfunction : get_plusarg_opts

endclass : bathtub

`endif // __BATHTUB_SVH
