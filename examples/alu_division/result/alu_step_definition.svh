`ifndef ALU_STEP_DEFINITION_SVH
`define ALU_STEP_DEFINITION_SVH

import bathtub_pkg::*;

class set_operand_A_and_B_vseq extends alu_base_vsequence implements bathtub_pkg::step_definition_interface;
    `Given("operand A is %d and operand B is %d")
    int operand_A, operand_B;
   `uvm_object_utils(set_operand_A_and_B_vseq)
    function new (string name="set_operand_A_and_B_vseq");
        super.new(name);
    endfunction : new
    virtual task body();
        // Extract the parameters
        `step_parameter_get_args_begin()
        operand_A = `step_parameter_get_next_arg_as(int);
        operand_B = `step_parameter_get_next_arg_as(int);
        `step_parameter_get_args_end
        // Do the actual work using the API in the base sequence
        super.set_operand_A(operand_A); 
        super.set_operand_B(operand_B);
    endtask : body
endclass : set_operand_A_and_B_vseq



class check_DIV_BY_ZERO_flag_vseq extends alu_base_vsequence implements bathtub_pkg::step_definition_interface;
    `Then("the DIV_BY_ZERO flag should be %s")
    string flag_arg;
    bit expected_flag;
    bit actual_flag;
  `uvm_object_utils(check_DIV_BY_ZERO_flag_vseq)
    function new (string name="check_DIV_BY_ZERO_flag_vseq");
        super.new(name);
    endfunction : new
    virtual task body();
        // Extract the parameter
        `step_parameter_get_args_begin()
        flag_arg = `step_parameter_get_next_arg_as(string);
        `step_parameter_get_args_end
        case (flag_arg) // convert the string to a bit value
            "raised", "asserted" : expected_flag = 1;
            "clear", "deasserted" : expected_flag = 0;
            default: `uvm_error("UNEXPECTED ARG", flag_arg)
        endcase
        super.get_div_by_zero_flag(actual_flag);
        check_DIV_BY_ZERO_flag : assert (expected_flag === actual_flag) else
            `uvm_error("MISMATCH", $sformatf("expected %b; actual %b", expected_flag, actual_flag)) 
    endtask : body
endclass : check_DIV_BY_ZERO_flag_vseq


class do_division_operation_vseq extends alu_base_vsequence implements bathtub_pkg::step_definition_interface;
  `When("the ALU performs the division operation")
  int operation;
  `uvm_object_utils(do_division_operation_vseq)
  function new (string name="do_division_operation_vseq");
    super.new(name);
  endfunction : new
  virtual task body();
    operation = DIVIDE;
    super.do_operation(operation);
  endtask : body
endclass : do_division_operation_vseq


class check_result_vseq extends alu_base_vsequence implements bathtub_pkg::step_definition_interface;
  `Then("the result should be %d")
    int expected_result;
  	int actual_result;
  `uvm_object_utils(check_result_vseq)
    function new (string name="check_DIV_BY_ZERO_flag_vseq");
        super.new(name);
    endfunction : new
    virtual task body();
        // Extract the parameter
        `step_parameter_get_args_begin()
      expected_result = `step_parameter_get_next_arg_as(int);
        `step_parameter_get_args_end
      super.get_result(actual_result);
      check_result : assert (expected_result === actual_result) else
        `uvm_error("MISMATCH", $sformatf("expected %0d; actual %0d", expected_result, actual_result)) 
    endtask : body
endclass : check_result_vseq
          
`endif // ALU_STEP_DEFINITION_SVH