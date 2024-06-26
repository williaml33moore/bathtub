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

`ifndef __GHERKIN_PARSER_INTERFACE_SVH
`define __GHERKIN_PARSER_INTERFACE_SVH

typedef class gherkin_doc_bundle;
`include "bathtub_pkg/gherkin_doc_bundle.svh"

interface class gherkin_parser_interface;
	pure virtual task parse_feature_file(input string feature_file_name, output gherkin_doc_bundle gherkin_doc_bndl);
	pure virtual task parse_feature_lines(const ref string feature_array[], output gherkin_doc_bundle gherkin_doc_bndl);
	pure virtual task parse_feature_string(input string feature, output gherkin_doc_bundle gherkin_doc_bndl);
endclass : gherkin_parser_interface;

`endif // __GHERKIN_PARSER_INTERFACE_SVH
