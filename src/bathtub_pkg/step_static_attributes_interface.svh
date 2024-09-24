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

`ifndef __STEP_STATIC_ATTRIBUTES_INTERFACE_SVH
`define __STEP_STATIC_ATTRIBUTES_INTERFACE_SVH

`ifndef __BATHTUB_PKG_SVH
`include "bathtub_pkg/bathtub_pkg.svh"
`endif

import uvm_pkg::*;

(* doc$markdown = "\
    \ Interface for the step's static attributes object.\n\
    \ \n\
    \ At time 0, the simulator collects static attributes from the user's step definition class into an attributes object.\n\
    \ The attributes object implements the methods in this `step_static_attributes_interface` interface class.\n\
    \ The step definition can use its `get_step_static_attributes()` function to retrieve its attributes object and call these methods.\n\
    \ However, several of these methods are more conveniently accessed through the step definition's own `step_definition_interface` methods.\n\
    \ The default `step_definition_interface` implementation delegates to the respective methods here in the static step attributes object.\n\
    \ \n\
    \ The static attributes are in contrast to the run-time step attributes, which are accessed through a different interface.\n\
    \ "
*)
interface class step_static_attributes_interface;
	// ==========================================
	
	(* doc$markdown = "\
        \ Gets the static step keyword.\n\
        \ \n\
        \ Retrieves the Gherkin keyword from the user's step definition class.\n\
        \ It is a static property of the class, and is determined by the user's choice of macro: `` `Given``, `` `When()``, or `` `Then()``.\n\
        \ This keyword is an enum of type `bathtub_pkg::step_keyword_t`, not a string.\n\
        \ Possible values are `Given`, `When`, or `Then`.\n\
        \ "
    *)
	pure virtual function step_keyword_t get_keyword();
		// --------------------------------------------

	(* doc$markdown = "\
        \ Gets the static step definition expression.\n\
        \ \n\
        \ Retrieves the step definition expression from the user's step definition class.\n\
        \ It is a static property of the class, and is the argument to the `` `Given``, `` `When()``, and `` `Then()`` macros.\n\
        \ The expression could be a POSIX regular expression surrounded by slashes (\"/\"),\n\
        \ or a SystemVerilog format specification with escape sequences like `%d` and `%s`.\n\
        \ Taking the regular expression or format specification into account, the expression matches the run-time step text.\n\
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
	pure virtual function string get_expression();
		// ---------------------------------------

	(* doc$markdown = "\
        \ Gets the static step definition regular expression.\n\
        \ \n\
        \ Retrieves the step definition regular expression from the user's step definition class.\n\
        \ It is a static property of the class, and is derived from the step definition expression argument to the `` `Given``, `` `When()``, and `` `Then()`` macros.\n\
        \ If the expression is a POSIX regular expression surrounded by slashes (\"/\"),\n\
        \ then the regular expression from `get_regexp()` is identical to the expression from `get_expression()`.\n\
        \ If the expression is a SystemVerilog format specification with escape sequences like `%d` and `%s`,\n\
        \ then the regular expression is the expression translated into a POSIX regular expression pattern.\n\
        \ The regular expression matches the run-time step text.\n\
        \ Note that the regular expression is stored in the UVM resource database as the \"scope\" lookup string for the step definition class.\n\
        \ \n\
        \ In this example, the expression is, \"the user types the single character %c\",\n\
        \ and `get_regexp()` returns the translated POSIX regular expression, \"/^the user types the single character (.)$/\".\n\
        \ Note that the SystemVerilog escape sequence `%c` has been translated into a grouped regular expression `(.)`.\n\
        \ ```sv\n\
        \ class user_step_definition extends uvm_pkg::uvm_sequence implements bathtub_pkg::step_definition_interface;\n\
        \ 	`When(\"the user types the single character %c\")\n\
        \ ```\n\
        \ "
    *)
	pure virtual function string get_regexp();
		// -----------------------------------

	(* doc$markdown = "\
		\ Gets the UVM object wrapper for the step definition class.\n\
		\ \n\
		\ As typical UVM objects, by default user step definition classes have UVM object wrappers which are registered with the UVM factory.\n\
		\ This function returns a reference to that object wrapper.\n\
		\ A user step definition would not typically need to retrieve its own object wrapper this way.\n\
		\ This function is primarily for completeness and debug.\n\
		\ "
	*)
	pure virtual function uvm_object_wrapper get_step_obj();
		// -------------------------------------------------

	(* doc$markdown = "\
		\ Gets the object type name for the step definition class.\n\
		\ \n\
		\ This function returns the type name of the user's step definition class, as returned by the class' UVM object wrapper.\n\
		\ A user step definition would not typically need to retrieve its own class name this way.\n\
		\ This function is primarily for completeness and debug.\n\
		\ "
	*)
	pure virtual function string get_step_obj_name();
		// ------------------------------------------
	
	(* doc$markdown = "\
        \ Prints the values of the static attributes object.\n\
        \ \n\
        \ Prints the values of the static attributes object with the given `verbosity`.\n\
        \ Prints with the default UVM report object, not Bathtub's dedicated report object.\n\
        \ "
    *)
    pure virtual function void print_attributes(uvm_verbosity verbosity);
		// --------------------------------------------------------------
	
endclass : step_static_attributes_interface

`endif // __STEP_STATIC_ATTRIBUTES_INTERFACE_SVH
