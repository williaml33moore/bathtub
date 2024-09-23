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

`ifndef __BATHTUB_INTERFACE_SVH
`define __BATHTUB_INTERFACE_SVH

import uvm_pkg::*;

`include "uvm_macros.svh"

`include "bathtub_pkg/bathtub_pkg.svh"

typedef class plusarg_options;

interface class bathtub_interface;

    pure virtual function void configure(
                uvm_sequencer_base sequencer,
                uvm_sequence_base parent_sequence = null,
                int sequence_priority = 100,
                bit sequence_call_pre_post = 1
            );
    pure virtual function plusarg_options get_plusarg_opts();
    pure virtual function strings_t get_feature_files();
    pure virtual function void concat_feature_files(string files[$]);
    pure virtual function void push_back_feature_file(string file);
    pure virtual function void set_report_object(uvm_report_object report_object);
    pure virtual function uvm_report_object get_report_object();
    pure virtual function uvm_sequencer_base get_sequencer();
    pure virtual function int get_sequence_priority();
    pure virtual function bit get_sequence_call_pre_post();
    pure virtual function bit get_dry_run();
    pure virtual function int get_starting_scenario_number();
    pure virtual function int get_stopping_scenario_number();
    pure virtual function strings_t get_include_tags();
    pure virtual function strings_t get_exclude_tags();
    pure virtual function void concat_undefined_steps(gherkin_pkg::step steps[$]);
    pure virtual function uvm_sequence_base as_sequence();

endclass : bathtub_interface

`include "bathtub_pkg/plusarg_options.svh"

`endif // __BATHTUB_INTERFACE_SVH
