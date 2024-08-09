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

`ifndef __GHERKIN_DOCUMENT_PRINTER_SVH
`define __GHERKIN_DOCUMENT_PRINTER_SVH

import uvm_pkg::*;
import gherkin_pkg::gherkin_pkg_metadata;

`include "bathtub_pkg/bathtub_pkg.svh"
`include "uvm_macros.svh"

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
		$display(indent(1), background.get_keyword(), ": ", background.get_scenario_definition_name());

		if (background.get_description().len() > 0) begin
			string description;
			$write(string'(indent(2)));
			description = background.get_description();
			foreach (description[i]) begin
				byte c = description[i];

				$write(string'(c));
				if (c inside {"\n", CR}) begin
					$write(indent(2));
				end
			end
			$display();
		end

		for (int i = 0; i < background.get_steps().size(); i++) begin
			background.get_steps().get(i).accept(this); // visit_step(background.get_steps().get(i))
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
		for (int i = 0; i < data_table.get_rows().size(); i++) begin
			data_table.get_rows().get(i).accept(this); // visit_table_row(data_table.get_rows().get(i))
		end
	endtask : visit_data_table

	/**
		* @param doc_string -
		*/
	virtual task visit_doc_string(gherkin_pkg::doc_string doc_string);
	// TODO Auto-generated task stub

	endtask : visit_doc_string

	virtual task visit_examples(gherkin_pkg::examples examples);
		$display({indent(2), examples.get_keyword(), ": ", examples.get_examples_name()});

		if (examples.get_description() != "") begin
			string description;
			$write(indent(2));
			description = examples.get_description();
			foreach (description[i]) begin
				byte c = description[i];

				$write(string'(c));
				if (c inside {"\n", CR}) begin
					$write(indent(2));
				end
			end
			$display();
		end

		examples.get_header().accept(this); // visit_table_row(examples.get_header())

		foreach (examples.rows[i]) begin
			examples.rows[i].accept(this); // visit_table_row(examples.rows[i])
		end
		$display();
		
	endtask : visit_examples

	/**
		* @param feature -
		*/
	virtual task visit_feature(gherkin_pkg::feature feature);
		string description;
		$display({"# language: ", feature.get_language()});

		foreach (feature.tags[i]) begin
			feature.tags[i].accept(this); // visit_tag(feature.tags[i])
		end

		$display(feature.get_keyword(), ": ", feature.get_feature_name());

		$write(indent(1));
		description = feature.get_description();
		foreach (description[i]) begin
			byte c = description[i];

			$write(string'(c));
			if (c == "\n") begin
				$write(indent(1));
			end
		end
		$display();

		foreach(feature.scenario_definitions[i]) begin
			feature.scenario_definitions[i].accept(this);
		end

		for (int i = 0; i < feature.get_rules().size(); i++) begin
			feature.get_rules().get(i).accept(this);
		end
	endtask : visit_feature

	virtual task visit_gherkin_document(gherkin_pkg::gherkin_document gherkin_document);
		for (int i = 0; i < gherkin_document.get_comments().size(); i++) begin
			gherkin_document.get_comments().get(i).accept(this); // visit_comment(gherkin_document.get_comments().get(i))
		end

		gherkin_document.get_feature().accept(this); // visit_feature(gherkin_document.get_feature())

	endtask : visit_gherkin_document

	virtual task visit_scenario(gherkin_pkg::scenario scenario);
		string description;

		foreach (scenario.tags[i]) begin
			scenario.tags[i].accept(this); // visit_tag(scenario.tags[i])
		end

		$display(indent(1), scenario.get_keyword(), ": ", scenario.get_scenario_definition_name());

		$write(indent(2));
		description = scenario.get_description();
		foreach (description[i]) begin
			byte c = description[i];

			$write(string'(c));
			if (c == "\n") begin
				$write(indent(2));
			end
		end
		$display();

		for (int i = 0; i < scenario.get_steps().size(); i++) begin
			scenario.get_steps().get(i).accept(this); // visit_step(scenario.get_steps().get(i))
		end
		$display();
		
	endtask : visit_scenario

	virtual task visit_scenario_definition(gherkin_pkg::scenario_definition scenario_definition);
	endtask : visit_scenario_definition

	virtual task visit_scenario_outline(gherkin_pkg::scenario_outline scenario_outline);
		string description;

		foreach (scenario_outline.tags[i]) begin
			scenario_outline.tags[i].accept(this); // visit_tag(scenario_outline.tags[i])
		end

		$display(indent(1), scenario_outline.get_keyword(), ": ", scenario_outline.get_scenario_definition_name());

		$write(indent(2));
		description = scenario_outline.get_description();
		foreach (description[i]) begin
			byte c = description[i];

			$write(string'(c));
			if (c == "\n") begin
				$write(indent(2));
			end
		end
		$display();

		for (int i = 0; i < scenario_outline.get_steps().size(); i++) begin
			scenario_outline.get_steps().get(i).accept(this); // visit_step(scenario_outline.get_steps().get(i))
		end
		$display();

		foreach (scenario_outline.examples[i]) begin
			scenario_outline.examples[i].accept(this); // visit_examples(scenario_outline.examples[i])
		end

	endtask : visit_scenario_outline

	virtual task visit_step(gherkin_pkg::step step);
		$display(indent(2), step.get_keyword(), " ", step.get_text());
		if (step.get_argument() != null) begin
			step.get_argument().accept(this);
		end
	endtask : visit_step

	virtual task visit_step_argument(gherkin_pkg::step_argument step_argument);
		// Nothing to do
	endtask : visit_step_argument

	virtual task visit_table_cell(gherkin_pkg::table_cell table_cell);
		$write(string'({" ", table_cell.get_value(), " |"}));
	endtask : visit_table_cell

	virtual task visit_table_row(gherkin_pkg::table_row table_row);
		gherkin_pkg::table_cells cells;

		$write(string'({indent(2), "|"}));
		cells = table_row.get_cells();
		for (int i = 0; i < cells.size(); i++) begin
			cells.get(i).accept(this); // visit_table_cell(cells.get(i))
		end
		$display();
	endtask : visit_table_row

	/**
		* @param tag -
		*/
	virtual task visit_tag(gherkin_pkg::tag tag);
	// TODO Auto-generated task stub

	endtask : visit_tag

	virtual task visit_rule(gherkin_pkg::rule rule);
		string description;

		// foreach (rule.tags[i]) begin
		// 	rule.tags[i].accept(this); // visit_tag(rule.tags[i])
		// end

		$display(rule.get_keyword(), ": ", rule.get_rule_name());

		$write(indent(1));
		description = rule.get_description();
		foreach (description[i]) begin
			byte c = description[i];

			$write(string'(c));
			if (c == "\n") begin
				$write(indent(1));
			end
		end
		$display();

		for (int i = 0; i < rule.get_scenario_definitions().size(); i++) begin
			rule.get_scenario_definitions().get(i).accept(this);
		end
	endtask : visit_rule


	static function string indent(int n);
		return string'({n{"  "}});
	endfunction : indent

endclass : gherkin_document_printer

`endif // __GHERKIN_DOCUMENT_PRINTER_SVH
