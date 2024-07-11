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

`ifndef __PLUSARG_OPTIONS_SVH
`define __PLUSARG_OPTIONS_SVH

import uvm_pkg::*;

typedef class bathtub_utils;
`include "bathtub_pkg/bathtub_utils.svh"

class plusarg_options;
    string bathtub_features[$];
    uvm_verbosity bathtub_verbosity;
    bit bathtub_dryrun;
    int bathtub_errormax;
    string bathtub_include[$];
    string bathtub_exclude[$];
    int bathtub_start;
    int bathtub_stop;
    bit bathtub_help;
    
    int unsigned num_bathtub_features;
    bit has_bathtub_verbosity;
    bit has_bathtub_dryrun;
    bit has_bathtub_errormax;
    int unsigned num_bathtub_include;
    int unsigned num_bathtub_exclude;
    bit has_bathtub_start;
    bit has_bathtub_stop;
    bit has_bathtub_help;

    function new(
        string bathtub_features[$]='{},
        uvm_verbosity bathtub_verbosity=UVM_MEDIUM,
        bit bathtub_dryrun=1'b0,
        int bathtub_errormax=0,
        string bathtub_include[$]='{},
        string bathtub_exclude[$]='{},
        int bathtub_start=0,
        int bathtub_stop=0,
        bit bathtub_help=1'b0
    );
        this.bathtub_features = bathtub_features;
        this.bathtub_verbosity = bathtub_verbosity;
        this.bathtub_dryrun = bathtub_dryrun;
        this.bathtub_errormax = bathtub_errormax;
        this.bathtub_include = bathtub_include;
        this.bathtub_exclude = bathtub_exclude;
        this.bathtub_start = bathtub_start;
        this.bathtub_stop = bathtub_stop;
        this.bathtub_help = bathtub_help;
    
        num_bathtub_features = 0;
        has_bathtub_verbosity = 1'b0;
        has_bathtub_dryrun = 1'b0;
        has_bathtub_errormax = 1'b0;
        num_bathtub_include = 0;
        num_bathtub_exclude = 0;
        has_bathtub_start = 1'b0;
        has_bathtub_stop = 1'b0;
        has_bathtub_help = 1'b0;
    endfunction : new


    (* fluent *)
    static function plusarg_options create(
        string bathtub_features[$]='{},
        uvm_verbosity bathtub_verbosity=UVM_MEDIUM,
        bit bathtub_dryrun=1'b0,
        int bathtub_errormax=0,
        string bathtub_include[$]='{},
        string bathtub_exclude[$]='{},
        int bathtub_start=0,
        int bathtub_stop=0,
        bit bathtub_help=1'b0
    );
        create = new(
            .bathtub_features (bathtub_features),
            .bathtub_verbosity (bathtub_verbosity),
            .bathtub_dryrun (bathtub_dryrun),
            .bathtub_errormax (bathtub_errormax),
            .bathtub_include (bathtub_include),
            .bathtub_exclude (bathtub_exclude),
            .bathtub_start (bathtub_start),
            .bathtub_stop (bathtub_stop),
            .bathtub_help (bathtub_help)
        );
    endfunction : create


    (* fluent *)
	virtual function plusarg_options populate();
		string plusarg_values[$];
		string plusarg_value;
		string plusarg_feature_files[$];

		num_bathtub_features = uvm_cmdline_processor::get_inst().get_arg_values("+bathtub_features=", plusarg_values);
        foreach (plusarg_values[i]) begin
            bathtub_utils::split_string(plusarg_values[i], plusarg_feature_files);
            foreach (plusarg_feature_files[j]) begin
                bathtub_features.push_back(plusarg_feature_files[j]);
            end
        end

        has_bathtub_dryrun = $test$plusargs("bathtub_dryrun") ? 1'b1 : 1'b0;
        if (has_bathtub_dryrun) begin
            bathtub_dryrun = 1'b1;
        end

        return this;
	endfunction : populate

endclass : plusarg_options

`endif // __PLUSARG_OPTIONS_SVH
