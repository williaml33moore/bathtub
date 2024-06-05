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

// ===================================================================
package bathtub_pkg;
// ===================================================================

	import uvm_pkg::*;
	
	typedef enum {Given, When, Then, And, But, \* } step_keyword_t;
	
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
	`include "gherkin_parser/gherkin_parser_interface.svh"
	`include "gherkin_parser/gherkin_parser.svh"
	`include "gherkin_document_printer/gherkin_document_printer.svh"
	`include "gherkin_document_runner/gherkin_document_runner.svh"

endpackage : bathtub_pkg
