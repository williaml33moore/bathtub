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

`ifndef __BATHTUB_PKG_SVH
`include "bathtub_pkg/bathtub_pkg.svh"
`endif

(* doc$markdown = "\
    \ Interface class for the user's step definition classes.\n\
    \ \n\
    \ In order for Bathtub to run Gherkin feature files, every step in the feature file needs to be implemented by a user-created step definition class.\n\
    \ Every step definition class must satisfy two criteria:\n\
    \ 1. It must extend the `uvm_pkg::uvm_sequence_base` class directly or indirectly.\n\
    \ 2. It must implement the `bathtub_pkg::step_definition_interface` class directly or indirectly.\n\
    \ \n\
    \ When a class is declared as a `step_definition_interface`, it must implement all its interface methods.\n\
    \ This is easily accomplished automatically if the step definition class includes one of the Bathtub step definition macros:\n\
    \ * `Given()\n\
    \ * `When()\n\
    \ * `Then()\n\
    \ * `virtual_step_definition()\n\
    \ \n\
    \ All of these macros expand into implementations of the required `step_definition_interface` methods.\n\
    \ This is an example of a working step definition that satisfies the Bathtub criteria.\n\
    \ It extends `uvm_sequence`, which itself is a child of `uvm_sequence_base`,\n\
    \ it implements `step_definition_interface` in the declaration,\n\
    \ and it contains a `` `When() `` macro which expands into implementations of the required `step_definition_interface` class methods.\n\
    \ Every UVM class must include an object utility macro like `` `uvm_object_utils() `` or equivalent, and a constructor `new()`.\n\
    \ Finally every UVM sequence class will override the `uvm_sequence_base::body()` task in order to provide its unique behavior.\n\
    \ ```sv\n\
    \ class user_step_definition extends uvm_pkg::uvm_sequence implements bathtub_pkg::step_definition_interface;\n\
    \ 	`When(\"the step definition prints 'Hello, World!'\")\n\
    \ \n\
    \ 	`uvm_object_utils(user_step_definition)\n\
    \ \n\
    \ 	function new (string name=\"user_step_definition\");\n\
    \ 		super.new(name);\n\
    \ 	endfunction\n\
    \ \n\
    \ 	virtual task body();\n\
    \ 		`uvm_info(\"WHEN\", \"Hello, World!\", UVM_NONE)\n\
    \ 	endtask\n\
    \ endclass\n\
    \ ```\n\
    \ \n\
    \ The `step_definition_interface` class methods provide a rich API the user-defined step definition class can use for introspection,\n\
    \ and for observation and manipulation of the Bathtub environment.\n\
    \ The class diagram below illustrates the cascading stack of resources and the paths to reach them.\n\
    \ This list summarizes a selection of accessors and utilities available to the class' methods.\n\
    \ They are all detailed in their respective documentation sections.\n\
    \ ```sv\n\
    \ // Run-time step attributes\n\
    \ this.get_step_keyword();\n\
    \ this.get_step_text();\n\
    \ this.get_step_argument_data_table();\n\
    \ this.get_step_argument_doc_string();\n\
    \ \n\
    \ // Static step attributes\n\
    \ this.get_step_definition_keyword();\n\
    \ this.get_step_definition_expression();\n\
    \ this.get_step_definition_regexp();\n\
    \ \n\
    \ // Context sequences\n\
    \ // See the respective sequence Class References.\n\
    \ this.get_current_scenario_sequence();\n\
    \ this.get_current_rule_sequence();\n\
    \ this.get_current_feature_sequence();\n\
    \ this.get_current_test_sequence();\n\
    \ \n\
    \ // Gherkin element objects\n\
    \ // See the respective sequence Class References.\n\
    \ this.get_current_scenario_sequence().get_scenario();\n\
    \ this.get_current_rule_sequence().get_rule();\n\
    \ this.get_current_feature_sequence().get_feature();\n\
    \ this.get_current_test_sequence().get_bathtub_object();\n\
    \ \n\
    \ // Context sequence pools\n\
    \ // The \"*\" stands for \"scenario,\" \"rule,\", \"feature,\", or \"test.\"\n\
    \ // See the `pool_provider_interface` Class Reference.\n\
    \ this.get_current_*_sequence().get_shortint_pool();\n\
    \ this.get_current_*_sequence().get_int_pool();\n\
    \ this.get_current_*_sequence().get_longint_pool();\n\
    \ this.get_current_*_sequence().get_byte_pool();\n\
    \ this.get_current_*_sequence().get_integer_pool();\n\
    \ this.get_current_*_sequence().get_time_pool();\n\
    \ this.get_current_*_sequence().get_real_pool();\n\
    \ this.get_current_*_sequence().get_shortreal_pool();\n\
    \ this.get_current_*_sequence().get_realtime_pool();\n\
    \ this.get_current_*_sequence().get_string_pool();\n\
    \ this.get_current_*_sequence().get_uvm_object_pool();\n\
    \ \n\
    \ // Low-level attributes interfaces\n\
    \ // See the `step attributes_interface` and `step_static_attributes_interface` Class References.\n\
    \ this.get_step_attributes().get_step();\n\
    \ this.get_step_static_attributes().get_step();\n\
    \ ```\n\
    \ \n\
    \ ```mermaid\n\
    \ ---\n\
    \ title: Class Diagram\n\
    \ ---\n\
    \ classDiagram\n\
    \     namespace bathtub_pkg{\n\
    \         class user_step_definition{\n\
    \             %% +__step_static_attributes : step_static_attributes_interface$\n\
    \             %% +__step_attributes : step_attributes_interface\n\
    \         }\n\
    \         class step_definition_interface{\n\
    \             <<interface>>\n\
    \             +get_step_keyword() : string\n\
    \             +get_step_text() : string\n\
    \             +get_step_argument_data_table() : gherkin_pkg::data_table\n\
    \             +get_step_argument_doc_string() : gherkin_pkg::doc_string\n\
    \             +get_step_definition_keyword() : step_keyword_t\n\
    \             +get_step_definition_expression() : string\n\
    \             +get_step_definition_regexp() : string\n\
    \             +get_current_scenario_sequence() : scenario_sequence_interface\n\
    \             +get_current_rule_sequence() : rule_sequence_interface\n\
    \             +get_current_feature_sequence() : feature_sequence_interface\n\
    \             +get_current_test_sequence() : test_sequence_interface\n\
    \             +get_step_attributes() : step_attributes_interface\n\
    \             +get_step_static_attributes() : step_static_attributes_interface\n\
    \         }\n\
    \         class step_nature{\n\
    \             #step_keyword_t : keyword\n\
    \             #expression : string\n\
    \             #regexp : string\n\
    \             #step_obj :  uvm_object_wrapper\n\
    \             #step_obj_name :  string\n\
    \         }\n\
    \         class step_nurture{\n\
    \             #step : gherkin_pkg::step\n\
    \             #current_test_seq : test_sequence_interface\n\
    \             #current_feature_seq : feature_sequence_interface\n\
    \             #current_rule_seq : rule_sequence_interface\n\
    \             #current_scenario_seq : scenario_sequence_interface\n\
    \         }\n\
    \         class step_static_attributes_interface{\n\
    \             <<interface>>\n\
    \             +get_keyword() : step_keyword_t\n\
    \             +get_regexp() : string\n\
    \             +get_expression() : string\n\
    \             +get_step_obj() : uvm_object_wrapper\n\
    \             +get_step_obj_name() : string\n\
    \             +print_attributes(uvm_verbosity verbosity) : void\n\
    \         }\n\
    \         class step_attributes_interface{\n\
    \             <<interface>>\n\
    \             +get_step() : gherkin_pkg::step\n\
    \             +get_current_test_sequence() : test_sequence_interface\n\
    \             +get_current_feature_sequence() : feature_sequence_interface\n\
    \             +get_current_rule_sequence() : rule_sequence_interface\n\
    \             +get_current_scenario_sequence() : scenario_sequence_interface\n\
    \             +print_attributes(uvm_verbosity verbosity) : void\n\
    \         }\n\
    \         class pool_provider_interface{\n\
    \             <<interface>>\n\
    \             +get_shortint_pool() : uvm_pool#(string, shortint)\n\
    \             +get_int_pool() : uvm_pool#(string, int)\n\
    \             +get_longint_pool() : uvm_pool#(string, longint)\n\
    \             +get_byte_pool() : uvm_pool#(string, byte)\n\
    \             +get_integer_pool() : uvm_pool#(string, integer)\n\
    \             +get_time_pool() : uvm_pool#(string, time) \n\
    \             +get_real_pool() : uvm_pool#(string, real)\n\
    \             +get_shortreal_pool() : uvm_pool#(string, shortreal) \n\
    \             +get_realtime_pool() : uvm_pool#(string, realtime)\n\
    \             +get_string_pool() : uvm_pool#(string, string)\n\
    \             +get_uvm_object_pool() : uvm_pool#(string, uvm_object)\n\
    \         }\n\
    \         class pool_provider{\n\
    \             +shortint_pool : uvm_pool#(string, shortint)\n\
    \             +int_pool : uvm_pool#(string, int)\n\
    \             +longint_pool : uvm_pool#(string, longint)\n\
    \             +byte_pool : uvm_pool#(string, byte)\n\
    \             +integer_pool : uvm_pool#(string, integer)\n\
    \             +time_pool : uvm_pool#(string, time) \n\
    \             +real_pool : uvm_pool#(string, real)\n\
    \             +shortreal_pool : uvm_pool#(string, shortreal) \n\
    \             +realtime_pool : uvm_pool#(string, realtime)\n\
    \             +string_pool : uvm_pool#(string, string)\n\
    \             +uvm_object_pool : uvm_pool#(string, uvm_object)\n\
    \         }\n\
    \         class test_sequence{\n\
    \             #bt : bathtub\n\
    \         }\n\
    \         class feature_sequence{\n\
    \             #feature : gherkin_pkg::feature\n\
    \         }\n\
    \         class rule_sequence{\n\
    \ 		    #rule : gherkin_pkg::rule\n\
    \ 		}\n\
    \         class scenario_sequence{\n\
    \ 		    #scenario : gherkin_pkg::scenario\n\
    \ 		}\n\
    \         class test_sequence_interface{\n\
    \             <<interface>>\n\
    \             +get_bathtub_object() : bathtub\n\
    \         }\n\
    \         class feature_sequence_interface{\n\
    \             <<interface>>\n\
    \             +get_feature() : gherkin_pkg::feature\n\
    \         }\n\
    \         class rule_sequence_interface{\n\
    \             <<interface>>\n\
    \ 	        +get_rule() : gherkin_pkg::rule\n\
    \         }\n\
    \         class scenario_sequence_interface{\n\
    \             <<interface>>\n\
    \ 			+get_scenario() : gherkin_pkg::scenario\n\
    \         }\n\
    \         class context_sequence\n\
    \     }\n\
    \     namespace uvm_pkg{\n\
    \         class uvm_pool\n\
    \         class uvm_sequence\n\
    \         %% class uvm_object\n\
    \     }\n\
    \     user_step_definition ..|> step_definition_interface\n\
    \     user_step_definition *-- step_nature\n\
    \     user_step_definition --> step_nurture\n\
    \     user_step_definition --|> uvm_sequence\n\
    \ \n\
    \     %% step_nature --|> uvm_object\n\
    \     step_nature ..|> step_static_attributes_interface\n\
    \ \n\
    \     %% step_nurture --|> uvm_object\n\
    \     step_nurture ..|> step_attributes_interface\n\
    \     step_nurture --> test_sequence\n\
    \     step_nurture --> feature_sequence\n\
    \     step_nurture --> rule_sequence\n\
    \     step_nurture --> scenario_sequence\n\
    \ \n\
    \     test_sequence --|> context_sequence\n\
    \     test_sequence ..|> test_sequence_interface\n\
    \ \n\
    \     feature_sequence --|> context_sequence\n\
    \     feature_sequence ..|> feature_sequence_interface\n\
    \ \n\
    \     rule_sequence --|> context_sequence\n\
    \     rule_sequence ..|> rule_sequence_interface\n\
    \ \n\
    \     scenario_sequence --|> context_sequence\n\
    \     scenario_sequence ..|> scenario_sequence_interface\n\
    \ \n\
    \     test_sequence_interface --|> pool_provider_interface\n\
    \     feature_sequence_interface --|> pool_provider_interface\n\
    \     rule_sequence_interface --|> pool_provider_interface\n\
    \     scenario_sequence_interface --|> pool_provider_interface\n\
    \ \n\
    \     context_sequence --> pool_provider\n\
    \     context_sequence ..|> pool_provider_interface\n\
    \ \n\
    \     pool_provider ..|> pool_provider_interface\n\
    \     pool_provider \"1\" *-- \"11\" uvm_pool\n\
    \ \n\
    \     uvm_sequence --|> uvm_sequence_base\n\
    \ \n\
    \     note for user_step_definition \"Contains a `Given(), `When(), or `Then() macro\"\n\
    \     style user_step_definition fill:#0ff\n\
    \ ```\n\
    \ \n\
    \ ### Context Sequences and Pools\n\
    \ \n\
    \ Gherkin feature files have a hierarchical structure of nested elements.\n\
    \ For example, here are two feature files, each with one feature.\n\
    \ The features have multiple scenarios and rules, the rules have multiple scenarios, and the scenarios have multiple _When_ and _Then_ steps.\n\
    \ \n\
    \ ```gherkin\n\
    \ # file_1.feature\n\
    \ Feature: This is the first feature\n\
    \     Scenario: This is the first scenario\n\
    \         When the host transmits 0x00112233 # step 1\n\
    \         Then the received data should be 0x00112233 # step 2\n\
    \     Rule: This is the first rule\n\
    \         Scenario: This is the second scenario\n\
    \             When the host transmits 0x44556677 # step 3\n\
    \             Then the received data should be 0x44556677 # step 4\n\
    \         Scenario: This is the third scenario\n\
    \             When the host transmits 0x8899aabb # step 5\n\
    \             Then the received data should be 0x8899aabb # step 6\n\
    \     Rule: This is the second rule\n\
    \         Scenario: This is the fourth scenario\n\
    \             When the host transmits 0xccddeeff # step 7\n\
    \             Then the received data should be 0xccddeeff # step 8\n\
    \ ```\n\
    \ ```gherkin\n\
    \ # file_2.feature\n\
    \ Feature: This is the second feature\n\
    \     Scenario: This is the first scenario\n\
    \         When the host transmits 0xffeeddcc # step 9\n\
    \         Then the received data should be 0xffeeddcc # step 10\n\
    \     Rule: This is the first rule\n\
    \         Scenario: This is the second scenario\n\
    \             When the host transmits 0xbbaa9988 # step 11\n\
    \             Then the received data should be 0xbbaa9988 # step 12\n\
    \         Scenario: This is the third scenario\n\
    \             When the host transmits 0x77665544 # step 13\n\
    \             Then the received data should be 0x77665544 # step 14\n\
    \     Rule: This is the second rule\n\
    \         Scenario: This is the fourth scenario\n\
    \             When the host transmits 0x33221100 # step 15\n\
    \             Then the received data should be 0x33221100 # step 16\n\
    \ ```\n\
    \ \n\
    \ We can visualize the feature files as a tree.\n\
    \ The \"Test\" at the root of the tree represents the Bathtub object in the user's UVM test.\n\
    \ The feature files are its children.\n\
    \ The details of the second feature file are omitted for clarity.\n\
    \ \n\
    \ ```mermaid\n\
    \ ---\n\
    \ title: Context Sequences\n\
    \ ---\n\
    \ classDiagram\n\
    \     class Test\n\
    \     class feature_1[\"Feature\"]{\n\
    \         \"This is the first feature\"\n\
    \     }\n\
    \     class feature_2[\"Feature\"]{\n\
    \         \"This is the second feature\"\n\
    \     }\n\
    \     class rule_1[\"Rule\"]{\n\
    \         \"This is the first rule\"\n\
    \     }\n\
    \     class rule_2[\"Rule\"]{\n\
    \         \"This is the second rule\"\n\
    \     }\n\
    \     class scenario_1[\"Scenario\"]{\n\
    \         \"This is the first scenario\"\n\
    \     }\n\
    \     class scenario_2[\"Scenario\"]{\n\
    \         \"This is the second scenario\"\n\
    \     }\n\
    \     class scenario_3[\"Scenario\"]{\n\
    \         \"This is the third scenario\"\n\
    \     }\n\
    \     class scenario_4[\"Scenario\"]{\n\
    \         \"This is the fourth scenario\"\n\
    \     }\n\
    \     class step_1[\"Step\"]{\n\
    \         step 1\n\
    \     }\n\
    \     class step_2[\"Step\"]{\n\
    \         step 2\n\
    \     }\n\
    \     class step_3[\"Step\"]{\n\
    \         step 3\n\
    \     }\n\
    \     class step_4[\"Step\"]{\n\
    \         step 4\n\
    \     }\n\
    \     class step_5[\"Step\"]{\n\
    \         step 5\n\
    \     }\n\
    \     class step_6[\"Step\"]{\n\
    \         step 6\n\
    \     }\n\
    \     class step_7[\"Step\"]{\n\
    \         step 7\n\
    \     }\n\
    \     class step_8[\"Step\"]{\n\
    \         step 8\n\
    \     }\n\
    \     Test --> feature_1\n\
    \     feature_1 --> scenario_1\n\
    \     feature_1 --> rule_1\n\
    \     rule_1 --> scenario_2\n\
    \     rule_1 --> scenario_3\n\
    \     feature_1 --> rule_2\n\
    \     rule_2 --> scenario_4\n\
    \     scenario_1 --> step_1\n\
    \     scenario_1 --> step_2\n\
    \     scenario_2 --> step_3\n\
    \     scenario_2 --> step_4\n\
    \     scenario_3 --> step_5\n\
    \     scenario_3 --> step_6\n\
    \     scenario_4 --> step_7\n\
    \     scenario_4 --> step_8\n\
    \     Test --> feature_2\n\
    \ ```\n\
    \ \n\
    \ Bathtub traverses the tree and when it reaches a step, it matches the step text to the user's step definition sequence class,\n\
    \ instantiates the step sequence, and runs it on a sequencer.\n\
    \ This object diagram depicts a snapshot of the moment Bathtub runs step 8, \"Then the received data should be 0xccddeeff.\"\n\
    \ \n\
    \ ```mermaid\n\
    \ ---\n\
    \ title: Run-time Context Sequences\n\
    \ ---\n\
    \ classDiagram\n\
    \     class Test{\n\
    \         bathtub\n\
    \     }\n\
    \     class feature_1[\"Feature\"]{\n\
    \         \"This is the first feature\"\n\
    \     }\n\
    \     class rule_2[\"Rule\"]{\n\
    \         \"This is the second rule\"\n\
    \     }\n\
    \     class scenario_4[\"Scenario\"]{\n\
    \         \"This is the fourth scenario\"\n\
    \     }\n\
    \     class step_8[\"Step\"]{\n\
    \         \"Then the received data should be 0xccddeeff\"\n\
    \     }\n\
    \     class step_nurture[\"step_attributes : bathtub_pkg::step_attributes_interface\"]\n\
    \     class test_seq[\"current_test_seq : bathtub_pkg::test_sequence\"] {\n\
    \         #bt : bathtub_pkg::bathtub\n\
    \         +*_pool : uvm_pool[0..11]\n\
    \     }\n\
    \     class feature_seq[\"current_feature_seq : bathtub_pkg::feature_sequence\"] {\n\
    \         #feature : gherkin_pkg::feature\n\
    \         +*_pool : uvm_pool[0..11]\n\
    \     }\n\
    \     class rule_seq[\"current_rule_seq : bathtub_pkg::rule_sequence\"]{\n\
    \         #rule : gherkin_pkg::rule\n\
    \         +*_pool : uvm_pool[0..11]\n\
    \     }\n\
    \     class scenario_seq[\"current_scenario_seq : bathtub_pkg::scenario_sequence\"]{\n\
    \         #scenario : gherkin_pkg::scenario\n\
    \         +*_pool : uvm_pool[0..11]\n\
    \     }\n\
    \     class step_seq[\"step_seq : user_step_definition\"]{\n\
    \         keyword: Then\n\
    \         expression: \"the received data should be 0x%x\"\n\
    \     }\n\
    \     %%class gherkin_step[\"gherkin_pkg::step\"]{\n\
    \     %%    #keyword : string\n\
    \     %%    #text : string\n\
    \     %%}\n\
    \     %%class gherkin_scenario[\"gherkin_pkg::scenario\"]{\n\
    \     %%    #name : string\n\
    \     %%    #steps : gherkin_pkg::step[*]\n\
    \     %%}\n\
    \     %%class gherkin_rule[\"gherkin_pkg::rule\"]{\n\
    \     %%    #name : string\n\
    \     %%    #scenarios : gherkgin_pkg::scenario[*]\n\
    \     %%}\n\
    \     %%class gherkin_feature[\"gherkin_pkg::feature\"]{\n\
    \     %%    #name : string\n\
    \     %%    #rules : gherkin_pkg::rule[*]\n\
    \     %%}\n\
    \     Test --> feature_1:child\n\
    \     test_seq --> Test:get_bathtub_object()\n\
    \     feature_1 --> rule_2:child\n\
    \     feature_seq --> feature_1:get_feature()\n\
    \     rule_2 --> scenario_4:child\n\
    \     rule_seq --> rule_2:get_rule()\n\
    \     scenario_4 --> step_8:child\n\
    \     scenario_seq --> scenario_4:get_scenario()\n\
    \     step_nurture --> test_seq:get_current_test_seq()\n\
    \     step_nurture --> feature_seq:get_current_feature_seq()\n\
    \     step_nurture --> rule_seq:get_current_rule_seq()\n\
    \     step_nurture --> scenario_seq:get_current_scenario_seq()\n\
    \     step_nurture --> step_8:get_step()\n\
    \     step_seq --> scenario_seq:parent\n\
    \     step_seq --> step_nurture:get_step_attributes()\n\
    \     scenario_seq --> rule_seq:parent\n\
    \     rule_seq --> feature_seq:parent\n\
    \     feature_seq --> test_seq:parent\n\
    \     style step_seq fill:#0ff\n\
    \     style Test fill:#8f0\n\
    \     style feature_1 fill:#8f0\n\
    \     style rule_2 fill:#8f0\n\
    \     style scenario_4 fill:#8f0\n\
    \     style step_8 fill:#8f0\n\
    \     %%step_8 --|> gherkin_step\n\
    \     %%scenario_4 --|> gherkin_scenario\n\
    \     %%rule_2 --|> gherkin_rule\n\
    \     %%feature_1 --|> gherkin_feature\n\
    \ ```\n\
    \ \n\
    \ The complete Gherkin tree path of Test --> Feature --> Rule --> Scenario --> Step is shown at the bottom.\n\
    \ The matching `user_step_definition` instance is shown at the top.\n\
    \ Every test/feature/rule/scenario element in the Gherkin tree path has an associated context sequence, shown in the middle of the diagram.\n\
    \ The context sequences are themselves linked together in their own chain of parentage.\n\
    \ \n\
    \ The context sequences have three purposes.\n\
    \ \n\
    \ First, they run their associated Gherkin elements.\n\
    \ The Gherkin elements are inert value objects comprised of strings parsed from the feature files.\n\
    \ The context sequences are UVM sequences with active `body()` tasks that execute the Gherkin value objects.\n\
    \ For example, the `feature_sequence` contains the code that iterates over the Gherkin feature object's child scenarios and rules, running each.\n\
    \ \n\
    \ Second, the context sequences hold references to their associated Gherkin objects.\n\
    \ The user's step definition sequences can access the strings in the Gherkin objects through the context sequences.\n\
    \ With this powerful capability, the step definitions can read the complete Gherkin code and act on it.\n\
    \ Note that the Gherkin objects are immutable, so the step definitions can't alter or break the Gherkin tree.\n\
    \ \n\
    \ Third, the context sequences contain a set of UVM pools specialized for eleven different SystemVerilog data types:\n\
    \ `shortint`, `int`, `longint`, `byte`, `integer`, `time`, `real`, `shortreal`, `realtime`, `string`, and `uvm_object`.\n\
    \ Note the variety of two-state, four-state, integer, and real scalar types, plus one object type.\n\
    \ The user step sequences can use these pools, at any level, to share data among themselves.\n\
    \ Step sequences are run sequentially.\n\
    \ Each one must finish before the next can start.\n\
    \ When each finishes, it is destroyed in the sense that all of its local variables go out of scope.\n\
    \ In order to pass data to future sequences, a step sequence can store it in an appropriate pool with a name and a value.\n\
    \ Subsequent sequences that know the pool and name can retrieve the data.\n\
    \ Consider our sample steps 7 and 8:\n\
    \ ```gherkin\n\
    \ When the host transmits 0xccddeeff # step 7\n\
    \ Then the received data should be 0xccddeeff # step 8\n\
    \ ```\n\
    \ The _When_ step can store its data word in the scenario's `int` pool, and the _Then_ step can retrieve it.\n\
    \ Recall that the pools are `uvm_pkg::uvm_pool()` objects that provide `add()` and `get()` methods, among others.\n\
    \ ```sv\n\
    \ // When step\n\
    \ //   Store 0xccddeeff in the scenario pool:\n\
    \ get_current_scenario_sequence().get_int_pool().add(\"data_word\", transmit_data_word);\n\
    \ ---\n\
    \ // Then step\n\
    \ //   Retrieve 0xccddeeff from the scenario pool:\n\
    \ int expected_data_word = get_current_scenario_sequence().get_int_pool().get(\"data_word\");\n\
    \ ```\n\
    \ The pools give the step definitions a great deal of freedom to store, retrieve, and even delete data across all the different contexts.\n\
    \ Use this power mindfully and sparingly.\n\
    \ It has the potential to introduce fragility, coupling, and order sensitivity to your Bathtub runs.\n\
    \ For example, you have to be careful that one step doesn't try to read a value from a pool before another step has written it.\n\
    \ Or, a step could accidentally overwrite a value written by an earlier step.\n\
    \ That being said, this sharing of state is a necessary evil common in BDD tools.\n\
    \ The best practice is to use only the lowest level scenario pools to share state among steps.\n\
    \ \n\
    \ Like the step definitions, each context sequence has a limited lifespan.\n\
    \ It is created when the test/feature/rule/scenario starts, and is destroyed when the test/feature/rule/scenario ends.\n\
    \ Its data pools are destroyed when the context sequence ends.\n\
    \ This actually helps guard against data leakage across Gherkin elements;\n\
    \ one scenario can't be contaminated by a previous scenario's pools because they have been destroyed.\n\
    \ The contexts represent different scopes.\n\
    \ The test sequence spans the lifetimes of all its child features.\n\
    \ Each feature sequence spans the lifetimes of all its child rules and scenarios.\n\
    \ Each rule sequence spans the lifetimes of all its scenarios.\n\
    \ Each scenario sequence spans the lifetimes of all its steps.\n\
    \ When all of a parent sequence's children complete, then the sequence completes.\n\
    \ "
*)
interface class step_definition_interface;
	// ===================================

    (* doc$markdown = "\
        \ Gets the run-time step keyword.\n\
        \ \n\
        \ Retrieves the actual step keyword from the Gherkin feature file.\n\
        \ Could be \"Given,\" \"When,\" \"Then,\" \"And,\" \"But,\" or \"*\".\n\
        \ Note that the actual keyword may or may not match the static keyword returned by `get_step_definition_keyword()`.\n\
        \ "
    *)
    pure virtual function string get_step_keyword();
        // -----------------------------------------


    (* doc$markdown = "\
        \ Gets the run-time step text.\n\
        \ \n\
        \ Retrieves the actual step text from the Gherkin feature file, i.e., the text following the step keyword.\n\
        \ The keyword is not part of the text.\n\
        \ The step text should match the static expressions returned by `get_step_definition_expression()` and `get_step_definition_regexp()`.\n\
        \ "
    *)
    pure virtual function string get_step_text();
        // --------------------------------------


    (* doc$markdown = "\
        \ Gets the run-time step data table argument.\n\
        \ \n\
        \ Retrieves the step data table argument from the Gherkin feature file.\n\
        \ Returns null if the step has no data table argument.\n\
        \ A Gherkin data table immediately follows the step, and is indicated by \"|\" characters, e.g.:\n\
        \ ```gherkin\n\
        \ When a step like this has a data table like this\n\
        \ | Example | of    | a |\n\
        \ | data    | table |\n\
        \ ```\n\
        \ See the `gherkin_pkg` Package Reference for `data_table` class details.\n\
        \ "
    *)
    pure virtual function gherkin_pkg::data_table get_step_argument_data_table();
        // ----------------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets the run-time step doc string argument.\n\
        \ \n\
        \ Retrieves the step doc string argument from the Gherkin feature file.\n\
        \ Returns null if the step has no doc string argument.\n\
        \ A Gherkin doc string immediately follows the step, and is indicated by triple quotes (\"\"\") or triple backticks (```), e.g.:\n\
        \ ```gherkin\n\
        \ When a step like this has a doc string like this\n\
        \ \"\"\"\n\
        \ Example of a\n\
        \ multi-line doc string\n\
        \ \"\"\"\n\
        \ ```\n\
        \ See the `gherkin_pkg` Package Reference for `doc_string` class details.\n\
        \ "
    *)
    pure virtual function gherkin_pkg::doc_string get_step_argument_doc_string();
        // ----------------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets the static step keyword.\n\
        \ \n\
        \ Retrieves the Gherkin keyword from the user's step definition class.\n\
        \ It is a static property of the class, and is determined by the user's choice of macro: `` `Given() ``, `` `When() ``, or `` `Then() ``.\n\
        \ This keyword is an enum of type `bathtub_pkg::step_keyword_t`, not a string.\n\
        \ Possible values are `Given`, `When`, or `Then`.\n\
        \ "
    *)
	pure virtual function step_keyword_t get_step_definition_keyword();
        // ------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets the static step definition expression.\n\
        \ \n\
        \ Retrieves the step definition expression from the user's step definition class.\n\
        \ It is a static property of the class, and is the argument to the `` `Given() ``, `` `When() ``, and `` `Then() `` macros.\n\
        \ The expression could be a POSIX regular expression surrounded by slashes (\"/\"),\n\
        \ or a SystemVerilog format specification with escape sequences like `%d` and `%s`.\n\
        \ Taking the regular expression or format specification into account, the expression matches the run-time step text as returned by `get_step_text()`.\n\
        \ \n\
        \ In this example, the expression is \"this expression matches %s\" and it is a SystemVerilog format specification.\n\
        \ ```sv\n\
        \ class user_step_definition extends uvm_pkg::uvm_sequence implements bathtub_pkg::step_definition_interface;\n\
        \ 	`When(\"this expression matches %s\")\n\
        \ ```\n\
        \ In this example, the expression is \"/^this expression matches .*$/\" and it is a POSIX regular expression.\n\
        \ ```sv\n\
        \ class user_step_definition extends uvm_pkg::uvm_sequence implements bathtub_pkg::step_definition_interface;\n\
        \ 	`When(\"/^this expression matches .*$/\")\n\
        \ ```\n\
        \ "
    *)
	pure virtual function string get_step_definition_expression();
        // -------------------------------------------------------


    (* doc$markdown = "\
        \ Gets the static step definition regular expression.\n\
        \ \n\
        \ Retrieves the step definition regular expression from the user's step definition class.\n\
        \ It is a static property of the class, and is derived from the step definition expression argument to the `` `Given() ``, `` `When() ``, and `` `Then() `` macros.\n\
        \ If the expression is a POSIX regular expression surrounded by slashes (\"/\"),\n\
        \ then the regular expression from `get_step_definition_regexp()` is identical to the expression from `get_step_definition_expression()`.\n\
        \ If the expression is a SystemVerilog format specification with escape sequences like `%d` and `%s`,\n\
        \ then the regular expression is the expression translated into a POSIX regular expression pattern.\n\
        \ The regular expression matches the run-time step text as returned by `get_step_text()`.\n\
        \ Note that the regular expression is stored in the UVM resource database as the \"scope\" lookup string for the step definition class.\n\
        \ \n\
        \ In this example, the expression is, \"the user types the single character %c\",\n\
        \ and `get_step_definition_regexp()` returns the translated POSIX regular expression, \"/^the user types the single character (.)$/\".\n\
        \ Note that the SystemVerilog escape sequence `%c` has been translated into a grouped regular expression `(.)`.\n\
        \ ```sv\n\
        \ class user_step_definition extends uvm_pkg::uvm_sequence implements bathtub_pkg::step_definition_interface;\n\
        \ 	`When(\"the user types the single character %c\")\n\
        \ ```\n\
        \ "
    *)
	pure virtual function string get_step_definition_regexp();
        // ---------------------------------------------------


    (* doc$markdown = "\
        \ Gets a reference to the current scenario context sequence.\n\
        \ \n\
        \ Returns a reference to the scenario-level context sequence, whose life spans the duration of the currently running Gherkin scenario.\n\
        \ The scenario-level context holds a reference to the `gherkin_pkg::scenario` object representing the current scenario.\n\
        \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
        \ If the scenario is part of a rule, the rule-level sequence is the scenario-level sequence's parent sequence.\n\
        \ If there is no rule, the feature-level sequence is the scenario-level sequence's parent sequence.\n\
        \ The scenario-level sequence is the parent of the step definition sequence.\n\
        \ "
    *)
	pure virtual function scenario_sequence_interface get_current_scenario_sequence();
		// ---------------------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets a reference to the current rule context sequence.\n\
        \ \n\
        \ Returns a reference to the rule-level context sequence, whose life spans the duration of the currently running Gherkin rule.\n\
        \ If there is no rule, `get_current_rule_sequence()` returns null.\n\
        \ The rule-level context holds a reference to the `gherkin_pkg::rule` object representing the current rule.\n\
        \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
        \ The rule-level context has the third highest scope.\n\
        \ The feature-level sequence is the rule-level sequence's parent sequence.\n\
        \ "
    *)
	pure virtual function rule_sequence_interface get_current_rule_sequence();
		// -------------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets a reference to the current feature context sequence.\n\
        \ \n\
        \ Returns a reference to the feature-level context sequence, whose life spans the duration of the currently running Gherkin feature.\n\
        \ The feature-level context holds a reference to the `gherkin_pkg::feature` object representing the current feature file.\n\
        \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
        \ The feature-level context has the second highest scope.\n\
        \ The test-level sequence is the feature-level sequence's parent sequence.\n\
        \ "
    *)
	pure virtual function feature_sequence_interface get_current_feature_sequence();
		// -------------------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets a reference to the test context sequence.\n\
        \ \n\
        \ Returns a reference to the test-level context sequence, whose life spans the duration of the Bathtub test run.\n\
        \ The test-level context holds a reference to the Bathtub object.\n\
        \ All the context sequences have a set of UVM pools the step definitions can use to store, retrieve, and share data among themselves.\n\
        \ The test-level context has the highest scope.\n\
        \ "
    *)
	pure virtual function test_sequence_interface get_current_test_sequence();
		// -------------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets the run-time step attributes object.\n\
        \ \n\
        \ While Bathtub is running a Gherkin feature file, when it encounters a step,\n\
        \ it packages the attributes of that step into a value object and provides it to the step definition sequence.\n\
        \ `get_step_attributes()` retrieves that step attributes object.\n\
        \ The step definition can use it to access the step text from the feature file and any Gherkin step arguments, i.e., doc strings or data tables.\n\
        \ Internally, this is how the step parameter macros extract in-line arguments from the step text.\n\
        \ The facade methods `get_step_keyword()`, `get_step_text()`, `get_step_argument_data_table()`, `get_step_argument_doc_string()`, and the context sequence accessors all delegate to the attributes object.\n\
        \ "
    *)
	pure virtual function step_attributes_interface get_step_attributes();
		// ---------------------------------------------------------------


    (* doc$markdown = "\
        \ Gets the static step attributes object.\n\
        \ \n\
        \ The `` `Given(string) ``, `` `When(string) ``, or `` `Then(string) `` macro in the user's step definition class specifies the keyword and matching expression string for that step definition.\n\
        \ Those are considered the static attributes of the step definition.\n\
        \ There are three more static attributes: the  matching expression string translated into a POSIX regular expression, the UVM object wrapper of the step definition class, and the name of the class.\n\
        \ Every instance of a step definition sequence class has different run-time attributes, but they all share the same static class attributes.\n\
        \ The static attributes are stored in a value object that implements interface class `step_static_attributes_interface`.\n\
        \ `get_step_static_attributes()` allows step definition objects to retrieve the static step attributes object.\n\
        \ The step definition can use it introspectively to access the expression string, the class name, etc.\n\
        \ Internally, this is how the step parameter macros know how to extract and interpret in-line arguments from the step text.\n\
        \ The facade methods `get_step_definition_keyword()`, `get_step_definition_expression()`, and `get_step_definition_regexp()` all delegate to the static attributes object.\n\
        \ "
    *)
	pure virtual function step_static_attributes_interface get_step_static_attributes();
		// -----------------------------------------------------------------------------
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
