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
    endfunction : new

endclass : plusarg_options

`endif // __PLUSARG_OPTIONS_SVH
