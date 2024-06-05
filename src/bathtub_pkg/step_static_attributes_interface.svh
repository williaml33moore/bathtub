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

	interface class step_static_attributes_interface;
		
		// Set keyword
		pure virtual function void set_keyword(step_keyword_t keyword);

		// Get keyword
		pure virtual function step_keyword_t get_keyword();

		// Set regexp
		pure virtual function void set_regexp(string regexp);

		// Get regexp
		pure virtual function string get_regexp();

		// Get expression
		pure virtual function string get_expression();

		// Set expression
		pure virtual function void set_expression(string expression);

		// Get step_obj
		pure virtual function uvm_object_wrapper get_step_obj();

		// Set obj_name
		pure virtual function void set_step_obj(uvm_object_wrapper step_obj);
		
		// Get step_obj_name
		pure virtual function string get_step_obj_name();
		
		pure virtual function void print_attributes(uvm_verbosity verbosity);
		
	endclass : step_static_attributes_interface

`endif // __STEP_STATIC_ATTRIBUTES_INTERFACE_SVH
