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

`ifndef __PARSE_STEP_SVH
`define __PARSE_STEP_SVH

task gherkin_parser::parse_step(ref gherkin_pkg::step step);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;
	gherkin_pkg::step_value step_value;

	line_mbox.peek(line_obj);

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_step enter", UVM_HIGH)
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

		case (line_analysis_result.token_before_space)
			"Given",
			"When",
			"Then",
			"And",
			"But",
			"*": begin : configure_step
				int num_step_arguments = 0;

				step_value.keyword = line_analysis_result.token_before_space;
				step_value.text = line_analysis_result.remainder_after_space;

				get_next_line(line_obj);

				while (status == OK) begin : step_elements
					line_mbox.peek(line_obj);

					if (line_obj.eof) break;

					analyze_line(line_obj.text, line_analysis_result);

					case (line_analysis_result.secondary_keyword)
						"|" : begin : construct_data_table
							gherkin_pkg::data_table data_table;

							parse_data_table(data_table);
							`pop_from_parser_stack(data_table)

							if (status == OK) begin
								if (num_step_arguments == 0) begin
									step_value.argument = data_table;
									num_step_arguments++;
								end
								else begin
									status = ERROR;
									`uvm_error(`BATHTUB__GET_SCOPE_NAME(), "A step can have only one argument")
								end
							end
						end

						"\"\"\"" : begin : construct_doc_string
							gherkin_pkg::doc_string doc_string;

							parse_doc_string(doc_string);
							`pop_from_parser_stack(doc_string)

							if (status == OK) begin
								if (num_step_arguments == 0) begin
									step_value.argument = doc_string;
									num_step_arguments++;
								end
								else begin
									status = ERROR;
									`uvm_error(`BATHTUB__GET_SCOPE_NAME(), "A step can have only one argument")
								end
							end
						end

						default: begin
							// Anything else terminates the step
							break;
						end
					endcase
				end
			end

			default : begin
				status = ERROR;
				`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.token_before_space,
					". Expecting \"Given\", \"When\", \"Then\", \"And\", \"But\", or \"*\""})
			end
		endcase
	end

	step = new("step", step_value);
	`push_onto_parser_stack(step)

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "parse_step exit", UVM_HIGH);
	`uvm_message_add_tag("status", status.name)
	`uvm_message_add_object(step)
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
endtask : parse_step

`endif // __PARSE_STEP_SVH
