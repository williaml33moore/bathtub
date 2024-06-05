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
