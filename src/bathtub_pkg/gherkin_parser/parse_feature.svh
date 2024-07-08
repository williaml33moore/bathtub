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

`ifndef __PARSE_FEATURE_SVH
`define __PARSE_FEATURE_SVH

task gherkin_parser::parse_feature(ref gherkin_pkg::feature feature);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;
	gherkin_pkg::feature_value feature_value;

	line_mbox.peek(line_obj);

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_feature enter", UVM_HIGH)
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

			"Feature" : begin : configure_feature
				int description_count = 0;
				int background_count = 0;
				bit can_receive_description = 1;

				feature_value.keyword = line_analysis_result.token_before_colon;
				feature_value.feature_name = line_analysis_result.remainder_after_colon;
				while (floating_tags.size() > 0) begin
					feature_value.tags.push_back(floating_tags.pop_front());
				end
				get_next_line(line_obj);

				while (status == OK) begin : feature_elements
					line_mbox.peek(line_obj);

					if (line_obj.eof) break;

					analyze_line(line_obj.text, line_analysis_result);

					case (line_analysis_result.token_before_colon)

						"Background" : begin : construct_background
							gherkin_pkg::background background;

							parse_background(background);
							`pop_from_parser_stack(background)
							if (status == OK) begin
								if (background_count == 0) begin
									feature_value.scenario_definitions.push_back(background);
									background_count++;
								end
								else begin
									status = ERROR;
									`uvm_error(`BATHTUB__GET_SCOPE_NAME(), "A feature can have only one background")
								end
							end
						end

						"Scenario", "Example" : begin : construct_scenario
							gherkin_pkg::scenario scenario;

							parse_scenario(scenario);
							`pop_from_parser_stack(scenario)
							if (status == OK) begin
								feature_value.scenario_definitions.push_back(scenario);
							end
						end

						"Scenario Outline", "Scenario Template" : begin : construct_scenario_outline
							gherkin_pkg::scenario_outline scenario_outline;

							parse_scenario_outline(scenario_outline);
							`pop_from_parser_stack(scenario_outline)
							if (status == OK) begin
								feature_value.scenario_definitions.push_back(scenario_outline);
							end
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

								"@" : begin : construct_tags
									gherkin_pkg::tag tags[$];

									parse_tags(tags);
									if (status == OK) begin
										while (tags.size() > 0) begin
											floating_tags.push_back(tags.pop_front());
										end
									end
									can_receive_description = 0;
								end

								default : begin
									if (can_receive_description) begin
										string description;
										parse_feature_description(description, line_obj);
										feature_value.description = description;
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
			end

			default : begin
				status = ERROR;
				`uvm_error(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
					". Expecting \"Feature:\"."})
			end
		endcase
	end

	feature = new("feature", feature_value);
	`push_onto_parser_stack(feature)

	`uvm_info_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_feature exit", UVM_HIGH)
	`uvm_message_add_tag("status", status.name())
	`uvm_message_add_object(feature)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_end
	`uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
endtask : parse_feature

`endif // __PARSE_FEATURE_SVH
