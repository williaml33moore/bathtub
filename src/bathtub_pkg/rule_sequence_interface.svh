/*
MIT License

Copyright (c) 2024 William L. Moore

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

`ifndef __RULE_SEQUENCE_INTERFACE_SVH
`define __RULE_SEQUENCE_INTERFACE_SVH

`include "bathtub_pkg/pool_provider_interface.svh"

(* doc$markdown = "\
    \ Interface for rule-level context sequences.\n\
    \ \n\
    \ The rule-level context sequences implement this interface.\n\
    \ A user step definition sequence can access the current rule-level context sequence through its `get_current_rule_sequence()` function.\n\
    \ "
*)
interface class rule_sequence_interface extends pool_provider_interface;
	// =================================================================

	(* doc$markdown = "\
        \ Gets a reference to the rule object.\n\
        \ \n\
        \ When Bathtub parses a rule in a Gherkin feature file, Bathtub creates a `gherkin_pkg::rule` object for it.\n\
        \ The rule-level context sequence contains a reference to the rule object.\n\
        \ A user step definition sequence can retrieve a reference to the rule object with the context sequence's implementation of this function, e.g.:\n\
        \ ```sv\n\
        \ gherkin_pkg::rule my_rule = (get_current_rule_sequence() == null) ? null : get_current_rule_sequence().get_rule();\n\
        \ ```\n\
        \ Rules are optional in Gherkin feature files, so it's a good practice to check if the rule is present by testing if the rule sequence reference is null.\n\
        \ "
    *)
    pure virtual function gherkin_pkg::rule get_rule();
		// --------------------------------------------
endclass : rule_sequence_interface

`endif // __RULE_SEQUENCE_INTERFACE_SVH
