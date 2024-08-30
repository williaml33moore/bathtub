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

typedef interface class step_static_attributes_interface;
typedef interface class step_attributes_interface;
typedef interface class test_sequence_interface;
typedef interface class feature_sequence_interface;
typedef interface class rule_sequence_interface;
typedef interface class scenario_sequence_interface;

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
This list summarizes a selection of accessors and utilities available to the class' methods.\
They are all detailed in their respective documentation sections.\
```sv\
// Static step attributes\
// See the `step_static_attributes_interface` Class Reference.\
this.get_step_static_attributes().get_keyword();\
this.get_step_static_attributes().get_regexp();\
this.get_step_static_attributes().get_expression();\
this.get_step_static_attributes().get_step_obj();\
this.get_step_static_attributes().get_step_obj_name();\
this.get_step_static_attributes().print_attributes();\
\
// Run-time step attributes\
// See the `step attributes_interface` Class Reference.\
this.get_step_attributes().get_step();\
this.get_step_attributes().get_current_test_sequence();\
this.get_step_attributes().get_current_feature_sequence();\
this.get_step_attributes().get_current_rule_sequence();\
this.get_step_attributes().get_current_scenario_sequence();\
this.get_step_attributes().print_attributes();\
\
// Context sequences\
// See the respective sequence Class References.\
this.get_current_test_sequence().get_bathtub_object();\
this.get_current_feature_sequence().get_feature();\
this.get_current_rule_sequence().get_rule();\
this.get_current_scenario_sequence().get_scenario();\
\
// Context sequence pools\
// The \"*\" stands for \"test,\" \"feature,\" \"rule,\" or \"scenario.\"\
// See the `pool_provider_interface` Class Reference.\
this.get_current_*_sequence().get_shortint_pool();\
this.get_current_*_sequence().get_int_pool();\
this.get_current_*_sequence().get_longint_pool();\
this.get_current_*_sequence().get_byte_pool();\
this.get_current_*_sequence().get_integer_pool();\
this.get_current_*_sequence().get_time_pool();\
this.get_current_*_sequence().get_real_pool();\
this.get_current_*_sequence().get_shortreal_pool();\
this.get_current_*_sequence().get_realtime_pool();\
this.get_current_*_sequence().get_string_pool();\
this.get_current_*_sequence().get_uvm_object_pool();\
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
            #step_keyword_t : keyword\
            #expression : string\
            #regexp : string\
            #step_obj :  uvm_object_wrapper\
            #step_obj_name :  string\
        }\
        class step_nurture{\
            #step : gherkin_pkg::step\
            #current_test_seq : test_sequence_interface\
            #current_feature_seq : feature_sequence_interface\
            #current_rule_seq : rule_sequence_interface\
            #current_scenario_seq : scenario_sequence_interface\
        }\
        class step_static_attributes_interface{\
            <<interface>>\
            +get_keyword() : step_keyword_t\
            +get_regexp() : string\
            +get_expression() : string\
            +get_step_obj() : uvm_object_wrapper\
            +get_step_obj_name() : string\
            +print_attributes(uvm_verbosity verbosity) : void\
        }\
        class step_attributes_interface{\
            <<interface>>\
            +get_step() : gherkin_pkg::step\
            +get_current_test_sequence() : test_sequence_interface\
            +get_current_feature_sequence() : feature_sequence_interface\
            +get_current_rule_sequence() : rule_sequence_interface\
            +get_current_scenario_sequence() : scenario_sequence_interface\
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
            +shortreal_pool : uvm_pool#(string, shortreal) \
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
\### Context Sequences and Pools\
\
Gherkin feature files have a hierarchical structure of nested elements.\
For example, here are two feature files, each with one feature.\
The features have multiple scenarios and rules, the rules have multiple scenarios, and the scenarios have multiple steps.\
\
```gherkin\
# file_1.feature\
Feature: This is the first feature\
    Scenario: This is the first scenario\
        When the host transmits 0x00112233 # step 1\
        Then the received data should be 0x00112233 # step 2\
    Rule: This is the first rule\
        Scenario: This is the second scenario\
            When the host transmits 0x44556677 # step 3\
            Then the received data should be 0x44556677 # step 4\
        Scenario: This is the third scenario\
            When the host transmits 0x8899aabb # step 5\
            Then the received data should be 0x8899aabb # step 6\
    Rule: This is the second rule\
        Scenario: This is the fourth scenario\
            When the host transmits 0xccddeeff # step 7\
            Then the received data should be 0xccddeeff # step 8\
```\
```gherkin\
# file_2.feature\
Feature: This is the second feature\
    Scenario: This is the first scenario\
        When the host transmits 0xffeeddcc # step 9\
        Then the received data should be 0xffeeddcc # step 10\
    Rule: This is the first rule\
        Scenario: This is the second scenario\
            When the host transmits 0xbbaa9988 # step 11\
            Then the received data should be 0xbbaa9988 # step 12\
        Scenario: This is the third scenario\
            When the host transmits 0x77665544 # step 13\
            Then the received data should be 0x77665544 # step 14\
    Rule: This is the second rule\
        Scenario: This is the fourth scenario\
            When the host transmits 0x33221100 # step 15\
            Then the received data should be 0x33221100 # step 16\
```\
\
We can visualize the feature files as a tree.\
The \"Test\" at the root of the tree is an abstract concept that corresponds to the Bathtub object in the user's UVM test.\
The feature files are its children.\
The details of the second feature file are omitted for clarity.\
\
```mermaid\
---\
title: Context Sequences\
---\
classDiagram\
    class Test\
    class feature_1[\"Feature\"]{\
        \"This is the first feature\"\
    }\
    class feature_2[\"Feature\"]{\
        \"This is the second feature\"\
    }\
    class rule_1[\"Rule\"]{\
        \"This is the first rule\"\
    }\
    class rule_2[\"Rule\"]{\
        \"This is the second rule\"\
    }\
    class scenario_1[\"Scenario\"]{\
        \"This is the first scenario\"\
    }\
    class scenario_2[\"Scenario\"]{\
        \"This is the second scenario\"\
    }\
    class scenario_3[\"Scenario\"]{\
        \"This is the third scenario\"\
    }\
    class scenario_4[\"Scenario\"]{\
        \"This is the fourth scenario\"\
    }\
    class step_1[\"Step\"]{\
        step 1\
    }\
    class step_2[\"Step\"]{\
        step 2\
    }\
    class step_3[\"Step\"]{\
        step 3\
    }\
    class step_4[\"Step\"]{\
        step 4\
    }\
    class step_5[\"Step\"]{\
        step 5\
    }\
    class step_6[\"Step\"]{\
        step 6\
    }\
    class step_7[\"Step\"]{\
        step 7\
    }\
    class step_8[\"Step\"]{\
        step 8\
    }\
    Test --> feature_1\
    feature_1 --> scenario_1\
    feature_1 --> rule_1\
    rule_1 --> scenario_2\
    rule_1 --> scenario_3\
    feature_1 --> rule_2\
    rule_2 --> scenario_4\
    scenario_1 --> step_1\
    scenario_1 --> step_2\
    scenario_2 --> step_3\
    scenario_2 --> step_4\
    scenario_3 --> step_5\
    scenario_3 --> step_6\
    scenario_4 --> step_7\
    scenario_4 --> step_8\
    Test --> feature_2\
```\
\
Bathtub traverses the tree and when it reaches a step, it matches the step text to the user's step definition sequence class,\
instantiates the step sequence, and runs it on a sequencer.\
This object diagram depicts a snapshot of the moment Bathtub runs step 8, \"Then the received data should be 0xccddeeff.\"\
\
```mermaid\
---\
title: Run-time Context Sequences\
---\
classDiagram\
    class Test{\
        User calls bathtub_pkg::bathtub::run_test()\
    }\
    class feature_1[\"Feature\"]{\
        \"This is the first feature\"\
    }\
    class rule_2[\"Rule\"]{\
        \"This is the second rule\"\
    }\
    class scenario_4[\"Scenario\"]{\
        \"This is the fourth scenario\"\
    }\
    class step_8[\"Step\"]{\
        \"Then the received data should be 0xccddeeff\"\
    }\
    class step_nurture[\"step_attributes : bathtub_pkg::step_attributes_interface\"]\
    class test_seq[\"current_test_seq : bathtub_pkg::test_sequence\"] {\
        #bt : bathtub_pkg::bathtub\
        +*_pool : uvm_pool[0..11]\
    }\
    class feature_seq[\"current_feature_seq : bathtub_pkg::feature_sequence\"] {\
        #feature : gherkin_pkg::feature\
        +*_pool : uvm_pool[0..11]\
    }\
    class rule_seq[\"current_rule_seq : bathtub_pkg::rule_sequence\"]{\
        #rule : gherkin_pkg::rule\
        +*_pool : uvm_pool[0..11]\
    }\
    class scenario_seq[\"current_scenario_seq : bathtub_pkg::scenario_sequence\"]{\
        #scenario : gherkin_pkg::scenario\
        +*_pool : uvm_pool[0..11]\
    }\
    class step_seq[\"step_seq : user_step_definition\"]{\
        keyword: \"Then\"\
        expression: \"the received data should be 0x%x\"\
    }\
    %%class gherkin_step[\"gherkin_pkg::step\"]{\
    %%    #keyword : string\
    %%    #text : string\
    %%}\
    %%class gherkin_scenario[\"gherkin_pkg::scenario\"]{\
    %%    #name : string\
    %%    #steps : gherkin_pkg::step[*]\
    %%}\
    %%class gherkin_rule[\"gherkin_pkg::rule\"]{\
    %%    #name : string\
    %%    #scenarios : gherkgin_pkg::scenario[*]\
    %%}\
    %%class gherkin_feature[\"gherkin_pkg::feature\"]{\
    %%    #name : string\
    %%    #rules : gherkin_pkg::rule[*]\
    %%}\
    Test --> feature_1:child\
    test_seq .. Test\
    feature_1 --> rule_2:child\
    feature_seq --> feature_1:get_feature()\
    rule_2 --> scenario_4:child\
    rule_seq --> rule_2:get_rule()\
    scenario_4 --> step_8:child\
    scenario_seq --> scenario_4:get_scenario()\
    step_nurture --> test_seq:get_current_test_seq()\
    step_nurture --> feature_seq:get_current_feature_seq()\
    step_nurture --> rule_seq:get_current_rule_seq()\
    step_nurture --> scenario_seq:get_current_scenario_seq()\
    step_nurture --> step_8:get_step()\
    step_seq --> scenario_seq:parent\
    step_seq --> step_nurture:get_step_attributes()\
    scenario_seq --> rule_seq:parent\
    rule_seq --> feature_seq:parent\
    feature_seq --> test_seq:parent\
    style step_seq fill:#0ff\
    style Test fill:#8f0\
    style feature_1 fill:#8f0\
    style rule_2 fill:#8f0\
    style scenario_4 fill:#8f0\
    style step_8 fill:#8f0\
    %%step_8 --|> gherkin_step\
    %%scenario_4 --|> gherkin_scenario\
    %%rule_2 --|> gherkin_rule\
    %%feature_1 --|> gherkin_feature\
```\
\
The complete Gherkin tree path of Test --> Feature --> Rule --> Scenario --> Step is shown at the bottom.\
The matching `user_step_definition` instance is shown at the top.\
Every test/feature/rule/scenario element in the Gherkin tree path has an associated context sequence, shown in the middle of the diagram.\
The context sequences are themselves linked together in their own chain of parentage.\
\
The context sequences have three purposes.\
\
First, they run their associated Gherkin elements.\
The Gherkin elements are inert value objects comprised of strings parsed from the feature files.\
The context sequences are UVM sequences with active `body()` tasks that execute the Gherkin objects.\
For example if a Gherkin `feature` object has two rules, the `feature_sequence` contains the code that iterates over those rules, running each.\
\
Second, the context sequences hold references to their associated Gherkin objects.\
The user's step definition sequences can access the strings in the Gherkin objects through the context sequences.\
With this powerful capability, the step definitions can read the complete Gherkin code and act on it.\
Note that the Gherkin objects are immutable, so the step definitions can't alter or break the Gherkin tree.\
\
Third, the context sequences contain a set of UVM pools specialized for eleven different SystemVerilog data types:\
`shortint`, `int`, `longint`, `byte`, `integer`, `time`, `real`, `shortreal`, `realtime`, `string`, and `uvm_object`.\
Note the variety of two-state, four-state, integer, and real scalar types, plus one object type.\
The user step sequences can use these pools, at any level, to share data among themselves.\
\
Each context sequence is created when the test/feature/rule/scenario starts, and is destroyed when the test/feature/rule/scenario ends.\
"*)
interface class step_definition_interface;
	// ===================================

