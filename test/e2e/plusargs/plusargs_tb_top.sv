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
      phase.raise_objection(this);
      bathtub.run_test(phase); // Run Bathtub!
      phase.drop_objection(this);
    endtask : run_phase

  endclass : plusarg_bathtub_features_test


endmodule : plusargs_tb_top
