`ifndef __TB_VIRTUAL_SEQUENCER_SVH
`define __TB_VIRTUAL_SEQUENCER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

interface class codec_step_definition_rif;
    pure virtual function reg_dut regmodel();
    pure virtual function vip_sequencer tx_src();
    pure virtual function vip_sequencer vip_sqr();
endclass : codec_step_definition_rif

class tb_virtual_sequencer#(type ENV=tb_env, type SEQ_RIF=codec_step_definition_rif) extends uvm_sequencer implements codec_step_definition_rif;
    protected ENV env_;

    function new(input string name="tb_virtual_sequencer", input uvm_component parent=null, ENV env=null);
        super.new(name, parent);
        set_env(env);
    endfunction

    virtual function void set_env (ENV env);
        this.env_ = env;
    endfunction : set_env

    virtual function ENV get_env ();
        return this.env_;
    endfunction : get_env

    `uvm_component_utils_begin(tb_virtual_sequencer)
    `uvm_field_object(env_, UVM_ALL_ON)
    `uvm_component_utils_end

    virtual function reg_dut regmodel();
        return get_env().regmodel;
    endfunction : regmodel

    virtual function vip_sequencer tx_src();
        return get_env().tx_src;
    endfunction : tx_src

    virtual function vip_sequencer vip_sqr();
        return get_env().vip.sqr;
    endfunction : vip_sqr
endclass: tb_virtual_sequencer

`endif // __TB_VIRTUAL_SEQUENCER_SVH
