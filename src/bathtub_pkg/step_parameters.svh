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

import uvm_pkg::*;

typedef class bathtub_utils;
`include "bathtub_pkg/bathtub_utils.svh"

typedef class step_parameter_arg;
`include "bathtub_pkg/step_parameter_arg.svh"

`include "bathtub_macros.sv"

class step_parameters extends uvm_object;
	protected step_parameter_arg argv[$];
	protected string step_text;
	protected string format;
	local bit has_been_scanned;
	
	
	`uvm_field_utils_begin(step_parameters)
	`uvm_field_utils_end
	
	
	function new(string str="", string format="");
		super.new("step_parameters");
		has_been_scanned = 1'b0;
	endfunction : new
	
	
	static function step_parameters create_new(string name, string step_text="", string format="");
		step_parameters new_obj = new(name);
		
		new_obj.step_text = step_text;
		new_obj.format = format;
		
		return new_obj;
		
	endfunction : create_new
	
	
	virtual function step_parameter_arg get_arg(int i);
		if (!has_been_scanned) begin
			void'(step_parameters::scan_step_params(step_text, format, argv));
			has_been_scanned = 1'b1;
		end
		return argv[i];
	endfunction : get_arg
	
	
	virtual function int num_args();
		if (!has_been_scanned) begin
			void'(step_parameters::scan_step_params(step_text, format, argv));
			has_been_scanned = 1'b1;
		end
		return argv.size();
	endfunction : num_args
		
	

// ===================================================================
	static function int scan_step_params(string step_text, string scanf_format, ref step_parameter_arg step_argv[$]);
// ===================================================================
		string text_tokens[$];
		string format_tokens[$];
		
		`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(-2), "", UVM_HIGH)
			`uvm_message_add_string(step_text)
			`uvm_message_add_string(scanf_format)
		`uvm_info_end

		step_argv.delete();

		bathtub_utils::split_string(scanf_format, format_tokens);
		bathtub_utils::split_string(step_text, text_tokens);

		for (int i = 0; i < format_tokens.size(); i++) begin
			int sscanf_code;
			string conversion_code;
			int int_arg;
			real real_arg;
			string string_arg;

			conversion_code = bathtub_utils::get_conversion_code(format_tokens[i]);

			case (conversion_code)
				"b", "o", "d", "h", "x",
				"B", "O", "D", "H", "X" : begin : case_$int
					sscanf_code = $sscanf(text_tokens[i], format_tokens[i], int_arg);

					if (sscanf_code == 1) begin
						step_argv.push_back(step_parameter_arg::create_new_int_arg("anonymous", int_arg));
					end
					else begin
						$fatal(1, $sformatf("Unexpected result (%0d) while parsing string '%s' with format '%s'",
							sscanf_code, text_tokens[i], format_tokens[i]));
					end
				end

				"f", "e", "g",
				"F", "E", "G" : begin : case_$real
					sscanf_code = $sscanf(text_tokens[i], format_tokens[i], real_arg);

					if (sscanf_code == 1) begin
						step_argv.push_back(step_parameter_arg::create_new_real_arg("anonymous", real_arg));
					end
					else begin
						$fatal(1, $sformatf("Unexpected result (%0d) while parsing string '%s' with format '%s'",
							sscanf_code, text_tokens[i], format_tokens[i]));
					end
				end

				"s", "c",
				"S", "C" : begin : case_$string
					sscanf_code = $sscanf(text_tokens[i], format_tokens[i], string_arg);

					if (sscanf_code == 1) begin
						step_argv.push_back(step_parameter_arg::create_new_string_arg("anonymous", string_arg));
					end
					else begin
						$fatal(1, $sformatf("Unexpected result (%0d) while parsing string '%s' with format '%s'",
							sscanf_code, text_tokens[i], format_tokens[i]));
					end
				end

				default : begin : case_$no_arg
					sscanf_code = $sscanf(text_tokens[i], format_tokens[i]);

					if (sscanf_code != 0) begin
						$fatal(1, $sformatf("Unexpected result (%0d) while parsing string '%s' with format '%s'",
							sscanf_code, text_tokens[i], format_tokens[i]));
					end
				end
			endcase
		end

		foreach (step_argv[i]) begin
			`uvm_info(`BATHTUB__GET_SCOPE_NAME(), {"\n", step_argv[i].sprint()}, UVM_HIGH)
		end

		return step_argv.size();
	endfunction : scan_step_params



endclass : step_parameters
