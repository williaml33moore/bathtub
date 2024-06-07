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

`ifndef __BATHTUB_MACROS_SV
`define __BATHTUB_MACROS_SV

// Macros for use in step definitions
// ==================================
`define Given `BATHTUB__GIVEN
`define When `BATHTUB__WHEN
`define Then `BATHTUB__THEN
`define virtual_step_definition `BATHTUB__VIRTUAL_STEP_DEFINITION
`define step_parameter_get_args_begin `BATHTUB__STEP_PARAMETER_GET_ARGS_BEGIN
`define step_parameter_get_arg_object `BATHTUB__STEP_PARAMETER_GET_ARG_OBJECT
`define step_parameter_get_arg_as `BATHTUB__STEP_PARAMETER_GET_ARG_AS
`define step_parameter_get_next_arg_object `BATHTUB__STEP_PARAMETER_GET_NEXT_ARG_OBJECT
`define step_parameter_get_next_arg_as `BATHTUB__STEP_PARAMETER_GET_NEXT_ARG_AS
`define step_parameter_num_args `BATHTUB__STEP_PARAMETER_NUM_ARGS
`define step_parameter_get_args_end `BATHTUB__STEP_PARAMETER_GET_ARGS_END

`ifdef EDAPG
`undef BATHTUB__MULTILINE_MACRO_IS_OK
`else
`define BATHTUB__MULTILINE_MACRO_IS_OK
`endif

`define BATHTUB__GIVEN(e) `BATHTUB__REGISTER_STEP_DEF(bathtub_pkg::Given, e)

`define BATHTUB__WHEN(e) `BATHTUB__REGISTER_STEP_DEF(bathtub_pkg::When, e)

`define BATHTUB__THEN(e) `BATHTUB__REGISTER_STEP_DEF(bathtub_pkg::Then, e)

`ifdef BATHTUB__MULTILINE_MACRO_IS_OK

`define BATHTUB__REGISTER_STEP_DEF(k, e) static bathtub_pkg::step_static_attributes_interface __step_static_attributes = bathtub_pkg::step_nature::register_step(k, e, get_type());\
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
`define BATHTUB__REGISTER_STEP_DEF(k, e) static bathtub_pkg::step_static_attributes_interface __step_static_attributes = bathtub_pkg::step_nature::register_step(k, e, get_type()); bathtub_pkg::step_attributes_interface __step_attributes; virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes(); return __step_static_attributes; endfunction : get_step_static_attributes virtual function bathtub_pkg::step_attributes_interface get_step_attributes(); return __step_attributes; endfunction : get_step_attributes virtual function void set_step_attributes(bathtub_pkg::step_attributes_interface step_attributes); this.__step_attributes = step_attributes; endfunction : set_step_attributes virtual function bathtub_pkg::feature_sequence_interface get_current_feature_sequence(); return this.__step_attributes.get_current_feature_sequence(); endfunction : get_current_feature_sequence virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq); this.__step_attributes.set_current_feature_sequence(seq); endfunction : set_current_feature_sequence virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence(); return this.__step_attributes.get_current_scenario_sequence(); endfunction : get_current_scenario_sequence virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq); this.__step_attributes.set_current_scenario_sequence(seq); endfunction : set_current_scenario_sequence
`endif // BATHTUB__MULTILINE_MACRO_IS_OK

`ifdef BATHTUB__MULTILINE_MACRO_IS_OK

`define BATHTUB__VIRTUAL_STEP_DEFINITION(e) virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes();\
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
`define BATHTUB__VIRTUAL_STEP_DEFINITION(e) virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes(); return null; endfunction : get_step_static_attributes virtual function bathtub_pkg::step_attributes_interface get_step_attributes(); return null; endfunction : get_step_attributes virtual function void set_step_attributes(bathtub_pkg::step_attributes_interface step_attributes); endfunction : set_step_attributes virtual function bathtub_pkg::feature_sequence_interface get_current_feature_sequence(); return null; endfunction : get_current_feature_sequence virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq); endfunction : set_current_feature_sequence virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence(); return null; endfunction : get_current_scenario_sequence virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq); endfunction : set_current_scenario_sequence
`endif // BATHTUB__MULTILINE_MACRO_IS_OK



`ifdef BATHTUB__MULTILINE_MACRO_IS_OK

`define BATHTUB__STEP_PARAMETER_GET_ARGS_BEGIN(f=get_step_attributes().get_expression())\
begin : step_parameter_get_args\
    bathtub_pkg::step_parameters __step_params;\
    int __next = 0;\
	__step_params = bathtub_pkg::step_parameters::create_new("__step_params", get_step_attributes().get_text(), f);

`else // BATHTUB__MULTILINE_MACRO_IS_OK
`define BATHTUB__STEP_PARAMETER_GET_ARGS_BEGIN(f=get_step_attributes().get_expression()) begin : step_parameter_get_args    bathtub_pkg::step_parameters __step_params;    int __next = 0;	__step_params = bathtub_pkg::step_parameters::create_new("__step_params", get_step_attributes().get_text(), f);
`endif // BATHTUB__MULTILINE_MACRO_IS_OK

`define BATHTUB__STEP_PARAMETER_GET_ARG_OBJECT(i) __step_params.get_arg(i)

`define BATHTUB__STEP_PARAMETER_GET_ARG_AS(i, t) `BATHTUB__STEP_PARAMETER_GET_ARG_OBJECT(i).as_``t()

`define BATHTUB__STEP_PARAMETER_GET_NEXT_ARG_OBJECT `BATHTUB__STEP_PARAMETER_GET_ARG_OBJECT(__next++)

`define BATHTUB__STEP_PARAMETER_GET_NEXT_ARG_AS(t) `BATHTUB__STEP_PARAMETER_GET_NEXT_ARG_OBJECT.as_``t()

`define BATHTUB__STEP_PARAMETER_NUM_ARGS __step_params.num_args()

`define BATHTUB__STEP_PARAMETER_GET_ARGS_END end : step_parameter_get_args

`define get_scope_name(d) ($sformatf("%m")) // TODO - Extract the last segment

`endif // __BATHTUB_MACROS_SV
