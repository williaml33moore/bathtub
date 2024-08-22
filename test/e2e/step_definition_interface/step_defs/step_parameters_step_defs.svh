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

`ifndef __STEP_PARAMETERS_STEP_DEFS_SVH
`define __STEP_PARAMETERS_STEP_DEFS_SVH

`include "uvm_macros.svh"
`include "bathtub_macros.sv"
`include "base_seq.svh"

virtual class receive_integer_argument extends base_seq implements bathtub_pkg::step_definition_interface;
    `virtual_step_definition("Base class for receiving integer arguments that could be decimal, hexadecimal, octal, or binary")

    protected int argument;
    protected string arg_type;
    
    function new (string name="receive_integer_argument");
        super.new(name);
    endfunction : new
    
    virtual task body();
        `step_parameter_get_args_begin()
        arg_type = `step_parameter_get_arg_as(1, string);
        case (arg_type)
            "int" : argument = `step_parameter_get_arg_as(0, int);
            default : `uvm_error("UNEXPECTED TYPE", arg_type)
        endcase
        `step_parameter_get_args_end
        get_current_scenario_sequence().get_int_pool().add("argument", argument);
    endtask : body
endclass : receive_integer_argument

class receive_decimal_argument extends receive_integer_argument;
    `When("a step definition interprets decimal integer %d as a %s")

    `uvm_object_utils(receive_decimal_argument)
    
    function new (string name="receive_decimal_argument");
        super.new(name);
    endfunction : new
endclass : receive_decimal_argument


class receive_hexadecimal_argument extends receive_integer_argument;
    `When("a step definition interprets hexadecimal integer 32'h%h as a %s")
    // This version uses specifier "%h"

    `uvm_object_utils(receive_hexadecimal_argument)
    
    function new (string name="receive_hexadecimal_argument");
        super.new(name);
    endfunction : new
endclass : receive_hexadecimal_argument


class receive_c_style_hexadecimal_argument extends receive_integer_argument;
    `When("a step definition interprets hexadecimal integer 0x%x as a %s")
    // This version uses specifier "%x"; it should be equivalent to "%h".

    `uvm_object_utils(receive_c_style_hexadecimal_argument)
    
    function new (string name="receive_c_style_hexadecimal_argument");
        super.new(name);
    endfunction : new
endclass : receive_c_style_hexadecimal_argument


class receive_octal_argument extends receive_integer_argument;
    `When("a step definition interprets octal integer 32'o%o as a %s")

    `uvm_object_utils(receive_octal_argument)
    
    function new (string name="receive_octal_argument");
        super.new(name);
    endfunction : new
endclass : receive_octal_argument


class receive_octal_argument_without_prefix extends receive_integer_argument;
    `When("a step definition interprets octal integer %o as a %s")
    // If the octal number has a 0 prefix, SystemVerilog should just ignore it.

    `uvm_object_utils(receive_octal_argument_without_prefix)
    
    function new (string name="receive_octal_argument_without_prefix");
        super.new(name);
    endfunction : new
endclass : receive_octal_argument_without_prefix


class check_decimal_argument extends base_seq implements bathtub_pkg::step_definition_interface;
    `Then("the resulting integer value should be %s")

    protected string value_str;
    protected int expected_value;

    `uvm_object_utils(check_decimal_argument)
    
    function new (string name="check_decimal_argument");
        super.new(name);
    endfunction : new

    virtual task body();
        int code;
        int actual_value;
        `step_parameter_get_args_begin()
        // Extract parameters from the step string, e.g.:
        value_str = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end
        code = $sscanf(value_str, "%d", expected_value);
        assert (code) else `uvm_error("SSCANF ERROR", $sformatf("$sscanf(\"%s\", \"%s\", value) returned %0d", value_str, "%d", code))
        
        actual_value = get_current_scenario_sequence().get_int_pool().get("argument");
        check_decimal_argument : assert (actual_value == expected_value) else
            `uvm_error("CHECK", $sformatf("actual_value %0d != expected_value %0d", actual_value, expected_value))
    endtask : body
endclass : check_decimal_argument


`endif // __STEP_PARAMETERS_STEP_DEFS_SVH
