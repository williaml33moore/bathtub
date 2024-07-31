/*
MIT License

Copyright (c) 2024 William L. Moore

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

`ifndef __STEP_DEFINITION_INTERFACE_STEP_DEFS_SVH
`define __STEP_DEFINITION_INTERFACE_STEP_DEFS_SVH

`include "uvm_macros.svh"
import uvm_pkg::*;

`include "bathtub_macros.sv"
import bathtub_pkg::bathtub_pkg_metadata;

/*
 * Driver sequence base class sets the sequence item type.
 */
class base_seq extends uvm_sequence#();

    `uvm_object_utils(base_seq)
    `uvm_declare_p_sequencer(uvm_sequencer)

    function new (string name="base_seq");
        super.new(name);
    endfunction : new
endclass : base_seq

/*
 * Example of a virtual step definition
 */
virtual class virtual_step_def_seq extends base_seq implements bathtub_pkg::step_definition_interface;
    `virtual_step_definition("Any text goes here")

    static const string return_value_$var_name = "var_return_value";

    function new (string name="virtual_step_def_seq");
        super.new(name);
    endfunction : new

    // Return a copy of the given string with the trailing character removed.
    static function string trim(string s);
        return s.substr(0, s.len() - 2);
    endfunction : trim
endclass : virtual_step_def_seq


// Given I store the value "42" in an item called "i" in the "scenario" "integer" pool
class store_value_in_pool_seq extends virtual_step_def_seq;
    `Given("I store the value \"%s in an item called \"%s in the \"%s \"%s pool")

    string value;
    string var_name;
    string pool;
    string var_type;

    `uvm_object_utils(store_value_in_pool_seq)
    function new (string name="store_value_in_pool_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `step_parameter_get_args_begin()
        value = trim(`step_parameter_get_next_arg_as(string));
        var_name = trim(`step_parameter_get_next_arg_as(string));
        pool = trim(`step_parameter_get_next_arg_as(string));
        var_type = trim(`step_parameter_get_next_arg_as(string));
        `step_parameter_get_args_end

        case (pool)
            "scenario" : begin
                case (var_type)
                    "integer" : get_current_scenario_sequence().get_int_pool().add(var_name, value.atoi());
                    "string" : get_current_scenario_sequence().get_string_pool().add(var_name, value);
                    default : `uvm_error("Unknown var_type", var_type)
                endcase
            end
            "test" : begin
                case (var_type)
                    "integer" : get_current_test_sequence().get_int_pool().add(var_name, value.atoi());
                    "string" : get_current_test_sequence().get_string_pool().add(var_name, value);
                    default : `uvm_error("Unknown var_type", var_type)
                endcase
            end
            default :`uvm_error("Unknown pool", pool)
        endcase
    endtask : body
endclass : store_value_in_pool_seq


// When I read item "i" from the "scenario" "integer" pool
class read_value_from_pool_seq extends virtual_step_def_seq;
    `When("I read item \"%s from the \"%s \"%s pool")

    string var_name;
    string pool;
    string var_type;

    `uvm_object_utils(read_value_from_pool_seq)
    function new (string name="read_value_from_pool_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `step_parameter_get_args_begin()
        var_name = trim(`step_parameter_get_next_arg_as(string));
        pool = trim(`step_parameter_get_next_arg_as(string));
        var_type = trim(`step_parameter_get_next_arg_as(string));
        `step_parameter_get_args_end

        case (pool)
            "scenario" : begin
                case (var_type)
                    "integer" : begin
                        int return_value;

                        if (!get_current_scenario_sequence().get_int_pool().exists(var_name)) begin
                            `uvm_warning(`BATHTUB__GET_SCOPE_NAME(), $sformatf("%s %s pool item %s does not exist", pool, var_type, var_name))
                        end
                        return_value = get_current_scenario_sequence().get_int_pool().get(var_name);
                        get_current_scenario_sequence().get_int_pool().add(return_value_$var_name, return_value);
                    end
                    default : `uvm_error("Unknown var_type", var_type)
                endcase
            end
            "test" : begin
                case (var_type)
                    "integer" : begin
                        int return_value;

                        if (!get_current_test_sequence().get_int_pool().exists(var_name)) begin
                            `uvm_warning(`BATHTUB__GET_SCOPE_NAME(), $sformatf("%s %s pool item %s does not exist", pool, var_type, var_name))
                        end
                        return_value = get_current_test_sequence().get_int_pool().get(var_name);
                        // Return_value is always stored in the scenario pool.
                        get_current_scenario_sequence().get_int_pool().add(return_value_$var_name, return_value);
                    end
                    "string" : begin
                        string return_value;

                        if (!get_current_test_sequence().get_string_pool().exists(var_name)) begin
                            `uvm_warning(`BATHTUB__GET_SCOPE_NAME(), $sformatf("%s %s pool item %s does not exist", pool, var_type, var_name))
                        end
                        return_value = get_current_test_sequence().get_string_pool().get(var_name);
                        // Return_value is always stored in the scenario pool.
                        get_current_scenario_sequence().get_string_pool().add(return_value_$var_name, return_value);
                    end
                    default : `uvm_error("Unknown var_type", var_type)
                endcase
            end
            default :`uvm_error("Unknown pool", pool)
        endcase
    endtask : body
endclass : read_value_from_pool_seq


// Then the returned "integer" value should be "42"
class check_return_value_seq extends virtual_step_def_seq;
    `Then("the returned \"%s value should be \"%s")

    string var_type;
    string expected_value;

    `uvm_object_utils(check_return_value_seq)
    function new (string name="check_return_value_seq");
        super.new(name);
    endfunction : new

    virtual task body();
        `step_parameter_get_args_begin()
        var_type = trim(`step_parameter_get_next_arg_as(string));
        expected_value = trim(`step_parameter_get_next_arg_as(string));
        `step_parameter_get_args_end
        
        case (var_type)
            "integer" : begin
                int act_value;
                int exp_value;

                act_value = get_current_scenario_sequence().get_int_pool().get(return_value_$var_name);
                exp_value = expected_value.atoi();
                check_return_value : assert (act_value == exp_value)
                    `uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("act_value: %0d, exp_value: %0d", act_value, exp_value), UVM_HIGH)
                else
                    `uvm_error(`BATHTUB__GET_SCOPE_NAME(), $sformatf("act_value: %0d, exp_value: %0d", act_value, exp_value))
            end
            "string" : begin
                string act_value;
                string exp_value;

                act_value = get_current_scenario_sequence().get_string_pool().get(return_value_$var_name);
                exp_value = expected_value;
                check_return_value : assert (act_value == exp_value)
                    `uvm_info(`BATHTUB__GET_SCOPE_NAME(), $sformatf("act_value: '%s', exp_value: '%s'", act_value, exp_value), UVM_HIGH)
                else
                    `uvm_error(`BATHTUB__GET_SCOPE_NAME(), $sformatf("act_value: '%s', exp_value: '%s'", act_value, exp_value))
            end
            default : `uvm_error("Unknown var_type", var_type)
        endcase
    endtask : body
endclass : check_return_value_seq

`endif // __STEP_DEFINITION_INTERFACE_STEP_DEFS_SVH
