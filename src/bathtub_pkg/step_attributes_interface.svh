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

`ifndef __STEP_ATTRIBUTES_INTERFACE_SVH
`define __STEP_ATTRIBUTES_INTERFACE_SVH

typedef interface class feature_sequence_interface;
`include "bathtub_pkg/feature_sequence_interface.svh"

typedef interface class scenario_sequence_interface;
`include "bathtub_pkg/scenario_sequence_interface.svh"

typedef interface class step_static_attributes_interface;
`include "bathtub_pkg/step_static_attributes_interface.svh"

interface class step_attributes_interface;
	pure virtual function string get_runtime_keyword();
	pure virtual function void set_runtime_keyword(string runtime_keyword);
	pure virtual function string get_text();
	pure virtual function void set_text(string step_text);
	pure virtual function gherkin_pkg::step_argument get_argument();
	pure virtual function void set_argument(gherkin_pkg::step_argument step_argument);
	pure virtual function step_static_attributes_interface get_static_attributes();
	pure virtual function void set_static_attributes(step_static_attributes_interface static_attributes);
	pure virtual function string get_format();
			
	pure virtual function step_keyword_t get_static_keyword();
	pure virtual function string get_expression();
	pure virtual function string get_regexp();
	pure virtual function uvm_object_wrapper get_step_obj();
	pure virtual function string get_step_obj_name();
	
	pure virtual function feature_sequence_interface get_current_feature_sequence();
	pure virtual function void set_current_feature_sequence(feature_sequence_interface seq);
	pure virtual function scenario_sequence_interface get_current_scenario_sequence();
	pure virtual function void set_current_scenario_sequence(scenario_sequence_interface seq);

	pure virtual function void print_attributes(uvm_verbosity verbosity);
endclass : step_attributes_interface

`endif // __STEP_ATTRIBUTES_INTERFACE_SVH
