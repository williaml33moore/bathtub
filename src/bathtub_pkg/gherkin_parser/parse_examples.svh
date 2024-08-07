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

`ifndef __PARSE_EXAMPLES_SVH
`define __PARSE_EXAMPLES_SVH

task gherkin_parser::parse_examples(ref gherkin_pkg::examples examples);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;
	gherkin_pkg::examples_value examples_value;
	int num_headers;

	num_headers = 0;

	line_mbox.peek(line_obj);

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_examples enter", UVM_HIGH, report_object)
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
		
		case (line_analysis_result.token_before_colon)
			"Examples", "Scenarios" : begin : configure_examples
				int description_count = 0;
				bit can_receive_description = 1;

				examples_value.keyword = line_analysis_result.token_before_colon;
				examples_value.examples_name = line_analysis_result.remainder_after_colon;
				while (floating_tags.size() > 0) begin
					examples_value.tags.push_back(floating_tags.pop_front());
				end

				get_next_line(line_obj);

				while (status == OK) begin : examples_elements

					line_mbox.peek(line_obj);

					if (line_obj.eof) break;

					analyze_line(line_obj.text, line_analysis_result);

					case (line_analysis_result.token_before_colon)

						"Rule",
						"Example",
						"Scenario",
						"Background",
						"Scenario Outline",
						"Scenario Template",
						"Examples",
						"Scenarios" : begin : terminate_examples
							// These primary keywords terminate the examples.
							break;
						end

						"Feature": begin
							status = ERROR;
							`uvm_error_context(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.token_before_colon}, report_object)
							break;
						end

						default : begin

							case (line_analysis_result.secondary_keyword)

								"#" : begin : construct_comment
									gherkin_pkg::comment comment;

									parse_comment(comment);
									`pop_from_parser_stack(comment)
									if (status == OK) begin
										; // Discard comment
									end
								end

								"|" : begin : construct_examples_row
									gherkin_pkg::table_row row;

									parse_table_row(row);
									`pop_from_parser_stack(row)
									if (status == OK) begin
										if (num_headers == 0) begin
											examples_value.header = row;
											num_headers++;
										end
										else begin
											examples_value.rows.push_back(row);
										end
									end
								end

								default: begin
									if (can_receive_description) begin
										string description;
										parse_examples_description(description, line_obj);
										examples_value.description = description;
										can_receive_description = 0;
									end
									else begin
										break;
									end
								end
							endcase
						end

					endcase

				end

				if (num_headers != 1) begin
					status = ERROR;
					`uvm_error_context(`BATHTUB__GET_SCOPE_NAME(), "An examples table must have exactly one header row", report_object)
				end

			end

			default : begin
				status = ERROR;
				`uvm_error_context(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
					". Expecting a table row beginning with \"|\"."}, report_object)
			end

		endcase
	end

	examples = new("examples", examples_value);
	`push_onto_parser_stack(examples)

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "parse_examples exit", UVM_HIGH, report_object)
	`uvm_message_add_tag("status", status.name)
	`uvm_message_add_object(examples)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_context_end
	`uvm_info_context(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH, report_object)
endtask : parse_examples

`endif // __PARSE_EXAMPLES_SVH