(* doc$markdown = "\
Gets the run-time step attributes object.\
\
While Bathtub is running a Gherkin feature file, when it encounters a step,\
it packages the attributes of that step into a value object and provides it to the step definition sequence.\
`get_step_attributes()` retrieves that step attributes object.\
The step definition can use it to access the step text from the feature file and any Gherkin step arguments, i.e., doc strings or data tables.\
Internally, this is how the step parameter macros extract in-line arguments from the step text.\
"*)
	pure virtual function step_attributes_interface get_step_attributes();
		// ---------------------------------------------------------------


(* doc$markdown = "\
Sets the step attributes object.\
\
Assigns the step definition's step attributes object to `step_attributes`.\
Intended for external use when Bathtub instantiates and configures a step definition sequence, not for use inside the step definition.\
"*)
	pure virtual function void set_step_attributes(step_attributes_interface step_attributes);
		// -----------------------------------------------------------------------------------


(* doc$markdown = "\
Gets the static step attributes object.\
\
The `` `Given(string)``, `` `When(string)``, or `` `Then(string)`` macro in the user's step definition class specifies the keyword and matching expression string for that step definition.\
Those are considered the static attributes of the step definition.\
There are three more static attributes: the  matching expression string formulated as a POSIX regular expression, the UVM object wrapper of the step definition class, and the name of the class.\
Every instance of the step definition sequences has different run-time attributes, but they all share the same static attributes.\
The static attributes are stored in a value object that implements interface class `step_static_attributes_interface`.\
`get_step_static_attributes()` allows step definition objects to retrieve the static step attributes object.\
The step definition can use it introspectively to access the expression string, the class name, etc.\
Internally, this is how the step parameter macros know how to extract and interpret in-line arguments from the step text.\
"*)
	pure virtual function step_static_attributes_interface get_step_static_attributes();
		// -----------------------------------------------------------------------------


