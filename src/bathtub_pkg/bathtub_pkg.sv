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

`include "uvm_macros.svh"
`include "bathtub_macros.sv"

`define push_onto_parser_stack(o) parser_stack.push_front(o);

`ifdef BATHTUB__MULTILINE_MACRO_IS_OK

`define pop_from_parser_stack(o) if (parser_stack.size() == 0) begin \
status = ERROR; \
`uvm_fatal(`get_scope_name(), "Visitor stack is empty") \
end \
else begin \
uvm_object obj = parser_stack.pop_front(); \
end

`else // BATHTUB__MULTILINE_MACRO_IS_OK
`define pop_from_parser_stack(o) if (parser_stack.size() == 0) begin status = ERROR; `uvm_fatal(`get_scope_name(), "Visitor stack is empty") end else begin uvm_object obj = parser_stack.pop_front(); end
`endif // BATHTUB__MULTILINE_MACRO_IS_OK

// ===================================================================
package bathtub_pkg;
// ===================================================================

	import uvm_pkg::*;
	
	
	typedef enum {Given, When, Then, And, But, \* } step_keyword_t;
	typedef class gherkin_parser;
	typedef class gherkin_document_printer;
	typedef class gherkin_document_runner;
	
	
	parameter byte CR = 13; // ASCII carriage return
	parameter string STEP_DEF_RESOURCE_NAME = "bathtub_pkg::step_definition_interface";
	
	`include "bathtub_utils.svh"
	`include "line_value.svh"
	`include "pool_provider_interface.svh"
	`include "pool_provider.svh"
	`include "feature_sequence_interface.svh"
	`include "feature_sequence.svh"
	`include "scenario_sequence_interface.svh"
	`include "scenario_sequence.svh"
	`include "step_parameter_arg.svh"
	`include "step_parameters.svh"
	`include "step_static_attributes_interface.svh"
	`include "step_nature.svh"
	`include "step_attributes_interface.svh"
	`include "step_nurture.svh"
	`include "step_definition_interface.svh"
	`include "gherkin_doc_bundle.svh"
	`include "bathtub.svh"
	`include "gherkin_parser_interface.svh"
	`include "gherkin_parser.svh"
	`include "gherkin_parser/parse_background.svh"

	task gherkin_parser::parse_comment(ref gherkin_pkg::comment comment);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::comment_value comment_value;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_comment enter", UVM_HIGH)
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

			case (line_analysis_result.secondary_keyword)
				"#": begin : configure_comment
					comment_value.text = line_analysis_result.remainder_after_secondary_keyword;

					get_next_line(line_obj);
				end

				default : begin
					status = ERROR;
					`uvm_error(`get_scope_name(), {"Unexpected keyword: ", line_analysis_result.secondary_keyword,
					". Expecting \"#\""})
				end
			endcase
		end

		comment = new("comment", comment_value);
		`push_onto_parser_stack(comment)

		`uvm_info_begin(`get_scope_name(), "parse_comment exit", UVM_HIGH);
		`uvm_message_add_tag("status", status.name)
		`uvm_message_add_object(comment)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_comment

	task gherkin_parser::parse_data_table(ref gherkin_pkg::data_table data_table);
		`uvm_fatal("PENDING", "")
	endtask : parse_data_table

	task gherkin_parser::parse_doc_string(ref gherkin_pkg::doc_string doc_string);
		`uvm_fatal("PENDING", "")
	endtask : parse_doc_string

	task gherkin_parser::parse_examples(ref gherkin_pkg::examples examples);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::examples_value examples_value;

		int num_headers = 0;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_examples enter", UVM_HIGH)
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
				"Examples", "Scenarios" : begin : configure_examples

					examples_value.keyword = line_analysis_result.token_before_colon;
					examples_value.examples_name = line_analysis_result.remainder_after_colon;

					get_next_line(line_obj);

					while (status == OK) begin : examples_elements

						line_mbox.peek(line_obj);

						if (line_obj.eof) break;

						analyze_line(line_obj.text, line_analysis_result);

						case (line_analysis_result.secondary_keyword)
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
								// Any other keyword terminates the examples table
								break;
							end
						endcase

					end

					if (num_headers != 1) begin
						status = ERROR;
						`uvm_error(`get_scope_name(), "An examples table must have exactly only one header row")
					end

				end

				default : begin
					status = ERROR;
					`uvm_error(`get_scope_name(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
						". Expecting a table row beginning with \"|\"."})
				end

			endcase
		end

		examples = new("examples", examples_value);
		`push_onto_parser_stack(examples)

		`uvm_info_begin(`get_scope_name(), "parse_examples exit", UVM_HIGH);
		`uvm_message_add_tag("status", status.name)
		`uvm_message_add_object(examples)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_examples

	task gherkin_parser::parse_feature(ref gherkin_pkg::feature feature);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::feature_value feature_value;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_feature enter", UVM_HIGH)
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

				"Feature" : begin : configure_feature
					int description_count = 0;
					int background_count = 0;
					bit can_receive_description = 1;

					feature_value.keyword = line_analysis_result.token_before_colon;
					feature_value.feature_name = line_analysis_result.remainder_after_colon;
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
										`uvm_error(`get_scope_name(), "A feature can have only one background")
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
				end

				default : begin
					status = ERROR;
					`uvm_error(`get_scope_name(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
						". Expecting \"Feature:\"."})
				end
			endcase
		end

		feature = new("feature", feature_value);
		`push_onto_parser_stack(feature)

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_feature exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(feature)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_feature


	task gherkin_parser::parse_gherkin_document(ref gherkin_pkg::gherkin_document gherkin_document);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::gherkin_document_value gherkin_document_value;
		int feature_count = 0;

		// Prime the mailbox so it contains the first non-empty line

		forever begin : find_first_non_empty_line
			line_mbox.peek(line_obj);

			if (line_obj.eof) break;

			else if (bathtub_utils::trim_white_space(line_obj.text) == "") begin
				// Ignore empty lines
				get_next_line(line_obj);
			end

			else begin
				// Mailbox is ready
				break;
			end
		end

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_gherkin_document enter", UVM_HIGH)
		`uvm_message_add_string(line_obj.file_name)
		`uvm_message_add_int(line_obj.line_number, UVM_DEC)
		`uvm_message_add_int(line_obj.eof, UVM_BIN)
		if (!line_obj.eof) begin
			`uvm_message_add_string(line_obj.text)
		end
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)

		while (status == OK) begin : document_elements
			line_mbox.peek(line_obj);

			if (line_obj.eof) break;

			analyze_line(line_obj.text, line_analysis_result);

			case (line_analysis_result.token_before_colon)

				"Feature" : begin : construct_feature
					gherkin_pkg::feature feature;

					parse_feature(feature);
					`pop_from_parser_stack(feature)

					if (status == OK) begin
						if (feature_count == 0) begin
							gherkin_document_value.feature = feature;
							feature_count++;
						end
						else begin
							status = ERROR;
							`uvm_error(`get_scope_name(), "A Gherkin document can have only one feature")
						end
					end
				end

				default : begin

					case (line_analysis_result.secondary_keyword)

						"#" : begin : construct_comment
							gherkin_pkg::comment comment;

							parse_comment(comment);
							`pop_from_parser_stack(comment)
							if (status == OK) begin
								gherkin_document_value.comments.push_back(comment);
							end
						end

						default : begin
							status = ERROR;
							`uvm_error(`get_scope_name(), {"Syntax error. Expecting \"Feature:\" or \"#\".",
								"\n", line_obj.text})
							get_next_line(line_obj);
							break;
						end
					endcase
				end
			endcase
		end

		gherkin_document = new("gherkin_document", gherkin_document_value);
		`push_onto_parser_stack(gherkin_document)

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_gherkin_document exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(gherkin_document)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_gherkin_document

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

	task gherkin_parser::parse_scenario_definition(ref gherkin_pkg::scenario_definition scenario_definition);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario_definition enter", UVM_HIGH)
		`uvm_message_add_string(line_obj.file_name)
		`uvm_message_add_int(line_obj.line_number, UVM_DEC)
		`uvm_message_add_int(line_obj.eof, UVM_BIN)
		if (!line_obj.eof) begin
			`uvm_message_add_string(line_obj.text)
		end
		`uvm_info_end

		if (!line_obj.eof) begin

			analyze_line(line_obj.text, line_analysis_result);

			case (line_analysis_result.token_before_colon)
			"Background",
			"Scenario",
			"Example",
			"Scenario Outline",
			"Scenario Template":
				; // Nothing to do

				default : begin
					status = ERROR;
					`uvm_error(`get_scope_name(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
						". Expecting \"Background:\", \"Scenario\", \"Example\", \"Scenario Outline\", or \"Scenario Template\""})
				end
			endcase
		end

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario_definition exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(scenario_definition)
		`uvm_info_end
	endtask : parse_scenario_definition

	task gherkin_parser::parse_scenario_outline(ref gherkin_pkg::scenario_outline scenario_outline);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::scenario_outline_value scenario_outline_value;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario_outline enter", UVM_HIGH)
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
				"Scenario Outline", "Scenario Template" : begin : configure_scenario_outline

					bit can_receive_description = 1;
					bit can_receive_step = 1;

					scenario_outline_value.base.keyword = line_analysis_result.token_before_colon;
					scenario_outline_value.base.scenario_definition_name = line_analysis_result.remainder_after_colon;

					get_next_line(line_obj);

					while (status == OK) begin : scenario_outline_elements
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
									if (can_receive_step) begin
										scenario_outline_value.base.steps.push_back(step);
									end
									else begin
										status = ERROR;
										`uvm_error(`get_scope_name(), "Can't have a step after a scenario outline example")
									end
								end
								// Can't have a description after steps
								can_receive_description = 0;
							end

							default : begin

								case (line_analysis_result.token_before_colon)
									"Examples",
									"Scenarios" : begin : construct_examples
										gherkin_pkg::examples examples;

										parse_examples(examples);
										`pop_from_parser_stack(examples)

										if (status == OK) begin
											scenario_outline_value.examples.push_back(examples);
											can_receive_step = 0;
										end
									end

									"Feature",
									"Rule",
									"Example",
									"Scenario",
									"Background",
									"Scenario Outline",
									"Scenario Template" : begin : terminate_scenario
										// Any other primary keyword terminates the scenario outline.
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
													scenario_outline_value.base.description = description;
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

		scenario_outline = new("scenario_outline", scenario_outline_value);
		`push_onto_parser_stack(scenario_outline)

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario_outline exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(scenario_outline)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_scenario_outline

	task gherkin_parser::parse_step(ref gherkin_pkg::step step);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::step_value step_value;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_step enter", UVM_HIGH)
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
										`uvm_error(`get_scope_name(), "A step can have only one argument")
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
										`uvm_error(`get_scope_name(), "A step can have only one argument")
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
					`uvm_error(`get_scope_name(), {"Unexpected keyword: ", line_analysis_result.token_before_space,
						". Expecting \"Given\", \"When\", \"Then\", \"And\", \"But\", or \"*\""})
				end
			endcase
		end

		step = new("step", step_value);
		`push_onto_parser_stack(step)

		`uvm_info_begin(`get_scope_name(), "parse_step exit", UVM_HIGH);
		`uvm_message_add_tag("status", status.name)
		`uvm_message_add_object(step)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_step

	task gherkin_parser::parse_step_argument(ref gherkin_pkg::step_argument step_argument);
		`uvm_fatal("PENDING", "")
	endtask : parse_step_argument

	task gherkin_parser::parse_table_cell(ref gherkin_pkg::table_cell table_cell);
		string cell_value;
		gherkin_pkg::table_cell_value table_cell_value;

		cell_mbox.get(cell_value);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_table_cell enter", UVM_HIGH)
		`uvm_message_add_string(cell_value)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)

		table_cell_value.value = cell_value;
		table_cell = new("table_cell", table_cell_value);
		`push_onto_parser_stack(table_cell)

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_table_cell exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(table_cell)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_table_cell

	task gherkin_parser::parse_table_row(ref gherkin_pkg::table_row table_row);
		line_value line_obj;
		line_analysis_result_t line_analysis_result;
		gherkin_pkg::table_row_value table_row_value;

		line_mbox.peek(line_obj);

		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_table_row enter", UVM_HIGH)
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

			case (line_analysis_result.secondary_keyword)
				"|" : begin : configure_table_row
					string cell_values[$];

					split_table_row(cell_values, bathtub_utils::trim_white_space(line_obj.text));
					get_next_line(line_obj);

					foreach (cell_values[i]) begin : construct_table_cell
						gherkin_pkg::table_cell table_cell;

						fork
							cell_mbox.put(cell_values[i]);
							begin
								parse_table_cell(table_cell);
								`pop_from_parser_stack(table_cell)
							end
						join

						if (status == OK) begin
							table_row_value.cells.push_back(table_cell);
						end
					end
				end

				default : begin
					status = ERROR;
					`uvm_error(`get_scope_name(), {"Unexpected keyword: ", line_analysis_result.secondary_keyword,
						". Expecting a table row beginning with \"|\""})
				end
			endcase

		end

		table_row = new("table_row", table_row_value);
		`push_onto_parser_stack(table_row)
		
		`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_table_row exit", UVM_HIGH)
		`uvm_message_add_tag("status", status.name())
		`uvm_message_add_object(table_row)
		`uvm_info_end
		`uvm_info(`get_scope_name(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH)
	endtask : parse_table_row


	task gherkin_parser::parse_tag(ref gherkin_pkg::tag tag);
		`uvm_fatal("PENDING", "")
	endtask : parse_tag


	class gherkin_document_printer extends uvm_object implements gherkin_pkg::visitor;

		gherkin_pkg::gherkin_document document;

		`uvm_object_utils_begin(gherkin_document_printer)
			`uvm_field_object(document, UVM_ALL_ON)
		`uvm_object_utils_end


		function new(string name = "gherkin_document_printer");
			// TODO Auto-generated constructor stub
			super.new(name);

		endfunction : new


		static function gherkin_document_printer create_new(string name = "gherkin_document_printer", gherkin_pkg::gherkin_document document);
			gherkin_document_printer new_printer;

			new_printer = new(name);
			new_printer.document = document;
			return new_printer;
		endfunction : create_new


		virtual task print();
			document.accept(this); // visit_gherkin_document(document)
		endtask : print

		/**
		 * @param background -
		 */
		virtual task visit_background(gherkin_pkg::background background);
			$display({1{"  "}}, background.keyword, ": ", background.scenario_definition_name);

			if (background.description.len() > 0) begin
				$write({2{"  "}});
				foreach (background.description[i]) begin
					byte c = background.description[i];

					$write(string'(c));
                  if (c inside {"\n", CR}) begin
						$write({2{"  "}});
					end
				end
				$display();
			end

			foreach (background.steps[i]) begin
				background.steps[i].accept(this); // visit_step(background.steps[i])
			end
			$display();

		endtask : visit_background

		/**
		 * @param comment -
		 */
		virtual task visit_comment(gherkin_pkg::comment comment);
		// TODO Auto-generated task stub

		endtask : visit_comment

		virtual task visit_data_table(gherkin_pkg::data_table data_table);
			foreach (data_table.rows[i]) begin
				data_table.rows[i].accept(this); // visit_table_row(data_table.rows[i])
			end
		endtask : visit_data_table

		/**
		 * @param doc_string -
		 */
		virtual task visit_doc_string(gherkin_pkg::doc_string doc_string);
		// TODO Auto-generated task stub

		endtask : visit_doc_string

		virtual task visit_examples(gherkin_pkg::examples examples);
			$display({{2{"  "}}, examples.keyword, ": ", examples.examples_name});

			if (examples.description != "") begin
				$write({2{"  "}});
				foreach (examples.description[i]) begin
					byte c = examples.description[i];

					$write(string'(c));
                  if (c inside {"\n", CR}) begin
						$write({2{"  "}});
					end
				end
				$display();
			end

			examples.header.accept(this); // visit_table_row(examples.header)

			foreach (examples.rows[i]) begin
				examples.rows[i].accept(this); // visit_table_row(examples.rows[i])
			end
			$display();
			
		endtask : visit_examples

		/**
		 * @param feature -
		 */
		virtual task visit_feature(gherkin_pkg::feature feature);
			$display({"# language: ", feature.language});

			foreach (feature.tags[i]) begin
				feature.tags[i].accept(this); // visit_tag(feature.tags[i])
			end

			$display(feature.keyword, ": ", feature.feature_name);

			$write({1{"  "}});
			foreach (feature.description[i]) begin
				byte c = feature.description[i];

				$write(string'(c));
				if (c == "\n") begin
					$write({1{"  "}});
				end
			end
			$display();

			foreach(feature.scenario_definitions[i]) begin
				feature.scenario_definitions[i].accept(this);
			end
		endtask : visit_feature

		virtual task visit_gherkin_document(gherkin_pkg::gherkin_document gherkin_document);
			foreach (gherkin_document.comments[i]) begin
				gherkin_document.comments[i].accept(this); // visit_comment(gherkin_document.comments[i])
			end

			gherkin_document.feature.accept(this); // visit_feature(gherkin_document.feature)

		endtask : visit_gherkin_document

		virtual task visit_scenario(gherkin_pkg::scenario scenario);
			foreach (scenario.tags[i]) begin
				scenario.tags[i].accept(this); // visit_tag(scenario.tags[i])
			end

			$display({1{"  "}}, scenario.keyword, ": ", scenario.scenario_definition_name);

			$write({2{"  "}});
			foreach (scenario.description[i]) begin
				byte c = scenario.description[i];

				$write(string'(c));
				if (c == "\n") begin
					$write({2{"  "}});
				end
			end
			$display();

			foreach (scenario.steps[i]) begin
				scenario.steps[i].accept(this); // visit_step(scenario.steps[i])
			end
			$display();
			
		endtask : visit_scenario

		virtual task visit_scenario_definition(gherkin_pkg::scenario_definition scenario_definition);
		endtask : visit_scenario_definition

		virtual task visit_scenario_outline(gherkin_pkg::scenario_outline scenario_outline);
			foreach (scenario_outline.tags[i]) begin
				scenario_outline.tags[i].accept(this); // visit_tag(scenario_outline.tags[i])
			end

			$display({1{"  "}}, scenario_outline.keyword, ": ", scenario_outline.scenario_definition_name);

			$write({2{"  "}});
			foreach (scenario_outline.description[i]) begin
				byte c = scenario_outline.description[i];

				$write(string'(c));
				if (c == "\n") begin
					$write({2{"  "}});
				end
			end
			$display();

			foreach (scenario_outline.steps[i]) begin
				scenario_outline.steps[i].accept(this); // visit_step(scenario_outline.steps[i])
			end
			$display();

			foreach (scenario_outline.examples[i]) begin
				scenario_outline.examples[i].accept(this); // visit_examples(scenario_outline.examples[i])
			end

		endtask : visit_scenario_outline

		virtual task visit_step(gherkin_pkg::step step);
			$display({2{"  "}}, step.keyword, " ", step.text);
			if (step.argument != null) begin
				step.argument.accept(this);
			end
		endtask : visit_step

		virtual task visit_step_argument(gherkin_pkg::step_argument step_argument);
			// Nothing to do
		endtask : visit_step_argument

		virtual task visit_table_cell(gherkin_pkg::table_cell table_cell);
			$write({" ", table_cell.value, " |"});
		endtask : visit_table_cell

		virtual task visit_table_row(gherkin_pkg::table_row table_row);
			$write({{2{"  "}}, "|"});
			foreach (table_row.cells[i]) begin
				table_row.cells[i].accept(this); // visit_table_cell(table_row.cells[i])
			end
			$display();
		endtask : visit_table_row

		/**
		 * @param tag -
		 */
		virtual task visit_tag(gherkin_pkg::tag tag);
		// TODO Auto-generated task stub

		endtask : visit_tag

	endclass : gherkin_document_printer

	class gherkin_document_runner extends uvm_object implements gherkin_pkg::visitor;

		gherkin_pkg::gherkin_document document;
		gherkin_pkg::background feature_background;

		uvm_sequencer_base sequencer;
		uvm_sequence_base parent_sequence;
		feature_sequence current_feature_seq;
		scenario_sequence current_scenario_seq;
		int sequence_priority;
		bit sequence_call_pre_post;
      uvm_phase starting_phase;
		string example_values[string];
		string current_step_keyword;
		bit dry_run;
		int starting_scenario_number;
		int stopping_scenario_number;

		`uvm_object_utils_begin(gherkin_document_runner)
			`uvm_field_object(document, UVM_ALL_ON)
			`uvm_field_int(dry_run, UVM_ALL_ON)
			`uvm_field_int(starting_scenario_number, UVM_ALL_ON | UVM_DEC)
			`uvm_field_int(stopping_scenario_number, UVM_ALL_ON | UVM_DEC)
		`uvm_object_utils_end

		function new(string name = "gherkin_document_runner");
			super.new(name);

			current_feature_seq = null;
			current_scenario_seq = null;
			current_step_keyword = "Given";
			feature_background = null;
			starting_scenario_number = 0;
			stopping_scenario_number = 0;
		endfunction : new


		static function gherkin_document_runner create_new(string name = "gherkin_document_runner", gherkin_pkg::gherkin_document document);
			gherkin_document_runner new_printer;

			new_printer = new(name);
			new_printer.document = document;
			return new_printer;
		endfunction : create_new


		virtual function void configure(
				uvm_sequencer_base sequencer,
				uvm_sequence_base parent_sequence = null,
				int sequence_priority = -1,
				bit sequence_call_pre_post = 1,
          uvm_phase starting_phase,
				bit dry_run = 0,
				int starting_scenario_number = 0,
				int stopping_scenario_number = 0
			);
			this.sequencer = sequencer;
			this.parent_sequence = parent_sequence;
			this.sequence_priority = sequence_priority;
			this.sequence_call_pre_post = sequence_call_pre_post;
          this.starting_phase = starting_phase;
			this.dry_run = dry_run;
			this.starting_scenario_number = starting_scenario_number;
			this.stopping_scenario_number = stopping_scenario_number;
		endfunction : configure


		virtual task run();
			`uvm_info(get_name(), {"\n", sprint()}, UVM_MEDIUM)
			document.accept(this); // visit_gherkin_docment(document)
		endtask : run

		/*
		 * Function: start_step
		 * Executes a sequence passed as Gherkin step.
		 *
		 * Parameters:
		 * wrap - A sequence or sequence item's type as returned by its get_type() method
		 */
		virtual task start_step(gherkin_pkg::step step);

			uvm_object obj;
			uvm_factory factory;
			uvm_sequence_base seq;
			uvm_resource_db#(uvm_object_wrapper)::rsrc_t step_resource;
			uvm_object_wrapper step_seq_object_wrapper;
			step_definition_interface step_seq;
			int success;
			string search_keyword;

			`uvm_info(`get_scope_name(), $sformatf("%s %s", step.keyword, step.text), UVM_MEDIUM)

			if (step.keyword inside {"Given", "When", "Then"}) begin
				// Look for a simple exact match for keyword.
				search_keyword = step.keyword;
			end
			else if (step.keyword inside {"And", "But", "*"}) begin
				// Keyword is syntactic sugar so throw it out and look for the current keyword again.
				search_keyword = current_step_keyword;
			end
			else begin
				`uvm_fatal(get_name(), $sformatf("Illegal step keyword: '%s'", step.keyword))
			end

			`uvm_info_begin(get_name(), "uvm_resource_db search parameters", UVM_HIGH)
          `uvm_message_add_string(step.text)
          `uvm_message_add_string(search_keyword)
			`uvm_info_end
                   
			step_resource = uvm_resource_db#(uvm_object_wrapper)::get_by_name(step.text, STEP_DEF_RESOURCE_NAME, 1);

			assert_step_resource_is_not_null : assert (step_resource) else begin
				if (uvm_get_report_object().get_report_verbosity_level() >= UVM_HIGH) begin
					uvm_resource_db#(uvm_object_wrapper)::dump();
				end
				`uvm_fatal(`get_scope_name(), $sformatf("No match for this step found in `uvm_resource_db`:\n> %s %s", search_keyword, step.text))
			end

			// Success. Update current keyword.
			current_step_keyword = search_keyword;

			step_seq_object_wrapper = step_resource.read();

			factory = uvm_factory::get();

			obj = factory.create_object_by_type(step_seq_object_wrapper, get_full_name(), step_seq_object_wrapper.get_type_name());

			success = $cast(seq ,obj);
			assert_step_object_is_sequence : assert (success) else begin
				`uvm_fatal(`get_scope_name(), $sformatf("Matched an object in `uvm_resource_db` that is not a sequence."))
			end

			if ($cast(step_seq, obj)) begin
				step_nurture step_attributes = step_nurture::type_id::create("step_attributes");
				step_attributes.set_runtime_keyword(step.keyword);
				step_attributes.set_text(step.text);
				step_attributes.set_argument(step.argument);
				step_attributes.set_static_attributes(step_seq.get_step_static_attributes());
				step_attributes.set_current_feature_sequence(current_feature_seq);
				step_attributes.set_current_scenario_sequence(current_scenario_seq);
				step_seq.set_step_attributes(step_attributes);
			end
			else begin
				`uvm_fatal(`get_scope_name(), $sformatf("Matched an object in `uvm_resource_db` that is not a valid step sequence."))
			end

			`uvm_info(get_name(), {"Executing sequence ", seq.get_name(),
					" (", seq.get_type_name(), ")"}, UVM_HIGH)

			seq.print_sequence_info = 1;
			if (!dry_run) begin
              seq.set_starting_phase(starting_phase);
				seq.start(this.sequencer, this.parent_sequence, this.sequence_priority, this.sequence_call_pre_post);
			end

		endtask : start_step

		virtual task visit_background(gherkin_pkg::background background);

			`uvm_info(get_name(), $sformatf("%s: %s", background.keyword, background.scenario_definition_name), UVM_MEDIUM)

			foreach (background.steps[i]) begin
				background.steps[i].accept(this); // visit_step(background.steps[i])
			end

		endtask : visit_background

		/**
		 * @param comment -
		 */
		virtual task visit_comment(gherkin_pkg::comment comment);
		// TODO Auto-generated task stub

		endtask : visit_comment

		/**
		 * @param data_table -
		 */
		virtual task visit_data_table(gherkin_pkg::data_table data_table);
		// TODO Auto-generated task stub

		endtask : visit_data_table

		/**
		 * @param doc_string -
		 */
		virtual task visit_doc_string(gherkin_pkg::doc_string doc_string);
		// TODO Auto-generated task stub

		endtask : visit_doc_string

		/**
		 * @param examples -
		 */
		virtual task visit_examples(gherkin_pkg::examples examples);
		// TODO Auto-generated task stub

		endtask : visit_examples

		virtual task visit_feature(gherkin_pkg::feature feature);
			gherkin_pkg::background feature_background;
			int start;
			int stop;
			gherkin_pkg::scenario_definition only_scenarios[$];

			`uvm_info(get_name(), $sformatf("%s: %s", feature.keyword, feature.feature_name), UVM_MEDIUM);
			
			// Separate background from scenario definitions
			only_scenarios.delete();
			foreach (feature.scenario_definitions[i]) begin
				if ($cast(feature_background, feature.scenario_definitions[i])) begin
					assert_only_one_background : assert (this.feature_background == null) else
						`uvm_fatal_begin(get_name(), "Found more than one background definition")
						`uvm_message_add_string(this.feature_background.scenario_definition_name, "Existing background")
						`uvm_message_add_string(feature_background.scenario_definition_name, "Conflicting background")
						`uvm_fatal_end
					this.feature_background = feature_background;
				end
				else begin
					only_scenarios.push_back(feature.scenario_definitions[i]);
				end
			end

			start = this.starting_scenario_number;
			stop = this.stopping_scenario_number;
			while (start < 0) start += only_scenarios.size();
			if (start > only_scenarios.size()) start = only_scenarios.size();
			while (stop <= 0) stop += only_scenarios.size();
			if (stop > only_scenarios.size()) stop = only_scenarios.size();
				
			for(int i = start; i < stop; i++) begin
				only_scenarios[i].accept(this);
			end

		endtask : visit_feature

		virtual task visit_gherkin_document(gherkin_pkg::gherkin_document gherkin_document);
			current_feature_seq = feature_sequence::type_id::create("current_feature_seq");
			current_feature_seq.set_parent_sequence(parent_sequence);
			current_feature_seq.set_sequencer(sequencer);
			current_feature_seq.set_starting_phase(starting_phase);
			current_feature_seq.set_priority(sequence_priority);

			current_feature_seq.configure(gherkin_document.feature, this);
			current_feature_seq.start(current_feature_seq.get_sequencer());
		endtask : visit_gherkin_document

		virtual task visit_scenario(gherkin_pkg::scenario scenario);

			`uvm_info(get_name(), $sformatf("%s: %s", scenario.keyword, scenario.scenario_definition_name), UVM_MEDIUM)

			current_scenario_seq = scenario_sequence::type_id::create("current_scenario_seq");
			current_scenario_seq.set_parent_sequence(current_feature_seq);
			current_scenario_seq.set_sequencer(sequencer);
			current_scenario_seq.set_starting_phase(starting_phase);
			current_scenario_seq.set_priority(sequence_priority);

			current_scenario_seq.configure(scenario, this, current_feature_seq);
			current_scenario_seq.start(current_scenario_seq.get_sequencer());
		endtask : visit_scenario

		virtual task visit_scenario_definition(gherkin_pkg::scenario_definition scenario_definition);

			// Reset current keyword to default "Given" in case first step is "And" or "But".
			current_step_keyword = "Given";
		endtask : visit_scenario_definition

		virtual task visit_scenario_outline(gherkin_pkg::scenario_outline scenario_outline);

			`uvm_info(get_name(), $sformatf("%s: %s", scenario_outline.keyword, scenario_outline.scenario_definition_name), UVM_MEDIUM)

			foreach (scenario_outline.examples[k]) begin

				foreach (scenario_outline.examples[k].rows[j]) begin
					gherkin_pkg::scenario scenario;
					gherkin_pkg::scenario scenario_definition;
				
					`uvm_info(get_name(), $sformatf("Example #%0d:", j + 1), UVM_MEDIUM)

					example_values.delete();

					// Store the example values in a hash.
					// Put the "<" ears ">" on the key.
					foreach (scenario_outline.examples[k].rows[j].cells[i]) begin
						example_values[{"<", scenario_outline.examples[k].header.cells[i].value, ">"}] = scenario_outline.examples[k].rows[j].cells[i].value;
					end

					// Create a new scenario out of this unrolled scenario outline
                  scenario = gherkin_pkg::scenario::create_new(scenario_outline.get_name(), scenario_outline.scenario_definition_name, scenario_outline.description);
					foreach (scenario_outline.steps[l])
                      scenario.steps.push_back(scenario_outline.steps[l]);
					foreach (scenario_outline.tags[l])
                      scenario.tags.push_back(scenario_outline.tags[l]);
					scenario_definition = scenario;
					// Give our new scenario the full scenario treatment
					scenario_definition.accept(this);

					example_values.delete();

				end

			end

		endtask : visit_scenario_outline


		static function string replace_string(string str, string search, string repl);
			int str_len = str.len();
			int search_len = search.len();
			int i;

			assert_search_string_not_empty : assert (search != "") else
				$fatal(1, "Search string is empty");

			replace_string = "";
			i = 0;
			while (i < str_len) begin
				if (str.substr(i, i + search_len - 1) == search) begin
					replace_string = {replace_string, repl};
					i += search_len;
				end
				else begin
					replace_string = {replace_string, str[i]};
					i++;
				end
			end
		endfunction : replace_string


		virtual task visit_step(gherkin_pkg::step step);
			string example_parameter;
			string replaced_text = step.text;
			gherkin_pkg::step replaced_step;
			gherkin_pkg::data_table data_table;
			gherkin_pkg::doc_string doc_string;
			gherkin_pkg::doc_string replaced_doc_string;

			`uvm_info(get_name(), $sformatf("Before replacement: %s %s", step.keyword, step.text), UVM_HIGH)

			if (example_values.first(example_parameter)) do
					replaced_text = replace_string(replaced_text, example_parameter, example_values[example_parameter]);
				while (example_values.next(example_parameter));

			replaced_step = gherkin_pkg::step::create_new("replaced_step", step.keyword, replaced_text);

			if (step.argument) begin

				if ($cast(data_table, step.argument)) begin
					gherkin_pkg::data_table replaced_data_table;

					replaced_data_table = new("replaced_data_table");

					foreach (data_table.rows[row]) begin
						gherkin_pkg::table_row replaced_table_row;

						replaced_table_row =new("replaced_table_row");
						foreach (data_table.rows[row].cells[col]) begin
							string replaced_cell_value = data_table.rows[row].cells[col].value;

							if (example_values.first(example_parameter)) do
									replaced_cell_value = replace_string(replaced_cell_value, example_parameter, example_values[example_parameter]);
								while (example_values.next(example_parameter));

							replaced_table_row.cells.push_back(gherkin_pkg::table_cell::create_new("anonymous", replaced_cell_value));

						end

						replaced_data_table.rows.push_back(replaced_table_row);

					end

					replaced_step.argument = replaced_data_table;

				end
				else if ($cast(doc_string, step.argument)) begin
				end
				else
					`uvm_fatal(get_name(), "Unexpected type of step argument")
			end


			`uvm_info(get_name(), $sformatf("%s %s", replaced_step.keyword, replaced_step.text), UVM_MEDIUM)
			start_step(replaced_step);
		endtask : visit_step

		/**
		 * @param step_argument -
		 */
		virtual task visit_step_argument(gherkin_pkg::step_argument step_argument);
		// TODO Auto-generated task stub

		endtask : visit_step_argument

		/**
		 * @param table_cell -
		 */
		virtual task visit_table_cell(gherkin_pkg::table_cell table_cell);
		// TODO Auto-generated task stub

		endtask : visit_table_cell

		/**
		 * @param table_row -
		 */
		virtual task visit_table_row(gherkin_pkg::table_row table_row);
		// TODO Auto-generated task stub

		endtask : visit_table_row

		/**
		 * @param tag -
		 */
		virtual task visit_tag(gherkin_pkg::tag tag);
		// TODO Auto-generated task stub

		endtask : visit_tag



	endclass : gherkin_document_runner

endpackage : bathtub_pkg
