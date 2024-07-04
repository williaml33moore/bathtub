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

`ifndef __STEP_DEFINITION_SEQ_SVH
`define __STEP_DEFINITION_SEQ_SVH

`include "bathtub_macros.sv"
`include "bathtub_pkg/bathtub_pkg.svh"

typedef class step_nature;
`include "bathtub_pkg/step_nature.svh"

typedef class step_parameters;
`include "bathtub_pkg/step_parameters.svh"

// Interfaces for step definitions
`include "bathtub_pkg/step_parameters_interface.svh"
`include "bathtub_pkg/step_definition_interface.svh"
`include "bathtub_pkg/step_static_attributes_interface.svh"
`include "bathtub_pkg/step_attributes_interface.svh"
`include "bathtub_pkg/feature_sequence_interface.svh"
`include "bathtub_pkg/scenario_sequence_interface.svh"

class step_definition_seq /*extends uvm_sequence implements step_definition_interface*/;
//     `virtual_step_definition(Gxiven , "")

//     function new (string name="step_definition_seq");
//         super.new(name);
//     endfunction : new

//     virtual task body();
//         `step_parameter_get_args_begin()
//         `step_parameter_get_args_end
//     endtask : body
endclass : step_definition_seq

`endif // __STEP_DEFINITION_SEQ_SVH
