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

`include "bathtub_pkg/step_static_attributes_interface.svh"
`include "bathtub_macros.sv"
`include "uvm_macros.svh"

typedef class bathtub_utils;
`include "bathtub_pkg/bathtub_utils.svh"

class step_nature extends uvm_object implements step_static_attributes_interface;

	protected step_keyword_t keyword;
	protected string expression;
	protected string regexp;
	protected uvm_object_wrapper step_obj;
	protected string step_obj_name;

	function new(string name="step_nature");
		super.new(name);
	endfunction : new


	`uvm_object_utils_begin(step_nature)
		`uvm_field_enum(step_keyword_t, keyword, UVM_DEFAULT)
		`uvm_field_string(expression, UVM_DEFAULT)
		`uvm_field_string(regexp, UVM_DEFAULT)
		`uvm_field_string(step_obj_name, UVM_DEFAULT)
	`uvm_object_utils_end

	
	static function step_static_attributes_interface register_step(step_keyword_t keyword, string expression, uvm_object_wrapper step_obj, bit store_in_db=1'b1);
		step_nature new_obj;

		new_obj = new("static_step_object");
		new_obj.keyword = keyword;
		new_obj.expression = expression;
		new_obj.set_step_obj(step_obj);
		
		if (bathtub_utils::is_regex(expression)) begin
			new_obj.regexp = expression;
		end
		else begin
			new_obj.regexp = bathtub_utils::bathtub_to_regexp(expression);
		end
		
		if (store_in_db) begin
			uvm_resource_db#(uvm_object_wrapper)::set(new_obj.regexp, STEP_DEF_RESOURCE_NAME, step_obj);
		end
		
		`uvm_info(`BATHTUB__GET_SCOPE_NAME(), {"\n", new_obj.sprint()}, UVM_HIGH)
		return new_obj;
	endfunction
	
	virtual function void print_attributes(uvm_verbosity verbosity);
		`uvm_info_begin(get_name(), "", verbosity)
		`uvm_message_add_tag("keyword", keyword.name())
		`uvm_message_add_string(expression)
		`uvm_message_add_string(regexp)
		`uvm_message_add_string(step_obj_name)
		`uvm_info_end
	endfunction : print_attributes
			
	// Set keyword
	virtual function void set_keyword(step_keyword_t keyword);
		this.keyword = keyword;
	endfunction : set_keyword

	// Get keyword
	virtual function step_keyword_t get_keyword();
		return keyword;
	endfunction : get_keyword

	// Get expression
	virtual function string get_expression();
		return expression;
	endfunction : get_expression

	// Set expression
	virtual function void set_expression(string expression);
		this.expression = expression;
	endfunction : set_expression

	// Set regexp
	virtual function void set_regexp(string regexp);
		this.regexp = regexp;
	endfunction : set_regexp

	// Get regexp
	virtual function string get_regexp();
		return regexp;
	endfunction : get_regexp

	// Get obj_name
	virtual function uvm_object_wrapper get_step_obj();
		return step_obj;
	endfunction : get_step_obj

	// Set obj_name
	virtual function void set_step_obj(uvm_object_wrapper step_obj);
		this.step_obj = step_obj;
		this.step_obj_name = step_obj ? step_obj.get_type_name() : "null";
	endfunction : set_step_obj
	
	// Get step_obj_name
	virtual function string get_step_obj_name();
		return step_obj_name;
	endfunction : get_step_obj_name

	// Set step_obj_name
	virtual function void set_step_obj_name(string step_obj_name);
		this.step_obj_name = step_obj_name;
	endfunction : set_step_obj_name
	
endclass : step_nature
