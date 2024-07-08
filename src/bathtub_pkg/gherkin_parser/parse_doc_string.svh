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

`ifndef __PARSE_DOC_STRING_SVH
`define __PARSE_DOC_STRING_SVH

task gherkin_parser::parse_doc_string(ref gherkin_pkg::doc_string doc_string);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;
	gherkin_pkg::doc_string_value doc_string_value;
	string delimiter = "";

	line_mbox.peek(line_obj);

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_doc_string enter", UVM_HIGH)
	`uvm_message_add_string(line_obj.file_name)
	`uvm_message_add_int(line_obj.line_number, UVM_DEC)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	if (!line_obj.eof) begin
		`uvm_message_add_string(line_obj.text)
	end
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)

	if (!line_obj.eof) begin

		analyze_line(line_obj.text, line_analysis_result);

		case (line_analysis_result.secondary_keyword)
			"\"\"\"", "```" : begin : configure_doc_string
				delimiter = line_analysis_result.secondary_keyword;

				doc_string_value.content_type = line_analysis_result.remainder_after_secondary_keyword;
				doc_string_value.content = "";

				get_next_line(line_obj);

				while (status == OK) begin : content
					line_mbox.peek(line_obj);

					if (line_obj.eof) break;

					analyze_line(line_obj.text, line_analysis_result);

					case (line_analysis_result.secondary_keyword)
						delimiter : begin : terminate
							// Matching delimiter terminates the doc string

							if (line_analysis_result.remainder_after_secondary_keyword.len() != 0) begin
								status = ERROR;
								`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected content type after closing delimiter: ", line_analysis_result.remainder_after_secondary_keyword,
									". Expecting nothing."})
							end

							get_next_line(line_obj);
							break;
						end

						default : begin : construct_content
							// Newline gets trimmed by parser, so append a new one.
							doc_string_value.content = {doc_string_value.content, line_obj.text, "\n"};
							// Preserve all white space in a doc string
							get_next_line(.line_obj(line_obj), .preserve_white_space(1'b1));
						end
					endcase
				end
			end

			default : begin
				status = ERROR;
				`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.secondary_keyword,
					". Expecting \"\"\" or ```"})
			end
		endcase
	end

	doc_string = new("data_table", doc_string_value);
	`push_onto_parser_stack(doc_string)

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_doc_string exit", UVM_HIGH)
	`uvm_message_add_tag("status", status.name())
	`uvm_message_add_object(doc_string)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
endtask : parse_doc_string

`endif // __PARSE_DOC_STRING_SVH
