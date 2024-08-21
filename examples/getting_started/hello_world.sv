// hello_world.sv

`timescale 1s/1ms
`include "uvm_macros.svh"
`include "bathtub_macros.sv"

program hello_world();

    import uvm_pkg::*;
    
    class echo_step extends uvm_sequence implements bathtub_pkg::step_definition_interface;
        `Given(".*")

        `uvm_object_utils(echo_step)

        function new (string name="echo_step");
            super.new(name);
        endfunction : new

        virtual task body();
            get_step_attributes().print_attributes(UVM_NONE);
        endtask : body
    endclass : echo_step


    class bathtub_test extends uvm_test;
        bathtub_pkg::bathtub bathtub;

        `uvm_component_utils(bathtub_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
            bathtub = new();
        endfunction : new
        
        virtual task run_phase(uvm_phase phase);
            bathtub.run_test(phase);
        endtask : run_phase
    endclass : bathtub_test
    
    initial run_test("bathtub_test");
    
endprogram : hello_world
