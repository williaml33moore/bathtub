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

`ifndef __STEP_PARAMETER_ARG_SVH
`define __STEP_PARAMETER_ARG_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

class step_parameter_arg extends uvm_object;
	typedef enum {INVALID, INT, REAL, STRING} arg_type_t;
	protected int int_arg;
	protected real real_arg;
	protected string string_arg;
	protected arg_type_t arg_type;
	

	function new(string name="step_parameter_arg");
		super.new(name);
		arg_type = INVALID;
	endfunction : new
	

	`uvm_object_utils_begin(step_parameter_arg)
		`uvm_field_enum(arg_type_t, arg_type, UVM_ALL_ON)
		`uvm_field_int(int_arg, UVM_ALL_ON)
		`uvm_field_real(real_arg, UVM_ALL_ON)
		`uvm_field_string(string_arg, UVM_ALL_ON)
	`uvm_object_utils_end
	
	
	static function step_parameter_arg create_new_int_arg(string name, int value);
		step_parameter_arg new_obj = new(name);
		new_obj.int_arg = value;
		new_obj.arg_type = INT;
		return new_obj;
	endfunction : create_new_int_arg
	
	
	static function step_parameter_arg create_new_real_arg(string name, real value);
		step_parameter_arg new_obj = new(name);
		new_obj.real_arg = value;
		new_obj.arg_type = REAL;
		return new_obj;
	endfunction : create_new_real_arg
	
	
	static function step_parameter_arg create_new_string_arg(string name, string value);
		step_parameter_arg new_obj = new(name);
		new_obj.string_arg = value;
		new_obj.arg_type = STRING;
		return new_obj;
	endfunction : create_new_string_arg
	
	
	virtual function int as_int();
		case (arg_type)
			INVALID : return 0;
			INT : return int_arg;
			REAL : return int'(real_arg);
			STRING : return string_arg.atoi(); // decimal
		endcase
	endfunction : as_int
	
	
	virtual function real as_real();
		case (arg_type)
			INVALID : return 0.0;
			INT : return real'(int_arg);
			REAL : return real_arg;
			STRING : return string_arg.atoreal();
		endcase
	endfunction : as_real
	
	
	virtual function string as_string();
		case (arg_type)
			INVALID : return "";
			INT : return $sformatf("%d", int_arg);
			REAL : return $sformatf("%f", real_arg);
			STRING : return string_arg;
		endcase
	endfunction : as_string
	
endclass : step_parameter_arg

`endif // __STEP_PARAMETER_ARG_SVH
