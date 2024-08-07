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

`ifndef __PARSE_GHERKIN_DOCUMENT_SVH
`define __PARSE_GHERKIN_DOCUMENT_SVH

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

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_gherkin_document enter", UVM_HIGH, report_object)
	`uvm_message_add_string(line_obj.file_name)
	`uvm_message_add_int(line_obj.line_number, UVM_DEC)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	if (!line_obj.eof) begin
		`uvm_message_add_string(line_obj.text)
	end
	`uvm_info_context_end
	`uvm_info_context(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH, report_object)

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
						`uvm_error_context(`BATHTUB__GET_SCOPE_NAME(), "A Gherkin document can have only one feature", report_object)
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

					"@" : begin : construct_tags
						gherkin_pkg::tag tags[$];

						parse_tags(tags);
						if (status == OK) begin
							while (tags.size() > 0) begin
								floating_tags.push_back(tags.pop_front());
							end
						end
					end

					default : begin
						status = ERROR;
						`uvm_error_context(`BATHTUB__GET_SCOPE_NAME(), {"Syntax error. Expecting \"Feature:\" or \"#\".",
							"\n", line_obj.text}, report_object)
						get_next_line(line_obj);
						break;
					end
				endcase
			end
		endcase
	end

	gherkin_document = new("gherkin_document", gherkin_document_value);
	`push_onto_parser_stack(gherkin_document)

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_gherkin_document exit", UVM_HIGH, report_object)
	`uvm_message_add_tag("status", status.name())
	`uvm_message_add_object(gherkin_document)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_context_end
	`uvm_info_context(`BATHTUB__GET_SCOPE_NAME(), $sformatf("parser_stack: %p", parser_stack), UVM_HIGH, report_object)
endtask : parse_gherkin_document

`endif // __PARSE_GHERKIN_DOCUMENT_SVH
