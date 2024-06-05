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

	class gherkin_parser extends uvm_object implements gherkin_parser_interface;

		typedef struct {
			string token_before_space;
			string token_before_colon;
			string remainder_after_space;
			string remainder_after_colon;
			string secondary_keyword;
			string remainder_after_secondary_keyword;
		} line_analysis_result_t;

		typedef enum {
			OK, ERROR
		} status_t;

		mailbox line_mbox;
		mailbox cell_mbox; // For table row cells
		uvm_object parser_stack[$]; // For bread crumbs
		status_t status;

		`uvm_object_utils_begin(gherkin_parser)
		`uvm_object_utils_end

		function new(string name = "gherkin_parser");
			super.new(name);

			line_mbox = new(1);
			cell_mbox = new(1);
			parser_stack.delete();
		endfunction : new


      	virtual task parse_feature_file(input string feature_file_name, output gherkin_doc_bundle gherkin_doc_bndl);
			integer fd;
			integer code;
			line_value line_obj;
			int line_number;
			gherkin_pkg::gherkin_document gherkin_doc;
				
			`uvm_info_begin(`get_scope_name(), "parse_feature_file enter", UVM_HIGH);
			`uvm_message_add_string(feature_file_name)
			`uvm_info_end

			`uvm_info(`get_scope_name(-2), {"Feature file: ", feature_file_name}, UVM_LOW)

			status = OK;

			fork
				begin : start_gherkin_document_parser
					parse_gherkin_document(gherkin_doc);
					`pop_from_parser_stack(gherkin_doc)
				end

				begin : read_feature_file_and_feed_lines_to_parser

					fd = $fopen(feature_file_name, "r");
					assert_fopen_succeeded : assert (fd != 0) else begin
						string ferror_msg;
						integer errno;

						errno = $ferror(fd, ferror_msg);
						status = ERROR;
						`uvm_fatal(`get_scope_name(-2), ferror_msg)
					end

					line_number = 1;
					while (!$feof(fd)) begin
						string line_buf;

						code = $fgets(line_buf, fd);
						line_obj = new(line_buf, feature_file_name, line_number);
						line_number++;
						line_mbox.put(line_obj);
					end

					$fclose(fd);

					line_obj = new(.eof (1),
						.text (""),
						.file_name (feature_file_name)
					); // Special signal that file is done
					line_mbox.put(line_obj);
				end
			join

			gherkin_doc_bndl = null;
			if (status == OK) begin
				gherkin_doc_bndl = new(
					.document (gherkin_doc),
					.file_name (feature_file_name)
				);
			end
			
			`uvm_info_begin(`get_scope_name(), "parse_feature_file exit", UVM_HIGH);
			`uvm_message_add_tag("status", status.name)
			`uvm_message_add_object(gherkin_doc)
			`uvm_info_end

		endtask : parse_feature_file


		function void analyze_line(string line_buf, ref line_analysis_result_t result);
			int start_of_keyword;
			int first_space_after_keyword;
			int first_colon_after_keyword;
			byte c;
			static string secondary_strings[] = {"\"\"\"", "|", "@", "#"};

			start_of_keyword = -1;
			first_space_after_keyword = -1;
			first_colon_after_keyword = -1;

			line_buf = bathtub_utils::trim_white_space(line_buf);

			for (int i = 0; i < line_buf.len(); i++) begin
				c = line_buf[i];

				if (start_of_keyword == -1) begin
                  if (!(c inside {" ", "\t", "\n", CR})) begin
						start_of_keyword = i;
					end
				end

				if (start_of_keyword != -1 && first_space_after_keyword == -1) begin
                  if (c inside {" ", "\t", "\n", CR}) begin
						first_space_after_keyword = i;
					end
				end

				if (start_of_keyword != -1 && first_colon_after_keyword == -1) begin
					if (c == ":") begin
						first_colon_after_keyword = i;
					end
				end
			end

			result.token_before_space = bathtub_utils::trim_white_space(line_buf.substr(start_of_keyword, first_space_after_keyword - 1));
			result.token_before_colon = bathtub_utils::trim_white_space(line_buf.substr(start_of_keyword, first_colon_after_keyword - 1));
			result.remainder_after_space = bathtub_utils::trim_white_space(line_buf.substr(first_space_after_keyword + 1, line_buf.len() - 1));
			result.remainder_after_colon = bathtub_utils::trim_white_space(line_buf.substr(first_colon_after_keyword + 1, line_buf.len() - 1));

			result.secondary_keyword = "";
			result.remainder_after_secondary_keyword = "";

			foreach (secondary_strings[i]) begin
				int length = secondary_strings[i].len();
				string leading_string = line_buf.substr(0, length - 1);

				if (leading_string == secondary_strings[i]) begin
					result.secondary_keyword = leading_string;
					result.remainder_after_secondary_keyword = bathtub_utils::trim_white_space(line_buf.substr(length, line_buf.len() - 1));
					break;
				end
			end

		endfunction : analyze_line


		virtual task get_next_line(ref line_value line_obj);
			line_mbox.get(line_obj);
			$write("%s [%4d]: %s", line_obj.file_name, line_obj.line_number, line_obj.text);

			if (!line_obj.eof) begin

				forever begin
					line_mbox.peek(line_obj);

					if (!line_obj.eof) begin

						if (bathtub_utils::trim_white_space(line_obj.text) == "") begin
							// Discard empty lines
							line_mbox.get(line_obj);
							$write("%s [%4d]: %s", line_obj.file_name, line_obj.line_number, line_obj.text);
						end
						else begin
							break;
						end
					end
					else begin
						break;
					end
				end
			end
		endtask : get_next_line


		virtual task split_table_row(ref string cell_values[$], input string line_buf);
			int start_pos;
			int end_pos;
			string cell_value;

			cell_values.delete();
			line_buf = bathtub_utils::trim_white_space(line_buf);

			assert_table_row_starts_with_separator : assert (line_buf[0] == "|") else
				`uvm_fatal(`get_scope_name(-2), $sformatf("%s\nTable row must start with \"|\" separator character", line_buf))

			assert_table_row_ends_with_separator : assert (line_buf[line_buf.len() - 1] == "|") else
				`uvm_fatal(`get_scope_name(-2), $sformatf("%s\nTable row must end with \"|\" separator character", line_buf))

			start_pos = -1;
			end_pos = -1;
			foreach (line_buf[i]) begin
				if (line_buf[i] == "|") begin
					end_pos = i - 1;
					if (start_pos > 0 && end_pos >= start_pos) begin
						cell_value = bathtub_utils::trim_white_space(line_buf.substr(start_pos, end_pos));
						cell_values.push_back(cell_value);
					end
					start_pos = i + 1;
				end
			end
		endtask : split_table_row


		virtual task parse_scenario_description(ref string description, ref line_value line_obj);
			line_analysis_result_t line_analysis_result;

			line_mbox.peek(line_obj);

			`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario_description enter", UVM_HIGH)
			`uvm_message_add_string(line_obj.file_name)
			`uvm_message_add_int(line_obj.line_number, UVM_DEC)
			`uvm_message_add_int(line_obj.eof, UVM_BIN)
			if (!line_obj.eof) begin
				`uvm_message_add_string(line_obj.text)
			end
			`uvm_info_end

			if (!line_obj.eof) begin

				description = "";

				while (status == OK) begin
					if (line_obj.eof) break;
					analyze_line(line_obj.text, line_analysis_result);
					if (line_analysis_result.token_before_space inside {"Given", "When", "Then", "And", "But", "*"}) begin
						break;
					end
					else begin
						description = {description, bathtub_utils::trim_white_space(line_obj.text), "\n"};
						get_next_line(line_obj);
					end
				end

			end

			`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_scenario_description exit", UVM_HIGH)
			`uvm_message_add_string(description)
			`uvm_info_end
		endtask : parse_scenario_description


		virtual task parse_feature_description(ref string description, ref line_value line_obj);
			line_analysis_result_t line_analysis_result;

			line_mbox.peek(line_obj);

			`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_feature_description enter", UVM_HIGH)
			`uvm_message_add_string(line_obj.file_name)
			`uvm_message_add_int(line_obj.line_number, UVM_DEC)
			`uvm_message_add_int(line_obj.eof, UVM_BIN)
			if (!line_obj.eof) begin
				`uvm_message_add_string(line_obj.text)
			end
			`uvm_info_end

			if (!line_obj.eof) begin

				description = "";

				while (status == OK) begin
					if (line_obj.eof) break;
					analyze_line(line_obj.text, line_analysis_result);
					if (line_analysis_result.token_before_colon inside {"Background", "Scenario", "Example", "Scenario Outline", "Scenario Template"}) begin
						break;
					end
					else begin
						description = {description, bathtub_utils::trim_white_space(line_obj.text), "\n"};
						get_next_line(line_obj);
					end
				end

			end

			`uvm_info_begin(`get_scope_name(), "gherkin_parser::parse_feature_description exit", UVM_HIGH)
			`uvm_message_add_string(description)
			`uvm_info_end
		endtask : parse_feature_description


		extern virtual task parse_background(ref gherkin_pkg::background background);
		extern virtual task parse_comment(ref gherkin_pkg::comment comment);
		extern virtual task parse_data_table(ref gherkin_pkg::data_table data_table);
		extern virtual task parse_doc_string(ref gherkin_pkg::doc_string doc_string);
		extern virtual task parse_examples(ref gherkin_pkg::examples examples);
		extern virtual task parse_feature(ref gherkin_pkg::feature feature);
		extern virtual task parse_gherkin_document(ref gherkin_pkg::gherkin_document gherkin_document);
		extern virtual task parse_scenario(ref gherkin_pkg::scenario scenario);
		extern virtual task parse_scenario_definition(ref gherkin_pkg::scenario_definition scenario_definition);
		extern virtual task parse_scenario_outline(ref gherkin_pkg::scenario_outline scenario_outline);
		extern virtual task parse_step(ref gherkin_pkg::step step);
		extern virtual task parse_step_argument(ref gherkin_pkg::step_argument step_argument);
		extern virtual task parse_table_cell(ref gherkin_pkg::table_cell table_cell);
		extern virtual task parse_table_row(ref gherkin_pkg::table_row table_row);
		extern virtual task parse_tag(ref gherkin_pkg::tag tag);

	endclass : gherkin_parser

	`include "parse_background.svh"
	`include "parse_comment.svh"
	`include "parse_data_table.svh"
	`include "parse_doc_string.svh"
	`include "parse_examples.svh"
	`include "parse_feature.svh"
	`include "parse_gherkin_document.svh"
	`include "parse_scenario.svh"
	`include "parse_scenario_definition.svh"
	`include "parse_scenario_outline.svh"
	`include "parse_step.svh"
	`include "parse_step_argument.svh"
	`include "parse_table_cell.svh"
	`include "parse_table_row.svh"
	`include "parse_tag.svh"