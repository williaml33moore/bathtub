`ifndef __BATHTUB_TEST_SVH
`define __BATHTUB_TEST_SVH

`ifndef UVM_VERSION_1_0
`ifndef UVM_VERSION_1_1
`define VERSION_ERROR
`endif // UVM_VERSION_1_1
`endif // UVM_VERSION_1_0
`ifdef VERSION_ERROR
$error({"\n",
    "Detected UVM version ", `UVM_VERSION_STRING, ".", "\n",
    "This file is intended For UVM 1.0 or 1.1.", "\n",
    "For UVM 1.2 or UVM 2017 (IEEE 1800.2) or later, use `examples/uvm_examples/codec/bathtub_test.svh` instead.", "\n",
    ""});
`endif // VERSION_ERROR

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "tb_virtual_sequencer.svh"
`include "codec_step_definitions.svh"

class bathtub_test extends test;
    bathtub_pkg::bathtub bathtub;
    tb_virtual_sequencer virtual_sequencer;

    `uvm_component_utils(bathtub_test)

    function new(string name="bathtub_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        uvm_sequence_base default_sequence_1, default_sequence_2;
        uvm_object_wrapper default_sequence_type;

        // Empty sequences
        default_sequence_1 = new("default_sequence_1");
        default_sequence_2 = new("default_sequence_2");
        default_sequence_type = uvm_sequence_base::type_id::get();

        super.build_phase(phase);

        bathtub = bathtub_pkg::bathtub::type_id::create("bathtub", this);

        virtual_sequencer = tb_virtual_sequencer#(tb_env)::type_id::create("virtual_sequencer", this);

        // Override default sequences set in the base class.
        uvm_config_db#(uvm_object_wrapper)::set(null, "env.vip.sqr.main_phase",
                                                "default_sequence",
                                                default_sequence_type);
        uvm_config_db#(uvm_object_wrapper)::set(null, "env.tx_src.main_phase",
                                                "default_sequence",
                                                default_sequence_type);
        uvm_config_db#(uvm_sequence_base)::set(null, "env.vip.sqr.main_phase",
                                                "default_sequence",
                                                default_sequence_1);
        uvm_config_db#(uvm_sequence_base)::set(null, "env.tx_src.main_phase",
                                                "default_sequence",
                                                default_sequence_2);
    endfunction : build_phase

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        
        virtual_sequencer.set_env(env);
        bathtub.configure(virtual_sequencer);
    endfunction

    task main_phase(uvm_phase phase);
        phase.raise_objection(this);
        bathtub.run_test(phase); // Run Bathtub!
        phase.drop_objection(this);
    endtask : main_phase

endclass : bathtub_test

`endif // __BATHTUB_TEST_SVH
