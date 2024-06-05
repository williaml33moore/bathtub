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

class gherkin_document_printer extends uvm_object implements gherkin_pkg::visitor;

	gherkin_pkg::gherkin_document document;

	`uvm_object_utils_begin(gherkin_document_printer)
		`uvm_field_object(document, UVM_ALL_ON)
	`uvm_object_utils_end


	function new(string name = "gherkin_document_printer");
		// TODO Auto-generated constructor stub
		super.new(name);

	endfunction : new


	static function gherkin_document_printer create_new(string name = "gherkin_document_printer", gherkin_pkg::gherkin_document document);
		gherkin_document_printer new_printer;

		new_printer = new(name);
		new_printer.document = document;
		return new_printer;
	endfunction : create_new


	virtual task print();
		document.accept(this); // visit_gherkin_document(document)
	endtask : print

	/**
		* @param background -
		*/
	virtual task visit_background(gherkin_pkg::background background);
		$display({1{"  "}}, background.keyword, ": ", background.scenario_definition_name);

		if (background.description.len() > 0) begin
			$write({2{"  "}});
			foreach (background.description[i]) begin
				byte c = background.description[i];

				$write(string'(c));
				if (c inside {"\n", CR}) begin
					$write({2{"  "}});
				end
			end
			$display();
		end

		foreach (background.steps[i]) begin
			background.steps[i].accept(this); // visit_step(background.steps[i])
		end
		$display();

	endtask : visit_background

	/**
		* @param comment -
		*/
	virtual task visit_comment(gherkin_pkg::comment comment);
	// TODO Auto-generated task stub

	endtask : visit_comment

	virtual task visit_data_table(gherkin_pkg::data_table data_table);
		foreach (data_table.rows[i]) begin
			data_table.rows[i].accept(this); // visit_table_row(data_table.rows[i])
		end
	endtask : visit_data_table

	/**
		* @param doc_string -
		*/
	virtual task visit_doc_string(gherkin_pkg::doc_string doc_string);
	// TODO Auto-generated task stub

	endtask : visit_doc_string

	virtual task visit_examples(gherkin_pkg::examples examples);
		$display({{2{"  "}}, examples.keyword, ": ", examples.examples_name});

		if (examples.description != "") begin
			$write({2{"  "}});
			foreach (examples.description[i]) begin
				byte c = examples.description[i];

				$write(string'(c));
				if (c inside {"\n", CR}) begin
					$write({2{"  "}});
				end
			end
			$display();
		end

		examples.header.accept(this); // visit_table_row(examples.header)

		foreach (examples.rows[i]) begin
			examples.rows[i].accept(this); // visit_table_row(examples.rows[i])
		end
		$display();
		
	endtask : visit_examples

	/**
		* @param feature -
		*/
	virtual task visit_feature(gherkin_pkg::feature feature);
		$display({"# language: ", feature.language});

		foreach (feature.tags[i]) begin
			feature.tags[i].accept(this); // visit_tag(feature.tags[i])
		end

		$display(feature.keyword, ": ", feature.feature_name);

		$write({1{"  "}});
		foreach (feature.description[i]) begin
			byte c = feature.description[i];

			$write(string'(c));
			if (c == "\n") begin
				$write({1{"  "}});
			end
		end
		$display();

		foreach(feature.scenario_definitions[i]) begin
			feature.scenario_definitions[i].accept(this);
		end
	endtask : visit_feature

	virtual task visit_gherkin_document(gherkin_pkg::gherkin_document gherkin_document);
		foreach (gherkin_document.comments[i]) begin
			gherkin_document.comments[i].accept(this); // visit_comment(gherkin_document.comments[i])
		end

		gherkin_document.feature.accept(this); // visit_feature(gherkin_document.feature)

	endtask : visit_gherkin_document

	virtual task visit_scenario(gherkin_pkg::scenario scenario);
		foreach (scenario.tags[i]) begin
			scenario.tags[i].accept(this); // visit_tag(scenario.tags[i])
		end

		$display({1{"  "}}, scenario.keyword, ": ", scenario.scenario_definition_name);

		$write({2{"  "}});
		foreach (scenario.description[i]) begin
			byte c = scenario.description[i];

			$write(string'(c));
			if (c == "\n") begin
				$write({2{"  "}});
			end
		end
		$display();

		foreach (scenario.steps[i]) begin
			scenario.steps[i].accept(this); // visit_step(scenario.steps[i])
		end
		$display();
		
	endtask : visit_scenario

	virtual task visit_scenario_definition(gherkin_pkg::scenario_definition scenario_definition);
	endtask : visit_scenario_definition

	virtual task visit_scenario_outline(gherkin_pkg::scenario_outline scenario_outline);
		foreach (scenario_outline.tags[i]) begin
			scenario_outline.tags[i].accept(this); // visit_tag(scenario_outline.tags[i])
		end

		$display({1{"  "}}, scenario_outline.keyword, ": ", scenario_outline.scenario_definition_name);

		$write({2{"  "}});
		foreach (scenario_outline.description[i]) begin
			byte c = scenario_outline.description[i];

			$write(string'(c));
			if (c == "\n") begin
				$write({2{"  "}});
			end
		end
		$display();

		foreach (scenario_outline.steps[i]) begin
			scenario_outline.steps[i].accept(this); // visit_step(scenario_outline.steps[i])
		end
		$display();

		foreach (scenario_outline.examples[i]) begin
			scenario_outline.examples[i].accept(this); // visit_examples(scenario_outline.examples[i])
		end

	endtask : visit_scenario_outline

	virtual task visit_step(gherkin_pkg::step step);
		$display({2{"  "}}, step.keyword, " ", step.text);
		if (step.argument != null) begin
			step.argument.accept(this);
		end
	endtask : visit_step

	virtual task visit_step_argument(gherkin_pkg::step_argument step_argument);
		// Nothing to do
	endtask : visit_step_argument

	virtual task visit_table_cell(gherkin_pkg::table_cell table_cell);
		$write({" ", table_cell.value, " |"});
	endtask : visit_table_cell

	virtual task visit_table_row(gherkin_pkg::table_row table_row);
		$write({{2{"  "}}, "|"});
		foreach (table_row.cells[i]) begin
			table_row.cells[i].accept(this); // visit_table_cell(table_row.cells[i])
		end
		$display();
	endtask : visit_table_row

	/**
		* @param tag -
		*/
	virtual task visit_tag(gherkin_pkg::tag tag);
	// TODO Auto-generated task stub

	endtask : visit_tag

endclass : gherkin_document_printer
