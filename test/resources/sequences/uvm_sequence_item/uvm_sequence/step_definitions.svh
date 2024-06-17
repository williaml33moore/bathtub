`ifndef STEP_DEFINITIONS_SVH
`define STEP_DEFINITIONS_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

import bathtub_pkg::step_definition_interface;
import bathtub_pkg::scenario_sequence_interface;
`include "bathtub_macros.sv"

/*
Checks its own static attributes.
*/
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


/*
Checks its own parameters against a fixed magic string.
*/
class hello_parameters_vseq extends uvm_sequence implements step_definition_interface;
    `Given("a step definition with parameters %d, %f, and %s")

    static string magic_step_text = "a step definition with parameters 42, 98.6, and Gherkin";

    `uvm_object_utils(hello_parameters_vseq)
    function new (string name="hello_parameters_vseq");
        super.new(name);
    endfunction : new
    
    virtual task body();
        int i;
        real f;
        string s;

        `step_parameter_get_args_begin()
        i = `step_parameter_get_next_arg_as(int);
        f = `step_parameter_get_next_arg_as(real);
        s = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end
        assert (i == 42) `uvm_info(get_name(), $sformatf("i=%0d", i), UVM_HIGH) else
            `uvm_error(get_name(), $sformatf("i=%0d", i))
        assert (f == 98.6) `uvm_info(get_name(), $sformatf("f=%f", f), UVM_HIGH) else
            `uvm_error(get_name(), $sformatf("f=%f", f))
        assert (s == "Gherkin") `uvm_info(get_name(), $sformatf("s='%s'", s), UVM_HIGH) else
            `uvm_error(get_name(), $sformatf("s='%s'", s))
    endtask : body
endclass : hello_parameters_vseq


/*
Writes its own parameters to the sequence pool so they can be checked externally.
*/
class hello_parameters_pool_vseq extends uvm_sequence implements step_definition_interface;
    `Given("a step definition with parameters %d, %f, and %s")

    // Partial magic string; the caller supplies the rest of the string with parameters.
    static string magic_step_text = "a step definition with parameters ";

    `uvm_object_utils(hello_parameters_pool_vseq)
    function new (string name="hello_parameters_pool_vseq");
        super.new(name);
    endfunction : new
    
    virtual task body();
        scenario_sequence_interface pools;
        int i;
        real f;
        string s;

        `step_parameter_get_args_begin()
        i = `step_parameter_get_next_arg_as(int);
        f = `step_parameter_get_next_arg_as(real);
        s = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end
        pools = get_current_scenario_sequence();
        pools.get_int_pool().add("i", i);
        pools.get_real_pool().add("f", f);
        pools.get_string_pool().add("s", s);
    endtask : body
endclass : hello_parameters_pool_vseq


/*
Sends its own parameters out as sequence items so they can be checked externally.
*/
class hello_parameters_seq_item_vseq extends uvm_sequence implements step_definition_interface;
    `Given("a step definition with parameters %d, %f, and %s")

    // Partial magic string; the caller supplies the rest of the string with parameters.
    static string magic_step_text = "a step definition with parameters ";

    `uvm_object_utils(hello_parameters_seq_item_vseq)
    function new (string name="hello_parameters_seq_item_vseq");
        super.new(name);
    endfunction : new
    
    virtual task body();
        int i;
        real f;
        string s;

        `step_parameter_get_args_begin()
        i = `step_parameter_get_next_arg_as(int);
        f = `step_parameter_get_next_arg_as(real);
        s = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end

        // Stash data in the req name as a string; use the name as storage for payload.
        req = new($sformatf("i: %0d", i));
        start_item(req);
        finish_item(req);
        
        req = new($sformatf("f: %f", f));
        start_item(req);
        finish_item(req);
        
        req = new($sformatf("s: %s", s));
        start_item(req);
        finish_item(req);
    endtask : body
endclass : hello_parameters_seq_item_vseq


/*
Sends its own parameters out as sequence items with `uvm_do macros so they can be checked externally.
*/
class hello_parameters_seq_item_uvm_do_vseq extends uvm_sequence implements step_definition_interface;
    `Given("a step definition with parameters %d, %f, and %s")

    // Partial magic string; the caller supplies the rest of the string with parameters.
    static string magic_step_text = "a step definition with parameters ";

    `uvm_object_utils(hello_parameters_seq_item_uvm_do_vseq)
    function new (string name="hello_parameters_seq_item_uvm_do_vseq");
        super.new(name);
    endfunction : new
    
    virtual task body();
        int i;
        real f;
        string s;

        `step_parameter_get_args_begin()
        i = `step_parameter_get_next_arg_as(int);
        f = `step_parameter_get_next_arg_as(real);
        s = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end

        // Stash data in the req name as a string; use the name as storage for payload.
        req = new($sformatf("i: %0d", i));
        `uvm_do(req)
        
        req = new($sformatf("f: %f", f));
        `uvm_do(req)
        
        req = new($sformatf("s: %s", s));
        `uvm_do(req)
    endtask : body
endclass : hello_parameters_seq_item_uvm_do_vseq

`endif // STEP_DEFINITIONS_SVH
