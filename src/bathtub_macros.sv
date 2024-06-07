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

`ifndef BATHTUB_MACROS_SV
`define BATHTUB_MACROS_SV

`ifdef EDAPG
`undef BATHTUB__MULTILINE_MACRO_IS_OK
`else
`define BATHTUB__MULTILINE_MACRO_IS_OK
`endif

`define Given(e) `__register_step_def(bathtub_pkg::Given, e)

`define When(e) `__register_step_def(bathtub_pkg::When, e)

`define Then(e) `__register_step_def(bathtub_pkg::Then, e)

`ifdef BATHTUB__MULTILINE_MACRO_IS_OK

`define __register_step_def(k, e) static bathtub_pkg::step_static_attributes_interface __step_static_attributes = bathtub_pkg::step_nature::register_step(k, e, get_type());\
bathtub_pkg::step_attributes_interface __step_attributes;\
virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes();\
return __step_static_attributes;\
endfunction : get_step_static_attributes\
virtual function bathtub_pkg::step_attributes_interface get_step_attributes();\
return __step_attributes;\
endfunction : get_step_attributes\
virtual function void set_step_attributes(bathtub_pkg::step_attributes_interface step_attributes);\
this.__step_attributes = step_attributes;\
endfunction : set_step_attributes\
virtual function bathtub_pkg::feature_sequence_interface get_current_feature_sequence();\
return this.__step_attributes.get_current_feature_sequence();\
endfunction : get_current_feature_sequence\
virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq);\
this.__step_attributes.set_current_feature_sequence(seq);\
endfunction : set_current_feature_sequence\
virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence();\
return this.__step_attributes.get_current_scenario_sequence();\
endfunction : get_current_scenario_sequence\
virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq);\
this.__step_attributes.set_current_scenario_sequence(seq);\
endfunction : set_current_scenario_sequence

`else // BATHTUB__MULTILINE_MACRO_IS_OK
`define __register_step_def(k, e) static bathtub_pkg::step_static_attributes_interface __step_static_attributes = bathtub_pkg::step_nature::register_step(k, e, get_type()); bathtub_pkg::step_attributes_interface __step_attributes; virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes(); return __step_static_attributes; endfunction : get_step_static_attributes virtual function bathtub_pkg::step_attributes_interface get_step_attributes(); return __step_attributes; endfunction : get_step_attributes virtual function void set_step_attributes(bathtub_pkg::step_attributes_interface step_attributes); this.__step_attributes = step_attributes; endfunction : set_step_attributes virtual function bathtub_pkg::feature_sequence_interface get_current_feature_sequence(); return this.__step_attributes.get_current_feature_sequence(); endfunction : get_current_feature_sequence virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq); this.__step_attributes.set_current_feature_sequence(seq); endfunction : set_current_feature_sequence virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence(); return this.__step_attributes.get_current_scenario_sequence(); endfunction : get_current_scenario_sequence virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq); this.__step_attributes.set_current_scenario_sequence(seq); endfunction : set_current_scenario_sequence
`endif // BATHTUB__MULTILINE_MACRO_IS_OK

`ifdef BATHTUB__MULTILINE_MACRO_IS_OK

`define virtual_step_definition(e) virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes();\
return null;\
endfunction : get_step_static_attributes\
virtual function bathtub_pkg::step_attributes_interface get_step_attributes();\
return null;\
endfunction : get_step_attributes\
virtual function void set_step_attributes(bathtub_pkg::step_attributes_interface step_attributes);\
endfunction : set_step_attributes\
virtual function bathtub_pkg::feature_sequence_interface get_current_feature_sequence();\
return null;\
endfunction : get_current_feature_sequence\
virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq);\
endfunction : set_current_feature_sequence\
virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence();\
return null;\
endfunction : get_current_scenario_sequence\
virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq);\
endfunction : set_current_scenario_sequence

`else // BATHTUB__MULTILINE_MACRO_IS_OK
`define virtual_step_definition(e) virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes(); return null; endfunction : get_step_static_attributes virtual function bathtub_pkg::step_attributes_interface get_step_attributes(); return null; endfunction : get_step_attributes virtual function void set_step_attributes(bathtub_pkg::step_attributes_interface step_attributes); endfunction : set_step_attributes virtual function bathtub_pkg::feature_sequence_interface get_current_feature_sequence(); return null; endfunction : get_current_feature_sequence virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq); endfunction : set_current_feature_sequence virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence(); return null; endfunction : get_current_scenario_sequence virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq); endfunction : set_current_scenario_sequence
`endif // BATHTUB__MULTILINE_MACRO_IS_OK



`ifdef BATHTUB__MULTILINE_MACRO_IS_OK

`define step_parameter_get_args_begin(f=get_step_attributes().get_expression())\
begin : step_parameter_get_args\
    bathtub_pkg::step_parameters __step_params;\
    int __next = 0;\
	__step_params = bathtub_pkg::step_parameters::create_new("__step_params", get_step_attributes().get_text(), f);

`else // BATHTUB__MULTILINE_MACRO_IS_OK
`define step_parameter_get_args_begin(f=get_step_attributes().get_expression()) begin : step_parameter_get_args    bathtub_pkg::step_parameters __step_params;    int __next = 0;	__step_params = bathtub_pkg::step_parameters::create_new("__step_params", get_step_attributes().get_text(), f);
`endif // BATHTUB__MULTILINE_MACRO_IS_OK

`define step_parameter_get_arg_object(i) __step_params.get_arg(i)

`define step_parameter_get_arg_as(i, t) `step_parameter_get_arg_object(i).as_``t()

`define step_parameter_get_next_arg_object `step_parameter_get_arg_object(__next++)

`define step_parameter_get_next_arg_as(t) `step_parameter_get_next_arg_object.as_``t()

`define step_parameter_num_args __step_params.num_args()

`define step_parameter_get_args_end end : step_parameter_get_args

`define get_scope_name(d) ($sformatf("%m")) // TODO - Extract the last segment

`endif // BATHTUB_MACROS_SV
