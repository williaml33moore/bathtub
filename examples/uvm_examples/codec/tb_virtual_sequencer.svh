`ifndef __TB_VIRTUAL_SEQUENCER_SVH
`define __TB_VIRTUAL_SEQUENCER_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

class tb_virtual_sequencer extends uvm_sequencer;
    reg_dut regmodel;
    vip_sequencer tx_src;
    vip_sequencer vip_sqr;

    function new(input string name="tb_virtual_sequencer", input uvm_component parent=null);
        super.new(name, parent);
    endfunction

    `uvm_component_utils(tb_virtual_sequencer)
endclass: tb_virtual_sequencer

`endif // __TB_VIRTUAL_SEQUENCER_SVH
