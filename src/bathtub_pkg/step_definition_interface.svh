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

`ifndef __STEP_DEFINITION_INTERFACE_SVH
`define __STEP_DEFINITION_INTERFACE_SVH

typedef interface class step_attributes_interface;
`include "bathtub_pkg/step_attributes_interface.svh"

typedef interface class test_sequence_interface;
`include "bathtub_pkg/test_sequence_interface.svh"

typedef interface class feature_sequence_interface;
`include "bathtub_pkg/feature_sequence_interface.svh"

typedef interface class rule_sequence_interface;
`include "bathtub_pkg/rule_sequence_interface.svh"

typedef interface class scenario_sequence_interface;
`include "bathtub_pkg/scenario_sequence_interface.svh"

(* doc$markdown = "\
Interface class for the user's step definition classes.\
\
In order for Bathtub to run Gherkin feature files, every step in the feature file needs to be implemented by a user-created step definition class.\
Every step definition class must satisfy two criteria:\
1. It must extend the `uvm_pkg::uvm_sequence_base` class directly or indirectly.\
2. It must implement the `bathtub_pkg::step_definition_interface` class directly or indirectly.\
\
When a class is declared as a `step_definition_interface`, it must implement all its interface methods.\
This is easily accomplished automatically if the step definition class includes one of the Bathtub step definition macros:\
* `Given()\
* `When()\
* `Then()\
* `virtual_step_definition()\
\
All of these macros expand into implementations of the required `step_definition_interface` methods.\
This is an example of a working step definition that satisfies the Bathtub criteria.\
It extends `uvm_sequence`, which itself is a child of `uvm_sequence_base`,\
it implements `step_definition_interface` in the declaration,\
and it contains a `` `When()`` macro which expands into implementations of the required `step_definition_interface` class methods.\
Every UVM class must include an object utility macro like `` `uvm_object_utils()`` or equivalent, and a constructor `new()`.\
Finally every UVM sequence class will override the `uvm_sequence_base::body()` task in order to provide its unique behavior.\
```sv\
class user_step_definition extends uvm_pkg::uvm_sequence implements bathtub_pkg::step_definition_interface;\
	`When(\"the step definition prints 'Hello, World!'\")\
\
	`uvm_object_utils(user_step_definition)\