(* doc$markdown = "\
Gets a reference to the test context sequence.\
\
Returns a reference to the test-level context sequence, whose life spans the duration of the Bathtub test run.\
The test-level context holds a reference to the Bathtub object.\
All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\
The test-level context has the highest scope.\
"*)
	pure virtual function test_sequence_interface get_current_test_sequence();
		// -------------------------------------------------------------------


(* doc$markdown = "\
Gets a reference to the current feature context sequence.\
\
Returns a reference to the feature-level context sequence, whose life spans the duration of the currently running Gherkin feature.\
The feature-level context holds a reference to the `gherkin_pkg::feature` object representing the current feature file.\
All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\
The feature-level context has the second highest scope.\
The test-level sequence is the feature-level sequence's parent sequence.\
"*)
	pure virtual function feature_sequence_interface get_current_feature_sequence();
		// -------------------------------------------------------------------------


(* doc$markdown = "\
Gets a reference to the current rule context sequence.\
\
Returns a reference to the rule-level context sequence, whose life spans the duration of the currently running Gherkin rule.\
If there is no rule, `get_current_rule_sequenc()` returns null.\
The rule-level context holds a reference to the `gherkin_pkg::rule` object representing the current rule.\
All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\
The rule-level context has the third highest scope.\
The feature-level sequence is the rule-level sequence's parent sequence.\
"*)
	pure virtual function rule_sequence_interface get_current_rule_sequence();
		// -------------------------------------------------------------------


