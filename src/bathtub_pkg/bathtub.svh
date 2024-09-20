/*
MIT License

Copyright (c) 2023 Everactive
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

`ifndef __BATHTUB_SVH
`define __BATHTUB_SVH

import uvm_pkg::*;

typedef class gherkin_parser;
typedef class gherkin_document_printer;
typedef class gherkin_document_runner;
typedef class plusarg_options;
typedef class test_sequence;
typedef class snippets;

`include "bathtub_macros.sv"
`include "bathtub_pkg/bathtub_pkg.svh"

(* doc$markdown = "\
    \ The simulation's entry point to Bathtub.\n\
    \ \n\
    \ The Bathtub class reads Gherkin feature files and runs them aginst the DUT.\n\
    \ In your UVM test or some other component, instantiate a Bathtub object, configure it with a sequencer (perhaps a virtual sequencer from your UVM environment), then run it.\n\
    \ Note that `bathtub` is a `uvm_component`.\n\
    \ \n\
    \ Typical usage:\n\
    \ ```sv\n\
    \ class bathtub_test extends uvm_test;\n\
    \ 	bathtub_pkg::bathtub bathtub;\n\
    \ 	uvm_env my_env;\n\
    \ \n\
    \     virtual function void build_phase(uvm_phase phase);\n\
    \         bathtub = bathtub_pkg::bathtub::type_id::create(\"bathtub\", this);\n\
    \         super.build_phase(phase);\n\
    \         ...\n\
    \     endfunction\n\
    \ \n\
    \     task run_phase(uvm_phase phase);\n\
    \         phase.raise_objection(this);\n\
    \         bathtub.configure(my_env.my_sequencer);\n\
    \         bathtub.run_test(phase);\n\
    \         phase.drop_objection(this);\n\
    \     endtask\n\
    \ endclass\n\
    \ ```\n\
    \ \n\
    \ Bathtub creates its own sequence, called `current_test_sequence`, which is an instance of class `bathtub_pkg::test_sequence`.\n\
    \ This sequence is the parent sequence of all sequences Bathtub creates, and provides context that persists for the duration of the simulation. \n\
    \ It contains UVM pools of various types so all the child sequences down to the step definitions can share information.\n\
    \ `current_test_sequence` also contains a reciprocal reference back to the Bathtub object, so child sequences have access to it as well.\n\
    \ \n\
    \ Bathtub is a subclass of `uvm_report_object` and by default serves as its own report object for the messages it prints through `` `uvm_info() ``, `` `uvm_error() ``, etc.\n\
    \ The Bathtub object's verbosity can be set with simulator command line plusarg `+bathtub_verbosity=<verbosity>` independently of `+UVM_VERBOSITY=<verbosity>`.\n\
    \ \n\
    \ ```mermaid\n\
    \ ---\n\
    \ title: Class Diagram\n\
    \ ---\n\
    \ classDiagram\n\
    \     namespace bathtub_pkg{\n\
    \         class bathtub{\n\
    \ 			#feature_files : string[*]\n\
    \ 			#sequencer : uvm_sequencer_base\n\
    \ 			#parent_sequence : uvm_sequence_base\n\
    \ 			#sequence_priority : int\n\
    \ 			#sequence_call_pre_post : bit\n\
    \ 			#dry_run : bit\n\
    \ 			#starting_scenario_number : int\n\
    \ 			#stopping_scenario_number : int\n\
    \ 			#bathtub_verbosity : uvm_verbosity\n\
    \ 			#report_object : uvm_report_object\n\
    \ 			#include_tags : string[*]\n\
    \ 			#exclude_tags : string[*]\n\
    \ 			#undefined_steps : gherkin_pkg::step[*]\n\
    \ 			#plusarg_opts : plusarg_options$ \n\
    \             +new()\n\
    \             +configure()\n\
    \             +run_test()\n\
    \         }\n\
    \         class test_sequence\n\
    \     }\n\
    \     namespace uvm_pkg{\n\
    \         class uvm_report_object\n\
    \     }\n\
    \     bathtub --|> uvm_report_object\n\
    \     bathtub *-- test_sequence : current_test_seq\n\
    \ 	test_sequence --> bathtub : bt\n\
    \ ```\n\
    \ "
*)
class bathtub extends uvm_component;
	// =================================

	protected string feature_files[$];
	protected uvm_sequencer_base sequencer;
	protected uvm_sequence_base parent_sequence;
	protected int sequence_priority;
	protected bit sequence_call_pre_post;
	protected bit dry_run;
	protected int starting_scenario_number;
	protected int stopping_scenario_number;
	protected uvm_verbosity bathtub_verbosity;
	protected uvm_report_object report_object;
	protected string include_tags[$];
	protected string exclude_tags[$];
	protected test_sequence current_test_seq;
	protected gherkin_pkg::step undefined_steps[$];

	protected static plusarg_options plusarg_opts = plusarg_options::create().populate();

	`uvm_component_utils_begin(bathtub)
		`uvm_field_queue_string(feature_files, UVM_ALL_ON)
		`uvm_field_int(dry_run, UVM_ALL_ON)
		`uvm_field_int(sequence_priority, UVM_ALL_ON)
		`uvm_field_int(sequence_call_pre_post, UVM_ALL_ON)
		`uvm_field_int(starting_scenario_number, UVM_ALL_ON)
		`uvm_field_int(stopping_scenario_number, UVM_ALL_ON)
		`uvm_field_queue_string(include_tags, UVM_ALL_ON)
		`uvm_field_queue_string(exclude_tags, UVM_ALL_ON)
	`uvm_component_utils_end


	(* doc$markdown = "\
        \ Constructor.\n\
        \ \n\
        \ Initializes the Bathtub object with the given `name`.\n\
        \ "
	*)
	function new(string name="bathtub", uvm_component parent);
		// -------------------------------
		super.new(name, parent);

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
		undefined_steps.delete();
	endfunction : new


	(* doc$markdown = "\
        \ Configures how the Bathtub object runs its sequences.\n\
        \ \n\
        \ Parameters `sequencer`, `parent_sequence`, `sequence_priority`, and `sequence_call_pre_post` are all related to the respective arguments of `uvm_sequence_base::start()`.\n\
        \ These parameters all influence how Bathtub executes its context and step definition sequences.\n\
        \ Call this function before calling `run_test()`.\n\
        \ \n\
        \ `sequencer` is the sequencer on which Bathtub will execute all its sequences.\n\
        \ This is the only required argument.\n\
        \ \n\
        \ The Bathtub object creates its own context sequence called `current_test_seq`.\n\
        \ If `parent_sequence` is null, then `current_test_seq` is a root parent, otherwise it is a child of `parent_sequence`.\n\
        \ \n\
        \ Bathtub assigns `sequence_priority` to all its sequences.\n\
        \ \n\
        \ `sequence_call_pre_post` determines whether the sequences' `pre_body()` and `post_body()` tasks are called.\n\
        \ "
	*)
	virtual function void configure(
			uvm_sequencer_base sequencer,
			uvm_sequence_base parent_sequence = null,
			int sequence_priority = 100,
			bit sequence_call_pre_post = 1
		);
		// ------------------------------------------
		this.sequencer = sequencer;
		this.parent_sequence = parent_sequence;
		this.sequence_priority = sequence_priority;
		this.sequence_call_pre_post = sequence_call_pre_post;
	endfunction : configure


	(* doc$markdown = "\
        \ Runs the Bathtub test.\n\
        \ \n\
        \ `run_test()` causes the Bathtub object to read the provided feature files and execute them on the configured sequencer.\n\
        \ \n\
        \ This task is typically called from a UVM test or component's phase implementation method, such as `run_phase()`.\n\
        \ The `phase` argument is passed along from the phase method's parameter.\n\
        \ Be sure to call `configure()` prior to calling `run_test()`.\n\
        \ \n\
        \ Typical usage:\n\
        \ ```sv\n\
        \ class bathtub_test extends uvm_test;\n\
        \     ...\n\
        \     task run_phase(uvm_phase phase);\n\
        \         phase.raise_objection(this);\n\
        \         bathtub.configure(my_env.my_sequencer);\n\
        \         bathtub.run_test(phase);\n\
        \         phase.drop_objection(this);\n\
        \     endtask\n\
        \ endclass\n\
        \ ```\n\
        \ If Bathtub encounters any feature file steps that don't have step definitions registered in the resource database,\n\
        \ then before returning, `run_test()` outputs a step definition snippet for each of the steps in the log file and in a separate file called `bathtub_snippets.svh`.\n\
        \ The snippets can be used as the basis for actual step definitions.\n\
        \ "
	*)
	virtual task run_test(uvm_phase phase);
		// --------------------------------

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

		write_snippets();

`ifdef BATHTUB_VERBOSITY_TEST
		`BATHTUB___TEST_VERBOSITY("bathtub_verbosity_test")
`endif // BATHTUB_VERBOSITY_TEST

	endtask : run_test


    /*
     * Writes snippets for undefined step definitions.
     *
     * As it runs, Bathtub accumulates a list of feature file steps which do not have matching step definitions.
     * `write_snippets()` produces snippets for those steps at the end of `run_test()`, writing them to the log and to a separate file in the simulation directory.
     * The snippets can be used as placeholders or starting points for actual step definitions.
     */
	protected virtual function void write_snippets();
		// ------------------------------------------
        string file_name;
        bit[31:0] fd;

        file_name = "bathtub_snippets.svh";
        
        fd = $fopen(file_name, "w");
        if (fd == 0)
            $fatal(0, "Could not open file '%s' for writing.", file_name);

		if (undefined_steps.size() == 0) begin
			$fclose(fd);
			return;
		end

		`uvm_info_context(`BATHTUB__GET_SCOPE_NAME(), "", UVM_NONE, this)
		$display("You can use the following snippets to create step definitions for undefined steps.");
		$display("They have been saved in file `%s`.", file_name);
		$display("```");
		$fdisplay(fd, "// You can use the following snippets to create step definitions for undefined steps.\n");
		$display("`include \"uvm_macros.svh\"");
		$fdisplay(fd, "`include \"uvm_macros.svh\"");
		$display("`include \"bathtub_macros.sv\"");
		$fdisplay(fd, "`include \"bathtub_macros.sv\"\n");
		foreach (undefined_steps[i]) begin
			string snippet;

			snippet = snippets::create_snippet(undefined_steps[i]);
            $display(snippet);
            $fdisplay(fd, snippet);
		end
		$display("```");

        $fclose(fd);
	endfunction : write_snippets


	(* doc$markdown = "\
        \ Gets the plusarg options object.\n\
        \ \n\
        \ The plusarg options object contains values passed as `+bathtub_*` plusargs on the simulator command line.\n\
        \ "
	*)
	function plusarg_options get_plusarg_opts();
		// -------------------------------------
		return plusarg_opts;
	endfunction : get_plusarg_opts


	(* doc$markdown = "\
        \ Gets the list of feature files.\n\
        \ \n\
        \ `strings_t` is a typedef for `uvm_queue#(string)`.\n\
        \ "
	*)
	function strings_t get_feature_files();
		// --------------------------------
		get_feature_files = new("feature_files");
		foreach (feature_files[i]) get_feature_files.push_back(feature_files[i]);
	endfunction : get_feature_files


	(* doc$markdown = "\
        \ Concatenates strings to the end of the internal list of feature files to run.\n\
        \ \n\
        \ `files` is a queue of strings.\n\
        \ Each string should be a single filename or a whitespace-separated list of filenames for Gherkin feature files.\n\
        \ \n\
        \ e.g.\n\
        \ ```sv\n\
        \ bathtub.concat_feature_files('{\"path/to/features/feature_A.feature\"});\n\
        \ bathtub.concat_feature_files('{\"path/to/features/feature_B.feature\", \"path/to/features/feature_C.feature\"});\n\
        \ bathtub.concat_feature_files('{\"path/to/features/feature_D.feature path/to/features/feature_E.feature\"});\n\
        \ bathtub.concat_feature_files(my_queue_of_strings);\n\
        \ bathtub.run_test(phase);\n\
        \ ```\n\
        \ "
	*)
	function void concat_feature_files(string files[$]);
		// ---------------------------------------------
		feature_files = {feature_files, files};
	endfunction : concat_feature_files


	(* doc$markdown = "\
        \ Pushes a single string to the end of the internal list of feature files to run.\n\
        \ \n\
        \ `file` should be a single filename or a whitespace-separated list of filenames for Gherkin feature files.\n\
        \ e.g.\n\
        \ ```sv\n\
        \ bathtub.push_back_feature_file(\"path/to/features/feature_A.feature\");\n\
        \ bathtub.push_back_feature_file(\"path/to/features/feature_B.feature path/to/features/feature_C.feature\");\n\
        \ bathtub.run_test(phase);\n\
        \ ```\n\
        \ "
	*)
	function void push_back_feature_file(string file);
		// -------------------------------------------
		feature_files.push_back(file);
	endfunction : push_back_feature_file


	(* doc$markdown = "\
        \ Sets the Bathtub object's report object.\n\
        \ \n\
        \ By default, Bathtub is its own UVM report object for the reports (`` `uvm_info() ``, `` `uvm_error() ``, etc.) it issues.\n\
        \ This accessor assigns a different report object.\n\
        \ e.g.\n\
        \ ```sv\n\
        \ bathtub.set_report_object(uvm_root::get()); // Global object\n\
        \ bathtub.set_report_object(bathtub); // Back to self\n\
        \ ```\n\
        \ "
	*)
	function void set_report_object(uvm_report_object report_object);
		// ----------------------------------------------------------
		this.report_object = report_object;
	endfunction : set_report_object
	

	(* doc$markdown = "\
        \ Gets the Bathtub object's report object.\n\
        \ \n\
        \ By default, Bathtub is its own UVM report object for the reports (`` `uvm_info() ``, `` `uvm_error() ``, etc.) it issues, but the report object could be reassigned by `set_report_object()`.\n\
        \ Use `get_report_object()` to get the current report object.\n\
        \ "
	*)
	function uvm_report_object get_report_object();
		// ----------------------------------------
		return report_object;
	endfunction : get_report_object


	(* doc$markdown = "\
        \ Gets Bathtub's configured sequencer.\n\
        \ \n\
        \ Returns the sequencer on which Bathtub will execute all its sequences, as set by `configure()`.\n\
        \ "
	*)
	function uvm_sequencer_base get_sequencer();
		// -------------------------------------
		return sequencer;
	endfunction : get_sequencer
	

	(* doc$markdown = "\
        \ Gets Bathtub's configured sequence priority.\n\
        \ \n\
        \ Returns the sequence priority Bathtub starts all its sequences with, as set by `configure()`.\n\
        \ "
	*)
	function int get_sequence_priority();
		// ------------------------------
		return sequence_priority;
	endfunction : get_sequence_priority
	

	(* doc$markdown = "\
        \ Gets Bathtub's configured `call_pre_post` value.\n\
        \ \n\
        \ Returns the `call_pre_post` value Bathtub starts all its sequences with, as set by `configure()`.\n\
        \ "
	*)
	function bit get_sequence_call_pre_post();
		// -----------------------------------
		return sequence_call_pre_post;
	endfunction : get_sequence_call_pre_post


	(* doc$markdown = "\
        \ Gets Bathtub's dry-run status.\n\
        \ \n\
        \ If the simulation is run with the `+bathtub_dryrun` command-line plusarg, then Bathtub will parse the Gherkin feature files, but not run them.\n\
        \ The `get_dry_run()` function returns the dry-run status: 1=dry-run; 0=run. \n\
        \ "
	*)
	function bit get_dry_run();
		// --------------------
		return dry_run;
	endfunction : get_dry_run


	(* doc$markdown = "\
        \ Gets Bathtub's starting scenario number.\n\
        \ \n\
        \ The simulator command-line plusarg `+bathtub_start=<number>` sets the zero-based index of the scenario Bathtub will start running with.\n\
        \ This is useful for narrowing the simulation down to scenarios of interest, for example to reproduce failures quickly.\n\
        \ `get_starting_scenario_number()` returns the starting number.\n\
        \ "
	*)
	function int get_starting_scenario_number();
		// -------------------------------------
		return starting_scenario_number;
	endfunction : get_starting_scenario_number


	(* doc$markdown = "\
        \ Gets Bathtub's stopping scenario number.\n\
        \ \n\
        \ The simulator command-line plusarg `+bathtub_stop=<number>` sets the zero-based index of the scenario to stop running with.\n\
        \ This is useful for narrowing the simulation down to scenarios of interest, for example to reproduce failures quickly.\n\
        \ `get_stopping_scenario_number()` returns the stopping number.\n\
        \ "
	*)
	function int get_stopping_scenario_number();
		// -------------------------------------
		return stopping_scenario_number;
	endfunction : get_stopping_scenario_number


	(* doc$markdown = "\
        \ Gets the list of Bathtub's include tags.\n\
        \ \n\
        \ The simulator command-line plusarg `+bathtub_include=<tags>` sets the comma-separated list of Gherkin tags to include.\n\
        \ Only scenarios that have or inherit these tags will run.\n\
        \ `get_include_tags()` returns the list of tags.\n\
        \ "
	*)
	function strings_t get_include_tags();
		// -------------------------------
		get_include_tags = new("include_tags");
		foreach (include_tags[i]) get_include_tags.push_back(include_tags[i]);
	endfunction : get_include_tags


	(* doc$markdown = "\
        \ Gets the list of Bathtub's exclude tags.\n\
        \ \n\
        \ The simulator command-line plusarg `+bathtub_exclude=<tags>` sets the comma-separated list of Gherkin tags to exclude.\n\
        \ Scenarios that have or inherit these tags will not run.\n\
        \ `get_exclude_tags()` returns the list of tags.\n\
        \ "
	*)
	function strings_t get_exclude_tags();
		// -------------------------------
		get_exclude_tags = new("exclude_tags");
		foreach (exclude_tags[i]) get_exclude_tags.push_back(exclude_tags[i]);
	endfunction : get_exclude_tags


	(* doc$markdown = "\
        \ Adds steps to Bathtub's list of undefined steps.\n\
        \ \n\
        \ As it runs, Bathtub maintains a list of feature file steps which do not have matching step definitions.\n\
        \ The Gherkin runner uses `concat_undefined_steps()` to add a queue of `gherkin_pkg::step` objects to the end of the list.\n\
        \ Bathtub uses the list to produce snippets at the end of `run_test()`.\n\
        \ This is for internal use.\n\
        \ "
	*)
	function void concat_undefined_steps(gherkin_pkg::step steps[$]);
		// ----------------------------------------------------------
		undefined_steps = {undefined_steps, steps};
	endfunction : concat_undefined_steps

endclass : bathtub

`include "bathtub_pkg/gherkin_parser/gherkin_parser.svh"
`include "bathtub_pkg/gherkin_document_printer/gherkin_document_printer.svh"
`include "bathtub_pkg/plusarg_options.svh"
`include "bathtub_pkg/snippets.svh"

`ifndef __GHERKIN_DOCUMENT_RUNNER_SVH
`include "bathtub_pkg/gherkin_document_runner/gherkin_document_runner.svh"
`endif

`ifndef __TEST_SEQUENCE_SVH
`include "bathtub_pkg/test_sequence.svh"
`endif

`endif // __BATHTUB_SVH
