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

`timescale 1s/1ms

`include "uvm_macros.svh"

module gherkin_parser_tb_top();

  import uvm_pkg::*;

  typedef class severity_system_task_cb;
  `include "severity_system_task_cb.svh"

  // UVM Tests

  `include "gherkin_parser_tests.svh"

  // Bathtub Step Definition UVM Sequences

  `include "gherkin_parser_step_def_seqs.svh"

  severity_system_task_cb my_severity_system_task_cb = severity_system_task_cb::instantiate("my_severity_system_task_cb").add();

  initial begin
    $timeformat(0, 3, "s", 20);
    run_test();
  end


endmodule : gherkin_parser_tb_top
