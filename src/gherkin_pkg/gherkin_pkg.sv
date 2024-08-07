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

`include "uvm_macros.svh"

// ===================================================================
package gherkin_pkg;
	// ===================================================================

	import uvm_pkg::*;

	const struct {
		string file;
	} gherkin_pkg_metadata = '{
		file : "`__FILE__",
		string : ""
	};

	typedef class background;
	typedef class comment;
	typedef class data_table;
	typedef class doc_string;
	typedef class examples;
	typedef class feature;
	typedef class gherkin_document;
	typedef class rule;
	typedef class scenario;
	typedef class scenario_definition;
	typedef class scenario_outline;
	typedef class step;
	typedef class step_argument;
	typedef class table_cell;
	typedef class table_row;
	typedef class tag;

	(* value_object *)
	typedef struct {
		string text="";
	} comment_value;

	(* value_object *)
	typedef struct {
		string value="";
	} table_cell_value;

	(* value_object *)
	typedef struct {
		table_cell cells[$];
	} table_row_value;

	(* value_object *)
	typedef struct {
		table_row rows[$];
	} data_table_value;

	(* value_object *)
	typedef struct {
		string content;
		string content_type;
	} doc_string_value;

	(* value_object *)
	typedef struct {
		string keyword;
		string text;
		step_argument argument;
	} step_value;

	(* value_object *)
	typedef struct {
		string keyword="";
		string scenario_definition_name="";
		string description="";
		step steps[$];
	} scenario_definition_value;

	(* value_object *)
	typedef struct {
		scenario_definition_value base;
	} background_value;

	(* value_object *)
	typedef struct {
		string tag_name="";
	} tag_value;

	(* value_object *)
	typedef struct {
		string keyword="";
		string examples_name="";
		string description="";
		table_row header;
		table_row rows[$];
		tag tags[$];
	} examples_value;

	(* value_object *)
	typedef struct {
		tag tags[$];
		scenario_definition_value base;
		gherkin_pkg::examples examples[$];
	} scenario_outline_value;

	(* value_object *)
	typedef struct {
		tag tags[$];
		scenario_definition_value base;
	} scenario_value;

	(* value_object *)
	typedef struct {
		string language="";
		tag tags[$];
		string keyword="";
		string feature_name="";
		string description="";
		scenario_definition scenario_definitions[$];
		rule rules[$];
	} feature_value;

	(* value_object *)
	typedef struct {
		gherkin_pkg::feature feature;
		comment comments[$];
	} gherkin_document_value;

	(* value_object *)
	typedef struct {
		tag tags[$];
		string keyword="";
		string rule_name="";
		string description="";
		gherkin_pkg::background background;
		scenario_definition scenario_definitions[$];
	} rule_value;

	// Collections

	typedef uvm_queue#(table_cell) table_cells;
	typedef uvm_queue#(table_row) table_rows;
	typedef uvm_queue#(step) steps;
	typedef uvm_queue#(tag) tags;
	typedef uvm_queue#(examples) examples_tables;
	typedef uvm_queue#(scenario_definition) scenario_definitions;
	typedef uvm_queue#(rule) rules;
	typedef uvm_queue#(comment) comments;


	(* visitor_pattern *)
	interface class visitor;
		pure virtual task visit_background(gherkin_pkg::background background);
		pure virtual task visit_comment(gherkin_pkg::comment comment);
		pure virtual task visit_data_table(gherkin_pkg::data_table data_table);
		pure virtual task visit_doc_string(gherkin_pkg::doc_string doc_string);
		pure virtual task visit_examples(gherkin_pkg::examples examples);
		pure virtual task visit_feature(gherkin_pkg::feature feature);
		pure virtual task visit_gherkin_document(gherkin_pkg::gherkin_document gherkin_document);
		pure virtual task visit_rule(gherkin_pkg::rule rule);
		pure virtual task visit_scenario(gherkin_pkg::scenario scenario);
		pure virtual task visit_scenario_definition(gherkin_pkg::scenario_definition scenario_definition);
		pure virtual task visit_scenario_outline(gherkin_pkg::scenario_outline scenario_outline);
		pure virtual task visit_step(gherkin_pkg::step step);
		pure virtual task visit_step_argument(gherkin_pkg::step_argument step_argument);
		pure virtual task visit_table_cell(gherkin_pkg::table_cell table_cell);
		pure virtual task visit_table_row(gherkin_pkg::table_row table_row);
		pure virtual task visit_tag(gherkin_pkg::tag tag);
	endclass : visitor


	(* visitor_pattern *)
	interface class element;
		pure virtual task accept(gherkin_pkg::visitor visitor);
	endclass : element


	class comment extends uvm_object implements element;
		protected string text;

		`uvm_object_utils_begin(comment)
		`uvm_field_string(text, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "comment", comment_value value='{""});
			super.new(name);

			this.text = value.text;
		endfunction : new

		virtual function comment_value get_as_value();
			get_as_value.text = this.text;
		endfunction : get_as_value

		function comment configure(string text);
			this.text = text;
			return this;
		endfunction : configure

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_comment(this);
		endtask : accept

		function string get_text();
			return text;
		endfunction : get_text

	endclass : comment


	virtual class step_argument extends uvm_object implements element;

		function new(string name = "step_argument");
			super.new(name);
		endfunction : new

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_step_argument(this);
		endtask : accept

	endclass : step_argument


	class table_cell extends uvm_object implements element;
		protected string value;

		`uvm_object_utils_begin(table_cell)
		`uvm_field_string(value, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="table_cell", table_cell_value value='{""});
			super.new(name);

			this.value = value.value;
		endfunction : new

		virtual function table_cell_value get_as_value();
			get_as_value.value = this.value;
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_table_cell(this);
		endtask : accept

		function string get_value();
			return value;
		endfunction : get_value

	endclass : table_cell


	class table_row extends uvm_object implements element;
		protected table_cell cells[$];

		`uvm_object_utils_begin(table_row)
		`uvm_field_queue_object(cells, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="table_row", table_row_value value='{'{}});
			super.new(name);

			this.cells.delete();
			foreach (value.cells[i]) begin
				table_cell new_obj = new value.cells[i]; // TODO - deep copy
				this.cells.push_back(new_obj);
			end
		endfunction : new

		virtual function table_row_value get_as_value();
			get_as_value.cells.delete();
			foreach (this.cells[i]) begin
				table_cell new_obj = new this.cells[i]; // TODO - deep copy
				get_as_value.cells.push_back(new_obj);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_table_row(this);
		endtask : accept

		function table_cells get_cells();
			get_cells = new("cells");
			foreach (cells[i]) get_cells.push_back(cells[i]);
		endfunction : get_cells

	endclass : table_row


	class data_table extends step_argument implements element;
		protected table_row rows[$];

		`uvm_object_utils_begin(data_table)
		`uvm_field_queue_object(rows, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "data_table", data_table_value value='{'{}});
			super.new(name);

			this.rows.delete();
			foreach (value.rows[i]) begin
				table_row new_obj = new value.rows[i]; // TODO - deep copy
				this.rows.push_back(new_obj);
			end
		endfunction : new

		virtual function data_table_value get_as_value();
			get_as_value.rows.delete();
			foreach (this.rows[i]) begin
				table_row new_obj = new this.rows[i]; // TODO - deep copy
				get_as_value.rows.push_back(new_obj);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_data_table(this);
		endtask : accept

		function gherkin_pkg::table_rows get_rows();
			get_rows = new("rows");
			foreach (rows[i]) get_rows.push_back(rows[i]);
		endfunction : get_rows

	endclass : data_table


	class doc_string extends step_argument implements element;
		protected string content;
		protected string content_type;

		`uvm_object_utils_begin(doc_string)
		`uvm_field_string(content, UVM_ALL_ON)
		`uvm_field_string(content_type, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "doc_string", doc_string_value value='{"", ""});
			super.new(name);

			this.content = value.content;
			this.content_type = value.content_type;
		endfunction : new

		virtual function doc_string_value get_as_value();
			get_as_value.content = this.content;
			get_as_value.content_type = this.content_type;
		endfunction : get_as_value

		function doc_string configure(string content="", string content_type="");
			this.content = content;
			this.content_type = content_type;
			return this;
		endfunction : configure

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_doc_string(this);
		endtask : accept

		function string get_content();
			return content;
		endfunction : get_content

		function string get_content_type();
			return content_type;
		endfunction : get_content_type

	endclass : doc_string


	class step extends uvm_object implements element;
		protected string keyword;
		protected string text;
		protected step_argument argument;

		`uvm_object_utils_begin(step)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(text, UVM_ALL_ON)
		`uvm_field_object(argument, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "step", step_value value='{
			"", // keyword
			"", // text
			null // argument
		});
			super.new(name);

			this.keyword = value.keyword;
			this.text = value.text;
			this.argument = value.argument;
		endfunction : new

		virtual function step_value get_as_value();
			get_as_value.keyword = this.keyword;
			get_as_value.text = this.text;
			get_as_value.argument = new this.argument; // TODO - deep copy
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_step(this);
		endtask : accept

		function string get_keyword();
			return keyword;
		endfunction : get_keyword
		
		function string get_text();
			return text;
		endfunction : get_text

		function step_argument get_argument();
			return argument;
		endfunction : get_argument

	endclass : step


	virtual class scenario_definition extends uvm_object implements element;
		protected string keyword;
		protected string scenario_definition_name;
		protected string description;
		protected step steps[$];

		`uvm_field_utils_begin(scenario_definition)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(scenario_definition_name, UVM_ALL_ON)
		`uvm_field_string(description, UVM_ALL_ON)
		`uvm_field_queue_object(steps, UVM_ALL_ON)
		`uvm_field_utils_end

		function new(string name = "scenario_definition", scenario_definition_value value='{
				"", // keyword
				"", // scenario_definition_name
				"", // description
				'{} // steps
		});
			super.new(name);

			this.keyword = value.keyword;
			this.scenario_definition_name = value.scenario_definition_name;
			this.description = value.description;

			this.steps.delete();
			foreach (value.steps[i]) begin
				this.steps.push_back(value.steps[i]);
			end
		endfunction : new

		function scenario_definition_value get_as_value();
			get_as_value.keyword = this.keyword;
			get_as_value.scenario_definition_name = this.scenario_definition_name;
			get_as_value.description = this.description;
			
			get_as_value.steps.delete();
			foreach (this.steps[i]) begin
				get_as_value.steps.push_back(this.steps[i]);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_scenario_definition(this);
		endtask : accept

		
		function string get_keyword();
			return keyword;
		endfunction : get_keyword

		function string get_scenario_definition_name();
			return scenario_definition_name;
		endfunction : get_scenario_definition_name

		function string get_description();
			return description;
		endfunction : get_description

		function gherkin_pkg::steps get_steps();
			get_steps = new("steps");
			foreach (steps[i]) get_steps.push_back(steps[i]);
		endfunction : get_steps

	endclass : scenario_definition


	class background extends scenario_definition implements element;

		`uvm_object_utils_begin(background)
		`uvm_object_utils_end

		function new(string name="background", background_value value='{
				'{
					"", // keyword
					"", // scenario_definition_name
					"", // description
					'{} // steps
				}
			});
			super.new(name, value.base);
		endfunction : new

		virtual function background_value get_as_value();
			get_as_value.base = super.get_as_value();
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_background(this);
		endtask : accept

	endclass : background


	class tag extends uvm_object implements element;
		protected string tag_name;

		`uvm_object_utils_begin(tag)
		`uvm_field_string(tag_name, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="tag", tag_value value='{""});
			super.new(name);

			this.tag_name = value.tag_name;
		endfunction : new

		virtual function tag_value get_as_value();
			get_as_value.tag_name = this.tag_name;
		endfunction : get_as_value

		function tag configure(string tag_name="");
			this.tag_name = tag_name;
			return this;
		endfunction : configure

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_tag(this);
		endtask : accept

		function string get_tag_name();
			return tag_name;
		endfunction : get_tag_name

	endclass : tag


	class examples extends uvm_object implements element;
		protected string keyword;
		protected string examples_name;
		protected string description;
		protected table_row header;
		protected table_row rows[$];
		protected tag tags[$];

		`uvm_object_utils_begin(examples)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(examples_name, UVM_ALL_ON)
		`uvm_field_string(description, UVM_ALL_ON)
		`uvm_field_object(header, UVM_ALL_ON)
		`uvm_field_queue_object(rows, UVM_ALL_ON)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="examples", examples_value value='{
				"", // keyword
				"", // examples_name
				"", // description
				null, // header
				'{}, // rows
				'{} // tags
			});
			super.new(name);

			this.keyword = value.keyword;
			this.examples_name = value.examples_name;
			this.description = value.description;

			this.header = new value.header; // TODO - deep copy

			this.rows.delete();
			foreach (value.rows[i]) begin
				table_row new_obj = new value.rows[i]; // TODO - deep copy
				this.rows.push_back(new_obj);
			end

			this.tags.delete();
			foreach (value.tags[i]) begin
				tag new_obj = new value.tags[i]; // TODO - deep copy
				this.tags.push_back(new_obj);
			end
		endfunction : new

		virtual function examples_value get_as_value();
			get_as_value.keyword = this.keyword;
			get_as_value.examples_name = this.examples_name;
			get_as_value.description = this.description;

			get_as_value.header = new this.header; // TODO - deep copy

			get_as_value.rows.delete();
			foreach (this.rows[i]) begin
				table_row new_obj = new this.rows[i]; // TODO - deep copy
				get_as_value.rows.push_back(new_obj);
			end
			foreach (this.tags[i]) begin
				tag new_obj = new this.tags[i]; // TODO - deep copy
				get_as_value.tags.push_back(new_obj);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_examples(this);
		endtask : accept

		
		function string get_keyword();
			return keyword;
		endfunction : get_keyword

		function string get_examples_name();
			return examples_name;
		endfunction : get_examples_name

		function string get_description();
			return description;
		endfunction : get_description

		function table_row get_header();
			return header;
		endfunction : get_header

		function table_rows get_rows();
			get_rows = new("rows");
			foreach (rows[i]) get_rows.push_back(rows[i]);
		endfunction : get_rows

		function gherkin_pkg::tags get_tags();
			get_tags = new("tags");
			foreach (tags[i]) get_tags.push_back(tags[i]);
		endfunction : get_tags

	endclass : examples


	class scenario_outline extends scenario_definition implements element;
		protected tag tags[$];
		protected gherkin_pkg::examples examples[$];

		`uvm_object_utils_begin(scenario_outline)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_field_queue_object(examples, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "scenario_outline", scenario_outline_value value='{
			'{}, // tags
			'{
				"", // keyword
				"", // scenario_definition_name
				"", // description
				'{} // steps
			}, // base
			'{} // examples
		});
			super.new(name, value.base);

			this.tags.delete();
			foreach (value.tags[i]) begin
				tag new_obj = new value.tags[i]; // TODO - deep copy
				this.tags.push_back(new_obj);
			end

			this.examples.delete();
			foreach (value.examples[i]) begin
				gherkin_pkg::examples new_obj = new value.examples[i]; // TODO - deep copy
				this.examples.push_back(new_obj);
			end
		endfunction : new

		virtual function scenario_outline_value get_as_value();
			get_as_value.tags.delete();
			foreach (this.tags[i]) begin
				tag new_obj = new this.tags[i]; // TODO - deep copy
				get_as_value.tags.push_back(new_obj);
			end

			get_as_value.base = super.get_as_value();

			get_as_value.examples.delete();
			foreach (this.examples[i]) begin
				gherkin_pkg::examples new_obj = new this.examples[i]; // TODO - deep copy
				get_as_value.examples.push_back(new_obj);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_scenario_outline(this);
		endtask : accept

		function gherkin_pkg::tags get_tags();
			get_tags = new("tags");
			foreach (tags[i]) get_tags.push_back(tags[i]);
		endfunction : get_tags

		function gherkin_pkg::examples_tables get_examples();
			get_examples = new("examples");
			foreach (examples[i]) get_examples.push_back(examples[i]);
		endfunction : get_examples

	endclass : scenario_outline


	class scenario extends scenario_definition implements element;
		protected tag tags[$];

		`uvm_object_utils_begin(scenario)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "scenario", scenario_value value='{
			'{}, // tags
			'{
				"", // keyword
				"", // scenario_definition_name
				"", // description
				'{} // steps
			} // base
		});
			super.new(name, value.base);

			this.tags.delete();
			foreach (value.tags[i]) begin
				tag new_obj = new value.tags[i]; // TODO - deep copy
				this.tags.push_back(new_obj);
			end
		endfunction : new

		virtual function scenario_value get_as_value();
			get_as_value.tags.delete();
			foreach (this.tags[i]) begin
				tag new_obj = new this.tags[i]; // TODO - deep copy
				get_as_value.tags.push_back(new_obj);
			end

			get_as_value.base = super.get_as_value();
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_scenario(this);
		endtask : accept

		function gherkin_pkg::tags get_tags();
			get_tags = new("tags");
			foreach (tags[i]) get_tags.push_back(tags[i]);
		endfunction : get_tags

	endclass : scenario


	class feature extends uvm_object implements element;
		protected string language;
		protected string keyword;
		protected string feature_name;
		protected string description;
		protected tag tags[$];
		protected scenario_definition scenario_definitions[$];
		protected rule rules[$];

		`uvm_object_utils_begin(feature)
		`uvm_field_string(language, UVM_ALL_ON)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(feature_name, UVM_ALL_ON)
		`uvm_field_string(description, UVM_ALL_ON)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_field_queue_object(scenario_definitions, UVM_ALL_ON)
		`uvm_field_queue_object(rules, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "feature", feature_value value='{
			"", // language
			'{}, // tags
			"", // keyword
			"", // feature_name
			"", // description
			'{}, // scenario_definitions
			'{} // rules
		});
			super.new(name);

			this.language = value.language;
			
			this.tags.delete();
			foreach (value.tags[i]) begin
				tag new_obj = new value.tags[i]; // TODO - deep copy
				this.tags.push_back(new_obj);
			end

			this.keyword = value.keyword;
			this.feature_name = value.feature_name;
			this.description = value.description;

			this.scenario_definitions.delete();
			foreach (value.scenario_definitions[i]) begin
				scenario_definition new_obj = new value.scenario_definitions[i]; // TODO - deep copy
				this.scenario_definitions.push_back(new_obj);
			end

			this.rules.delete();
			foreach (value.rules[i]) begin
				rule new_obj = new value.rules[i]; // TODO - deep copy
				this.rules.push_back(new_obj);
			end
		endfunction : new

		virtual function feature_value get_as_value();
			get_as_value.language = this.language;
			
			get_as_value.tags.delete();
			foreach (this.tags[i]) begin
				tag new_obj = new this.tags[i]; // TODO - deep copy
				get_as_value.tags.push_back(new_obj);
			end

			get_as_value.keyword = this.keyword;
			get_as_value.feature_name = this.feature_name;
			get_as_value.description = this.description;

			get_as_value.scenario_definitions.delete();
			foreach (this.scenario_definitions[i]) begin
				scenario_definition new_obj = new this.scenario_definitions[i]; // TODO - deep copy
				get_as_value.scenario_definitions.push_back(new_obj);
			end

			get_as_value.rules.delete();
			foreach (this.rules[i]) begin
				rule new_obj = new this.rules[i]; // TODO - deep copy
				get_as_value.rules.push_back(new_obj);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_feature(this);
		endtask : accept

		
		function string get_language();
			return language;
		endfunction : get_language

		function string get_keyword();
			return keyword;
		endfunction : get_keyword

		function string get_feature_name();
			return feature_name;
		endfunction : get_feature_name

		function string get_description();
			return description;
		endfunction : get_description

		function gherkin_pkg::tags get_tags();
			get_tags = new("tags");
			foreach (tags[i]) get_tags.push_back(tags[i]);
		endfunction : get_tags

		function gherkin_pkg::scenario_definitions get_scenario_definitions();
			get_scenario_definitions = new("scenario_definitions");
			foreach (scenario_definitions[i]) get_scenario_definitions.push_back(scenario_definitions[i]);
		endfunction : get_scenario_definitions

		function gherkin_pkg::rules get_rules();
			get_rules = new("rules");
			foreach (rules[i]) get_rules.push_back(rules[i]);
		endfunction : get_rules

	endclass : feature


	class gherkin_document extends uvm_object implements element;
		protected gherkin_pkg::feature feature;
		protected comment comments[$];

		`uvm_object_utils_begin(gherkin_document)
		`uvm_field_object(feature, UVM_ALL_ON)
		`uvm_field_queue_object(comments, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="gherkin_document", gherkin_document_value value='{
			null, // feature
			'{} // comments
		});
			super.new(name);

			this.feature = value.feature;

			this.comments.delete();
			foreach (value.comments[i]) begin
				comment new_obj = new value.comments[i]; // TODO - deep copy
				this.comments.push_back(new_obj);
			end
		endfunction : new

		virtual function gherkin_document_value get_as_value();
			get_as_value.feature = this.feature;

			get_as_value.comments.delete();
			foreach (this.comments[i]) begin
				comment new_obj = new this.comments[i]; // TODO - deep copy
				get_as_value.comments.push_back(new_obj);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_gherkin_document(this);
		endtask : accept

		
		function gherkin_pkg::feature get_feature();
			return this.feature;
		endfunction : get_feature

		function gherkin_pkg::comments get_comments();
			get_comments = new("comments");
			foreach (comments[i]) get_comments.push_back(comments[i]);
		endfunction : get_comments

	endclass : gherkin_document


	class rule extends uvm_object implements element;
		protected string keyword;
		protected string rule_name;
		protected string description;
		protected tag tags[$];
		protected gherkin_pkg::background background;
		protected scenario_definition scenario_definitions[$];

		`uvm_field_utils_begin(rule)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(rule_name, UVM_ALL_ON)
		`uvm_field_string(description, UVM_ALL_ON)
		`uvm_field_object(background, UVM_ALL_ON)
		`uvm_field_queue_object(scenario_definitions, UVM_ALL_ON)
		`uvm_field_utils_end

		function new(string name = "rule", rule_value value='{
			'{}, // tags
			"", // keyword
			"", // rule_name
			"", // description
			null, // background
			'{} // scenario_definitions
		});
			super.new(name);
			
			this.tags.delete();
			foreach (value.tags[i]) begin
				tag new_obj = new value.tags[i]; // TODO - deep copy
				this.tags.push_back(new_obj);
			end

			this.keyword = value.keyword;
			this.rule_name = value.rule_name;
			this.description = value.description;
			this.background = value.background;

			this.scenario_definitions.delete();
			foreach (value.scenario_definitions[i]) begin
				this.scenario_definitions.push_back(value.scenario_definitions[i]);
			end
		endfunction : new

		function rule_value get_as_value();
			get_as_value.tags.delete();
			foreach (this.tags[i]) begin
				tag new_obj = new this.tags[i]; // TODO - deep copy
				get_as_value.tags.push_back(new_obj);
			end

			get_as_value.keyword = this.keyword;
			get_as_value.rule_name = this.rule_name;
			get_as_value.description = this.description;
			get_as_value.background = this.background;
			
			get_as_value.scenario_definitions.delete();
			foreach (this.scenario_definitions[i]) begin
				get_as_value.scenario_definitions.push_back(this.scenario_definitions[i]);
			end
		endfunction : get_as_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_rule(this);
		endtask : accept

		
		function string get_keyword();
			return keyword;
		endfunction : get_keyword

		function string get_rule_name();
			return rule_name;
		endfunction : get_rule_name

		function string get_description();
			return description;
		endfunction : get_description

		function gherkin_pkg::background get_background();
			return background;
		endfunction : get_background

		function gherkin_pkg::tags get_tags();
			get_tags = new("tags");
			foreach (tags[i]) get_tags.push_back(tags[i]);
		endfunction : get_tags

		function gherkin_pkg::scenario_definitions get_scenario_definitions();
			get_scenario_definitions = new("scenario_definitions");
			foreach (scenario_definitions[i]) get_scenario_definitions.push_back(scenario_definitions[i]);
		endfunction : get_scenario_definitions

	endclass : rule


endpackage : gherkin_pkg
