`ifndef \bathtub_test.svh
`define \bathtub_test.svh

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "codec_step_definitions.svh"

class bathtub_test extends test;

`uvm_component_utils(bathtub_test)

function new(string name="bathtub_test", uvm_component parent = null);
    super.new(name, parent);
endfunction
      

function void build_phase(uvm_phase phase);
    uvm_sequence_base default_sequence;
    uvm_object_wrapper default_sequence_type;

`ifdef UVM_VERSION_1_0
    default_sequence = new("default_sequence");
    default_sequence_type = uvm_sequence_base::type_id::get();
`else
    default_sequence = null;
    default_sequence_type = null;
`endif

    super.build_phase(phase);

    // Override default sequences set in the base class.
    uvm_config_db#(uvm_object_wrapper)::set(null, "env.vip.sqr.main_phase",
                                            "default_sequence",
                                            default_sequence_type);
    uvm_config_db#(uvm_object_wrapper)::set(null, "env.tx_src.main_phase",
                                            "default_sequence",
                                            default_sequence_type);
    uvm_config_db#(uvm_sequence_base)::set(null, "env.vip.sqr.main_phase",
                                            "default_sequence",
                                            default_sequence);
    uvm_config_db#(uvm_sequence_base)::set(null, "env.tx_src.main_phase",
                                            "default_sequence",
                                            default_sequence);
endfunction : build_phase

task main_phase(uvm_phase phase);
    bathtub_pkg::bathtub bathtub;

    phase.raise_objection(this);

    bathtub = bathtub_pkg::bathtub::type_id::create("bathtub");
    bathtub.configure(env.virtual_sequencer);
    bathtub.run_test(phase); // Run Bathtub!
    phase.drop_objection(this);
endtask : main_phase

endclass : bathtub_test

`endif // \bathtub_test.svh
