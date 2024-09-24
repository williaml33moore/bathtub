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

`ifndef __PARSE_SCENARIO_DEFINITION_SVH
`define __PARSE_SCENARIO_DEFINITION_SVH

task gherkin_parser::parse_scenario_definition(ref gherkin_pkg::scenario_definition scenario_definition);
	line_value line_obj;
	line_analysis_result_t line_analysis_result;

	line_mbox.peek(line_obj);

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_scenario_definition enter", UVM_HIGH, report_object)
	`uvm_message_add_string(line_obj.file_name)
	`uvm_message_add_int(line_obj.line_number, UVM_DEC)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	if (!line_obj.eof) begin
		`uvm_message_add_string(line_obj.text)
	end
	`uvm_info_context_end

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
				`uvm_error_context(`BATHTUB__GET_SCOPE_NAME(), {"Unexpected keyword: ", line_analysis_result.token_before_colon,
					". Expecting \"Background:\", \"Scenario\", \"Example\", \"Scenario Outline\", or \"Scenario Template\""}, report_object)
			end
		endcase
	end

	`uvm_info_context_begin(`BATHTUB__GET_SCOPE_NAME(), "gherkin_parser::parse_scenario_definition exit", UVM_HIGH, report_object)
	`uvm_message_add_tag("status", status.name())
	`uvm_message_add_object(scenario_definition)
	`uvm_message_add_int(line_obj.eof, UVM_BIN)
	`uvm_info_context_end
endtask : parse_scenario_definition

`endif // __PARSE_SCENARIO_DEFINITION_SVH
