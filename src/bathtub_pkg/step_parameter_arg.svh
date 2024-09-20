/*
MIT License

Copyright (c) 2023 Everactive
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

`ifndef __STEP_PARAMETER_ARG_SVH
`define __STEP_PARAMETER_ARG_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

class step_parameter_arg extends uvm_object;
	static string type_name = "step_parameter_arg";
	typedef step_parameter_arg this_type;
	typedef enum {INVALID, INT, REAL, STRING} arg_type_t;
	local string _raw_text;
	local arg_type_t _arg_type;
	local int _int_value;
	local real _real_value;
	local string _string_value;
	

	local function new (string name="step_parameter_arg", string raw_text="", arg_type_t arg_type=INVALID, int int_arg=0, real real_arg=0.0, string string_arg="");
		super.new(name);
		this._raw_text = raw_text;
		this._arg_type = arg_type;
		this._int_value = int_arg;
		this._real_value = real_arg;
		this._string_value = string_arg;
	endfunction : new
	

	`uvm_field_utils_begin(step_parameter_arg)
		`uvm_field_string(_raw_text, UVM_ALL_ON | UVM_NOPACK | UVM_NOCOPY | UVM_READONLY)
		`uvm_field_enum(arg_type_t, _arg_type, UVM_ALL_ON | UVM_NOPACK | UVM_NOCOPY | UVM_READONLY)
		`uvm_field_int(_int_value, UVM_ALL_ON | UVM_NOPACK | UVM_NOCOPY | UVM_READONLY)
		`uvm_field_real(_real_value, UVM_ALL_ON | UVM_NOPACK | UVM_NOCOPY | UVM_READONLY)
		`uvm_field_string(_string_value, UVM_ALL_ON | UVM_NOPACK | UVM_NOCOPY | UVM_READONLY)
	`uvm_field_utils_end


	virtual function string get_type_name ();
		return type_name;
	endfunction : get_type_name


	virtual function uvm_object create (string name="");
		this_type object = new(name);
		return object;
	endfunction : create
	
	
	static function step_parameter_arg create_new_int_arg(string name, string raw_text, int value);
		create_new_int_arg = new(.name (name), .raw_text (raw_text), .arg_type (INT), .int_arg (value));
	endfunction : create_new_int_arg
	
	
	static function step_parameter_arg create_new_real_arg(string name, string raw_text, real value);
		create_new_real_arg = new(.name (name), .raw_text (raw_text), .arg_type (REAL), .real_arg (value));
	endfunction : create_new_real_arg
	
	
	static function step_parameter_arg create_new_string_arg(string name, string raw_text, string value);
		create_new_string_arg = new(.name (name), .raw_text (raw_text), .arg_type (STRING), .string_arg (value));
	endfunction : create_new_string_arg


	static function step_parameter_arg create_copy(string name="", uvm_object rhs);
		step_parameter_arg rhs_;
		int success;

		success = $cast(rhs_, rhs);
		rhs_type_check : assert (success) else `uvm_fatal("TYPE_MISMATCH", "rhs argument is not type step_parameter_arg")

		rhs_ = new(name,
			rhs_.get_raw_text(),
			rhs_.get_arg_type(),
			rhs_.int_value(),
			rhs_.real_value(),
			rhs_.get_string_value()
		);
		return rhs_;
	endfunction : create_copy


	virtual function string get_raw_text ();
		return this._raw_text;
	endfunction : get_raw_text


	virtual function arg_type_t get_arg_type ();
		return this._arg_type;
	endfunction : get_arg_type


	virtual function int int_value ();
		return this._int_value;
	endfunction : int_value


	virtual function real real_value ();
		return this._real_value;
	endfunction : real_value


	virtual function string get_string_value ();
		return this._string_value;
	endfunction : get_string_value
	
	
	virtual function int as_int();
		case (get_arg_type())
			INVALID : return 0;
			INT : return int_value;
			REAL : return int'(real_value);
			STRING : return get_string_value().atoi(); // decimal
		endcase
	endfunction : as_int
	
	
	virtual function real as_real();
		case (get_arg_type())
			INVALID : return 0.0;
			INT : return real'(int_value);
			REAL : return real_value;
			STRING : return get_string_value().atoreal();
		endcase
	endfunction : as_real
	
	
	virtual function string as_string ();
		case (get_arg_type())
			INVALID : return "";
			INT : return $sformatf("%d", int_value);
			REAL : return $sformatf("%f", real_value);
			STRING : return get_string_value();
		endcase
	endfunction : as_string
	
endclass : step_parameter_arg

`endif // __STEP_PARAMETER_ARG_SVH
