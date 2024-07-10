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

  initial begin
    $timeformat(0, 3, "s", 20);
    run_test();
  end


  class plusargs_env extends uvm_env;
    `uvm_component_utils(plusargs_env)

    mock_object_sequencer mock_seqr;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      mock_seqr = mock_object_sequencer::type_id::create("mock_seqr", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
      ; // Placeholder
    endfunction : connect_phase

  endclass : plusargs_env
  


  class plusarg_bathtub_features_test extends uvm_test;
    `uvm_component_utils(plusarg_bathtub_features_test)
    plusargs_env my_plusargs_env; // uvm_env containing the virtual sequencer
    bathtub_pkg::bathtub bathtub;

    function new(string name = "plusarg_bathtub_features_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      bathtub = bathtub_pkg::bathtub::type_id::create("bathtub");
      super.build_phase(phase);
      my_plusargs_env = plusargs_env::type_id::create("my_plusargs_env", this);
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
      bathtub.configure(my_plusargs_env.mock_seqr);
      fork
        begin
          phase.raise_objection(this);
          bathtub.run_test(phase); // Run Bathtub!
          phase.drop_objection(this);
        end
      
        begin
          uvm_sequence_item item;
          mock_object_sequence_item obj_item;
          bathtub_pkg::step_definition_interface actual_step_def;

          for (int i = 0; i < 2; i++) begin
            phase.raise_objection(this);
            my_plusargs_env.mock_seqr.get_next_item(item);
            my_plusargs_env.mock_seqr.item_done();

            `uvm_info(get_name(), "Got one!", UVM_NONE)
            check_item_received : assert ($cast(obj_item, item));
            check_item_is_a_step : assert ($cast(actual_step_def, obj_item.get_payload()));
            phase.drop_objection(this);
          end
        end
      join
    endtask : run_phase

  endclass : plusarg_bathtub_features_test


  class severity_system_task_cb extends uvm_report_catcher;
    function new (string name="severity_system_task_cb");
      super.new(name);
    endfunction : new

    function action_e catch();
      if (get_severity() == UVM_ERROR) $error;
      if (get_severity() == UVM_FATAL) begin
        set_action(get_action() & ~UVM_EXIT);
        issue();
        $fatal;
      end
      return THROW;
    endfunction : catch
  endclass : severity_system_task_cb

  severity_system_task_cb my_severity_system_task_cb = new;
  initial begin
      uvm_report_cb::add(null, my_severity_system_task_cb);
  end


endmodule : plusargs_tb_top
