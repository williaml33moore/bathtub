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

typedef interface class test_sequence_interface;
`include "bathtub_pkg/test_sequence_interface.svh"

typedef interface class feature_sequence_interface;
`include "bathtub_pkg/feature_sequence_interface.svh"

typedef interface class rule_sequence_interface;
`include "bathtub_pkg/rule_sequence_interface.svh"

typedef interface class scenario_sequence_interface;
`include "bathtub_pkg/scenario_sequence_interface.svh"

typedef interface class step_static_attributes_interface;
`include "bathtub_pkg/step_static_attributes_interface.svh"

interface class step_attributes_interface;
	pure virtual function string get_runtime_keyword();
	pure virtual function string get_text();
	pure virtual function gherkin_pkg::step_argument get_argument();
	
	pure virtual function test_sequence_interface get_current_test_sequence();
	pure virtual function feature_sequence_interface get_current_feature_sequence();
	pure virtual function rule_sequence_interface get_current_rule_sequence();
	pure virtual function scenario_sequence_interface get_current_scenario_sequence();

	pure virtual function void print_attributes(uvm_verbosity verbosity);
endclass : step_attributes_interface

`endif // __STEP_ATTRIBUTES_INTERFACE_SVH
