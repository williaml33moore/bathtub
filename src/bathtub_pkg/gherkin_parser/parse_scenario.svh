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

	task gherkin_parser::parse_scenario(ref gherkin_pkg::scenario scenario);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::scenario_value scenario_value;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario enter", UVM_HIGH)
		`uvm_message_add_string(line_obj.file_name)
		`uvm_message_add_int(line_obj.line_number, UVM_DEC)
		`uvm_message_add_int(line_obj.eof, UVM_BIN)
		if (!line_obj.eof) begin
			`uvm_message_add_string(line_obj.text)
		end
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)

		if (!line_obj.eof) begin

			analyze_line(line_obj.text, line_analysis_result);

			case (line_analysis_result.token_before_colon)
				"Scenario", "Example": begin : configure_scenario

					bit can_receive_description = 1;

					scenario_value.base.keyword = line_analysis_result.token_before_colon;
					scenario_value.base.scenario_definition_name = line_analysis_result.remainder_after_colon;
					
					get_next_line(line_obj);

					while (status == OK) begin : scenario_elements
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
									scenario_value.base.steps.push_back(step);
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
									"Scenarios" : begin : terminate_scenario
										// Any primary keyword terminates the scenario.
										break;
									end

									default : begin

										case (line_analysis_result.secondary_keyword)
											"#" : begin : ignore_comment
												get_next_line(line_obj);
											end

											default : begin

												if (can_receive_description) begin
													string description;
													parse_scenario_description(description, line_obj);
													scenario_value.base.description = description;
													can_receive_description = 0;
												end
												else begin
													status = ERROR;
													`uvm_error(`get_scope_name(), {"Unexpected line does not begin with a keyword, and is not in a legal place for a description"})
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
					`uvm_error(`get_scope_name(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
						". Expecting \"Scenario:\" or \"Example\""})
				end
			endcase
		end

		scenario = new("scenario", scenario_value);
		`push_onto_parser_stack(scenario)

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(scenario)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_scenario
