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
	typedef class gherkin_parser;
	typedef class gherkin_document_printer;
	typedef class gherkin_document_runner;

	class bathtub extends uvm_object;

		string feature_files[$];

		gherkin_doc_bundle gherkin_docs[$];
		uvm_sequencer_base sequencer;
		uvm_sequence_base parent_sequence;
		int sequence_priority;
		bit sequence_call_pre_post;
		bit dry_run;
		int starting_scenario_number;
		int stopping_scenario_number;

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
			sequence_priority = -1;
			sequence_call_pre_post = 1;
			dry_run = 0;
			starting_scenario_number = 0;
			stopping_scenario_number = 0;
		endfunction : new


		virtual function void configure(
				uvm_sequencer_base sequencer,
				uvm_sequence_base parent_sequence = null,
				int sequence_priority = -1,
				bit sequence_call_pre_post = 1
			);
			this.sequencer = sequencer;
			this.parent_sequence = parent_sequence;
			this.sequence_priority = sequence_priority;
			this.sequence_call_pre_post = sequence_call_pre_post;
		endfunction : configure


      virtual task run_test(uvm_phase phase);
			gherkin_doc_bundle gherkin_doc_bundle;
			gherkin_parser parser;
			gherkin_document_printer printer;
			gherkin_document_runner runner;

			foreach (feature_files[i]) begin : iterate_over_feature_files
				
				`uvm_info(`get_scope_name(-2), {"Feature file: ", feature_files[i]}, UVM_HIGH)

				parser = gherkin_parser::type_id::create("parser");
				parser.parse_feature_file(feature_files[i], gherkin_doc_bundle);

				assert_gherkin_doc_is_not_null : assert (gherkin_doc_bundle.document);

				if (uvm_get_report_object().get_report_verbosity_level() >= UVM_HIGH) begin
					printer = gherkin_document_printer::create_new("printer", gherkin_doc_bundle.document);
					printer.print();
				end

				runner = gherkin_document_runner::create_new("runner", gherkin_doc_bundle.document);
              runner.configure(sequencer, parent_sequence, sequence_priority, sequence_call_pre_post, phase, dry_run, starting_scenario_number, stopping_scenario_number);
              runner.run();

			end

		endtask : run_test

	endclass : bathtub
