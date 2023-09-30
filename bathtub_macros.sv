
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
bathtub_pkg::feature_sequence_interface __current_feature_seq;\
bathtub_pkg::scenario_sequence_interface __current_scenario_seq;\
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
return this.__current_feature_seq;\
endfunction : get_current_feature_sequence\
virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq);\
this.__current_feature_seq = seq;\
endfunction : set_current_feature_sequence\
virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence();\
return this.__current_scenario_seq;\
endfunction : get_current_scenario_sequence\
virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq);\
this.__current_scenario_seq = seq;\
endfunction : set_current_scenario_sequence

`else // BATHTUB__MULTILINE_MACRO_IS_OK
`define __register_step_def(k, e) static bathtub_pkg::step_static_attributes_interface __step_static_attributes = bathtub_pkg::step_nature::register_step(k, e, get_type()); bathtub_pkg::step_attributes_interface __step_attributes; bathtub_pkg::feature_sequence_interface __current_feature_seq; bathtub_pkg::scenario_sequence_interface __current_scenario_seq; virtual function bathtub_pkg::step_static_attributes_interface get_step_static_attributes(); return __step_static_attributes; endfunction : get_step_static_attributes virtual function bathtub_pkg::step_attributes_interface get_step_attributes(); return __step_attributes; endfunction : get_step_attributes virtual function void set_step_attributes(bathtub_pkg::step_attributes_interface step_attributes); this.__step_attributes = step_attributes; endfunction : set_step_attributes virtual function bathtub_pkg::feature_sequence_interface get_current_feature_sequence(); return this.__current_feature_seq; endfunction : get_current_feature_sequence virtual function void set_current_feature_sequence(bathtub_pkg::feature_sequence_interface seq); this.__current_feature_seq = seq; endfunction : set_current_feature_sequence virtual function bathtub_pkg::scenario_sequence_interface get_current_scenario_sequence(); return this.__current_scenario_seq; endfunction : get_current_scenario_sequence virtual function void set_current_scenario_sequence(bathtub_pkg::scenario_sequence_interface seq); this.__current_scenario_seq = seq; endfunction : set_current_scenario_sequence
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
    step_parameters __step_params;\
    int __next = 0;\
	__step_params = step_parameters::create_new("__step_params", get_step_attributes().get_text(), f);

`else // BATHTUB__MULTILINE_MACRO_IS_OK
`define step_parameter_get_args_begin(f=get_step_attributes().get_expression()) begin : step_parameter_get_args    step_parameters __step_params;    int __next = 0;	__step_params = step_parameters::create_new("__step_params", get_step_attributes().get_text(), f);
`endif // BATHTUB__MULTILINE_MACRO_IS_OK

`define step_parameter_get_arg_object(i) __step_params.get_arg(i)

`define step_parameter_get_arg_as(i, t) `step_parameter_get_arg_object(i).as_``t()

`define step_parameter_get_next_arg_object `step_parameter_get_arg_object(__next++)

`define step_parameter_get_next_arg_as(t) `step_parameter_get_next_arg_object.as_``t()

`define step_parameter_num_args __step_params.num_args()

`define step_parameter_get_args_end end : step_parameter_get_args

`define get_scope_name(d) ($sformatf("%m")) // TODO - Extract the last segment

`endif // BATHTUB_MACROS_SV
