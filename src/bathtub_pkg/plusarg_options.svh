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
    string bathtub_include[$];
    string bathtub_exclude[$];
    int bathtub_start;
    int bathtub_stop;
    bit bathtub_help;
    
    int unsigned num_bathtub_features;
    bit has_bathtub_verbosity;
    bit has_bathtub_dryrun;
    int unsigned num_bathtub_include;
    int unsigned num_bathtub_exclude;
    bit has_bathtub_start;
    bit has_bathtub_stop;
    bit has_bathtub_help;

    function new(
        string bathtub_features[$]='{},
        uvm_verbosity bathtub_verbosity=UVM_MEDIUM,
        bit bathtub_dryrun=1'b0,
        string bathtub_include[$]='{},
        string bathtub_exclude[$]='{},
        int bathtub_start=0,
        int bathtub_stop=0,
        bit bathtub_help=1'b0
    );
        this.bathtub_features = bathtub_features;
        this.bathtub_verbosity = bathtub_verbosity;
        this.bathtub_dryrun = bathtub_dryrun;
        this.bathtub_include = bathtub_include;
        this.bathtub_exclude = bathtub_exclude;
        this.bathtub_start = bathtub_start;
        this.bathtub_stop = bathtub_stop;
        this.bathtub_help = bathtub_help;
    
        num_bathtub_features = 0;
        has_bathtub_verbosity = 1'b0;
        has_bathtub_dryrun = 1'b0;
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
		string split_values[$];
        uvm_cmdline_processor clp;

        clp = uvm_cmdline_processor::get_inst();

        has_bathtub_help = $test$plusargs("bathtub_help") ? 1'b1 : 1'b0;
        if (has_bathtub_help) begin
            print_usage();
            uvm_root::get().die();
        end

		num_bathtub_features = clp.get_arg_values("+bathtub_features=", plusarg_values);
        foreach (plusarg_values[i]) begin
            bathtub_utils::split_string(plusarg_values[i], split_values);
            foreach (split_values[j]) begin
                bathtub_features.push_back(split_values[j]);
            end
        end

        has_bathtub_dryrun = $test$plusargs("bathtub_dryrun") ? 1'b1 : 1'b0;
        if (has_bathtub_dryrun) begin
            bathtub_dryrun = 1'b1;
        end

		has_bathtub_start = clp.get_arg_value("+bathtub_start=", plusarg_value) ? 1'b1 : 1'b0;
        if (has_bathtub_start) begin
            bathtub_start = plusarg_value.atoi();
        end

		has_bathtub_stop = clp.get_arg_value("+bathtub_stop=", plusarg_value) ? 1'b1 : 1'b0;
        if (has_bathtub_stop) begin
            bathtub_stop = plusarg_value.atoi();
        end

        has_bathtub_verbosity = clp.get_arg_value("+bathtub_verbosity=", plusarg_value) ? 1'b1 : 1'b0;
        if (has_bathtub_verbosity) begin
            bathtub_verbosity = str_to_verbosity(plusarg_value);
        end

		num_bathtub_include = clp.get_arg_values("+bathtub_include=", plusarg_values);
        foreach (plusarg_values[i]) begin
            uvm_split_string(plusarg_values[i], ",", split_values);
            foreach (split_values[j]) begin
                bathtub_include.push_back(split_values[j]);
            end
        end

		num_bathtub_exclude = clp.get_arg_values("+bathtub_exclude=", plusarg_values);
        foreach (plusarg_values[i]) begin
            uvm_split_string(plusarg_values[i], ",", split_values);
            foreach (split_values[j]) begin
                bathtub_exclude.push_back(split_values[j]);
            end
        end

        return this;
	endfunction : populate


    static function void print_usage();
        string usage;
        int unsigned max_plusarg_len;

        struct {
            string p; // Plusarg
            string d; // Description
        } options[$];

        options.push_back('{
            p : "+bathtub_help",
            d : "Print this help message then immediately exit"
        });

        options.push_back('{
            p : "+bathtub_features=<files>",
            d : "Whitespace-separated list of Gherkin feature file paths. Relative paths are relative to simulation run directory."
        });

        options.push_back('{
            p : "+bathtub_verbosity=<verbosity>",
            d : "UVM verbosity level for messages generated by the Bathtub object. Defaults to your overall verbosity, i.e., as set by +UVM_VERBOSITY."
        });

        options.push_back('{
            p : "+bathtub_dryrun",
            d : "Parse the Gherkin files but do not run them"
        });

        options.push_back('{
            p : "+bathtub_include=<tags>",
            d : "Comma-separated list of Gherkin tags. Only scenarios that have or inherit these tags will run. E.g., +bathtub_include=@smoke,@registers"
        });

        options.push_back('{
            p : "+bathtub_exclude=<tags>",
            d : "Comma-separated list of Gherkin tags. Scenarios that have or inherit these tags will not run. E.g., +bathtub_exclude=@long"
        });

        options.push_back('{
            p : "+bathtub_start=<number>",
            d : "Zero-based index of the scenario to start running with. Default=0."
        });

        options.push_back('{
            p : "+bathtub_stop=<number>",
            d : "Zero-based index of the scenario to stop running with. Default=0, meaning run all scenarios."
        });

        max_plusarg_len = 0;
        foreach (options[i]) begin
            if (options[i].p.len() > max_plusarg_len) max_plusarg_len = options[i].p.len();
        end

        usage = {
            "\n",
            "Bathtub BDD Command-Line Plusarg Options\n",
            "========================================\n",
            ""
        };

        foreach (options[i]) begin
            usage = {usage,
            options[i].p,
            {(max_plusarg_len + 4 - options[i].p.len()){" "}},
            options[i].d,
            "\n"
            };
        end

        usage = {usage,
            "----------------------------------------\n"
        };

        $info(usage);
    endfunction : print_usage


    // Convert string to uvm_verbosity value.
    // Code adapted from uvm_root::m_check_verbosity().

    static function uvm_verbosity str_to_verbosity(string verb_string);
        int verbosity;

        case(verb_string)
            "UVM_NONE"    : verbosity = UVM_NONE;
            "NONE"        : verbosity = UVM_NONE;
            "UVM_LOW"     : verbosity = UVM_LOW;
            "LOW"         : verbosity = UVM_LOW;
            "UVM_MEDIUM"  : verbosity = UVM_MEDIUM;
            "MEDIUM"      : verbosity = UVM_MEDIUM;
            "UVM_HIGH"    : verbosity = UVM_HIGH;
            "HIGH"        : verbosity = UVM_HIGH;
            "UVM_FULL"    : verbosity = UVM_FULL;
            "FULL"        : verbosity = UVM_FULL;
            "UVM_DEBUG"   : verbosity = UVM_DEBUG;
            "DEBUG"       : verbosity = UVM_DEBUG;
            default       : begin
                verbosity = verb_string.atoi();
                if(verbosity > 0)
                    uvm_report_info("NSTVERB", $sformatf("Non-standard verbosity value, using provided '%0d'.", verbosity), UVM_NONE);
                if(verbosity == 0) begin
                    verbosity = UVM_MEDIUM;
                    uvm_report_warning("ILLVERB", "Illegal verbosity value, using default of UVM_MEDIUM.", UVM_NONE);
                end
            end
        endcase
        return uvm_verbosity'(verbosity);
    endfunction : str_to_verbosity


endclass : plusarg_options




`endif // __PLUSARG_OPTIONS_SVH
