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

`ifndef __STEP_NURTURE_SVH
`define __STEP_NURTURE_SVH

import gherkin_pkg::gherkin_pkg_metadata;

`include "uvm_macros.svh"
`include "bathtub_macros.sv"
`include "bathtub_pkg/step_attributes_interface.svh"
`include "bathtub_pkg/step_definition_interface.svh"
`include "bathtub_pkg/test_sequence_interface.svh"
`include "bathtub_pkg/feature_sequence_interface.svh"
`include "bathtub_pkg/scenario_sequence_interface.svh"

class step_nurture extends uvm_object implements step_attributes_interface;

	string runtime_keyword;
	string text;
	gherkin_pkg::step_argument argument;
	step_static_attributes_interface static_attributes;
	test_sequence_interface current_test_seq;
	feature_sequence_interface current_feature_seq;
	scenario_sequence_interface current_scenario_seq;

	function new(string name="step_nurture");
		super.new(name);
		current_test_seq = null;
		current_feature_seq = null;
		current_scenario_seq = null;
	endfunction : new

	`uvm_object_utils_begin(step_nurture)
		`uvm_field_string(runtime_keyword, UVM_ALL_ON)
		`uvm_field_string(text, UVM_ALL_ON)
		`uvm_field_object(argument, UVM_ALL_ON)
	`uvm_object_utils_end
	
	virtual function void print_attributes(uvm_verbosity verbosity);
		`uvm_info_begin(get_name(), "", verbosity)
		`uvm_message_add_string(runtime_keyword)
		`uvm_message_add_string(text)
		`uvm_message_add_object(argument)
		`uvm_info_end
		static_attributes.print_attributes(verbosity);
	endfunction : print_attributes

	virtual function string get_runtime_keyword();
		return this.runtime_keyword;
	endfunction : get_runtime_keyword

	virtual function void set_runtime_keyword(string runtime_keyword);
		this.runtime_keyword = runtime_keyword;
	endfunction : set_runtime_keyword
	
	virtual function string get_text();
		return this.text;
	endfunction : get_text

	virtual function void set_text(string step_text);
		this.text = step_text;
	endfunction : set_text

	virtual function gherkin_pkg::step_argument get_argument();
		return this.argument;
	endfunction : get_argument

	virtual function void set_argument(gherkin_pkg::step_argument step_argument);
		this.argument = step_argument;
	endfunction : set_argument

	virtual function void set_static_attributes(step_static_attributes_interface static_attributes);
		this.static_attributes = static_attributes;			
	endfunction : set_static_attributes

	virtual function step_static_attributes_interface get_static_attributes();
		return this.static_attributes;			
	endfunction : get_static_attributes

	virtual function string get_format();
		return static_attributes.get_expression();
	endfunction : get_format

	virtual function step_keyword_t get_static_keyword();
		return static_attributes.get_keyword();
	endfunction : get_static_keyword

	virtual function string get_expression();
		return static_attributes.get_expression();
	endfunction : get_expression

	virtual function string get_regexp();
		return static_attributes.get_regexp();
	endfunction : get_regexp
	
	virtual function uvm_object_wrapper get_step_obj();
		return static_attributes.get_step_obj();
	endfunction : get_step_obj

	virtual function string get_step_obj_name();
		return static_attributes.get_step_obj_name();
	endfunction : get_step_obj_name

	virtual function test_sequence_interface get_current_test_sequence();
		return this.current_test_seq;
	endfunction : get_current_test_sequence

	virtual function void set_current_test_sequence(test_sequence_interface seq);
		this.current_test_seq = seq;
	endfunction : set_current_test_sequence

	virtual function feature_sequence_interface get_current_feature_sequence();
		return this.current_feature_seq;
	endfunction : get_current_feature_sequence

	virtual function void set_current_feature_sequence(feature_sequence_interface seq);
		this.current_feature_seq = seq;
	endfunction : set_current_feature_sequence

	virtual function scenario_sequence_interface get_current_scenario_sequence();
		return this.current_scenario_seq;
	endfunction : get_current_scenario_sequence

	virtual function void set_current_scenario_sequence(scenario_sequence_interface seq);
		this.current_scenario_seq = seq;
	endfunction : set_current_scenario_sequence

	virtual function void configure(
		gherkin_pkg::step step,
		step_definition_interface step_seq,
		scenario_sequence_interface current_scenario_seq = null,
		feature_sequence_interface current_feature_seq = null,
		test_sequence_interface current_test_seq = null
		);
		set_runtime_keyword(step.keyword);
		set_text(step.text);
		set_argument(step.argument);
		set_static_attributes(step_seq.get_step_static_attributes());
		set_current_scenario_sequence(current_scenario_seq);
		set_current_feature_sequence(current_feature_seq);
		set_current_test_sequence(current_test_seq);
	endfunction : configure

endclass : step_nurture

`endif // __STEP_NURTURE_SVH
