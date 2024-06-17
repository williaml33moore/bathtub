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

`include "bathtub_macros.sv"

// ===================================================================
package bathtub_pkg;
// ===================================================================

	// Classes
	typedef class bathtub;
	typedef class bathtub_utils;
	typedef class feature_sequence;
	typedef class gherkin_doc_bundle;
	typedef class gherkin_document_printer;
	typedef class gherkin_document_runner;
	typedef class gherkin_parser;
	typedef class gherkin_step_bundle;
	typedef class line_value;
	typedef class pool_provider;
	typedef class scenario_sequence;
	typedef class step_nature;
	typedef class step_nurture;
	typedef class step_parameter_arg;
	typedef class step_parameters;

	// Main entry point
	`include "bathtub_pkg/bathtub.svh"

	// Interfaces for step definitions
	`include "bathtub_pkg/step_definition_interface.svh"
	`include "bathtub_pkg/step_static_attributes_interface.svh"
	`include "bathtub_pkg/step_attributes_interface.svh"
	`include "bathtub_pkg/step_nature.svh"
	`include "bathtub_pkg/step_parameters.svh"
	`include "bathtub_pkg/feature_sequence_interface.svh"
	`include "bathtub_pkg/scenario_sequence_interface.svh"

endpackage : bathtub_pkg
