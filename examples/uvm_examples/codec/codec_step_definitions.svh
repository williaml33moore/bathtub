`ifndef __CODEC_STEP_DEFINITIONS_SVH
`define __CODEC_STEP_DEFINITIONS_SVH

`ifdef UVM_VERSION_1_0
`define VERSION_ERROR
`endif 
`ifdef UVM_VERSION_1_1
`define VERSION_ERROR
`endif
`ifdef VERSION_ERROR
$error({"\n",
"Detected UVM version ", `UVM_VERSION_STRING, ".", "\n",
"This file requires UVM 1.2 or UVM 2017 (IEEE 1800.2) or later.", "\n",
"For UVM 1.0 or 1.1, use `examples/uvm_examples/codec/uvm-1.0p1/codec_step_definitions.svh` instead.", "\n",
""});
`endif // VERSION_ERROR

`include "uvm_macros.svh"
`include "bathtub_macros.sv"
`include "tb_virtual_sequencer.svh"

import uvm_pkg::*;

virtual class codec_step_definition extends uvm_sequence implements bathtub_pkg::step_definition_interface;
    `virtual_step_definition("abstract base class for step definitions")
    `uvm_declare_p_sequencer(tb_virtual_sequencer)
    function new (string name="codec_step_definition");
        super.new(name);
        set_automatic_phase_objection(1);
    endfunction : new
endclass : codec_step_definition


class transmit_chr_seq extends codec_step_definition;
    `When("the host transmits character 0x%s")
    string chr_str;
    int chr;
    vip_tr tr;

    `uvm_object_utils(transmit_chr_seq)

    function new (string name="transmit_chr_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `step_parameter_get_args_begin()
        // Extract parameters from the step string, e.g.:
        chr_str = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end
        chr = chr_str.atohex();
        `uvm_do_on_with(tr, p_sequencer.tx_src, {chr == local::chr;})
    endtask : body
endclass : transmit_chr_seq


class vip_transmit_chr_seq extends codec_step_definition;
    `When("the VIP transmits character 0x%s")
    string chr_str;
    int chr;
    vip_tr tr;

    `uvm_object_utils(vip_transmit_chr_seq)
    
    function new (string name="vip_transmit_chr_seq");
        super.new(name);
    endfunction : new
    
    virtual task body();
        `step_parameter_get_args_begin()
        // Extract parameters from the step string, e.g.:
        chr_str = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end
        chr = chr_str.atohex();
        `uvm_do_on_with(tr, p_sequencer.vip_sqr, {chr == local::chr;})
    endtask : body
endclass : vip_transmit_chr_seq


`endif // __CODEC_STEP_DEFINITIONS_SVH
