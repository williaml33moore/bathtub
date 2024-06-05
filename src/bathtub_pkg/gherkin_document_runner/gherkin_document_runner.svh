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

	class gherkin_document_runner extends uvm_object implements gherkin_pkg::visitor;

		gherkin_pkg::gherkin_document document;
		gherkin_pkg::background feature_background;

		uvm_sequencer_base sequencer;
		uvm_sequence_base parent_sequence;
		feature_sequence current_feature_seq;
		scenario_sequence current_scenario_seq;
		int sequence_priority;
		bit sequence_call_pre_post;
      uvm_phase starting_phase;
		string example_values[string];
		string current_step_keyword;
		bit dry_run;
		int starting_scenario_number;
		int stopping_scenario_number;

		`uvm_object_utils_begin(gherkin_document_runner)
			`uvm_field_object(document, UVM_ALL_ON)
			`uvm_field_int(dry_run, UVM_ALL_ON)
			`uvm_field_int(starting_scenario_number, UVM_ALL_ON | UVM_DEC)
			`uvm_field_int(stopping_scenario_number, UVM_ALL_ON | UVM_DEC)
		`uvm_object_utils_end

		function new(string name = "gherkin_document_runner");
			super.new(name);

			current_feature_seq = null;
			current_scenario_seq = null;
			current_step_keyword = "Given";
			feature_background = null;
			starting_scenario_number = 0;
			stopping_scenario_number = 0;
		endfunction : new


		static function gherkin_document_runner create_new(string name = "gherkin_document_runner", gherkin_pkg::gherkin_document document);
			gherkin_document_runner new_printer;

			new_printer = new(name);
			new_printer.document = document;
			return new_printer;
		endfunction : create_new


		virtual function void configure(
				uvm_sequencer_base sequencer,
				uvm_sequence_base parent_sequence = null,
				int sequence_priority = -1,
				bit sequence_call_pre_post = 1,
          uvm_phase starting_phase,
				bit dry_run = 0,
				int starting_scenario_number = 0,
				int stopping_scenario_number = 0
			);
			this.sequencer = sequencer;
			this.parent_sequence = parent_sequence;
			this.sequence_priority = sequence_priority;
			this.sequence_call_pre_post = sequence_call_pre_post;
          this.starting_phase = starting_phase;
			this.dry_run = dry_run;
			this.starting_scenario_number = starting_scenario_number;
			this.stopping_scenario_number = stopping_scenario_number;
		endfunction : configure


		virtual task run();
			`uvm_info(get_name(), {"\n", sprint()}, UVM_MEDIUM)
			document.accept(this); // visit_gherkin_docment(document)
		endtask : run

		/*
		 * Function: start_step
		 * Executes a sequence passed as Gherkin step.
		 *
		 * Parameters:
		 * wrap - A sequence or sequence item's type as returned by its get_type() method
		 */
		virtual task start_step(gherkin_pkg::step step);

			uvm_object obj;
			uvm_factory factory;
			uvm_sequence_base seq;
			uvm_resource_db#(uvm_object_wrapper)::rsrc_t step_resource;
			uvm_object_wrapper step_seq_object_wrapper;
			step_definition_interface step_seq;
			int success;
			string search_keyword;

			`uvm_info(`get_scope_name(), $sformatf("%s %s", step.keyword, step.text), UVM_MEDIUM)

			if (step.keyword inside {"Given", "When", "Then"}) begin
				// Look for a simple exact match for keyword.
				search_keyword = step.keyword;
			end
			else if (step.keyword inside {"And", "But", "*"}) begin
				// Keyword is syntactic sugar so throw it out and look for the current keyword again.
				search_keyword = current_step_keyword;
			end
			else begin
				`uvm_fatal(get_name(), $sformatf("Illegal step keyword: '%s'", step.keyword))
			end

			`uvm_info_begin(get_name(), "uvm_resource_db search parameters", UVM_HIGH)
          `uvm_message_add_string(step.text)
          `uvm_message_add_string(search_keyword)
			`uvm_info_end
                   
			step_resource = uvm_resource_db#(uvm_object_wrapper)::get_by_name(step.text, STEP_DEF_RESOURCE_NAME, 1);

			assert_step_resource_is_not_null : assert (step_resource) else begin
				if (uvm_get_report_object().get_report_verbosity_level() >= UVM_HIGH) begin
					uvm_resource_db#(uvm_object_wrapper)::dump();
				end
				`uvm_fatal(`get_scope_name(), $sformatf("No match for this step found in `uvm_resource_db`:\n> %s %s", search_keyword, step.text))
			end

			// Success. Update current keyword.
			current_step_keyword = search_keyword;

			step_seq_object_wrapper = step_resource.read();

			factory = uvm_factory::get();

			obj = factory.create_object_by_type(step_seq_object_wrapper, get_full_name(), step_seq_object_wrapper.get_type_name());

			success = $cast(seq ,obj);
			assert_step_object_is_sequence : assert (success) else begin
				`uvm_fatal(`get_scope_name(), $sformatf("Matched an object in `uvm_resource_db` that is not a sequence."))
			end

			if ($cast(step_seq, obj)) begin
				step_nurture step_attributes = step_nurture::type_id::create("step_attributes");
				step_attributes.set_runtime_keyword(step.keyword);
				step_attributes.set_text(step.text);
				step_attributes.set_argument(step.argument);
				step_attributes.set_static_attributes(step_seq.get_step_static_attributes());
				step_attributes.set_current_feature_sequence(current_feature_seq);
				step_attributes.set_current_scenario_sequence(current_scenario_seq);
				step_seq.set_step_attributes(step_attributes);
			end
			else begin
				`uvm_fatal(`get_scope_name(), $sformatf("Matched an object in `uvm_resource_db` that is not a valid step sequence."))
			end

			`uvm_info(get_name(), {"Executing sequence ", seq.get_name(),
					" (", seq.get_type_name(), ")"}, UVM_HIGH)

			seq.print_sequence_info = 1;
			if (!dry_run) begin
              seq.set_starting_phase(starting_phase);
				seq.start(this.sequencer, this.parent_sequence, this.sequence_priority, this.sequence_call_pre_post);
			end

		endtask : start_step

		virtual task visit_background(gherkin_pkg::background background);

			`uvm_info(get_name(), $sformatf("%s: %s", background.keyword, background.scenario_definition_name), UVM_MEDIUM)

			foreach (background.steps[i]) begin
				background.steps[i].accept(this); // visit_step(background.steps[i])
			end

		endtask : visit_background

		/**
		 * @param comment -
		 */
		virtual task visit_comment(gherkin_pkg::comment comment);
		// TODO Auto-generated task stub

		endtask : visit_comment

		/**
		 * @param data_table -
		 */
		virtual task visit_data_table(gherkin_pkg::data_table data_table);
		// TODO Auto-generated task stub

		endtask : visit_data_table

		/**
		 * @param doc_string -
		 */
		virtual task visit_doc_string(gherkin_pkg::doc_string doc_string);
		// TODO Auto-generated task stub

		endtask : visit_doc_string

		/**
		 * @param examples -
		 */
		virtual task visit_examples(gherkin_pkg::examples examples);
		// TODO Auto-generated task stub

		endtask : visit_examples

		virtual task visit_feature(gherkin_pkg::feature feature);
			gherkin_pkg::background feature_background;
			int start;
			int stop;
			gherkin_pkg::scenario_definition only_scenarios[$];

			`uvm_info(get_name(), $sformatf("%s: %s", feature.keyword, feature.feature_name), UVM_MEDIUM);
			
			// Separate background from scenario definitions
			only_scenarios.delete();
			foreach (feature.scenario_definitions[i]) begin
				if ($cast(feature_background, feature.scenario_definitions[i])) begin
					assert_only_one_background : assert (this.feature_background == null) else
						`uvm_fatal_begin(get_name(), "Found more than one background definition")
						`uvm_message_add_string(this.feature_background.scenario_definition_name, "Existing background")
						`uvm_message_add_string(feature_background.scenario_definition_name, "Conflicting background")
						`uvm_fatal_end
					this.feature_background = feature_background;
				end
				else begin
					only_scenarios.push_back(feature.scenario_definitions[i]);
				end
			end

			start = this.starting_scenario_number;
			stop = this.stopping_scenario_number;
			while (start < 0) start += only_scenarios.size();
			if (start > only_scenarios.size()) start = only_scenarios.size();
			while (stop <= 0) stop += only_scenarios.size();
			if (stop > only_scenarios.size()) stop = only_scenarios.size();
				
			for(int i = start; i < stop; i++) begin
				only_scenarios[i].accept(this);
			end

		endtask : visit_feature

		virtual task visit_gherkin_document(gherkin_pkg::gherkin_document gherkin_document);
			current_feature_seq = feature_sequence::type_id::create("current_feature_seq");
			current_feature_seq.set_parent_sequence(parent_sequence);
			current_feature_seq.set_sequencer(sequencer);
			current_feature_seq.set_starting_phase(starting_phase);
			current_feature_seq.set_priority(sequence_priority);

			current_feature_seq.configure(gherkin_document.feature, this);
			current_feature_seq.start(current_feature_seq.get_sequencer());
		endtask : visit_gherkin_document

		virtual task visit_scenario(gherkin_pkg::scenario scenario);

			`uvm_info(get_name(), $sformatf("%s: %s", scenario.keyword, scenario.scenario_definition_name), UVM_MEDIUM)

			current_scenario_seq = scenario_sequence::type_id::create("current_scenario_seq");
			current_scenario_seq.set_parent_sequence(current_feature_seq);
			current_scenario_seq.set_sequencer(sequencer);
			current_scenario_seq.set_starting_phase(starting_phase);
			current_scenario_seq.set_priority(sequence_priority);

			current_scenario_seq.configure(scenario, this, current_feature_seq);
			current_scenario_seq.start(current_scenario_seq.get_sequencer());
		endtask : visit_scenario

		virtual task visit_scenario_definition(gherkin_pkg::scenario_definition scenario_definition);

			// Reset current keyword to default "Given" in case first step is "And" or "But".
			current_step_keyword = "Given";
		endtask : visit_scenario_definition

		virtual task visit_scenario_outline(gherkin_pkg::scenario_outline scenario_outline);

			`uvm_info(get_name(), $sformatf("%s: %s", scenario_outline.keyword, scenario_outline.scenario_definition_name), UVM_MEDIUM)

			foreach (scenario_outline.examples[k]) begin

				foreach (scenario_outline.examples[k].rows[j]) begin
					gherkin_pkg::scenario scenario;
					gherkin_pkg::scenario scenario_definition;
				
					`uvm_info(get_name(), $sformatf("Example #%0d:", j + 1), UVM_MEDIUM)

					example_values.delete();

					// Store the example values in a hash.
					// Put the "<" ears ">" on the key.
					foreach (scenario_outline.examples[k].rows[j].cells[i]) begin
						example_values[{"<", scenario_outline.examples[k].header.cells[i].value, ">"}] = scenario_outline.examples[k].rows[j].cells[i].value;
					end

					// Create a new scenario out of this unrolled scenario outline
                  scenario = gherkin_pkg::scenario::create_new(scenario_outline.get_name(), scenario_outline.scenario_definition_name, scenario_outline.description);
					foreach (scenario_outline.steps[l])
                      scenario.steps.push_back(scenario_outline.steps[l]);
					foreach (scenario_outline.tags[l])
                      scenario.tags.push_back(scenario_outline.tags[l]);
					scenario_definition = scenario;
					// Give our new scenario the full scenario treatment
					scenario_definition.accept(this);

					example_values.delete();

				end

			end

		endtask : visit_scenario_outline


		static function string replace_string(string str, string search, string repl);
			int str_len = str.len();
			int search_len = search.len();
			int i;

			assert_search_string_not_empty : assert (search != "") else
				$fatal(1, "Search string is empty");

			replace_string = "";
			i = 0;
			while (i < str_len) begin
				if (str.substr(i, i + search_len - 1) == search) begin
					replace_string = {replace_string, repl};
					i += search_len;
				end
				else begin
					replace_string = {replace_string, str[i]};
					i++;
				end
			end
		endfunction : replace_string


		virtual task visit_step(gherkin_pkg::step step);
			string example_parameter;
			string replaced_text = step.text;
			gherkin_pkg::step replaced_step;
			gherkin_pkg::data_table data_table;
			gherkin_pkg::doc_string doc_string;
			gherkin_pkg::doc_string replaced_doc_string;

			`uvm_info(get_name(), $sformatf("Before replacement: %s %s", step.keyword, step.text), UVM_HIGH)

			if (example_values.first(example_parameter)) do
					replaced_text = replace_string(replaced_text, example_parameter, example_values[example_parameter]);
				while (example_values.next(example_parameter));

			replaced_step = gherkin_pkg::step::create_new("replaced_step", step.keyword, replaced_text);

			if (step.argument) begin

				if ($cast(data_table, step.argument)) begin
					gherkin_pkg::data_table replaced_data_table;

					replaced_data_table = new("replaced_data_table");

					foreach (data_table.rows[row]) begin
						gherkin_pkg::table_row replaced_table_row;

						replaced_table_row =new("replaced_table_row");
						foreach (data_table.rows[row].cells[col]) begin
							string replaced_cell_value = data_table.rows[row].cells[col].value;

							if (example_values.first(example_parameter)) do
									replaced_cell_value = replace_string(replaced_cell_value, example_parameter, example_values[example_parameter]);
								while (example_values.next(example_parameter));

							replaced_table_row.cells.push_back(gherkin_pkg::table_cell::create_new("anonymous", replaced_cell_value));

						end

						replaced_data_table.rows.push_back(replaced_table_row);

					end

					replaced_step.argument = replaced_data_table;

				end
				else if ($cast(doc_string, step.argument)) begin
				end
				else
					`uvm_fatal(get_name(), "Unexpected type of step argument")
			end


			`uvm_info(get_name(), $sformatf("%s %s", replaced_step.keyword, replaced_step.text), UVM_MEDIUM)
			start_step(replaced_step);
		endtask : visit_step

		/**
		 * @param step_argument -
		 */
		virtual task visit_step_argument(gherkin_pkg::step_argument step_argument);
		// TODO Auto-generated task stub

		endtask : visit_step_argument

		/**
		 * @param table_cell -
		 */
		virtual task visit_table_cell(gherkin_pkg::table_cell table_cell);
		// TODO Auto-generated task stub

		endtask : visit_table_cell

		/**
		 * @param table_row -
		 */
		virtual task visit_table_row(gherkin_pkg::table_row table_row);
		// TODO Auto-generated task stub

		endtask : visit_table_row

		/**
		 * @param tag -
		 */
		virtual task visit_tag(gherkin_pkg::tag tag);
		// TODO Auto-generated task stub

		endtask : visit_tag



	endclass : gherkin_document_runner
