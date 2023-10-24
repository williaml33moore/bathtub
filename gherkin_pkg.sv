// ===================================================================
package gherkin_pkg;
	// ===================================================================

	import uvm_pkg::*;
	import meta_pkg::*;

	typedef class background;
	typedef class comment;
	typedef class data_table;
	typedef class doc_string;
	typedef class examples;
	typedef class feature;
	typedef class gherkin_document;
	typedef class scenario;
	typedef class scenario_definition;
	typedef class scenario_outline;
	typedef class step;
	typedef class step_argument;
	typedef class table_cell;
	typedef class table_row;
	typedef class tag;

	typedef struct {
		string keyword="";
		string scenario_definition_name="";
		string description="";
		step steps[$];
	} scenario_definition_value;

	typedef struct {
		scenario_definition_value base;
	} background_value;

	typedef struct {
		string tag_name="";
	} tag_value;

	typedef struct {
		string keyword="";
		string examples_name="";
		string description="";
		table_row header;
		table_row rows[$];
	} examples_value;


	(* visitor_pattern *)
	interface class visitor;
		pure virtual task visit_background(gherkin_pkg::background background);
		pure virtual task visit_comment(gherkin_pkg::comment comment);
		pure virtual task visit_data_table(gherkin_pkg::data_table data_table);
		pure virtual task visit_doc_string(gherkin_pkg::doc_string doc_string);
		pure virtual task visit_examples(gherkin_pkg::examples examples);
		pure virtual task visit_feature(gherkin_pkg::feature feature);
		pure virtual task visit_gherkin_document(gherkin_pkg::gherkin_document gherkin_document);
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
		string text;

		`uvm_object_utils_begin(comment)
		`uvm_field_string(text, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "comment");
			super.new(name);
		endfunction : new


		function comment configure(string text);
			this.text = text;
			return this;
		endfunction : configure

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_comment(this);
		endtask : accept

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
		string value;

		`uvm_object_utils_begin(table_cell)
		`uvm_field_string(value, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="table_cell");
			super.new(name);

			this.value = "";
		endfunction : new

		static function table_cell create_new(string name="table_cell", string value="");
			table_cell new_obj;

			new_obj = new(name);
			new_obj.value = value;
			return new_obj;
		endfunction : create_new

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_table_cell(this);
		endtask : accept

	endclass : table_cell


	class table_row extends uvm_object implements element;
		table_cell cells[$];

		`uvm_object_utils_begin(table_row)
		`uvm_field_queue_object(cells, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="table_row");
			super.new(name);

			cells.delete();
		endfunction : new

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_table_row(this);
		endtask : accept

	endclass : table_row


	class data_table extends step_argument implements element;
		table_row rows[$];

		`uvm_object_utils_begin(data_table)
		`uvm_field_queue_object(rows, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "data_table");
			super.new(name);

			rows.delete();
		endfunction : new

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_data_table(this);
		endtask : accept

	endclass : data_table


	class doc_string extends step_argument implements element;
		string content;
		string content_type;

		`uvm_object_utils_begin(doc_string)
		`uvm_field_string(content, UVM_ALL_ON)
		`uvm_field_string(content_type, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "doc_string");
			super.new(name);

			this.content = "";
			this.content_type = "";
		endfunction : new

		function doc_string configure(string content="", string content_type="");
			this.content = content;
			this.content_type = content_type;
			return this;
		endfunction : configure

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_doc_string(this);
		endtask : accept

	endclass : doc_string


	class step extends uvm_object implements element;
		string keyword;
		string text;
		step_argument argument;

		`uvm_object_utils_begin(step)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(text, UVM_ALL_ON)
		`uvm_field_object(argument, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "step");
			super.new(name);

			this.keyword = "";
			this.text = "";
			this.argument = null;
		endfunction : new


		static function step create_new(string name = "step", string keyword, string text);
			step new_obj;

			new_obj = new(name);
			new_obj.keyword = keyword;
			new_obj.text = text;
			return new_obj;
		endfunction : create_new

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_step(this);
		endtask : accept

	endclass : step


	virtual class scenario_definition extends uvm_object implements element;
		string keyword;
		string scenario_definition_name;
		string description;
		step steps[$];

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

		function scenario_definition_value get_value();
			get_value.keyword = this.keyword;
			get_value.scenario_definition_name = this.scenario_definition_name;
			get_value.description = this.description;
			
			get_value.steps.delete();
			foreach (this.steps[i]) begin
				get_value.steps.push_back(this.steps[i]);
			end
		endfunction : get_value

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_scenario_definition(this);
		endtask : accept

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

		virtual function background_value get_value();
			get_value.base = super.get_value();
		endfunction : get_value

		static function background create_new(string name = "background", string scenario_definition_name="", string description="", string keyword="Background");
			background new_obj;

			new_obj = new(name);
			new_obj.scenario_definition_name = scenario_definition_name;
			new_obj.description = description;
			new_obj.keyword = keyword;
			return new_obj;
		endfunction : create_new

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_background(this);
		endtask : accept

	endclass : background


	class tag extends uvm_object implements element;
		string tag_name;

		`uvm_object_utils_begin(tag)
		`uvm_field_string(tag_name, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="tag", tag_value value='{""});
			super.new(name);

			this.tag_name = value.tag_name;
		endfunction : new

		virtual function tag_value get_value();
			get_value.tag_name = this.tag_name;
		endfunction : get_value

		function tag configure(string tag_name="");
			this.tag_name = tag_name;
			return this;
		endfunction : configure

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_tag(this);
		endtask : accept

	endclass : tag


	class examples extends uvm_object implements element;
		string keyword;
		string examples_name;
		string description;
		table_row header;
		table_row rows[$];

		`uvm_object_utils_begin(examples)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(examples_name, UVM_ALL_ON)
		`uvm_field_string(description, UVM_ALL_ON)
		`uvm_field_object(header, UVM_ALL_ON)
		`uvm_field_queue_object(rows, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name="examples", examples_value value='{
			"", // keyword
			"", // examples_name
			"", // description
			null, // header
			'{} // rows
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
		endfunction : new

		virtual function examples_value get_value();
			get_value.keyword = this.keyword;
			get_value.examples_name = this.examples_name;
			get_value.description = this.description;

			get_value.header = new this.header; // TODO - deep copy

			get_value.rows.delete();
			foreach (this.rows[i]) begin
				table_row new_obj = new this.rows[i]; // TODO - deep copy
				get_value.rows.push_back(new_obj);
			end
		endfunction : get_value

		static function examples create_new(string name="examples", string examples_name="", string description="", string keyword="Examples");
			examples new_obj;

			new_obj = new(name);
			new_obj.examples_name = examples_name;
			new_obj.description = description;
			new_obj.keyword = keyword;
			return new_obj;
		endfunction : create_new

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_examples(this);
		endtask : accept

	endclass : examples


	class scenario_outline extends scenario_definition implements element;
		tag tags[$];
		gherkin_pkg::examples examples[$];

		`uvm_object_utils_begin(scenario_outline)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_field_queue_object(examples, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "scenario_outline");
			super.new(name);

			tags.delete();
			examples.delete();
		endfunction : new

		static function scenario_outline create_new(string name = "scenario_outline", string scenario_definition_name="", string description="", string keyword="Scenario Outline");
			scenario_outline new_obj;

			new_obj = new(name);
			new_obj.scenario_definition_name = scenario_definition_name;
			new_obj.description = description;
			new_obj.keyword = keyword;
			return new_obj;
		endfunction : create_new

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_scenario_outline(this);
		endtask : accept

	endclass : scenario_outline


	class scenario extends scenario_definition implements element;
		tag tags[$];

		`uvm_object_utils_begin(scenario)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "scenario");
			super.new(name);

			tags.delete();

		endfunction : new

		static function scenario create_new(string name = "scenario", string scenario_definition_name="", string description="", string keyword="Scenario");
			scenario new_obj;

			new_obj = new(name);
			new_obj.scenario_definition_name = scenario_definition_name;
			new_obj.description = description;
			new_obj.keyword = keyword;
			return new_obj;
		endfunction : create_new

		virtual task accept(gherkin_pkg::visitor visitor);
			super.accept(visitor);
			visitor.visit_scenario(this);
		endtask : accept

	endclass : scenario


	class feature extends uvm_object implements element;
		string language;
		string keyword;
		string feature_name;
		string description;
		tag tags[$];
		scenario_definition scenario_definitions[$];

		`uvm_object_utils_begin(feature)
		`uvm_field_string(language, UVM_ALL_ON)
		`uvm_field_string(keyword, UVM_ALL_ON)
		`uvm_field_string(feature_name, UVM_ALL_ON)
		`uvm_field_string(description, UVM_ALL_ON)
		`uvm_field_queue_object(tags, UVM_ALL_ON)
		`uvm_field_queue_object(scenario_definitions, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "feature");
			super.new(name);

			scenario_definitions.delete();
		endfunction : new

		static function feature create_new(string name = "feature", string feature_name="", string description="", string keyword="Feature", string language="en");
			feature new_obj;

			new_obj = new(name);
			new_obj.keyword = keyword;
			new_obj.feature_name = feature_name;
			new_obj.description = description;
			new_obj.language = language;
			return new_obj;
		endfunction : create_new

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_feature(this);
		endtask : accept

	endclass : feature


	class gherkin_document extends uvm_object implements element;
		gherkin_pkg::feature feature;
		comment comments[$];

		`uvm_object_utils_begin(gherkin_document)
		`uvm_field_object(feature, UVM_ALL_ON)
		`uvm_field_queue_object(comments, UVM_ALL_ON)
		`uvm_object_utils_end

		function new(string name = "gherkin_document");
			super.new(name);

			this.feature = null;
			this.comments.delete();
		endfunction : new

		virtual task accept(gherkin_pkg::visitor visitor);
			visitor.visit_gherkin_document(this);
		endtask : accept

	endclass : gherkin_document


endpackage : gherkin_pkg
