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

`ifndef __PARSE_DATA_TABLE_SVH
`define __PARSE_DATA_TABLE_SVH

task gherkin_parser::parse_data_table(ref gherkin_pkg::data_table data_table);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;
	gherkin_pkg::data_table_value data_table_value;

	line_mbox.peek(line_obj);

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_data_table enter", UVM_HIGH)
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
			"|" : begin : configure_data_table

				data_table_value.rows.delete();

				while (status == OK) begin : rows
					line_mbox.peek(line_obj);

					if (line_obj.eof) break;

					analyze_line(line_obj.text, line_analysis_result);

					case (line_analysis_result.secondary_keyword)

						"#" : begin : construct_comment
							gherkin_pkg::comment comment;

							parse_comment(comment);
							`pop_from_parser_stack(comment)
							if (status == OK) begin
								; // Discard comment
							end
						end
						
						"|" : begin : construct_table_row
							gherkin_pkg::table_row table_row;

							parse_table_row(table_row);
							`pop_from_parser_stack(table_row)

							if (status == OK) begin
								data_table_value.rows.push_back(table_row);
							end
						end

						default : begin
							// Anything else terminates the data table
							break;
						end
					endcase
				end
			end

			default : begin
				status = ERROR;
				`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.secondary_keyword,
					". Expecting \"|\""})
			end
		endcase

	end

	data_table = new("data_table", data_table_value);
	`push_onto_parser_stack(data_table)

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_data_table exit", UVM_HIGH)
	`uvm_message_add_tag("status", status.name())
	`uvm_message_add_object(data_table)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)

endtask : parse_data_table

`endif // __PARSE_DATA_TABLE_SVH