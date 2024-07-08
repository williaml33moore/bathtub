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

`ifndef __PARSE_BACKGROUND_SVH
`define __PARSE_BACKGROUND_SVH

task gherkin_parser::parse_background(ref gherkin_pkg::background background);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;
	gherkin_pkg::background_value background_value;

	line_mbox.peek(line_obj);

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_background enter", UVM_HIGH)
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

		case (line_analysis_result.token_before_colon)
			"Background": begin : configure_background

				bit can_receive_description = 1;

				background_value.base.keyword = line_analysis_result.token_before_colon;
				background_value.base.scenario_definition_name = line_analysis_result.remainder_after_colon;
				if (floating_tags.size() > 0) begin
					status = ERROR;
					`uvm_error(`BATHTUB__GET_SCOPE_NAME(), "A background can not have tags")
				end

				get_next_line(line_obj);

				while (status == OK) begin : background_elements
					line_mbox.peek(line_obj);

					if (line_obj.eof) break;

					analyze_line(line_obj.text, line_analysis_result);

					case (line_analysis_result.token_before_space)
						"Given",
						"When",
						"Then",
						"And",
						"But",
						"*": begin : construct_step
							gherkin_pkg::step step;

							parse_step(step);
							`pop_from_parser_stack(step)

							if (status == OK) begin
								background_value.base.steps.push_back(step);
							end
							// Can't have a description after steps
							can_receive_description = 0;
						end

						default : begin

							case (line_analysis_result.token_before_colon)
								"Feature",
								"Rule",
								"Example",
								"Scenario",
								"Background",
								"Scenario Outline",
								"Scenario Template",
								"Examples",
								"Scenarios" : begin : terminate_background
									// Any primary keyword terminates the background.
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

										"@" : begin : break_on_secondary_keyword
											// Any legal secondary keyword terminates the background
											break;
										end

										default : begin

											if (can_receive_description) begin
												string description;
												parse_scenario_description(description, line_obj);
												background_value.base.description = description;
												can_receive_description = 0;
											end
											else begin
												status = ERROR;
												`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected line does not begin with a keyword, and is not in a legal place for a description:\n",
													line_obj.text})
											end
										end
									endcase
								end
							endcase
						end
					endcase
				end
			end

			default : begin
				status = ERROR;
				`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
					". Expecting \"Background:\""})
			end
		endcase
	end

	background = new("background", background_value);
	`push_onto_parser_stack(background)

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_background exit", UVM_HIGH)
	`uvm_message_add_tag("status", status.name())
	`uvm_message_add_object(background)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
endtask : parse_background

`endif // __PARSE_BACKGROUND_SVH
