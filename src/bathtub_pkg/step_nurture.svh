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
`include "bathtub_pkg/rule_sequence_interface.svh"
`include "bathtub_pkg/scenario_sequence_interface.svh"

class step_nurture extends uvm_object implements step_attributes_interface;

	protected string runtime_keyword;
	protected string text;
	protected gherkin_pkg::step_argument argument;
	protected test_sequence_interface current_test_seq;
	protected feature_sequence_interface current_feature_seq;
	protected rule_sequence_interface current_rule_seq;
	protected scenario_sequence_interface current_scenario_seq;

	function new(
			string name="step_nurture",
			gherkin_pkg::step step = null,
			step_definition_interface step_seq = null,
			scenario_sequence_interface current_scenario_seq = null,
			rule_sequence_interface current_rule_seq = null,
			feature_sequence_interface current_feature_seq = null,
			test_sequence_interface current_test_seq = null
		);
		super.new(name);
		this.runtime_keyword = step.get_keyword();
		this.text = step.get_text();
		this.argument = step.get_argument();
		this.current_scenario_seq = current_scenario_seq;
		this.current_rule_seq = current_rule_seq;
		this.current_feature_seq = current_feature_seq;
		this.current_test_seq = current_test_seq;
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

	virtual function test_sequence_interface get_current_test_sequence();
		return this.current_test_seq;
	endfunction : get_current_test_sequence

	virtual function feature_sequence_interface get_current_feature_sequence();
		return this.current_feature_seq;
	endfunction : get_current_feature_sequence

	virtual function rule_sequence_interface get_current_rule_sequence();
		return this.current_rule_seq;
	endfunction : get_current_rule_sequence

	virtual function scenario_sequence_interface get_current_scenario_sequence();
		return this.current_scenario_seq;
	endfunction : get_current_scenario_sequence

endclass : step_nurture

`endif // __STEP_NURTURE_SVH
