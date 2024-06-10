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

`ifndef __PARSE_TAG_SVH
`define __PARSE_TAG_SVH

task gherkin_parser::parse_tag(ref gherkin_pkg::tag tag);
	string tag_name;
	gherkin_pkg::tag_value tag_value;

	tag_mbox.get(tag_name);

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_tag enter", UVM_HIGH)
	`uvm_message_add_string(tag_name)
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)

	if (tag_name[0] != "@") begin
		status = ERROR;
		`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Illegal tag name: ", tag_name,
			". Tag name must begin with \"@\""})
	end
	else begin
		foreach(tag_name[i]) begin
			if (tag_name[i] inside {" ", "\t", "\n", CR}) begin
				status = ERROR;
				`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Illegal tag name: ", tag_name,
					". Tag name must not contain white space"})
				break;
			end
		end
	end

	if (status == OK) begin
		tag_value.tag_name = tag_name;
		tag = new("table_cell", tag_value);
		`push_onto_parser_stack(tag)
	end

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_tag exit", UVM_HIGH)
	`uvm_message_add_tag("status", status.name())
	`uvm_message_add_object(tag)
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
endtask : parse_tag

`endif // __PARSE_TAG_SVH
