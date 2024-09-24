`include "uvm_macros.svh"

module top();

  import uvm_pkg::*;
  
  typedef enum {ADD=0, SUBTRACT=1, MULTIPLY=2, DIVIDE=3} op_type;
  typedef enum {OKAY=0, DIV_BY_ZERO=1, OP_ERR=2} status_type;

  alu_if vif();
  alu dut(vif);

  initial begin
    $timeformat(0, 3, "s", 20);
    uvm_config_db#(virtual alu_if)::set(uvm_coreservice_t::get().get_root(), "top", "vif", vif);
    run_test();
  end


  class alu_sequencer extends uvm_sequencer#(uvm_sequence_item);
    `uvm_component_utils(alu_sequencer)
    virtual alu_if vif;

    function new (string name="alu_sequencer", uvm_component parent) ;
      super.new(name, parent);
    endfunction : new
  endclass


  class alu_env extends uvm_env;
    `uvm_component_utils(alu_env)

    alu_sequencer alu_vseqr;
    virtual alu_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      alu_vseqr = alu_sequencer::type_id::create("alu_vseqr", this);
    endfunction : build_phase

    virtual function void connect_phase(uvm_phase phase);
      bit ok;

      ok = uvm_config_db#(virtual alu_if)::get(uvm_coreservice_t::get().get_root(), "top", "vif", vif);
      assert (ok);
      assert_vif_not_null : assert (vif != null);
      alu_vseqr.vif = vif;
    endfunction : connect_phase

  endclass : alu_env
  
  
  class alu_base_vsequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(alu_base_vsequence)
    `uvm_declare_p_sequencer(alu_sequencer)
    
    function new(string name="alu_base_vsequence");
      super.new(name);
      set_automatic_phase_objection(1);
    endfunction : new
    
    task set_operand_A(bit[15:0] operand_A);
      `uvm_info(get_name(), "set_operand_A", UVM_MEDIUM)
      p_sequencer.vif.driver.operand_a = operand_A;
    endtask : set_operand_A
    
    task set_operand_B(bit[15:0] operand_B);
      `uvm_info(get_name(), "set_operand_B", UVM_MEDIUM)
      p_sequencer.vif.driver.operand_b = operand_B;
    endtask : set_operand_B
    
    task do_operation(bit[3:0] operation);
      `uvm_info(get_name(), "set_operation", UVM_MEDIUM)
      p_sequencer.vif.driver.operation = operation;
    endtask : do_operation
    
    task get_result(output bit[31:0] result);
      `uvm_info(get_name(), "get_result", UVM_MEDIUM)
      result = p_sequencer.vif.driver.result;
    endtask : get_result
    
    task get_div_by_zero_flag(output bit div_by_zero_flag);
      bit[31:0] status;
      `uvm_info(get_name(), "get_div_by_zero_flag", UVM_MEDIUM)
      status = p_sequencer.vif.driver.status;
      div_by_zero_flag = status[DIV_BY_ZERO];
    endtask : get_div_by_zero_flag
    
  endclass : alu_base_vsequence


  class bathtub_test extends uvm_test;
    `uvm_component_utils(bathtub_test)
    alu_env my_alu_env; // uvm_env containing the virtual sequencer
    bathtub_pkg::bathtub bathtub;

    function new(string name = "bathtub_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
      bathtub = bathtub_pkg::bathtub::type_id::create("bathtub", this);
      super.build_phase(phase);
      my_alu_env = alu_env::type_id::create("my_alu_env", this);
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
      bathtub.configure(my_alu_env.alu_vseqr); // Virtual sequencer
      bathtub.push_back_feature_file("alu_division.feature"); // Feature file
      phase.raise_objection(this);
      bathtub.run_test(phase); // Run Bathtub!
      phase.drop_objection(this);
    endtask : run_phase

  endclass : bathtub_test

      
`include "alu_step_definition.svh"

endmodule : top
