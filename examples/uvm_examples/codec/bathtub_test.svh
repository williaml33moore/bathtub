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

    super.build_phase(phase);

    // Override default sequences set in the base class.
    uvm_config_db#(uvm_object_wrapper)::set(null, "env.vip.sqr.main_phase",
                                            "default_sequence",
                                            null);
    uvm_config_db#(uvm_object_wrapper)::set(null, "env.tx_src.main_phase",
                                            "default_sequence",
                                            null);
    uvm_config_db#(uvm_sequence_base)::set(null, "env.vip.sqr.main_phase",
                                            "default_sequence",
                                            null);
    uvm_config_db#(uvm_sequence_base)::set(null, "env.tx_src.main_phase",
                                            "default_sequence",
                                            null);
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
