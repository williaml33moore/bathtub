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

`ifndef __BATHTUB_PKG_SVH
`define __BATHTUB_PKG_SVH

import uvm_pkg::*;
typedef class step_nurture;

typedef enum {Given, When, Then, And, But, \* } step_keyword_t;
typedef uvm_queue#(string) strings_t;
typedef uvm_pool#(uvm_sequence_base, step_nurture) step_attributes_pool_t;

parameter byte CR = 13; // ASCII carriage return
parameter string STEP_DEF_RESOURCE_NAME = "bathtub_pkg::step_definition_interface";

// Metadata object
const struct {
    string file;
} bathtub_pkg_metadata = '{
    file : "`__FILE__",
    string : ""
};

`include "bathtub_pkg/step_nurture.svh"

`endif // __BATHTUB_PKG_SVH