(* doc$markdown = "\
Gets a reference to the current scenario context sequence.\
\
Returns a reference to the scenario-level context sequence, whose life spans the duration of the currently running Gherkin scenario.\
The scenario-level context holds a reference to the `gherkin_pkg::scenario` object representing the current scenario.\
All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\
If the scenario is part of a rule, the rule-level sequence is the scenario-level sequence's parent sequence.\
If there is no rule, the feature-level sequence is the scenario-level sequence's parent sequence.\
The scenario-level sequence is the parent of the step definition sequence.\
"*)
	pure virtual function scenario_sequence_interface get_current_scenario_sequence();
		// ---------------------------------------------------------------------------
endclass : step_definition_interface

`include "bathtub_pkg/step_static_attributes_interface.svh"

`ifndef __STEP_ATTRIBUTES_INTERFACE_SVH
`include "bathtub_pkg/step_attributes_interface.svh"
`endif // __STEP_ATTRIBUTES_INTERFACE_SVH

`ifndef __TEST_SEQUENCE_INTERFACE_SVH
`include "bathtub_pkg/test_sequence_interface.svh"
`endif // __TEST_SEQUENCE_INTERFACE_SVH

`include "bathtub_pkg/feature_sequence_interface.svh"

`include "bathtub_pkg/rule_sequence_interface.svh"

`include "bathtub_pkg/scenario_sequence_interface.svh"
`endif // __STEP_DEFINITION_INTERFACE_SVH
