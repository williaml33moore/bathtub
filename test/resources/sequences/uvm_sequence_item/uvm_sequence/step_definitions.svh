`ifndef STEP_DEFINITIONS_SVH
`define STEP_DEFINITIONS_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

class hello_world_vseq extends uvm_sequence /*implements step_definition_interface*/;
    /*`Given("a working step definition")*/

    `uvm_object_utils(hello_world_vseq)
    function new (string name="hello_world_vseq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_info(get_name(), "Hello, world!", UVM_NONE)
    endtask : body
endclass : hello_world_vseq

`endif // STEP_DEFINITIONS_SVH
