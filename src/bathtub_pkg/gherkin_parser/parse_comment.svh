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

`ifndef __PARSE_COMMENT_SVH
`define __PARSE_COMMENT_SVH

task gherkin_parser::parse_comment(ref gherkin_pkg::comment comment);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;
	gherkin_pkg::comment_value comment_value;

	line_mbox.peek(line_obj);

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_comment enter", UVM_HIGH, report_object)
	`uvm_message_add_string(line_obj.file_name)
	`uvm_message_add_int(line_obj.line_number, UVM_DEC)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	if (!line_obj.eof) begin
		`uvm_message_add_string(line_obj.text)
	end
	`uvm_info_context_end
	`uvm_info_context(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH, report_object)

	if (!line_obj.eof) begin
		analyze_line(line_obj.text, line_analysis_result);

		case (line_analysis_result.secondary_keyword)
			"#": begin : configure_comment
				comment_value.text = line_analysis_result.remainder_after_secondary_keyword;

				get_next_line(line_obj);
			end

			default : begin
				status = ERROR;
				`uvm_error_context(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.secondary_keyword,
				". Expecting \"#\""}, report_object)
			end
		endcase
	end

	comment = new("comment", comment_value);
	`push_onto_parser_stack(comment)

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "parse_comment exit", UVM_HIGH, report_object)
	`uvm_message_add_tag("status", status.name)
	`uvm_message_add_object(comment)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_context_end
	`uvm_info_context(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH, report_object)
endtask : parse_comment

`endif // __PARSE_COMMENT_SVH
