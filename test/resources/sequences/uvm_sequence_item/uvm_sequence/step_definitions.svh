`ifndef STEP_DEFINITIONS_SVH
`define STEP_DEFINITIONS_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

import bathtub_pkg::step_definition_interface;
`include "bathtub_macros.sv"

class hello_world_vseq extends uvm_sequence implements step_definition_interface;
    `Given("a step definition with no parameters")

    `uvm_object_utils(hello_world_vseq)
    function new (string name="hello_world_vseq");
        super.new(name);
    endfunction : new

    virtual task body();
        `uvm_info(get_name(), "Hello, world!", UVM_HIGH)
        check_name : assert (get_step_static_attributes().get_step_obj_name() == "hello_world_vseq") else
            `uvm_error(get_name(), get_step_static_attributes().get_step_obj_name())
        check_keyword : assert (get_step_static_attributes().get_keyword().name() == "Given") else
            `uvm_error(get_name(), get_step_static_attributes().get_keyword().name())
        check_expression : assert (get_step_static_attributes().get_expression() == "a step definition with no parameters") else
            `uvm_error(get_name(), get_step_static_attributes().get_expression())
        check_regexp : assert (get_step_static_attributes().get_regexp() == "/^a step definition with no parameters$/") else
            `uvm_error(get_name(), get_step_static_attributes().get_regexp())
    endtask : body
endclass : hello_world_vseq

`endif // STEP_DEFINITIONS_SVH
