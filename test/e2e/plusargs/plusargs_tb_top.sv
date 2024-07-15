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

module plusargs_tb_top();

  import uvm_pkg::*;

  `include "mock_sequencers.svh"

  `include "mock_step_definition_seqs.svh"

  typedef class plusargs_env;
  `include "plusargs_env.svh"

  typedef class severity_system_task_cb;
  `include "severity_system_task_cb.svh"

  typedef class plusarg_bathtub_features_test;
  `include "plusarg_bathtub_features_test.svh"

  typedef class plusarg_bathtub_dryrun_test;
  `include "plusarg_bathtub_dryrun_test.svh"

  typedef class plusarg_bathtub_start_stop_test;
  `include "plusarg_bathtub_start_stop_test.svh"

  severity_system_task_cb my_severity_system_task_cb = new;

  initial begin
    $timeformat(0, 3, "s", 20);
    uvm_report_cb::add(null, my_severity_system_task_cb);
    run_test();
  end


endmodule : plusargs_tb_top
