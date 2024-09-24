/*
MIT License

Copyright (c) 2024 William L. Moore

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

`ifndef __SNIPPETS_SVH
`define __SNIPPETS_SVH

import uvm_pkg::*;

virtual class snippets extends uvm_object;
    static local int unsigned snippet_counter = 1;

    static function int unsigned get_next_snippet_number();
        return snippet_counter++;
    endfunction : get_next_snippet_number

    static function string create_snippet(gherkin_pkg::step step);
        string class_name;
        string keyword_macro;

        case (step.get_keyword())
            "Given", "When", "Then": keyword_macro = {"`", step.get_keyword()};
            default : keyword_macro = "`Given";
        endcase

        class_name = $sformatf("step_definition_%0d_seq", get_next_snippet_number());
        
        create_snippet = "";
        create_snippet = {create_snippet, "class ", class_name, " extends uvm_pkg::uvm_sequence implements bathtub_pkg::step_definition_interface;", "\n"};
        create_snippet = {create_snippet, "    ", keyword_macro, "(\"", step.get_text(), "\")", "\n"};
        create_snippet = {create_snippet, "    `uvm_object_utils(", class_name, ")", "\n"};
        create_snippet = {create_snippet, "    // Declare the correct virtual sequencer type here", "\n"};
        create_snippet = {create_snippet, "    `uvm_declare_p_sequencer(uvm_sequencer)", "\n"};
        create_snippet = {create_snippet, "    function new (string name=\"", class_name, "\");", "\n"};
        create_snippet = {create_snippet, "        super.new(name);", "\n"};
        create_snippet = {create_snippet, "    endfunction : new", "\n"};
        create_snippet = {create_snippet, "    virtual task body();", "\n"};
        create_snippet = {create_snippet, "        `step_parameter_get_args_begin()", "\n"};
        create_snippet = {create_snippet, "        // Extract parameters from the step string, e.g.:", "\n"};
        create_snippet = {create_snippet, "        // my_arg = `step_parameter_get_next_arg_as(int);", "\n"};
        create_snippet = {create_snippet, "        `step_parameter_get_args_end", "\n"};
        create_snippet = {create_snippet, "        `uvm_error(\"PENDING\", \"** Write code that performs this step's actions here **\")", "\n"};
        create_snippet = {create_snippet, "    endtask : body", "\n"};
        create_snippet = {create_snippet, "endclass : ", class_name, "\n"};
    endfunction : create_snippet

endclass : snippets

`endif // __SNIPPETS_SVH