\
	function new (string name=\"user_step_definition\");\
		super.new(name);\
	endfunction\
\
	virtual task body();\
		`uvm_info(\"WHEN\", \"Hello, World!\", UVM_NONE)\
	endtask\
endclass\
```\
\
The `step_definition_interface` class methods provide a rich API the user-defined step definition class can use for introspection,\
and for observation and manipulation of the Bathtub environment.\
The class diagram below illustrates the cascading stack of resources and the paths to reach them.\
This list summarizes a subset of accessors and utilities available to the class' methods.\
They are all detailed in their respective documentation sections.\
```sv\
// Static step attributes\
// See the `step_static_attributes_interface` Class Reference.\
this.get_step_static_attributes().get_keyword()\
this.get_step_static_attributes().get_regexp()\
this.get_step_static_attributes().get_expression()\
this.get_step_static_attributes().get_step_obj()\
this.get_step_static_attributes().get_step_obj_name()\
this.get_step_static_attributes().print_attributes()\
\
// Dynamic step attributes\
// See the `step attributes_interface` Class Reference.\
this.get_step_attributes().get_runtime_keyword()\
this.get_step_attributes().get_text()\
this.get_step_attributes().get_argument()\
this.get_step_attributes().get_static_attributes()\
this.get_step_attributes().get_format()\
this.get_step_attributes().get_static_keyword()\
this.get_step_attributes().get_expression()\
this.get_step_attributes().get_regexp()\
this.get_step_attributes().get_step_obj()\
this.get_step_attributes().get_step_obj_name()\
this.get_step_attributes().get_current_test_sequence()\
this.get_step_attributes().get_current_feature_sequence()\
this.get_step_attributes().get_current_rule_sequence()\
this.get_step_attributes().get_current_scenario_sequence()\
this.get_step_attributes().print_attributes()\
\
// Context sequences\
this.get_current_test_sequence().get_bathtub_object()\
\
// Context sequence pools\
// The \"*\" stands for \"test,\" \"feature,\" \"rule,\" or \"scenario.\"\
// See the `pool_provider_interface` Class Reference.\
this.get_current_*_sequence().get_shortint_pool()\
this.get_current_*_sequence().get_int_pool()\
this.get_current_*_sequence().get_longint_pool()\
this.get_current_*_sequence().get_byte_pool()\
this.get_current_*_sequence().get_integer_pool()\
this.get_current_*_sequence().get_time_pool()\
this.get_current_*_sequence().get_real_pool()\
this.get_current_*_sequence().get_shortreal_pool()\
this.get_current_*_sequence().get_realtime_pool()\
this.get_current_*_sequence().get_string_pool()\
this.get_current_*_sequence().get_uvm_object_pool()\
```\
\
```mermaid\
---\
title: Class Diagram\
---\
classDiagram\
    namespace bathtub_pkg{\
        class user_step_definition{\
            %% +__step_static_attributes : step_static_attributes_interface$\
            %% +__step_attributes : step_attributes_interface\
        }\
        class step_definition_interface{\
            <<interface>>\
            +get_step_attributes() : step_attributes_interface\
            +set_step_attributes(step_attributes_interface step_attributes) : void\
            +get_step_static_attributes() : step_static_attributes_interface\
            +get_current_test_sequence() : test_sequence_interface\
            +set_current_test_sequence(test_sequence_interface seq) : void\
            +get_current_feature_sequence() : feature_sequence_interface\
            +set_current_feature_sequence(feature_sequence_interface seq) : void\
            +get_current_rule_sequence() : rule_sequence_interface\
            +set_current_rule_sequence(rule_sequence_interface seq) : void\
            +get_current_scenario_sequence() : scenario_sequence_interface\
            +set_current_scenario_sequence(scenario_sequence_interface seq) : void\
        }\
        class step_nature{\
            step_keyword_t : keyword\
            expression : string\
            regexp : string\
            step_obj :  uvm_object_wrapper\
            step_obj_name :  string\
        }\
        class step_nurture{\
            +runtime_keyword : string\
            +text : string\
            +argument : gherkin_pkg::step_argument\
            +static_attributes : step_static_attributes_interface\
            +current_test_seq : test_sequence_interface\
            +current_feature_seq : feature_sequence_interface\
            +current_rule_seq : rule_sequence_interface\
            +current_scenario_seq : scenario_sequence_interface\
        }\
        class step_static_attributes_interface{\
            <<interface>>\
            +set_keyword(step_keyword_t keyword) : void\
            +get_keyword() : step_keyword_t\
            +set_regexp(string regexp) : void\
            +get_regexp() : string\
            +get_expression() : string\
            +set_expression(string expression) : void\
            +get_step_obj() : uvm_object_wrapper\
            +set_step_obj(uvm_object_wrapper step_obj) : void\
            +get_step_obj_name() : string\
            +print_attributes(uvm_verbosity verbosity) : void\
        }\
        class step_attributes_interface{\
            <<interface>>\
            +get_runtime_keyword() : string\
            +set_runtime_keyword(string runtime_keyword) : void\
            +get_text() : string\
            +set_text(string step_text) : void\
            +get_argument() : gherkin_pkg::step_argument\
            +set_argument(gherkin_pkg::step_argument step_argument) : void\
            +get_static_attributes() : step_static_attributes_interface\
            +set_static_attributes(step_static_attributes_interface static_attributes) : void\
            +get_format() : string\
            +get_static_keyword() : step_keyword_t\
            +get_expression() : string\
            +get_regexp() : string\
            +get_step_obj() : uvm_object_wrapper\
            +get_step_obj_name() : string\
            +get_current_test_sequence() : test_sequence_interface\
            +set_current_test_sequence(test_sequence_interface seq) : void\
            +get_current_feature_sequence() : feature_sequence_interface\
            +set_current_feature_sequence(feature_sequence_interface seq) : void\
            +get_current_rule_sequence() : rule_sequence_interface\
            +set_current_rule_sequence(rule_sequence_interface seq) : void\
            +get_current_scenario_sequence() : scenario_sequence_interface\
            +set_current_scenario_sequence(scenario_sequence_interface seq) : void\
            +print_attributes(uvm_verbosity verbosity) : void\
        }\
        class pool_provider_interface{\
            <<interface>>\
            +get_shortint_pool() : uvm_pool#(string, shortint)\
            +get_int_pool() : uvm_pool#(string, int)\
            +get_longint_pool() : uvm_pool#(string, longint)\
            +get_byte_pool() : uvm_pool#(string, byte)\
            +get_integer_pool() : uvm_pool#(string, integer)\
            +get_time_pool() : uvm_pool#(string, time) \
            +get_real_pool() : uvm_pool#(string, real)\
            +get_shortreal_pool() : uvm_pool#(string, shortreal) \
            +get_realtime_pool() : uvm_pool#(string, realtime)\
            +get_string_pool() : uvm_pool#(string, string)\
            +get_uvm_object_pool() : uvm_pool#(string, uvm_object)\
        }\
        class pool_provider{\
            +shortint_pool : uvm_pool#(string, shortint)\
            +int_pool : uvm_pool#(string, int)\
            +longint_pool : uvm_pool#(string, longint)\
            +byte_pool : uvm_pool#(string, byte)\
            +integer_pool : uvm_pool#(string, integer)\
            +time_pool : uvm_pool#(string, time) \
            +real_pool : uvm_pool#(string, real)\
            +hortreal_pool : uvm_pool#(string, shortreal) \
            +realtime_pool : uvm_pool#(string, realtime)\
            +string_pool : uvm_pool#(string, string)\
            +uvm_object_pool : uvm_pool#(string, uvm_object)\
        }\
        class test_sequence{\
            #bt : bathtub\
        }\
        class feature_sequence{\
            #feature : gherkin_pkg::feature\
        }\
        class rule_sequence{\
		    #rule : gherkin_pkg::rule\
		}\
        class scenario_sequence{\
		    #scenario : gherkin_pkg::scenario\
		}\
        class test_sequence_interface{\
            <<interface>>\
            +get_bathtub_object() : bathtub\
        }\
        class feature_sequence_interface{\
            <<interface>>\
            +get_feature() : gherkin_pkg::feature\
        }\
        class rule_sequence_interface{\
            <<interface>>\
	        +get_rule() : gherkin_pkg::rule\
        }\
        class scenario_sequence_interface{\
            <<interface>>\
			+get_scenario() : gherkin_pkg::scenario\
        }\
        class context_sequence\
    }\
    namespace uvm_pkg{\
        class uvm_pool\
        class uvm_sequence\
        %% class uvm_object\
    }\
    user_step_definition ..|> step_definition_interface\
    user_step_definition *-- step_nature\
    user_step_definition --> step_nurture\
    user_step_definition --|> uvm_sequence\
\
    %% step_nature --|> uvm_object\
    step_nature ..|> step_static_attributes_interface\
\
    %% step_nurture --|> uvm_object\
    step_nurture ..|> step_attributes_interface\
    step_nurture --> test_sequence\
    step_nurture --> feature_sequence\
    step_nurture --> rule_sequence\
    step_nurture --> scenario_sequence\
\
    test_sequence --|> context_sequence\
    test_sequence ..|> test_sequence_interface\
\
    feature_sequence --|> context_sequence\
    feature_sequence ..|> feature_sequence_interface\
\
    rule_sequence --|> context_sequence\
    rule_sequence ..|> rule_sequence_interface\
\
    scenario_sequence --|> context_sequence\
    scenario_sequence ..|> scenario_sequence_interface\
\
    test_sequence_interface --|> pool_provider_interface\
    feature_sequence_interface --|> pool_provider_interface\
    rule_sequence_interface --|> pool_provider_interface\
    scenario_sequence_interface --|> pool_provider_interface\
\
    context_sequence --> pool_provider\
    context_sequence ..|> pool_provider_interface\
\
    pool_provider ..|> pool_provider_interface\
    pool_provider \"1\" *-- \"11\" uvm_pool\
\
    uvm_sequence --|> uvm_sequence_base\
\
    note for user_step_definition \"Contains a `Given(), `When(), or `Then() macro\"\
    style user_step_definition fill:#0ff\
```\
\
"*)
interface class step_definition_interface;
	pure virtual function step_attributes_interface get_step_attributes();
	pure virtual function void set_step_attributes(step_attributes_interface step_attributes);
	pure virtual function step_static_attributes_interface get_step_static_attributes();
	pure virtual function test_sequence_interface get_current_test_sequence();
	pure virtual function void set_current_test_sequence(test_sequence_interface seq);
	pure virtual function feature_sequence_interface get_current_feature_sequence();
	pure virtual function void set_current_feature_sequence(feature_sequence_interface seq);
	pure virtual function rule_sequence_interface get_current_rule_sequence();
	pure virtual function void set_current_rule_sequence(rule_sequence_interface seq);
	pure virtual function scenario_sequence_interface get_current_scenario_sequence();
	pure virtual function void set_current_scenario_sequence(scenario_sequence_interface seq);
endclass : step_definition_interface

`endif // __STEP_DEFINITION_INTERFACE_SVH
